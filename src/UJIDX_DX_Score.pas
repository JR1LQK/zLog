unit UJIDX_DX_Score;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, StdCtrls, ExtCtrls, Grids, Aligrid, zLogGlobal, Buttons;

type
  TJIDX_DX_Score = class(TBasicScore)
    Grid: TStringAlignGrid;
  private
    { Private declarations }
  public
    procedure Renew; override;
    procedure Reset; override;
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
    procedure CalcPoints(var aQSO : TQSO); virtual;
    { Public declarations }
  end;

var
  JIDX_DX_Score: TJIDX_DX_Score;

implementation

{$R *.DFM}

procedure TJIDX_DX_Score.Renew;
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

procedure TJIDX_DX_Score.Reset;
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

procedure TJIDX_DX_Score.CalcPoints(var aQSO : TQSO);
begin
  case aQSO.QSO.Band of
    b19 : aQSO.QSO.Points := 4;
    b35 : aQSO.QSO.Points := 2;
    b7..b21 : aQSO.QSO.Points := 1;
    b28 : aQSO.QSO.Points := 2;
  else
    aQSO.QSO.Points := 0;
  end;
end;

procedure TJIDX_DX_Score.AddNoUpdate(var aQSO : TQSO);
begin
  inherited;
  if aQSO.QSO.Dupe then
    exit;
  CalcPoints(aQSO);
  inc(Points[aQSO.QSO.Band], aQSO.QSO.Points);
end;

procedure TJIDX_DX_Score.Update;
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
