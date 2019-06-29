unit JLLabel;
{==========================================================================}
{ JL's RotateLabel with 3D-effects                                         }
{                                                                          }
{ Copyright © 1996 by Jörg Lingner, Munich, Germany (jlingner@t-online.de) }
{                                                                          }
{ FREEWARE                                                                 }
{ Free to use and redistribute.                                            }
{ No warranty is given by the author, expressed or implied.                }
{                                                                          }
{ 3D-effects: from RZLABEL-component                                       }
{ Copyright © by Ray Konopka (Raize Software Solutions, Inc.)              }
{--------------------------------------------------------------------------}
{ This component works like TLabel and has 2 additional properties:        }
{                                                                          }
{ Escapement: draw text with angle (0..360 deg)                            }
{             selected font must be a TrueType!!!                          }
{                                                                          }
{ TextStyle:  draw text with 3D-effects  tsRecessed                        }
{                                        tsRaised                          }
{                                        tsNone                            }
{                                                                          }
{--------------------------------------------------------------------------}
{ Vers.  Date   Remarks                                                    }
{ 1.0  30.03.97 Initial release                                            }
{                                                                          }
{==========================================================================}
interface

uses

  WinProcs, Wintypes, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus;

type
  TTextStyle = (tsNone,tsRaised,tsRecessed);

  TRotateLabel = class(TCustomLabel)
   private
    fEscapement : Integer;
    fTextStyle  : TTextStyle;
    procedure   SetEscapement(aVal:Integer);
    procedure   SetTextStyle (aVal:TTextStyle);
    procedure   CalcTextPos(var aRect:TRect;aAngle:Integer;aTxt:String);
    procedure   DrawAngleText(aCanvas:TCanvas;aRect:TRect;aAngle:Integer;aTxt:String);
   protected
    procedure   DoDrawText(var Rect:TRect;Flags:Word);
    procedure   Paint; override;
   public
    constructor Create(AOwner: TComponent); override;
   published
    property Escapement: Integer    read fEscapement write SetEscapement;
    property TextStyle : TTextStyle read fTextStyle  write SetTextStyle;
    property Align;
    property Alignment;
    property AutoSize;
    property Caption;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FocusControl;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
    property ShowHint;
    property Transparent;
    property Visible;
    property WordWrap;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    {$IFDEF WIN32}
    property OnStartDrag;
    {$ENDIF}
  end;

procedure Register;

{==========================================================================}
implementation



procedure Register;
{==========================================================================}
begin
  RegisterComponents('Grafik', [TRotateLabel]);
end;
{==========================================================================}

constructor TRotateLabel.Create(aOwner:TComponent);
{==========================================================================}
begin
  inherited Create(aOwner);

  fEscapement:= 45;
  fTextStyle := tsRaised;
  Font.Name := 'Arial';
end;
{==========================================================================}

procedure TRotateLabel.SetEscapement(aVal:Integer);
{==========================================================================}
begin
  if fEscapement <> aVal then begin
     if aVal < 0 then begin
        while aVal < -360 do aVal := aVal + 360;
        aVal := 360 + aVal;
     end;
     while aVal > 360 do aVal := aVal - 360;
     fEscapement := aVal;
     Invalidate;
  end;
end;
{==========================================================================}

procedure TRotateLabel.SetTextStyle(aVal:TTextStyle);
{==========================================================================}
begin
  if fTextStyle <> aVal then begin
     fTextStyle := aVal;
     Invalidate;
  end;
end;
{==========================================================================}

procedure TRotateLabel.Paint;
{==========================================================================}
const
  Alignments: array[TAlignment] of Word = (DT_LEFT,DT_RIGHT,DT_CENTER);
  WordWraps : array[Boolean] of Word = (0,DT_WORDBREAK);
var
  Rect: TRect;
begin
  with Canvas do begin
    if not Transparent then begin
      Brush.Color := Self.Color;
      Brush.Style := bsSolid;
      FillRect(ClientRect);
    end;
    Brush.Style := bsClear;
    Rect := ClientRect;
    DoDrawText(Rect,DT_EXPANDTABS or WordWraps[WordWrap] or Alignments[Alignment]);
  end;
end;
{==========================================================================}

procedure TRotateLabel.CalcTextPos(var aRect:TRect;aAngle:Integer;aTxt:String);
{==========================================================================}
{ Calculate text pos. depend. on: Font, Escapement, Alignment and length   }
{ if AutoSize true : set properties Height and Width                       }
{--------------------------------------------------------------------------}
var DC      : HDC;
    hSavFont: HFont;
    Size    : TSize;
    x,y     : Integer;
    cStr    : array[0..255] of Char;

begin
  StrPCopy(cStr,aTxt);
  DC := GetDC(0);
  hSavFont := SelectObject(DC,Font.Handle);
  {$IFDEF WIN32}
  GetTextExtentPoint32(DC,cStr,Length(aTxt),Size);
  {$ELSE}
  GetTextExtentPoint(DC,cStr,Length(aTxt),Size);
  {$ENDIF}
  SelectObject  (DC,hSavFont);
  ReleaseDC(0,DC);

  if          aAngle<=90  then begin             { 1.Quadrant }
     x := 0;
     y := Trunc(Size.cx * sin(aAngle*Pi/180));
  end else if aAngle<=180 then begin             { 2.Quadrant }
     x := Trunc(Size.cx * -cos(aAngle*Pi/180));
     y := Trunc(Size.cx *  sin(aAngle*Pi/180) + Size.cy * cos((180-aAngle)*Pi/180));
  end else if aAngle<=270 then begin             { 3.Quadrant }
     x := Trunc(Size.cx * -cos(aAngle*Pi/180) + Size.cy * sin((aAngle-180)*Pi/180));
     y := Trunc(Size.cy * sin((270-aAngle)*Pi/180));
  end else if aAngle<=360 then begin             { 4.Quadrant }
     x := Trunc(Size.cy * sin((360-aAngle)*Pi/180));
     y := 0;
  end;
  aRect.Top := aRect.Top +y;
  aRect.Left:= aRect.Left+x;

  x := Abs(Trunc(Size.cx * cos(aAngle*Pi/180))) + Abs(Trunc(Size.cy * sin(aAngle*Pi/180)));
  y := Abs(Trunc(Size.cx * sin(aAngle*Pi/180))) + Abs(Trunc(Size.cy * cos(aAngle*Pi/180)));

  if Autosize then begin
     Width  := x;
     Height := y;
  end else if Alignment = taCenter then begin
     aRect.Left:= aRect.Left + ((Width-x) div 2);
  end else if Alignment = taRightJustify then begin
     aRect.Left:= aRect.Left + Width - x;
  end;
end;
{==========================================================================}

procedure TRotateLabel.DrawAngleText(aCanvas:TCanvas;aRect:tRect;aAngle:Integer;aTxt:String);
{==========================================================================}
{ Draw text with FontIndirect (angle -> escapement)                        }
{--------------------------------------------------------------------------}
var LFont             : TLogFont;
    hOldFont, hNewFont: HFont;
begin
  CalcTextPos(aRect,aAngle,aTxt);

  GetObject(aCanvas.Font.Handle,SizeOf(LFont),Addr(LFont));
  LFont.lfEscapement := aAngle*10;
  hNewFont := CreateFontIndirect(LFont);
  hOldFont := SelectObject(aCanvas.Handle,hNewFont);

  aCanvas.TextOut(aRect.Left,aRect.Top,aTxt);

  hNewFont := SelectObject(aCanvas.Handle,hOldFont);
  DeleteObject(hNewFont);
end;
{==========================================================================}

procedure TRotateLabel.DoDrawText(var Rect:TRect;Flags:Word);
{==========================================================================}
{ Draw the text normal or with angle and with 3D-effects                   }
{                                                                          }
{ 3D-effects: RZLABEL-component                                            }
{ (c) by Ray Konopka (Raize Software Solutions, Inc.)                      }
{--------------------------------------------------------------------------}
var Text        : String;
    TmpRect     : TRect;
    UpperColor  : TColor;
    LowerColor  : TColor;
    {$IFDEF WINDOWS}
    cStr        : array[0..255] of Char;
    {$ENDIF}
  begin
    Text := Caption;
    {$IFDEF WINDOWS}
    StrPCopy(cStr,Text);
    {$ENDIF}

    if (Flags and DT_CALCRECT <> 0) and ((Text = '') or ShowAccelChar and
    (Text[1] = '&') and (Text[2] = #0)) then Text := Text + ' ';

    if not ShowAccelChar then Flags := Flags or DT_NOPREFIX;
    Canvas.Font := Font;

    UpperColor := clBtnHighlight;
    LowerColor := clBtnShadow;

    if FTextStyle = tsRecessed then begin
      UpperColor := clBtnShadow;
      LowerColor := clBtnHighlight;
    end;

    if FTextStyle in [tsRecessed,tsRaised] then begin
      TmpRect := Rect;
      OffsetRect(TmpRect,1,1);
      Canvas.Font.Color := LowerColor;
      if fEscapement <> 0 then DrawAngleText(Canvas,TmpRect,fEscapement,Text)
      {$IFDEF WIN32}
      else DrawText(Canvas.Handle,pChar(Text),Length(Text),TmpRect,Flags);
      {$ELSE}
      else DrawText(Canvas.Handle,cStr,Length(Text),TmpRect,Flags);
      {$ENDIF}

      TmpRect := Rect;
      OffsetRect(TmpRect,-1,-1);
      Canvas.Font.Color := UpperColor;
      if fEscapement <> 0 then DrawAngleText(Canvas,TmpRect,fEscapement,Text)
      {$IFDEF WIN32}
      else DrawText(Canvas.Handle,pChar(Text),Length(Text),TmpRect,Flags);
      {$ELSE}
      else DrawText(Canvas.Handle,cStr,Length(Text),TmpRect,Flags);
      {$ENDIF}
    end;

    Canvas.Font.Color := Font.Color;

    if not Enabled then Canvas.Font.Color := clGrayText;

    if fEscapement <> 0 then DrawAngleText(Canvas,Rect,fEscapement,Text)
    {$IFDEF WIN32}
    else DrawText(Canvas.Handle,pChar(Text),Length(Text),Rect,Flags);
    {$ELSE}
    else DrawText(Canvas.Handle,cStr,Length(Text),Rect,Flags);
    {$ENDIF}
end;
{==========================================================================}

end.
