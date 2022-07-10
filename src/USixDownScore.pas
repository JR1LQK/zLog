unit USixDownScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, Aligrid, StdCtrls, ExtCtrls, zLogGlobal, Buttons;

type
  TSixDownScore = class(TBasicScore)
    Grid: TStringAlignGrid;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
    procedure Reset; override;
    procedure Add(var aQSO : TQSO); override;
  end;

var
  SixDownScore: TSixDownScore;

implementation

{$R *.DFM}

procedure TSixDownScore.AddNoUpdate(var aQSO : TQSO);
var band : TBand;
begin
  inherited;

  if aQSO.QSO.Dupe then
    exit;

  band := aQSO.QSO.band;
  if band in [b2400..HiBand] then
    aQSO.QSO.points := 2
  else
    aQSO.QSO.points := 1;
  inc(Points[band], aQSO.QSO.Points);
end;

procedure TSixDownScore.Update;
var band : TBand;
    TotMulti, TotPoints : LongInt;
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

  for band := b50 to b10G do
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
  Grid.Cells[1, 8] := IntToStr(TotPoints);
  Grid.Cells[2, 8] := IntToStr(TotMulti);
  Grid.Cells[2, 9] := IntToStr(TotPoints*TotMulti);

  if ShowCWRatio then
    begin
      Grid.Cells[3, row] := IntToStr(TotalCWQSOs);
      if TotPoints > 0 then
        Grid.Cells[4, row] := FloatToStrF(100*(TotalCWQSOs/TotalQSOs), ffFixed, 1000, 1)
      else
        Grid.Cells[4, row] := '-';
    end;

(*
  TotQSO := 0; TotMulti := 0; TotPoints := 0;
  row := 1;
  for band := b50 to HiBand do
    begin
      if NotWARC(band) then
        begin
          Grid.Cells[1,row] := IntToStr(Points[band]);
          TotPoints := TotPoints + Points[band];
          TotQSO := TotQSO + QSO[band];
          Grid.Cells[2,row] := IntToStr(Multi[band]);
          TotMulti := TotMulti + Multi[band];
          inc(row);
        end;
    end;
  Grid.Cells[1, 8] := IntToStr(TotPoints);
  Grid.Cells[2, 8] := IntToStr(TotMulti);
  Grid.Cells[2, 9] := IntToStr(TotPoints*TotMulti);
*)
end;

procedure TSixDownScore.Reset;
begin
  inherited;
end;

procedure TSixDownScore.Add(var aQSO : TQSO);
begin
  inherited;
end;


procedure TSixDownScore.FormShow(Sender: TObject);
begin
  inherited;
  Button1.SetFocus;
  Grid.Col := 1;
  Grid.Row := 1;
end;

procedure TSixDownScore.FormCreate(Sender: TObject);
begin
  inherited;
  //ShowCWRatio := True;
end;

end.
