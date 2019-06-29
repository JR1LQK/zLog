unit UARRL10Score;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Grids, Cologrid, StdCtrls, ExtCtrls, zLogGlobal;

type
  TARRL10Score = class(TBasicScore)
    Grid: TMgrid;
    procedure FormCreate(Sender: TObject);
    procedure GridSetting(ARow, Acol: Integer; var Fcolor: Integer;
      var Bold, Italic, underline: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Update; override;
    procedure AddNoUpdate(var aQSO : TQSO);  override;
  end;

var
  ARRL10Score: TARRL10Score;

implementation

{$R *.DFM}

procedure TARRL10Score.Update;
begin
  Grid.Cells[1,0] := IntToStr(QSO[b28]);
  Grid.Cells[1,1] := IntToStr(QSO[b28] - CWQSO[b28]);
  Grid.Cells[1,2] := IntToStr(CWQSO[b28]);
  Grid.Cells[1,3] := IntToStr(Points[b28]);
  Grid.Cells[1,4] := IntToStr(Multi[b28]);
  Grid.Cells[1,5] := IntToStr(Points[b28]*Multi[b28]);
end;

procedure TARRL10Score.AddNoUpdate(var aQSO : TQSO);
var i : integer;
begin
  {BasicScore.AddNoUpdate(aQSO);}
  inherited;
  aQSO.QSO.Points := 0;
  if aQSO.QSO.Dupe then
    exit;
  if aQSO.QSO.Mode = mCW then
    begin
      i := length(aQSO.QSO.Callsign) - 1;
      if (pos('/N', aQSO.QSO.Callsign) = i) or (pos('/T', aQSO.QSO.Callsign) = i) then
        aQSO.QSO.Points := 8 // novice or technician cw qso : 8pts
      else
        aQSO.QSO.Points := 4;
    end
  else
    if aQSO.QSO.Mode in [mSSB, mFM, mAM] then
      begin
        aQSO.QSO.Points := 2;
      end;
  inc(Points[b28], aQSO.QSO.Points);
end;


procedure TARRL10Score.FormCreate(Sender: TObject);
begin
  inherited;
  with Grid do
    begin
      RowCount := 6;
      ColCount := 2;
      Cells[0,0] := 'QSO';
      Cells[0,1] := 'Ph';
      Cells[0,2] := 'CW';
      Cells[0,3] := 'Pts';
      Cells[0,4] := 'Multi';
      Cells[0,5] := 'Score';
      ColWidths[1] := 80;
      Height := GridHeight;
      Width := GridWidth;
    end;
  ClientHeight := Grid.Height + Panel1.Height+ 10;
end;

procedure TARRL10Score.GridSetting(ARow, Acol: Integer;
  var Fcolor: Integer; var Bold, Italic, underline: Boolean);
begin
  inherited;
  if ACol = 0 then
    FColor := clBlue
  else
    FColor := clBlack;
end;

end.
