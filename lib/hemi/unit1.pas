unit Unit1;

interface

uses
  Classes, Graphics, Forms, Controls, HemiBtn, ExtCtrls, StdCtrls, Buttons, Dialogs, SysUtils;

type
  TForm1 = class(TForm)
    Panel2: TPanel;
    Edit1: TEdit;
    HemisphereButton1: THemisphereButton;
    HemisphereButton2: THemisphereButton;
    HemisphereButton3: THemisphereButton;
    HemisphereButton4: THemisphereButton;
    HemisphereButton8: THemisphereButton;
    HemisphereButton9: THemisphereButton;
    HemisphereButton10: THemisphereButton;
    HemisphereButton14: THemisphereButton;
    HemisphereButton15: THemisphereButton;
    HemisphereButton16: THemisphereButton;
    HemisphereButton5: THemisphereButton;
    HemisphereButton6: THemisphereButton;
    HemisphereButton7: THemisphereButton;
    HemisphereButton18: THemisphereButton;
    HemisphereButton19: THemisphereButton;
    HemisphereButton20: THemisphereButton;
    HemisphereButton21: THemisphereButton;
    HemisphereButton22: THemisphereButton;
    HemisphereButton23: THemisphereButton;
    HemisphereButton24: THemisphereButton;
    HemisphereButton25: THemisphereButton;
    HemisphereButton26: THemisphereButton;
    HemisphereButton27: THemisphereButton;
    HemisphereButton31: THemisphereButton;
    HemisphereButton32: THemisphereButton;
    HemisphereButton11: THemisphereButton;
    HemisphereButton12: THemisphereButton;
    procedure OnDigitClick(Sender: TObject);
    procedure HemisphereButton1Click(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.OnDigitClick(Sender: TObject);
var
  aChar: char;
begin
  if TControl(Sender).Tag < 10 then begin
    aChar := char(48+TControl(Sender).Tag);
    Edit1.Text := Edit1.Text + aChar;
  end;
end;

procedure TForm1.HemisphereButton1Click(Sender: TObject);
begin
  ShowMessage('Author:'+#13+#13+'Christian Schnell'+#13+'lulli@cs.tu-berlin.de');
end;

end.
