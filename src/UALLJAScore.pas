unit UALLJAScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, Aligrid, StdCtrls, ExtCtrls, zLogGlobal, Buttons;

type
  TALLJAScore = class(TBasicScore)
    Grid: TStringAlignGrid;
    procedure CWButtonClick(Sender: TObject);
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
  ALLJAScore: TALLJAScore;

implementation

{$R *.DFM}

procedure TALLJAScore.AddNoUpdate(var aQSO : TQSO);
var band : TBand;
begin
  inherited;

  if aQSO.QSO.Dupe then
    exit;

  band := aQSO.QSO.band;
  aQSO.QSO.points := 1;
  inc(Points[band]);
end;

procedure TALLJAScore.Update;
var band : TBand;
    TotPoints, TotMulti : LongInt;
    row : integer;
begin
  TotPoints := 0; TotMulti := 0;
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

  if ShowCWRatio then
    begin
      Grid.Cells[3,0] := 'CW Q''s';
      Grid.Cells[4,0] := 'CW %';
    end;

  for band := b35 to b50 do
    begin
      if NotWARC(band) then
        begin
          Grid.Cells[1,row] := IntToStr(Points[band]);
          TotPoints := TotPoints + Points[band];
          Grid.Cells[2,row] := IntToStr(Multi[band]);
          TotMulti := TotMulti + Multi[band];
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
  Grid.Cells[1, 7] := IntToStr(TotPoints);
  Grid.Cells[2, 7] := IntToStr(TotMulti);
  Grid.Cells[2, 8] := IntToStr(TotPoints*TotMulti);

  if ShowCWRatio then
    begin
      Grid.Cells[3, row] := IntToStr(TotalCWQSOs);
      if TotPoints > 0 then
        Grid.Cells[4, row] := FloatToStrF(100*(TotalCWQSOs/TotPoints), ffFixed, 1000, 1)
      else
        Grid.Cells[4, row] := '-';
    end;


end;

procedure TALLJAScore.Reset;
begin
  inherited;
end;

procedure TALLJAScore.Add(var aQSO : TQSO);
begin
  inherited;
end;



procedure TALLJAScore.CWButtonClick(Sender: TObject);
begin
  inherited;
  Width := Grid.Width + 15;
end;

end.
