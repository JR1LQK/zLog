{********************************************************}
{*                                                      *}
{*             Copyright (c) Dan Daley 1996             *}
{*             Contact: daley@guernsey.com              *}
{*                 URL: http://www.guernsey.com         *}
{*                                                      *}
{*  This code is provided as is for your use.  It may   *}
{*  be modified and redistributed.  All I ask is that   *}
{*  any modifications be described in this header and   *}
{*  that you provide a means for others to contact you  *}
{*  regarding your modifications.                       *}
{*                                                      *}
{*  This code is not to be sold and must be distributed *}
{*  for free.                                           *}
{*                                                      *}
{********************************************************}
unit WThread;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

const
  WM_SafeExec = WM_User + 1;
  WM_ThreadTerm = WM_User + 2;
  WM_ThreadException = WM_User + 3;

type
  TWinThread = class;

  { TWinThreadParam is passed as an argument to your thread procedure }
  TWinThreadParam = record
    ThreadComp: TWinThread; { a pointer to the thread component that created you }
    ThreadParam: pointer;   { a pointer to the parameter you passed to spawn }
    ThreadHandle: THandle;  { your thread handle }
  end;

  TSafeExecCode = procedure (Param: LongInt) of object;
  TWinThreadEvent = function(Sender: TComponent; ThreadInfo: TWinThreadParam): THandle of Object;

  { TWinThreadInfo is used by start thread to execute your thread code }
  TWinThreadInfo = record
    ThreadComp: TWinThread;
    ThreadProc: TWinThreadEvent;
    ThreadParam: pointer;
    ThreadHandle: THandle;
    SpawnEvent: THandle;
    UserThread: Boolean;
  end;

  TWinThreadException = procedure(Sender: TComponent; ThreadInfo: TWinThreadInfo; E:Exception) of Object;

  TWinThread = class(TCustomControl)
  private
    { Private declarations }
    FAttributes: DWORD;
    FCallOnKill: Boolean;
    FDestroying: Boolean;
    FKilling: Boolean;
    FSafeExecCode: TSafeExecCode;
    FSecurity: ^TSecurityAttributes;
    FSpawnEvent: THandle;
    FSpawnMutex: THandle;
    FStackSize: LongInt;
    FThreadHandles: TList;
    FWaitWinThreadHandles: TList;
    FTimeOut: LongInt;
    FThreadException: TWinThreadException;
    FThreadProc: TWinThreadEvent;
    FThreadTerminateEvent: TWinThreadEvent;
    function WaitWinThread(Sender: TComponent; aThreadInfo: TWinThreadParam): THandle;
    function GetCount: LongInt;
    procedure WMSafeExec(var aMsg: TMessage); message WM_SafeExec;
    procedure WMThreadTerm(var aMsg: TMessage); message WM_ThreadTerm;
    procedure WMThreadException(var aMsg: TMessage); message WM_ThreadException;
  protected
    procedure Paint; override;
    function GetPriority(Index: Integer): LongInt;
    procedure SetPriority(Index: Integer; Value: LongInt);
    procedure Loaded; override;
    procedure LockHandles; virtual;
    procedure ReleaseHandles; virtual;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  public
    constructor Create(AComponent: TComponent); override;
    destructor Destroy; override;
    function SpawnThread(Param: pointer): THandle; { Spawn a new thread passing it Param as a parameter }
    function CanClose: Boolean;
    function KillThreads: Boolean; { destroy all threads }
    procedure SafeExec(Param: LongInt); { execute SafeExecCode in main process space using PostMessage }
    procedure WaitExec(Param: LongInt); { execute SafeExecCode in main process space using SendMessage }
    procedure Wait; { wait for all threads to terminate }
    function WaitWithTimeOut(aTimeOut: DWord): DWord;
//    property Security: ^TSecurityAttributes read FSecurity write FSecurity default;
    property Count: LongInt read GetCount; { return the number of active threads }
    property Destroying: Boolean read FDestroying;
    property Killing: Boolean read FKilling;
    property Priority[Index: Integer]: LongInt read GetPriority write SetPriority;
  published
    property Attributes: DWORD read FAttributes write FAttributes default 0;
    property CallOnKill: Boolean read FCallOnKill write FCallOnKill default False; { call ThreadTerminate code if thread is killed abnormally }
    property StackSize: LongInt read FStackSize write FStackSize default 0; { size of stack to give thread - 0 means same as exe's stack }
    property TimeOut: LongInt read FTimeOut write FTimeOut default $FFFFFFFF; { timeout is the max time for this component to wait for mutexes and events - default is infinite }
    property SafeExecCode: TSafeExecCode read FSafeExecCode write FSafeExecCode; { code that gets executed in main process space when SafeExec is call from within thread }
    property ThreadException: TWinThreadException read FThreadException write FThreadException;
    property ThreadProc: TWinThreadEvent read FThreadProc write FThreadProc; { code to execute in a separate thread when spawn is called }
    property ThreadTerminate: TWinThreadEvent read FThreadTerminateEvent write FThreadTerminateEvent; { code that is called when a thread is ends execution }
  end;

procedure Register;

implementation
var
  aBitmap: TBitmap;
  Loaded: Boolean;

procedure LoadBitmap;
begin
  if Loaded then exit;
  Loaded := True;
  if aBitmap = nil then aBitmap := TBitmap.Create;
  try
    aBitmap.LoadFromResourceName(HInstance, 'TWINTHREAD');
  except
    on E:Exception do ShowMessage(E.Message);
  end;
end;

function StartWinThread(pThreadInfo: pointer): THandle;
var
  ThreadInfo: TWinThreadInfo;
  WinThreadParam: TWinThreadParam;
begin
  ThreadInfo := TWinThreadInfo(pThreadInfo^);
  with ThreadInfo do
  begin
    WinThreadParam.ThreadComp := ThreadComp;
    WinThreadParam.ThreadParam := ThreadParam;
    WinThreadParam.ThreadHandle := ThreadHandle;

    SetEvent(SpawnEvent);
    if UserThread then SuspendThread(GetCurrentThread); // will be resumed later
    try
      ThreadProc(ThreadComp, WinThreadParam);
    except
      on E:Exception do
        SendMessage(ThreadInfo.ThreadComp.Handle, WM_ThreadException, LongInt(@ThreadInfo), LongInt(E));
    end;
  end;
end;

constructor TWinThread.Create(AComponent: TComponent);
begin
  inherited Create(AComponent);
  FDestroying := False;
  FAttributes := 0;
  FCallOnKill := False;
  FStackSize := 0;
  FKilling := False;
  FTimeOut := $FFFFFFFF;
  FSecurity := nil;
  FSpawnEvent :=
    CreateEvent(
      nil, { security object }
      False, { auto reset }
      False, { not signaled }
      'Spawn process started');
  FSpawnMutex :=
    CreateMutex(
      nil,   { security object }
      False, { initially not owned }
      nil); { Mutex name }

  FThreadHandles := TList.Create;
  FWaitWinThreadHandles := TList.Create;
  Height := 25;
  Width := 25;
end;

destructor TWinThread.Destroy;
var
  Index: LongInt;
  pThreadInfo: ^TWinThreadInfo;
  ThreadExitCode: DWord;
begin
  { kill or wait for threads }
  FDestroying := True;
  Wait;

  { make sure that no wait threads are hanging around }
  for Index := FWaitWinThreadHandles.Count - 1 downto 0 do
  begin
    pThreadInfo := FWaitWinThreadHandles[Index];
    GetExitCodeProcess(pThreadInfo^.ThreadHandle, ThreadExitCode);
    if ThreadExitCode = Still_Active then TerminateThread(pThreadInfo^.ThreadHandle, -1);
    CloseHandle(pThreadInfo^.ThreadHandle);
    FreeMem(FWaitWinThreadHandles[Index], SizeOf(TWinThreadInfo));
  end;
  FThreadHandles.Free;
  FWaitWinThreadHandles.Free;
  CloseHandle(FSpawnMutex);
  CloseHandle(FSpawnEvent);
  inherited Destroy;
end;

procedure TWinThread.Loaded;
begin
  if csDesigning in ComponentState then LoadBitmap
  else SetBounds(0,0,0,0);
  inherited Loaded;
end;

procedure TWinThread.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if csDesigning in ComponentState then
  begin
    AWidth := 25;
    AHeight := 25;
  end;
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure TWinThread.LockHandles;
begin
  if WaitForSingleObject(FSpawnMutex, INFINITE) <> Wait_Object_0 then
    raise Exception.Create('Could not obtain lock mutex');
end;

procedure TWinThread.ReleaseHandles;
begin
  ReleaseMutex(FSpawnMutex);
end;

function TWinThread.CanClose;
begin
  LockHandles;
  try
    Result := FThreadHandles.Count = 0;
  finally
    ReleaseHandles;
  end;
end;

function TWinThread.GetPriority(Index: Integer): LongInt;
begin
  { Make sure no one is modifying the thread list }
  LockHandles;
  try
    if (Index < 0) or (Index >= FThreadHandles.Count) then raise Exception.Create('Invalid thread index');
    Result := GetThreadPriority(THandle(FThreadHandles[Index]));
  finally
    ReleaseHandles;
  end;
end;

procedure TWinThread.SetPriority(Index: Integer; Value: LongInt);
begin
  { Make sure no one is modifying the thread list }
  LockHandles;
  try
    if (Index < 0) or (Index >= FThreadHandles.Count) then raise Exception.Create('Invalid thread index');
    SetThreadPriority(THandle(FThreadHandles[Index]), Value);
  finally
    ReleaseHandles;
  end;
end;

procedure TWinThread.Paint;
begin
  if csDesigning in ComponentState then
    Canvas.StretchDraw(Canvas.ClipRect, aBitmap);
  inherited Paint;
end;

function TWinThread.KillThreads: Boolean;
var
  Index: LongInt;
  pThreadInfo: ^TWinThreadInfo;
  ThreadExitCode: DWord;
  Done: Boolean;
begin
  FKilling := True;
  Result := False;
  try
    Done := False;
    while not Done do
    begin
      LockHandles;
      try
        Done := FThreadHandles.Count = 0;
        if not Done then pThreadInfo := FThreadHandles[0];
      finally
        ReleaseHandles;
      end;

      if not Done then
      begin
        GetExitCodeThread(pThreadInfo^.ThreadHandle, ThreadExitCode); // see if thread is still active
        if (ThreadExitCode = Still_Active) and not TerminateThread(pThreadInfo^.ThreadHandle, -1) then
        begin
          { if we failed to kill the thread wait 1 sec and try again }
          WaitForSingleObject(pThreadInfo^.ThreadHandle, 1000);
          GetExitCodeThread(pThreadInfo^.ThreadHandle, ThreadExitCode);
          if (ThreadExitCode = Still_Active) and not TerminateThread(pThreadInfo^.ThreadHandle, -1) then Done := True;
        end;
      end;
      { handles will be closed in WaitWinThread }
    end;

    LockHandles;
    try
      Result := (Done = True) and (FThreadHandles.Count = 0);
    finally
      ReleaseHandles;
    end;
  finally
    FKilling := False;
  end;
end;

procedure TWinThread.Wait;
begin
  WaitWithTimeOut(INFINITE);
end;

function TWinThread.WaitWithTimeOut(aTimeOut: DWord): DWord;
var
  NumObjects, Index: DWord;
  pThreadInfo: ^TWinThreadInfo;
  ThreadExitCode: DWord;
  Threads: PWOHandleArray;
begin
  Result := -100;

  LockHandles;
  try
    NumObjects := FThreadHandles.Count;
    GetMem(Threads, NumObjects * SizeOf(THandle));
    try
      for Index := NumObjects - 1 downto 0 do
      begin
        pThreadInfo := FThreadHandles[Index];
        Threads[Index] := THandle(pThreadInfo^.ThreadHandle);
      end;
      Result := WaitForMultipleObjects(NumObjects, Threads, Bool(True), aTimeOut);
    finally
      FreeMem(Threads, NumObjects * SizeOf(THandle));
      { handles will be closed in WaitWinThread }
    end;
  finally
    ReleaseHandles;
  end;
end;

function TWinThread.GetCount: LongInt;
begin
  { Make sure no one is modifying the thread list }
  LockHandles;
  try
    Result := FThreadHandles.Count;
  finally
    ReleaseHandles;
  end;
end;

procedure TWinThread.WMSafeExec(var aMsg: TMessage);
begin
  if Assigned(FSafeExecCode) then FSafeExecCode(aMsg.WParam);
end;

procedure TWinThread.WMThreadTerm(var aMsg: TMessage);
var
  WinThreadParam: TWinThreadParam;
begin
  { Thread Terminate Event is executed in main process space }
  with TWinThreadInfo(Pointer(aMsg.WParam)^) do
  begin
    WinThreadParam.ThreadComp := ThreadComp;
    WinThreadParam.ThreadParam := ThreadParam;
    WinThreadParam.ThreadHandle := ThreadHandle;
  end;

  if Assigned(FThreadTerminateEvent) then
    FThreadTerminateEvent(Self, WinThreadParam);
end;

procedure TWinThread.WMThreadException(var aMsg: TMessage);
begin
  if Assigned(FThreadException) then
    FThreadException(Self, TWinThreadInfo(Pointer(aMsg.WParam)^), Exception(Pointer(aMsg.LParam)));
end;

procedure TWinThread.SafeExec(Param: LongInt);
begin
  { Thread will not wait for main thread to process message }
  PostMessage(Handle, WM_SafeExec, Param, 0);
end;

procedure TWinThread.WaitExec(Param: LongInt);
begin
  { Thread will wait for main thread to process message }
  SendMessage(Handle, WM_SafeExec, Param, 0);
end;

function TWinThread.WaitWinThread(Sender: TComponent; aThreadInfo: TWinThreadParam): THandle;
var
  pThreadInfo: ^TWinThreadInfo;
  ThreadInfo: TWinThreadInfo;
begin
  ThreadInfo := TWinThreadInfo(aThreadInfo.ThreadParam^);
  if WaitForSingleObject(ThreadInfo.ThreadHandle, INFINITE) <> Wait_Object_0 then
     raise Exception.Create('Wait for thread failed');

  {
    if we are being destroyed or we are killing the threads do not call then OnTerminate event unless
    CallOnKill is true
  }
  if not FDestroying and Assigned(FThreadTerminateEvent) and (not FKilling or (CallOnKill and FKilling)) then
    SendMessage(Handle, WM_ThreadTerm, Cardinal(@ThreadInfo), 0);

  { remove thread from our list }
  LockHandles;
  try
    pThreadInfo := aThreadInfo.ThreadParam;
    FThreadHandles.Remove(pThreadInfo);
    CloseHandle(TWinThreadInfo(pThreadInfo^).ThreadHandle);
    FreeMem(pThreadInfo);
  finally
    ReleaseHandles;
  end;
end;

function TWinThread.SpawnThread(Param: pointer): THandle;
var
  pThreadInfo: ^TWinThreadInfo;
  pWaitWinThreadInfo: ^TWinThreadInfo;
  CreateRes: THandle;
begin
  if Assigned(FThreadProc) then
  begin
    LockHandles;
    try
      GetMem(pThreadInfo, SizeOf(TWinThreadInfo));
      FThreadHandles.Add(pThreadInfo);

      { prepare thread information to pass to thread procedure }
      with pThreadInfo^ do
      begin
        ThreadComp := self;
        ThreadProc := FThreadProc; { user procedure to execute }
        ThreadParam := Param;      { user param }
        SpawnEvent := FSpawnEvent; { event to signal when thread is spawned }
        UserThread := True;
      end;

      ResetEvent(FSpawnEvent);
      CreateRes :=
        BeginThread(
          FSecurity   {defualt security},
          FStackSize    {same stack size as exe},
          @StartWinThread  {thread routine},
          pThreadInfo   {thread param},
          FAttributes   {create attribute - create immediately},
          Result);

      if CreateRes = 0 then raise Exception.Create('Could not create thread');
      pThreadInfo^.ThreadHandle := CreateRes; { store the thread handle }

      { wait for thread to be spawned before continuing }
      if WaitForSingleObject(FSpawnEvent, FTimeOut) <> Wait_Object_0 then
        raise Exception.Create('Spawn event not triggered');

      GetMem(pWaitWinThreadInfo, SizeOf(TWinThreadInfo));
      FWaitWinThreadHandles.Add(pWaitWinThreadInfo);

      { prepare thread information for the waiting thread }
      with pWaitWinThreadInfo^ do
      begin
        ThreadComp := self;
        ThreadProc := WaitWinThread;   { thread to trigger exit procedure }
        ThreadParam := pThreadInfo; { thread info for thread to wait on }
        SpawnEvent := FSpawnEvent;  { event to trigger when thread has started }
        UserThread := False;
      end;

      ResetEvent(FSpawnEvent);
      CreateRes :=
        BeginThread(
          nil   {defualt security},
          0    {same stack size as exe},
          @StartWinThread    {thread routine},
          pWaitWinThreadInfo {thread param},
          0               {create attribute - create immediately},
          Result);

      if CreateRes = 0 then  // need to terminate the above thread as well at this point
      begin
        TerminateThread(pThreadInfo^.ThreadHandle, 0);
        raise Exception.Create('Could not create thread 2');
      end;
      pWaitWinThreadInfo^.ThreadHandle := CreateRes;

      { wait until thread has started }
      if WaitForSingleObject(FSpawnEvent, FTimeOut) <> Wait_Object_0 then
      begin  // Terminate both threads in this case
        TerminateThread(pThreadInfo^.ThreadHandle, 0);
        TerminateThread(pWaitWinThreadInfo^.ThreadHandle, 0);
        raise Exception.Create('Spawn event not triggered');
      end;

      ResumeThread(pThreadInfo^.ThreadHandle); { resume the user's thread }

      Result := pThreadInfo^.ThreadHandle;
    finally
      ReleaseHandles;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TWinThread]);
end;

initialization
  aBitmap := nil;
  Loaded := False;
finalization
  aBitmap.Free;
end.
