{
   WARNING! THIS CODE IS PROVIDED AS IS WITH NO GUARANTEES OF ANY KIND!
   USE THIS AT YOUR OWN RISK - YOU ARE THE ONLY PERSON RESPONSIBLE FOR
   ANY DAMAGE THIS CODE MAY CAUSE - YOU HAVE BEEN WARNED!


   SplitBar component for Delphi

   Install this unit as a component and you can use whenever
   you're in need of one or more panels that have to be resized.
   Click on the bar and drag it around and it will resize the
   underlying control.
   The bar works like a panel so it has all the properties you
   know from TPanel.

   Added properties are:
   - SplitOrientation: Choose spHorizontal if you want to split
     the underlying control horizontally and spVertical for vertical
     splitting. Sorry for the confusion but I choose the identifiers
     as meaningful as Borlands Cursor property: You'll have a HSplit
     cursor when using spHorizontal splitting.
   - MinOffset/MaxOffset: If you don't want the underlying panel to be
     resized to the whole window.

   This software is free.

 	(c) 01-06/1996 by Guido Schoepp
   email: gus@abo.rhein-zeitung.de
}
unit SplitBar;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, ExtCtrls;

type
  TSplitOrientation = (spHorizontal, spVertical);

  TSplitBar = class(TPanel)
  private
	 fSplitDC : HDC;
    fSplitRect : TRect;
    fSplitOff,
    fSplitMax,
    fSplitMin : Integer;
    fSplitOrg : TPoint;
    fMouseIsDown : Boolean;
    fOrient : TSplitOrientation;
    fMaxOff,
    fMinOff : Integer;
    fClipRgn : HRGN;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
  	 constructor Create(aOwner:TComponent); override;
  published
    property SplitOrientation:TSplitOrientation read fOrient write fOrient default spHorizontal;
    property Cursor default crHSplit;
    property MinOffset:Integer read fMinOff write fMinOff default 0;
    property MaxOffset:Integer read fMaxOff write fMaxOff default 0;
  end;

	procedure Register;

implementation


constructor TSplitBar.create(aOwner:TComponent);
begin
	inherited Create(aOwner);
   fMouseIsDown := FALSE;
   fSplitDC := 0;
   fOrient := spHorizontal;
   Cursor := crHSplit;
end;

procedure TSplitBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	p : TPoint;
   r : TRect;
   parentForm : TForm;
begin
	if not fMouseIsDown then
   begin
		fMouseIsDown := TRUE;
		fSplitDC := GetWindowDC(0);

      parentForm := getParentForm(self);
      r := parentForm.clientRect;

      fSplitOrg := clientToScreen(Point(x, y));
      fSplitRect := clientRect;
      p := clientToScreen(fSplitRect.topLeft);
      fSplitRect := Rect(p.x, p.y, p.x+abs(fSplitRect.right-fSplitRect.left), p.y+abs(fSplitRect.bottom-fSplitRect.top));

      if fOrient=spHorizontal then
      begin
         p := parentForm.clientToScreen(r.topLeft);
         fSplitMin := p.x;
         p := parentForm.clientToScreen(r.bottomRight);
         fSplitMax := p.x;
	      fSplitOff := fSplitOrg.x-fSplitRect.left;
      end else
      begin
         p := parentForm.clientToScreen(r.topLeft);
         fSplitMin := p.y;
         p := parentForm.clientToScreen(r.bottomRight);
         fSplitMax := p.y;

	      fSplitOff := fSplitOrg.y-fSplitRect.top;
      end;

      r := Application.MainForm.clientRect;
      r.topLeft := Application.MainForm.clientToScreen(r.topLeft);
      r.bottomRight := Application.MainForm.clientToScreen(r.bottomRight);

      fClipRgn := WinProcs.CreateRectRgnIndirect(r);

      selectClipRgn(fSplitDC, fClipRgn);
      WinProcs.PatBlt(fSplitDC,
      				fSplitRect.left, fSplitRect.top,
                  fSplitRect.right-fSplitRect.left,
                  fSplitRect.bottom-fSplitRect.top,
                  PATINVERT);
	end;
end;

procedure TSplitBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
	p : TPoint;
begin
	if fMouseIsDown then
	begin
      WinProcs.PatBlt(fSplitDC,
      				fSplitRect.left, fSplitRect.top,
                  fSplitRect.right-fSplitRect.left,
                  fSplitRect.bottom-fSplitRect.top,
                  PATINVERT);

      p := clientToScreen(Point(x, y));
      if fOrient=spHorizontal then
      begin
	      fSplitRect := Rect(p.x-fSplitOff, fSplitRect.top,
         						p.x-fSplitOff+abs(fSplitRect.right-fSplitRect.left),
                           fSplitRect.bottom);
         if Align=alRight then
         begin
		      if fSplitRect.Left<fSplitMin+fMinOff then
      	      OffsetRect(fSplitRect, fSplitMin+fMinOff-fSplitRect.left, 0);
         	if fSplitRect.Right>fSplitMax-fMaxOff then
            	OffsetRect(fSplitRect, fSplitMax-fMaxOff-fSplitRect.right, 0);
         end else
         if Align=alLeft then
         begin
		      if fSplitRect.Left<fSplitMin+fMaxOff then
      	      OffsetRect(fSplitRect, fSplitMin+fMaxOff-fSplitRect.left, 0);
         	if fSplitRect.Right>fSplitMax-fMinOff then
            	OffsetRect(fSplitRect, fSplitMax-fMinOff-fSplitRect.right, 0);
         end;
		end else
      begin
	      fSplitRect := Rect(fSplitRect.left, p.y-fSplitOff,
         					fSplitRect.right, p.y-fSplitOff+abs(fSplitRect.bottom-fSplitRect.top));

         if Align=alBottom then
         begin
            if fSplitRect.top<fSplitMin+fMinOff then
               OffsetRect(fSplitRect, 0, fSplitMin+fMinOff-fSplitRect.top);
            if fSplitRect.bottom>fSplitMax-fMaxOff then
               OffsetRect(fSplitRect, 0, fSplitMax-fMaxOff-fSplitRect.bottom);
         end else
         if Align=alTop then
         begin
            if fSplitRect.top<fSplitMin+fMaxOff then
               OffsetRect(fSplitRect, 0, fSplitMin+fMaxOff-fSplitRect.top);
            if fSplitRect.bottom>fSplitMax-fMinOff then
               OffsetRect(fSplitRect, 0, fSplitMax-fMinOff-fSplitRect.bottom);
         end;
      end;
      WinProcs.PatBlt(fSplitDC,
      				fSplitRect.left, fSplitRect.top,
                  fSplitRect.right-fSplitRect.left,
                  fSplitRect.bottom-fSplitRect.top,
                  PATINVERT);
   end;
end;

procedure TSplitBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   off : Integer;
begin
	if fMouseIsDown then
   begin
      WinProcs.PatBlt(fSplitDC,
      				fSplitRect.left, fSplitRect.top,
                  fSplitRect.right-fSplitRect.left,
                  fSplitRect.bottom-fSplitRect.top,
                  PATINVERT);

      if fOrient=spHorizontal then
      begin
      	off := fSplitOrg.x-(fSplitOff+fSplitRect.left);
	      if Align = alLeft then
		      parent.width := parent.width + off
	      else if Align = alRight then
		      parent.width := parent.width - off;
      end else
      begin
      	off := fSplitOrg.y-(fSplitOff+fSplitRect.top);
	      if Align = alTop then
		      parent.height := parent.height + off
      	else if Align = alBottom then
	      	parent.height := parent.height - off;
      end;

		DeleteObject(fClipRgn);
      fClipRgn := 0;

      if (fSplitDC<>0) then
	      ReleaseDC(0, fSplitDC);
      fSplitDC := 0;

   	fMouseIsDown := FALSE;
   end;
end;


procedure Register;
begin
  RegisterComponents('test', [TSplitBar]);
end;


end.
