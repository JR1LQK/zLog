unit BGK32Lib; {Delphi Interface Unit for BGK32.DLL}

interface

{$ifndef w95}
uses
  HIDControllerClass, ToneGen;
{$endif}

var BGKRefresh : boolean; // set to true after a char is sent

const
    BGKCALLMAX = 16;
{$ifndef w95}
const MAXREPORTSIZE = 2;
    TOWRITE = 9;
    REPORTSIZE = 2;
    DEBUG_FLAG : integer = 0;

type TZLHID = class
       procedure DeviceChanges(Sender: TObject);
       procedure DeviceUnplug(HidDev: TJvHidDevice);
       function Enumeration(HidDev: TJvHidDevice; Index: Integer) : boolean;
     end;

var ZLHID : TZLHID; // dummy object for HIDContol class to hand over events
    USBIF : TJvHIDDevice;
    USB_Detected : boolean;
    Tone : TToneGen;
    //SelectedBuf : byte; {0..2}


const  _usbportstatus : byte = $FF;
       _usbportbuf : byte = $FF;

{$endif}

const IBMPC = 0; {machine code as defined in BGK32.DLL}
      NEC98 = 255;

      _WIN2KMODE : boolean = false;
      DEBUGMODE : boolean = False;

      // mask data for data port
      _rigmask : byte = $00; // bit mask for sel rig
      _pttmask : byte = $00; // bit mask for ptt
      _bandmask : byte = $00; //bit mask for band data
      _voicemask : byte = $00; // bit mask for voice memory

      _RIGREVERSE : Boolean = false;
      _PTTREVERSE : Boolean = false;
      UserFlag : Boolean = False; // can be set to true by user. set to false only when ClrBuffer is called or "  is reached in the sending buffer. // 1.9z2 used in QTCForm
      VoiceFlag : integer = 0;  //temporary

type TKeyingPort = (tkpParallel, tkpSerial1, tkpSerial2, tkpUSB);
const KeyingPort : TKeyingPort = tkpParallel;

function GetPRTPort : string;
procedure UpdateDataPort; // sets data port acc to mask data
procedure SetRigFlag(i : integer); // 0 : no rigs, 1 : rig 1, etc
procedure SetVoiceFlag(i : integer); //0 or 1
procedure ReverseLogicKeying(KeyReverse : boolean); // _cwon, _cwoff
procedure ReverseRigOut(Reverse : boolean);
procedure ReversePTTOut(Reverse : boolean);

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
function GetCWPort : ShortString; {Gets current port LPT?}
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
{$ifndef w95}
procedure PaddleProcessUSB;
{$endif}
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
{ $IFNDEF RCCLITE}
  URigControl,    // 1/21/01 ver 1.9h for serial port keying
{ $ENDIF}
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
  SpaceFactor : word = 100; {space length factor in %}
  EISpaceFactor : word = 100; {space length factor after E and I}
  SelectedBuf : byte; {0..2}
  CWSendBuf : array[0..2,1..charmax*codemax] of byte;
  CodeTable : CodeTableType;

  RandCQStr : array[1..2] of string[255];

{$ifndef w95}
  HidController: TJvHidDeviceController;
{$endif}

const USBIF4CW_VENDORID = $BFE;
const USBIF4CW_PRODID = $E00;

var Initialized : boolean = False;

var
  PTTFLAG : boolean; {internal PTT flag}
  SendOK : boolean;{TRUE if OK to send}
  PTTEnabled : boolean;
  TimerID : UINT;  {CW timer ID}

  millisec : integer; //word; {CW timer interval}
  IntrIntvl : integer; //word;{CW timer interval in microsec }
  Machine : integer; //word;  {IBMPC (default) or NEC98}
  sss : integer; // word;      {CW timer counter}


  PRTport : word;  {CW output port}
  PTTport : word;

  _pttbefore, _pttafter : integer; // word;
  _pttholdcount : integer; {counter used to hold PTT in paddle wait}

  _pttout : byte; {value that is output to PTTport. $08 by default}

  cwstrptr : word;
  tailcwstrptr : word;

  callsignptr : word; {char pos. not absolute pos}

  Hz : word;       {side tone pitch}
  _dot, _dash, _bl1, _bl3 : integer; //word;
  CQrep : integer; //word;
  CQmax : integer; //word;
  BGKWPM : integer; //word;
  BGKWeight : integer; //word;
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


function GetPort(address: Word): byte;
var
   bValue: Byte;
begin
   if _WIN2KMODE then exit;
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
   if _WIN2KMODE then exit;
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
{$ifndef w95}
  if KeyingPort = tkpUSB then
    begin
      _usbportbuf := (not(_bandmask) and $F0) or (_usbportbuf and $0F);
    end;
{$endif}
end;

procedure SetRigFlag(i : integer); // 0 : no rigs, 1 : rig 1, etc
var _outb : byte;
begin
  case i of
    0 : _rigmask := $00;
    1 : _rigmask := $00;
    2 : _rigmask := $04;
  end;
  if _RIGREVERSE then
    _rigmask := _rigmask xor $04;
  UpdateDataPort;

{$ifndef w95}
  if KeyingPort = tkpUSB then
    begin
      case i of
        0, 1:  _outb := _usbportbuf or $04;
        2 :    _outb := _usbportbuf and $FB;
      else
        _outb := _usbportbuf;
      end;
      _usbportbuf := _outb;
      exit;
    end;
{$endif}
end;

procedure _SetUSBPort(X : byte);
var BW : DWORD;
{$ifndef w95}
    OutReport : array[0..8] of byte;
{$endif}
begin
{$ifndef w95}
  if USBIF <> nil then
    begin
      OutReport[0] := 0;
      OutReport[1] := 1;
      OutReport[2] := X;
      OutReport[3] := 0;
      OutReport[4] := 0;
      OutReport[5] := 0;
      OutReport[6] := 0;
      OutReport[7] := 0;
      OutReport[8] := 0;
      _usbportstatus := X;
      USBIF.WriteFile(OutReport, USBIF.Caps.OutputReportByteLength, BW);
    end;
{$endif}
end;

procedure SetUSBPort(X : byte);
begin
{$ifndef w95}
  _usbportbuf := x;
{$endif}
end;



procedure SetVoiceFlag(i : integer); // 0 : no rigs, 1 : rig 1, etc
var _out : word;
    _outb : byte;
begin

{$ifndef w95}          // 2.1a changed 2.1b
  VoiceFlag := i;
  if KeyingPort = tkpUSB then
    begin
      if i = 1 then
        _outb := _usbportbuf and $F7
      else
        _outb := _usbportbuf or $08;
      _usbportbuf := _outb;
      //SetUSBPort(_outb);
      exit;
    end;
{$endif}

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

procedure ReverseRigOut(Reverse : boolean);
begin
  _RIGREVERSE := Reverse;
end;

procedure ReversePTTOut(Reverse : boolean);
begin
  _PTTREVERSE := Reverse;
end;

procedure Sound(Hz: word);
begin {Sound}
  if _WIN2KMODE = false then
    SetPort($61, GetPort($61) or 3)
  else
    begin

{$ifndef w95}
      //Tone.Prepare;
      Tone.Play;
{$endif}
    end;
end;

procedure NoSound;
begin
  if _WIN2KMODE = FALSE then
    SetPort($61,GetPort($61) and $FC)
  else
{$ifndef w95}
    Tone.Stop;
{$endif}
end;


procedure ControlPTT(PTTON : boolean);
var _out : word;
    _outb : byte;
begin
  PTTFLAG := PTTON;

{$ifndef w95}
  if KeyingPort = tkpUSB then
    begin
      if PTTON then
        _outb := _usbportbuf and $FD
      else
        _outb := _usbportbuf or $02;
      _usbportbuf := _outb;
      //SetUSBPort(_outb);
      exit;
    end;
{$endif}

  if KeyingPort in [tkpSerial1, tkpSerial2] then
    begin
      if RigControl.ZCom3 = nil then
        exit;
      if _PTTREVERSE Then
        RigControl.ZCom3.ToggleRTS(not(PTTON))
      else
        RigControl.ZCom3.ToggleRTS(PTTON);
      exit;
    end;

  if PTTON then
    _out := _pttout
  else
    _out := $00;

  if _PTTREVERSE then
    _out := _out xor _pttout;

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
    end;
end;

procedure SetPTT(_on : boolean);
begin
  PTTEnabled := _on;
end;

function PTTIsOn : boolean;
begin
  Result := PTTFLAG;
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
{$ifndef w95}
  Tone.Frequency := Hz;
{$endif}
  if Machine <> NEC98 then
    begin
      w := BeepF div Hz;
      SetPort($43, $B6);
      SetPort($42, Low(w));
      SetPort($42, Hi(w));
    end
  else
    begin
      {
      if Hz = 0 then
        exit;
      w := Round(SysClock98 / Hz);
      SetPort($3fdb, Low(w));
      SetPort($3fdb, Hi(w));
      }
    end;
end;

function GetPitch : word;
begin
  Result := Hz;
end;

Procedure SetCWSendBufChar(C : char);
var m : byte;
begin
  for m:=1 to codemax do
    CWSendBuf[0, codemax*(tailcwstrptr-1)+m]:=CodeTable[Ord(C)][m];
  inc(tailcwstrptr);
  if tailcwstrptr>charmax then tailcwstrptr:=1;

  for m:=1 to codemax do
    CWSendBuf[0, codemax*(tailcwstrptr-1)+m]:=$FF;
end;

Procedure SetCWSendBufCharPTT(C : char);
var m : integer;
begin
  if PTTEnabled and Not(PTTIsOn) then
    begin
      ControlPTT(True);
      sss := _pttbefore;
    end;

  //SendOK := False;
  for m:=1 to codemax do
    CWSendBuf[0, codemax*(tailcwstrptr-1)+m]:=CodeTable[Ord(C)][m];

  if PTTEnabled then
    begin
      _pttholdcount := _pttafter;
      CWSendBuf[0, codemax*(tailcwstrptr-1)+codemax + 1]:=$A2; {holds PTT until pttafter expires}

      inc(tailcwstrptr);
      if tailcwstrptr>charmax then tailcwstrptr:=1;
      exit;
    end;

  inc(tailcwstrptr);
  if tailcwstrptr>charmax then tailcwstrptr:=1;

  for m:=1 to codemax do
    CWSendBuf[0, codemax*(tailcwstrptr-1)+m]:=$FF;
  //SendOK := True;
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

    end;
  Result := SS;
end;

Procedure SetCWSendBuf( b: byte; S :ShortString );
var n,m,Len : word;
    code : integer;
    SS : string;
begin
  SS := S;
  if SS[1]='>' then
    begin
      Val(SS[2]+SS[3], n, code);
      SetCWSpeed(n);
      SS:=copy(SS,4,255);
    end;

  SS := DecodeCommands(SS);

  Len:=Length(SS);
  for n:=1 to Len do
    begin
      if SS[n] = ':' then {callsign 1st char}
        callsignptr := n;
      for m:=1 to codemax do
      CWSendBuf[b,codemax*(n-1)+m]:=CodeTable[Ord(SS[n])][m];
    end;
  CWSendBuf[b,codemax*Len+1]:=$FF;
end;

Procedure SendStr(sStr : ShortString);
var SS : string;
begin
  if sStr = '' then
    exit;
  SS := DecodeCommands(sStr);
  //SS := S;
  if PTTEnabled {and Not(PTTIsOn)} then
    SS := '('+SS+')';
  SetCWSendBuf(0,SS);
  cwstrptr:=1;
  sendok:=true;
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

Procedure SendStrFIFO(sStr : ShortString);
var n : integer;
    SS : string;
begin
  {StringBuffer := StringBuffer + sStr; }
  SS := DecodeCommands(sStr);
  if PTTEnabled then
    SS := '('+SS+')';
  for n := 1 to Length(SS) do
    begin
      if SS[n] = ':' then {callsign 1st char}
        callsignptr := n;
      SetCWSendBufChar(SS[n]);
    end;
end;

procedure CW_ON;
begin
  Case KeyingPort of
    tkpParallel : SetPort(PRTport, _cwon);
    tkpSerial1, tkpSerial2 : RigControl.ZCom3.ToggleDTR(True);
{$ifndef w95}
    tkpUSB : SetUSBPort(_usbportstatus and $FE);
{$endif}
  end;
end;

procedure CW_OFF;
begin
  Case KeyingPort of
    tkpParallel : SetPort(PRTport, _cwoff);
    tkpSerial1, tkpSerial2 : RigControl.ZCom3.ToggleDTR(False);
{$ifndef w95}
    tkpUSB : SetUSBPort(_usbportstatus or $01);
{$endif}
 end;
end;

Procedure TimerProcess(uTimerID, uMessage: word;
                       dwUser, dw1, dw2: Longint); stdcall;
var  workw, workx : word; {work variables in TimerProcess $AA}
label xxx;
label _ff;
begin
  if sss > 0 then
    begin
     dec(sss);
    end
  else
    begin
      if SendOK then
        begin
          Case CWSendBuf[SelectedBuf,cwstrptr] of
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
                  SetPort(PRTport, GetPort(PRTport) or $80);
                  sss:=100; {30 ms}
                end;
            5 : begin SetPort(PRTport, GetPort(PRTport) and $7F); nosound; sss:=_bl1; end; {???}
            (*
            0 : begin SetPort(PRTport, GetPort(PRTport) and $FE); nosound; sss:=_bl1; end;
            2 : begin SetPort(PRTport, GetPort(PRTport) and $FE); nosound; sss:=_bl3; end;
            1 : begin
                  SetPort(PRTport, GetPort(PRTport) or $01);
                  if BGKsidetone then sound(Hz);
                  sss:=_dot;
                end;
            3 : begin
                  SetPort(PRTport, GetPort(PRTport) or $01);
                  if BGKsidetone then sound(Hz);
                  sss:=_dash;
                end;
            4 : begin
                  if BGKsidetone then sound(Hz);
                  SetPort(PRTport, GetPort(PRTport) or $80);
                  sss:=100; {30 ms}
                end;
            5 : begin SetPort(PRTport, GetPort(PRTport) and $7F); nosound; sss:=_bl1; end;
            *)
            9 : begin
                  BGKRefresh := True;
                  cwstrptr:=(cwstrptr div codemax +1)*codemax;
                end;
          $A2 : begin
                  if _pttholdcount <= 0 then
                    begin
                      //ControlPTT(False);
                      // same as $FF
                      cwstrptr:=0;
                      callsignptr := 0;
                      mousetail:=1;
                      tailcwstrptr := 1;
                      paddle_waiting:=true;
                      CWSendBuf[SelectedBuf,1]:=$FF;
                      CW_OFF;
                      nosound;
                      ControlPTT(False);
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
                      CWSendBuf[SelectedBuf,1]:=$FF;
                      CQrep := 0;
                      SelectedBuf:=0;
                      goto _ff;
                    end
                  else
                    if CQrep>4 then
                      begin
                        SelectedBuf:=CQrep mod 3; //random(3);
                        if SelectedBuf > 2 then
                          begin
                            DEBUG_FLAG := SELECTEDBUF;
                            SelectedBuf := 0;
                          end;
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
_ff:
                  cwstrptr:=0;
                  callsignptr := 0;
                  mousetail:=1;
                  tailcwstrptr := 1;
                  paddle_waiting:=true;
                  CWSendBuf[SelectedBuf,1]:=$FF;
                  //SetPort(PRTport, _cwoff);
{$ifndef w95}
                  if KeyingPort <> tkpUSB then
                    CW_OFF;
{$else}
                  CW_OFF;
{$endif}
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
          $0B : UserFlag := False;

          end;
          inc(cwstrptr);

            
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

{$ifndef w95}
procedure TZLHID.DeviceChanges(Sender: TObject);
begin
   USB_Detected := False;
   if USBIF <> nil then
     begin
       HidController.CheckOut(USBIF);
     end;
   HidController.Enumerate;
end;

procedure TZLHID.DeviceUnplug(HidDev: TJvHidDevice);
begin
end;

function TZLHID.Enumeration(HidDev: TJvHidDevice; Index: Integer): Boolean;
var
   p: string;
begin
   with HidDev do
   begin
      if (Attributes.ProductID = USBIF4CW_PRODID) and (Attributes.VendorID = USBIF4CW_VENDORID) then
        begin
          if HIDController.CheckOutByIndex(USBIF, Index) = True then
            begin
             USBIF.OpenFile;
             USB_Detected := True;
             Result := False;
             exit;
            end;
        end;
   end;
   Result := True;
end;
{$endif}

procedure InitializeBGK(msec : integer);
var n, m : word;
var debugfile : textfile;
begin
if DEBUGMODE then
  begin
    assignfile(debugfile, 'DEBUG.TXT');
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-1');
    closefile(debugfile);
  end;
  Initialized := True;
  RandCQStr[1] := '';
  RandCQStr[2] := '';
  BGKRefresh := False;

{$ifndef w95}
 HIDController := nil;
if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-9-1');
    closefile(debugfile);
  end;

 HidController := TJvHidDeviceController.Create(nil);

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-10');
    closefile(debugfile);
  end;

 ZLHID := TZLHID.Create;
 USBIF := nil;
 USB_Detected := False;

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-11');
    closefile(debugfile);
  end;

 with HidController do
   begin
     OnDeviceChange := ZLHID.DeviceChanges;
     OnEnumerate    := ZLHID.Enumeration;
     OnDeviceUnplug := ZLHID.DeviceUnplug;
     Enumerate;
   end;

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-12');
    closefile(debugfile);
  end;

{$endif}



if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-2');
    closefile(debugfile);
  end;
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
if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-3');
    closefile(debugfile);
  end;
  SetLoopTime(2.0);
  for n:=0 to 255 do
    for m:= 1 to codemax do
      CodeTable[n,m]:=$FF;
  for m := 0 to 2 do
    CWSendBuf[m,1]:=$FF;
if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-4');
    closefile(debugfile);
  end;
  SendOK := True;
  sss := 10;
  SetPitch(800); {800 Hz}
if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-5');
    closefile(debugfile);
  end;
  BGKWeight := 50;
  BGKSideTone := True;
  SetCWSpeed(25);
  CQrep := 0;
  CQmax := 15;
if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-6');
    closefile(debugfile);
  end;

  timeBeginPeriod(1);

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-7');
    closefile(debugfile);
  end;
  TimerID := timeSetEvent(millisec,0, @TimerProcess, 0, time_Periodic);

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-8');
    closefile(debugfile);
  end;

  PTTEnabled := False;
  SetPTTDelay(50, 50); {50ms/50ms}

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-9');
    closefile(debugfile);
  end;


(*
{$ifndef w95}
 HIDController := nil;
if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-9-1');
    closefile(debugfile);
  end;

 HidController := TJvHidDeviceController.Create(nil);

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-10');
    closefile(debugfile);
  end;

 ZLHID := TZLHID.Create;
 USBIF := nil;
 USB_Detected := False;

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-11');
    closefile(debugfile);
  end;

 with HidController do
   begin
     OnDeviceChange := ZLHID.DeviceChanges;
     OnEnumerate    := ZLHID.Enumeration;
     OnDeviceUnplug := ZLHID.DeviceUnplug;
     Enumerate;
   end;

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-12');
    closefile(debugfile);
  end;

{$endif}
*)

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-13');
    closefile(debugfile);
  end;

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

  CodeTable[ord('"')][1] := $0B; // set UserFlag to false
  CodeTable[ord('"')][2] := 9;

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

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-14');
    closefile(debugfile);
  end;

  for n:=1 to codemax do
    CodeTable[Ord('%')][n]:=$EE;

  for n:=1 to codemax do
    CodeTable[Ord('{')][n]:=$14;

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4-15');
    closefile(debugfile);
  end;

end;

function CloseBGK : word;
var R : UINT;
begin
  if not (KeyingPort in [tkpSerial1, tkpSerial2]) then
    ControlPTT(False);
  if not(Initialized) then exit;
  R:=timeKillEvent(TimerID);

  if Initialized then
    timeEndPeriod(1);

  {R:=timeKillEvent(PaddleTimerID);}
  R := 0;
  NoSound;
  if not (KeyingPort in [tkpSerial1, tkpSerial2]) then
    CW_OFF;

{$ifndef w95}
  if _WIN2KMODE then
    begin
      if USBIF <> nil then
        begin
          KeyingPort := tkpParallel;
          SleepEx(10, false);
          _SetUSBPort($FF);
          USBIF.CloseFile;
          HidController.CheckIn(USBIF);
          ZLHID.Destroy;
          USB_Detected := False;
        end;
    end;
{$endif}

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
  //SetPort(PRTport, _cwoff);
  CW_OFF;
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

function GetCWPort : ShortString;
begin
  Result := CWPortStr;
end;

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
  SelectedBuf := 0; // ver 2.1b
  callsignptr := 0;
  mousetail:=1;
  tailcwstrptr := 1;
  paddle_waiting:=true;
  NoSound;
  SendOK := True;
  CQrep := 0;
  CW_OFF;

  UserFlag := False;

  if PTTEnabled then
    ControlPTT(False);
end;

procedure CancelLastChar;
var m : integer;
begin
  if ((tailcwstrptr-1)*codemax+1) > (cwstrptr) then
    begin
      dec(tailcwstrptr, 1);
      for m:=1 to codemax do
        CWSendBuf[SelectedBuf, codemax*(tailcwstrptr-1)+m]:=$FF;
    end;
end;

Procedure SetCWSendBufChar2(C : char; CharPos : word);
var m : integer;
begin
  for m:=1 to codemax do
    CWSendBuf[0, codemax*(CharPos-1)+m]:=CodeTable[Ord(C)][m];
end;

procedure SetCallSign(S : ShortString);
var ss : string[BGKCALLMAX];
    i : word;
begin
  if callsignptr = 0 then exit;
  ss := S + '*********************';
  while pos('.',ss) > 0 do
    begin
      ss[pos('.',ss)] := '?';
    end;
  ss[BGKCALLMAX] := '^'; {pause}
  for i := 1 to BGKCALLMAX do
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
// ver 2.1c
  RandCQStr[1] := Str1;
  SetCWSendBuf(1, '('+Str1+')@');
  RandCQStr[2] := Str2;
  SetCWSendBuf(2, '('+Str2+')@');
{  if Str1 <> '' then
    begin
      RandCQStr[1] := Str1;
      SetCWSendBuf(1, '('+Str1+')@');
    end
  if Str2 <> '' then
    begin
      RandCQStr[2] := Str2;
      SetCWSendBuf(2, '('+Str2+')@');
    end;  }
end;

procedure SetPTTPortDirect(p : word);
begin
  PTTport := p;
  _pttout := $08; {parallel}
end;

procedure SetCWPortDirect(p : word);
begin
  PRTport := p;
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

{$ifndef w95}
Procedure PaddleProcessUSB;
var OutReport : array[0..8] of byte;
    InReport : array[0..8] of byte;
    BR : DWORD;
    PaddleStatus, laststatus : byte;
begin
repeat
  if USBIF = nil then exit;
  OutReport[0] := 0;
  OutReport[1] := 4;
  OutReport[2] := $0F;
  OutReport[3] := 4;
  OutReport[4] := 0;
  OutReport[5] := 0;
  OutReport[6] := 0;
  OutReport[7] := 0;
  OutReport[8] := 0;
  InReport[0] := 0;
  InReport[1] := 4;
  InReport[2] := $0F;
  InReport[3] := 4;
  InReport[4] := 0;
  InReport[5] := 0;
  InReport[6] := 0;
  InReport[7] := 0;
  InReport[8] := 0;

  USBIF.ReadFile(InReport, USBIF.Caps.InputReportByteLength, BR);

  if not ( (BGK32LIB.KeyingPort = tkpUSB) and (PaddlePort = 0) ) then
    begin  // ver 2.2b

      if (InReport[1] = 4) and (InReport[3] = 4) and (InReport[2]<>$F) then
        begin
          PaddleStatus := $05 and InReport[2];
          case mousetail-cwstrptr of
            0 :
              case PaddleStatus of
                $00 : { both }
                  case CWSendBuf[0,mousetail-2] of
                    1 : m_set(3);
                    3 : m_set(1);
                  end;
                $01 : {dit}
                  if paddle_waiting then m_set(mouX);
                $04 : {dah}
                  if paddle_waiting then m_set(mouY);
               end;
            1 :
               case PaddleStatus of
                 $00 :
                   case CWSendBuf[0,cwstrptr-1] of
                     1 : m_set(3);
                     3 : m_set(1);
                   end;
                 $01 : if CWSendBuf[0,cwstrptr-1] = mouY then
                     m_set(mouX);
                 $04 : if CWSendBuf[0,cwstrptr-1] = mouX then
                     m_set(mouY);
               end;
             else
               if (PaddleStatus=$01) or (PaddleStatus=$04) then
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
         end;

    end;   // ver 2.2b

  if _usbportbuf = _usbportstatus then
    begin
      USBIF.WriteFile(OutReport, USBIF.Caps.OutputReportByteLength, BR);
    end
  else
    begin
      _SetUSBPort(_usbportbuf);
    end;
until KeyingPort <> tkpUSB;

end;
{$endif}

Procedure PaddleProcess;
begin
(*
{$ifndef w95}
if KeyingPort = tkpUSB then
  begin
    PaddleProcessUSB;
    exit;
  end;
{$endif}
*)
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

function BinaryStr(B : Byte) : string;
const _16str : array[0..$F] of string =
      ('0000', '0001', '0010', '0011',
       '0100', '0101', '0110', '0111',
       '1000', '1001', '1010', '1011',
       '1100', '1101', '1110', '1111');
var i : integer;
begin
  i := B;
  Result := _16str[B div $F] + _16str[B and $F];
end;

function GetPRTPort : string;
var B : byte;
begin
  B := GetPort(PTTPort);
  Result := BinaryStr(B) + ' ' + IntToStr(B);
end;



begin
{$ifndef w95}
 Tone := TToneGen.Create(nil);
 Tone.Waveform := tgSine;
 Tone.Duration := 100;
 Tone.Loop := True;
 Tone.Frequency := 700;
{$endif}
end.
