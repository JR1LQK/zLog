{-------------------------------------------------------------
-BPanel:  Visible Component used to display beveled edges    -
-simular to edges seen between button bars and pull-down     -
-menus in Windows 95.  Any combination of top,bottom,left and-
-right bevels can be shown.                                  -
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
unit Bpanel;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls;

type
  TBevelType = ( btInset, btOutset );

type
  TBevelPanel = class(TCustomPanel)
  private
    { Private declarations }
    FDrawTop:   boolean;
    FDrawBottom:boolean;
    FDrawLeft:  boolean;
    FDrawRight: boolean;

    FBevelType: TBevelType;
  protected
    { Protected declarations }
    procedure SetDrawTop(newDrawTop: boolean);
    procedure SetDrawBottom(newDrawBottom: boolean);
    procedure SetDrawLeft(newDrawLeft: boolean);
    procedure SetDrawRight(newDrawRight: boolean);

    procedure SetBevelType(newBevelType: TBevelType);
  public
    { Public declarations }
    procedure Paint; override;
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property DrawTop:    boolean read FDrawTop    write SetDrawTop;
    property DrawBottom: boolean read FDrawBottom write SetDrawBottom;
    property DrawLeft:   boolean read FDrawLeft   write SetDrawLeft;
    property DrawRight:  boolean read FDrawRight  write SetDrawRight;

    property BevelType:  TBevelType read FBevelType write SetBevelType;

    property Align;
    property Color;
    property Cursor;
  end;

implementation

procedure TBevelPanel.SetDrawTop(newDrawTop: boolean);
begin
   FDrawTop:= newDrawTop;
   Invalidate;
end;

procedure TBevelPanel.SetDrawBottom(newDrawBottom: boolean);
begin
   FDrawBottom:= newDrawBottom;
   Invalidate;
end;

procedure TBevelPanel.SetDrawLeft(newDrawLeft: boolean);
begin
   FDrawLeft:= newDrawLeft;
   Invalidate;
end;

procedure TBevelPanel.SetDrawRight(newDrawRight: boolean);
begin
   FDrawRight:= newDrawRight;
   Invalidate;
end;

procedure TBevelPanel.SetBevelType(newBevelType: TBevelType);
begin
   FBevelType:= newBevelType;
   Invalidate;
end;

constructor TBevelPanel.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   Width:= 100;
   Height:= 30;
   FBevelType:= btInset;
   FDrawBottom:= True;
   Color:= clBtnFace;
end;

procedure TBevelPanel.Paint;
var
   inColor, outColor: TColor;
begin
   if FBevelType = btInset then          { set bevel colors }
   begin
      inColor:= clBtnShadow;
      outColor:=clBtnHighlight;
   end
   else
   begin
      outColor:=clBtnShadow;
      inColor:= clBtnHighlight;
   end;

   with Canvas do
   begin
      pen.color:= clBtnFace; brush.color:= Color;
      Rectangle(0,0,width-1,height-1);   { clear center }

      if FDrawBottom then                { draw bottom? }
      begin
         pen.Color:= outColor; MoveTo(0,Height-1); LineTo(Width-1,Height-1);
         pen.Color:= inColor;  MoveTo(0,Height-2); LineTo(Width-1,Height-2);
      end;
      if FDrawRight then
      begin                              { draw right? }
         pen.Color:= outColor; MoveTo(Width-1,0); LineTo(Width-1,Height-1);
         pen.Color:= inColor;  MoveTo(Width-2,0); LineTo(Width-2,Height-1);
      end;
      if FDrawTop then
      begin                              { draw top? }
         pen.Color:= outColor; MoveTo(0,1); LineTo(Width-1,1);
         pen.Color:= inColor;  MoveTo(0,0); LineTo(Width-1,0);
      end;
      if FDrawLeft then
      begin                              { draw left? }
         pen.Color:= outColor; MoveTo(1,0); LineTo(1,Height-1);
         pen.Color:= inColor;  MoveTo(0,0); LineTo(0,Height-1);
      end;
   end;
end;

end.
