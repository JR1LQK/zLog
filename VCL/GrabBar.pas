{ -------------------------------------------------------------------------------------}
{ A grab bar, or splitter, to allow two windows to be resized simultaneously.          }
{ Copyright 1996, Brad Stowers.  All Rights Reserved.                                  }
{ This component can be freely used and distributed in commercial and private          }
{ environments, provied this notice is not modified in any way.                        }
{ -------------------------------------------------------------------------------------}
{ Feel free to contact me if you have any questions, comments or suggestions at        }
{ bstowers@pobox.com or 72733,3374 on CompuServe.                                      }
{ -------------------------------------------------------------------------------------}
{ Date last modified:  12/10/96                                                        }
{ -------------------------------------------------------------------------------------}

{ -------------------------------------------------------------------------------------}
{ TGrabBar v1.04                                                                       }
{ -------------------------------------------------------------------------------------}
{ Description:                                                                         }
{   A bar that allows two TWinControl components to be resized by dragging it.         }
{ Problems:                                                                            }
{   Because of the DCX_PARENTCLIP in GetDCEx, moving bar over controls that            }
{     are not involved in the moving process will get a bar drawn on them.             }
{     But, in practice, the bar should never be in a position to move over             }
{     windows that it is not connected with.  Without this, couldn't see bar           }
{     over controls created after it.                                                  }
{   Does not get along with siblings who are alClient aligned.  Use a TPanel           }
{     as parent of bar and siblings and align the panel as alClient.                   }
{                                                                                      }
{ Needs:                                                                               }
{   Keyboard interface.                                                                }
{ -------------------------------------------------------------------------------------}
{ Revision History:                                                                    }
{ 1.00:  + Initial release                                                             }
{ 1.01:  + Stupid last minute optimization broke the thing.  Fixed.                    }
{ 1.02:  + Automatically adjusts windows it owns to proper alignment in this way:      }
{            Alignment of alNone is not adjusted.  alClient is changed to              }
{            alLeft/alRight or alTop/alBottom based on current divider style.          }
{            alLeft/alRight and alTop/alBottom are validated, i.e. if WindowA property }
{            is aligned alRight, it is changed to be alLeft, or if WindowB was alLeft  }
{            in a gbHorizonal bar, it would be changed to alTop.                       }
{        + Changing the style now will now move the control to the center of parent    }
{            window.  Before it would be something silly like flush top or left.       }
{ 1.03:  + Resource for 16 and 32-bit version.  This takes the place of a              }
{          DCR file, which can't be compatible with both.  See the $R directive below. }
{          To compile the resource file, use the following                             }
{            Delphi 1: BRCC.EXE -foGrabBar.r16 -31 GrabBar.rc                          }
{            Delphi 2: BRCC32.EXE -foGrabBar.r32 -w32 GrabBar.rc                       }
{ 1.04:  + Fixed problem that could allow bar to be moved under controls that were not }
{          being separated by the bar.  This would hide the bar from the user.         }
{        + Fixed bug that would, under certain conditions, cause the bar to have an    }
{          incorrect thickness.                                                        }
{        + Fixed bug that would allow you to select the same window for both WindowA   }
{          and WindowB properties.  Caused nasty crash when the control is removed.    }
{        + Added DragUpdate property that resizes the split windows as you drag the    }
{          grab bar.                                                                   }
{ -------------------------------------------------------------------------------------}

unit GrabBar;

interface

{$IFDEF WIN32}
  {$R GrabBar.r32}
{$ELSE}
  {$R GrabBar.r16}
{$ENDIF}

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TGrabBarStyle = (gbHorizontal, gbVertical);

  TGrabBar = class(TCustomControl)
  private
    { Property Variables }
    FBorderStyle: TBorderStyle;
    FStyle: TGrabBarStyle;
    FWindowA,
    FWindowB: TWinControl;
    FDragUpdate: boolean;

    { Event Variables }
    FOnMove: TNotifyEvent;

    { Internal Variables }
    LastRect: TRect;
    OldWndProc: TFarProc;
    NewWndProc: Pointer;
    FDragging: boolean;

    { Utility functions }
    procedure HookParent;
    procedure UnhookParent;
    procedure HookWndProc(var Message: TMessage);

    function BarRect(APoint: TPoint): TRect;
    function ClientToParent(APoint: TPoint): TPoint;
    procedure InvertedRect(R: TRect; InvertLast: boolean);
    procedure MoveWindows;
    procedure ResizeBar;

    { Message response methods }
    procedure CMCtl3DChanged(var Message: TMessage);  message CM_CTL3DCHANGED;
    procedure WMMove(var Msg: TWMMove);               message WM_MOVE;
    procedure WMSize(var Msg: TWMSize);               message WM_SIZE;
  protected
    { Property methods }
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetStyle(Value: TGrabBarStyle);
    function GetThickness: Integer;
    procedure SetThickness(Value: Integer);
    procedure SetWindowA(Value: TWinControl);
    procedure SetWindowB(Value: TWinControl);

    { Overriden methods }
    procedure SetParent(Value: TWinControl);                   override;
    procedure Paint;                                           override;
    procedure MouseDown(Button: TMouseButton;
                        Shift: TShiftState; X, Y: Integer);    override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);    override;
    procedure MouseUp(Button: TMouseButton;
                      Shift: TShiftState; X, Y: Integer);      override;
    procedure Notification(AComponent: TComponent;
                           Operation: TOperation);             override;
    procedure SetBounds(ALeft,ATop,AWidth,AHeight: Integer);   override;
  public
    constructor Create(AOwner: TComponent);                    override;
    destructor Destroy;                                        override;
  published
    { Properties }
    property BorderStyle: TBorderStyle
             read FBorderStyle write SetBorderStyle
             default bsSingle;
    property DragUpdate: boolean
             read FDragUpdate write FDragUpdate
             default FALSE;
    property Style: TGrabBarStyle
             read FStyle write SetStyle
             default gbHorizontal;
    property Thickness: integer
             read GetThickness write SetThickness;
    property WindowA: TWinControl
             read FWindowA write SetWindowA;
    property WindowB: TWinControl
             read FWindowB write SetWindowB;
    { Events }
    property OnMove: TNotifyEvent
             read FOnMove write FOnMove;

    { Publish Inherited Protected Properties }
    property Color;
    property Ctl3D;
    property Cursor
             default crVSplit;
    property Hint;
    property ParentColor;
    property ParentCtl3D;
    property ParentShowHint;
    property ShowHint;
    property Visible;

    { Publish Inherited Protected Events }
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  procedure Register;

implementation

{ Note that the "hook" is not installed here.  Parent is not valid in the }
{ constructor.  See SetParent.                                            }
constructor TGrabBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  { Initialize variables }
  FDragging := FALSE;
  FDragUpdate := FALSE;
  NewWndProc := NIL;
  OldWndProc := NIL;
  SetRectEmpty(LastRect);
  { Set Defaults }
  FBorderStyle := bsSingle;
  FStyle := gbHorizontal;
  Cursor := crVSplit;
  Thickness := 4
end;

destructor TGrabBar.Destroy;
begin
  if FDragging then { Remove the clipping of the mouse cursor }
    ClipCursor(NIL);
  { Always make sure that the hook is removed. }
  UnhookParent;
  inherited Destroy;
end;

{ This procedure is used to get the parent's window procedure, save it,      }
{ and replace it with our own.  This allows see all of the parent's messages }
{ before it does.                                                            }
procedure TGrabBar.HookParent;
begin
  { If there is no parent, we can't hook it. }
  if Parent = NIL then exit;
  { Get the old window procedure via API call and store it. }
  OldWndProc := TFarProc(GetWindowLong(Parent.Handle, GWL_WNDPROC));
  { Convert our object method into something Windows knows how to call }
  NewWndProc := MakeObjectInstance(HookWndProc);
  { Install it as the new Parent window procedure }
  SetWindowLong(Parent.Handle, GWL_WNDPROC, LongInt(NewWndProc));
end;

{ Remove our window function and reinstall the original. }
procedure TGrabBar.UnhookParent;
begin
  { We must have a parent, and we must have already hooked it. }
  if (Parent <> NIL) and assigned(OldWndProc) then
    { Set back to original window procedure }
    SetWindowLong(Parent.Handle, GWL_WNDPROC, LongInt(OldWndProc));
  { If we have created a window procedure via MakeObjectInstance, }
  { it must be disposed of.                                       }
  if assigned(NewWndProc) then
    FreeObjectInstance(NewWndProc);
  { Reset variables to NIL }
  NewWndProc := NIL;
  OldWndProc := NIL;
end;

{ The window procedure that is installed into our parent. }
procedure TGrabBar.HookWndProc(var Message: TMessage);
begin
  { If there's no parent, something has really gone wrong. }
  if Parent = NIL then exit;
  with Message do begin
    { If Parent gets a WM_SIZE message, it has been resized }
    if (Msg = WM_SIZE) and (wParam <> SIZE_MINIMIZED) then begin
      { We need to resize the bar so it fits in the new size }
      ResizeBar;
      { And update the positions of the windows we control }
      MoveWindows;
    end;

    { ALWAYS call the old window procedure so the parent can process its    }
    { messages.  Thanks to Gary Frerking for pointing me at CallWindowProc. }
    { I was trying to call the function directly, which died horribly.      }
    Result := CallWindowProc(OldWndProc, Parent.Handle, Msg, wParam, lParam);
  end;
end;

{ Function to calculate rectangle coordinates of the bar given a point. }
function TGrabBar.BarRect(APoint: TPoint): TRect;
begin
  SetRectEmpty(Result);
  if Parent = nil then exit;
  if FStyle = gbHorizontal then
    Result := Bounds(0, APoint.Y - (Thickness div 2),
                     Parent.ClientWidth, Thickness)
  else
    Result := Bounds(APoint.X - (Thickness div 2), 0,
                     Thickness, Parent.ClientHeight);
end;

{ Convert from our client coordinates to parent's client coordinates. }
function TGrabBar.ClientToParent(APoint: TPoint): TPoint;
begin
  if Parent = NIL then
    Result := ClientToScreen(APoint)
  else begin
    Result := ClientToScreen(APoint);
    Result := Parent.ScreenToClient(Result);
  end;
end;

{ Draw an inverted rectangle on the parent to indicate where the bar }
{ will be when it is released.                                       }
procedure TGrabBar.InvertedRect(R: TRect; InvertLast: boolean);
var
  aDC: hDC;
begin
  if Parent = nil then exit;
  { Get the parent's device context (something we can draw on).  Flags }
  { indicate that we want to be able to draw anywhere on the parent,   }
  { regardless of what it's child windows have to say about it.  Also  }
  { speed it up a bit.                                                 }
  aDC := GetDCEx(Parent.Handle, 0, DCX_PARENTCLIP or DCX_CACHE);
  { Invert the last rectange we drew to remove it. }
  { Inverted + Inverted = NOT Inverted.            }
  if InvertLast and not IsRectEmpty(LastRect) then
    InvertRect(aDC, LastRect);
  { Draw the new rectangle }
  InvertRect(aDC, R);
  { Release the DC when done with it or very bad things will happen. }
  ReleaseDC(Parent.Handle, aDC);
end;

{ Reposition the windows we are responsible for. }
procedure TGrabBar.MoveWindows;
  { Move the top or left window by setting its height or width }
  procedure MoveWindowA;
  begin
    if FStyle = gbHorizontal then
      FWindowA.Height := Top - FWindowA.Top
    else
      FWindowA.Width := Left - FWindowA.Left;
  end;

  { Move the bottom or right window by recalculating its Top or Left }
  procedure MoveWindowB;
  var
    X, Y: integer;
  begin
    if FStyle = gbHorizontal then begin
      X := Top + Thickness;
      Y := FWindowB.Height + FWindowB.Top - X;
      with FWindowB do SetBounds(Left, X, Width, Y);
    end else begin
      X := Left + Thickness;
      Y := FWindowB.Width + (FWindowB.Left - X);
      with FWindowB do SetBounds(X, Top, Y, Height);
    end;
  end;
begin
  if Parent = NIL then exit;
  { Disable parent aligning until we move both windows.  If we don't, the    }
  { parent will try to reposition aligned controls when they are moved.      }
  { This produces scrollbars in some cases and annoying flicker most always. }
  Parent.DisableAlign;
  if assigned(FWindowA) then
    MoveWindowA;
  if assigned(FWindowB) then
    MoveWindowB;
  { Tell parent it can align controls now if it wants.  We have repositioned }
  { windows and they should not need further moving.                         }
  Parent.EnableAlign;
end;

{ Reset the bar's size to fill the client's width or height. }
procedure TGrabBar.ResizeBar;
begin
  if (Parent = NIL) then exit;
  if FStyle = gbHorizontal then
    SetBounds(0, Top, Parent.ClientWidth, Thickness)
  else
    SetBounds(Left, 0, Thickness, Parent.ClientHeight);
end;

{ The value of the Ctl3D property has changed, invalidate the control so }
{ that it is redrawn to reflect the change.                              }
procedure TGrabBar.CMCtl3DChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

{ We have been moved.  Make sure we are as wide or tall as the parent. }
procedure TGrabBar.WMMove(var Msg: TWMMove);
begin
  inherited;
  ResizeBar;
end;

{ We have been resized.  Make sure we are as wide or tall as the parent. }
procedure TGrabBar.WMSize(var Msg: TWMSize);
begin
  inherited;
  ResizeBar;
end;

{ BorderStyle property has changed.  Redraw control to reflect change. }
procedure TGrabBar.SetBorderStyle(Value: TBorderStyle);
begin
  if Value = FBorderStyle then exit;
  FBorderStyle := Value;
  Invalidate;
end;

{ A Parent has been assigned or changed.  Unhook old parent and install }
{ hook in new parent.                                                   }
procedure TGrabBar.SetParent(Value: TWinControl);
begin
  { UnhookParent knows if the current parent has been hooked or not }
  UnhookParent;
  { Set Parent to the new value }
  inherited SetParent(Value);
  { Hook the new parent's window procedure }
  HookParent;
  { Size ourselves to fill the new parent's client area }
  ResizeBar;
  { Position our windows accordingly }
  MoveWindows;
end;

{ Set whether the bar is horizontal or vertical, setting the cursor }
{ accordingly. }
procedure TGrabBar.SetStyle(Value: TGrabBarStyle);
begin
  if Value = FStyle then exit;
  FStyle := Value;
  if FStyle = gbHorizontal then begin
    Cursor := crVSplit;
    Height := Width;
{    if Parent <> NIL then
      Top := Parent.ClientHeight div 2;}
  end else begin
    Cursor := crHSplit;
    Width := Height;
{    if Parent <> NIL then
      Left := Parent.ClientWidth div 2;}
  end;
  ResizeBar;
end;

{ Return the thickness of the bar, depending on the orientation. }
function TGrabBar.GetThickness: integer;
begin
  if FStyle = gbHorizontal then
    Result := Height
  else
    Result := Width;
end;

{ Set the thickness, depending on the orientation. }
procedure TGrabBar.SetThickness(Value: integer);
begin
  if (Value = Thickness) or (Value < 0) then exit;
  if FStyle = gbHorizontal then
    Height := Value
  else
    Width := Value;
end;

{ Set a window we are responsible for.  Do not allow selection of ourself or }
{ the other window being split.                                              }
procedure TGrabBar.SetWindowA(Value: TWinControl);
begin
  if (Value = FWindowA) or (Value = FWindowB) or (Value = Self) then exit;
  FWindowA := Value;
  { Position it correctly with the bar. }
  MoveWindows;
end;

{ Set a window we are responsible for.  Do not allow selection of ourself or }
{ the other window being split.                                              }
procedure TGrabBar.SetWindowB(Value: TWinControl);
begin
  if (Value = FWindowA) or (Value = FWindowB) or (Value = Self) then exit;
  FWindowB := Value;
  { Position it correctly with the bar. }
  MoveWindows;
end;

{ TCustomControl descendants know nothing about how to paint themselves.  }
{ We are entirely responsible for drawing ourself. There is no reason to  }
{ call the inherited method.                                              }
procedure TGrabBar.Paint;
var
  Offset: byte;
begin
  with Canvas do begin
    { Set the background color to the color the user has selected }
    Brush.Color := Color;

    if FBorderStyle = bsSingle then begin
      { If there is a border, set the color to Windows' frame color }
      { and set and offset so we don't draw over in Ctl3D painting  }
      Pen.Color := clWindowFrame;
      Offset := 1;
    end else begin
      { If no border, hide it by setting the pen to the same color }
      { as the background.  No offset needed for Ctl3D painting    }
      Pen.Color := Color;
      Offset := 0;
    end;
    { Draw the bar }
    with ClientRect do Rectangle(Left, Top, Right, Bottom);

    { CTL3D.DLL knows nothing about how to 3-D shade a grab bar, so }
    { we have to simulate it ourselves, accounting for a frame      }
    if Ctl3D then begin
      { Draw the left and top lines in white }
      Pen.Color := clWhite;
      MoveTo(Offset, Height-Offset-1);
      LineTo(Offset, Offset);
      LineTo(Width-Offset-1, Offset);
      { Draw the right and bottom lines in gray }
      Pen.Color := clGray;
      LineTo(Width-Offset-1, Height-Offset-1);
      LineTo(Offset, Height-Offset-1);
    end;
  end;
end;

{ Mouse button has been pressed.  Setup for moving the bar. This is only }
{ called when the application is running, not in design mode.            }
procedure TGrabBar.MouseDown(Button: TMouseButton;
                             Shift: TShiftState; X, Y: Integer);
  function Min(i1, i2: integer): integer;
  begin
    if i1 > i2 then
      Result := i2
    else
      Result := i1;
  end;

  function Max(i1, i2: integer): integer;
  begin
    if i1 < i2 then
      Result := i2
    else
      Result := i1;
  end;
var
  WARect, WBRect,
  ClipRect: TRect;
begin
  inherited MouseDown(Button, Shift, X, Y);
  { If no parent or not left button pressed, no reason to go on }
  if (Parent = NIL) or (Button <> mbLeft) then exit;

(*
  { Get the rectangle of our parent }
  ClipRect := Parent.ClientRect;
  { Convert rectangle to screen coords. Simpler than calling ClientToScreen }
  { twice, once for TopLeft and again for BottomRight                       }
  with Parent.ClientOrigin do OffsetRect(ClipRect, X, Y);
*)

  if WindowA = NIL then
    GetWindowRect(Parent.Handle, WARect)
  else
    GetWindowRect(WindowA.Handle, WARect);

  if WindowB = NIL then
    GetWindowRect(Parent.Handle, WBRect)
  else
    GetWindowRect(WindowB.Handle, WBRect);

  with ClipRect do begin
    Left := Min(WARect.Left, WBRect.Left);
    Top := Min(WARect.Top, WBRect.Top);
    Right := Max(WARect.Right, WBRect.Right);
    Bottom := Max(WARect.Bottom, WBRect.Bottom);
  end;

  { Subtract our size from the rectange }
  if FStyle = gbHorizontal then begin
    Inc(ClipRect.Top, Thickness div 2);
    Dec(ClipRect.Bottom, (Thickness div 2) - 1);
  end else begin
    Inc(ClipRect.Left, Thickness div 2);
    Dec(ClipRect.Right, (Thickness div 2) - 1);
  end;

  { Clip the mouse cursor to the rectangle.  Prevents from moving out of it }
  ClipCursor(@ClipRect);
  FDragging := TRUE;
  LastRect := BoundsRect;
  if not FDragUpdate then { Draw the indicator bar }
    InvertedRect(LastRect, FALSE);
end;

{ The mouse has moved.  Move the indicator bar accordingly. }
procedure TGrabBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  R: TRect;
begin
  inherited MouseMove(Shift, X, Y);
  if (ssLeft in Shift) and FDragging then begin
    { Convert our client point to our parent's client point }
    R := BarRect(ClientToParent(Point(X,Y)));
    { If the bar is still in the same place as last time, }
    { there's nothing to do                               }
    if EqualRect(R, LastRect) or IsRectEmpty(R) then exit;
    if not FDragUpdate then { Draw the indicator bar }
      InvertedRect(R, TRUE);
    LastRect := R;

    if FDragUpdate then { Update the bar's position.  This updates windows, too}
      if FStyle = gbHorizontal then
        Top := LastRect.Top
      else
        Left := LastRect.Left;
  end;
end;

{ The mouse button has been released, update the position of the }
{ bar and it's windows.                                          }
procedure TGrabBar.MouseUp(Button: TMouseButton;
                           Shift: TShiftState; X, Y: Integer);
var
  OldRect,
  Intersect: TRect;
begin
  inherited MouseUp(Button, Shift, X, Y);
  { Don't do anything if it wasn't the left button. }
  if not ((Button = mbLeft) and FDragging) then exit;

  { Remove the clipping of the mouse cursor }
  ClipCursor(NIL);
  FDragging := FALSE;
  if not IsRectEmpty(LastRect) then begin
    if not FDragUpdate then { Remove the last indicator bar }
      InvertedRect(LastRect, FALSE);
    OldRect := BoundsRect;
    { Update the bar position.  Because SetBounds is overridden, }
    { the other windows will be moved accordingly.               }
    if FStyle = gbHorizontal then
      Top := LastRect.Top
    else
      Left := LastRect.Left;
    if not FDragUpdate then begin
      { If new rect is in old rect, part of inverted rect gets left over. }
      { Invalidate the control and update so it is repainted immediately. }
      IntersectRect(Intersect, LastRect, OldRect);
      if not IsRectEmpty(Intersect) then begin
        Invalidate;
        Update;
      end;
    end;
  end;
  SetRectEmpty(LastRect);
  { Fire the OnMove event if there is one }
  if assigned(FOnMove) then
    FOnMove(Self);
end;

{ We have be notified of a change in the on-form components. If it is one }
{ that we are responsible for, update variables accordingly.              }
procedure TGrabBar.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if Operation = opRemove then begin
    if AComponent = FWindowA then
      FWindowA := NIL;
    if AComponent = FWindowB then
      FWindowB := NIL;
  end;
end;

{ Every change to Top, Left, Width and Height come through this procedure.  }
{ The statement: Top := 10; will result in the procedure being called.  By  }
{ overriding it, we can ensure that the windows our repositioned every time }
{ we are moved.                                                             }
procedure TGrabBar.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  MoveWindows;
end;

{ Add the components to the Delphi Component Palette.  You will want to }
{ modify this so that it appears on the page of your choice.            }
procedure Register;
begin
  RegisterComponents('My Controls', [TGrabBar]);
end;

end.
