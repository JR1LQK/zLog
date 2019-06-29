unit SoftButt;
{

    *** SoftButt.Pas by Rickard Dahlstrand  (c)Tilde Konsult 1997 ***

    This Component is like the Speedbutton except for the softborders, nice ehh?
    And some other stuff I played around with. And as a BONUS, the --> SoftPann <--
    just like a panel but...

    This is creditware so by using this you have to accept the following condition.
    You can change my code or use it as is, but whatever you do please include me in
    your creditline!  Like this... ' Thanks to rickard@tilde.se for the SoftButts... '
    If you don't like doing this, mail me and we'll discuss it!

    AND...

    I like credit in my mailbox too!! So if you like this or/and have made improvements,
    MAIL ME!!!

    If anyone looking for useless things to do, try to derive the TSoftButt from TButton,
    if you do, please mail me a copy!!

    /rickard@tilde.se

}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons;

type
  TSoftButt = class(TSpeedButton)
  private
    focused: Boolean;
    Sshowfocusring: Boolean;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ShowFocusRing: Boolean read Sshowfocusring write Sshowfocusring default True;
  end;

  TSoftPann = class(TPanel)
  protected
    procedure Paint; override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Standard', [TSoftButt]);
  RegisterComponents('Standard', [TSoftPann]);
end;

// Just init some values...
constructor TSoftButt.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  showfocusring := True;
  Height := 25;
  Width := 35;
end;

// Draw a focusline on mouseenter
procedure TSoftButt.CMMouseEnter(var Message: TMessage);
begin
  focused := True;
  Repaint;
end;

// Remove the focusline on mouseleave
procedure TSoftButt.CMMouseLeave(var Message: TMessage);
begin
  focused := False;
  Repaint;
end;

// This is the BUTT paint method...
procedure TSoftButt.Paint;

// Small proc to make one pixels dots...
procedure Dotme(Yta: TCanvas; x,y: Integer);
begin
  Yta.MoveTo(x, y);
  Yta.LineTo(x+1, y);
end;

var
  MaxX, MaxY: Integer;
  rect: TRect;
begin
  inherited Paint;  // Draw all other stuff before drawing my stuff...

  With Self, Canvas do
  begin
    If Flat then  // If the butt is flat, don't draw anything...
      If not focused then exit; // Unless it is focused, the draw all...

    If FState = bsDown then begin // If but is down...
      MaxX := ClientWidth -1;  // The max X value I can use...
      MaxY := ClientHeight -1; // The max Y value I can use...

      Brush.Color := $02BFBFBF; // Don't make me comment this,
      Pen.Color := $02BFBFBF;   // just a bit of drawing...
      Pen.Color := $02E7E7E7;
      MoveTo(MaxX, 0);
      LineTo(MaxX, MaxY);
      LineTo(0, MaxY);
      Pen.Color := $02666666;
      LineTo(0, 0);
      LineTo(1, 1);
      LineTo(0, 0);
      LineTo(MaxX, 0);
      Pen.Color := $02999999;
      MoveTo(MaxX, 1);
      LineTo(2, 1);
      LineTo(2, 2);
      LineTo(1, 2);
      LineTo(1, MaxY);
      Dotme(Canvas, 0, MaxY);
      Dotme(Canvas, MaxX, 0);
      Pen.Color := $02BFBFBF;
      Dotme(Canvas, MaxX, 2);
      Dotme(Canvas, MaxX, 1);
      Dotme(Canvas, 1, MaxY);
      Pen.Color := $02FFFFFF;
      Dotme(Canvas, MaxX-1, MaxY-1);
    end
    else begin  // If butt is up..
      MaxX := ClientWidth -1;
      MaxY := ClientHeight -1;
      Rect.Top := 2;            // Init some focus rect values
      Rect.Left := 2;
      Rect.Right := MaxX -2;
      Rect.Bottom := MaxY -2;

      Brush.Color := $02BFBFBF;
      Pen.Color := $02BFBFBF;
      Pen.Color := $02E7E7E7;
      // Draw focusrect...
      If focused and Sshowfocusring then Canvas.DrawFocusRect(Rect);
      MoveTo(MaxX, 0);
      LineTo(0, 0);
      LineTo(0, MaxY);
      Pen.Color := $02666666;
      LineTo(MaxX, MaxY);
      LineTo(MaxX-1, MaxY-1);
      LineTo(MaxX, MaxY);
      LineTo(MaxX, 0);
      Pen.Color := $02999999;
      MoveTo(MaxX-1, 0);
      LineTo(MaxX-1, MaxY-2);
      LineTo(MaxX-2, MaxY-2);
      LineTo(MaxX-2, MaxY-1);
      LineTo(0, MaxY-1);
      Dotme(Canvas, 0, MaxY);
      Dotme(Canvas, MaxX, 0);
      Pen.Color := $02BFBFBF;
      Dotme(Canvas, 0, MaxY-2);
      Dotme(Canvas, 0, MaxY-1);
      Dotme(Canvas, MaxX-1, 0);
      Pen.Color := $02FFFFFF;
      Dotme(Canvas, 1, 1);
    end;
  end;

end;
// This is the PANN paint method...
procedure TSoftPann.Paint;

// Small proc to make one pixels dots...
procedure Dotme(Yta: TCanvas; x,y: Integer);
begin
  Yta.MoveTo(x, y);
  Yta.LineTo(x+1, y);
end;

var
  MaxX, MaxY: Integer;
begin
  inherited Paint;

  With Self, Canvas do
  begin  // used the OUTER bevel, but it's easy to modify...
    If BevelOuter = bvNone then Exit;  // Don't draw, no bevel...
    If BevelOuter = bvLowered then begin  // Like buttdown...
      MaxX := ClientWidth -1;
      MaxY := ClientHeight -1;

      Brush.Color := $02BFBFBF;
      Pen.Color := $02BFBFBF;
      Pen.Color := $02E7E7E7;
      MoveTo(MaxX, 0);
      LineTo(MaxX, MaxY);
      LineTo(0, MaxY);
      Pen.Color := $02666666;
      LineTo(0, 0);
      LineTo(1, 1);
      LineTo(0, 0);
      LineTo(MaxX, 0);
      Pen.Color := $02999999;
      MoveTo(MaxX, 1);
      LineTo(2, 1);
      LineTo(2, 2);
      LineTo(1, 2);
      LineTo(1, MaxY);
      Dotme(Canvas, 0, MaxY);
      Dotme(Canvas, MaxX, 0);
      Pen.Color := $02BFBFBF;
      Dotme(Canvas, MaxX, 2);
      Dotme(Canvas, MaxX, 1);
      Dotme(Canvas, 1, MaxY);
      Pen.Color := $02FFFFFF;
      Dotme(Canvas, MaxX-1, MaxY-1);
    end
    else begin  // Like buttup, but no focusline...
      MaxX := ClientWidth -1;
      MaxY := ClientHeight -1;

      Brush.Color := $02BFBFBF;
      Pen.Color := $02BFBFBF;
      Pen.Color := $02E7E7E7;
      MoveTo(MaxX, 0);
      LineTo(0, 0);
      LineTo(0, MaxY);
      Pen.Color := $02666666;
      LineTo(MaxX, MaxY);
      LineTo(MaxX-1, MaxY-1);
      LineTo(MaxX, MaxY);
      LineTo(MaxX, 0);
      Pen.Color := $02999999;
      MoveTo(MaxX-1, 0);
      LineTo(MaxX-1, MaxY-2);
      LineTo(MaxX-2, MaxY-2);
      LineTo(MaxX-2, MaxY-1);
      LineTo(0, MaxY-1);
      Dotme(Canvas, 0, MaxY);
      Dotme(Canvas, MaxX, 0);
      Pen.Color := $02BFBFBF;
      Dotme(Canvas, 0, MaxY-2);
      Dotme(Canvas, 0, MaxY-1);
      Dotme(Canvas, MaxX-1, 0);
      Pen.Color := $02FFFFFF;
      Dotme(Canvas, 1, 1);
    end;
  end;
end;

end.
