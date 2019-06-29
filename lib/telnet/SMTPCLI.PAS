{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


Author:       François PIETTE
Object:       TSMTPClient class implements the SMTP protocol (RFC-821)
EMail:        francois.piette@ping.be
              francois.piette@f2202.n293.z2.fidonet.org
              2:293/2202@fidonet.org, BBS +32-4-3651395
WebSite:      http://www.rtfm.be/fpiette
Creation:     09 october 1997
Version:      1.00
Support:      Use twsocket@rtfm.be mailing list. See website for details.
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
Oct 25, 1997  Added the OnHeaderLine event to allow modification/deletion of
              header lines.
Oct 26, 1997  V1.00 Released
              Changed the OnGetData event arguments to have code compatible
              between 16 and 32 bit versions (replaced string with PChar).


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit smtpcli;

interface

{$B-}

uses
    WinTypes,
    WinProcs,
    SysUtils,
    Messages,
    Classes,
    Graphics,
    Controls,
    Forms,
    Dialogs,
    Menus,
    WSocket,
    Wait;

const
  SmtpCliVersion = 100;

type
    TSmtpDisplay = procedure(Sender: TObject; Msg : String) of object;
    TSmtpHeaderLineEvent = procedure(Sender: TObject; Msg : PChar; Size : Integer) of object;
    TSmtpGetDataEvent = procedure(Sender: TObject;
                                  LineNum: Integer; 
                                  MsgLine: PChar;
                                  MaxLen: Integer;
                                  var More: Boolean) of object;
    TSmtpState    = (smtpDisconnected, smtpConnecting, smtpConnected);
    TSmtpClient = class(TComponent)
    private
        FWSocket        : TWSocket;
        FHost           : String;
        FSignOn         : String;
        FFromName       : String;
        FRcptName       : TStrings;
        FHdrFrom        : String;
        FHdrTo          : String;
        FHdrSubject     : String;
        FState          : TSmtpState;
        FLastResponse   : String;
        FErrorMessage   : String;
        FWait           : TWait;
        FTimeout        : Integer;
        FTimeOutFlag    : Boolean;
        FTag            : LongInt;

        FOnDisplay      : TSmtpDisplay;
        FOnGetData      : TSmtpGetDataEvent;
        FOnHeaderLine   : TSmtpHeaderLineEvent;
    protected
        procedure   Notification(AComponent: TComponent; Operation: TOperation); override;
        procedure   ClearErrorMessage;
        procedure   SetErrorMessage;
        procedure   Display(Msg : String);
        procedure   SetWait(Value : TWait);
        function    GetResponse : Integer;
        function    WaitResponse(ValidResponse : integer; CloseOnError : Boolean) : Boolean;
        function    WaitResponse2(ValidResponse1 : Integer;
                                  ValidResponse2 : Integer;
                                  CloseOnError : Boolean) : Boolean;
        procedure   SendCommand(Cmd : String);
        procedure   WaitTimeOut(Sender : TObject);
        procedure   SessionClosed(Sender : TObject; Error : WORD);
        procedure   SendHeaderLine(Line : PChar; Size : Integer);
    public
        constructor Create(AOwner : TComponent); override;
        destructor  Destroy; override;
        function    Connect : Boolean;
        function    Mail : Boolean;
        function    Quit : Boolean;
    published
        property Host : String                       read  FHost
                                                     write FHost;
        property SignOn : String                     read  FSignOn
                                                     write FSignOn;
        property FromName : String                   read  FFromName
                                                     write FFromName;
        property RcptName : TStrings                 read  FRcptName
                                                     write FRcptName;
        property HdrFrom : String                    read  FHdrFrom
                                                     write FHdrFrom;
        property HdrTo : String                      read  FHdrTo
                                                     write FHdrTo;
        property HdrSubject : String                 read  FHdrSubject
                                                     write FHdrSubject;
        property Wait : TWait                        read  FWait
                                                     write SetWait;
        property TimeOut : Integer                   read  FTimeout
                                                     write FTimeout;
        property ErrorMessage : String               read  FErrorMessage;
        property LastResponse : String               read  FLastResponse;
        property Tag : LongInt                       read  FTag
                                                     write FTag;

        property OnDisplay : TSmtpDisplay            read  FOnDisplay
                                                     write FOnDisplay;
        property OnGetData : TSmtpGetDataEvent       read  FOnGetData
                                                     write FOnGetData;
        property OnHeaderLine : TSmtpHeaderLineEvent read  FOnHeaderLine
                                                     write FOnHeaderLine;
    end;

procedure Register;

implementation


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF VER80}
procedure SetLength(var S: string; NewLength: Integer);
begin
    S[0] := chr(NewLength);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function RTrim(Str : String) : String;
var
    i : Integer;
begin
    i := Length(Str);
    while (i > 0) and (Str[i] = ' ') do
        i := i - 1;
    Result := Copy(Str, 1, i);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function LTrim(Str : String) : String;
var
    i : Integer;
begin
    if Str[1] <> ' ' then             { Petite optimisation: pas d'espace   }
        Result := Str
    else begin
        i := 1;
        while (i <= Length(Str)) and (Str[i] = ' ') do
            i := i + 1;
        Result := Copy(Str, i, Length(Str) - i + 1);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function Trim(Str : String) : String;
begin
    Result := LTrim(Rtrim(Str));
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function stpblk(PValue : PChar) : PChar;
begin
    Result := PValue;
    while Result^ in [' ', #9, #10, #13] do
        Inc(Result);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function atoi(PValue : PChar) : Integer;
begin
    Result := 0;
    PValue := stpblk(PValue);
    while PValue^ in ['0'..'9'] do begin
        Result := Result * 10 + ord(PValue^) - ord('0');
        Inc(PValue);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TSmtpClient.Create(AOwner : TComponent);
begin
    inherited Create(AOwner);
    FWSocket                 := TWSocket.Create(nil);
    FWSocket.OnSessionClosed := SessionClosed;
    FTimeout                 := 15;
    FState                   := smtpDisconnected;
    FRcptName                := TStringList.Create;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor TSmtpClient.Destroy;
begin
    if Assigned(FWSocket) then begin
        FWSocket.Destroy;
        FWSocket := nil;
    end;
    FRcptName.Destroy;
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TSmtpClient.Connect : Boolean;
begin
    Result := FALSE;
    if FWait = nil then begin
        FErrorMessage := 'No wait object';
        Display(FErrorMessage);
        Exit;
    end;

    FWait.OnTimeout := WaitTimeout;
    FTimeOutFlag    := FALSE;

    if FState > smtpDisconnected then begin
        { Already connected, it's ok }
        Result := TRUE;
        Exit;
    end;

    ClearErrorMessage;

    if Length(FHost) = 0 then begin
        FErrorMessage := 'No host specified';
        Display(FErrorMessage);
        Exit;
    end;

    try
        FWSocket.Proto           := 'tcp';
        FWSocket.Port            := 'smtp';
        FWSocket.Addr            := FHost;
        FWSocket.OnDataAvailable := nil;

        FWSocket.Connect;
    except
        on E:ESocketException do begin
            FErrorMessage := E.Message;
            Exit;
        end;
    end;

    if not FWSocket.Wait(FTimeout, wsConnected) then begin
        FErrorMessage := 'Can''t connect to host ''' + FHost + '''';
        Display(FErrorMessage);
        FWSocket.Close;
        Exit;
    end;
    Display('Connected with SMTP server');

    FState := smtpConnecting;
    if WaitResponse(220, TRUE) then
        Exit;

    if FSignOn = '' then
        SendCommand('HELO ' + LocalHostName)
    else
        SendCommand('HELO ' + FSignOn);

    if WaitResponse(250, TRUE) then
        Exit;

    FState := smtpConnected;
    Result := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpClient.SendHeaderLine(Line : PChar; Size : Integer);
begin
    if Assigned(FOnHeaderLine) then
        FOnHeaderLine(Self, Line, Size);
    if Line[0] <> #0 then
        SendCommand(StrPas(Line));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TSmtpClient.Mail : Boolean;
var
    I       : Integer;
    LineNum : Integer;
    More    : Boolean;
    MsgLine : array [0..1023] of char;
begin
    Result := FALSE;
    if (FState = smtpDisconnected) and (not Connect) then
        Exit;

    SendCommand('MAIL FROM:<' + Trim(FFromName) + '>');
    if WaitResponse(250, FALSE) then
        Exit;

    for I := 0 to FRcptName.Count - 1 do begin
        SendCommand('RCPT TO:<' + Trim(FRcptName.Strings[I]) + '>');
        if WaitResponse2(250, 251, FALSE) then
            Exit;
    end;

    SendCommand('DATA');
    if WaitResponse(354, FALSE) then
        Exit;

    StrPCopy(MsgLine, 'From: ' + FHdrFrom);
    SendHeaderLine(@MsgLine, SizeOf(MsgLine));
    StrPCopy(MsgLine, 'To: '   + FHdrTo);
    SendHeaderLine(@MsgLine, SizeOf(MsgLine));
    StrPCopy(MsgLine, 'Subject: ' + FHdrSubject);
    SendHeaderLine(@MsgLine, SizeOf(MsgLine));
    StrPCopy(MsgLine, 'Mime-Version: 1.0');
    SendHeaderLine(@MsgLine, SizeOf(MsgLine));
    StrPCopy(MsgLine, 'Content-Type: text/plain; charset="iso-8859-1"');
    SendHeaderLine(@MsgLine, SizeOf(MsgLine));
    SendCommand('');

    More    := TRUE;
    LineNum := 1;
    while More and (FState = smtpConnected) do begin
        if not Assigned(FOnGetData) then
            break;
        try
            FOnGetData(Self, LineNum, @MsgLine, High(MsgLine), More);
        except
            More := FALSE;
        end;
        if not More then
            break;
        if StrComp(MsgLine, '.') = 0 then
            StrCopy(MsgLine, '..');
        SendCommand(StrPas(MsgLine));
        Inc(LineNum);
        Application.ProcessMessages;
    end;
    SendCommand('.');
    if WaitResponse(250, FALSE) then
        Exit;

    Result := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TSmtpClient.Quit : Boolean;
begin
    if FState = smtpDisconnected then begin
        { Not connected, it's ok }
        Result := TRUE;
        Exit;
    end;

    try
        SendCommand('QUIT');
        Result := (GetResponse <> 221);
    except
        Result := FALSE;
    end;

    FState := smtpDisconnected;
    FWSocket.Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpClient.WaitTimeOut(Sender : TObject);
begin
    FTimeOutFlag := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpClient.SessionClosed(Sender : TObject; Error : WORD);
begin
    if Assigned(FWait) then
        FWait.Stop;
    FState := smtpDisconnected;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpClient.SendCommand(Cmd : String);
begin
    if FState = smtpDisconnected then
        Exit;

    Display('> ' + Cmd);
    Application.ProcessMessages;
    FWSocket.SendStr(Cmd + #13 + #10);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TSmtpClient.GetResponse : integer;
begin
    if FState = smtpDisconnected then begin
        FLastResponse := '554 not connected';
        Display('< ' + FLastResponse);
    end
    else begin
        repeat
            FWSocket.ReadLine(FTimeout, FLastResponse);
            if FTimeOutFlag then
                FLastResponse := '554 receive timeout';
            Display('< ' + FLastResponse);
        until (FTimeOutFlag) or
              (Length(FLastResponse) < 4) or
              (FLastResponse[4] <> '-');
    end;

    Result := atoi(@FLastResponse[1]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Wait for a response and check for validity. If response is not valid,     }
{ return TRUE and optionnaly close the socket.                              }
function TSmtpClient.WaitResponse2(
    ValidResponse1 : integer;
    ValidResponse2 : integer;
    CloseOnError   : Boolean) : Boolean;
var
    Response : Integer;
begin
    Response := GetResponse;
    Result := ((Response <> ValidResponse1) and
               (Response <> ValidResponse2));
    if Result then begin
        SetErrorMessage;
        if CloseOnError then
            FWSocket.Close;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Wait for a response and check for validity. If response is not valid,     }
{ return TRUE and optionnaly close the socket.                              }
function TSmtpClient.WaitResponse(
    ValidResponse : integer;
    CloseOnError  : Boolean) : Boolean;
begin
    Result := (GetResponse <> ValidResponse);
    if Result then begin
        SetErrorMessage;
        if CloseOnError then
            FWSocket.Close;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpClient.SetWait(Value : TWait);
begin
    FWait             := Value;
    FWSocket.WaitCtrl := Value;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpClient.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if Operation = opRemove then begin
        if AComponent = FWait then
            FWait := nil
        else if AComponent = FWSocket then
            FWSocket := nil;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpClient.Display(Msg : String);
begin
    if Assigned(FOnDisplay) then
        FOnDisplay(Self, Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpClient.ClearErrorMessage;
begin
    FErrorMessage := '';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpClient.SetErrorMessage;
begin
    if FErrorMessage = '' then
        FErrorMessage := FLastResponse;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Register;
begin
    RegisterComponents('FPiette', [TSmtpClient]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

