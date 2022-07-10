unit UAllAsianScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UIARUScore, Grids, Cologrid, StdCtrls, ExtCtrls, zLogGlobal, Buttons;

type
  TAllAsianScore = class(TIARUScore)
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddNoUpdate(var aQSO : TQSO);  override;
    procedure CalcPoints(var aQSO : TQSO);
  end;

var
  AllAsianScore: TAllAsianScore;

implementation

{$R *.DFM}

procedure TAllAsianScore.CalcPoints(var aQSO : TQSO);
begin
  case aQSO.QSO.Band of
    b19 : aQSO.QSO.Points := 3;
    b35 : aQSO.QSO.Points := 2;
  else
    aQSO.QSO.Points := 1;
  end;
end;

procedure TAllAsianScore.AddNoUpdate(var aQSO : TQSO);
var B : TBand;
begin
  //BasicScore.AddNoUpdate(aQSO);
  B := aQSO.QSO.band;
  inc(QSO[B]);
  if aQSO.QSO.mode = mCW then
    inc(CWQSO[B]);
  if aQSO.QSO.NewMulti1 then
    inc(Multi[B]);
  //inherited;
  //aQSO.QSO.Points := 0;
  if aQSO.QSO.Dupe then
    exit;
  //B := aQSO.QSO.band;
  //CalcPoints(aQSO);
  {
  case B of
    b19 : aQSO.QSO.Points := 3;
    b35 : aQSO.QSO.Points := 2;
  else
    aQSO.QSO.Points := 1;
  end;
  }
  {if aQSO.QSO.NewMulti2 then
    inc(Multi2[band]);}
  inc(Points[B], aQSO.QSO.Points);
end;


end.
