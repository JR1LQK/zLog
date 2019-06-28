Unit Sock;

// *****************************************************************************
// Sock.Pas (TSock)
// Windows Socket Component For Delphi 3.0 & C++Builder
// Version 1.0f
// Written By Tom Bradford
// (C) 1997 By Beach Dog Software, Inc.
// All Rights Reserved
// http://www.beachdogsoftware.com
// *****************************************************************************

Interface

Uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     WinSock;

Type TSocketInfo = (siLookUp, siConnect, siClose, siListen, siReceive, siSend, siAccept, siError);
     TSocketType = (stStream, stDatagram);
     TLineBreak  = (lbCRLF, lbCR, lbLF, lbSmart);

Const WM_SOCK = WM_USER + 75; // Hopefully, Your App Won't Use This Message

Type TSock = Class; // Forward Declared For Event Types

     ESockException = Class(Exception);
     TNotifyReadEvent = Procedure(Sender : TObject; Count : Integer) Of Object;
     TNotifyAutoEvent = Procedure(Sender : TObject; NewSock : TSock) Of Object;
     TNotifyInfoEvent = Procedure(sender : TObject; SocketInfo : TSocketInfo; Msg : String) Of Object;

     TSock = Class(TCustomControl)
        Private
           FSockAddrIn : TSockAddrIn;  // Address Information Block
           FRecvAddrIn : TSockAddrIn;  // Address Information Block For RecvFrom
           FLastChar   : Char;         // Last Character Read For Line-Input

           FPicture    : TBitmap;      // Holder For Design-Time Image
           FBmp_TCP    : TBitmap;      // TCP Bitmap
           FBmp_UDP    : TBitmap;      // UDP Bitmap
           FBmp_Listen : TBitmap;      // Listening Bitmap

           // Character Buffer (Most WINSOCK.DLLs Max At 32k)
           FCharBuf    : Array[1..32768] Of Char;

           FSocketType : TSocketType;  // Socket Type (Stream Or Datagram)
           FLineBreak  : TLineBreak;   // Line Break Style For Line Input
           FHostName   : String;       // Host Name Or IP Address
           FPortName   : String;       // Port Name Or Well-Known Number
           FSocket     : TSocket;      // Socket Handle
           FInBuffer   : String;       // Input Buffer
           FOutBuffer  : String;       // Output Buffer For Non-Blocking
           FListen     : Boolean;      // Socket Listens?
           FBlocking   : Boolean;      // Do Blocking Calls?
           FAutoAccept : Boolean;      // Automatically Accept Incomings
           FConnected  : Boolean;      // Are We Connected?
           FBlockTime  : Integer;      // How Long To Wait For Blocking Operation
           FStream     : TStream;      // Associated TSockStream Object

           FOnConnect    : TNotifyEvent;
           FOnDisconnect : TNotifyEvent;
           FOnInfo       : TNotifyInfoEvent;
           FOnRead       : TNotifyReadEvent;
           FOnWrite      : TNotifyEvent;
           FOnAccept     : TNotifyEvent;
           FOnAutoAccept : TNotifyAutoEvent;

           // Property Set/Get Routines
           Procedure SetHostName(Value : String);
           Procedure SetPortName(Value : String);
           Function GetText : String;
           Procedure SetText(Value : String);
           Procedure SetListen(Value : Boolean);
           Procedure SetBlocking(Value : Boolean);
           Procedure SetAutoAccept(Value : Boolean);
           Procedure SetConnected(Value : Boolean);
           Function GetConnected : Boolean;
           Procedure SetSocket(Value : TSocket);
           Procedure SetSocketType(Value : TSocketType);
           Function GetRemoteHost : String;
           Function GetEOF : Boolean;

           // Private Support Methods
           Procedure DoInfo(SocketInfo : TSocketInfo; Msg : String);
           Procedure SetBitmap;
        Protected
           // Event Handlers
           Procedure WMSock(Var Message : TMessage); Message WM_SOCK;
           Procedure WMPaint(Var Message : TWMPaint); Message WM_PAINT;
           Procedure WMSize(Var Message : TWMSize); Message WM_SIZE;

           // Loaded Handles Starting Listening Mode After Streaming The Properties
           Procedure Loaded; Override;

           // Protected Constructor Can Only Be Called By TSock Class
           Constructor CreateWithSocket(AOwner : TComponent; NewSocket : TSocket); Virtual;
           Destructor Destroy; Override;

        Public
           Constructor Create(AOwner : TComponent); Override;

           Function Open : Boolean;
           Function Close : Boolean;
           Function Send(Value : String) : Boolean;
           Function ReceiveCount(Count : Integer) : String;
           Function Receive : String;
           Function ReceiveLine : String;
           Function SendDatagram(Value, HostName : String) : Boolean;
           Function ReceiveDatagram(Var HostName : String) : String;

           // The Accept Method Will Create NewSock, But User Must Free
           Function Accept(Var NewSock : TSock) : Boolean;

           // Public Support Methods
           Function HostLookup(Value : String) : TInAddr;
           Function PortLookup(Value : String) : U_Short;

           // StartListen And StopListen Are A Robust Form Of Setting Listen
           Function StartListen : Boolean;
           Function StopListen : Boolean;

           Property Text : String Read GetText Write SetText;
           Property Connected : Boolean Read GetConnected Write SetConnected; // Used To Read FConnected

           Property EndOfFile : Boolean Read GetEOF;
           Property Socket : TSocket Read FSocket Write SetSocket;

           Property Stream : TStream Read FStream;

           // RemoteHost Returns The Remote IP If SocketType=stStream
           // And Will Return The Most Recent Incoming Datagram IP If
           // SocketType=stDatagram
           Property RemoteHost : String Read GetRemoteHost;

        Published
           Property SocketType : TSocketType Read FSocketType Write SetSocketType;
           Property HostName : String Read FHostName Write SetHostName;
           Property PortName : String Read FPortName Write SetPortName;
           Property Blocking : Boolean Read FBlocking Write SetBlocking;
           Property AutoAccept : Boolean Read FAutoAccept Write SetAutoAccept;
           Property Listen : Boolean Read FListen Write SetListen;
           Property LineBreak : TLineBreak Read FLineBreak Write FLineBreak;
           Property BlockingTimeout : Integer Read FBlockTime Write FBlockTime;

           Property OnConnect : TNotifyEvent Read FOnConnect Write FOnConnect;
           Property OnDisconnect : TNotifyEvent Read FOnDisconnect Write FOnDisconnect;
           Property OnInfo : TNotifyInfoEvent Read FOnInfo Write FOnInfo;
           Property OnRead : TNotifyReadEvent Read FOnRead Write FOnRead;
           Property OnWrite : TNotifyEvent Read FOnWrite Write FOnWrite;
           Property OnAccept : TNotifyEvent Read FOnAccept Write FOnAccept;
           Property OnAutoAccept : TNotifyAutoEvent Read FOnAutoAccept Write FOnAutoAccept;
     End;

// Global IP Caching Mechanism.  Uses A String List That Stores The 32-Bit IP
// Address Of It's Associated Hostname In The Object Property Of The List.  You
// Should Never Have To Manipulate This Object Directly, But It Is Made Public
// For The Purpose Of Calling The Clear Method To Empty It.
Var IPCache : TStringList;

Function WSDescription : String; // Returns A Description Of The WinSock Driver
Function WSSystemStatus : String; // Returns System Status From The WinSock Driver
Function SocketInfoText(Value : TSocketInfo) : String; // Converts TSocketInfo Values To Text
Function ErrToStr(Value : Integer) : String; // Converts A WinSock Error To Text
Function Base64Encode(Value : String) : String; // Converts Passed Value To MIME Base64
Function Base64Decode(Value : String) : String; // Converts Passed Value From MIME Base64
Function URLEncode(Value : String) : String; // Converts String To A URLEncoded String
Function URLDecode(Value : String) : String; // Converts String From A URLEncoded String

Procedure Register;

Implementation

{$R SOCK.RES}

Const Base64Table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
      ValidURLChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      SocketInfoMsg : Array[siLookUp..siError] Of String = ('Lookup','Connect','Close','Listen','Receive','Send','Accept','Error');

Type TSockStream = Class(TStream)
        Private
           Sock : TSock;
        Public
           function Read(Var Buffer; Count : Longint): Longint; Override;
           function Write(Const Buffer; Count : Longint): Longint; Override;
           function Seek(Offset : Longint; Origin : Word): Longint; Override;

           Constructor Create(Sock : TSock); Virtual;
     End;

Type TSockThread = Class(TThread)
        Private
           ParentSock : TSock;
           ClientSock : TSock;
        Public
           Procedure Execute; Override;
           Procedure RunThread(ParentSock, ClientSock : TSock);
     End;

// WinSock Initialization Data
Var WSAData : TWSAData;

//*** TSockStream Methods ******************************************************

Constructor TSockStream.Create(Sock : TSock);
Begin
   Self.Sock := Sock;
End;

Function TSockStream.Read(Var Buffer; Count : Longint): Longint;
Var Temp : String;
Begin
   Temp := Sock.ReceiveCount(Count);
   Move(Temp[1], Buffer, Length(Temp));
   Result := Length(Temp);
End;

Function TSockStream.Write(Const Buffer; Count : Longint): Longint;
Var Temp : String;
Begin
   SetLength(Temp, Count);
   Move(Buffer, Temp[1], Count);
   Sock.Send(Temp);
   Result := Count;
End;

Function TSockStream.Seek(Offset : Longint; Origin : Word): Longint;
Begin
   Result := 0;
End;

//*** TSockThread Methods ******************************************************

Procedure TSockThread.Execute;
Begin
   ParentSock.OnAutoAccept(ParentSock, ClientSock);
   Self.Free;
End;

Procedure TSockThread.RunThread(ParentSock, ClientSock : TSock);
Begin
   Self.ParentSock := ParentSock;
   Self.ClientSock := ClientSock;
   Resume;
End;

//*** Property Set/Get Procedures **********************************************

Procedure TSock.SetHostName(Value : String);
Begin
   If (FSocketType = stStream) And FConnected Then
      DoInfo(SiLookup, 'Setting HostName While Connected Has No Effect');
   FHostName := Value;
   If (FSocketType = stDatagram) And FConnected Then
      FSockAddrIn.SIn_Addr := HostLookup(Value);
End;

Procedure TSock.SetPortName(Value : String);
Begin
   If FConnected Then
      DoInfo(SiLookup, 'Setting PortName While Connected Has No Effect');
   FPortName := Value;
End;

Function TSock.GetText : String;
Begin
   // Just Call The Receive Method
   Result := Receive;
End;

Procedure TSock.SetText(Value : String);
Begin
   // Just Call The Send Method And Ignore The Boolean Result
   Send(Value);
End;

Procedure TSock.SetListen(Value : Boolean);
Var WasListen : Boolean;
    Addr      : TSockAddr;
    Res       : Integer;
Begin
   If (csDesigning In ComponentState) Then
      Begin
         FListen := Value;
         If Value and (FSocketType = stDatagram) Then
            // Listening Sockets Must Be Stream Sockets
            SetSocketType(stStream)
         Else
            SetBitmap;
         Exit;
      End
   Else
      If (csReading In ComponentState) Then
         Begin
            // If We Haven't Loaded Yet, Just Set The Value And Exit
            FListen := Value;
            Exit;
         End;
   WasListen := FListen;
   If (FSocket <> INVALID_SOCKET) And (Not WasListen) Then
      Begin
         FListen := False;
         Raise ESockException.Create('Listen - Socket Already In Use');
      End;
   If (FSocketType = stDatagram) And Value Then
      Begin
         FListen := False;
         Raise ESockException.Create('Listen - Cannot Listen On A Datagram Socket');
      End;
   FListen := Value;
   If FListen Then
      Begin
         If Not WasListen Then
            Begin
               // Have To Create A Socket Start Asynchronous Listening
               FListen := True;
               FSocket := WinSock.Socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
               FillChar(Addr, SizeOf(Addr), #0);
               Addr.SIn_Family := AF_INET;
               Addr.SIn_Port := PortLookup(FPortName);
               Addr.SIn_Addr.S_Addr := HToNL(INADDR_ANY);
               // SetBlocking Will Set The Asynchronous Mode
               SetBlocking(FBlocking);
               FListen := False;
               Res := WinSock.Bind(FSocket, Addr, SizeOf(Addr));
               If Res <> 0 Then
                  Raise ESockException.Create('Listen - Error Binding Socket');
               Res := WinSock.Listen(FSocket, 5);
               If Res <> 0 Then
                  Raise ESockException.Create('Listen - Error Starting Listen');
               FListen := True;
               DoInfo(SiListen, 'Listening Started');
            End
         Else
            DoInfo(SiListen, 'Listening Already Running');
      End
   Else
      Begin
         Close;
         DoInfo(SiListen, 'Listening Stopped');
      End;
End;

Procedure TSock.SetBlocking(Value : Boolean);
Var Il : U_Long;
    Ev : U_Long;
Begin
   If (Not (csDesigning In ComponentState)) And (csReading In ComponentState) Then
      Begin
         // If We Haven't Fully Loaded Yet, Just Set The Value And Exit
         FBlocking := Value;
         Exit;
      End;
   If FSocket = INVALID_SOCKET Then
      FBlocking := Value
   Else
      Begin
         Ev := 0;
         FBlocking := Value;
         If (Parent = Nil) Then
            Begin
               // If The Component Has No Parent (Dynamically Created) We Adopt It
               Parent := Screen.Forms[0];
               HandleNeeded;
            End;
         If FBlocking And (Not FListen) Then
            Begin
               Il := 0;
               // Turn Off Async Checking And Set Blocking On
               WinSock.WSAAsyncSelect(FSocket, Handle, WM_SOCK, Ev);
               WinSock.IOCtlSocket(FSocket, FIONBIO, Il);
            End
         Else
            Begin
               If FListen Then
                  // If We're Listening, We Only Care About Accept Messages
                  Ev := FD_ACCEPT
               Else
                  Begin
                     Ev := FD_READ; // Datagram Sockets Only Care About Read Messages
                     If FSocketType = stStream Then
                        Ev := Ev Or FD_CLOSE Or FD_CONNECT Or FD_WRITE Or FD_READ;
                  End;
               WinSock.WSAAsyncSelect(FSocket, Handle, WM_SOCK, Ev);
            End;
      End;
End;

Procedure TSock.SetAutoAccept(Value : Boolean);
Begin
   FAutoAccept := Value;
End;

Procedure TSock.SetConnected(Value : Boolean);
Begin
   If Value Then
      Open
   Else
      Close;
End;

Function TSock.GetConnected : Boolean;
Begin
   If FSocket = INVALID_SOCKET Then
      FConnected := False;
   Result := FConnected;
End;

Function TSock.GetEOF : Boolean;
Begin
   Result := (FInBuffer = '') And (Not FConnected);
End;

Procedure TSock.SetSocket(Value : TSocket);
Var Buf : Array[1..10] Of Char;
    Len : Integer;
    Res : Integer;
Begin
   FSocket := Value;
   If FSocket = INVALID_SOCKET Then
      Begin
         // If The Socket Is Unassigned Then Who Cares
         FConnected := False;
         FListen := False;
      End
   Else
      Begin
         // Otherwise, We Need To Check To See If It's Already Listening
         Len := SizeOf(Buf);
         Res := WinSock.GetSockOpt(FSocket, IPPROTO_TCP, SO_ACCEPTCONN, PChar(@Buf), Len);
         If (Res = 0) And (Buf[1] <> #0) Then
            Begin
               FSocket := INVALID_SOCKET;
               Raise ESockException.Create('Socket - Can''t Assign A Listening Socket');
            End
         Else
            FConnected := True;
      End;
End;

Procedure TSock.SetSocketType(Value : TSocketType);
Begin
   If csDesigning In ComponentState Then
      Begin
         // At Design-Time, stDatagram And Listen Are Mutually Exclusive
         If (Value = stDatagram) And FListen Then
            SetListen(False);
         FSocketType := Value;
         SetBitmap;
      End
   Else
      Begin
         If FListen Then
            Raise ESockException.Create('SocketType - Can''t Assign Socket Type While Listening');
         If FConnected Then
            Raise ESockException.Create('SocketType - Can''t Assign Socket Type While Connected');
         FSocketType := Value;
      End
End;

Function TSock.GetRemoteHost : String;
Begin
   // Convert FRecvAddrIn To A String IP Address
   Result := INet_NToA(FRecvAddrIn.SIn_Addr);
End;

Procedure TSock.DoInfo(SocketInfo : TSocketInfo; Msg : String);
Begin
   If Assigned(FOnInfo) Then
      FOnInfo(Self, SocketInfo, Msg);
End;

Procedure TSock.SetBitmap;
Begin
   // Determine The Design-Time Bitmap To Use
   If FSocketType = stDatagram Then
      FPicture := FBmp_UDP
   Else
      If FListen Then
         FPicture := FBmp_Listen
      Else
         FPicture := FBmp_TCP;
   Invalidate;
End;

//*** Constructor/Destructor ***************************************************

Constructor TSock.Create(AOwner : TComponent);
Begin
   Inherited Create(AOwner);
   If (csDesigning In ComponentState) Then
      Begin
         // Get Bitmaps For Design-Time Image
         FBmp_TCP := TBitmap.Create;
         FBmp_UDP := TBitmap.Create;
         FBmp_Listen := TBitmap.Create;
         FBmp_TCP.Handle := LoadBitmap(hInstance, 'TCP');
         FBmp_UDP.Handle := LoadBitmap(hInstance, 'UDP');
         FBmp_Listen.Handle := LoadBitmap(hInstance, 'LISTEN');
         FPicture := FBmp_TCP;
         Width := FPicture.Width;
         Height := FPicture.Height;
         SetZOrder(True);
      End
   Else
      Begin
         Width := 0;
         Height := 0;
         SetZOrder(False);
         Visible := False;
      End;
   FHostName := '';
   FPortName := '';
   FSocket := INVALID_SOCKET;
   FLineBreak := lbSmart;
   FLastChar := #0;
   FInBuffer := '';
   FOutBuffer := '';
   FListen := False;
   FBlocking := False;
   FAutoAccept := False;
   FConnected := False;
   FStream := TSockStream.Create(Self);
End;

// This Constructor Assumes NewSocket Is A Valid Socket Handle
Constructor TSock.CreateWithSocket(AOwner : TComponent; NewSocket : TSocket);
Begin
   Create(AOwner);
   FSocket := NewSocket;
   SetBlocking(TSock(AOwner).Blocking);
   FBlockTime := TSock(AOwner).BlockingTimeout;
   FOnRead := TSock(AOwner).OnRead;
   FOnWrite := TSock(AOwner).OnWrite;
   FOnDisconnect := TSock(AOwner).OnDisconnect;
   FOnInfo := TSock(AOwner).OnInfo;
   FConnected := True;
End;

Destructor TSock.Destroy;
Begin
   If FListen Or FConnected Then
      Close;
   If (csDesigning In ComponentState) Then
      Begin
         FBmp_TCP.Free;
         FBmp_UDP.Free;
         FBmp_Listen.Free;
      End;
   Inherited Destroy;
End;

Procedure TSock.Loaded;
Begin
   If Not (csDesigning In ComponentState) Then
      Begin
         // If Component Has Been Loaded At Run-Time And Listen Then Start Listening
         SetBlocking(FBlocking);
         If FListen Then
            Begin
               FListen := False;
               SetListen(True);
            End;
      End;
End;

//*** Event Handling ***********************************************************

Procedure TSock.WMSock(Var Message : TMessage);
Var Event : Word;
    Error : Word;
    Res   : Integer;
    AcSck : TSocket;
    Addr  : TSockAddrIn;
    AddrL : Integer;
    CSock : TSock;
    Spawn : TSockThread;
Begin
   Inherited;
   // Message Handling For Non-Blocking Sockets
   Event := WinSock.WSAGetSelectEvent(Message.LParam);
   Error := WinSock.WSAGetSelectError(Message.LParam);
   If Error > WSABASEERR Then
      DoInfo(SiError, 'Error #'+IntToStr(Error)+' ('+ErrToStr(Error)+')')
   Else
      // Messages Mean Different Things Depending On Whether You're Listening Or Not
      Case Event Of
         FD_ACCEPT  : Begin
                         // Incoming Socket
                         If FAutoAccept And Assigned(FOnAutoAccept) Then
                            Begin
                               // If AutoAccept Is Set To True And OnAutoAccept Is Set...
                               // Create A New Socket Based On The Accepted One And Begin
                               // AutoAccept As If It Were A Thread... The AutoAccept
                               // Routine Is Responsible For Destroying The New Socket
                               // Component.
                               AddrL := SizeOf(Addr);
                               FillChar(Addr, SizeOf(Addr), #0);
   {$IFDEF VER100}
                               AcSck := WinSock.Accept(FSocket, @Addr, @AddrL);
   {$ELSE}
                               AcSck := WinSock.Accept(FSocket, Addr, AddrL);
   {$ENDIF}
                               FRecvAddrIn := Addr;
                               CSock := TSock.CreateWithSocket(Self, AcSck);
                               CSock.PortName := FPortName;
                               CSock.HostName := INet_NToA(Addr.SIn_Addr);
                               If FBlocking Then
                                  Begin
                                     Spawn := TSockThread.Create(True);
                                     Spawn.RunThread(Self, CSock);
                                  End
                               Else
                                  FOnAutoAccept(Self, CSock);
                            End
                         Else
                            If Assigned(FOnAccept) Then
                               FOnAccept(Self);
                      End;
         FD_CONNECT : Begin
                         FConnected := True;
                         DoInfo(SiConnect, 'Non-Blocking Socket Connected');
                         If Assigned(FOnConnect) Then
                            FOnConnect(Self);
                      End;
         FD_CLOSE   : Begin
                         If Assigned(FOnDisconnect) Then
                            FOnDisconnect(Self);
                         Close;
                      End;
         FD_READ    : Begin
                         If FSocketType = stStream Then
                            Begin
                               Res := WinSock.Recv(FSocket, FCharBuf, SizeOf(FCharBuf), 0);
                               If Res > 0 Then
                                  FInBuffer := FInBuffer + Copy(FCharBuf, 1, Res);
                               DoInfo(SiReceive, 'Non-Blocking Incoming Data');
                               If Assigned(FOnRead) Then
                                  FOnRead(Self, Length(FInBuffer));
                            End
                         Else
                            If Assigned(FOnRead) Then
                               FOnRead(Self, Length(FInBuffer));
                      End;
         FD_WRITE   : Begin
                         If FOutBuffer <> '' Then
                            Send('');
                         DoInfo(SiSend, 'Non-Blocking Outgoing Data');
                         If Assigned(FOnWrite) Then
                            FOnWrite(Self);
                      End;
      End;
   Message.Result := 0;
End;

Procedure TSock.WMPaint(Var Message : TWMPaint);
Begin
   Inherited;
   If (csDesigning In ComponentState) Then
      Canvas.Draw(0, 0, FPicture);
   Message.Result := 0;
End;

Procedure TSock.WMSize(Var Message : TWMSize);
Begin
   Inherited;
   If (csDesigning In ComponentState) Then
      Begin
         If Width <> FPicture.Width Then
            Width := FPicture.Width;
         If Height <> FPicture.Height Then
            Height := FPicture.Height;
      End;
   Message.Result := 0;
End;

//*** Support Methods **********************************************************

Function TSock.Open : Boolean;
Var Res : Integer;
    ST  : Integer;
Begin
   If FSocket = INVALID_SOCKET Then
      Begin
         If FSocketType = stStream Then
            ST := SOCK_STREAM
         Else
            ST := SOCK_DGRAM;

         // Create The Socket And Set Up The Remote Address And Port
         FSocket := WinSock.Socket(AF_INET, ST, IPPROTO_IP);

         FSockAddrIn.SIn_Family := AF_INET;
         FSockAddrIn.SIn_Port := PortLookup(FPortName);
         If FSocketType = stDatagram Then
            FSockAddrIn.SIn_Addr := HostLookup('')
         Else
            FSockAddrIn.SIn_Addr := HostLookup(FHostName);

         SetBlocking(FBlocking);

         If FSocketType = stStream Then
            Begin
               // Stream Sockets Require A Connect
               Res := WinSock.Connect(FSocket, FSockAddrIn, SizeOf(TSockAddrIn));
               If FBlocking Then
                  Begin
                     If Res = 0 Then
                        Begin
                           FConnected := True;
                           DoInfo(SiConnect, 'Blocking Socket Connected');
                           If Assigned(FOnConnect) Then
                              FOnConnect(Self);
                        End
                     Else
                        Begin
                           DoInfo(SiClose, 'Blocking Socket Can''t Connect');
                           Close;
                        End;
                  End;
            End
         Else
            Begin
               // Datagram Sockets Require A Bind
               Res := WinSock.Bind(FSocket, FSockAddrIn, SizeOf(TSockAddrIn));
               If Res = 0 Then
                  Begin
                     FConnected := True;
                     DoInfo(SiConnect, 'Datagram Socket Connected');
                     If Assigned(FOnConnect) Then
                        FOnConnect(Self);
                  End;
            End;
      End;
   Result := FConnected;
End;

Function TSock.Close : Boolean;
Begin
   Result := (WinSock.CloseSocket(FSocket) = 0);
   FSocket := INVALID_SOCKET;
   FConnected := False;
   If Not FListen Then
      DoInfo(SiClose, 'Socket Closed');
   FListen := False;
End;

Function TSock.Send(Value : String) : Boolean;
Var Remain : Integer;
Begin
   Result := True;
   If FSocket = INVALID_SOCKET Then
      Raise ESockException.Create('Send - Socket Not Connected');
   If FListen Then
      Raise ESockException.Create('Send - Cannot Send On A Listener Socket');
   If FSocketType = stStream Then
      Begin
         FOutBuffer := FOutBuffer + Value;
         If FOutBuffer = '' Then
            Exit;
         If FBlocking Then
            Begin
               Remain := Length(FOutBuffer);
               // While Any Content Remains Or No Errors Have Happened, Then Loop
               While Remain > 0 Do
                  Begin
                     Remain := WinSock.Send(FSocket, FOutBuffer[1], Length(FOutBuffer), 0);
                     If (Remain = SOCKET_ERROR) And (WinSock.WSAGetLastError <> WSAEINPROGRESS) Then
                        Begin
                           DoInfo(SiError, 'Socket Error On Send');
                           Raise ESockException.Create('Send - Socket Error');
                        End
                     Else
                        Begin
                           If Remain > 0 Then
                              Delete(FOutBuffer, 1, Remain);
                           Remain := Length(FOutBuffer);
                           DoInfo(SiSend, 'Blocking Outgoing Data');
                        End;
                  End;
               FOutBuffer := '';
            End
         Else
            Begin
               // Do Not Loop For A Non-Blocking Socket
               DoInfo(SiSend, 'Non-Blocking Outgoing Data');
               Remain := WinSock.Send(FSocket, FOutBuffer[1], Length(FOutBuffer), 0);
               If Remain > 0 Then
                  Delete(FOutBuffer, 1, Remain);
            End;
      End
   Else
      SendDatagram(Value, FHostName);
End;

Function TSock.Receive : String;
Begin
   Result := ReceiveCount(-1);
End;

Function TSock.ReceiveCount(Count : Integer) : String;
Var Res   : Integer;
    FDSet : PFDSet;
    TV    : PTimeVal;
    Err   : Integer;
    HostN : String;
    Cnt   : Integer;
Begin
   If (FSocket = INVALID_SOCKET) And (FInBuffer = '') Then
      Raise ESockException.Create('Receive - Socket Not Connected');
   If FListen Then
      Raise ESockException.Create('Receive - Cannot Receive On A Listener Socket');
   Cnt := Count;
   If (Cnt = -1) Or (Cnt > SizeOf(FCharBuf)) Then
      Cnt := SizeOf(FCharBuf);
   If FSocketType = stStream Then
      Begin
         If FBlocking Then
            Begin
               FDSet := New(PFDSet);
               FDSet^.FD_Count := 1;
               FDSet^.FD_Array[0] := FSocket;
               If FBlockTime >= 0 Then
                  Begin
                     TV := New(PTimeVal);
                     TV^.tv_sec := FBlockTime;
                  End
               Else
                  TV := Nil;
               // Used To Loop While We're Connected And Anything Is In The Input Queue
               If FConnected And (WinSock.Select(FSocket, FDSet, Nil, Nil, TV) > 0) Then
                  Begin
                     DoInfo(SiReceive, 'Blocking Incoming Data');
                     Res := WinSock.Recv(FSocket, FCharBuf, Cnt, 0);
                     If (Res = SOCKET_ERROR) Then
                        Begin
                           Err := WSAGetLastError;
                           Result := '';
                           FInBuffer := '';
                           Dispose(FDSet);
                           Dispose(TV);
                           DoInfo(SiError, 'Socket Error On Receive');
                           Raise ESockException.Create('Receive - Socket Error '+ErrToStr(Err));
                        End
                     Else
                        Begin
                           If Res > 0 Then
                              FInBuffer := FInBuffer + Copy(FCharBuf, 1, Res)
                           Else
                              If Res = 0 Then
                                 Begin
                                    DoInfo(siClose, 'Socket Disconnected On Receive');
                                    Close;
                                    If Assigned(FOnDisconnect) Then
                                       FOnDisconnect(Self);
                                 End;
                        End;
                  End;
               Result := FInBuffer;
               FInBuffer := '';
               Dispose(FDSet);
               Dispose(TV);
            End
         Else
            Begin
               If((Count<>-1) And (Length(FInBuffer)>Count)) Then
                  Begin
                     Result := Copy(FInBuffer, 1, Count);
                     Delete(FInBuffer, 1, Count);
                  End
               Else
                  Begin
                     Result := FInBuffer;
                     FInBuffer := '';
                  End;
            End;
      End
   Else
      Result := ReceiveDatagram(HostN);
End;

Function TSock.ReceiveLine : String;
Var CPos, CLen : LongInt;
    Temp       : String;
Begin
   CPos := 0;
   Result := '';
   If FSocketType = stStream Then
      Begin
         If(FBlocking And FConnected) Then
            Begin
               Temp := FInBuffer;
               Temp := Temp + Receive;
               FInBuffer := Temp;
            End;
         If (FLastChar = #13) And (FLineBreak = lbSmart) And (FInBuffer[1] = #10) Then
            Begin
               Delete(FInBuffer, 1, 1);
               FLastChar := #0;
            End;
         Case FLineBreak Of
            lbCR    : CPos := Pos(#13, FInBuffer);
            lbLF    : CPos := Pos(#10, FInBuffer);
            lbCRLF  : CPos := Pos(#13#10, FInBuffer);
            lbSmart : Begin
                         CPos := Pos(#13, FInBuffer);
                         If Pos(#10, FInBuffer) < CPos Then
                            CPos := Pos(#10, FInBuffer);
                         If CPos > 0 Then
                            FLastChar := FInBuffer[CPos]
                         Else
                            FLastChar := #0;
                      End;
         End;
         If FLineBreak = lbCRLF Then
            CLen := 2
         Else
            CLen := 1;
         If (CPos > 0) Or (Not FConnected) Then
            Begin
               If CPos > 0 Then
                  Begin
                     Result := Copy(FInBuffer, 1, CPos-1);
                     Delete(FInBuffer, 1, CPos+(CLen-1));
                  End
               Else
                  Begin
                     Result := FInBuffer;
                     FInBuffer := '';
                  End;
            End;
      End
   Else
      Result := Receive;
End;

Function TSock.SendDatagram(Value, HostName : String) : Boolean;
Begin
   If FSocket = INVALID_SOCKET Then
      Raise ESockException.Create('SendDatagram - Socket Not Connected');
   If FSocketType = stStream Then
      Raise ESockException.Create('SendDatagram - Datagram Send Not Supported On Stream Sockets');
   Result := True;
   SetHostName(HostName);
   If Value = '' Then
      Exit;
   WinSock.SendTo(FSocket, Value[1], Length(Value), 0, FSockAddrIn, SizeOf(TSockAddrIn));
End;

Function TSock.ReceiveDatagram(Var HostName : String) : String;
Var Res   : Integer;
    FDSet : PFDSet;
    TV    : PTimeVal;
    FLen  : Integer;
Begin
   If FSocket = INVALID_SOCKET Then
      Raise ESockException.Create('ReceiveDatagram - Socket Not Connected');
   If FSocketType = stStream Then
      Raise ESockException.Create('ReceiveDatagram - Datagram Receive Not Supported On Stream Sockets');
   FDSet := New(PFDSet);
   FDSet^.FD_Count := 1;
   FDSet^.FD_Array[0] := FSocket;
   Result := '';
   HostName := '';
   If FBlockTime >= 0 Then
      Begin
         TV := New(PTimeVal);
         TV^.tv_sec := FBlockTime;
      End
   Else
      TV := Nil;
   If WinSock.Select(FSocket, FDSet, Nil, Nil, TV) > 0 Then
      Begin
         Res := WinSock.RecvFrom(FSocket, FCharBuf, SizeOf(FCharBuf), 0, FRecvAddrIn, FLen);
         If Res > 0 Then
            Begin
               Result := Copy(FCharBuf, 1, Res);
               HostName := GetRemoteHost;
            End
      End;
   Dispose(FDSet);
   Dispose(TV);
End;

Function TSock.Accept(Var NewSock : TSock) : Boolean;
Var AcSck : TSocket;
    AddrL : Integer;
    Addr  : TSockAddrIn;
Begin
   // Accept Creates A New Instance Of A TSock Component And Returns It To The
   // User Application.  The User Is Responsible For Freeing The Component.
   If Not FListen Then
      Raise ESockException.Create('Accept - Socket Not In Listening Mode');
   If FBlocking Then
      DoInfo(SiAccept, 'Blocking Accept');
   AddrL := SizeOf(Addr);
{$IFDEF VER100}
   AcSck := WinSock.Accept(FSocket, @Addr, @AddrL);
{$ELSE}
   AcSck := WinSock.Accept(FSocket, Addr, AddrL);
{$ENDIF}
   FRecvAddrIn := Addr;
   If AcSck <> INVALID_SOCKET Then
      Begin
         NewSock := TSock.CreateWithSocket(Self, AcSck);
         NewSock.PortName := FPortName;
         NewSock.HostName := INet_NToA(Addr.SIn_Addr);
         Result := True;
         DoInfo(SiAccept, 'Created New TSock Structure');
      End
   Else
      Begin
         Result := False;
         DoInfo(SiAccept, 'Could Not Accept Connection');
      End;
End;

Function TSock.HostLookup(Value : String) : TInAddr;
Type PLongInt = ^LongInt;
Var PHost : PHostEnt;
    Res   : Integer;
Begin
   If Value = '' Then
      Exit;
   DoInfo(SiLookUp, 'Lookup Of Host '+Value);
   FillChar(Result, SizeOf(TInAddr), #0);
   If Pos(Value[1],'0123456789') > 0 Then
      // If It's Dot-Notation, Just Convert It From An IP Address
      Result := TInAddr(WinSock.Inet_Addr(PChar(Value)))
   Else
      Begin
         Res := IPCache.IndexOf(Value);
         If Res >= 0 Then
            // It's Cached... Don't Bother Doing A Lookup
            Result.S_Addr := U_Long(IPCache.Objects[Res])
         Else
            Begin
               // Isn't Cached, Have To Do A GetHostByName
               If Value <> '' Then
                  Begin
                     PHost := WinSock.GetHostByName(PChar(Value));
                     If PHost <> Nil Then
                        Begin
                           Result.S_Addr := LongInt(PLongInt(PHost^.H_Addr_List^)^);
                           IPCache.AddObject(Value, Pointer(Result.S_Addr));
                        End
                     Else
                        Raise ESockException.Create('Host Lookup - Could Not Find Host Entry');
                  End
               Else
                  Result.S_Addr := HToNL(INADDR_ANY);
            End;
      End;
End;

Function TSock.PortLookup(Value : String) : U_Short;
Var PEnt : PServEnt;
    Prot : String;
Begin
   DoInfo(SiLookUp, 'Lookup Of Port '+Value);
   If Pos(Value[1],'0123456789') > 0 Then
      // It's Numeric, Just Convert It To A Network Byte Order Integer
      Result := HToNS(StrToInt(Value))
   Else
      Begin
         // Otherwise, Perform A GetServByName Based On The Protocol
         If FSocketType = stStream Then
            Prot := 'tcp'
         Else
            Prot := 'udp';
         PEnt := WinSock.GetServByName(PChar(Value), PChar(Prot));
         If PEnt <> Nil Then
            Result := PEnt^.S_Port
         Else
            Raise ESockException.Create('Port Lookup - Could Not Find Service Entry');
      End;
End;

Function TSock.StartListen : Boolean;
Begin
   SetListen(True);
   Result := FListen;
End;

Function TSock.StopListen : Boolean;
Begin
   Result := True;
   SetListen(False);
End;

//*** Additional General-Purpose Support Functions *****************************

Function WSDescription : String;
Begin
   Result := StrPas(WSAData.szDescription);
End;

Function WSSystemStatus : String;
Begin
   Result := StrPas(WSAData.szSystemStatus);
End;

Function SocketInfoText(Value : TSocketInfo) : String;
Begin
   Result := SocketInfoMsg[Value];
End;

Function ErrToStr(Value : Integer) : String;
Begin
   Result := 'UNKNOWN ERROR';
   Case Value Of
      WSABASEERR+4 : Result := 'WSAEINTR';
      WSABASEERR+9 : Result := 'WSAEBADF';
      WSABASEERR+13 : Result := 'WSAEACCES';
      WSABASEERR+14 : Result := 'WSAEFAULT';
      WSABASEERR+22 : Result := 'WSAEINVAL';
      WSABASEERR+24 : Result := 'WSAEMFILE';
      WSABASEERR+35 : Result := 'WSAEWOULDBLOCK';
      WSABASEERR+36 : Result := 'WSAEINPROGRESS';
      WSABASEERR+37 : Result := 'WSAEALREADY';
      WSABASEERR+38 : Result := 'WSAENOTSOCK';
      WSABASEERR+39 : Result := 'WSAEDESTADDRREQ';
      WSABASEERR+40 : Result := 'WSAEMSGSIZE';
      WSABASEERR+41 : Result := 'WSAEPROTOTYPE';
      WSABASEERR+42 : Result := 'WSAENOPROTOOPT';
      WSABASEERR+43 : Result := 'WSAEPROTONOSUPPORT';
      WSABASEERR+44 : Result := 'WSAESOCKTNOSUPPORT';
      WSABASEERR+45 : Result := 'WSAEOPNOTSUPP';
      WSABASEERR+46 : Result := 'WSAEPFNOSUPPORT';
      WSABASEERR+47 : Result := 'WSAEAFNOSUPPORT';
      WSABASEERR+48 : Result := 'WSAEADDRINUSE';
      WSABASEERR+49 : Result := 'WSAEADDRNOTAVAIL';
      WSABASEERR+50 : Result := 'WSAENETDOWN';
      WSABASEERR+51 : Result := 'WSAENETUNREACH';
      WSABASEERR+52 : Result := 'WSAENETRESET';
      WSABASEERR+53 : Result := 'WSAECONNABORTED';
      WSABASEERR+54 : Result := 'WSAECONNRESET';
      WSABASEERR+55 : Result := 'WSAENOBUFS';
      WSABASEERR+56 : Result := 'WSAEISCONN';
      WSABASEERR+57 : Result := 'WSAENOTCONN';
      WSABASEERR+58 : Result := 'WSAESHUTDOWN';
      WSABASEERR+59 : Result := 'WSAETOOMANYREFS';
      WSABASEERR+60 : Result := 'WSAETIMEDOUT';
      WSABASEERR+61 : Result := 'WSAECONNREFUSED';
      WSABASEERR+62 : Result := 'WSAELOOP';
      WSABASEERR+63 : Result := 'WSAENAMETOOLONG';
      WSABASEERR+64 : Result := 'WSAEHOSTDOWN';
      WSABASEERR+65 : Result := 'WSAEHOSTUNREACH';
      WSABASEERR+66 : Result := 'WSAENOTEMPTY';
      WSABASEERR+67 : Result := 'WSAEPROCLIM';
      WSABASEERR+68 : Result := 'WSAEUSERS';
      WSABASEERR+69 : Result := 'WSAEDQUOT';
      WSABASEERR+70 : Result := 'WSAESTALE';
      WSABASEERR+71 : Result := 'WSAEREMOTE';
      WSABASEERR+91 : Result := 'WSASYSNOTREADY';
      WSABASEERR+92 : Result := 'WSAVERNOTSUPPORTED';
      WSABASEERR+93 : Result := 'WSANOTINITIALISED';
      WSABASEERR+101 : Result := 'WSAEDISCON';
      WSABASEERR+1001 : Result := 'WSAHOST_NOT_FOUND';
      WSABASEERR+1002 : Result := 'WSATRY_AGAIN';
      WSABASEERR+1003 : Result := 'WSANO_RECOVERY';
      WSABASEERR+1004 : Result := 'WSANO_DATA';
   End;
End;

// Base-64 Encoding Is The Process Of Taking An Input Stream And Converting
// Every 3 Bytes Into 4 Bytes, Each Of Which Whose ASCII Value Fits Within
// A 64-Bit Range.  Base-64 Is Often Used For Encoding Binary Streams For
// Attaching To Email, But Is Perfect For Converting Binary To A Character
// Set That Can Be Used For URL-Encoding.  The Base-64 Character Set Does Not
// Include Characters That URLs Use For Delimiting Such As '=', '&', Carriage
// Returns, Etc...

Function Base64Encode(Value : String) : String;
Var AIn   : Array[1..3] Of Byte;
    AOut  : Array[1..4] Of Byte;
    AWork : Array[1..3] Of Byte;
    I : Integer;
    O : LongInt;
Begin
   Result := '';
   I := 1;
   O := Length(Value);
   Case Length(Value) Mod 3 Of
      1 : Value := Value + #0 + #0;
      2 : Value := Value + #0;
   End;
   While I < Length(Value) Do
      Begin
         AIn[1] := Byte(Value[I]);
         AIn[2] := Byte(Value[I+1]);
         AIn[3] := Byte(Value[I+2]);

         AOut[1] := Byte(AIn[1] Shr 2);
         AWork[1] := Byte(AIn[1] Shl 4);
         AWork[2] := Byte(AWork[1] And $30);
         AWork[3] := Byte(AIn[2] Shr 4);
         AOut[2] := Byte(AWork[2] Or AWork[3]);
         AWork[1] := Byte(AIn[2] Shl 2);
         AWork[2] := Byte(AWork[1] And $3C);
         AWork[3] := Byte(AIn[3] Shr 6);
         AOut[3] := Byte(AWork[2] Or AWork[3]);
         AOut[4] := Byte(AIn[3] And $3F);

         Inc(I, 3);
         Result := Result + Base64Table[AOut[1]+1] + Base64Table[AOut[2]+1] + Base64Table[AOut[3]+1] + Base64Table[AOut[4]+1];
      End;
   If O Mod 3 > 0 Then
      Result[Length(Result)] := '=';
   If O Mod 3 = 1 Then
      Result[Length(Result)-1] := '=';
End;

Function Base64Decode(Value : String) : String;
Var AIn   : Array[1..4] Of Byte;
    AOut  : Array[1..3] Of Byte;
    AWork : Array[1..3] Of Byte;
    I : Integer;
    C : Integer;
Begin
   Result := '';
   I := 1;
   While I < Length(Value) Do
      Begin
         C := 3;
         FillChar(AWork, SizeOf(AWork), #0);
         FillChar(AOut, SizeOf(AWork), #0);
         AIn[1] := Byte(Pos(Value[I],Base64Table)-1);
         AIn[2] := Byte(Pos(Value[I+1],Base64Table)-1);
         AIn[3] := Byte(Pos(Value[I+2],Base64Table)-1);
         AIn[4] := Byte(Pos(Value[I+3],Base64Table)-1);
         If Value[I+3]='=' Then
            Begin
               C := 2;
               AIn[4] := 0;
               If Value[I+2]='=' Then
                  Begin
                     C := 1;
                     AIn[3] := 0;
                  End;
            End;
         AWork[2] := Byte(AIn[1] Shl 2);
         AWork[3] := Byte(AIn[2] Shr 4);
         AOut[1] := Byte(AWork[2] Or AWork[3]);
         AWork[2] := Byte(AIn[2] Shl 4);
         AWork[3] := Byte(AIn[3] Shr 2);
         AOut[2] := Byte(AWork[2] Or AWork[3]);
         AWork[2] := Byte(AIn[3] Shl 6);
         AOut[3] := Byte(AWork[2] Or AIn[4]);
         Result := Result + Char(AOut[1]);
         If C > 1 Then
            Result := Result + Char(AOut[2]);
         If C > 2 Then
            Result := Result + Char(AOut[3]);
         Inc(I, 4);
      End;
End;

Function URLEncode(Value : String) : String;
Var I : Integer;
Begin
   Result := '';
   For I := 1 To Length(Value) Do
      Begin
         If Pos(UpperCase(Value[I]), ValidURLChars) > 0 Then
            Result := Result + Value[I]
         Else
            Begin
               If Value[I] = ' ' Then
                  Result := Result + '+'
               Else
                  Begin
                     Result := Result + '%';
                     Result := Result + IntToHex(Byte(Value[I]), 2);
                  End;
            End;
      End;
End;

Function URLDecode(Value : String) : String;
Const HexChars = '0123456789ABCDEF';
Var I        : Integer;
    Ch,H1,H2 : Char;
Begin
   Result := '';
   I := 1;
   While I <= Length(Value) Do
      Begin
         Ch := Value[I];
         Case Ch Of
            '%' : Begin
                     H1 := Value[I+1];
                     H2 := Value[I+2];
                     Inc(I, 2);
                     Result := Result + Chr(((Pos(H1, HexChars) - 1) * 16) + (Pos(H2, HexChars) - 1));
                  End;
            '+' : Result := Result + ' ';
            '&' : Result := Result + #13+#10;
            Else Result := Result + Ch;
         End;
         Inc(I);
      End;
End;

//*** Registration And Initialization ******************************************

Procedure Register;
Begin
   RegisterComponents('Beach Dog', [TSock]);
End;

Initialization
   // We're Looking To Use Version 1.1 Of WinSock Here
   If WinSock.WSAStartup($0101, WSAData) <> 0 Then
      Raise ESockException.Create('WSAStartup - Could Not Initialize WinSock');
   IPCache := TStringList.Create;
   IPCache.Clear;
Finalization
   IPCache.Free;
   WinSock.WSACleanup;
End.
