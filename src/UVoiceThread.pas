unit UVoiceThread;

interface

uses
  Classes, MMSystem, SysUtils, Windows, UOptions, BGK32LIB, WavePlayer;


var
  WP : TWavePlayer;
  FS : TFileStream;

type
  TVoiceThread = class(TThread)
  private
    { Private declarations }
    _filename : string;
    _loop : boolean;
    _looptime : integer;
  protected
    procedure Execute; override;
  public
    constructor Create(FileName : string; Loop : boolean; LoopTime : integer);
    procedure Pause;
    function Playing : boolean;
    // looptime is in millisec.
  end;

procedure BreakLoop;
//function VoicePlaying : boolean;

implementation

var Break : boolean;

{ Important: Methods and properties of objects in VCL can only be used in a
  method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure VoiceThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ VoiceThread }

procedure BreakLoop;
begin
  Break := True;
end;

procedure TVoiceThread.Pause;
begin
  if WP <> nil then
    WP.Pause;
end;

function TVoiceThread.Playing : boolean;
begin
  Result := False;
  if WP = nil then
    exit;
  if WP.State = wpPlaying then
    Result := True;
end;

constructor TVoiceThread.Create(FileName : string; Loop : boolean; LoopTime : integer);
begin
  _filename := FileName;
  _loop := Loop;
  _looptime := LoopTime;
  Break := False;
  //Playing := False;
  FreeOnTerminate := True;
  //WP := TWavePlayer.Create;
  FS := TFileStream.Create(_FileName, fmOpenRead or fmShareDenyNone);
  WP.Loop := False;
  WP.Source := FS;
  inherited Create(False);
end;

procedure TVoiceThread.Execute;
var //P : PChar;
    start : TDateTime;

begin
  //P := StrAlloc(256);
  //StrPCopy(P, _filename);
  if Not(_loop) then
    begin
      if Options.PTTEnabled then
        BGK32LIB.ControlPTT(True);
      BGK32LIB.SetVoiceFlag(1);
      WP.Play;
      Repeat
        SleepEx(10,False);
      until (WP.State = wpStopped) or Terminated;
      //PlaySound(P ,0, snd_FileName or snd_Sync);
      BGK32LIB.SetVoiceFlag(0);
      if Options.PTTEnabled then
        BGK32LIB.ControlPTT(False);
    end
  else
    begin
      while not(Terminated) and not(Break) do
        begin
          if Options.PTTEnabled then
            BGK32LIB.ControlPTT(True);
          BGK32LIB.SetVoiceFlag(1);
          //PlaySound(P, 0, snd_FileName or snd_Sync);
          //WP.Reset;
          WP.Play;
          Repeat
            SleepEx(50,False);
          until (WP.State = wpStopped) or Terminated;
          if Terminated then
            WP.Stop;
          BGK32LIB.SetVoiceFlag(0);
          if Options.PTTEnabled then
            BGK32LIB.ControlPTT(False);
          start := Time;
          repeat
            SleepEx(10,False);
          until Break or Terminated or (Trunc((Time - start)*24*60*60*1000) >= _looptime)
        end;
    end;
  { Place thread code here }
  //StrDispose(P);
  WP.Stop;
  repeat until WP.State = wpStopped;
  //WP.Free;
  FS.Free;
end;

initialization
  WP := TWavePlayer.Create;
end.
