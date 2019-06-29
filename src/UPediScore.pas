unit UPediScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, Aligrid, StdCtrls, ExtCtrls, zLogGlobal;

type
  TPediScore = class(TBasicScore)
    Grid: TStringAlignGrid;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    Stats: array[b19..HiBand, mCW..mOther] of integer;
  public
    { Public declarations }
    procedure Update; override;
    procedure AddNoUpdate(var aQSO : TQSO); override;
    procedure Reset; override;
    procedure SummaryWriteScore(FileName : string); override;
  end;

var
  PediScore: TPediScore;

implementation

{$R *.DFM}

procedure TPediScore.SummaryWriteScore(FileName : string);
var f : textfile;
    b : TBand;
    M : TMode;
    TotQSO, TotBandQSO : LongInt;
    ModeQSO : array[mCW..mOther] of integer;
begin
  AssignFile(f, FileName);
  Append(f);
  write(f, 'MHz     ');
  for m := mCW to mOther do
    write(f, FillLeft(ModeString[m], 6));
  write(f, '   QSO');
  writeln(f);

  TotQSO := 0;
  for M := mCW to mOther do
    ModeQSO[M] := 0;
  for B := b19 to HiBand do
    begin
      TotBandQSO := 0;
      write(f, FillRight(MHzString[b],8));
      for M := mCW to mOther do
        begin
          write(f, FillLeft(IntToStr(Stats[B, M]), 6));
          Inc(TotBandQSO, Stats[B, M]);
          inc(ModeQSO[M], Stats[B, M]);
        end;
      inc(TotQSO, TotBandQSO);
      write(f, FillLeft(IntToStr(TotBandQSO),6));
      writeln(f);
    end;
  write(f, FillRight('Total',8));
  for M := mCW to mOther do
    write(f, FillLeft(IntToStr(ModeQSO[M]), 6));
  writeln(f, FillLeft(IntToStr(TotQSO), 6));

  CloseFile(f);
end;


procedure TPediScore.Update;
var B : TBand;
    M : TMode;
    TotQSO, TotBandQSO : LongInt;
    ModeQSO : array[mCW..mOther] of integer;
begin
  TotQSO := 0;
  for M := mCW to mOther do
    ModeQSO[M] := 0;
  for B := b19 to HiBand do
    begin
      TotBandQSO := 0;
      for M := mCW to mOther do
        begin
          Grid.Cells[ord(M)+ 2, ord(B) + 1] := IntToStr(Stats[B, M]);
          Inc(TotBandQSO, Stats[B, M]);
          inc(ModeQSO[M], Stats[B, M]);
        end;
      inc(TotQSO, TotBandQSO);
      Grid.Cells[1, ord(B) + 1] := IntToStr(TotBandQSO);
    end;
  Grid.Cells[1, ord(HiBand)+2] := IntToStr(TotQSO);
  for M := mCW to mOther do
    Grid.Cells[ord(M) + 2, ord(HiBand)+2] := IntToStr(ModeQSO[M]);
end;

procedure TPediScore.AddNoUpdate(var aQSO : TQSO);
var band : TBand;
begin
  aQSO.QSO.points := 1;
  inc(Stats[aQSO.QSO.Band, aQSO.QSO.Mode]);
end;

procedure TPediScore.Reset;
var B : TBand;
    M : TMode;
begin
  for B := b19 to Hiband do
    for M := mCW to mOther do
      Stats[B, M] := 0;
end;

procedure TPediScore.FormShow(Sender: TObject);
begin
  inherited;
  Button1.SetFocus;
  Grid.Col := 1;
  Grid.Row := 1;
end;

end.
