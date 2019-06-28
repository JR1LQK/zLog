unit cm_hyper;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ColMemo;

type
  TFrmHyperTextDemo = class(TForm)
    ColorMemo1: TColorMemo;
    Label1: TLabel;
    procedure ColorMemo1HotSpotClick(Sender: TObject; const SRC: String);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmHyperTextDemo: TFrmHyperTextDemo;

implementation

{$R *.DFM}


procedure TFrmHyperTextDemo.ColorMemo1HotSpotClick(Sender: TObject;
  const SRC: String);
begin
  if SRC='sound' then
    MessageBeep(0)
  else
  if SRC='chapter' then
    ColorMemo1.ScrollBy(0,26)
  else
  if SRC='next line' then
    ColorMemo1.ScrollBy(0,1)
  else
  if SRC='previous line' then
    ColorMemo1.ScrollBy(0,-1)
  else ShowMessage('You'' clicked on "' + SRC + '" hotspot');
end;

end.
