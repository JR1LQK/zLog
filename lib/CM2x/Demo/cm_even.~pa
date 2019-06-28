unit cm_even;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ColMemo, ExtCtrls;

type
  TFrmEventsDemo = class(TForm)
    ColorMemo1: TColorMemo;
    Label13: TLabel;
    eFile: TEdit;
    btnFile: TButton;
    ODlg: TOpenDialog;
    cbxDrawKey: TCheckBox;
    cbxDraw: TCheckBox;
    gbxDraw: TGroupBox;
    eSearch: TEdit;
    lblSearch: TLabel;
    pnlDrawKey: TPanel;
    cbxBold: TCheckBox;
    cbxItalic: TCheckBox;
    cbxUnderline: TCheckBox;
    cbxFont: TComboBox;
    lblFonts: TLabel;
    procedure btnFileClick(Sender: TObject);
    procedure ColorMemo1DrawKey(Canvas: TCanvas; const PKey: String;
      Rect: TRect; KColor: TColor);
    procedure cbxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbxFontChange(Sender: TObject);
    procedure ColorMemo1Draw(Sender: TObject; FromPos: PChar;
      var A: array of TKeyDescr; var ItemsCount: Integer);
    procedure cbxDrawKeyClick(Sender: TObject);
    procedure cbxDrawClick(Sender: TObject);
    procedure eSearchExit(Sender: TObject);
    procedure eSearchKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadIt;
  end;

var
  FrmEventsDemo: TFrmEventsDemo;

implementation

{$R *.DFM}

procedure TFrmEventsDemo.btnFileClick(Sender: TObject);
begin
     if ODlg.Execute then
     begin
          eFile.Text:=ODlg.FileName;
          LoadIt;
     end;
end;

procedure TFrmEventsDemo.LoadIt;
begin
     try
        ColorMemo1.Lines.LoadFromFile(eFile.Text);
     except
     end;
end;

procedure TFrmEventsDemo.ColorMemo1DrawKey(Canvas: TCanvas;
  const PKey: String; Rect: TRect; KColor: TColor);
var OldFS: TFontStyles;
begin
  OldFS := Canvas.Font.Style;
  if cbxDrawKey.Checked then begin
     if cbxBold.Checked then 
        Canvas.Font.Style := Canvas.Font.Style + [fsBold];
     if cbxItalic.Checked then 
        Canvas.Font.Style := Canvas.Font.Style + [fsItalic];
     if cbxUnderline.Checked then 
        Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
  end;
     
  Canvas.TextOut( Rect.Left, Rect.Top, PKey);
  Canvas.Font.Style := OldFS;
end;

procedure TFrmEventsDemo.cbxChange(Sender: TObject);
begin
  ColorMemo1.Refresh;
end;

procedure TFrmEventsDemo.FormCreate(Sender: TObject);
begin
     cbxFont.Items := Screen.Fonts;
end;

procedure TFrmEventsDemo.cbxFontChange(Sender: TObject);
begin
  ColorMemo1.Font.Name := cbxFont.Text;
end;

procedure TFrmEventsDemo.ColorMemo1Draw(Sender: TObject; FromPos: PChar;
  var A: array of TKeyDescr; var ItemsCount: Integer);
var Str :String;
    i : integer;
begin
  Str := StrPas(FromPos);
  i := Pos(eSearch.Text, Str);
  if i<>0 then begin
    A[0].Left := i-1;
    A[0].Right := i + Length(eSearch.Text) -1;
    A[0].KeyColor := clBlue;
    A[0].ZOrder := 1;
  end;
  ItemsCount := 1;
end;

procedure TFrmEventsDemo.cbxDrawKeyClick(Sender: TObject);
begin
  cbxBold.Enabled := cbxDrawKey.Checked;
  cbxItalic.Enabled := cbxDrawKey.Checked;
  cbxUnderline.Enabled := cbxDrawKey.Checked;
  cbxFont.Enabled := cbxDrawKey.Checked;
  ColorMemo1.Refresh;
end;


procedure TFrmEventsDemo.cbxDrawClick(Sender: TObject);
begin
  ColorMemo1.ColorRules.Items[4].Enabled := cbxDraw.Checked;
  eSearch.Enabled := cbxDraw.Checked;
  ColorMemo1.Refresh;
end;

procedure TFrmEventsDemo.eSearchExit(Sender: TObject);
begin
    ColorMemo1.Refresh;
end;

procedure TFrmEventsDemo.eSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then ColorMemo1.Refresh;
end;

end.
