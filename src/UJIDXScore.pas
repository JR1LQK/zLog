unit UJIDXScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Aligrid, StdCtrls, ExtCtrls, zLogGlobal, UBasicScore, UWWScore, Grids;

type
  TJIDXScore = class(TWWScore)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddNoUpdate(var aQSO : TQSO);  override;
  end;

var
  JIDXScore: TJIDXScore;

implementation

{uses UBasicScore; }

{$R *.DFM}


procedure TJIDXScore.AddNoUpdate(var aQSO : TQSO);
var band : TBand;
begin
  if aQSO.QSO.Dupe then
    exit;

  BasicScore.AddNoUpdate(aQSO);
  band := aQSO.QSO.band;
  if aQSO.QSO.NewMulti2 then
    inc(Multi2[band]);
  case aQSO.QSO.Band of
    b19 : aQSO.QSO.Points := 4;
    b35 : aQSO.QSO.Points := 2;
    b7..b21 : aQSO.QSO.Points := 1;
    b28 : aQSO.QSO.Points := 2;
  else
    aQSO.QSO.Points := 0;
  end;

  inc(Points[band], aQSO.QSO.Points);
end;

procedure TJIDXScore.FormCreate(Sender: TObject);
var i : integer;
begin
  inherited;
  i := 0;
end;

end.
