unit UJA0Score;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, Aligrid, StdCtrls, ExtCtrls, zLogGlobal, Buttons;

type
  TJA0Score = class(TBasicScore)
    Grid: TStringAlignGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    JA0Band : TBand;
    procedure Reset; override;
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure Update; override;
    function IsJA0(aQSO : TQSO) : boolean;
    procedure SetBand(B : TBand);
  end;

var
  JA0Score: TJA0Score;

implementation

uses Main;

{$R *.DFM}

procedure TJA0Score.Reset;
var band : TBand;
begin
  for band := b19 to HiBand do
    begin
      QSO[band] := 0;
      Points[band] := 0;
      Multi[band] := 0;
    end;
end;

function TJA0Score.IsJA0(aQSO : TQSO) : boolean;
begin
  if Pos('0',aQSO.QSO.CallSign) > 0 then
    Result := True
  else
    Result := False;
end;

procedure TJA0Score.AddNoUpdate(var aQSO : TQSO);
var P : integer;
    band : TBand;
begin
  inherited;

  if aQSO.QSO.Dupe then
    exit;

  if IsJA0(aQSO) then
    aQSO.QSO.Points := 3
  else
    aQSO.QSO.Points := 1;
  inc(Points[aQSO.QSO.Band], aQSO.QSO.Points);
end;

procedure TJA0Score.Update;
begin
  if (JA0Band = b21) or (JA0Band = b28) then
    begin
      Grid.Cells[1, 1] := IntToStr(QSO[b21]);
      Grid.Cells[2, 1] := IntToStr(Points[b21]);
      Grid.Cells[3, 1] := IntToStr(Multi[b21]);
      Grid.Cells[1, 2] := IntToStr(QSO[b28]);
      Grid.Cells[2, 2] := IntToStr(Points[b28]);
      Grid.Cells[3, 2] := IntToStr(Multi[b28]);
      Grid.Cells[3, 3] := IntToStr((Points[b21]+Points[b28])*(Multi[b21]+Multi[b28]));
    end
  else
    begin
      Grid.Cells[1, 1] := IntToStr(QSO[JA0Band]);
      Grid.Cells[2, 1] := IntToStr(Points[JA0Band]);
      Grid.Cells[3, 1] := IntToStr(Multi[JA0Band]);
      Grid.Cells[3, 2] := IntToStr(Points[JA0Band]*Multi[JA0Band]);
    end;
end;


procedure TJA0Score.FormCreate(Sender: TObject);
begin
  inherited;
  // JA0Band := Main.CurrentQSO.QSO.Band;
  // Grid.Cells[0,1] := MHzString[JA0Band];
end;

procedure TJA0Score.SetBand(B : TBand);
begin
  JA0Band := B;
  if (B = b21) or (B = b28) then
    begin
      Grid.Height := Grid.DefaultRowHeight*4 + 2;
      Height := 130 + 22;
      Grid.RowCount := 4;
      Grid.Cells[0,1] := MHzString[b21];
      Grid.Cells[0,2] := MHzString[b28];
      Grid.Cells[0,3] := 'Score';
    end
  else
    begin
      Height := 130;
      Grid.Height := 57;
      Grid.RowCount := 3;
      Grid.Cells[0,1] := MHzString[JA0Band];
      Grid.Cells[0,2] := 'Score';
    end;
end;

procedure TJA0Score.FormShow(Sender: TObject);
begin
  inherited;
  Grid.Col := 1;
  Grid.Row := 1;
end;

end.
