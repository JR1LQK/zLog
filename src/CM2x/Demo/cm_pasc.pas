unit cm_pasc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ColMemo;

type
  TFrmPascalDemo = class(TForm)
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
  FrmPascalDemo: TFrmPascalDemo;

implementation

{$R *.DFM}

procedure TFrmPascalDemo.btnFileClick(Sender: TObject);
begin
     if ODlg.Execute then
     begin
          eFile.Text:=ODlg.FileName;
          LoadIt;
     end;
end;

procedure TFrmPascalDemo.LoadIt;
begin
     try
        ColorMemo1.Lines.LoadFromFile(eFile.Text);
     except
     end;
end;

end.
