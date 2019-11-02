unit UWWZone;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, UzLogGlobal;

type
  TWWZone = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    cbStayOnTop: TCheckBox;
    Grid: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbStayOnTopClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Reset;
    procedure Mark(B : TBand; Zone : integer);
  end;

const
  MaxWidth = 592;

implementation

uses Main;

{$R *.DFM}

procedure TWWZone.Reset;
var
   B : TBand;
   i : integer;
begin
   for B := b19 to b28 do begin
      if NotWARC(B) then begin
         for i := 1 to 40 do begin
            Grid.Cells[i, OldBandOrd(B)+1] := '.';
         end;
      end;
   end;
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
   if Self.Width > MaxWidth then begin
      Self.Width := MaxWidth;
   end;
end;

procedure TWWZone.FormCreate(Sender: TObject);
begin
  Width := MaxWidth;
end;

procedure TWWZone.cbStayOnTopClick(Sender: TObject);
begin
   if cbStayOnTop.Checked then begin
      FormStyle := fsStayOnTop;
   end
   else begin
      FormStyle := fsNormal;
   end;
end;

procedure TWWZone.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   case Key of
      VK_ESCAPE : MainForm.LastFocus.SetFocus;
   end;
end;

procedure TWWZone.GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
   strText: string;
begin
   inherited;
   strText := TStringGrid(Sender).Cells[ACol, ARow];

   with TStringGrid(Sender).Canvas do begin
      Brush.Color := TStringGrid(Sender).Color;
      Brush.Style := bsSolid;
      FillRect(Rect);

      Font.Name := 'ÇlÇr ÉSÉVÉbÉN';
      Font.Size := 11;

      if Copy(strText, 1, 1) = '*' then begin
         strText := Copy(strText, 2);
         Font.Color := clBlue;
      end
      else begin
         Font.Color := clBlack;
      end;

      TextRect(Rect, strText, [tfRight,tfVerticalCenter,tfSingleLine]);
   end;
end;

end.
