unit UKCJScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, Aligrid, StdCtrls, ExtCtrls, zLogGlobal, Buttons;

type
  TKCJScore = class(TBasicScore)
    Grid: TStringAlignGrid;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
  end;

var
  KCJScore: TKCJScore;

implementation

{$R *.DFM}

procedure TKCJScore.AddNoUpdate(var aQSO : TQSO);
var band : TBand;
begin
  inherited;

  if aQSO.QSO.Dupe then
    exit;

  band := aQSO.QSO.band;
  //aQSO.QSO.points := 1;

  if pos(aQSO.QSO.NrRcvd+'$', 'AS$NA$SA$EU$AF$OC$') > 0 then
    aQSO.QSO.Points := 5
  else
    aQSO.QSO.Points := 1;

  inc(Points[band], aQSO.QSO.Points);
end;

procedure TKCJScore.Update;
var band : TBand;
    TotPoints, TotMulti : LongInt;
    row : integer;
begin
  TotPoints := 0; TotMulti := 0;
  row := 1;
  for band := b19 to b50 do
    begin
      if NotWARC(band) then
        begin
          Grid.Cells[1,row] := IntToStr(Points[band]);
          TotPoints := TotPoints + Points[band];
          Grid.Cells[2,row] := IntToStr(Multi[band]);
          TotMulti := TotMulti + Multi[band];
          inc(row);
        end;
    end;
  Grid.Cells[1, 8] := IntToStr(TotPoints);
  Grid.Cells[2, 8] := IntToStr(TotMulti);
  Grid.Cells[2, 9] := IntToStr(TotPoints*TotMulti);
end;


end.
