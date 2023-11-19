unit Main;

interface

uses
    Forms, SysUtils, WinTypes, WinProcs, Messages, ColMemo, 
    StdCtrls,  Controls, ExtCtrls, Classes;

Var GoodHeight:Word;

type
  TMainForm = class(TForm)
    ToolBarPanel: TPanel;
    Bevel1: TBevel;
    Bevel3: TBevel;
    Bevel2: TBevel;
    Label7: TLabel;
    ColorMemo3: TColorMemo;
    ColorMemo4: TColorMemo;
    ColorMemo1: TColorMemo;
    ColorMemo2: TColorMemo;
    procedure FormCreate(Sender: TObject);
    procedure ColorMemo1HotSpotClick(Sender: TObject; const SRC: String);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure MinMax(var m: TWMGETMINMAXINFO); message wm_getminmaxinfo;
  end;

var
  MainForm: TMainForm;

implementation
{$R *.DFM}
uses cm_pasc, cm_html, cm_even, cm_hyper;

procedure TMainForm.FormCreate(Sender: TObject);
var I: word;
begin
     { What size should we be ? }
     with ToolBarPanel do begin
          i:=0;
          GoodHeight:=Controls[i].Top+Controls[i].Height;
          for i:=1 to ControlCount-1 do
              if Controls[i].Top+Controls[i].Height>GoodHeight then
                 GoodHeight:=Controls[i].Top+Controls[i].Height;
     end;
     GoodHeight:= GoodHeight+
                  +11+
                  +GetSystemMetrics(SM_CYCAPTION);
     Top:=0; Left:=0;
     Width:=ROUND(GetSystemMetrics(SM_CXSCREEN));
     Height:=GoodHeight;

     ColorMemo2.Width := Width - ColorMemo2.Left - 10;
     ColorMemo2.WordWrap := TRUE;
end;

procedure TMainForm.minmax(var m : TWMGETMINMAXINFO);
begin
     m.minmaxinfo^.ptmaxsize.x:=ROUND(GetSystemMetrics(SM_CXSCREEN	));
     m.minmaxinfo^.ptmaxsize.y:=GoodHeight;
     m.minmaxinfo^.ptmaxTracksize.x:=ROUND(GetSystemMetrics(SM_CXSCREEN	));
     m.minmaxinfo^.ptmaxTracksize.y:=GoodHeight;
     m.minmaxinfo^.ptminTracksize.x:=600;
     m.minmaxinfo^.ptminTracksize.y:=GoodHeight;
end;

procedure TMainForm.ColorMemo1HotSpotClick(Sender: TObject;
  const SRC: String);
begin
  If SRC = 'Pascal' then 
    FrmPascalDemo.Show
  else
  if SRC = 'HTML' then
    FrmHTMLDemo.Show
  else
  if SRC = 'Events' then
    FrmEventsDemo.Show
  else
  if SRC = 'HyperText' then
    FrmHyperTextDemo.Show
  else
  if SRC = 'help file' then begin
    Application.HelpFile := 'colormemo.hlp';
    Application.HelpCommand(Help_Contents,0);
  end;
end;

end.

