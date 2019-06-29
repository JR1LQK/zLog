unit UWWZone;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, Aligrid, zLogGlobal;

type
  TWWZone = class(TForm)
    Grid: TStringAlignGrid;
    Panel1: TPanel;
    Button1: TButton;
    cbStayOnTop: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbStayOnTopClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    { Private declarations }
  public
    procedure Reset;
    procedure Mark(B : TBand; Zone : integer);
    { Public declarations }
  end;

var
  WWZone: TWWZone;

const
  MaxWidth = 592;

implementation

uses Main;

{$R *.DFM}

procedure TWWZone.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TWWZone.Reset;
var B : TBand;
    i : integer;
begin
  for B := b19 to b28 do
    if NotWARC(B) then
      for i := 1 to 40 do
        Grid.Cells[i, OldBandOrd(B)+1] := '.';
end;

procedure TWWZone.Mark(B : TBand; Zone : integer);
begin
  Grid.Cells[Zone, OldBandOrd(B)+1] := '*';
end;

procedure TWWZone.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TWWZone.FormResize(Sender: TObject);
begin
  if WWZone.Width > MaxWidth then
    WWZone.Width := MaxWidth;
end;

procedure TWWZone.FormCreate(Sender: TObject);
begin
  Width := MaxWidth;
end;

procedure TWWZone.cbStayOnTopClick(Sender: TObject);
begin
  if cbStayOnTop.Checked then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

procedure TWWZone.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : MainForm.LastFocus.SetFocus;
  end;
end;

end.
