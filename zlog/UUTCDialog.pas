unit UUTCDialog;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, UzLogGlobal;

type
  TUTCDialog = class(TForm)
    OKBtn: TButton;
    Bevel1: TBevel;
    CheckBox: TCheckBox;
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TUTCDialog.OKBtnClick(Sender: TObject);
begin
  if CheckBox.Checked then
    UseUTC := True
  else
    UseUTC := False;
end;

end.
