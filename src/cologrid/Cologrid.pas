{Copyright © 1998 by Michael Tran}
unit Cologrid;
{.$R mgrid.res}
interface

uses WinTypes, WinProcs, Messages, SysUtils, Classes, Controls,
     Graphics, Grids, menus;

type
  TSettingEvent = Procedure(ARow,Acol: Longint;var Fcolor:Longint;var Bold,Italic,underline:boolean) of object;
  TMgrid = class(TStringGrid)
    private
      { Private fields of TMgrid }
        Fsetting:TSettingEvent;
        FColors1: Tcolor;
        FColors2: Tcolor;
        FColors3: Tcolor;
        FAlignCell : TAlignment;
      { Private methods of TMgrid }
        { Method to set variable and property values and create objects }
        procedure AutoInitialize;
        { Method to free any objects created by AutoInitialize }
        procedure AutoDestroy;
    protected
        FBorderbitmap : tbitmap;
        FoddBitmap : Tbitmap;
        FevenBitmap : Tbitmap;

      { Protected methods of TMgrid }
        procedure Loaded; override;
        procedure Paint; override;
        Procedure setCellAlignment(value : TAlignment);
        Procedure setBorderColor(value : tcolor);
        Procedure setOddColor(value : tcolor);
        Procedure setEvencolor(value : tcolor);
        Procedure SetBorderBitmap(value: Tbitmap);
        Procedure SetOddBitmap(value: Tbitmap);
        Procedure SetEvenBitmap(value: Tbitmap);
    public
      { Public fields of TMgrid }
        procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
              AState: TGridDrawState); override;
        procedure DrawCellText(ACol, ARow: Longint; ARect: TRect);
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        function GetPalette: HPALETTE; override;
    published
      { Published properties of the component }
        Property Alignment : TAlignment read FAlignCell write setCellAlignment;
        Property BorderColor: Tcolor read Fcolors1 write setBorderColor;
        Property OddRowColor: Tcolor read Fcolors2 write setOddColor;
        Property EvenRowColor: Tcolor read Fcolors3 write setEvenColor;
        Property BorderPattern : Tbitmap read Fborderbitmap write SetBorderBitmap stored true;
        Property OddRowPattern : Tbitmap read FOddbitmap write SetOddBitmap;
        Property EvenRowPattern : Tbitmap read FEvenbitmap write SetEvenBitmap;
        Property Popupmenu;
        property OnClick;
        property OnDblClick;
        property OnDragDrop;
        property OnMouseDown;
        property OnMouseMove;
        property OnMouseUp;
        property OnKeyUp;
        property OnKeyDown;
        property OnKeyPress;
        property OnEnter;
        property OnExit;
        Property OnSetting: TSettingEvent read Fsetting write Fsetting;
        property OnDrawCell;
end;

procedure Register;

Implementation

procedure Register;
begin
     RegisterComponents('Mik', [TMgrid]);
end;

procedure TMgrid.SetBorderBitmap(value: Tbitmap);
begin
        FBorderbitmap.assign(value);
        refresh;

end;
procedure TMgrid.SetOddBitmap(value: Tbitmap);
begin
        FoddBitmap.assign(value);
        refresh;

end;

function TMgrid.GetPalette: HPALETTE;
begin
  Result := 0;	{ default result is no palette }
  Result := TBitmap(FoddBitmap).Palette;	{ use it if available }
end;

procedure TMgrid.SetEvenBitmap(value: Tbitmap);
begin
        FevenBitmap.assign(value);
        refresh;
end;
procedure TMgrid.setCellAlignment(value : TAlignment);
begin
FAlignCell := value;
refresh;
end;
procedure TMgrid.setBorderColor(value : tcolor);
begin
fcolors1 := value;
refresh;
end;
procedure TMgrid.setOddColor(value : tcolor);
begin
fcolors2 := value;
refresh;
end;
procedure TMgrid.setEvencolor(value : tcolor);
begin
fcolors3 := value;
refresh;
end;

procedure TMgrid.AutoInitialize;
begin
FONT.name := 'Arial';
FONT.size := 10;
CANVAS.BRUSH.COLOR := color;
CANVAS.FONT := FONT;
FBorderbitmap := tbitmap.create;
FoddBitmap := Tbitmap.create;
FevenBitmap := Tbitmap.create;
fcolors1 := clsilver;
fcolors2 := clAqua;
fcolors3 := cllime;
FAlignCell := taLeftJustify;
refresh;
end; { of AutoInitialize }

{ Method to free any objects created by AutoInitialize }
procedure TMgrid.AutoDestroy;
begin
  FBorderbitmap.free;
  FoddBitmap.free;
  FevenBitmap.free;
end; { of AutoDestroy }


constructor TMgrid.Create(AOwner: TComponent);
begin

  inherited Create(AOwner);
  AutoInitialize;

end;

destructor TMgrid.Destroy;
begin
     AutoDestroy;
     inherited Destroy;
end;

procedure TMgrid.Loaded;
begin
inherited Loaded;
end;

procedure TMgrid.Paint;
begin
     { Make this component look like its parent component by calling
       its parent's Paint method. }
     inherited Paint;

end;


procedure TMgrid.DrawCellText(ACol, ARow: Longint; ARect: TRect);
var
    Text: array[0..255] of Char;
  begin
    StrPCopy(Text, Cells[ACol, ARow]);
    ExtTextOut(Canvas.Handle, ARect.Left + 2, ARect.Top + 2, ETO_CLIPPED or
      ETO_OPAQUE, @ARect, Text, StrLen(Text), nil);
end;


procedure TMgrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);

VAR OldColor : TColor;
   OldBrush : TBrush;
   fcolor : longint;
   u,i,b : boolean;
begin
with Canvas do
begin
    OldColor := Font.Color;
    OldBrush := Brush;
 brush.style := bssolid;
if (Acol < fixedcols) or (Arow < fixedrows) then
 begin
 if not Fborderbitmap.empty then
  begin
   brush.bitmap := Fborderbitmap;
   PaletteChanged(false);
  end
 else
  brush.color := Fcolors1;
  Font.Color := clblack;
 end
else
if odd(Arow) then
 begin
 if not Foddbitmap.empty then
 begin
   brush.bitmap := Foddbitmap;
   PaletteChanged(false);
 end
 else
  brush.color := Fcolors2;
 end
else
 begin
 if not FevenBitmap.empty then
 begin
  brush.bitmap := FevenBitmap;
  PaletteChanged(false);
 end
 else
  brush.color := Fcolors3;
 end;
 FillRect(ARect);
 SetBkMode(Canvas.Handle,TRANSPARENT);
 b:= fsbold in canvas.font.style;
 i:= fsitalic in canvas.font.style;
 u:= fsUnderline in canvas.font.style;
 fcolor := -1;
 if assigned(Fsetting) THEN
 begin
   Fsetting(arow,acol,FCOLOR,b,i,u);
   if fcolor >=0 then
    CANVAS.FONT.COLOR := TCOLOR(FCOLOR);
   CANVAS.FONT.style := [];
   if b then
      CANVAS.FONT.style := [fsbold];
   if i then
      CANVAS.FONT.style := CANVAS.FONT.style + [fsitalic];
   if u then
      CANVAS.FONT.style := CANVAS.FONT.style + [fsunderline];
 end;

 if FAlignCell = taLeftJustify then
   TextOut(ARect.Left+2,ARect.Top+2,Cells[ACol,ARow])
 else
   TextOut(ARect.Left+2 + (ARect.Right - ARect.Left - 3 - TextWidth(Cells[ACol,ARow])),
           ARect.Top+2,Cells[ACol,ARow]);
 Font.Color := OldColor;
 Brush := OldBrush;
 end;

end;
end.

