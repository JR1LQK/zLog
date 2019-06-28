{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

   BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA
   BETA                                                             BETA
   BETA              THIS IS BETA CODE. USE ONLY FOR TESTING        BETA
   BETA           EVERYTHING CAN CHANGE IN THE REALEASE VERSION     BETA
   BETA                                                             BETA
   BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA

Author:       François PIETTE
Email:        francois.piette@ping.be  http://www.rtfm.be/fpiette
              francois.piette@rtfm.be
Creation:     November 23, 1997
Version:      0.95 BETA
Description:  THttpCli is an implementation for the HTTP protocol
              RFC 1945 (V1.0), RFC 2068 (V1.1)
Support:      There is a mailing list for support. See web site for
              subscription http://www.rtfm.be/fpiette/supportuk.htm
Credit:       This component is based on a freeware from by Andreas Hoerstemeier
              and used with his permission.
              andy@hoerstemeier.de http://www.westend.de/~hoerstemeier
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
11/29/97 RcvdStream and SendStream properties moved to public section
11/30/97 Document name bug corrected
12/02/97 Removed bug occuring with terminating slash in docname
12/03/97 Added properties RcvdCount and SentCount to easily add a progress
         bar feature (On receive, the ContentLength is initialized with the
         value from the header. Update the progress bar in the OnDocData event,
         or the OnSendData event).
         Added the OnSendBegin, OnSendData and OnSendEnd events.
12/07/97 Corrected Head function to work as expected. Thanks to
         R. Barry Jones <rbjones@therightside.demon.co.uk

  BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA
  BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit HttpProt;

interface

uses
    WinProcs, WinTypes, SysUtils, Classes, Forms, WSocket, Wait;

const
    HttpCliVersion   = 094;
    DefaultProxyPort = '80';

type
    EHttpException = class(Exception)
        ErrorCode : Word;
        constructor Create(const Msg : String; ErrCode : Word);
    end;

    TOnCommand    = procedure (Sender : TObject; const s:String) of object;
    TDocDataEvent = procedure (Sender : TObject;
                               Buffer : Pointer;
                               Len    : Integer) of object;
    THttpEncoding = (encUUEncode, encBase64, encMime);
    THttpRequest  = (httpGET, httpPOST, httpHEAD);

    THttpCli = class(TComponent)
    protected
        FWSocket       : TWSocket;
        FWait          : TWait;
        FTimeout       : LongInt;
        FHostName      : String;
        FTargetHost    : String;
        FPort          : String;
        FProxy         : String;
        FProxyPort     : String;
        FUsername      : String;
        FPassword      : String;
        FConnected     : Boolean;
        FBuffer        : array [0..1023] of char;
        FURL           : String;
        FPath          : String;
        FDocName       : String;
        FSender        : String;
        FReference     : String;
        FAgent         : String;
        FNoCache       : Boolean;
        FStatusCode    : Integer;
        FReasonPhrase  : String;
        FContentLength : LongInt;
        FContentType   : String;
        FDoAuthor      : TStringList;
        FContentPost   : String;
        FLocationFlag  : Boolean;
        FRcvdHeader    : TStrings;
        FRcvdStream    : TStream;
        FRcvdCount     : LongInt;
        FSentCount     : LongInt;
        FSendStream    : TStream;
        FReqStream     : TMemoryStream;
        FAnswerLine    : String;
        FOnHeaderBegin : TNotifyEvent;
        FOnHeaderEnd   : TNotifyEvent;
        FOnDocBegin    : TNotifyEvent;
        FOnDocEnd      : TNotifyEvent;
        FOnDocData     : TDocDataEvent;
        FOnSendBegin   : TNotifyEvent;
        FOnSendEnd     : TNotifyEvent;
        FOnSendData    : TDocDataEvent;
        FOnTrace       : TNotifyEvent;
        FOnAnswerLine  : TNotifyEvent;
        FOnCommand     : TOnCommand;

        procedure SendRequest(const method,Version: String);
        procedure GetAnswer;
        procedure SendCommand(const Cmd : String); virtual;
        procedure Login; virtual;
        procedure Logout; virtual;
        procedure SocketSessionClosed(Sender: TObject; Error: Word);
        procedure ReceiveDataDataAvailable(Sender: TObject; Error: Word);
        procedure ReceiveData;
        procedure SendData;
        procedure DoRequest(rq : THttpRequest);
        procedure TriggerHeaderBegin; virtual;
        procedure TriggerHeaderEnd; virtual;
        procedure TriggerDocBegin; virtual;
        procedure TriggerDocData(Data : Pointer; Len : Integer); virtual;
        procedure TriggerDocEnd; virtual;
        procedure TriggerSendBegin; virtual;
        procedure TriggerSendData(Data : Pointer; Len : Integer); virtual;
        procedure TriggerSendEnd; virtual;
    public
        constructor Create(Aowner:TComponent); override;
        destructor  Destroy; override;
        procedure   Get;
        procedure   Post;
        procedure   Head;

        property ContentLength   : LongInt         read  FContentLength;
        property ContentType     : String          read  FContentType;
        property RcvdCount       : LongInt         read  FRcvdCount;
        property SentCount       : LongInt         read  FSentCount;
        property StatusCode      : Integer         read  FStatusCode;
        property ReasonPhrase    : String          read  FReasonPhrase;
        property AuthorizationRequest: TStringList read  FDoAuthor;
        property AnswerLine      : String          read  FAnswerLine
                                                   write FAnswerLine;
        property DocName         : String          read  FDocName;
        property RcvdStream      : TStream         read  FRcvdStream
                                                   write FRcvdStream;
        property SendStream      : TStream         read  FSendStream
                                                   write FSendStream;
    published
        property URL             : String          read  FURL
                                                   write FURL;
        property Proxy           : String          read  FProxy
                                                   write FProxy;
        property ProxyPort       : String          read  FProxyPort
                                                   write FProxyPort;
        property Sender          : String          read  FSender
                                                   write FSender;
        property Agent           : String          read  FAgent
                                                   write FAgent;
        property Reference       : String          read  FReference
                                                   write FReference;
        property Username        : String          read  FUsername
                                                   write FUsername;
        property Password        : String          read  FPassword
                                                   write FPassword;
        property NoCache         : Boolean         read  FNoCache
                                                   write FNoCache;
        property Timeout         : LongInt         read  FTimeout
                                                   write FTimeout;
        property ContentTypePost : String          read  FContentPost
                                                   write FContentPost;
        property RcvdHeader      : TStrings        read  FRcvdHeader
                                                   write FRcvdHeader;
        property OnTrace         : TNotifyEvent    read  FOnTrace
                                                   write FOnTrace;
        property OnAnswerLine    : TNotifyEvent    read  FOnAnswerLine
                                                   write FOnAnswerLine;
        property OnCommand       : TOnCommand      read  FOnCommand
                                                   write FOnCommand;
        property OnHeaderBegin   : TNotifyEvent    read  FOnHeaderBegin
                                                   write FOnHeaderBegin;
        property OnHeaderEnd     : TNotifyEvent    read  FOnHeaderEnd
                                                   write FOnHeaderEnd;
        property OnDocBegin      : TNotifyEvent    read  FOnDocBegin
                                                   write FOnDocBegin;
        property OnDocData       : TDocDataEvent   read  FOnDocData
                                                   write FOnDocData;
        property OnDocEnd        : TNotifyEvent    read  FOnDocEnd
                                                   write FOnDocEnd;
        property OnSendBegin     : TNotifyEvent    read  FOnSendBegin
                                                   write FOnSendBegin;
        property OnSendData      : TDocDataEvent   read  FOnSendData
                                                   write FOnSendData;
        property OnSendEnd       : TNotifyEvent    read  FOnSendEnd
                                                   write FOnSendEnd;
    end;

procedure Register;
procedure ParseURL(const URL : String;
                   var Proto, User, Pass, Host, Port, Path : String);
function  Posn(const s, t : String; count : Integer) : Integer;
function  EncodeLine(Encoding : THttpEncoding;
                     SrcData : PChar; Size : Integer):String;
function EncodeStr(Encoding : THttpEncoding; const Value : String) : String;


implementation

const
    bin2uue  : String = '`!"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_';
    bin2b64  : String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    uue2bin  : String = ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_ ';
    b642bin  : String = '~~~~~~~~~~~^~~~_TUVWXYZ[\]~~~|~~~ !"#$%&''()*+,-./0123456789~~~~~~:;<=>?@ABCDEFGHIJKLMNOPQRS';
    linesize = 45;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure Register;
begin
    RegisterComponents('FPiette', [THttpCli]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor EHttpException.Create(const Msg : String; ErrCode : Word);
begin
    Inherited Create(Msg);
    ErrorCode := ErrCode;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF VER80}
procedure SetLength(var S: string; NewLength: Integer);
begin
    S[0] := chr(NewLength);
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor THttpCli.Create(Aowner:TComponent);
begin
    inherited create(AOwner);
    FWait                    := TWait.Create(Self);
    FWSocket                 := TWSocket.Create(Self);
    FWSocket.WaitCtrl        := FWait;
    FTimeout                 := 15;
    FProxyPort               := DefaultProxyPort;
    FContentPost             := 'application/x-www-form-urlencoded';
    FDoAuthor                := TStringlist.Create;
    FWSocket.OnSessionClosed := SocketSessionClosed;
    FRcvdHeader              := TStringList.Create;
    FReqStream               := TMemoryStream.Create;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
destructor THttpCli.Destroy;
begin
    FDoAuthor.Free;
    FWSocket.Free;
    FWait.Free;
    FRcvdHeader.Free;
    FReqStream.Free;
    inherited Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.TriggerDocBegin;
begin
    if Assigned(FOnDocBegin) then
        FOnDocBegin(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.TriggerDocEnd;
begin
    if Assigned(FOnDocEnd) then
        FOnDocEnd(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.TriggerDocData(Data : Pointer; Len : Integer);
begin
    if Assigned(FOnDocData) then
        FOnDocData(Self, Data, Len);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.TriggerSendBegin;
begin
    if Assigned(FOnSendBegin) then
        FOnSendBegin(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.TriggerSendEnd;
begin
    if Assigned(FOnSendEnd) then
        FOnSendEnd(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.TriggerSendData(Data : Pointer; Len : Integer);
begin
    if Assigned(FOnSendData) then
        FOnSendData(Self, Data, Len);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.TriggerHeaderBegin;
begin
    if Assigned(FOnHeaderBegin) then
        FOnHeaderBegin(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.TriggerHeaderEnd;
begin
    if Assigned(FOnHeaderEnd) then
        FOnHeaderEnd(Self);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure ReplaceExt(var FName : String; const newExt : String);
var
    I : Integer;
begin
    I := Posn('.', FName, -1);
    if I <= 0 then
        FName := FName + '.' + newExt
    else
        FName := Copy(FName, 1, I) + newExt;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.Login;
begin
    if FConnected then
       Logout;
    FWSocket.Addr  := FHostName;
    FWSocket.Port  := FPort;
    FWSocket.Proto := 'tcp';
    FWSocket.Connect;
    FWSocket.Wait(FTimeout, wsConnected);
    FConnected    := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.Logout;
begin
    FWSocket.Close;
    FConnected := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.SendCommand(const Cmd : String);
const
    CRLF : String[2] = #13#10;
begin
    if Assigned(FOnCommand) then
        FOnCommand(Self, Cmd);
    FReqStream.Write(Cmd[1], Length(Cmd));
    FReqStream.Write(CRLF[1], 2);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.SendRequest(const Method, Version: String);
begin
    FReqStream.Clear;
    TriggerHeaderBegin;
    SendCommand(method + ' ' + FPath + ' HTTP/' + Version);
    if FSender <> '' then
        SendCommand('From: ' + FSender);
    if FReference <> '' then
        SendCommand('Referer: ' + FReference);
    if FAgent <> '' then
        SendCommand('User-Agent: ' + FAgent);
    if FNoCache then
        SendCommand('Pragma: no-cache');
    if method = 'POST' then begin
        SendCommand('Content-Length: ' + IntToStr(SendStream.Size));
        if FContentPost <> '' then
            SendCommand('Content-Type: ' + FContentPost);
    end;
{   SendCommand('Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*'); }
{   SendCommand('Accept-Language: fr,en'); }
{   SendCommand('UA-pixels: 1024x768'); }
{   SendCommand('UA-color: color8'); }
    SendCommand('Host: ' + FTargetHost);
    if FUsername <> '' then
        SendCommand('Authorization: Basic ' +
                    EncodeStr(encBase64, FUsername + ':' + FPassword));

    TriggerHeaderEnd;
    SendCommand('');
    FWSocket.Send(FReqStream.Memory, FReqStream.Size);
    FReqStream.Clear;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.GetAnswer;
var
    proto  : String;
    user   : String;
    pass   : String;
    port   : String;
    Field  : String;
    Data   : String;
    nSep   : Integer;
    bFirst : Boolean;
begin
    FDoAuthor.Clear;
    FContentType   := '';
    FContentLength := 0;
    bFirst         := TRUE;
    FLocationFlag  := FALSE;
    FRcvdHeader.Clear;
    while TRUE do begin
        FWSocket.ReadLine(FTimeout, FAnswerLine);

        if FWSocket.State <> wsConnected then
            break;

        if Assigned(FOnAnswerLine) then
            FOnAnswerLine(Self);

        if Length(FAnswerLine) <= 0 then
            break;                         { End of answer }

        if bFirst then begin
            bFirst := FALSE;
            TriggerHeaderBegin;
        end;

        FRcvdHeader.Add(FAnswerLine);

        nSep := pos(':', FAnswerLine);
        if Copy(FAnswerLine, 1, 8) = 'HTTP/1.0' then begin
            FStatusCode   := StrToInt(Copy(FAnswerLine, 10, 3));
            FReasonPhrase := Copy(FAnswerLine, 14, Length(FAnswerLine));
            if FStatusCode >= 400 then
                break;   { HTTP error returned }
        end
        else if nSep > 0 then begin
            Field := LowerCase(Copy(FAnswerLine, 1, nSep - 1));
            Data  := Copy(FAnswerLine, nSep + 2, Length(FAnswerLine));
            if Field = 'location' then begin { Change the URL ! }
                FLocationFlag := TRUE;
                if proxy <> '' then
                    FPath := Data  { it goes via a proxy, so just change the uri }
                else begin
                    ParseURL(Data, proto, user, pass, FHostName, port, FPath);
                    if port <> '' then
                        FPort := port;
                end;
            end
            else if Field = 'content-length' then
                FContentLength := StrToInt(Data)
            else if Field = 'content-type' then
                FContentType := Data
            else if Field = 'www-authenticate' then
                FDoAuthor.add(Data)
        {   else if Field = 'date' then }
        {   else if Field = 'mime-version' then }
        {   else if Field = 'pragma' then }
        {   else if Field = 'allow' then }
        {   else if Field = 'server' then }
        {   else if Field = 'content-encoding' then }
        {   else if Field = 'expires' then }
        {   else if Field = 'last-modified' then }
       end
       else { Ignore  all other responses }
           ;
    end;

    if FStatusCode >= 400 then
        raise EHttpException.Create(FReasonPhrase, FStatusCode);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.Get;
begin
    DoRequest(httpGET);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.Head;
begin
    DoRequest(httpHEAD);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.Post;
begin
    DoRequest(httpPOST);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.DoRequest(rq : THttpRequest);
var
    Document, Proto, User, Pass, Host, Port, Path: String;
begin
    Document    := '';
    FStatusCode := 0;
    FRcvdCount  := 0;
    FSentCount  := 0;

    { parse url and proxy to FHostName, FPath and FPort }
    if FProxy <> '' then begin
        ParseURL(FURL, Proto, User, Pass, Host, Port, Path);
        FTargetHost := Host;
        FPath       := FURL;
        Document    := Path;
        if User <> '' then
            FUserName := User;
        if Pass <> '' then
            FPassword := Pass;
        if Proto = '' then
            FPath := 'http://'+FPath;
        ParseURL(FProxy, Proto, User, Pass, Host, Port, Path);
        if Port = '' then
            Port := ProxyPort;
    end
    else begin
        ParseURL(FURL, Proto, User, Pass, Host, Port, FPath);
        FTargetHost := Host;
        Document    := FPath;
        if User <> '' then
            FUserName := User;
        if Pass <> '' then
            FPassword := Pass;
        if Port = '' then
            Port := '80';
    end;
    if Proto = '' then
        Proto := 'http';
    if FPath = '' then
        FPath := '/';
    if (Document = '') or (Document = '/') then
        Document := 'document.htm'
    else begin
        if Document[Length(Document)] = '/' then
            SetLength(Document, Length(Document) - 1);
        Document := Copy(Document, Posn('/', Document, -1) + 1, 255);
    end;

    FHostName   := host;
    FPort       := Port;

    Login;
    try
        while TRUE do begin
            case Rq of
            httpPOST:
                begin
                    SendRequest('POST', '1.0');
                    TriggerSendBegin;
                    try
                        SendData;
                    finally
                        TriggerSendEnd;
                    end;
                end;
            httpGET,
            httpHEAD:
                begin
                    SendRequest('GET', '1.0');
                end;
            end;
            GetAnswer;
            if not FLocationFlag then
                break;
            Login;       { This will Logout automatically }
        end;

        if lowercase(ExtractFileExt(Document)) = '.exe' then begin
            if FContentType = 'text/html' then
                ReplaceExt(Document, 'htm');
        end;
        FDocName := Document;

        if Rq in [httpGET, httpPOST] then begin
            TriggerDocBegin;
            try
                ReceiveData;
            finally
                TriggerDocEnd;
            end;
        end;
    finally
        Logout;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.SocketSessionClosed(Sender: TObject; Error: Word);
begin
    FConnected := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.ReceiveDataDataAvailable(Sender: TObject; Error: Word);
var
   Len : Integer;
begin
    Len := FWSocket.Receive(@FBuffer, sizeof(FBuffer));
    if Len > 0 then begin
        FRcvdCount := FRcvdCount + Len;
        TriggerDocData(@FBuffer, Len);
        if Assigned(FRcvdStream) then
            FRcvdStream.WriteBuffer(FBuffer, Len);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.SendData;
var
    Len : Integer;
begin
    repeat
        Len := FSendStream.Read(FBuffer, sizeof(FBuffer));
        if Len > 0 then begin
            FSentCount := FSentCount + Len;
            TriggerSendData(@FBuffer, Len);
            FWSocket.Send(@FBuffer, Len);
        end;
    until Len <= 0;
    FWSocket.Flush;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpCli.ReceiveData;
var
    OldDataAvailable : TDataAvailable;
begin
    OldDataAvailable         := FWSocket.OnDataAvailable;
    FWSocket.OnDataAvailable := ReceiveDataDataAvailable;
    try
        while FWSocket.State = wsConnected do
            Application.ProcessMessages;
    finally
        FWSocket.OnDataAvailable := OldDataAvailable;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Syntax of an URL: protocol://[user[:password]@]server[:port]/path         }
procedure ParseURL(
    const url : String;
    var Proto, User, Pass, Host, Port, Path : String);
var
    p, q : Integer;
    s    : String;
begin
    proto := '';
    User  := '';
    Pass  := '';
    Host  := '';
    Port  := '';
    Path  := '';

    p := pos('://',url);
    if p = 0 then begin
        if lowercase(Copy(url,1,7)) = 'mailto:' then begin
            proto := 'mailto';
            p := pos(':', url);
        end;
    end
    else begin
        proto := Copy(url, 1, p - 1);
        inc(p, 2);
    end;
    s := Copy(url, p + 1, Length(url));

    p := pos('/', s);
    if p = 0 then
        p := Length(s) + 1;
    Path := Copy(s, p, Length(s));
    s := Copy(s, 1, p-1);

    p := Posn(':', s, -1);
    if p > Length(s) then
        p := 0;
    q := Posn('@', s, -1);
    if q > Length(s) then
        q := 0;
    if (p = 0) and (q = 0) then begin   { no user, password or port }
        Host := s;
        Exit;
    end
    else if q < p then begin  { a port given }
        Port := Copy(s, p + 1, Length(s));
        Host := Copy(s, q + 1, p - q - 1);
        if q = 0 then
            Exit; { no user, password }
        s := Copy(s, 1, q - 1);
    end
    else begin
        Host := Copy(s, q + 1, Length(s));
        s := Copy(s, 1, q - 1);
    end;
    p := pos(':', s);
    if p = 0 then
        User := s
    else begin
        User := Copy(s, 1, p - 1);
        Pass := Copy(s, p + 1, Length(s));
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function EncodeStr(Encoding : THttpEncoding; const Value : String) : String;
begin
    Result := EncodeLine(Encoding, @Value[1], Length(Value));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function EncodeLine(
    Encoding : THttpEncoding;
    SrcData  : PChar;
    Size     : Integer) : String;
var
    Offset : Integer;
    Pos1   : Integer;
    Pos2   : Integer;
    I      : Integer;
begin
    SetLength(Result, Size * 4 div 3 + 4);
    FillChar(Result[1], Size * 4 div 3 + 2, #0);

    if Encoding = encUUEncode then begin
        Result[1] := Char(((Size - 1) and $3f) + $21);
        Size      := ((Size + 2) div 3) * 3;
    end;
    Offset := 2;
    Pos1   := 0;
    Pos2   := 0;
    case Encoding of
        encUUEncode:        Pos2 := 2;
        encBase64, encMime: Pos2 := 1;
    end;
    Result[Pos2] := #0;

    while Pos1 < Size do begin
        if Offset > 0 then begin
            Result[Pos2] := Char(ord(Result[Pos2]) or
                                 ((ord(SrcData[Pos1]) and
                                  ($3f shl Offset)) shr Offset));
            Offset := Offset - 6;
            Inc(Pos2);
            Result[Pos2] := #0;
        end
        else if Offset < 0 then begin
            Offset := Abs(Offset);
            Result[Pos2] := Char(ord(Result[Pos2]) or
                                 ((ord(SrcData[Pos1]) and
                                  ($3f shr Offset)) shl Offset));
            Offset := 8 - Offset;
            Inc(Pos1);
        end
        else begin
            Result[Pos2] := Char(ord(Result[Pos2]) or
                                 ((ord(SrcData[Pos1]) and $3f)));
            Inc(Pos2);
            Inc(Pos1);
            Result[Pos2] := #0;
            Offset    := 2;
        end;
    end;

    case Encoding of
    encUUEncode:
        begin
            if Offset = 2 then
                Dec(Pos2);
            for i := 2 to Pos2 do
                Result[i] := bin2uue[ord(Result[i])+1];
        end;
    encBase64, encMime:
        begin
            if Offset = 2 then
                Dec(Pos2);
            for i := 1 to Pos2 do
                Result[i] := bin2b64[ord(Result[i])+1];
            while (Pos2 and 3) <> 0  do begin
                Inc(Pos2);
                Result[Pos2] := '=';
            end;
        end;
    end;
    SetLength(Result, Pos2);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Find the count'th occurence of the s string in the t string.              }
{ If count < 0 then look from the back                                      }
function Posn(const s , t : String; Count : Integer) : Integer;
var
    i, h, Last : Integer;
    u          : String;
begin
    u := t;
    if Count > 0 then begin
        Result := Length(t);
        for i := 1 to Count do begin
            h := Pos(s, u);
            if h > 0 then
                u := Copy(u, h + 1, Length(u))
            else begin
                u := '';
                Inc(Result);
            end;
        end;
        Result := Result - Length(u);
    end
    else if Count < 0 then begin
        Last := 0;
        for i := Length(t) downto 1 do begin
            u := Copy(t, i, Length(t));
            h := Pos(s, u);
            if (h <> 0) and ((h + i) <> Last) then begin
                Last := h + i - 1;
                Inc(count);
                if Count = 0 then
                    break;
            end;
        end;
        if Count = 0 then
            Result := Last
        else
            Result := 0;
    end
    else
        Result := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

