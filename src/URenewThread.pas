unit URenewThread;

interface

uses
  Classes, zLogGlobal;

type
  TRenewThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure SyncProc;
    procedure Execute; override;
  end;

procedure RequestRenewThread;

const Renewing : boolean = False;

implementation

uses Main;
{ Important: Methods and properties of objects in VCL can only be used in a
  method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TRenewThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TRenewThread }

procedure TRenewThread.SyncProc;
var boo : boolean;
begin
  Main.MyContest.MultiForm.Update;
  Main.MyContest.ScoreForm.Update;
  boo := false;
  if MainForm.Grid.Focused then
    boo := True;
  MainForm.EditScreen.Renew;
  MainForm.ReevaluateCountDownTimer;
  MainForm.ReevaluateQSYCount;

  if boo then
    MainForm.Grid.SetFocus;
end;

procedure TRenewThread.Execute;
var i, j : integer;
    aQSO : TQSO;
begin
  FreeOnTerminate := True;

  Repeat until
    Renewing = False;

  Renewing := True;

  Log.SetDupeFlags;

  for i := 1 to Log.TotalQSO do
    begin
      aQSO := TQSO(Log.List[i]);
      if Log.CountHigherPoints = True then
        j := Log.IsDupe(aQSO); // called to set log.differentmodepointer
      Main.MyContest.MultiForm.AddNoUpdate(aQSO);
      Main.MyContest.ScoreForm.AddNoUpdate(aQSO);
    end;

  Synchronize(SyncProc);
  Renewing := False;
  { Place thread code here }
end;

procedure RequestRenewThread;
var RTh : TRenewThread;
begin
  Main.MyContest.MultiForm.Reset;
  Main.MyContest.ScoreForm.Reset;
  RTh := TRenewThread.Create(False);
end;

end.
