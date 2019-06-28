unit UWPXScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, Aligrid, StdCtrls, ExtCtrls, zLogGlobal, Buttons;

type
  TWPXScore = class(TBasicScore)
    Grid: TStringAlignGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    AllAsianDXMode : Boolean;
    procedure Reset; override;
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
    procedure SummaryWriteScore(FileName : string); override;
  end;

var
  WPXScore: TWPXScore;

implementation

uses UWPXMulti;

{$R *.DFM}


procedure TWPXScore.Reset;
var band : TBand;
begin
  for band := b19 to HiBand do
    begin
      QSO[band] := 0;
      Points[band] := 0;
    end;
end;

procedure TWPXScore.AddNoUpdate(var aQSO : TQSO);
var P : integer;
    band : TBand;
begin
  inherited; {points are calculated in WPXMulti}
  if aQSO.QSO.Dupe then
    exit;

  if AllAsianDXMode then
    begin
      case aQSO.QSO.Band of
        b19: aQSO.QSO.Points := 3;
        b35, b28 : aQSO.QSO.Points := 2;
        b7..b21 : aQSO.QSO.Points := 1;
      end;
      if aQSO.QSO.Power2 = 777 then // asia. see uwpxmulti.addnoupdate
        aQSO.QSO.Points := 0;
    end;

  inc(Points[aQSO.QSO.Band], aQSO.QSO.Points);
end;

procedure TWPXScore.Update;
var band : TBand;
    TotQSO, TotPts : LongInt;
    row : integer;
begin
  TotQSO := 0; TotPts := 0;
  row := 1;
  for band := b19 to b28 do
    begin
      if NotWARC(band) then
        begin
          Grid.Cells[1,row] := IntToStr(QSO[band]);
          TotQSO := TotQSO + QSO[band];
          Grid.Cells[2,row] := IntToStr(Points[band]);
          TotPts := TotPts + Points[band];
          inc(row);
        end;
    end;
  Grid.Cells[1, 7] := IntToStr(TotQSO);
  Grid.Cells[2, 7] := IntToStr(TotPts);
  Grid.Cells[2, 8] := IntToStr(WPXMulti.TotalPrefix);
  Grid.Cells[2, 9] := IntToStr(TotPts*WPXMulti.TotalPrefix);
end;

procedure TWPXScore.SummaryWriteScore(FileName : string);
var f : textfile;
    tqso, tpts : LongInt;
    b : TBand;
begin
  tqso := 0; tpts := 0; {tmulti := 0; }
  AssignFile(f, FileName);
  Append(f);
  writeln(f, 'MHz           QSOs    Points');
  for b := b19 to b28 do
    begin
      if NotWARC(b) then
        begin
          writeln(f, FillRight(MHzString[b],8)+FillLeft(IntToStr(QSO[b]),10)+
                     FillLeft(IntToStr(Points[b]),10) );
          tqso := tqso + QSO[b];
          tpts := tpts + Points[b];
        end;
    end;
  writeln(f, FillRight('Total :',8)+FillLeft(IntToStr(tqso),10)+
             FillLeft(IntToStr(tpts),10) );
  writeln(f, 'Total prefixes: ' + IntToStr(WPXMulti.TotalPrefix));
  writeln(f,'Total score : ' + IntToStr(tpts*WPXMulti.TotalPrefix));
  CloseFile(f);
end;



procedure TWPXScore.FormCreate(Sender: TObject);
begin
  inherited;
  AllAsianDXMode := false;
end;

end.
