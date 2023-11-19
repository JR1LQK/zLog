{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Email:        francois.piette@ping.be  http://www.rtfm.be/fpiette
              2:293/2202@fidonet.org, BBS +32-4-3651395
Creation:     May 1996
Version:      2.10
Object:       TFtpClient is a FTP client (RFC 959 implementation)
Support:      Please ask your question in the following newsgroup:
              news://forums.borland.com/borland.public.delphi.vcl.components.using
Legal issues: Copyright (C) 1997 by François PIETTE <francois.piette@ping.be>

              This software is provided 'as-is', without any express or
  	      implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

Updates:
Nov 04, 1996  Better error handling
              Property for timeout, defualt to 15 sec
Dec 03, 1996  Adapted display functionnality for Delphi 2
Dec 27, 1996  Added transmit functions
              Changed all procedure to function returning boolean status
Aug 13, 1997  Added multiline response support
              Added support for strange Microsoft PWS FTP behaviour
Sep 10, 1997  Added support for Dir and Ls commands
              Corrected bugs to enable correct use of separate commands
Oct 16, 1997  V2.07 Adapted for changes in TWSocket object
              Added FtpCliVersion constant
Nov 25, 1997  V2.08 Accept 250 as well as 226 for succesfull file transfert
              Suggested by fdragon@world-net.net
Nov 26, 1997  V2.09 don't display error message in the receive event when
              the socket is no more connected.
Nov 29, 1997  V2.10 added Mkd and Mkdir functions to create a directory.
              As suggested by Christian Rösner <christian.roesner@usa.net>
Dec 04, 1997  V2.11 Added Ren, Dele, Rmd functions
              As suggested by Frank Riemann <riemann@student.uni-kl.de>
              Changed Mkd and Mkdir functions to take HostFileName to
              specify the directory name. This is more consistent with the
              rest of the component usage.


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit Ftpcli;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, WinSock, WSocket, Wait;

const
  FtpCliVersion = 210;

const
  BLOCK_SIZE = 1024;

type
  TFtpDisplay  = procedure(Sender: TObject; var Msg : String) of object;
  TFtpProgress = procedure(Sender: TObject;
                           Count : LongInt; var Abort : Boolean) of object;
  TFtpOp       = (FtpTransmit, FtpReceive);
  TFtpMethod   =  function : Boolean of object;

  TFtpClient = class(TWinControl)
  private
    ControlSocket    : TWSocket;
    AcceptSocket     : TWSocket;
    StartTime        : LongInt;
    StopTime         : LongInt;
    FMode            : TFtpOp;
    FFtpDisplay      : TFtpDisplay;
    FFtpProgress     : TFtpProgress;
    FHostName        : String;
    FUserName        : String;
    FPassWord        : String;
    FLocalFileName   : String;
    FHostFileName    : String;
    FHostDirName     : String;
    FDisplayFlag     : Boolean;
    FType            : Char;
    FFileHandle      : Integer;
    FWait            : TWait;
    FTimeout         : Integer;
    FLastResponse    : String;
    FErrorMessage    : String;
    FConnected       : Boolean;
    FSendBuffer      : array [0..BLOCK_SIZE - 1] of char;
    FSendCount       : LongInt;
    procedure   ClearErrorMessage;
    procedure   SetErrorMessage;
    procedure   FtpGetDataAvailable(Sender: TObject; Error : word);
    procedure   FtpGetSessionAvailable(Sender: TObject; Error : word);
    procedure   FtpPutSessionAvailable(Sender: TObject; Error : word);
    procedure   FtpSessionClosed(Sender: TObject; Error : word);
    procedure   FtpDataSent(Sender: TObject; Error : word);
    function    FtpGetFile(Cmd, HostFileName : String) : Boolean;
    procedure   SendCommand(Cmd : String);
    procedure   SendNextData;
    function    SendPort(Port : Integer) : Integer;
    function    FtpQuit : Boolean;
    function    GetResponse : Integer;
    procedure   Display(Msg : String);
    procedure   TWMPaint(var msg:TWMPaint); message WM_PAINT;
    procedure   Notification(AComponent: TComponent; Operation: TOperation); override;
    function    Progress : Boolean;
    function    FtpHighLevel(Method : TFtpMethod) : Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function    Connect : Boolean;
    function    Cwd : Boolean;
    function    TypeSet : Boolean;
    function    Get : Boolean;
    function    Put : Boolean;
    function    Quit : Boolean;
    function    Receive : Boolean;
    function    Transmit : Boolean;
    function    Dir : Boolean;
    function    Directory : Boolean;
    function    Ls : Boolean;
    function    List : Boolean;
    function    Mkd : Boolean;
    function    Mkdir : Boolean;
    function    Ren : Boolean;
    function    Rename : Boolean;
    function    Dele : Boolean;
    function    Delete : Boolean;
    function    Rmd : Boolean;
    function    Rmdir : Boolean;
    procedure   SetBinary(Value : Boolean);
    function    GetBinary : Boolean;
    procedure   SetWait(Value : TWait);
    procedure   Abort;
    function    IsConnected : Boolean;
  published
    property OnDisplay : TFtpDisplay   read FFtpDisplay    write FFtpDisplay;
    property OnProgress : TFtpProgress read FFtpProgress   write FFtpProgress;
    property HostName : String         read FHostName      write FHostName;
    property UserName : String         read FUserName      write FUserName;
    property PassWord : String         read FPassWord      write FPassWord;
    property HostDirName : String      read FHostDirName   write FHostDirName;
    property HostFileName : String     read FHostFileName  write FHostFileName;
    property LocalFileName : String    read FLocalFileName write FLocalFileName;
    property DisplayFlag : Boolean     read FDisplayFlag   write FDisplayFlag;
    property Binary : Boolean          read GetBinary      write SetBinary;
    property Wait : TWait              read FWait          write SetWait;
    property TimeOut : Integer         read FTimeout       write FTimeout;
    property ErrorMessage : String     read FErrorMessage;
  end;

procedure Register;

implementation

{$IFNDEF WIN32}
const
    HFILE_ERROR = $FFFF;
{$ENDIF}

{$B-}  { Do not evaluate boolean expressions more than necessary }


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Register;
begin
    RegisterComponents('FPiette', [TFtpClient]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function atoi(value : string) : Integer;
var
    i : Integer;
begin
    Result := 0;
    i := 1;
    while (i <= Length(Value)) and (Value[i] = ' ') do
        i := i + 1;
    while (i <= Length(Value)) and (Value[i] >= '0') and (Value[i] <= '9')do begin
        Result := Result * 10 + ord(Value[i]) - ord('0');
        i := i + 1;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TFtpClient.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);

    FTimeout      := 15;
    FFtpDisplay   := nil;
    FFileHandle   := -1;
    FType         := 'I';
    Width         := 32;
    Height        := 32;
    ControlSocket := TWSocket.Create(Self);
    AcceptSocket  := TWSocket.Create(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TFtpClient.Destroy;
begin
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if Operation = opRemove then begin
        if AComponent = FWait then
            FWait := nil
        else if AComponent = ControlSocket then
            ControlSocket := nil
        else if AComponent = AcceptSocket then
            AcceptSocket := nil;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.SetWait(Value : TWait);
begin
    FWait                  := Value;
    ControlSocket.WaitCtrl := Value;
    AcceptSocket.WaitCtrl  := Value;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.TWMPaint(var msg: TWMPaint);
var
    icon : HIcon;
    dc   : HDC;
begin
    if csDesigning in ComponentState then begin
        icon   := LoadIcon(HInstance, MAKEINTRESOURCE('TFTPCLIENT'));
        dc     := GetDC(Handle);
        Width  := 32;
        Height := 32;
        DrawIcon(dc, 0, 0, icon);
        ReleaseDC(Handle, dc);
        FreeResource(icon);
    end;
    ValidateRect(Handle, nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.ClearErrorMessage;
begin
    FErrorMessage := '';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.SetErrorMessage;
begin
    if FErrorMessage = '' then
        FErrorMessage := FLastResponse;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.Display(Msg : String);
begin
    if Assigned(FFtpDisplay) then
        FFtpDisplay(Self, Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.GetBinary : Boolean;
begin
     Result := (FType = 'I');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.SetBinary(Value : Boolean);
begin
     if Value then
         FType := 'I'
     else
         FType := 'A';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.FtpGetSessionAvailable(Sender: TObject; Error : word);
var
    NewHSocket : TSocket;
begin
    NewHSocket := AcceptSocket.Accept;
    StartTime := GetTickCount;
    Display('Data: session opened');
    AcceptSocket.Dup(NewHSocket);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.FtpPutSessionAvailable(Sender: TObject; Error : word);
var
    NewHSocket : TSocket;
begin
    NewHSocket := AcceptSocket.Accept;
    StartTime := GetTickCount;
    Display('Data: session opened');
    AcceptSocket.Dup(NewHSocket);
    FtpDataSent(AcceptSocket, 0);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFNDEF WIN32}
procedure SetLength(var Str : String; Len : Integer);
begin
    Str[0] := chr(Len);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Progress : Boolean;
var
    Abort : Boolean;
begin
    Abort := FALSE;
    if Assigned(FFtpProgress) then begin
        if FMode = FtpReceive then
            FFtpProgress(Self, AcceptSocket.ReadCount, Abort)
        else
            FFtpProgress(Self, FSendCount, Abort);
    end;

    if Abort then begin
        Display('Abort requested');
        AcceptSocket.Close;
    end;

    Result := not Abort;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.FtpGetDataAvailable(Sender: TObject; Error : word);
var
    Len    : Integer;
    Buffer : array [1..2048] of Char;
    Line   : String;
    i, j   : Integer;
begin
    if FMode <> FtpReceive then
        Exit;

    if not Progress then
        Exit;

    Len := AcceptSocket.Receive(@Buffer[1], High(Buffer));
    if Len = 0 then
        { Remote has closed, ignore }
    else if Len < 0 then begin
        { An error has occured }
        if (AcceptSocket.State = wsConnected) and
           (AcceptSocket.LastError <> WSAEWOULDBLOCK) then
            Display('Data: Receive error ' + IntToStr(AcceptSocket.LastError));
    end
    else begin
        if _lwrite(FFileHandle, @Buffer[1], Len) = -1 then begin
{$IFDEF WIN32}
            Display('Error ' + IntToStr(GetLastError) + ' writing local file');
{$ELSE}
            Display('Error writing local file');
{$ENDIF}
            AcceptSocket.Shutdown(2);
            exit;
        end;

        if FDisplayFlag then begin
            if (Len > 0) then begin
                i := 1;
                while (i < Len) do begin
                    j := 1;
                    while (i < Len) and (Buffer[i] <> #10) and (Buffer[i] <> #13) do begin
                        i := i + 1;
                        j := j + 1;
                    end;
                    SetLength(Line, j - 1);
                    Move(Buffer[i - j + 1], Line[1], j - 1);
                    Display('Data: ' + Line);
                    while (i < Len) and ((Buffer[i] = #10) or (Buffer[i] = #13)) do
                        i := i + 1;
                end;
            end;
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.FtpSessionClosed(Sender: TObject; Error : word);
var
    Buffer : String;
    Count  : LongInt;
    KBSec  : LongInt;
begin
    StopTime := GetTickCount;
    if FMode = FtpReceive then
        Count := AcceptSocket.ReadCount
    else
        Count := FSendCount;

    Progress;

    Buffer := 'Data: session closed, ' +
              IntToSTr(Count) + ' bytes transfered, ' +
              IntToStr((StopTime - StartTime) div 1000) + ' Seconds elapsed';
    if StopTime <> StartTime then begin
        if Count > 32767 then
            KBSec := 1000 * (Count div (StopTime - StartTime))
        else
            KBSec := (1000 * Count) div (StopTime - StartTime);
        Buffer := Buffer + ', ' + IntToStr(KBSec) + ' Bytes/Sec';
    end;
    Display(Buffer);
    AcceptSocket.Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.SendCommand(Cmd : String);
var
    Buffer : String;
begin
    Buffer := '> ' + Cmd;
    SetLength(Buffer, Length(Buffer) - 2);
    Display(Buffer);
    Application.ProcessMessages;
    ControlSocket.Send(@Cmd[1], Length(Cmd));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.GetResponse : Integer;
begin
    repeat
        ControlSocket.ReadLine(FTimeout, FLastResponse);
        Display('< ' + FLastResponse);
    until (Length(FLastResponse) < 4) or (FLastResponse[4] <> '-');
    Result := atoi(FLastResponse);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{* Send QUIT message to logoff from FTP server *}
function TFtpClient.FtpQuit : Boolean;
begin
    FConnected := FALSE;
    Result     := TRUE;
    if ControlSocket.State = wsClosed then
        Display('Can''t QUIT: connection closed')
    else begin
        SendCommand('QUIT' + #13 + #10);
        if GetResponse <> 221 then
            Result := FALSE;
        ControlSocket.Close;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.Abort;
begin
    if ControlSocket.State <> wsClosed then
        ControlSocket.Close;
    if AcceptSocket.State <> wsClosed then
        AcceptSocket.Close;
    FConnected := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.IsConnected : Boolean;
begin
    Result := ControlSocket.State <> wsClosed;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Connect : Boolean;
var
    Response   : Integer;
begin
    if FConnected then begin
        Result := TRUE;
        Exit;
    end;

    Result := FALSE;
    ClearErrorMessage;

    if FWait = nil then begin
        FErrorMessage := 'No wait object';
        Display(FErrorMessage);
        Exit;
    end;

    try
        ControlSocket.Proto           := 'tcp';
        ControlSocket.Port            := 'ftp';
        ControlSocket.Addr            := FHostName;
        ControlSocket.OnDataAvailable := nil;

        ControlSocket.Connect;
    except
        on E:ESocketException do begin
            FErrorMessage := E.Message;
            Exit;
        end;
    end;

    if not ControlSocket.Wait(FTimeout, wsConnected) then begin
        FErrorMessage := 'Can''t connect to host ''' + FHostName + '''';
        Display(FErrorMessage);
        ControlSocket.Close;
        Exit;
    end;
    Display('Connected for FTP');

    {* Wait for FTP server banner *}
    Response := GetResponse;

    if Response <> 220 then begin
        SetErrorMessage;
        ControlSocket.Close;
        Exit;
    end;

    SendCommand('USER ' + FUserName + #13 + #10);
    Response := GetResponse;

    if Response = 331 then begin
        SendCommand('PASS ' + FPassWord + #13 + #10);
        Response := GetResponse;
    end;

    if Response <> 230 then begin
        SetErrorMessage;
        FtpQuit;
        Exit;
    end;

    FConnected := TRUE;
    Result     := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Cwd : Boolean;
var
    Response   : Integer;
begin
    if Length(FHostDirName) > 0 then begin
        SendCommand('CWD '+ FHostDirName + #13 + #10);
        Response := GetResponse;

        if (Response <> 250) and (response <> 257) then begin
            SetErrorMessage;
            Result := FALSE;
            Exit;
        end;
    end;
    Result := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Mkd : Boolean;
var
    Response   : Integer;
begin
    Result := FALSE;
    if Length(FHostFileName) > 0 then begin
        SendCommand('MKD '+ FHostFileName + #13 + #10);
        Response := GetResponse;

        if (response <> 257) then begin
            SetErrorMessage;
            Exit;
        end;
    end;
    Result := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Dele : Boolean;
var
    Response: Integer;
begin
    if Length(FHostFileName) > 0 then begin
        SendCommand('DELE '+ FHostFileName + #13 + #10);
        Response := GetResponse;
        if (Response <> 250) and (response <> 257) then begin
             SetErrorMessage;
             Result := FALSE;
             Exit;
        end;
    end;
    Result := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Rmd : Boolean;
var
    Response: Integer;
begin
    if Length(FHostFileName) > 0 then begin
        SendCommand('RMD '+ FHostFileName + #13 + #10);
        Response := GetResponse;
        if (Response <> 250) and (Response <> 257) then begin
            SetErrorMessage;
            Result := FALSE;
            Exit;
        end;
    end;
    Result := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Ren : Boolean;
var
    Response: Integer;
begin
    if Length(FHostFileName) > 0 then begin
        SendCommand('RNFR '+ FHostFileName + #13 + #10);
        Response := GetResponse;

        if (Response <> 350) then begin
            SetErrorMessage;
            Result := FALSE;
            Exit;
        end;

        SendCommand('RNTO '+ FLocalFileName + #13 + #10);
        Response := GetResponse;

        if (Response <> 250) and (response <> 257) then begin
            SetErrorMessage;
            Result := FALSE;
            Exit;
        end;
    end;
    Result := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.TypeSet : Boolean;
var
    Response   : Integer;
begin
    SendCommand('TYPE '+ FType + #13 + #10);
    Response := GetResponse;

    if Response = 200 then
        Result := TRUE
    else begin
        SetErrorMessage;
        Result := FALSE;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.SendPort(Port : Integer) : Integer;
var
    Msg      : String;
    saddr    : TSockAddrIn;
    saddrlen : Integer;
    InAddr   : TInAddr;
begin
    saddrlen := SizeOf(saddr);
    ControlSocket.GetSockName(saddr, saddrlen);
    InAddr := saddr.sin_addr;

    { Strange behaviour of PWS (FrontPage 97 Web Server for W95) }
    { which do not like effective address when localhost is used }
    if ControlSocket.sin.sin_addr.s_addr = htonl($7F000001) then
        Msg := Format('PORT 127,0,0,1,%d,%d',
                      [HiByte(port),
                       LoByte(port)]) + #13 + #10
    else
        Msg := Format('PORT %d,%d,%d,%d,%d,%d',
                      [ord(InAddr.S_un_b.s_b1),
                       ord(InAddr.S_un_b.s_b2),
                       ord(InAddr.S_un_b.s_b3),
                       ord(InAddr.S_un_b.s_b4),
                       HiByte(port),
                       LoByte(port)]) + #13 + #10;

    SendCommand(Msg);
    Result := GetResponse;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Get : Boolean;
begin
    Result := FtpGetFile('RETR', FHostFileName);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.FtpGetFile(Cmd, HostFileName : String) : Boolean;
var
    Response   : Integer;
    Port       : Integer;
    saddr      : TSockAddrIn;
    saddrlen   : Integer;
begin
    FMode  := FtpReceive;
    Result := FALSE;

    AcceptSocket.Proto  := 'tcp';
    AcceptSocket.Addr   := '0.0.0.0';               { INADDR_ANY }
    AcceptSocket.Port   := '0';                     { IPPORT_ANY }
    AcceptSocket.OnSessionAvailable := nil;
    AcceptSocket.OnDataAvailable    := nil;
    AcceptSocket.OnSessionClosed    := nil;

    AcceptSocket.Listen;

    AcceptSocket.OnSessionAvailable := FtpGetSessionAvailable;
    AcceptSocket.OnDataAvailable    := FtpGetDataAvailable;
    AcceptSocket.OnSessionClosed    := FtpSessionClosed;

    { nul terminate the local file name }
    FLocalFileName[Length(FLocalFileName) + 1] := chr(0);

    { open the destination file }
    FFileHandle := _lcreat(@FLocalFileName[1], 0);
    if FFileHandle = -1 then begin
        FErrorMessage := 'Unable to open local file';
{$IFDEF WIN32}
        FErrorMessage := FErrorMessage + ', error ' +
                         IntToStr(GetLastError);
{$ENDIF}
        Display(FErrorMessage);
        AcceptSocket.Close;
        exit;
    end;

    saddrLen := SizeOf(saddr);
    AcceptSocket.GetSockName(saddr, saddrLen);

    Port := ntohs(saddr.sin_port);
    Response := SendPort(Port);

    if Response <> 200 then begin
        SetErrorMessage;
        AcceptSocket.Close;
        exit;
    end;

    if Length(HostFileName) > 0 then
        SendCommand(Cmd + ' ' + HostFileName + #13 + #10)
    else
        SendCommand(Cmd + #13 + #10);

    Response := GetResponse;
    ControlSocket.Pause;

    if Response <> 150 then begin
        SetErrorMessage;
        ControlSocket.Resume;
        AcceptSocket.Close;
    end
    else begin
        Display('Receiving data into file ' + FLocalFileName);
        while AcceptSocket.State <> wsClosed do
            Application.ProcessMessages;
        Display('Data received');

        {* Waiting '226 File sent OK' or '550 Can't read file' *}
        ControlSocket.Resume;
        Response := GetResponse;

        if ((Response <> 226) and (Response <> 250)) then begin
            SetErrorMessage;
            _lclose(FFileHandle);
            FFileHandle := -1;
            ControlSocket.Close;
            AcceptSocket.Close;
            Display('Failed');
            Exit;
        end;
        Result := TRUE;
    end;

    { close the local file }
    _lclose(FFileHandle);
    FFileHandle := -1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Put : Boolean;
var
    Response   : Integer;
    Port       : Integer;
    saddr      : TSockAddrIn;
    saddrlen   : Integer;
begin
    FMode      := FtpTransmit;
    Result     := FALSE;
    FSendCount := 0;

    AcceptSocket.Proto  := 'tcp';
    AcceptSocket.Addr   := '0.0.0.0';               { INADDR_ANY }
    AcceptSocket.Port   := '0';                     { IPPORT_ANY }
    AcceptSocket.OnSessionAvailable := nil;
    AcceptSocket.OnDataAvailable    := nil;
    AcceptSocket.OnSessionClosed    := nil;

    AcceptSocket.Listen;

    AcceptSocket.OnSessionAvailable := FtpPutSessionAvailable;
    AcceptSocket.OnSessionClosed    := FtpSessionClosed;
    AcceptSocket.OnDataSent         := FtpDataSent;

    { nul terminate the local file name }
    FLocalFileName[Length(FLocalFileName) + 1] := chr(0);

    { open the local source file }
    FFileHandle := _lopen(@FLocalFileName[1], OF_READ);
    if FFileHandle = -1 then begin
        FErrorMessage := 'Unable to open local file';
{$IFDEF WIN32}
        FErrorMessage := FErrorMessage + ', error ' +
                         IntToStr(GetLastError);
{$ENDIF}
        Display(FErrorMessage);
        AcceptSocket.Close;
        Exit;
    end;

    saddrLen := SizeOf(saddr);
    AcceptSocket.GetSockName(saddr, saddrLen);
    Port     := ntohs(saddr.sin_port);
    Response := SendPort(Port);

    if Response <> 200 then begin
        SetErrorMessage;
        AcceptSocket.Close;
        Exit;
    end;

    SendCommand('STOR ' + FHostFileName + #13 + #10);
    Response := GetResponse;
    ControlSocket.Pause;

    if Response <> 150 then begin
        SetErrorMessage;
        ControlSocket.Resume;
        AcceptSocket.Close;
    end
    else begin
        Display('Sending data into file ' + FLocalFileName);
        while AcceptSocket.State <> wsClosed do
            Application.ProcessMessages;
        Display('Data Sent');

        { Waiting '226 File received OK' }
        ControlSocket.Resume;
        Response := GetResponse;

        if Response <> 226 then begin
            SetErrorMessage;
            ControlSocket.Close;
            AcceptSocket.Close;
            _lclose(FFileHandle);
            FFileHandle := -1;
            Display('Failed');
            Exit;
        end;
        Result := TRUE;
    end;

    { close the local file }
    _lclose(FFileHandle);
    FFileHandle := -1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.SendNextData;
var
    Count      : Integer;
begin
    if FMode <> FtpTransmit then
        Exit;
        
    if not Progress then
        Exit;

    Count := _lread(FFileHandle, @FSendBuffer, BLOCK_SIZE);
    if Count > 0 then begin
        FSendCount := FSendCount + Count;
        AcceptSocket.Send(@FSendBuffer, Count);
    end
    else begin
        if Count = HFILE_ERROR then
            Display('Error reading file');
        AcceptSocket.Close;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpClient.FtpDataSent(Sender: TObject; Error : word);
begin
    SendNextData;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Quit : Boolean;
begin
    {* Send QUIT message to break the FTP session *}
    Result := FtpQuit;
    if AcceptSocket.State <> wsClosed then
        AcceptSocket.Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Dir : Boolean;
begin
    Result := FtpGetFile('LIST', FHostFileName);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Ls : Boolean;
begin
    Result := FtpGetFile('NLST', FHostFileName);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.FtpHighLevel(Method : TFtpMethod) : Boolean;
const
    ResultMsg : array [Boolean] of string = ('Failed', 'Done');
begin
    Result := Connect and Cwd and TypeSet and Method;
    Quit;
    Display(ResultMsg[Result]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Mkdir : Boolean;
begin
    Result := FtpHighLevel(Mkd);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Directory : Boolean;
begin
    Result := FtpHighLevel(Dir);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.List : Boolean;
begin
    Result := FtpHighLevel(Ls);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Receive : Boolean;
begin
    Result := FtpHighLevel(Get);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Transmit : Boolean;
begin
    Result := FtpHighLevel(Put);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Delete : Boolean;
begin
    Result := FtpHighLevel(Dele);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Rmdir : Boolean;
begin
    Result := FtpHighLevel(Rmd);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TFtpClient.Rename : Boolean;
begin
    Result := FtpHighLevel(Ren);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

