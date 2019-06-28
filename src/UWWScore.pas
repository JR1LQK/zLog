unit UWWScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, zLogGlobal, Grids, Aligrid, StdCtrls, ExtCtrls, Buttons;

type
  TWWScore = class(TBasicScore)
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
    procedure SummaryWriteScore(FileName : string); override;
  end;

var
  WWScore: TWWScore;

implementation

{$R *.DFM}

constructor TWWScore.Create;
var band : TBand;
begin
  inherited;
  for band := b19 to HiBand do
    begin
      Multi2[band] := 0;
    end;
end;

procedure TWWScore.Renew;
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

procedure TWWScore.Reset;
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

procedure TWWScore.AddNoUpdate(var aQSO : TQSO);
var P : integer;
    band : TBand;
begin
  {BasicScore.AddNoUpdate(aQSO);}
  inherited;
  if aQSO.QSO.Dupe then
    exit;
  band := aQSO.QSO.band;
  if aQSO.QSO.NewMulti2 then
    inc(Multi2[band]);
  inc(Points[band], aQSO.QSO.Points); {Points calculated in WWMulti.AddNoUpdate}
end;

procedure TWWScore.Update;
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

procedure TWWScore.SummaryWriteScore(FileName : string);
var f : textfile;
    tqso, tpts, tmulti, tmulti2 : LongInt;
    b : TBand;
begin
  tqso := 0; tpts := 0; tmulti := 0; tmulti2 := 0;
  AssignFile(f, FileName);
  Append(f);
  writeln(f, 'MHz           QSOs    Points    Zones  Countries');
  for b := b19 to b28 do
    begin
      if NotWARC(b) then
        begin
          writeln(f, FillRight(MHzString[b],8)+FillLeft(IntToStr(QSO[b]),10)+
                     FillLeft(IntToStr(Points[b]),10)+FillLeft(IntToStr(Multi[b]),10)+
                     FillLeft(IntToStr(Multi2[b]),10));
          tqso := tqso + QSO[b];
          tpts := tpts + Points[b];
          tmulti := tmulti + Multi[b];
          tmulti2 := tmulti2 + Multi2[b];
        end;
    end;
  writeln(f, FillRight('Total :',8)+FillLeft(IntToStr(tqso),10)+
             FillLeft(IntToStr(tpts),10)+FillLeft(IntToStr(tmulti),10)+
             FIllLeft(IntToStr(tmulti2),10) );
  writeln(f,'Total score : ' + IntToStr(tpts*(tmulti+tmulti2)));
  CloseFile(f);
end;

end.
