unit cm_html;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ColMemo;

type
  TFrmHTMLDemo = class(TForm)
    ColorMemo1: TColorMemo;
    Label13: TLabel;
    eFile: TEdit;
    btnFile: TButton;
    ODlg: TOpenDialog;
    procedure btnFileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadIt;
  end;

var
  FrmHTMLDemo: TFrmHTMLDemo;

implementation

{$R *.DFM}

procedure TFrmHTMLDemo.btnFileClick(Sender: TObject);
begin
     if ODlg.Execute then
     begin
          eFile.Text:=ODlg.FileName;
          LoadIt;
     end;
end;

procedure TFrmHtmlDemo.LoadIt;
begin
     try
        ColorMemo1.Lines.LoadFromFile(eFile.Text);
     except
     end;
end;

end.
