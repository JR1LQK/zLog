unit Mjwcrt;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, stdctrls, printers, clipbrd;

{ TMJWcrt component - version 1.00b

  Copyright 1996 (c) by Michael Wilcox
  Email:  mwilcox@economat.demon.co.uk

  This component:
    - is Freeware, do not pay money for it!!!
    - is used at your own risk.
    - is open to amendments - please give credit.
    - can be published or supplied on CD-ROM (only if not amended)
    - would be ideal for a debug screen, terminal emulator, DOS Screens etc.

  Thanks to:
    - Danny Thorpe, (Tconsole)
    - Marco Cantu, "Mastering Delphi"
    - Dave Jewell, PC PRO magazine.
    - David P J Hill, for use of compuserve.
    - Borland & TeamB (compuserve)

  Features:
    - Simple text output screen (Fixed-spaced fonts only).
    - 132 columns.
    - 24 rows.
    - change Text & Background Colours.
    - Fast automatic scrolling.
    - Copy screen to clipboard.
    - Print screen to printer.

  Last Note:
    - Please Email me if you use this component, I would value your comments
      and let you know of updates.
    - I feel it is wrong for developers to charge for components, they should be
      written to support Borland Delphi and its users - otherwise it could be a
      world of C++ and Visual Basic. It should be the completed application that
      is sold - if you must make money!!!
    - Oh yes Borland - why did you not include an Async Comms VCL with Delphi 2?
    - Please, please, please let me know if you use this component.

  Thank you... enjoy...

  Amendment History - contributions with thanks:
  	1.00a		11/06/96		Uploaded to Compuserve.
    1.00b		14/06/96		Thomas A. Digate	-	Compile with hints & warnings:
    																				Destroy; override; added.
                                            Remove variables not used.
                        Michael Wilcox    - Bug fix: refresh problem,
                                            ClrEoL and CMscrollPaint.
                                            Added: #12: ClrScr; to WriteBuf.
                                            Property Cursor = true or false.
                                            Showcursor/Hidecursor now Protected.
                                            Added: procedure WMGetDlgCode.
                                            Print screen with black text, title
                                            and its own font.
                                            PrinterFont added.
                                            Tscrn now has 25 rows (same as DOS).
                                            Set80Mode & Set132Mode - procedures.
}

const cm_scrollpaint = wm_user+100;
      version = '1.00b';

type
	Tscrn = record
  	pos : array[1..132, 1..25] of record
    	ch	: char;
      bk,cl 	: Tcolor;
      end;
    end;

  TCMScrollPaint = record
  	Msg : Cardinal;
  end;

  TLineBreak = (CRLF, CR);

  TMJWcrt = class(TCustomControl)
  private
    { Private declarations }
    FFocused : Boolean;
    FLineBreak : TLinebreak;
    Metrics : TTextMetric;
    CharSize : TPoint;
    CharAscent : Integer;
    Scrn : Tscrn;
    Invrect : TRect;
    procedure WMSize(var M: TWMSize); message wm_Size;
    procedure WMSetfocus(Var M: TWMsetFocus); message wm_setfocus;
    procedure WMKillFocus(Var M: TWMKillFocus); message wm_killfocus;
    procedure WMGetDlgCode(Var M: TWMGetDlgCode); message wm_getdlgcode;
    procedure FastScroll;
    procedure CMScrollPaint(var M: TCMScrollPaint); message cm_scrollpaint;
  protected
    { Protected declarations }
    Ffont, FPfont, F80Font, F132Font : TFont;
    Fcol, Frow : integer;
    FBackColor : TColor;
    FTextColor : TColor;
    FOwnerDraw : boolean;
    FScrolling : Boolean;
    FCursor : Boolean;
    CurPos : Tpoint;
    Scrollcnt : integer;
    PC : array[0..255] of char;
    procedure SetFont(FF : TFont);
    procedure SetPFont(FF : TFont);
    procedure Set80Font(FF : TFont);
    procedure Set132Font(FF : TFont);
    procedure ReDrawBMP;
    procedure ShowText(L, R: Integer);
    procedure SetTextColor(tc : Tcolor);
    procedure SetBackColor(bc : Tcolor);
    procedure SetCol(c : integer);
    procedure SetRow(r : integer);
    procedure SetCursor(cr : boolean);
    procedure Loaded; override;
    procedure Fontchanged(Sender:Tobject);
    procedure ShowCursor; virtual;												{Show Cursor}
    procedure HideCursor;																	{Hide Cursor}
  public
    { Public declarations }
    constructor Create(Owner : Tcomponent); override;
    destructor Destroy; override;
    procedure Paint; override;														{Paint Method}
    procedure ClrScr;																			{Clears Whole Screen}
    procedure ClrEol;																			{Clears to End of Line}
    procedure ClrEoP;																			{Clears to End of Page}
    procedure WriteBuf(Buffer: PChar; Count: Word);				{Prints Buffer}
    procedure WriteChar(Ch: Char);												{Prints Character}
    procedure Writeln(ss: Tcaption);											{Prints String with Return}
    procedure Write(ss: Tcaption);												{Prints String}
    procedure GotoXY(x,y: integer);												{Moves Cursor Location}
    function  WhereX : integer;														{Gets Cursor X Location}
    function  WhereY : integer;														{Gets Cursor Y Location}
    procedure Print; 																			{Prints Screen Graphically}
    procedure Copy;  																			{Copy screen to clipboard}
    procedure Set80Mode;																	{Use 80 columns and Font80}
    procedure Set132Mode;																	{Use 132 columns and Font132}
  published
    { Published declarations }
    property Font : TFont Read FFont write SetFont;
    property PrinterFont : TFont Read FPFont write SetPFont;
    property Font80 : TFont Read F80Font write Set80Font;
    property Font132 : TFont Read F132Font write Set132Font;
    property BackColor : Tcolor read FBackColor write setBackcolor;
    property TextColor : Tcolor read FTextColor write setTextcolor;
    property Columns : integer Read Fcol write SetCol;
    property Rows : integer Read Frow Write SetRow;
    property OwnerDraw : Boolean read FOwnerDraw Write FOwnerDraw default False;
    property LineBreak : TLineBreak read FLineBreak write FLineBreak;
    property Cursor : Boolean read Fcursor write SetCursor default True;
    property Left;
    property Top;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnKeyPress;
    property OnKeyDown;
    property OnKeyUp;
    property Visible;
    property ShowHint;
  end;

procedure Register;

implementation

{ Register component }
procedure Register;
begin
  RegisterComponents('Mick', [TMJWcrt]);
end;

{ Create }
constructor TMJWcrt.Create(Owner :TComponent);
begin
	inherited Create(Owner);
  FScrolling := false;
  Fcol := 80;
  Frow := 24;
  FOwnerDraw := false;
  Fcursor := true;
  parentcolor := false;
  FFont := TFont.create;
  FPFont := TFont.create;
  F80Font := TFont.create;
  F132Font := TFont.create;
  with FFont do
  begin
		name := 'Courier New';
  	size := 8;
  	style := [];
  end;
  SetPFont(FFont);
  Set80Font(FFont);
  Set132Font(FFont);
  FBackColor := color;
 	FTextColor := FFont.color;
  clrscr;
  FFont.onchange := Fontchanged;
end;

{ Destroy }
destructor TMJWcrt.destroy;
begin
	hidecursor;
  FFont.free;
  FPFont.free;
  F132Font.free;
  F80Font.free;
	inherited destroy;
end;

{ Clear screen when loaded }
procedure TMJWcrt.loaded;
begin
	inherited Loaded;
  clrscr;
end;

{ Set Font }
procedure TMJWcrt.SetFont(FF : TFont);
begin
  FFont.Assign(FF);
  invalidate;
  Fontchanged(FFont);
end;

{ Set Printer Font }
procedure TMJWcrt.SetPFont(FF : TFont);
begin
  FPFont.Assign(FF);
end;

{ Set 80 Font }
procedure TMJWcrt.Set80Font(FF : TFont);
begin
  F80Font.Assign(FF);
end;

{ Set 132 Font }
procedure TMJWcrt.Set132Font(FF : TFont);
begin
  F132Font.Assign(FF);
end;

{ Get Font Details }
procedure TMJWcrt.FontChanged(Sender:Tobject);
var
  DC: HDC;
begin
  canvas.font := FFont;
  DC := GetDC(0);
  SelectObject(DC, Font.Handle);
	GetTextMetrics(DC, Metrics);
  ReleaseDC(0, DC);
  CharSize.X := Metrics.tmAveCharWidth;
	CharSize.Y := Metrics.tmHeight + Metrics.tmExternalLeading;
	CharAscent := Metrics.tmAscent;
  width := Fcol*charsize.x;
  height := Frow*charsize.y;
  update;
end;

{ Show Cursor }
procedure TMJWcrt.ShowCursor;
begin
	if not handleallocated then exit;
  if FCursor = true then
  begin
	  CreateCaret(Handle, 0, charsize.x, charsize.y);
  	SetCaretPos((curpos.X-1)*charsize.x,((curpos.Y-1)*charsize.y));
  	showCaret(Handle);
  end;
end;

{ Hide Cursor }
procedure TMJWcrt.HideCursor;
begin
	destroycaret;
end;

{ Set Cursor on or off }
procedure TMJWcrt.SetCursor(cr : boolean);
begin
	Fcursor := cr;
  if Fcursor = false then HideCursor;
  if (Fcursor = true) and (FFocused = true) then ShowCursor;
end;

{ Clears Whole Screen }
procedure TMJWcrt.clrscr;
var xx,yy : integer;
    s : string;
    NewRect: TRect;
begin
	for yy := 1 to 25 do
  begin
  for xx := 1 to 132 do
  begin
		with scrn do
    begin
    	pos[xx,yy].ch := ' ';
      pos[xx,yy].bk := FBackColor;
      pos[xx,yy].cl := FTextColor;
    end;
  end;
  end;
  if (csDesigning in componentstate) then
  begin
		s := 'Copyright (c) 1996, Michael Wilcox - Version: '+version;
    for xx := 1 to length(s) do
	  begin
			with scrn do
    	begin
    		pos[xx,1].ch := s[xx];
      	pos[xx,1].bk := FBackColor;
      	pos[xx,1].cl := FTextColor;
    	end;
  	end;
  end;
  curpos.X := 1;
	curpos.Y := 1;
	if handleallocated then
  begin
	  if FFocused = true then hidecursor;
    color := FBackColor;
	  NewRect := Rect(0, 0, width, height);
    canvas.brush.color := FBackColor;
  	Canvas.FillRect(NewRect);
    if FFocused = true then showcursor;
   end else
  begin
   	update;
  end;
end;

{Clear to end of line}
procedure TMJWcrt.clrEol;
var xx : integer;
begin
  for xx := curpos.x to fcol do
  begin
		with scrn do
    begin
    	pos[xx,curpos.y].ch := ' ';
      pos[xx,curpos.y].bk := FBackColor;
      pos[xx,curpos.y].cl := FTextColor;
    end;
  end;
	showtext(curpos.x,Fcol);
end;

{Clear to end of page}
procedure TMJWcrt.clrEoP;
var xx,yy : integer;
		b : Trect;
begin
  clrEoL;
	if Curpos.Y+1 <= Frow then
	begin
		for yy := Curpos.Y+1 to Frow do
		begin
      for xx := 1 to fcol do
		  begin
				with scrn do
		    begin
    		pos[xx,yy].ch := ' ';
      	pos[xx,yy].bk := FBackColor;
      	pos[xx,yy].cl := FTextColor;
		    end;
		  end;
		end;
		b:= clientrect;
    b.top  := (curpos.y)* charsize.y;
    invalidaterect(handle , @b, false);
    if FOwnerDraw = false then update;
  end;
end;

{ Return the smaller of two integer values }
function Min(X, Y: Integer): Integer;
begin
  if X < Y then Min := X else Min := Y;
end;

{ Return the larger of two integer values }
function Max(X, Y: Integer): Integer;
begin
  if X > Y then Max := X else Max := Y;
end;

{ FastScroll by removing multiple messages cm_scrollpaint }
procedure TMJWcrt.fastscroll;
var msg : TMSG;
begin
	if handleallocated then
  begin
		if peekmessage(Msg, handle, cm_ScrollPaint, cm_scrollpaint, PM_Remove) then
    begin
      Fscrolling := true;
      inc(scrollcnt,1);
    end;
    if scrollcnt > (round(Frow div 4)*3) then
    begin
      Perform(cm_scrollpaint, 0, 0);
    end else
    begin
    	Postmessage(handle,cm_scrollpaint, 0, 0);
    end;
  end;
end;

{ CMscrollpaint message }
procedure TMJWcrt.CMscrollpaint(var M : TCMScrollPaint);
var cr : trect;
begin
   	{redraw screen}
		cr := clientrect;
	  invalidaterect(handle,@cr,false);
	  update;
	  Fscrolling := false;
	 	scrollcnt := 0;
end;

{ Write text buffer to CRT window }
procedure TMJWcrt.WriteBuf(Buffer: PChar; Count: Word);
var
  L, R: Integer;

procedure Return;
begin
  if (Fscrolling= false) and (curpos.y<>FRow) then ShowText(L, R);
  L := 1;
  R := 1;
  Curpos.X := 1;
end;

procedure NewLine;
var xx: integer;
begin
  if (Fscrolling= false) and (curpos.y<>FRow) then ShowText(L, R);
  Inc(Curpos.Y);
  if Curpos.Y > Frow then
  begin
    {Scroll up}
    Curpos.Y := frow;
    move(scrn.pos[1,2],scrn.pos[1,1], sizeof(scrn));
	  for xx := 1 to 132 do
  	begin
			with scrn do
	    begin
  	  	pos[xx,frow].ch := ' ';
    	  pos[xx,frow].bk := FBackColor;
        pos[xx,frow].cl := FTextColor;
	    end;
    end;
    fastscroll;
  end;
end;

begin
  L := Curpos.X;
  R := Curpos.X;
  while Count > 0 do
  begin
    case Buffer^ of
      #32..#255: 		begin
									 	 Scrn.pos[Curpos.X, Curpos.Y].ch := Buffer^;
								     Scrn.pos[Curpos.X, Curpos.Y].bk := FBackColor;
								     Scrn.pos[Curpos.X, Curpos.Y].cl := FTextColor;
									 	 Inc(Curpos.X);
									 	 if Curpos.X > R then R := Curpos.X;
									 	 if Curpos.X > Fcol then
                     begin
                     		Return;
                        NewLine;
                     end;
										end;
      #13:					begin
      					      if FLineBreak = CR then
                      begin
							        	Return;
                      end else
                      begin
                      	Return;
	      								NewLine;
                      end;
      							end;
      #10:					NewLine;
      #12:					ClrScr;
      #8:           if (Curpos.X > 1) then
										begin
	  									Dec(Curpos.X);
	  									Scrn.Pos[Curpos.X, Curpos.Y].ch := ' ';
    									Scrn.pos[Curpos.X, Curpos.Y].bk := FBackcolor;
    									Scrn.pos[Curpos.X, Curpos.Y].cl := FTextColor;
										  if Curpos.X < L then L := Curpos.X;
									    showtext(L,R);
									  end else
									  begin
									  	{backspace to previous line}
									    if (curpos.y > 1) then
									    begin
										  	Curpos.x := Fcol;
									  	  if curpos.y > 1 then dec(curpos.y,1);
									    	Scrn.Pos[Curpos.X, Curpos.Y].ch := ' ';
									    	Scrn.pos[Curpos.X, Curpos.Y].bk := FBackcolor;
									    	Scrn.pos[Curpos.X, Curpos.Y].cl := FTextColor;
										  	if Curpos.X < L then L := Curpos.X;
									    	if Curpos.X > R then R := Curpos.X;
									      showtext(L,R);
									    end;
										end;
      #7:           MessageBeep(0);
    end;
    Inc(Buffer);
    Dec(Count);
  end;
  if (Fscrolling= false) then ShowText(L, R);
end;

{ Write character to CRT window }
procedure TMJWcrt.WriteChar(Ch: Char);
begin
  WriteBuf(@Ch, 1);
end;

{ Adds return to end of line }
procedure TMJWcrt.Writeln(ss: Tcaption);
begin
	strPcopy(pc, ss+#13);
  WriteBuf(@pc[0], length(ss)+1);
end;

{ Writes text }
procedure TMJWcrt.Write(ss: Tcaption);
begin
	strPcopy(pc, ss);
  WriteBuf(@pc[0], length(ss));
end;

{ Moves Cursor to x,y }
procedure TMJWcrt.Gotoxy(x,y: integer);
begin
	if FFocused then hidecursor;
	Curpos.x := Max(1, Min(x, Fcol));
  Curpos.y := Max(1, Min(y, Frow));
  if FFocused then showcursor;
end;

{ Get X location }
function  TMJWcrt.WhereX : integer;
begin
	whereX := curpos.x;
end;

{ Get Y Location }
function  TMJWcrt.WhereY : integer;
begin
  whereY := curpos.y;
end;

{ Print screen Graphically }
procedure TMJWcrt.print;
var
  xx,yy : integer;
  MyFile: system.text;
  s : string;
begin
  Printer.Title := Application.title+' - Print Screen';
  Printer.canvas.brush.color := clwhite;
  Printer.Canvas.Font := FPFont;
  Printer.Canvas.Font.color := clblack;
  AssignPrn(MyFile);
  Rewrite(MyFile);
	for yy := 1 to Frow do
  begin
  s:= '';
  for xx := 1 to Fcol do
  begin
		with scrn do
    begin
      s:=s+pos[xx,yy].ch;
    end;
  end;
  system.Writeln(MyFile, s);
  end;
  System.CloseFile(MyFile);
end;

{ Copy screen to clipboard }
procedure TMJWcrt.copy;
var
  xx,yy : integer;
  s : string;
  memo : Tmemo;
begin
	memo := Tmemo.create(self);
  memo.visible := false;
  memo.parent := parent;
	for yy := 1 to Frow do
  begin
  s:= '';
  for xx := 1 to Fcol do
  begin
		with scrn do
    begin
      s:=s+pos[xx,yy].ch;
    end;
  end;
  memo.lines.add(s);
  end;
  memo.selectall;
  memo.copytoclipboard;
  memo.free;
end;

{ Invalidates Line }
procedure TMJWcrt.ShowText(L, R: Integer);
var B : Trect;
begin
  if handleallocated and (L <= R) then
  begin
  	b.left := (L-1) * charsize.x;
    b.top  := (curpos.y-1)* charsize.y;
    b.right:= r * charsize.x;
    b.bottom:=(b.top + charsize.y);
    invalidaterect(handle , @b, false);
    if FOwnerDraw = false then update;
	end;
end;

{ Set Text Colour }
procedure TMJWcrt.SetTextColor(tc : Tcolor);
begin
	FTextcolor := tc;
  if (csDesigning in componentstate) then
  begin
      clrscr;
      paint;
	end;
end;

{ Set Background Colour }
procedure TMJWcrt.SetBackColor(bc : Tcolor);
begin
	FBackcolor := bc;
  if (csDesigning in componentstate) then
  begin
      clrscr;
      paint;
  end;
end;

{ Set Number of Columns }
procedure TMJWcrt.SetCol(c : integer);
begin
	if (c > 1) and ( c <= 132) then
  begin
		FCol := c;
  	width := c*charsize.x;
    if curpos.x > c then curpos.x := c;
    if (csDesigning in componentstate) then
 		begin
      clrscr;
      paint;
    end;
  end;
end;

{ Set Number of Rows }
procedure TMJWcrt.SetRow(r : integer);
begin
	if (r > 1) and ( r <= 25) then
  begin
		FRow := r;
  	height := r*charsize.y;
    if curpos.y > r then curpos.y := r;
    if (csDesigning in componentstate) then
  	begin
	    clrscr;
      paint;
  	end;
  end;
end;

{Set display to 80 mode using Font80}
procedure TMJWcrt.Set80Mode;
begin
	if Fcol <> 80 then
  begin
		Fcol := 80;
		setfont(F80Font);
  end;
end;

{Set display to 132 mode using Font132}
procedure TMJWcrt.Set132Mode;
begin
	if Fcol <> 132 then
  begin
		Fcol := 132;
 		setfont(F132Font);
  end;
end;

{ Fontchange on resize }
procedure TMJWcrt.WMSize(var M:TWMSize);
begin
	inherited;
  if FOwnerDraw = false then
  begin
  	if FFocused then hidecursor;
 		fontchanged(FFont);
	  if FFocused then showcursor;
  end;
end;

{ set focus to show cursor }
procedure TMJWcrt.WMSetFocus(var M :TWMSetfocus);
begin
	FFocused := true;
  showcursor;
  inherited;
end;

{ killfocus will hidecursor }
procedure TMJWcrt.WMKillFocus(var M :TWMKillfocus);
begin
	inherited;
 	FFocused := false;
  hidecursor;
end;

{ key codes }
procedure TMJWcrt.WMGetDlgCode(var M :TWMGetDlgCode);
begin
	M.Result := DLGC_WantArrows or DLGC_WantChars or DLGC_WantAllKeys or DLGC_WantTab;
end;

{ Paint Method }
procedure TMJWcrt.Paint;
begin
	if FOwnerDraw = false then
  begin
   	redrawbmp;
  end;
end;

{ redraw screen }
procedure TMJWcrt.ReDrawBMP;
var x2,y2,x1,y1, RunStart, RunEnd, len, count : integer;
		cbrect : Trect;
    buf : array[0..133] of char;
    s:string;
    cb, cp : Tcolor;
begin
	if not handleallocated then exit;
  if ffocused = true then hidecursor;
  cbrect := Canvas.ClipRect;
	x1 := Max(0, cbrect.left div charsize.x);
  x2 := Min(Fcol, (cbrect.right+charsize.x-1) div charsize.x);
  y1 := Max(0, cbrect.top div charsize.y);
  y2 := Min(Frow, (cbrect.bottom+charsize.y-1) div charsize.y);
  While y1 < y2 do
  begin
    Runend := x1;
    count := x2-x1;
    cbrect.top := y1*charsize.y;
    cbrect.bottom := y1*charsize.y+charsize.y;
    while count > 0 do
    begin
			runstart := runend;
  	  cb      := scrn.pos[runstart+1,y1+1].bk;
    	cp      := scrn.pos[runstart+1,y1+1].cl;
      s := '';
      repeat
	      inc(runend);
        s := s+scrn.pos[runend,y1+1].ch;
      until (runend > x2) or (scrn.pos[runend+1,y1+1].bk <> cb) or (scrn.pos[runend+1,y1+1].cl <> cp);
      StrPCopy(buf, s);
      Len := length(s);
      count := x2 - runend;
      cbrect.left  := runstart*charsize.x;
      cbrect.right := cbrect.left+(len*charsize.x);
      canvas.brush.color := cb;
  	  canvas.font.color := cp;
			ExtTextOut(Canvas.Handle, cbrect.left, cbrect.top, ETO_CLIPPED or
      ETO_OPAQUE, @cbRect, buf, Len, nil);
    end;
    inc(y1);
	end;
 if ffocused = true then showcursor;
end;

end.
