{-------------------------------------------------------------
-RButton: Visible Component used to display round buttons    -
-         instead of square.  Works identical to the standard-
-         TSpeedButton component.                            -
--------------------------------------------------------------
- !INSTALLATION!:  In Delphi, go to Options|Install Component-
- and Add BPReg.pas.  This will add both components.         -
--------------------------------------------------------------
-Programmed by Brendan Rempel, October 1996                  -
-Copyright 1996; All Rights Reserved                         -
-Send any comments/change requests/etc. to:                  -
-   rempelb@mail.pr-unlimited.com                            -
-                                                            -
-This component is hereby given to the public domain.  I do  -
-claim copyright of this code and I hereby prohibit the sale -
-of the source or compiled code to anyone for any amount.    -
-------------------------------------------------------------}
unit Rbutton;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

const
  DefaultWidth = 40;
  DefaultHeight = 40;

type
  TNumGlyphs = 1..4;
  TRButtonType = (rtRegular,rtInset);

type
  TRoundButton = class(TGraphicControl)
  private
    FGlyph:            TBitmap;
    FNumGlyphs:        TNumGlyphs;
    FDown:             boolean;
    FTransparentColor: TColor;
    FMouseDown:        boolean;
    FMouseInside:      boolean;
    FOnClick:          TNotifyEvent;
    FRButtonType:      TRButtonType;
    FOnMouseEnter:     TNotifyEvent;
    FOnMouseExit:      TNotifyEvent;

  protected
    procedure Paint;  override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
       override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
       override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
       override;

    function  IsInsideButton(X,Y: Integer): boolean;

    procedure SetGlyph(newGlyph: TBitmap);
    procedure SetNumGlyphs(newNumGlyphs: TNumGlyphs);
    procedure SetTransparentColor(newTransparentColor: TColor);
    procedure SetRButtonType(newRButtonType: TRButtonType);

    procedure PaintButton;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property ButtonType: TRButtonType read FRButtonType write SetRButtonType;
    property Enabled;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property NumGlyphs: TNumGlyphs read FNumGlyphs write SetNumGlyphs default 1;
    property ParentShowHint;
    property ShowHint;
    property TransparentColor: TColor read FTransparentColor write SetTransparentColor;
    property Visible;
    property OnClick:   TNotifyEvent read FOnClick write FOnClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;

    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseExit:  TNotifyEvent read FOnMouseExit  write FOnMouseExit;
  end;

implementation

constructor TRoundButton.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);

   FGlyph:= TBitmap.Create;
   FNumGlyphs:= 1;
   FDown:=  False;
   FMouseInside:= False;
   Width:=  DefaultWidth;
   Height:= DefaultHeight;

   FMouseDown:= False;
end;

destructor  TRoundButton.Destroy;
begin
   FGlyph.Free;
   inherited Destroy;
end;

procedure TRoundButton.SetGlyph(newGlyph: TBitmap);
begin
   if(Assigned(FGlyph)) then
   begin
      FGlyph.Assign(newGlyph);

      if (csDesigning in ComponentState) then
      begin
         { bitmap 1: main, 2: disabled, 3: down;
           must have dimensions of (height * NoBitmaps) = width }
         if (newGlyph.width mod newGlyph.height = 0) then
            FNumGlyphs:= newGlyph.width div newGlyph.height
         else
            FNumGlyphs:= 1;
      end;

      Invalidate;
   end;
end;

procedure TRoundButton.SetNumGlyphs(newNumGlyphs: TNumGlyphs);
begin
   FNumGlyphs:= newNumGlyphs;
   Invalidate;
end;

procedure TRoundButton.SetRButtonType(newRButtonType: TRButtonType);
begin
   FRButtonType:= newRButtonType;
   Invalidate;
end;

procedure TRoundButton.SetTransparentColor(newTransparentColor: TColor);
begin
   FTransparentColor:= newTransparentColor;
   Invalidate;
end;

function TRoundButton.IsInsideButton(X,Y: Integer): boolean;
var
   Hypotonuse: integer;
begin
   X:= Abs((Width shr 1) - X);  { calculate the (X,Y) distance }
   Y:= Abs((Height shr 1) - Y);

   Hypotonuse:= Round(Sqrt(Abs((X * X) + (Y * Y))));
                                { calculate hypotenuse (distance from center) }

   Result:= (Hypotonuse <= (Width shr 1)-1);
                                { return true if Hypotonuse less than half of width }
end;

procedure TRoundButton.Paint;
begin
   with Canvas do
   begin
      brush.color:= clBtnFace;

      case FRButtonType of
         rtRegular:
         begin
            pen.color:= clBlack;
            Ellipse(0,0,width-1,height-1); { fill inner button, black edge }
         end;
         rtInset:
         begin
            pen.color:= clBtnFace;
            Ellipse(1,1,width-2,height-2); { fill inner button }

            pen.color:= clBtnShadow;       { shadowed edge }
            Arc(0,0,width-1,height-1,width div 5 * 4,height div 5,width div 5,height div 5 * 4);
            pen.color:= clBtnHighlight;    { highlighted edge }
            Arc(0,0,width-1,height-1,width div 5,height div 5 * 4,width div 5 * 4,height div 5);
         end;
      end;
   end;

   PaintButton;                            { repaint rest }
end;

procedure TRoundButton.PaintButton;
var
   Dest,Source: TRect;
   outWidth,outHeight: integer;
begin
   if Assigned(FGlyph) then                { if has a bitmap }
   begin
      with Source do
      begin                                { setup bounding rectangle }
         Left:= 0; Top:= 0; Right:= FGlyph.Width; Bottom:= FGlyph.Height;

         if FNumGlyphs > 0 then
            Right:= Right div FNumGlyphs;
      end;
   end;

   with Canvas do
   begin                                   { draw top left edge }
      if FDown then  pen.color:= clBtnShadow else pen.color:= clBtnHighlight;
      Arc(1,1,width-2,height-2,width div 5 * 4,height div 5,width div 5,height div 5 * 4);
                                           { draw bottom right edge }
      if Not FDown then  pen.color:= clBtnShadow else pen.color:= clBtnHighlight;
      Arc(1,1,width-2,height-2,width div 5,height div 5 * 4,width div 5 * 4,height div 5);

{---place glyph---------------------------------------}
      if Assigned(FGlyph) and (FNumGlyphs > 0) then
      begin
         if(Not Enabled and (FNumGlyphs > 1)) then
         begin                             { draw disabled button }
            Source.Left:=  FGlyph.width div FNumGlyphs;
            Source.Right:= Source.Left shl 1;
         end;
                                           { setup output image retangle }
         outWidth:=  Source.Right-Source.Left;
         outHeight:= Source.Bottom-Source.Top;
                                           { find center }
         Dest.Left:=  ((Width  - outWidth)  shr 1);
         Dest.Right:= ((Width  - outWidth)  shr 1)+outWidth;
         Dest.Top:=   ((Height - outHeight) shr 1);
         Dest.Bottom:=((Height - outHeight) shr 1)+outHeight;

         Pen.Color:= clBtnFace;

         if FDown then
         begin                        { shift image position down and right 1 }
            Inc(Dest.Left); Inc(Dest.Right); Inc(Dest.Top); Inc(Dest.Bottom);
                                           { clear ghost }
            MoveTo(Dest.Left-1,Dest.Bottom);
            LineTo(Dest.Left-1,Dest.Top-1);
            LineTo(Dest.Right,Dest.Top-1);
         end
         else
         begin                             { clear ghost }
            MoveTo(Dest.Right,Dest.Top);
            LineTo(Dest.Right,Dest.Bottom);
            LineTo(Dest.Left,Dest.Bottom);
         end;

         if(FDown and (FNumGlyphs > 2)) then { show pushed image if available }
         begin
            Source.Left:= FGlyph.width div FNumGlyphs * 2;
            Source.Right:=FGlyph.width div FNumGlyphs * 3;
         end;
         Brush.Color:= clBtnFace;          { paint transparent image }
         BrushCopy(Dest,FGlyph,Source,FTransparentColor);
      end;
   end;
end;

procedure TRoundButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (Enabled and IsInsideButton(X,Y)) then
   begin
      FDown:= True;                        { push button and repaint }
      PaintButton;
   end;
   FMouseDown:= True;
end;

procedure TRoundButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (Enabled and IsInsideButton(X,Y)) then
   begin
      FDown:= False;                       { release button and repaint }
      PaintButton;
      if Assigned(FOnClick) then           { issue event to application }
         FOnClick(Self);
   end;
   FMouseDown:= False;
end;

procedure TRoundButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
   if FMouseDown then
   begin
      if Not IsInsideButton(X,Y) then
      begin
         if FDown then                     { mouse has slid off, so release }
         begin
            FDown:= False;
            PaintButton;
         end;
      end
      else
      begin
         if Not FDown then                 { mouse has slid back on, so push }
         begin
            FDown:= True;
            PaintButton;
         end;
      end;
   end;
end;

end.
