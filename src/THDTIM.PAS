unit ThdTim;

interface

uses
  Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs;

type
  TThreadedTimer = class;

  TTimerThread = class(TThread)
    OwnerTimer: TThreadedTimer;
    procedure Execute; override;
    procedure DoTimer;
  end;

  TThreadedTimer = class(TComponent)
  private
    FEnabled: Boolean;
    FInterval: Word;
    FOnTimer: TNotifyEvent;
    FTimerThread: TTimerThread;
    FThreadPriority: TThreadPriority;
  protected
    procedure UpdateTimer;
    procedure SetEnabled(Value: Boolean);
    procedure SetInterval(Value: Word);
    procedure SetOnTimer(Value: TNotifyEvent);
    procedure SetThreadPriority(Value: TThreadPriority);
    procedure Timer; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Enabled: Boolean
      read FEnabled
      write SetEnabled
      default True;
    property Interval: Word
      read FInterval
      write SetInterval
      default 1000;
    property OnTimer: TNotifyEvent
      read FOnTimer
      write SetOnTimer;
    property ThreadPriority: TThreadPriority
      read FThreadPriority
      write SetThreadPriority;
  end;

procedure Register;

implementation

procedure
TTimerThread.Execute;
begin
  Priority := OwnerTimer.FThreadPriority;
  repeat
    SleepEx(OwnerTimer.FInterval, False);
    Synchronize(DoTimer);
  until Terminated;
end;

procedure
TTimerThread.DoTimer;
begin
  OwnerTimer.Timer;
end;

constructor
TThreadedTimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnabled := True;
  FInterval := 1000;
  FThreadPriority := tpNormal;
  FTimerThread := TTimerThread.Create(False);
  FTimerThread.OwnerTimer := Self;
end;

destructor
TThreadedTimer.Destroy;
begin
  FEnabled := False;
  UpdateTimer;
  FTimerThread.Free;
  inherited Destroy;
end;

procedure
TThreadedTimer.UpdateTimer;
begin
  FTimerThread.Suspend;
  if (FInterval <> 0) and FEnabled
    and Assigned(FOnTimer) then
      FTimerThread.Resume;
end;

procedure
TThreadedTimer.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    UpdateTimer;
  end;
end;

procedure
TThreadedTimer.SetInterval(Value: Word);
begin
  if Value <> FInterval then
  begin
    FInterval := Value;
    UpdateTimer;
  end;
end;

procedure
TThreadedTimer.SetOnTimer(Value: TNotifyEvent);
begin
  FOnTimer := Value;
  UpdateTimer;
end;

procedure
TThreadedTimer.SetThreadPriority(Value: TThreadPriority);
begin
  if Value <> FThreadPriority then
  begin
    FThreadPriority := Value;
    UpdateTimer;
  end;
end;

procedure
TThreadedTimer.Timer;
begin
  if Assigned(FOnTimer) then
    FOnTimer(Self);
end;

procedure Register;
begin
  RegisterComponents('Samples', [TThreadedTimer]);
end;

end.
 