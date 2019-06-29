unit UARRLDXScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, Aligrid, StdCtrls, ExtCtrls, zLogGlobal;

type
  TARRLDXScore = class(TBasicScore)
    Grid: TStringAlignGrid;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Renew; override;
    procedure Reset; override;
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
    procedure CalcPoints(var aQSO : TQSO); virtual;
  end;

var
  ARRLDXScore: TARRLDXScore;

implementation

{$R *.DFM}

procedure TARRLDXScore.Renew;
var i : word;
    band : TBand;
begin
  Reset;
  for i := 1 to Log.TotalQSO do
    begin
      band := TQSO(Log.List[i]).QSO.band;
      inc(QSO[band]);
      inc(Points[band],TQSO(Log.List[i]).QSO.Points);
      if TQSO(Log.List[i]).QSO.NewMulti1 then
        inc(Multi[band]);
    end;
end;

procedure TARRLDXScore.Reset;
var band : TBand;
begin
  for band := b19 to HiBand do
    begin
      QSO[band] := 0;
      CWQSO[band] := 0;
      Points[band] := 0;
      Multi[band] := 0;
    end;
end;

procedure TARRLDXScore.CalcPoints(var aQSO : TQSO);
begin
  aQSO.QSO.Points := 3;
end;

procedure TARRLDXScore.AddNoUpdate(var aQSO : TQSO);
begin
  inherited;

  if aQSO.QSO.Dupe then
    exit;

  CalcPoints(aQSO);
  inc(Points[aQSO.QSO.Band], aQSO.QSO.Points);
end;

procedure TARRLDXScore.Update;
var band : TBand;
    TotQSO, TotPts, TotMulti : LongInt;
    row : integer;
begin
  TotQSO := 0; TotPts := 0; TotMulti := 0;
  row := 1;
  for band := b19 to b28 do
    begin
      if NotWARC(band) then
        begin
          Grid.Cells[1,row] := IntToStr(QSO[band]);
          TotQSO := TotQSO + QSO[band];
          Grid.Cells[2,row] := IntToStr(Points[band]);
          TotPts := TotPts + Points[band];
          Grid.Cells[3,row] := IntToStr(Multi[band]);
          TotMulti := TotMulti + Multi[band];
          inc(row);
        end;
    end;
  Grid.Cells[1, 7] := IntToStr(TotQSO);
  Grid.Cells[2, 7] := IntToStr(TotPts);
  Grid.Cells[3, 7] := IntToStr(TotMulti);
  Grid.Cells[3, 8] := IntToStr(TotPts*TotMulti);
end;

end.
