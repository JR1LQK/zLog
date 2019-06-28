unit Trapedit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TTrapEdit = class(TEdit)
  private
    { Private-Deklarationen }
  protected
    { Protected-Deklarationen }
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
  public
    { Public-Deklarationen }
    TrapKeys:set of byte;
  published
    { Published-Deklarationen }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('HDComps', [TTrapEdit]);
end;

procedure TTrapEdit.CNKeyDown(var Message: TWMKeyDown);
var aonkeydown:TKeyEvent;
begin
  aOnkeydown:=onkeydown;
  if message.charcode in trapkeys then
    if assigned(aonkeydown) then
      onkeydown(self,message.charcode,KeyDataToShiftState(message.KeyData));
  if message.charcode=0 then
    message.result:=1;
  inherited;
end;

end.
