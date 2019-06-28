unit DemoForm2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TPaperSizeForm = class(TForm)
    EditWidth: TEdit;
    EditLength: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Button2: TButton;
    procedure grpUnitClick(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  PaperSizeForm: TPaperSizeForm;

implementation

{$R *.DFM}
uses NKPrinters;

procedure TPaperSizeForm.grpUnitClick(Sender: TObject);
var Size: TSize;
begin
  Size := NkPrinter.UserPaperExtent;
  EditWidth.Text :=  IntToStr(Size.cx);
  EditLength.Text := IntToStr(Size.cy);
end;

end.
