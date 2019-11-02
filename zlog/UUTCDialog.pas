unit UUTCDialog;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TUTCDialog = class(TForm)
    OKBtn: TButton;
    Bevel1: TBevel;
    CheckBox: TCheckBox;
  private
    { Private declarations }
    function GetUseUTC(): Boolean;
  public
    { Public declarations }
    property UseUTC: Boolean read GetUseUTC;
  end;

implementation

{$R *.DFM}

function TUTCDialog.GetUseUTC(): Boolean;
begin
   Result := CheckBox.Checked;
end;

end.
