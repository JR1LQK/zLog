unit UWAEScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, Aligrid, StdCtrls, Buttons, ExtCtrls, zLogGlobal;

const BandFactor : array[b19..b28] of integer =
           (0, 4, 3, 0, 2, 0, 2, 0, 2);    // multi bonus factor

type
  TWAEScore = class(TBasicScore)
    Grid: TStringAlignGrid;
  private
    { Private declarations }
    QTCs : array[b19..b28] of integer;
  public
    procedure Reset; override;
    procedure Renew; override;
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
    procedure SummaryWriteScore(FileName : string); override;
  end;

var
  WAEScore: TWAEScore;

implementation

{$R *.DFM}

procedure TWAEScore.Reset;
var B : TBand;
begin
  inherited;
  for b := b19 to b28 do
    QTCs[b] := 0;
end;

procedure TWAEScore.Renew;
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
      if pos('[QTC', TQSO(Log.List[i]).QSO.Memo) > 0 then
        inc(QTCs[band]);
    end;
end;

procedure TWAEScore.AddNoUpdate(var aQSO : TQSO);
var P : integer;
    band : TBand;
begin
  inherited;
  if aQSO.QSO.Dupe then
    exit;
  if aQSO.QSO.Multi1 = 'Non-EU' then
    exit;
  band := aQSO.QSO.band;
  aQSO.QSO.Points := 1;
  inc(Points[band]);
  if pos('[QTC', aQSO.QSO.Memo) > 0 then
    inc(QTCs[band]);
end;

procedure TWAEScore.Update;
var band : TBand;
    TotQSO, TotMulti, TotQTCs : LongInt;
    row : integer;
begin
  TotQSO := 0; TotMulti := 0; TotQTCs := 0;
  row := 1;
  for band := b35 to b28 do
    begin
      if NotWARC(band) then
        begin
          Grid.Cells[1,row] := IntToStr(QSO[band]);
          TotQSO := TotQSO + QSO[band];
          Grid.Cells[2,row] := IntToStr(QTCs[band]);
          TotQTCs := TotQTCs + QTCs[band];
          Grid.Cells[3,row] := IntToStr(BandFactor[band]*Multi[band]);
          TotMulti := TotMulti + BandFactor[band]*Multi[band];
          inc(row);
        end;
    end;
  Grid.Cells[1, 6] := IntToStr(TotQSO);
  Grid.Cells[2, 6] := IntToStr(TotQTCs);
  Grid.Cells[3, 6] := IntToStr(TotMulti);
  Grid.Cells[3, 7] := IntToStr((TotQSO+TotQTCs)*TotMulti);
end;

procedure TWAEScore.SummaryWriteScore(FileName : string);
var f : textfile;
    tqso, tmulti, tqtc : LongInt;
    b : TBand;
begin
  tqso := 0; tqtc := 0; tmulti := 0;
  AssignFile(f, FileName);
  Append(f);
  writeln(f, 'MHz           QSOs     QTCs    Mult(*bonus)');
  for b := b35 to b28 do
    begin
      if NotWARC(b) then
        begin
          writeln(f, FillRight(MHzString[b],8)+FillLeft(IntToStr(QSO[b]),10)+
                     FillLeft(IntToStr(QTCs[b]),10)+FillLeft(IntToStr(Multi[b]*BandFactor[b]),10));
          tqso := tqso + QSO[b];
          tqtc := tqtc + QTCs[b];
          tmulti := tmulti + Multi[b]*BandFactor[b];
        end;
    end;
  writeln(f, FillRight('Total :',8)+FillLeft(IntToStr(tqso),10)+
             FillLeft(IntToStr(tqtc),10)+FillLeft(IntToStr(tmulti),10));
  writeln(f,'Total score : ' + IntToStr((tqso+tqtc)*tmulti));
  CloseFile(f);
end;

end.
