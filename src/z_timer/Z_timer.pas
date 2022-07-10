// ZTimer component, by Antonie Baars
// email d950021@icpc00.icpc.fukui-u.ac.jp

unit Z_timer;

interface
uses classes,windows,messages,forms;

TYPE

TZTimer = class(Tcomponent)
 private
    FOnTimer: TNotifyEvent;
    FEnabled: Boolean;
    fcount,FInterval,ftimeout,ReqToStop:integer;
    FWindowHandle: HWND;
    procedure UpdateTimer;
    procedure SetEnabled(Value: Boolean);
    procedure SetInterval(Value: extended);
    function  getinterval:extended;
    procedure SetOnTimer(Value: TNotifyEvent);
    procedure Timerloop;
    procedure WndProc(var Msg: TMessage);
  protected
    procedure Timer;virtual;
  public
    property count :integer read fcount;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Interval: extended read getInterval write SetInterval;
    property OnTimer: TNotifyEvent read FOnTimer write SetOnTimer;
    property TimeoutSeconds:integer read ftimeout write ftimeout;
  end;

procedure Register;

implementation

const      WM_PACER:integer=WM_USER+202;

procedure Register;
begin
  RegisterComponents('Samples', [TZTimer]);
end;

constructor TZTimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnabled := false;
  FInterval := 1000;
  ftimeout:=10;
  FWindowHandle := AllocateHWnd(WndProc);
end;

destructor TZTimer.Destroy;
begin
  FEnabled := False;
  updatetimer;
  DeallocateHWnd(FWindowHandle);
  inherited Destroy;
end;
procedure TZTimer.WndProc(var Msg: TMessage);
begin
  with Msg do
    if Msg = WM_PACER then
      try
        Timerloop;
      except
        Application.HandleException(Self);
      end
    else
      Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);
end;

procedure TZTimer.UpdateTimer;
begin
reqtostop:=1;                                   // break out current loop
if (FInterval <> 0) and FEnabled and Assigned(FOnTimer)
   and not (csdesigning in componentstate) then
   postmessage(fwindowhandle,WM_PACER,0,0);     // start new run after cleanup
end;


procedure TZTimer.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    UpdateTimer;
  end;
end;

procedure TZTimer.SetInterval(Value: extended);
begin
    FInterval := round(Value*10);
    if finterval<1 then finterval:=1;
    UpdateTimer;
end;
function TZTimer.getInterval: extended;
begin
result:=FInterval/10;
end;
procedure TZTimer.SetOnTimer(Value: TNotifyEvent);
begin
  FOnTimer := Value;
  UpdateTimer;
end;

procedure TZTimer.Timer;
begin
  if Assigned(FOnTimer) then FOnTimer(Self);
end;
procedure TZTimer.Timerloop;
label again;
var sampletime,timeout,areqtostop:integer;
begin
sampletime:=round(finterval/0.1509);
timeout:=trunc(1e4*ftimeout/finterval);
reqtostop:=0;
fcount:=0;
{$IFDEF WIN32}
SetPriorityClass(GetCurrentProcess(),REALTIME_PRIORITY_CLASS);
{$ENDIF}
asm
        in   al,61h
        and  al,0010000b
        mov  ah,al
again:  mov  ecx,sampletime
@wait:  in   al,61h
        and  al,0010000b
        cmp  al,ah
        je   @wait         // wait for levelchange
        mov  ah,al
        dec  ecx
        jnz  @wait
        push ax
        end;
        inc(fcount);
        timer ;        // perform ontimer event
        if fcount>timeout then reqtostop:=1;
        areqtostop:=reqtostop;
        asm
        pop ax
        cmp  areqtostop,0
        jz   again
        end;
{$IFDEF WIN32}
SetPriorityClass(GetCurrentProcess(),NORMAL_PRIORITY_CLASS);
{$ENDIF}
end;


end.
