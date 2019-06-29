unit UJIDXScore2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, Aligrid, StdCtrls, ExtCtrls, zLogGlobal, Buttons;

type
  TJIDXScore2 = class(TBasicScore)
    Grid: TStringAlignGrid;
  private
    { Private declarations }
  public
    { Public declarations }
    Multi2 : array[b19..HiBand] of LongInt;
    constructor Create; override;
    procedure Renew; override;
    procedure Reset; override;
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
    procedure CalcPoints(var aQSO : TQSO);
  end;

var
  JIDXScore2: TJIDXScore2;

implementation

{$R *.DFM}

constructor TJIDXScore2.Create;
var band : TBand;
begin
  inherited;
  for band := b19 to HiBand do
    begin
      Multi2[band] := 0;
    end;
end;

procedure TJIDXScore2.Renew;
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
      if TQSO(Log.List[i]).QSO.NewMulti2 then
        inc(Multi2[band]);
    end;
end;

procedure TJIDXScore2.Reset;
var band : TBand;
begin
  for band := b19 to HiBand do
    begin
      QSO[band] := 0;
      CWQSO[band] := 0;
      Points[band] := 0;
      Multi[band] := 0;
      Multi2[band] := 0;
    end;
end;

procedure TJIDXScore2.CalcPoints(var aQSO : TQSO);
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

procedure TJIDXScore2.AddNoUpdate(var aQSO : TQSO);
begin
  inherited;

  if aQSO.QSO.Dupe then
    exit;

  if aQSO.QSO.NewMulti2 then
    inc(Multi2[aQSO.QSO.Band]);

  CalcPoints(aQSO);

 {case aQSO.QSO.Band of
    b19 : aQSO.QSO.Points := 4;
    b35 : aQSO.QSO.Points := 2;
    b7..b21 : aQSO.QSO.Points := 1;
    b28 : aQSO.QSO.Points := 2;
  else
    aQSO.QSO.Points := 0;
  end;}
  inc(Points[aQSO.QSO.Band], aQSO.QSO.Points);
end;

procedure TJIDXScore2.Update;
var band : TBand;
    TotQSO, TotPts, TotMulti, TotMulti2 : LongInt;
    row : integer;
begin
  TotQSO := 0; TotPts := 0; TotMulti := 0; TotMulti2 := 0;
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
          Grid.Cells[4,row] := IntToStr(Multi2[band]);
          TotMulti2 := TotMulti2 + Multi2[band];
          inc(row);
        end;
    end;
  Grid.Cells[1, 7] := IntToStr(TotQSO);
  Grid.Cells[2, 7] := IntToStr(TotPts);
  Grid.Cells[3, 7] := IntToStr(TotMulti);
  Grid.Cells[4, 7] := IntToStr(TotMulti2);
  Grid.Cells[4, 8] := IntToStr(TotPts*(TotMulti+TotMulti2));
end;


end.
