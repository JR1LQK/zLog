unit BGK32Lib2; {Background keying engine ver. 2}

interface

var BGKRefresh : boolean; // set to true after a char is sent

const IBMPC = 0; {machine code as defined in BGK32.DLL}
      NEC98 = 255;

      // mask data for data port
      _rigmask : byte = $00; // bit mask for sel rig
      _pttmask : byte = $00; // bit mask for ptt
      _bandmask : byte = $00; //bit mask for band data
      _voicemask : byte = $00; // bit mask for voice memory

type TKeyingPort = (tkpParallel, tkpSerial1, tkpSerial2);
const KeyingPort : TKeyingPort = tkpParallel;

procedure UpdateDataPort; // sets data port acc to mask data
procedure SetRigFlag(i : integer); // 0 : no rigs, 1 : rig 1, etc
procedure SetVoiceFlag(i : integer); //0 or 1
procedure ReverseLogicKeying(KeyReverse : boolean); // _cwon, _cwoff
procedure SetPTT(_on : boolean);
function PTTIsOn : boolean;
procedure SetPTTDelay(before, after : word);
procedure ControlPTT(PTTON : boolean); {Sets PTT on/off}
function Paused : boolean; {Returns True if SendOK is False}
function GetLoopCount : integer; {Returns the current loop count}
procedure SetLoopMax(Max : integer); {Sets the maximum loop count}
function GetLoopMax : word; {Returns the maximum loop count}
procedure SetPitch(Hertz : integer); {Sets the pitch of the side tone}
function GetPitch : word; {Returns the current pitch in Hz}
procedure SetCWSendBufChar( C : char ); {Adds a char to the end of buffer}
procedure SetCWSendBufCharPTT( C : char ); {Adds a char to the end of buffer. Also controls PTT if enabled. Called from Keyboard}
Procedure SetCWSendBuf( b: byte; S :ShortString ); {Sets str to buffer but does not start sending}
procedure SendStr(sStr : ShortString); {Sends a string (Overwrites buffer)}
procedure SendStrLoop(S : ShortString); {Sends a string (repeat CQmax times)}
procedure SendStrFIFO(sStr : ShortString); {Sends a string (adds to buffer)}
procedure TimerProcess(uTimerID, uMessage: Word;
                       dwUser, dw1, dw2: Longint); stdcall;
//procedure TimerProcessEX;
procedure SetCWSpeed(_WPM : word); {Sets CW speed 1-60 wpm}
procedure SetLoopTime(Tsec : Real); {Sets the pause between repeats}
function GetLoopTime : real; {Returns the loop time in seconds}
procedure InitializeBGK(msec : integer); {Initializes BGK. msec is interval}
function CloseBGK : word; {Closes BGK}
procedure PauseCW; {Pause}
procedure ResumeCW; {Resume}
procedure IncWPM; {Increases CW speed by 1WPM}
procedure DecWPM; {Decreases CW speed by 1WPM}
procedure SetWeight(W : word); {Sets the weight 0-100 %}
procedure SetSideTone(B : boolean); {Turn on/off side tone (TRUE=ON FALSE=OFF)}
procedure SetCWPort(i : integer); {Sets CW port to LPT i}
function GetCWPort : ShortString; {Gets current port LPT?}
procedure SetMachine(M : word); {Sets machine as well as CW port address}
function GetMachine : word; {Returns machine code 98 or IBM}
function GetVersion : real; {Returns the current version of BGK32.DLL}
procedure ClrBuffer; {Stops CW and clears buffer}
procedure CancelLastChar; {BackSpace}
procedure SetCallSign(S : ShortString); {Update realtime callsign}
function CallSignSent : boolean; {Returns true if realtime callsign is sent already}
function IsPlaying : boolean;
procedure SetRandCQStr(Str1, Str2 : shortstring);
procedure SetPTTPortDirect(p : word);
procedure SetCWPortDirect(p : word);
procedure SetPaddlePortDirect(p : word);
procedure PaddleProcess;
procedure ReversePaddle(boo : boolean);
procedure SetSpaceFactor(R : integer);
procedure SetEISpaceFactor(R : integer);
function LeftInBuffer : word; {returns # char left in buffer}
procedure TuneOn;
procedure SetCode(C : Char; Code : string);

implementation


// 1.04 added 'b' [BK]
// 1.05 added '-', '=' [BT];
// 1.10 started working on paddle input
// 1.11 port set to 0 in PauseCW
// 1.12 PRTport output set to $01 or $00
// 1.20 first working version of paddle
// 1.21 \+, \- FOR INCWPM/DECWPM
// 1.30 PTT
// 1.31 fixed PTT for 98 or serial (pttport = prtport) proc ControlPTT()
// 1.32 bug fix for \+n/\-n at the end of strings
// 1.33 setspacefactor
// 1.34 setport$00 and nosound added to $FF
// 1.35 recompiled for zLog for Win 1.0 @ hamfair 98
// 1.36 fixed a bug which failed to control ptt between cq loops
// 1.40 initializebgk takes msec as timer interval. no compatibility with 1.36 and older
// 1.41 PTTFLAG was added
// 1.42 LeftInBuffer added. Returns # of Char's in buffer
// 1.43 Added timeBeginPeriod and timeEndPeriod

{$F+,X+}

uses
  SysUtils,
  Classes,
  Windows,
{$IFNDEF RCCLITE}
  URigControl,    // 1/21/01 ver 1.9h for serial port keying
{$ENDIF}
  MMSystem;

const
  version = 1.43;
  charmax=256;
  codemax=16;
  MAXWPM =60;
  MINWPM =1;
  PCIBM = 0; {machine code}
  PC98 = 255;
  BeepF : LongInt = 1193180; {for calculation of pitch (IBM)}
  _inccw = $80;
  _deccw = $81;

  _cwon : byte = $01;
  _cwoff : byte = $00;

type
  CodeData = array[1..codemax] of byte;
  CodeTableType = array[0..255] of CodeData;

var
  SendCharBuffer : array[1..codemax] of byte; //new buffer
  XX : integer = 1;
  SendBuffer : array[0..2] of string = ('', '', '');
  SendBufferPtr : integer = 0;

  SpaceFactor : word = 100; {space length factor in %}
  EISpaceFactor : word = 100; {space length factor after E and I}
  SelectedBuf : byte; {0..2}
  //CWSendBuf : array[0..2,1..charmax*codemax] of byte;
  CodeTable : CodeTableType;

  RandCQStr : array[1..2] of string[255];

var Initialized : boolean = False;

var
  PTTFLAG : boolean; {internal PTT flag}
  SendOK : boolean;{TRUE if OK to send}
  TimerID : UINT;  {CW timer ID}
  millisec : word; {CW timer interval}
  IntrIntvl : word;{CW timer interval in microsec }
  Machine : word;  {IBMPC (default) or NEC98}
  sss : word;      {CW timer counter}

  PTTEnabled : boolean;

  PRTport : word;  {CW output port}
  PTTport : word;

  _pttbefore, _pttafter : word;
  _pttholdcount : integer; {counter used to hold PTT in paddle wait}

  _pttout : byte; {value that is output to PTTport. $08 by default}

  cwstrptr : word;
  tailcwstrptr : word;

  callsignptr : word; {char pos. not absolute pos}

  Hz : word;       {side tone pitch}
  _dot, _dash, _bl1, _bl3 : word;
  CQrep : word;
  CQmax : word;
  BGKWPM : word;
  BGKWeight : word;
  BGKSideTone : boolean;
  LoopCount_ : LongInt;
  LoopTimeSec : Real;
  CWPortStr : ShortString;

var {Paddle related variables}
  paddleport : word; {paddle input port. PRTport -1 }
  paddle_waiting : boolean; {true if ready to receive paddle input}
  mousetail : word; {pointer in CWSendBuf}
  p_char_count : word; {counter which determines the end of a word}
                       {set in m_set and decremented in $AA }
  mouX, mouY : word;  { 1 or 3 dot or dash}
  paddle_input : array[1..codemax+1] of byte;


function GetMachine : word;
begin
  Result := PCIBM;
end;

{for internal use}

function MemW(Seg, Ofs : word): Word;
var
   bValue: Word;
begin
{   asm
      mov AX, Seg;
      mov ES, AX;
      mov AX, ES:Ofs;
      mov bValue, AX
   end;}
   asm
      mov AX, Seg;
      mov DS, AX;
      mov AX, DS:Ofs;
      mov bValue, AX
   end;
   result := bValue;
end;

function GetPort(address: Word): byte;
var
   bValue: Byte;
begin
   asm
      mov DX, address
      in  AL, DX
      mov bValue, AL
   end;
   result := bValue;
end;

procedure SetPort(address, value : Word);
var
   bValue: Byte;
begin
   bValue := value;
   asm
      mov DX, address
      mov AL, bValue
      out DX, AL
   end;
end;

procedure UpdateDataPort;
begin
  SetPort(PTTport, _rigmask or _pttmask or _bandmask or _voicemask);
end;

procedure SetRigFlag(i : integer); // 0 : no rigs, 1 : rig 1, etc
begin
  case i of
    0 : _rigmask := $00;
    1 : _rigmask := $00;
    2 : _rigmask := $04;
  end;
  UpdateDataPort;
end;

procedure SetVoiceFlag(i : integer); // 0 : no rigs, 1 : rig 1, etc
begin
  case i of
    0 : _voicemask := $00;
    1 : _voicemask := $02;
  end;
  UpdateDataPort;
end;

procedure ReverseLogicKeying(KeyReverse : boolean);
begin
  if KeyReverse = False then
    begin
      _cwon := $01;
      _cwoff := $00;
    end
  else
    begin
      _cwon := $00;
      _cwoff := $01;
    end;
end;

procedure Sound(Hz: word);

	procedure PutCount(n: word); assembler;
	asm
		mov		al, $B6
		out		$43, al
		mov		ax, n
		out		$42, al
		xchg	ah, al
		out		$42, al
	end;

begin {Sound}
if Machine<>NEC98 then
  begin
    {PutCount(BeepF div Hz);}
    SetPort($61, GetPort($61) or 3);
  end
else
  begin
    //SetPort($37, $06);
  end;
end;

procedure NoSound;
begin
  if Machine<>NEC98 then
    begin
      SetPort($61,GetPort($61) and $FC);
    end
  else
    begin
      SetPort($37, $07);
    end;
end;

procedure ControlPTT(PTTON : boolean);
var _out : word;
begin
  PTTFLAG := PTTON;

{$IFNDEF RCCLITE}
  if KeyingPort <> tkpParallel then //Serial
    begin
      RigControl.CommPort3.RTS(PTTON);
      exit;
    end;
{$ENDIF}

  if PTTON then
    _out := _pttout
  else
    _out := $00;
  if PTTport = PRTport then {PTT and CW same port, 98 or serial}
    begin
      if PTTON then
        SetPort(PTTport, GetPort(PTTport) or _out)
      else
        SetPort(PTTport, GetPort(PTTport) and not(_out));
    end
  else
    begin
      _pttmask := _out;
      UpdateDataPort;
    //SetPort(PTTport, _out);
    end;
end;

procedure SetPTT(_on : boolean);
begin
  PTTEnabled := _on;
end;

function PTTIsOn : boolean;
begin
  Result := PTTFLAG;
{
  if GetPort(PTTport and _pttout) = _pttout then
    Result := True
  else
    Result := False;
}
end;

procedure SetPTTDelay(before, after : word);
var i : integer;
begin
  if IntrIntvl = 0 then
    exit;
  if before = 0 then
    i := 1
  else
    i := before;
  _pttbefore := Trunc(i*1000/IntrIntvl);
  if after = 0 then
    i := 1
  else
    i := after;
  _pttafter := Trunc(i*1000/IntrIntvl);
end;

function Paused : boolean;
begin
  Result := not SendOK;
end;

function GetLoopCount : integer;
begin
  Result := CQrep;
end;

procedure SetLoopMax(Max : integer);
begin
  CQmax := Max;
end;

function GetLoopMax : word;
begin
  Result := CQmax;
end;

procedure SetPitch(Hertz : integer);
var w : word;
begin
  if Hertz < 2500 then
    Hz := Hertz;
  if Machine <> NEC98 then
    begin
      w := BeepF div Hz;
      SetPort($43, $B6);
      SetPort($42, Low(w));
      SetPort($42, Hi(w));
    end
  else
    begin
    end;
end;

function GetPitch : word;
begin
  Result := Hz;
end;

Procedure SetCharBuffer(C : char);
var m : integer;
begin
  for m:=1 to codemax do
    SendCharBuffer[m]:=CodeTable[Ord(C)][m];
  XX := 1;
end;

Procedure SetCWSendBufCharPTT(C : char);
var m : byte;
begin
{
  if PTTEnabled and Not(PTTIsOn) then
    begin
      ControlPTT(True);
      sss := _pttbefore;
    end;

  for m:=1 to codemax do
    CWSendBuf[0, codemax*(tailcwstrptr-1)+m]:=CodeTable[Ord(C)][m];

  if PTTEnabled then
    begin
      _pttholdcount := _pttafter;
      CWSendBuf[0, codemax*(tailcwstrptr-1)+codemax + 1]:=$A2; //holds PTT until pttafter expires
      inc(tailcwstrptr);
      if tailcwstrptr>charmax then tailcwstrptr:=1;
      exit;
    end;

  inc(tailcwstrptr);
  if tailcwstrptr>charmax then tailcwstrptr:=1;

  for m:=1 to codemax do
    CWSendBuf[0, codemax*(tailcwstrptr-1)+m]:=$FF;}
end;

function DecodeCommands(S : string) : string;
var SS : string;
    n, j, k : word;
begin
  SS := S;
  while pos('\',SS) > 0 do  // \+ incwpm \- decwpm
    begin
      n := pos('\',SS);
      SS[n] := '_'; // just to avoid infinite loop
//      if n < (length(SS) - 2) then
      if n <= (length(SS) - 2) then // bug fix
        begin
          if SS[n+1] = '+' then
            begin
              if SS[n+2] in ['1'..'9'] then
                begin
                  k := ord(SS[n+2]) - ord('0');
                  delete(SS, n, 3);
                  for j := 1 to k do
                    insert(Chr(_inccw), SS, n);
                end;
            end;
          if SS[n+1] = '-' then
            begin
              if SS[n+2] in ['1'..'9'] then
                begin
                  k := ord(SS[n+2]) - ord('0');
                  delete(SS, n, 3);
                  for j := 1 to k do
                    insert(Chr(_deccw), SS, n);
                end;
            end;
        end;

{      if n < length(SS) then
        begin
          if SS[n+1] = '+' then
            begin
              delete(SS, n, 2);
              insert(Chr(_inccw), SS, n);
            end;
          if SS[n+1] = '-' then
            begin
              delete(SS, n, 2);
              insert(Chr(_deccw), SS, n);
            end;
        end; }
    end;
  Result := SS;
end;

Procedure SendStr(sStr : String);
var SS : string;
begin
  SS := DecodeCommands(sStr);
  //SS := S;
  if PTTEnabled {and Not(PTTIsOn)} then
    SS := '('+SS+')';
  SendBuffer[0] := SS;
  SendBufferPtr := 1;
  sendok := true;
  sss:=1;
end;

procedure SendStrLoop(S : ShortString);
var SS : string;
begin
  SS := DecodeCommands(S);
  if PTTEnabled then
    SS := '('+SS+')';
  CQrep := 1;
  SendStr(SS+'@');
end;

Procedure SendStrFIFO(sStr : String);
var SS : string;
begin
  {StringBuffer := StringBuffer + sStr; }
  SS := DecodeCommands(sStr);
  if PTTEnabled then
    SS := '('+SS+')';
  SendBuffer[0] := SendBuffer[0] + SS;
  sendok := true;
end;

procedure CW_ON;
begin
  Case KeyingPort of
    tkpParallel : SetPort(PRTport, _cwon);
{$IFNDEF RCCLITE}
    tkpSerial1, tkpSerial2 : RigControl.CommPort3.DTR(True);
{$ENDIF}
  end;
end;

procedure CW_OFF;
begin
  Case KeyingPort of
    tkpParallel : SetPort(PRTport, _cwoff);
{$IFNDEF RCCLITE}
    tkpSerial1, tkpSerial2 : RigControl.CommPort3.DTR(False);
{$ENDIF}
  end;
end;

Procedure TimerProcess(uTimerID, uMessage: word;
                       dwUser, dw1, dw2: Longint); stdcall;
var  workw, workx : word; {work variables in TimerProcess $AA}
label xxx;
begin
  //PaddleProcess;
  if sss > 0 then dec(sss) else
    begin
      if SendOK then
        begin
          Case SendCharBuffer[XX] of
          $55 : { set ptt delay before}
                sss := _pttbefore;
          $10 : ControlPTT(True);
          $1F : ControlPTT(False);
            0 : begin
                  //SetPort(PRTport, _cwoff);
                  CW_OFF;
                  nosound; sss:=_bl1;
                end;
            2 : {normal space x space factor (%)}
                begin
                  //SetPort(PRTport, _cwoff);
                  CW_OFF;
                  nosound;
                  sss := Trunc(_bl3*SpaceFactor/100);
                end;
          $E : {normal space x space factor x eispacefactor(%)}
                begin
                  //SetPort(PRTport, _cwoff);
                  CW_OFF;
                  nosound;
                  sss := Trunc(_bl3*(SpaceFactor/100)*(EISpaceFactor/100));
                end;
            1 : begin
                  //SetPort(PRTport, _cwon);
                  CW_ON;
                  if BGKsidetone then sound(Hz);
                  sss:=_dot;
                end;
            3 : begin
                  //SetPort(PRTport, _cwon);
                  CW_ON;
                  if BGKsidetone then sound(Hz);
                  sss:=_dash;
                end;
            4 : begin
                  if BGKsidetone then sound(Hz);
                  SetPort(PRTport, GetPort(PRTport) or $80); //for external voice memory pulse
                  sss:=100; {30 ms}
                end;
            5 : begin SetPort(PRTport, GetPort(PRTport) and $7F); nosound; sss:=_bl1; end; {???}
            9 : begin
                  BGKRefresh := True;
                  inc(SendBufferPtr);
                  if SendBufferPtr <= length(SendBuffer[0]) then
                    begin
                      SetCharBuffer(SendBuffer[0][SendBufferPtr]);
                      XX := 1;
                    end
                  else // no more to send
                    begin
                      SendCharBuffer[1] := $FF;
                      XX := 1;
                      sss := 500;
                    end;
                end;
          $A2 : begin
                  if _pttholdcount = 0 then
                    begin
                      ControlPTT(False);
                      // same as $FF
                      cwstrptr:=0;
                      callsignptr := 0;
                      mousetail:=1;
                      tailcwstrptr := 1;
                      paddle_waiting:=true;
                      CWSendBuf[SelectedBuf,1]:=$FF;
                      //SetPort(PRTport, _cwoff);
                      CW_OFF;
                      nosound;
                    end
                  else
                    begin
                      dec(_pttholdcount);
                      goto xxx;
                    end;
                end;
          $AA : begin {paddle waiting routine. if p_char_count expires, }
                  paddle_waiting:=true;
                  if p_char_count=0 then
                    begin
                      if mousetail>codemax then workx:=codemax
                        else workx:=mousetail;
                      for workw:=1 to workx-1 do
                        paddle_input[workw]:=CWSendBuf[0,workw];
                      paddle_input[workx]:=$FF;

                      if PTTEnabled then
                        begin
                          _pttholdcount := _pttafter;
                          CWSendBuf[SelectedBuf,cwstrptr] := $A2;
                          goto xxx;
                        end;

                      cwstrptr:=1;
                      mousetail:=1;
                      paddle_waiting:=true;
                      CWSendBuf[SelectedBuf,1]:=$FF;
                     {sendok:=false;}
                    end
                  else
                    dec(p_char_count);
                  goto xxx;
                end;
          $BB : begin dec(cwstrptr); end;
          $CC : begin
                  inc(CQrep);
                  if CQrep>CQmax then
                    begin
                      {selectedBuf:=0;}
                      CWSendBuf[SelectedBuf,1]:=$FF;
                      cwstrptr:=0;
                      mousetail:=1;
                      tailcwstrptr := 1;
                      paddle_waiting:=true;
                      CQrep := 0;
                    end
                  else
                    if CQrep>4 then
                      begin
                        SelectedBuf:=random(3);
                        if SelectedBuf in [1..2] then
                          if RandCQStr[SelectedBuf]='' then
                            SelectedBuf := 0;
                      end;
                  cwstrptr:=0;
                end;
          $DD : begin
                  sss:=LoopCount_;
                end;
          $C1 : begin  {voice}
                  inc(CQrep);
                  if CQrep>CQmax then
                    begin
                      SendOK:=false;
                      cwstrptr:=0;
                    end
                  else
                    cwstrptr:=0;
                end;
          $D1 : begin
                  {sss:=voiceLoopCount;}
                end;
          $EE : begin {cwstrptr:=(BGKcall+callmax-1)*codemax;}end;
          $FA : begin
                  dec(cwstrptr);
                end;
          $FF : begin
                  {SendOK:=false;}
                  XX := 0;
                  cwstrptr:=0;
                  callsignptr := 0;
                  mousetail:=1;
                  tailcwstrptr := 1;
                  paddle_waiting:=true;
                  CWSendBuf[SelectedBuf,1]:=$FF;
                  //SetPort(PRTport, _cwoff);
                  CW_OFF;
                  nosound;
                  {if PTTEnabled then  // 1.3c
                    ControlPTT(False); } // PTT doesn't work with \
                end;
          $99 : begin {pause}
                  SendOK := False;
                end;

          $41 : begin
                  IncWPM;
                end;
          $42 : begin
                  DecWPM;
                end;

          end;
          inc(XX);
xxx:
       end;
    end;
end; {TimerProcess}


Procedure SetCWSpeed(_WPM : word);
begin
  if (_WPM<=MAXWPM) and (_WPM>=MINWPM) then
    begin
     if _WPM*IntrIntvl=0 then exit;
     _dot:=Trunc((2*BGKweight/100)*(1200000/(_WPM*IntrIntvl)));
     _bl1:=Trunc((2*(1-BGKweight/100))*(1200000/(_WPM*IntrIntvl)));
     _dash:=_dot*3;
     _bl3:=_bl1*3;
     BGKWPM:=_WPM;
   end;
end;

procedure SetLoopTime(Tsec : Real);
begin
  if IntrIntvl = 0 then
    IntrIntvl := 1000;
  LoopCount_:=Trunc(Tsec*1000000 /IntrIntvl);
  LoopTimeSec := Tsec;
end;

function GetLoopTime : Real;
begin
  Result := LoopTimeSec;
end;

procedure InitializeBGK(msec : integer);
var n, m : word;
begin
  Initialized := True;
  RandCQStr[1] := '';
  RandCQStr[2] := '';
  BGKRefresh := False;

  PRTport := $037A;
  PTTport := $0378;
  _pttout := $08;
  PTTFLAG := False;

  paddleport := $00;
  mouX := 1; mouY := 3;

  callsignptr := 0; {points to the 1st char of realtime updated callsign}
  SelectedBuf := 0;
  cwstrptr := 1;
  tailcwstrptr := 1;
  Machine := IBMPC;
  millisec := msec; {timer interval}
  IntrIntvl := millisec * 1000;
  SetLoopTime(2.0);
  for n:=0 to 255 do
    for m:= 1 to codemax do
      CodeTable[n,m]:=$FF;
  for m := 0 to 2 do
    CWSendBuf[m,1]:=$FF;
  SendOK := True;
  sss := 10;
  SetPitch(800); {800 Hz}
  BGKWeight := 50;
  BGKSideTone := True;
  SetCWSpeed(25);
  CQrep := 0;
  CQmax := 15;

  timeBeginPeriod(1);

  TimerID := timeSetEvent(millisec,0, @TimerProcess, 0, time_Periodic);

  PTTEnabled := False;
  SetPTTDelay(50, 50); {50ms/50ms}

  CodeTable[Ord('A')][1]:=1;
  CodeTable[Ord('A')][2]:=0;
  CodeTable[Ord('A')][3]:=3;
  CodeTable[Ord('A')][4]:=2;
  CodeTable[Ord('A')][5]:=9;

  CodeTable[Ord('B')][1]:=3;
  CodeTable[Ord('B')][2]:=0;
  CodeTable[Ord('B')][3]:=1;
  CodeTable[Ord('B')][4]:=0;
  CodeTable[Ord('B')][5]:=1;
  CodeTable[Ord('B')][6]:=0;
  CodeTable[Ord('B')][7]:=1;
  CodeTable[Ord('B')][8]:=2;
  CodeTable[Ord('B')][9]:=9;

  CodeTable[Ord('C')][1]:=3;
  CodeTable[Ord('C')][2]:=0;
  CodeTable[Ord('C')][3]:=1;
  CodeTable[Ord('C')][4]:=0;
  CodeTable[Ord('C')][5]:=3;
  CodeTable[Ord('C')][6]:=0;
  CodeTable[Ord('C')][7]:=1;
  CodeTable[Ord('C')][8]:=2;
  CodeTable[Ord('C')][9]:=9;

  CodeTable[Ord('D')][1]:=3;
  CodeTable[Ord('D')][2]:=0;
  CodeTable[Ord('D')][3]:=1;
  CodeTable[Ord('D')][4]:=0;
  CodeTable[Ord('D')][5]:=1;
  CodeTable[Ord('D')][6]:=2;
  CodeTable[Ord('D')][7]:=9;

  CodeTable[Ord('E')][1]:=1;
  CodeTable[Ord('E')][2]:=$E;
  CodeTable[Ord('E')][3]:=9;

  CodeTable[Ord('F')][1]:=1;
  CodeTable[Ord('F')][2]:=0;
  CodeTable[Ord('F')][3]:=1;
  CodeTable[Ord('F')][4]:=0;
  CodeTable[Ord('F')][5]:=3;
  CodeTable[Ord('F')][6]:=0;
  CodeTable[Ord('F')][7]:=1;
  CodeTable[Ord('F')][8]:=2;
  CodeTable[Ord('F')][9]:=9;

  CodeTable[Ord('G')][1]:=3;
  CodeTable[Ord('G')][2]:=0;
  CodeTable[Ord('G')][3]:=3;
  CodeTable[Ord('G')][4]:=0;
  CodeTable[Ord('G')][5]:=1;
  CodeTable[Ord('G')][6]:=2;
  CodeTable[Ord('G')][7]:=9;

  CodeTable[Ord('H')][1]:=1;
  CodeTable[Ord('H')][2]:=0;
  CodeTable[Ord('H')][3]:=1;
  CodeTable[Ord('H')][4]:=0;
  CodeTable[Ord('H')][5]:=1;
  CodeTable[Ord('H')][6]:=0;
  CodeTable[Ord('H')][7]:=1;
  CodeTable[Ord('H')][8]:=2;
  CodeTable[Ord('H')][9]:=9;

  CodeTable[Ord('I')][1]:=1;
  CodeTable[Ord('I')][2]:=0;
  CodeTable[Ord('I')][3]:=1;
  CodeTable[Ord('I')][4]:=0;
  CodeTable[Ord('I')][5]:=$E;
  CodeTable[Ord('I')][6]:=9;

  CodeTable[Ord('J')][1]:=1;
  CodeTable[Ord('J')][2]:=0;
  CodeTable[Ord('J')][3]:=3;
  CodeTable[Ord('J')][4]:=0;
  CodeTable[Ord('J')][5]:=3;
  CodeTable[Ord('J')][6]:=0;
  CodeTable[Ord('J')][7]:=3;
  CodeTable[Ord('J')][8]:=2;
  CodeTable[Ord('J')][9]:=9;

  CodeTable[Ord('K')][1]:=3;
  CodeTable[Ord('K')][2]:=0;
  CodeTable[Ord('K')][3]:=1;
  CodeTable[Ord('K')][4]:=0;
  CodeTable[Ord('K')][5]:=3;
  CodeTable[Ord('K')][6]:=2;
  CodeTable[Ord('K')][7]:=9;

  CodeTable[Ord('L')][1]:=1;
  CodeTable[Ord('L')][2]:=0;
  CodeTable[Ord('L')][3]:=3;
  CodeTable[Ord('L')][4]:=0;
  CodeTable[Ord('L')][5]:=1;
  CodeTable[Ord('L')][6]:=0;
  CodeTable[Ord('L')][7]:=1;
  CodeTable[Ord('L')][8]:=2;
  CodeTable[Ord('L')][9]:=9;

  CodeTable[Ord('M')][1]:=3;
  CodeTable[Ord('M')][2]:=0;
  CodeTable[Ord('M')][3]:=3;
  CodeTable[Ord('M')][4]:=0;
  CodeTable[Ord('M')][5]:=2;
  CodeTable[Ord('M')][6]:=9;

  CodeTable[Ord('N')][1]:=3;
  CodeTable[Ord('N')][2]:=0;
  CodeTable[Ord('N')][3]:=1;
  CodeTable[Ord('N')][4]:=0;
  CodeTable[Ord('N')][5]:=2;
  CodeTable[Ord('N')][6]:=9;

  CodeTable[Ord('O')][1]:=3;
  CodeTable[Ord('O')][2]:=0;
  CodeTable[Ord('O')][3]:=3;
  CodeTable[Ord('O')][4]:=0;
  CodeTable[Ord('O')][5]:=3;
  CodeTable[Ord('O')][6]:=2;
  CodeTable[Ord('O')][7]:=9;

  CodeTable[Ord('P')][1]:=1;
  CodeTable[Ord('P')][2]:=0;
  CodeTable[Ord('P')][3]:=3;
  CodeTable[Ord('P')][4]:=0;
  CodeTable[Ord('P')][5]:=3;
  CodeTable[Ord('P')][6]:=0;
  CodeTable[Ord('P')][7]:=1;
  CodeTable[Ord('P')][8]:=2;
  CodeTable[Ord('P')][9]:=9;

  CodeTable[Ord('Q')][1]:=3;
  CodeTable[Ord('Q')][2]:=0;
  CodeTable[Ord('Q')][3]:=3;
  CodeTable[Ord('Q')][4]:=0;
  CodeTable[Ord('Q')][5]:=1;
  CodeTable[Ord('Q')][6]:=0;
  CodeTable[Ord('Q')][7]:=3;
  CodeTable[Ord('Q')][8]:=2;
  CodeTable[Ord('Q')][9]:=9;

  CodeTable[Ord('R')][1]:=1;
  CodeTable[Ord('R')][2]:=0;
  CodeTable[Ord('R')][3]:=3;
  CodeTable[Ord('R')][4]:=0;
  CodeTable[Ord('R')][5]:=1;
  CodeTable[Ord('R')][6]:=2;
  CodeTable[Ord('R')][7]:=9;

  CodeTable[Ord('S')][1]:=1;
  CodeTable[Ord('S')][2]:=0;
  CodeTable[Ord('S')][3]:=1;
  CodeTable[Ord('S')][4]:=0;
  CodeTable[Ord('S')][5]:=1;
  CodeTable[Ord('S')][6]:=2;
  CodeTable[Ord('S')][7]:=9;

  CodeTable[Ord('T')][1]:=3;
  CodeTable[Ord('T')][2]:=2;
  CodeTable[Ord('T')][3]:=9;

  CodeTable[Ord('U')][1]:=1;
  CodeTable[Ord('U')][2]:=0;
  CodeTable[Ord('U')][3]:=1;
  CodeTable[Ord('U')][4]:=0;
  CodeTable[Ord('U')][5]:=3;
  CodeTable[Ord('U')][6]:=2;
  CodeTable[Ord('U')][7]:=9;

  CodeTable[Ord('V')][1]:=1;
  CodeTable[Ord('V')][2]:=0;
  CodeTable[Ord('V')][3]:=1;
  CodeTable[Ord('V')][4]:=0;
  CodeTable[Ord('V')][5]:=1;
  CodeTable[Ord('V')][6]:=0;
  CodeTable[Ord('V')][7]:=3;
  CodeTable[Ord('V')][8]:=2;
  CodeTable[Ord('V')][9]:=9;

  CodeTable[Ord('W')][1]:=1;
  CodeTable[Ord('W')][2]:=0;
  CodeTable[Ord('W')][3]:=3;
  CodeTable[Ord('W')][4]:=0;
  CodeTable[Ord('W')][5]:=3;
  CodeTable[Ord('W')][6]:=2;
  CodeTable[Ord('W')][7]:=9;

  CodeTable[Ord('X')][1]:=3;
  CodeTable[Ord('X')][2]:=0;
  CodeTable[Ord('X')][3]:=1;
  CodeTable[Ord('X')][4]:=0;
  CodeTable[Ord('X')][5]:=1;
  CodeTable[Ord('X')][6]:=0;
  CodeTable[Ord('X')][7]:=3;
  CodeTable[Ord('X')][8]:=2;
  CodeTable[Ord('X')][9]:=9;

  CodeTable[Ord('Y')][1]:=3;
  CodeTable[Ord('Y')][2]:=0;
  CodeTable[Ord('Y')][3]:=1;
  CodeTable[Ord('Y')][4]:=0;
  CodeTable[Ord('Y')][5]:=3;
  CodeTable[Ord('Y')][6]:=0;
  CodeTable[Ord('Y')][7]:=3;
  CodeTable[Ord('Y')][8]:=2;
  CodeTable[Ord('Y')][9]:=9;

  CodeTable[Ord('Z')][1]:=3;
  CodeTable[Ord('Z')][2]:=0;
  CodeTable[Ord('Z')][3]:=3;
  CodeTable[Ord('Z')][4]:=0;
  CodeTable[Ord('Z')][5]:=1;
  CodeTable[Ord('Z')][6]:=0;
  CodeTable[Ord('Z')][7]:=1;
  CodeTable[Ord('Z')][8]:=2;
  CodeTable[Ord('Z')][9]:=9;

  CodeTable[Ord(' ')][1]:=0;
  //CodeTable[Ord(' ')][2]:=$22;
  CodeTable[Ord(' ')][2]:=2;
  CodeTable[Ord(' ')][3]:=9;

  CodeTable[Ord('_')][1]:=0;
  CodeTable[Ord('_')][2]:=9;

  CodeTable[Ord('1')][1]:=1;
  CodeTable[Ord('1')][2]:=0;
  CodeTable[Ord('1')][3]:=3;
  CodeTable[Ord('1')][4]:=0;
  CodeTable[Ord('1')][5]:=3;
  CodeTable[Ord('1')][6]:=0;
  CodeTable[Ord('1')][7]:=3;
  CodeTable[Ord('1')][8]:=0;
  CodeTable[Ord('1')][9]:=3;
  CodeTable[Ord('1')][10]:=2;
  CodeTable[Ord('1')][11]:=9;

  CodeTable[Ord('2')][1]:=1;
  CodeTable[Ord('2')][2]:=0;
  CodeTable[Ord('2')][3]:=1;
  CodeTable[Ord('2')][4]:=0;
  CodeTable[Ord('2')][5]:=3;
  CodeTable[Ord('2')][6]:=0;
  CodeTable[Ord('2')][7]:=3;
  CodeTable[Ord('2')][8]:=0;
  CodeTable[Ord('2')][9]:=3;
  CodeTable[Ord('2')][10]:=2;
  CodeTable[Ord('2')][11]:=9;

  CodeTable[Ord('3')][1]:=1;
  CodeTable[Ord('3')][2]:=0;
  CodeTable[Ord('3')][3]:=1;
  CodeTable[Ord('3')][4]:=0;
  CodeTable[Ord('3')][5]:=1;
  CodeTable[Ord('3')][6]:=0;
  CodeTable[Ord('3')][7]:=3;
  CodeTable[Ord('3')][8]:=0;
  CodeTable[Ord('3')][9]:=3;
  CodeTable[Ord('3')][10]:=2;
  CodeTable[Ord('3')][11]:=9;

  CodeTable[Ord('4')][1]:=1;
  CodeTable[Ord('4')][2]:=0;
  CodeTable[Ord('4')][3]:=1;
  CodeTable[Ord('4')][4]:=0;
  CodeTable[Ord('4')][5]:=1;
  CodeTable[Ord('4')][6]:=0;
  CodeTable[Ord('4')][7]:=1;
  CodeTable[Ord('4')][8]:=0;
  CodeTable[Ord('4')][9]:=3;
  CodeTable[Ord('4')][10]:=2;
  CodeTable[Ord('4')][11]:=9;

  CodeTable[Ord('5')][1]:=1;
  CodeTable[Ord('5')][2]:=0;
  CodeTable[Ord('5')][3]:=1;
  CodeTable[Ord('5')][4]:=0;
  CodeTable[Ord('5')][5]:=1;
  CodeTable[Ord('5')][6]:=0;
  CodeTable[Ord('5')][7]:=1;
  CodeTable[Ord('5')][8]:=0;
  CodeTable[Ord('5')][9]:=1;
  CodeTable[Ord('5')][10]:=2;
  CodeTable[Ord('5')][11]:=9;

  CodeTable[Ord('6')][1]:=3;
  CodeTable[Ord('6')][2]:=0;
  CodeTable[Ord('6')][3]:=1;
  CodeTable[Ord('6')][4]:=0;
  CodeTable[Ord('6')][5]:=1;
  CodeTable[Ord('6')][6]:=0;
  CodeTable[Ord('6')][7]:=1;
  CodeTable[Ord('6')][8]:=0;
  CodeTable[Ord('6')][9]:=1;
  CodeTable[Ord('6')][10]:=2;
  CodeTable[Ord('6')][11]:=9;

  CodeTable[Ord('7')][1]:=3;
  CodeTable[Ord('7')][2]:=0;
  CodeTable[Ord('7')][3]:=3;
  CodeTable[Ord('7')][4]:=0;
  CodeTable[Ord('7')][5]:=1;
  CodeTable[Ord('7')][6]:=0;
  CodeTable[Ord('7')][7]:=1;
  CodeTable[Ord('7')][8]:=0;
  CodeTable[Ord('7')][9]:=1;
  CodeTable[Ord('7')][10]:=2;
  CodeTable[Ord('7')][11]:=9;

  CodeTable[Ord('8')][1]:=3;
  CodeTable[Ord('8')][2]:=0;
  CodeTable[Ord('8')][3]:=3;
  CodeTable[Ord('8')][4]:=0;
  CodeTable[Ord('8')][5]:=3;
  CodeTable[Ord('8')][6]:=0;
  CodeTable[Ord('8')][7]:=1;
  CodeTable[Ord('8')][8]:=0;
  CodeTable[Ord('8')][9]:=1;
  CodeTable[Ord('8')][10]:=2;
  CodeTable[Ord('8')][11]:=9;

  CodeTable[Ord('9')][1]:=3;
  CodeTable[Ord('9')][2]:=0;
  CodeTable[Ord('9')][3]:=3;
  CodeTable[Ord('9')][4]:=0;
  CodeTable[Ord('9')][5]:=3;
  CodeTable[Ord('9')][6]:=0;
  CodeTable[Ord('9')][7]:=3;
  CodeTable[Ord('9')][8]:=0;
  CodeTable[Ord('9')][9]:=1;
  CodeTable[Ord('9')][10]:=2;
  CodeTable[Ord('9')][11]:=9;

  CodeTable[Ord('0')][1]:=3;
  CodeTable[Ord('0')][2]:=0;
  CodeTable[Ord('0')][3]:=3;
  CodeTable[Ord('0')][4]:=0;
  CodeTable[Ord('0')][5]:=3;
  CodeTable[Ord('0')][6]:=0;
  CodeTable[Ord('0')][7]:=3;
  CodeTable[Ord('0')][8]:=0;
  CodeTable[Ord('0')][9]:=3;
  CodeTable[Ord('0')][10]:=2;
  CodeTable[Ord('0')][11]:=9;

  CodeTable[Ord('-')][1]:=3;
  CodeTable[Ord('-')][2]:=0;
  CodeTable[Ord('-')][3]:=1;
  CodeTable[Ord('-')][4]:=0;
  CodeTable[Ord('-')][5]:=1;
  CodeTable[Ord('-')][6]:=0;
  CodeTable[Ord('-')][7]:=1;
  CodeTable[Ord('-')][8]:=0;
  CodeTable[Ord('-')][9]:=3;
  CodeTable[Ord('-')][10]:=2;
  CodeTable[Ord('-')][11]:=9;

  CodeTable[Ord('=')][1]:=3;
  CodeTable[Ord('=')][2]:=0;
  CodeTable[Ord('=')][3]:=1;
  CodeTable[Ord('=')][4]:=0;
  CodeTable[Ord('=')][5]:=1;
  CodeTable[Ord('=')][6]:=0;
  CodeTable[Ord('=')][7]:=1;
  CodeTable[Ord('=')][8]:=0;
  CodeTable[Ord('=')][9]:=3;
  CodeTable[Ord('=')][10]:=2;
  CodeTable[Ord('=')][11]:=9;

  CodeTable[Ord('/')][1]:=3;
  CodeTable[Ord('/')][2]:=0;
  CodeTable[Ord('/')][3]:=1;
  CodeTable[Ord('/')][4]:=0;
  CodeTable[Ord('/')][5]:=1;
  CodeTable[Ord('/')][6]:=0;
  CodeTable[Ord('/')][7]:=3;
  CodeTable[Ord('/')][8]:=0;
  CodeTable[Ord('/')][9]:=1;
  CodeTable[Ord('/')][10]:=2;
  CodeTable[Ord('/')][11]:=9;

  CodeTable[Ord('a')][1]:=1;
  CodeTable[Ord('a')][2]:=0;
  CodeTable[Ord('a')][3]:=3;
  CodeTable[Ord('a')][4]:=0;
  CodeTable[Ord('a')][5]:=1;
  CodeTable[Ord('a')][6]:=0;
  CodeTable[Ord('a')][7]:=3;
  CodeTable[Ord('a')][8]:=0;
  CodeTable[Ord('a')][9]:=1;
  CodeTable[Ord('a')][10]:=2;
  CodeTable[Ord('a')][11]:=9;

  CodeTable[Ord('b')][1]:=3;
  CodeTable[Ord('b')][2]:=0;
  CodeTable[Ord('b')][3]:=1;
  CodeTable[Ord('b')][4]:=0;
  CodeTable[Ord('b')][5]:=1;
  CodeTable[Ord('b')][6]:=0;
  CodeTable[Ord('b')][7]:=1;
  CodeTable[Ord('b')][8]:=0;
  CodeTable[Ord('b')][9]:=3;
  CodeTable[Ord('b')][10]:=0;
  CodeTable[Ord('b')][11]:=1;
  CodeTable[Ord('b')][12]:=0;
  CodeTable[Ord('b')][13]:=3;
  CodeTable[Ord('b')][14]:=2;
  CodeTable[Ord('b')][15]:=9;

  CodeTable[Ord('s')][1]:=1;
  CodeTable[Ord('s')][2]:=0;
  CodeTable[Ord('s')][3]:=1;
  CodeTable[Ord('s')][4]:=0;
  CodeTable[Ord('s')][5]:=1;
  CodeTable[Ord('s')][6]:=0;
  CodeTable[Ord('s')][7]:=3;
  CodeTable[Ord('s')][8]:=0;
  CodeTable[Ord('s')][9]:=1;
  CodeTable[Ord('s')][10]:=0;
  CodeTable[Ord('s')][11]:=3;
  CodeTable[Ord('s')][12]:=2;
  CodeTable[Ord('s')][13]:=9;

  CodeTable[Ord('k')][1]:=3;
  CodeTable[Ord('k')][2]:=0;
  CodeTable[Ord('k')][3]:=1;
  CodeTable[Ord('k')][4]:=0;
  CodeTable[Ord('k')][5]:=3;
  CodeTable[Ord('k')][6]:=0;
  CodeTable[Ord('k')][7]:=3;
  CodeTable[Ord('k')][8]:=0;
  CodeTable[Ord('k')][9]:=1;
  CodeTable[Ord('k')][10]:=2;
  CodeTable[Ord('k')][11]:=9;

  CodeTable[Ord('p')][1]:=1;
  CodeTable[Ord('p')][2]:=0;
  CodeTable[Ord('p')][3]:=9;

  CodeTable[Ord('q')][1]:=3;
  CodeTable[Ord('q')][2]:=0;
  CodeTable[Ord('q')][3]:=9;

  CodeTable[Ord('?')][1]:=1;
  CodeTable[Ord('?')][2]:=0;
  CodeTable[Ord('?')][3]:=1;
  CodeTable[Ord('?')][4]:=0;
  CodeTable[Ord('?')][5]:=3;
  CodeTable[Ord('?')][6]:=0;
  CodeTable[Ord('?')][7]:=3;
  CodeTable[Ord('?')][8]:=0;
  CodeTable[Ord('?')][9]:=1;
  CodeTable[Ord('?')][10]:=0;
  CodeTable[Ord('?')][11]:=1;
  CodeTable[Ord('?')][12]:=2;
  CodeTable[Ord('?')][13]:=9;

  CodeTable[Ord('~')][1]:=3;
  CodeTable[Ord('~')][2]:=0;
  CodeTable[Ord('~')][3]:=1;
  CodeTable[Ord('~')][4]:=0;
  CodeTable[Ord('~')][5]:=1;
  CodeTable[Ord('~')][6]:=0;
  CodeTable[Ord('~')][7]:=1;
  CodeTable[Ord('~')][8]:=0;
  CodeTable[Ord('~')][9]:=3;
  CodeTable[Ord('~')][10]:=0;
  CodeTable[Ord('~')][11]:=1;
  CodeTable[Ord('~')][12]:=0;
  CodeTable[Ord('~')][13]:=3;
  CodeTable[Ord('~')][14]:=2;
  CodeTable[Ord('~')][15]:=9;

  CodeTable[Ord('@')][1]:=$DD;
  CodeTable[Ord('@')][2]:=$CC;

  CodeTable[Ord('|')][1]:=$D1;
  CodeTable[Ord('|')][2]:=$C1;

  CodeTable[Ord(']')][1]:=4;
  CodeTable[Ord(']')][2]:=5;
  CodeTable[Ord(']')][3]:=9;

  CodeTable[Ord('<')][1]:=$B0;
  CodeTable[Ord('<')][2]:=$B1;
  CodeTable[Ord('<')][3]:=$B2;
  CodeTable[Ord('<')][4]:=$DD;
  CodeTable[Ord('<')][5]:=$C1;

  CodeTable[Ord('#')][1]:=$BB;

  CodeTable[Ord('*')][1]:=9; {skips to the next char}
  CodeTable[Ord(':')][1]:=9; {skips to the next char; callsign 1st char}

  CodeTable[Ord('^')][1]:=$99; {pause}
  CodeTable[Ord('^')][2]:=9;

  CodeTable[Ord('(')][1]:=$10; {PTT on}
  CodeTable[Ord('(')][2]:=$55; {set PTT delay}
  CodeTable[Ord('(')][3]:=9;

  CodeTable[Ord(')')][1]:=$1F; {PTT off}
  CodeTable[Ord(')')][2]:=9;

  CodeTable[_inccw][1] := $41; {IncWPM}
  CodeTable[_inccw][2] := 9;

  CodeTable[ord('u')][1] := $41; {IncWPM}
  CodeTable[ord('u')][2] := 9;

  CodeTable[_deccw][1] := $42; {DecWPM}
  CodeTable[_deccw][2] := 9;

  for n:=1 to codemax do
    CodeTable[Ord('%')][n]:=$EE;

  for n:=1 to codemax do
    CodeTable[Ord('{')][n]:=$14;

end;

function CloseBGK : word;
var R : UINT;
begin
  ControlPTT(False);
  if not(Initialized) then exit;
  R:=timeKillEvent(TimerID);

  if Initialized then
    timeEndPeriod(1);

  {R:=timeKillEvent(PaddleTimerID);}
  R := 0;
  NoSound;
  if R = TIMERR_NOERROR
    then R := 121
  else
    if R = MMSYSERR_INVALPARAM
      then R := 999
    else
      R := 7777;
  result := R;
end;

function GetWPM : byte;
begin
  GetWPM := BGKWPM;
end;

procedure PauseCW;
begin
  SendOK := False;
  NoSound;
  {SetPort(PRTport, GetPort(PRTport) and $FE);} // 1.11
  SetPort(PRTport, 0);
  if PTTEnabled then
    ControlPTT(False);
end;

procedure ResumeCW;
begin
  if PTTEnabled then
    begin
      ControlPTT(True);
      sss := _pttbefore;
    end;
  SendOK := True;
end;

procedure IncWPM;
begin
  if BGKWPM < MAXWPM then
    SetCWSpeed(BGKWPM+1);
end;

procedure DecWPM;
begin
  if BGKWPM > MINWPM then
    SetCWSpeed(BGKWPM-1);
end;

procedure SetWeight(W : word);
begin
  if W in [0..100] then
    BGKWeight := W;
  SetCWSpeed(BGKWPM);
end;

procedure SetSideTone(B : boolean);
begin
  BGKSideTone := B;
end;

procedure SetCWPort(i : integer);
var p : word;
begin
  if Machine = NEC98 then
    begin
      PRTport := $40;
      {PaddlePort := $42;
      paddlemask := $A0;}
      CWPortStr := 'LPT1';
    end
  else
    begin
      p := MemW($40,$06+2*i);
      inc(p); {CT}
      PRTport := p;
      {PaddlePort := p;
      paddlemask := $30;}
      CWPortStr := 'LPT'+IntToStr(i);
    end;
end;

function GetCWPort : ShortString;
begin
  Result := CWPortStr;
end;

procedure SetMachine(M : word);
begin
  Machine := M;
  if Machine = NEC98 then
    begin
      SetCWPort(1);
      {PRTport := $40;
      paddleport := $42;
      paddlemask := $A0;}
    end
  else
    begin
      if CWportStr = 'LPT1' then
        SetCWport(1)
      else
        SetCWport(2);
      {paddlemask := $30; }
    end;
end;

{function GetMachine : word;
begin
  Result := Machine;
end; }

function GetVersion : real;
begin
  GetVersion := Version;
end;

procedure ClrBuffer;
var m : integer;
begin
  {SendOK:=false;}
  {StringBuffer := ''; }
  for m := 0 to 2 do
    CWSendBuf[m,1]:=$FF;
  cwstrptr:=0;
  callsignptr := 0;
  mousetail:=1;
  tailcwstrptr := 1;
  paddle_waiting:=true;
  NoSound;
  SendOK := True;
  CQrep := 0;
  if PTTEnabled then
    ControlPTT(False);
end;

procedure CancelLastChar;
var m : byte;
begin
  {m := Length(StringBuffer);
  Delete(StringBuffer,m,1); }

  if ((tailcwstrptr-1)*codemax+1) > (cwstrptr) then
    begin
      dec(tailcwstrptr, 1);
      for m:=1 to codemax do
        CWSendBuf[SelectedBuf, codemax*(tailcwstrptr-1)+m]:=$FF;
    end;
end;

Procedure SetCWSendBufChar2(C : char; CharPos : word);
var m : byte;
begin
  for m:=1 to codemax do
    CWSendBuf[0, codemax*(CharPos-1)+m]:=CodeTable[Ord(C)][m];
end;

procedure SetCallSign(S : ShortString);
var ss : string[12];
    i : word;
begin
  if callsignptr = 0 then exit;
  ss := S + '************';
  while pos('.',ss) > 0 do
    begin
      ss[pos('.',ss)] := '?';
    end;
  ss[12] := '^'; {pause}
  for i := 1 to 12 do
    SetCWSendBufChar2(ss[i], callsignptr+i-1);
end;

function CallSignSent : boolean;
begin
  Result := false;
  if callsignptr > 0 then
    if CWSendBuf[0, cwstrptr-1] = $99 then
    //if cwstrptr > (callsignptr + 10)*codemax then
      begin
        Result := true;
        callsignptr := 0;
      end;
end;

function IsPlaying : boolean;
begin
  if (cwstrptr > 1) and SendOK then
    Result := True
  else
    Result := False;
end;

procedure SetRandCQStr(Str1, Str2 : shortstring);
begin
  if Str1 <> '' then
    begin
      RandCQStr[1] := Str1;
      SetCWSendBuf(1, Str1+'@');
    end;
  if Str2 <> '' then
    begin
      RandCQStr[2] := Str2;
      SetCWSendBuf(2, Str2+'@');
    end;
end;

procedure SetPTTPortDirect(p : word);
begin
  PTTport := p;
  _pttout := $08; {parallel}
end;

procedure SetCWPortDirect(p : word);
begin
  PRTport := p;
(*
  if p = $40 then
    PTTport := $40 {pc9800}
  else
    PTTport := p - 2;
  _pttout := $08; {parallel}
*)
  // PaddlePort := p - 1; { for ibm lpt only. while debugging}
end;

procedure SetPaddlePortDirect(p : word);
begin
  PaddlePort := p;
end;

Procedure m_set(b : word);
begin
  if PTTEnabled and (mousetail = 1) then
    begin
      ControlPTT(True);
      CWSendBuf[0,1] := $55; {set PTT delay}
      inc(mousetail);
    end;

  if (mousetail+2)>(charmax*codemax) then mousetail:=1;
  CWSendBuf[0,mousetail]:=b;
  CWSendBuf[0,mousetail+1]:=0;
  CWSendBuf[0,mousetail+2]:=$AA;
  inc(mousetail,2);
  p_char_count:=(_dot*3) div 2;
  SendOK:=true;
  {inLoop:=false; } // not sure what it was used for}
  paddle_waiting:=false;
end;


Procedure PaddleProcess;
begin
if paddleport>0 then begin
  case mousetail-cwstrptr of
    0 :
      case ($30 and GetPort(paddleport)) of
        $00 : { both }
          case CWSendBuf[0,mousetail-2] of
            1 : m_set(3);
            3 : m_set(1);
          end;
        $10 : {dit}
          if paddle_waiting then m_set(mouX);
        $20 : {dah}
          if paddle_waiting then m_set(mouY);
      end;
    1 :
      case ($30 and GetPort(paddleport)) of
        $00 :
          case CWSendBuf[0,cwstrptr-1] of
            1 : m_set(3);
            3 : m_set(1);
          end;
        $10 : if CWSendBuf[0,cwstrptr-1] = mouY then
                  m_set(mouX);
        $20 : if CWSendBuf[0,cwstrptr-1] = mouX then
                  m_set(mouY);
      end;
    else
      if (($30 and GetPort(paddleport))=$20) or (($30 and GetPort(paddleport))=$10)
      then
        if abs(mousetail-cwstrptr) > 5 then
        begin
          SelectedBuf:=0;
          cwstrptr:=1;
          mousetail:=1;
          sss:=1;
          paddle_waiting:=true;
          m_set(0);
        end;
  end;
end
else begin
  (*  Mouse buttons as a paddle
  case mousetail-cwstrptr of
    0 :
      case mousebutton of
        m_both :
          case CWSendBuf[0,mousetail-2] of
            1 : m_set(3);
            3 : m_set(1);
          end;
        m_left : if paddle_waiting then m_set(mouX);
        m_right: if paddle_waiting then m_set(mouY);
      end;
    1 :
      case mousebutton of
        m_both :
          case CWSendBuf[0,cwstrptr-1] of
            1 : m_set(3);
            3 : m_set(1);
          end;
        m_left : if CWSendBuf[0,cwstrptr-1] = mouY then m_set(mouX);
        m_right: if CWSendBuf[0,cwstrptr-1] = mouX then m_set(mouY);
      end;
    else
      if (mousebutton=1) or (mousebutton=2) then
        if abs(mousetail-cwstrptr) > 5 then
        begin
          buf:=0;
          cwstrptr:=1;
          mousetail:=1;
          sss:=1;
          paddle_waiting:=true;
          m_set(0);
        end;
  end;*)
end;
end;

procedure ReversePaddle(boo : boolean);
begin
  if boo then
    begin
      mouX := 3;
      mouY := 1;
    end
  else
    begin
      mouX := 1;
      mouY := 3;
    end;
end;

procedure SetSpaceFactor(R : integer);
begin
  if R > 0 then
    SpaceFactor := R;
end;

procedure SetEISpaceFactor(R : integer);
begin
  if R > 0 then
    EISpaceFactor := R;
end;

function LeftInBuffer : Word;
begin
  Result := 0;
  if tailcwstrptr = 1 then
    exit;
  //Result := ((tailcwstrptr*codemax) - cwstrptr + 1) div codemax - 1;
  Result := ((tailcwstrptr*codemax) - cwstrptr + 1) div codemax;
end;

procedure TuneOn;
begin
  ClrBuffer;
  SendOK := False;
  ControlPTT(True);
  //SetPort(PRTport, _cwon);
  CW_ON;
  if BGKsidetone then
    sound(Hz);
end;

procedure SetCode(C : Char; Code : string);
const dot1 = '¥'; dot2 = '.'; dot3 = '*';
      dash1 = '-'; dash2 = '_';
      Dots : set of char = [dot1, dot2, dot3];
      Dashes : set of char = [dash1, dash2];
var i : integer;
begin
  for i := 1 to length(Code) do
    begin
      if 2*i > codemax then
        exit;
      if Code[i] in Dots then
        CodeTable[ord(C)][2*i-1] := 1;
      if Code[i] in Dashes then
        CodeTable[ord(C)][2*i-1] := 3;
      CodeTable[ord(C)][2*i] := 0;
    end;
  CodeTable[ord(C)][2*length(Code)] := 2;
  CodeTable[ord(C)][2*length(Code)+1] := 9;
end;



begin
end.
