unit UBGKMonitorThread;

interface

uses
  Classes, BGK32LIB, Windows, Main;

type
  TBGKMonitorThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create;
    procedure DotheJob;
  end;

var BGKMonitorThread : TBGKMonitorThread;

implementation

{ Important: Methods and properties of objects in VCL can only be used in a
  method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TBGKMonitorThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TBGKMonitorThread }

constructor TBGKMonitorThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(False);
end;

procedure TBGKMonitorThread.DotheJob;
begin
  MainForm.CallsignSentProc;
end;

procedure TBGKMonitorThread.Execute;
begin
  repeat
    SleepEx(2, False);
    if BGK32Lib.CallsignSent then
      begin
        Synchronize(DotheJob);
      end;
    //PaddleProcess;
  until Terminated;
end;

initialization
  //BGKMonitorThread := nil;
  BGKMonitorThread := TBGKMonitorThread.Create;
end.
