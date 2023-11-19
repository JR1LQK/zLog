unit UAPSprintScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, Aligrid, StdCtrls, ExtCtrls, zLogGlobal;

type
  TAPSprintScore = class(TBasicScore)
    Grid: TStringAlignGrid;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Reset; override;
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
  end;

var
  APSprintScore: TAPSprintScore;

implementation

uses UWPXMulti;

{$R *.DFM}

procedure TAPSprintScore.Reset;
var band : TBand;
begin
  for band := b19 to HiBand do
    begin
      QSO[band] := 0;
      Points[band] := 0;
    end;
end;

procedure TAPSprintScore.AddNoUpdate(var aQSO : TQSO);
var P : integer;
    band : TBand;
begin
  inherited;

  if aQSO.QSO.Dupe then
    exit;

  aQSO.QSO.Points := 1;
  inc(Points[aQSO.QSO.Band]);
end;

procedure TAPSprintScore.Update;
var TotPts : LongInt;
begin
  TotPts := 0;
  Grid.Cells[1, 1] := IntToStr(Points[b7]);
  Grid.Cells[1, 2] := IntToStr(Points[b14]);
  Grid.Cells[1, 3] := IntToStr(Points[b21]);
  TotPts := Points[b7] + Points[b14] + Points[b21];
  Grid.Cells[1, 4] := IntToStr(TotPts);
  Grid.Cells[1, 5] := IntToStr(WPXMulti.TotalPrefix);
  Grid.Cells[1, 6] := IntToStr(TotPts*WPXMulti.TotalPrefix);
end;

procedure TAPSprintScore.FormShow(Sender: TObject);
begin
  inherited;
  Grid.Col := 1;
  Grid.Row := 1;
end;

end.
