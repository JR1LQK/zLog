unit UACAGScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, StdCtrls, ExtCtrls, Aligrid, zLogGlobal, menus,
  Buttons;

type
  TACAGScore = class(TBasicScore)
    Grid: TStringAlignGrid;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
    procedure Reset; override;
    procedure Add(var aQSO : TQSO); override;
    { Public declarations }
  end;

var
  ACAGScore: TACAGScore;

implementation

uses Main;

{$R *.DFM}

procedure TACAGScore.AddNoUpdate(var aQSO : TQSO);
var band : TBand;
begin
  inherited;

  if aQSO.QSO.Dupe then
    exit;

  band := aQSO.QSO.band;
  aQSO.QSO.points := 1;
  inc(Points[band]);
end;

procedure TACAGScore.Update;
var band : TBand;
    TotQSO, TotPoints, TotMulti : LongInt;
    row : integer;
    mb : TMenuItem;
begin
  TotQSO := 0; TotPoints := 0; TotMulti := 0;
  row := 1;

  if ShowCWRatio then
    begin
      Grid.ColCount := 5;
      Grid.Width :=  Grid.DefaultColWidth * 5;
    end
  else
    begin
      Grid.ColCount := 3;
      Grid.Width := Grid.DefaultColWidth * 3;
    end;


  Grid.Cells[0,0] := 'MHz';
  Grid.Cells[1,0] := 'Points';
  Grid.Cells[2,0] := 'Mult';

  if ShowCWRatio then
    begin
      Grid.Cells[3,0] := 'CW Q''s';
      Grid.Cells[4,0] := 'CW %';
    end;


  for band := b35 to HiBand do
    begin
      if NotWARC(band) then
        begin
          TotPoints := TotPoints + Points[band];
          TotMulti := TotMulti + Multi[band];
          TotQSO := TotQSO + QSO[band];
          mb := MainForm.BandMenu.Items[ord(band)];
          if mb.Visible and mb.Enabled then
            begin
              Grid.CellFont[0,row].Color := clBlue;
              Grid.Cells[0,row] := MHzString[band];
              Grid.Cells[1,row] := IntToStr(Points[band]);
              Grid.Cells[2,row] := IntToStr(Multi[band]);

             if ShowCWRatio then
               begin
                 Grid.Cells[3,row] := IntToStr(CWQSO[band]);
                 if QSO[band] > 0 then
                   Grid.Cells[4,row] := FloatToStrF(100*(CWQSO[band] / QSO[band]), ffFixed, 1000, 1)
                 else
                   Grid.Cells[4,row] := '-';
               end;

              inc(row);
            end;
        end;
    end;
{
  Grid.Cells[1, 13] := IntToStr(TotPoints);
  Grid.Cells[2, 13] := IntToStr(TotMulti);
  Grid.Cells[2, 14] := IntToStr(TotPoints*TotMulti);
  }
  Grid.CellFont[0, row].Color := clBlack;
  Grid.Cells[0, row] := 'Total';
  Grid.Cells[1, row] := IntToStr(TotPoints);
  Grid.Cells[2, row] := IntToStr(TotMulti);


  if ShowCWRatio then
    begin
      Grid.Cells[3, row] := IntToStr(TotalCWQSOs);
      if TotQSO > 0 then
        Grid.Cells[4, row] := FloatToStrF(100*(TotalCWQSOs/TotQSO), ffFixed, 1000, 1)
      else
        Grid.Cells[4, row] := '-';
    end;

  inc(row);
  Grid.CellFont[0, row].Color := clBlack;
  Grid.Cells[0, row] := 'Score';
  Grid.Cells[1, row] := '';
  Grid.Cells[2, row] := IntToStr(TotPoints*TotMulti);
  Grid.Height := 16*(row+1);
  ACAGScore.Height := Grid.Height + (325-256);

end;

procedure TACAGScore.Reset;
begin
  inherited;
end;

procedure TACAGScore.Add(var aQSO : TQSO);
begin
  inherited;
end;

procedure TACAGScore.FormShow(Sender: TObject);
begin
  inherited;
  Button1.SetFocus;
  Grid.Col := 1;
  Grid.Row := 1;
end;

end.
