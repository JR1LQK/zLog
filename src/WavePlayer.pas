//This file introduces a class that is able to play waves from resource,
//memory and disk via TStream class. It uses WAVE_MAPPER instead of PlaySound,
//so that you can play waves simultaneously.

//Copyright(c) 2001-2002 by Ing. Tomas Koutny. (rawos@rawos.com, xdtktom@quick.cz)
//Version 1.7
//This file is freeware. AUTHOR does not take any responsibility of possible
//direct or indirect damage caused by this SOFTWARE PRODUCT.

//See www.rawos.com for more software and resources.

//If you would like to use this file somehow or if you would like to comment
//something, please send me e-mail so that I can have some feedback
//on releasing such kind of files.

(*
 * Version History:
 *
 *
 * Version 1.7
 *
 * + Chunks after 'data' one are no longer being played
 *   => No more strange sounds if 'data' chunk is not the last one.
 *
 * Version 1.6
 *
 * + TWavePlayer.Stop no longer waits for infinity with sleep 
 *
 * Version 1.5
 *
 * + Playback functions were made virtual including constructor
 * + New class TFakeWavePlayer to produce sound when TWavePlayer crashes
 *
 * Version 1.0
 *
 * + fixed bugs related to the playback stopping
 * + now able to play via synchronyous device
 *
 * Version 0.94
 *
 * + fixed bugs, which occurred in stop and destructor 
 *
 * Version 0.93
 *
 * + now can beep on Play in case of failure
 * + fixed for configurations, which are able to play only one sound
 *   simultaneously
 *
 * Version 0.92
 * + fixed cbSize treatment with PCM wavs loading
 *
 * Version 0.91
 * + new properties to control the count of loops to be played
 * = properties Stream and Loop were made published
 *
 * Version 0.9
 * * Initial release
 *)

unit WavePlayer;

interface

uses classes, windows, mmsystem;


type
  TWavePlayingState = (wpStopped, wpPlaying, wpPaused);

  TWavePlayer = class
  private
    FDevice:HWAVEOUT;                //Device to play the wave
    FBuffers:array[0..7] of TWAVEHDR;//8 buffers to have not chopping playback
    FBufferSize:integer;             //How much memory to allocate per buffer
    FRepeat:boolean;                 //Whether to play in a loop
    FDataStart:integer;              //Where the headers end
    FDataEnd:integer;                //Length of data (+1 to avoid one asm add
                                     //in LoadBuffer) ; data chunk is not
                                     //always the last one
    FPlayingBufferCount:integer;     //Number of buffers being played
    procedure LoadBuffer(AIndex:integer);  //Loads values into selected buffer
  protected
    FState:TWavePlayingState;  //Internal (and desired) state
    FSource:TStream;           //Source the wave will be played from
        //Following two variables may be figured out by setting FRepeat to true
    FLoopsToPlay:integer;      //Remaining count of loops to be played
    FDesiredLoops:integer;     //Desired count of loops to be played
    FBeepAtLeast:boolean;

   procedure waveOutProc(hwo:HWAVEOUT; uMsg:UINT; dwInstance:DWORD;
                          dwParam1:DWORD; dwParam2:DWORD);  virtual;
                          //Plays the wave
  public
    constructor Create; virtual;
    destructor Destroy; override;

    //All functions below return true if they proceed successfuly
    //and false if not.
    function Play:boolean;  virtual;     //Starts or unpauses the wave playing
    function Stop:boolean;  virtual;    //Stops the current wave playing
    function Reset:boolean; virtual;    //Rewinds to zero and stops playing
    function Pause:boolean; virtual;    //Pauses or unpauses the wave playing

    property State:TWavePlayingState read FState;
  published
    //The Source property MUST be set before the wave playing is started!
    //(The riff file format uses 32 bit adressing => the standard stream
    // is sufficient.)
    property Source:TStream read FSource write FSource;
     //The Loop property should be also set before the wave playing is started,
    //because all internal buffers are being queued regardless of this value.
    property Loop:boolean read FRepeat write FRepeat;

    property Loops:integer read FDesiredLoops write FDesiredLoops;

    property BeepAtLeast:boolean read FBeepAtLeast write FBeepAtLeast;
  end;

  TFakeWaveMode = (none,            //No faking at all; default
                   message,         //MessageBeep(MB_OK)
                   speaker,         //System beep via speaker
                   silence);        //No playback will ever occur

  TFakeWavePlayer = class(TWavePlayer)
  protected
    FFakeMode:TFakeWaveMode;
    FOddPause:boolean;  //Needed to simulate un/pausing
  public
    constructor Create; override;

    function Play:boolean;  override;
    function Stop:boolean;  override;
    function Reset:boolean; override;
    function Pause:boolean; override;
  published
    property FakeMode:TFakeWaveMode read FFakeMode write FFakeMode;
        //NEVER CHANGE DURING A PLAYBACK!!!
  end;

implementation

uses SysUtils;

const
  BlocksInBuffer = 512; //2048000; //How much blocks will be in one buffer - now
                         //0.0116 of a second in the PCM uncompressed mode.
                         //Small value makes playing chopping, the big one
                         //makes play stopping hard.

  WaveHdrSize = sizeof(TWAVEHDR); //Why to call sizeof so much times?

//Declare the wave file header's structure
type
  TWAVHeader = packed record
    RIFFHeader: packed array [0..3] of Char;   //'RIFF'
    FileSize: Longint;
    WAVEHeader: packed array [0..3] of Char;   //'WAVE'
    FormatHeader: packed array [0..3] of Char; //'fmt ' - there's a space!
    FormatSize: Longint;
    FormatEx:TWaveFormatEx;
  end;

  TChunk = packed record
    Signature:LongWord;
    Length:longint;
  end;

procedure waveOutProc(hwo:HWAVEOUT; uMsg:UINT; dwInstance:DWORD;
                          dwParam1:DWORD; dwParam2:DWORD); stdcall;
begin
  //because the instance id represents a class pointer, this procedure will just
  //try to forward the call
  TWavePlayer(dwInstance).waveOutProc(hwo, uMsg, dwInstance,
                                      dwParam1, dwParam2);
end;

//--------------------------------------------------------------- Class' methods

constructor TWavePlayer.Create;
begin
  FState:=wpStopped;
  FRepeat:=false;
  BeepAtLeast:=false;
end;

destructor TWavePlayer.Destroy;
begin
  try
    Stop;
  except
  end;

  inherited;
end;

procedure TWavePlayer.waveOutProc(hwo:HWAVEOUT; uMsg:UINT; dwInstance:DWORD;
                          dwParam1:DWORD; dwParam2:DWORD);
var i:integer;
begin
  case uMsg of
    //WOM_CLOSE: exit;//No reason to do something here
    WOM_DONE:begin
               //Using hwo is faster than FDevice since it is in a register
               waveOutUnprepareHeader(hwo,
                                      PWAVEHDR(dwParam1),
                                      WaveHdrSize);
               dec(FPlayingBufferCount);

               if FState = wpStopped then exit;
                        //Presume that stopping is in progress

               //Get data
               LoadBuffer(PWAVEHDR(dwParam1)^.dwUser);

               //Check for end of wave
               if PWAVEHDR(dwParam1)^.dwBufferLength = 0 then
                 begin
                   if FRepeat or (FLoopsToPlay>0) then  //Play once again or not?
                     begin
                       FSource.Position:=FDataStart;
                       LoadBuffer(PWAVEHDR(dwParam1)^.dwUser);
                       waveOutWrite(hwo, PWAVEHDR(dwParam1), WaveHdrSize);
                       dec(FLoopsToPlay);
                       if FLoopsToPlay<0 then FLoopsToPlay:=0;
                     end else
                       if FPlayingBufferCount<1 then
                         try
                           //No more data to play => properly end the playback
                           FState:=wpStopped;
                           waveOutReset(hwo); //it may hang up without this 
                           waveOutClose(hwo);//Some devices are able to play
                                             //only one sound=>close it
                                             //and hope that only one sound
                                             //is desired to be played
                           for i:=0 to 7 do
                             freemem(FBuffers[i].lpData);
                         except
                         end;
                 end else
                   waveOutWrite(hwo, PWAVEHDR(dwParam1), WaveHdrSize);
             end;
    //WOM_OPEN:exit;  //Nothing to play so soon
  end;
end;

procedure TWavePlayer.LoadBuffer(AIndex:integer);
var LoadableBufferSize:integer;
begin
  with FBuffers[AIndex], FSource do
    begin
      dwFlags:=0;

      LoadableBufferSize:=FDataEnd-Position-FBufferSize;
      if LoadableBufferSize>=0 then LoadableBufferSize:=FBufferSize
        else inc(LoadableBufferSize, FBufferSize);

      dwBufferLength:=Read(lpData^, LoadableBufferSize);
      if dwBufferLength = 0 then exit; //no data to be played

      if waveOutPrepareHeader(FDevice, @FBuffers[AIndex], WaveHdrSize) =
         MMSYSERR_NOERROR then inc(FPlayingBufferCount);
    end;
end;

function TWavePlayer.Play:boolean;
var WaveHdr:TWAVHeader;
    WaveInfo:PWaveFormatEx;
    i:integer;
    chunk:TChunk;

begin
  //There can be a case instead of this 2 ifs, but the compiler will optimize it

  if FState = wpPlaying then
    begin
      result:=false;
      exit;
    end;

  //Check for unpause
  if FState = wpPaused then
    begin
      result:=Pause;
      exit;
    end;

  //if anything will go wrong, then an exception will arise
  WaveInfo:=nil; //keeps compiler quiet
  try
    //Firstly we have to gather required info about wave from selected source
    FSource.Position:=0;
    FSource.ReadBuffer(WaveHdr, sizeof(TWAVHeader));

    //check for PCM files
    with WaveHdr.FormatEx do
      if wFormatTag = WAVE_FORMAT_PCM then
        begin
          cbSize:=0; //sanity assignment
          FSource.Position:=WaveHdr.FormatSize+20;
                 //Some programs takes cbSize as a header member and some don't,
                 //but all programs (I've seen) fills FormatSize correctly
        end;

    getmem(WaveInfo, WaveHdr.FormatEx.cbSize+sizeof(TWaveFormatEx));
    WaveInfo^:=WaveHdr.FormatEx;

    //And load the rest of format dependent data if any
    FSource.ReadBuffer(pointer(Cardinal(WaveInfo)+sizeof(TWaveFormatEx))^,
                       WaveInfo^.cbSize);

    //Skip all chunks, that we're not interested in
    FSource.ReadBuffer(chunk, sizeof(chunk));
    while chunk.Signature <> $61746164 do //<> 'data'
      begin
        FSource.position:=FSource.position+chunk.Length; //seek doesn't function
        FSource.ReadBuffer(chunk, sizeof(chunk));
      end;
    //Remember the file island of the 'data' chunk
    FDataStart:=FSource.position;
    FDataEnd:=FDataStart+chunk.Length;

    FLoopsToPlay:=FDesiredLoops-1; //One loop will be always played
    FPlayingBufferCount:=0;        //None is actually being played

    //Allocate Buffers
    FBufferSize:=WaveInfo^.nBlockAlign*BlocksInBuffer;
    for i:=0 to 7 do
      begin
        getmem(FBuffers[i].lpData, FBufferSize);
        FBuffers[i].dwLoops:=1;
        FBuffers[i].dwUser:=i;
      end;

    //Open the WAVE_MAPPER,
    if waveOutOpen(@FDevice, WAVE_MAPPER, WaveInfo,
                   dword(@WavePlayer.waveOutProc),
                   cardinal(Self),
                   CALLBACK_FUNCTION  or WAVE_ALLOWSYNC) <> MMSYSERR_NOERROR
       then Abort;
    freemem(WaveInfo);

    //load buffers
    for i:=0 to 7 do
      LoadBuffer(i);

    //and play them.
    FState:=wpPlaying; //Mark desired state
    for i:=0 to 7 do
      if FBuffers[i].dwBufferLength <> 0 then
         waveOutWrite(FDevice, @FBuffers[i], WaveHdrSize);

    result:=true;
  except
    FState:=wpStopped;

    freemem(WaveInfo);
    for i:=0 to 7 do
      freemem(FBuffers[i].lpData);
    result:=false;

    if FBeepAtLeast then Windows.MessageBeep(MB_ICONQUESTION);

    FState:=wpStopped;
  end;
end;

function TWavePlayer.Stop:boolean;
var i:integer;
begin
  result:=false;

  if FState = wpStopped then exit;

  try
    //if not Reset then Abort;  //This call sets FState to wpStopped
    FState:=wpStopped; //This will stop loading the buffers

    //Actually a call to waveOutReset should be here, but it always hangs up
    //current thread => try to close the device right now

    if waveOutClose(FDevice) <> MMSYSERR_NOERROR then
      //Successfull waveOutClose sends WOM_DONE for all buffers
      //=>waveOutProc unprepares and frees them
      begin
        //OK, we can still try to stop the playback without any reset

        i:=16;   //Countdown - Forever Is Long Long Time
        while (FPlayingBufferCount>0) and (i>0) do
          begin
            Sleep(100);
            dec(i);
          end;

        if waveOutClose(FDevice) <> MMSYSERR_NOERROR then Abort;

        //Because we've waited with demand to immediately stop loading buffers,
        //we've to release them manualy
        for i:=0 to 7 do
          freemem(FBuffers[i].lpData);
      end;

    result:=true;
  except
  end;
end;

function TWavePlayer.Reset:boolean;
begin
  try
    FState:=wpStopped; //--This will at least stop loading the buffers
    if waveOutReset(FDevice) <> MMSYSERR_NOERROR then Abort;

    result:=true;
  except
    result:=false;
  end;
end;

function TWavePlayer.Pause:boolean;
begin
  try
    case FState of
      wpStopped:Abort;
      wpPlaying:begin
                  FState:=wpPaused; //Mark desired state
                  if waveOutPause(FDevice) <> MMSYSERR_NOERROR then Abort;
                end;
      wpPaused: begin
                  FState:=wpPlaying; //Mark desired state
                  if waveOutRestart(FDevice) <> MMSYSERR_NOERROR then Abort;
                end;
    end;
    result:=true;
  except
    result:=false;
  end;
end;

//---------------------------------------------------------------TFakeWavePlayer

constructor TFakeWavePlayer.Create;
begin
  inherited;

  FFakeMode:=none;
  FOddPause:=false;
end;

function TFakeWavePlayer.Play:boolean;
begin
  result:=true;  //Anything else then non has to return true
  case FFakeMode of
    none:       result:=inherited Play;
    message     :MessageBeep(MB_OK);
    speaker     :MessageBeep($FFFFFFFF);
    //none:     OK, so let's be silent
  end;
end;

function TFakeWavePlayer.Stop:boolean;
begin
  if FFakeMode = none then result:=inherited Stop
    else result:=true;
end;

function TFakeWavePlayer.Reset:boolean;
begin
  if FFakeMode = none then result:=inherited Reset
    else result:=true;
end;

function TFakeWavePlayer.Pause:boolean;
begin
  if FFakeMode = none then result:=inherited Pause
    else begin
      FOddPause:=not FOddPause;
      if FOddPause then result:=Play
        else result:=true;
    end

end;

end.
