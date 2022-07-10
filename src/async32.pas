//******************************************************************************
//                      VARIAN ASYNC32 COMPONENT v1.01
//               (c) VARIAN SOFTWARE SERVICES NL 1996-1997
//                          ALL RIGHTS RESERVED
//******************************************************************************

//Written by Varian Software Services NL, The Netherlands
//Subject: Async32 Component
//Version: 1.01
//Platform: Delphi 3, Win95, NT
//Date: 2 June 1997
//Last update: 13st September 1997
//Release: Freeware, just let us know what you think of it....

//if you make any modifications to the source, please send us a copy.
//We will verify your changes and give you proper credit when included.

//Please send any questions, remarks or suggestions to our following
//address: Varian@worldaccess.nl

// THIS SOFTWARE IS PROVIDED 'AS-IS', WITHOUT ANY EXPRESS OR IMPLIED
//WARRANTY. IN NO EVENT WILL THE AUTHOR BE HELD LIABLE FOR ANY DAMAGES
//               ARISING FROM THE USE OF THIS SOFTWARE.

//****************************************************************************
//     Our thanks goes to all the people who helped creating and
//     testing this component for their support and suggestions.
//****************************************************************************

//Shortcuts:
//CTS        - Clear to send
//DSR        - Data set ready
//RING       - Ring indicator
//RLSD       - Receive line signal detect
//EV_BREAK   - A break was detected on input.
//EV_CTS     - The CTS (clear-to-send) signal changed state.
//EV_DSR     - The DSR (data-set-ready) signal changed state.
//EV_ERR     - A line-status error occurred. Line-status errors
//             are CE_FRAME, CE_OVERRUN, and CE_RXPARITY.
//EV_RING    - A ring indicator was detected.
//EV_RLSD    - The RLSD (receive-line-signal-detect) signal changed state.
//EV_RXCHAR  - A character was received and placed in the input buffer.
//EV_RXFLAG  - The event character was received and placed in the input buffer.
//             The event character is specified in the device's DCB structure,
//             which is applied to a serial port by using the SetCommState function.
//EV_TXEMPTY - The last character in the output buffer was sent.

//Available provider subtypes:
//PST_FAX            FAX device
//PST_LAT            LAT protocol
//PST_MODEM          Modem device
//PST_NETWORK_BRIDGE Unspecified network bridge
//PST_PARALLELPORT   Parallel port
//PST_RS232          RS-232 serial port
//PST_RS422          RS-422 port
//PST_RS423          RS-423 port
//PST_RS449          RS-449 port
//PST_SCANNER        Scanner device
//PST_TCPIP_TELNET   TCP/IP Telnet® protocol
//PST_UNSPECIFIED    Unspecified
//PST_X25            X.25 standards

//Errorflags OnErrorSignal:
//CE_BREAK       The hardware detected a break condition.
//CE_DNS         Windows 95 only: A parallel device is not selected.
//CE_FRAME       The hardware detected a framing error.
//CE_IOE         An I/O error occurred during communications with the device.
//CE_MODE        The requested mode is not supported, or the hFile parameter
//               is invalid. If this value is specified, it is the only valid error.
//CE_OOP         Windows 95 only: A parallel device signaled that it is out of paper.
//CE_OVERRUN     A character-buffer overrun has occurred. The next character is lost.
//CE_PTO         Windows 95 only: A time-out occurred on a parallel device.
//CE_RXOVER      An input buffer overflow has occurred. There is either no
//               room in the input buffer, or a character was received after
//               the end-of-file (EOF) character.
//CE_RXPARITY    The hardware detected a parity error.
//CE_TXFULL      The application tried to transmit a character, but the output
//               buffer was full.

unit async32;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, dialogs;

type
  TC32Event = procedure(Sender: TObject; Status: dword) of object;
  TC32EventState = (evBreak, evCTS, evDSR, evError, evRing,
    evRlsd, evRxChar, evRxFlag, evTxEmpty);
  TC32EventType = set of TC32EventState;

  TC32Thread = class(TThread)
  private
    FHandle: THandle;
    FStatus: dword;
    FOnSignal: TC32Event;
    hCloseEvent: THandle;
  protected
    procedure Execute; override;
    procedure DoOnSignal;
  public
    constructor Create(Handle: THandle; Events: TC32EventType);
    destructor Destroy; override;
    procedure ReleaseThread;
    property OnSignal: TC32Event read FOnSignal write FOnSignal;
  end;

  TBaudRate = (cbr110, cbr300, cbr600, cbr1200, cbr2400, cbr4800,
               cbr9600, cbr14400, cbr19200, cbr38400, cbr56000,
               cbr57600, cbr115200, cbr128000, cbr256000);
  TParity = (paNone, paOdd, paEven, paMark, paSpace);
  TStopbits = (sb10, sb15, sb20);
  TDatabits=(da4, da5, da6, da7, da8);
  TFlowControl = (fcNone, fcCTS, fcDTR, fcSoftware, fcDefault);

  TComm32Option = (osParityCheck, osDsrSensitivity, osIgnoreXOff,
                osErrorChar, osNullStrip);
  TComm32Options = set of TComm32Option;

  TC32RxCharEvent = procedure(Sender: TObject; Count: Integer) of object;
  TC32ErrorEvent = procedure(Sender: TObject; Errors: Integer) of object;
  TC32OpenEvent = procedure(Sender: TObject; ProviderSubType: Integer;
    Error: Integer) of object;

  TCustomComm32 = class(TComponent)
  private
    FHandle: THandle;
    FWriteEvent: THandle;
    FCT: TComStat;
    FDCB: TDCB;
    FCommConfig: TCommConfig;
    FTC32Thread: TC32Thread;
    FErrors: dword;
    FIOpending: Boolean;
    FWriteOS: TOverlapped;
    FDeviceName: String;
    FBaudRate: TBaudRate;
    FParity: TParity;
    FStopbits: TStopbits;
    FDatabits: TDatabits;
    FMonitorEvents: TC32EventType;
    FReadBufferSize: Integer;
    FWriteBufferSize: Integer;
    FFlowControl: TFlowControl;
    FXonChar: char;
    FXoffChar: char;
    FOptions: TComm32Options;
    FOnOpen: TC32OpenEvent;
    FOnBreakSignal: TNotifyEvent;
    FOnCTSSignal: TNotifyEvent;
    FOnDSRSignal: TNotifyEvent;
    FOnErrorSignal: TC32ErrorEvent;
    FOnRingSignal: TNotifyEvent;
    FOnRLSDSignal: TNotifyEvent;
    FOnRxCharSignal: TC32RxCharEvent;
    FOnRxFlagSignal: TNotifyEvent;
    FOnTxEmptySignal: TNotifyEvent;
    procedure EnableHandshaking(var DCB: TDCB);
    function GetModemState(Index: Integer): Boolean;
    procedure HandleTC32Event(Sender: TObject; Status: dword);
    procedure SetBaudRate(Value: TBaudRate);
    procedure SetParity(Value: TParity);
    procedure SetStopbits(Value: TStopBits);
    procedure SetDatabits(Value: TDatabits);
    procedure SetFlowControl(Value: TFlowControl);
    procedure SetXonChar(Value: char);
    procedure SetXoffChar(Value: char);
    procedure SetOptions(Value: TComm32Options);
  protected
    procedure EventStateChange(Event: Integer); dynamic;
    procedure AfterOpen(ProviderSubType: Integer; Error: Integer); dynamic;
    property DeviceName: string read FDeviceName write FDeviceName;
    property BaudRate: TBaudRate read FBaudRate write SetBaudRate default cbr9600;
    property Parity: TParity read FParity write SetParity default paNone;
    property Stopbits: TStopbits read FStopbits write SetStopbits default sb10;
    property Databits: TDatabits read FDatabits write SetDatabits default da8;
    property MonitorEvents: TC32EventType read FMonitorEvents write FMonitorEvents;
    property ReadBufferSize: Integer read FReadBufferSize write FReadBufferSize default 4096;
    property WriteBufferSize: Integer read FWriteBufferSize write FWriteBufferSize default 2048;
    property FlowControl: TFlowControl read FFlowControl write SetFlowControl default fcDefault;
    property XonChar: char read FXonChar write SetXonChar default #17;
    property XoffChar: char read FXoffChar write SetXoffChar default #19;
    property Options: TComm32Options read FOptions write SetOptions;
    {Comm signal events}
    property OnOpen: TC32OpenEvent read FOnOpen write FOnOpen;
    property OnBreak: TNotifyEvent read FOnBreakSignal write FOnBreakSignal;
    property OnCTS: TNotifyEvent read FOnCTSSignal write FOnCTSSignal;
    property OnDSR: TNotifyEvent read FOnDSRSignal write FOnDSRSignal;
    property OnRing: TNotifyEvent read FOnRingSignal write FOnRingSignal;
    property OnRLSD: TNotifyEvent read FOnRLSDSignal write FOnRLSDSignal;
    property OnError: TC32ErrorEvent read FOnErrorSignal write FOnErrorSignal;
    property OnRxChar: TC32RxCharEvent read FOnRxCharSignal write FOnRxCharSignal;
    property OnRxFlag: TNotifyEvent read FOnRxFlagSignal write FOnRxFlagSignal;
    property OnTxEmpty: TNotifyEvent read FOnTxEmptySignal write FOnTxEmptySignal;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    function Enabled: Boolean;
    function Write(const Buf; Count: Integer): Integer;
    function Read(var Buf; Count: Integer): Integer;
    function InQueCount: Integer;
    function OutQueCount: Integer;
    procedure PurgeIn;
    procedure PurgeOut;
    //Comm escape functions
    function DTR(State: Boolean): boolean;
    function RTS(State: Boolean): boolean;
    function BREAK(State: Boolean): boolean;
    function XON(State: Boolean): boolean;
    //Comm status flags
    property CTS: Boolean index 1 read GetModemState;
    property DSR: Boolean index 2 read GetModemState;
    property RING: Boolean index 3 read GetModemState;
    property RLSD: Boolean index 4 read GetModemState;
    //Reference to internal device handle
    property Handle: THandle read FHandle;
  end;

  TComm32 = class(TCustomComm32)
  published
    property DeviceName;
    property BaudRate;
    property Parity;
    property Stopbits;
    property Databits;
    property MonitorEvents;
    property ReadBufferSize;
    property WriteBufferSize;
    property FlowControl;
    property XonChar;
    property XoffChar;
    property Options;
    property OnOpen;
    property OnBreak;
    property OnCTS;
    property OnDSR;
    property OnError;
    property OnRing;
    property OnRLSD;
    property OnRxChar;
    property OnRxFlag;
    property OnTxEmpty;
  end;


procedure Register;


implementation

const
  fBinary           = $00000001;
  fParity           = $00000002;
  fOutxCtsFlow      = $00000004;
  fOutxDsrFlow      = $00000008;
  fDtrControl       = $00000030;
  fDsrSensitivity   = $00000040;
  fTXContinueOnXoff = $00000080;
  fOutX             = $00000100;
  fInX              = $00000200;
  fErrorChar        = $00000400;
  fNull             = $00000800;
  fRtsControl       = $00003000;
  fAbortOnError     = $00004000;
  fDummy2           = $FFFF8000;

  CBR: array[TBaudRate] of Integer =
    (CBR_110, CBR_300, CBR_600, CBR_1200, CBR_2400, CBR_4800, CBR_9600,
     CBR_14400, CBR_19200, CBR_38400, CBR_56000, CBR_57600, CBR_115200,
     CBR_128000, CBR_256000);

  DAB: array[TDatabits] of Integer =
    (4, 5, 6, 7, 8);

  PAR: array[TParity] of Integer =
    (NOPARITY, ODDPARITY, EVENPARITY, MARKPARITY, SPACEPARITY);

  STB: array[TStopbits] of Integer =
    (ONESTOPBIT, ONE5STOPBITS, TWOSTOPBITS);

  OPT: array[TComm32Option] of Integer =
   (fParity, fDsrSensitivity, fTXContinueOnXoff, fErrorChar, fNull);

//TC32Thread

constructor TC32Thread.Create(Handle: THandle; Events: TC32EventType);
const
  EvList: array[TC32EventState] of dword = (EV_BREAK, EV_CTS, EV_DSR, EV_ERR,
    EV_RING, EV_RLSD, EV_RXCHAR, EV_RXFLAG, EV_TXEMPTY);
var
  EvIndex: TC32EventState;
  AttrWord: dword;
begin
  Inherited Create(true);
  Priority := tpHighest;
  FHandle := Handle;
  AttrWord := 0;
  for EvIndex := evBREAK to evTXEMPTY do
    if EvIndex in Events then
      AttrWord := AttrWord or EvList[EvIndex];
  SetCommMask(FHandle, AttrWord);
  Resume;
end;

destructor TC32Thread.Destroy;
begin
  CloseHandle(hCloseEvent);
  Inherited Destroy;
end;

procedure TC32Thread.Execute;
var
  HandlesToWaitFor: array[0..2] of THandle;
  dwHandleSignaled: DWORD;
  BytesTransferred: DWORD; //Dummy, not valid for WaitCommEvent
  OverlappedCommEvent: TOverlapped;
begin
  FillChar(OverlappedCommEvent, Sizeof(OverlappedCommEvent), 0);
  hCloseEvent := CreateEvent(nil, True, False, nil);
  OverlappedCommEvent.hEvent := CreateEvent(nil, True, True, nil);
  HandlesToWaitFor[0] := hCloseEvent;
  HandlesToWaitFor[1] := OverlappedCommEvent.hEvent;

  repeat
    WaitCommEvent(FHandle, FStatus, @OverlappedCommEvent);
    dwHandleSignaled := WaitForMultipleObjects(2, @HandlesToWaitFor, False, INFINITE);
    case dwHandleSignaled of
      WAIT_OBJECT_0    : Break;
      WAIT_OBJECT_0 + 1:
          if GetOverlappedResult(FHandle, OverlappedCommEvent,
             BytesTransferred, false) then Synchronize(DoOnSignal);
      else
        Break  //This should never occur
    end;
  until Terminated;
  PurgeComm(FHandle, PURGE_RXABORT + PURGE_RXCLEAR);
  CloseHandle(OverlappedCommEvent.hEvent);
end;

procedure TC32Thread.ReleaseThread;
begin
  SetEvent(hCloseEvent);
end;

procedure TC32Thread.DoOnSignal;
begin
  if Assigned(FOnSignal) then FOnSignal(Self, FStatus);
end;

//TCustomComm32

constructor TCustomComm32.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  FHandle := INVALID_HANDLE_VALUE;
  FDeviceName := 'COM2';
  FBaudRate := cbr9600;
  FParity := paNone;
  FStopbits := sb10;
  FDatabits := da8;
  FXonChar := #17;
  FXoffChar := #19;
  FOptions := [];
  FMonitorEvents := [evBreak, evCTS, evDSR, evError, evRing,
                     evRlsd, evRxChar, evRxFlag, evTxEmpty];
  FReadBufferSize := 4096;
  FWriteBufferSize := 2048;
  FFlowControl := fcDefault;
  FWriteEvent := CreateEvent(nil, false, false, nil);
end;

destructor TCustomComm32.Destroy;
begin
  Close;
  CloseHandle(FWriteEvent);
  Inherited Destroy;
end;

function TCustomComm32.Enabled: Boolean;
begin
  Result := FHandle <> INVALID_HANDLE_VALUE;
end;

procedure TCustomComm32.AfterOpen(ProviderSubType: Integer; Error: Integer);
begin
  if assigned(FOnOpen) then
    FOnOpen(Self, ProviderSubType, Error);
end;

procedure TCustomComm32.Open;
var
  CommTimeouts: TCommTimeouts;
  OptIndex: TComm32Option;
  Size: Integer;
begin
  Close;

  SetLastError(0); //remove any pending errors

  Fillchar(FCommConfig, Sizeof(FCommConfig), 0);

  FHandle := CreateFile(PCHAR(FDeviceName), GENERIC_READ or GENERIC_WRITE,
                        0, nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
  if Enabled then
  begin
    Size := Sizeof(TCommConfig);
    GetCommConfig(FHandle, FCommConfig, Size);
    SetCommState(FHandle, FCommConfig.DCB); //Initialize windows hardware settings

    SetupComm(FHandle, FReadBufferSize, FWriteBufferSize);

    GetCommTimeOuts(FHandle, CommTimeOuts);
    CommTimeouts.ReadIntervalTimeout := 250;
    CommTimeouts.ReadTotalTimeoutMultiplier := 0;
    CommTimeouts.ReadTotalTimeoutConstant := 0;
    CommTimeouts.WriteTotalTimeoutMultiplier := 0;
    CommTimeouts.WriteTotalTimeoutConstant := 0;
    SetCommTimeOuts(FHandle, CommTimeOuts);

    GetCommState(FHandle, FDCB);
    FDCB.BaudRate := CBR[FBaudRate];
    FDCB.Parity := PAR[FParity];
    FDCB.Stopbits := STB[FStopbits];
    FDCB.Bytesize := DAB[FDatabits];

    for OptIndex := osParityCheck to osNullStrip do
     if OptIndex in FOptions then
       FDCB.Flags := FDCB.Flags or OPT[OptIndex]
     else
       FDCB.Flags := FDCB.Flags and not OPT[OptIndex];

    EnableHandshaking(FDCB);
    SetCommState(FHandle, FDCB);

    FTC32Thread := TC32Thread.Create(FHandle, FMonitorEvents);
    FTC32Thread.OnSignal := HandleTC32Event;
  end;

  AfterOpen(FCommConfig.dwProviderSubType, GetLastError);
end;

procedure TCustomComm32.Close;
begin
  if Enabled then
  begin
    if FTC32Thread <> nil then
    begin
      FTC32Thread.ReleaseThread;
      FTC32Thread.Suspend;
    end;
    FTC32Thread.Free;
    CloseHandle(FHandle);
    FHandle := INVALID_HANDLE_VALUE;
  end;
end;

function TCustomComm32.Write(const Buf; Count: Integer): Integer;
var
  dwBytesTransfered: DWORD;
begin
  //no writes allowed while IOPending
  if FIOPending then
  begin
    while not GetOverlappedResult(FHandle, FWriteOS,
      dwBytesTransfered, false) do
    begin
      Result := 0;
      exit;
    end;
    FIOPending := false;
  end;

  FillChar(FWriteOS, Sizeof(FWriteOS), 0);
  FWriteOS.hEvent := FWriteEvent;
  if not WriteFile(FHandle, Buf, Count, Result, @FWriteOS) then
    if (GetLastError = Error_IO_Pending) then
      FIOPending := true
    else
      Result := -1;
end;

function TCustomComm32.Read(var Buf; Count: Integer): Integer;
var
  OS: TOverlapped;
begin
  Fillchar(OS, Sizeof(OS), 0);
  if not ReadFile(FHandle, Buf, Count, Result, @OS) then Result := -1;
end;

procedure TCustomComm32.EventStateChange(Event: Integer);
begin
  case Event of
    EV_BREAK:
      if assigned(FOnBreakSignal) then
        FOnBreakSignal(self);
    EV_CTS:
      if assigned(FOnCTSSignal) then
        FOnCTSSignal(self);
    EV_DSR:
      if assigned(FOnDSRSignal) then
        FOnDSRSignal(self);
    EV_ERR:
      if assigned(FOnErrorSignal) then
        FOnErrorSignal(self, FErrors);
    EV_RING:
      if assigned(FOnRingSignal) then
        FOnRingSignal(self);
    EV_RLSD:
      if assigned(FOnRLSDSignal) then
        FOnRLSDSignal(self);
    EV_RXCHAR:
      if assigned(FOnRxCharSignal) then
        FOnRxCharSignal(self, FCT.cbInQue);
    EV_RXFLAG:
      if assigned(FOnRxFlagSignal) then
        FOnRxFlagSignal(self);
    EV_TXEMPTY:
      if assigned(FOnTxEmptySignal) then
        FOnTxEmptySignal(self);
  end;
end;

procedure TCustomComm32.HandleTC32Event(Sender: TObject; Status: dword);
begin
  ClearCommError(FHandle, FErrors, @FCT);
  if (Status and EV_BREAK > 0) then EventStateChange(EV_BREAK);
  if (Status and EV_CTS > 0) then EventStateChange(EV_CTS);
  if (Status and EV_DSR > 0) then EventStateChange(EV_DSR);
  if (Status and EV_ERR > 0) then EventStateChange(EV_ERR);
  if (Status and EV_RING > 0) then EventStateChange(EV_RING);
  if (Status and EV_RLSD > 0) then EventStateChange(EV_RLSD);
  if (Status and EV_RXCHAR > 0) then EventStateChange(EV_RXCHAR);
  if (Status and EV_RXFLAG > 0) then EventStateChange(EV_RXFLAG);
  if (Status and EV_TXEMPTY > 0) then EventStateChange(EV_TXEMPTY);
end;

procedure TCustomComm32.SetBaudRate(Value: TBaudRate);
begin
  FBaudRate := Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    FDCB.BaudRate := CBR[FBaudRate];
    SetCommState(FHandle, FDCB);
  end;
end;

procedure TCustomComm32.SetParity(Value: TParity);
begin
  FParity := Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    FDCB.Parity := PAR[FParity];
    SetCommState(FHandle, FDCB);
  end;
end;

procedure TCustomComm32.SetStopbits(Value: TStopbits);
begin
  FStopbits := Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    FDCB.Stopbits := STB[FStopbits];
    SetCommState(FHandle, FDCB);
  end;
end;

procedure TCustomComm32.SetDataBits(Value: TDatabits);
begin
  FDataBits:=Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    FDCB.Bytesize := DAB[FDatabits];
    SetCommState(FHandle, FDCB);
  end;
end;

procedure TCustomComm32.SetFlowControl(Value: TFlowControl);
begin
  FFlowControl := Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    EnableHandshaking(FDCB);
    SetCommState(FHandle, FDCB);
  end;
end;

procedure TCustomComm32.SetXonChar(Value: char);
begin
  FXonChar := Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    FDCB.XonChar := FXonChar;
    SetCommState(FHandle, FDCB);
  end;
end;

procedure TCustomComm32.SetXoffChar(Value: char);
begin
  FXoffChar := Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    FDCB.XoffChar := FXoffChar;
    SetCommState(FHandle, FDCB);
  end;
end;

procedure TCustomComm32.SetOptions(Value: TComm32Options);
var
  OptIndex: TComm32Option;
begin
  FOptions := Value;
  if Enabled then
  begin
    GetCommState(FHandle, FDCB);
    for OptIndex := osParityCheck to osNullStrip do
      if OptIndex in FOptions then
        FDCB.Flags := FDCB.Flags or OPT[OptIndex]
      else
        FDCB.Flags := FDCB.Flags and not OPT[OptIndex];
    SetCommState(FHandle, FDCB);
  end;
end;

function TCustomComm32.InQueCount: Integer;
var
  Errors: dword;
begin
  ClearCommError(FHandle, Errors, @FCT);
  Result := FCT.cbInQue;
end;

function TCustomComm32.OutQueCount: Integer;
var
  Errors: dword;
begin
  ClearCommError(FHandle, Errors, @FCT);
  Result := FCT.cbOutQue;
end;

procedure TCustomComm32.PurgeIn;
begin
  PurgeComm(FHandle, PURGE_RXABORT or PURGE_RXCLEAR);
end;

procedure TCustomComm32.PurgeOut;
begin
  PurgeComm(FHandle, PURGE_TXABORT or PURGE_TXCLEAR);
end;

function TCustomComm32.GetModemState(Index: Integer): boolean;
var
  Flag, State: dword;
begin
  case Index of
    1: State := MS_CTS_ON;
    2: State := MS_DSR_ON;
    3: State := MS_RING_ON;
    4: State := MS_RLSD_ON;
    else
      State := 0;
  end;
  Result := false;
  if Enabled then
    if GetCommModemStatus(FHandle, Flag) then
      Result := (Flag and State > 0);
end;

function TCustomComm32.DTR(State: boolean): boolean;
const
  DTR: array[boolean] of Integer = (CLRDTR, SETDTR);
begin
  Result := EscapeCommFunction(FHandle, DTR[State]);
end;

function TCustomComm32.RTS(State: boolean): boolean;
const
  RTS: array[boolean] of Integer = (CLRRTS, SETRTS);
begin
  Result := EscapeCommFunction(FHandle, RTS[State]);
end;

function TCustomComm32.BREAK(State: Boolean): boolean;
const
  BREAK: array[boolean] of Integer = (CLRBREAK, SETBREAK);
begin
  Result := EscapeCommFunction(FHandle, BREAK[State]);
  PurgeComm(FHandle, PURGE_RXABORT + PURGE_RXCLEAR +
   PURGE_TXABORT + PURGE_TXCLEAR);
end;

function TCustomComm32.XON(State: Boolean): boolean;
const
  XON: array[boolean] of Integer = (SETXOFF, SETXON);
begin
  Result := EscapeCommFunction(FHandle, XON[State]);
end;

procedure TCustomComm32.EnableHandshaking(var DCB: TDCB);
begin
  case FFlowControl of  // if hDefault, nothing happens
    fcNone:
      begin
        DCB.Flags := DCB.Flags and (not fOutxCtsFlow);
        DCB.Flags := DCB.Flags and (not fRtsControl) or (RTS_CONTROL_TOGGLE shl 12);
        DCB.Flags := DCB.Flags and (not fOutxDsrFlow);
        DCB.Flags := DCB.Flags and (not fDtrControl) or (DTR_CONTROL_ENABLE shl 4);
        DCB.Flags := DCB.Flags and (not fOutX) and (not fInX);
      end;
    fcCTS:
      begin
        DCB.Flags := DCB.Flags or fOutxCtsFlow;
        DCB.Flags := DCB.Flags and (not fRtsControl) or (RTS_CONTROL_HANDSHAKE shl 12);
        DCB.Flags := DCB.Flags and (not fOutxDsrFlow);
        DCB.Flags := DCB.Flags and (not fDtrControl) or (DTR_CONTROL_ENABLE shl 4);
        DCB.Flags := DCB.Flags and (not fOutX) and (not fInX);
      end;
    fcDTR:
      begin
        DCB.Flags := DCB.Flags and (not fOutxCtsFlow);
        DCB.Flags := DCB.Flags and (not fRtsControl) or (RTS_CONTROL_ENABLE shl 12);
        DCB.Flags := DCB.Flags or fOutxDsrFlow;
        DCB.Flags := DCB.Flags and (not fDtrControl) or (DTR_CONTROL_HANDSHAKE shl 4);
        DCB.Flags := DCB.Flags and (not fOutX) and (not fInX);
      end;
    fcSoftware:
      begin
        DCB.Flags := DCB.Flags and (not fOutxCtsFlow);
        DCB.Flags := DCB.Flags and (not fRtsControl) or (RTS_CONTROL_ENABLE shl 12);
        DCB.Flags := DCB.Flags and (not fOutxDsrFlow);
        DCB.Flags := DCB.Flags and (not fDtrControl) or (DTR_CONTROL_ENABLE shl 4);
        DCB.Flags := DCB.Flags or fOutX or fInX;
        DCB.XonChar := FXonChar;
        DCB.XoffChar := FXOffChar;
      end;
  end;
end;

procedure Register;
begin
  RegisterComponents('Varian FreeWare', [TComm32]);
end;

end.
