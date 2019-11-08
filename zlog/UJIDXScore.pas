unit UJIDXScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, UzLogGlobal, UWWScore, Grids, Buttons;

type
  TJIDXScore = class(TWWScore)
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddNoUpdate(var aQSO : TQSO);  override;
  end;

implementation

{$R *.DFM}

procedure TJIDXScore.AddNoUpdate(var aQSO : TQSO);
var
   band : TBand;
begin
   if aQSO.QSO.Dupe then begin
      Exit;
   end;

   Inherited AddNoUpdate(aQSO);

   band := aQSO.QSO.band;
   if aQSO.QSO.NewMulti2 then begin
      Inc(Multi2[band]);
   end;

   case aQSO.QSO.Band of
      b19 : aQSO.QSO.Points := 4;
      b35 : aQSO.QSO.Points := 2;
      b7..b21 : aQSO.QSO.Points := 1;
      b28 : aQSO.QSO.Points := 2;
      else
         aQSO.QSO.Points := 0;
   end;

   Inc(Points[band], aQSO.QSO.Points);
end;

end.
