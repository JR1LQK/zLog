unit CalPop97;

(******************************************************************************
tFrmCalPop97

This form unit is used by the DateEdit97 component.

Author name=BOURMAD Mehdi
Author E-mail=bourmad@mygale.org
Author URL=www.mygale.org/~bourmad
******************************************************************************)

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls;

const
   m_DaysPerMonth: array[1..12] of Integer =
    (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

type
  TfrmCalPop97 = class(TForm)
    procedure FormCancel;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    Button_Width,Button_Height,BORDER,TEXT_INDENT: integer;
    m_CurrentDateSelected: TDateTime;
    m_FontWidth: Integer;
    m_FontHeight: Integer;
    m_DateArray: array[1..42] of string[2];
    m_CurrentDateIndex: Integer;
    m_PreviousDateHighlight,
    m_PreviousDateIndex: Integer;
    m_MouseDown: Bool;
    m_CurrentDay, m_CurrentYear, m_CurrentMonth: Word;
    m_PreviousDay, m_PreviousYear, m_PreviousMonth: Word;
    ParentColor:TColor;
    ctlParent : tComponent;
    procedure ClosePopup;
    procedure WMMouseActivate(var Message: TWMActivate); Message WM_MOUSEACTIVATE;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
  protected
    function DaysInMonth(nMonth: Integer): Integer;
    procedure DrawButtons;
    procedure DrawCalendarBorder;
    Function GetGoodColor (dtTest : tDateTime) : tColor;
    procedure DrawDates;
    procedure DrawDaysHeader;
    procedure EraseDateFrame(nIndex: Integer);
    procedure DrawFocusFrame(nIndex: Integer; IsUp : boolean);
    procedure DrawMonthHeader;
    function GetMonthBegin: Integer;
    function GetCalendarRect: TRect;
    function GetLeftButtonRect: TRect;
    function GetRightButtonRect: TRect;
    function GetDblLeftButtonRect: TRect;
    function GetDblRightButtonRect: TRect;
    function GetCancelButtonRect: TRect;
    function GetRectFromIndex(nIndex: Integer): TRect;
    function GetIndexFromDate: Integer;
    function GetIndexFromPoint(nLeft: Integer; nTop: Integer): Integer;
    function IsLeapYear: Boolean;
    procedure LoadDateArray;
    procedure NextDay;
    procedure PrevDay;
    procedure NextWeek;
    procedure PrevWeek;
    procedure NextMonth;
    procedure PrevMonth;
    procedure NextYear;
    procedure PrevYear;
    procedure SetDate(nDays: Integer);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  DateEd97;

{$R *.DFM}

procedure DrawLine(Canvas:TCanvas;X1,Y1,X2,Y2:integer);
begin
  Canvas.MoveTo(X1,Y1);
  Canvas.LineTo(X2,Y2);
end;

function PointInRect(const rectTest: TRect; X, Y: Integer): Boolean;
begin
  Result := ((X >= rectTest.Left) and
             (X <= rectTest.Right) and
             (Y >= rectTest.Top) and
             (Y <= rectTest.Bottom));
end;

{************************** Create ************************
 *****  This procedure is used to initialize values   *****
 *****  for control owner, calendar position and      *****
 *****  other resources.                              *****
 **********************************************************}
constructor TfrmCalPop97.Create(AOwner: TComponent);
var
   tmTextMetrics: TTextMetric;
   rectPlace: TRect;
   ptUpper, ptLower: TPoint;
   nTop, nLeft : Integer;
begin
  inherited Create(AOwner);

  ctlParent := AOwner;

  (ctlParent as TDateEdit97).DoDate;                          

  {if the FontWidth is not set, determine Font Height and Width for
   positioning Dates}
  with Canvas do
  begin
    Font := (ctlParent as TDateEdit97).Font;
    ParentColor := Font.Color;
    Pen.Color := ParentColor;
    GetTextMetrics(Handle, tmTextMetrics);
    m_FontWidth :=  Round(tmTextMetrics.tmAveCharWidth +
                          tmTextMetrics.tmAveCharWidth * 6 / 10);
    m_FontHeight :=  Round(tmTextMetrics.tmHeight +
                           tmTextMetrics.tmHeight / 3);

    Button_Width := m_FontWidth * 3 div 2;
    if Button_Width < 16
      then Button_Width := 16;
    Button_Height := Button_Width;
    BORDER := Button_width div 8 + 1;          
    TEXT_INDENT := BORDER;
  end;

  {Initialize form Height & Width based on Font }
  Height := (m_FontHeight * 6) + (m_FontHeight * 2) + (BORDER * 2);
  Width := ((m_FontWidth *3) * 7) + (2* BORDER) + (2* TEXT_INDENT);
  {comment : m_FontWidth *3 = width for 1 character}

  {Dynamically set the size and position}
  rectPlace := (ctlParent as TDateEdit97).ClientRect;
  ptUpper.X := rectPlace.Left;
  ptUpper.Y := rectPlace.Top;
  ptUpper := (ctlParent as TDateEdit97).ClientToScreen(ptUpper);
  ptLower.X := rectPlace.Right;
  ptLower.Y := rectPlace.Bottom;
  ptLower := (ctlParent as TDateEdit97).ClientToScreen(ptLower);

  {if too far down, pop the calendar above the control}
  if ptUpper.X + 1 + Width > Screen.Width then
    nLeft := Screen.Width - Width - 1
  else
    nLeft := ptUpper.X + 1;

  if ptLower.Y + 1 + Height > Screen.Height then
    nTop := ptUpper.Y - Height
  else
    nTop := ptLower.Y + 1;

  SetBounds (nLeft, nTop, Width, Height);

  {Define initial date}
  m_CurrentDateSelected := Date;

  {Extract date Components}
  DecodeDate(m_CurrentDateSelected, m_CurrentYear, m_CurrentMonth, m_CurrentDay);
  m_CurrentDateIndex := m_CurrentDay + GetMonthBegin - 1;
  m_PreviousDateIndex := 0;
  m_PreviousDateHighlight := 0;

  LoadDateArray;
  m_MouseDown := False;

end;

{*********************** FormShow *************************
 *****  This procedure is used to initialize values   *****
 *****  for control owner, calendar position and      *****
 *****  other resources when showing it               *****
 **********************************************************}
procedure TfrmCalPop97.FormShow(Sender: TObject);
var
   rectPlace: TRect;
   ptUpper, ptLower: TPoint;
   nTop, nLeft : Integer;
begin
  {Transform the number in date to assign it to varibles}
  (ctlParent as TDateEdit97).DoDate;                          

  {Initialize form Height & Width based on Font }
  Height := (m_FontHeight * 6) + (m_FontHeight * 2) + (BORDER * 2);
  Width := ((m_FontWidth *3) * 7) + (2* BORDER) + (2* TEXT_INDENT);
  {comment : m_FontWidth *3 = width for 1 character}

  {Dynamically set the size and position}
  rectPlace := (ctlParent as TDateEdit97).ClientRect;
  ptUpper.X := rectPlace.Left;
  ptUpper.Y := rectPlace.Top;
  ptUpper := (ctlParent as TDateEdit97).ClientToScreen(ptUpper);
  ptLower.X := rectPlace.Right;
  ptLower.Y := rectPlace.Bottom;
  ptLower := (ctlParent as TDateEdit97).ClientToScreen(ptLower);

  {if too far down, pop the calendar above the control}
  if ptUpper.X + 1 + Width > Screen.Width then
    nLeft := Screen.Width - Width - 1
  else
    nLeft := ptUpper.X + 1;

  if ptLower.Y + 1 + Height > Screen.Height then
    nTop := ptUpper.Y - Height
  else
    nTop := ptLower.Y + 1;

  SetBounds (nLeft, nTop, Width, Height);

  {Define initial date}
  if (Length((ctlParent as TDateEdit97).Text)=0)
  or (ctlParent as TDateEdit97).PopupToday
  then
    m_CurrentDateSelected := Date
  else
    try
      m_CurrentDateSelected := StrToDate((ctlParent as TDateEdit97).Text)
    except
      m_CurrentDateSelected := Date;
    end;

  {Extract date Components}
  DecodeDate(m_CurrentDateSelected, m_CurrentYear, m_CurrentMonth, m_CurrentDay);
  m_CurrentDateIndex := m_CurrentDay + GetMonthBegin - 1;
  m_PreviousDateIndex := 0;
  m_PreviousDateHighlight := 0;

  LoadDateArray;
  m_MouseDown := False;
end;

procedure TfrmCalPop97.ClosePopup;
begin
  if (ctlParent as TDateEdit97).IsModal
    then Close;
  (ctlParent as TDateEdit97).PopupCalendar(Self);
end;

{********************** WMMouseActivate *******************
 ***  These functions hide calendar when it loose focus ***
 **********************************************************}
procedure TfrmCalPop97.WMMouseActivate(var Message: TWMActivate);
begin
  inherited;
  Message.Result := MA_NOACTIVATE;
end;

procedure TfrmCalPop97.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if Visible
    then ClosePopup;
end;

{********************** Days In Month *********************
 *****  This function returns the number of days in   *****
 *****  the month specified in nMonth.                *****
 **********************************************************}
function TfrmCalPop97.DaysInMonth(nMonth: Integer): Integer;
begin
  Result := m_DaysPerMonth[nMonth];
  if (nMonth = 2) and IsLeapYear then Inc(Result); { leap-year Feb is special }
end;

{******************** Draw Butttons ***********************
 **********************************************************}
procedure TfrmCalPop97.DrawButtons;
var
  LeftButtonRect: TRect;
  RightButtonRect: TRect;
  DblLeftButtonRect: TRect;
  DblRightButtonRect: TRect;
  CancelButtonRect: TRect;
  OldStyle: TBrushStyle;
  ArrowWMarg,
  ArrowHMarg : integer;
begin
  with Canvas do
  begin
    LeftButtonRect := GetLeftButtonRect;
    RightButtonRect := GetRightButtonRect;
    DblLeftButtonRect := GetDblLeftButtonRect;
    DblRightButtonRect := GetDblRightButtonRect;
    CancelButtonRect := GetCancelButtonRect;

    {Select Solid Pen}
    Pen.Style := psSolid;
    Pen.Width := 1;

    {Create Embossed effect - Outline left & upper in white}
    Pen.Color := clWhite;
    MoveTo(LeftButtonRect.Left, LeftButtonRect.Bottom - 1);
    LineTo(LeftButtonRect.Left, LeftButtonRect.Top);
    LineTo(LeftButtonRect.Right - 1, LeftButtonRect.Top);

    MoveTo(RightButtonRect.Left, RightButtonRect.Bottom - 1);
    LineTo(RightButtonRect.Left, RightButtonRect.Top);
    LineTo(RightButtonRect.Right - 1, RightButtonRect.Top);

    MoveTo(DblLeftButtonRect.Left, DblLeftButtonRect.Bottom - 1);
    LineTo(DblLeftButtonRect.Left, DblLeftButtonRect.Top);
    LineTo(DblLeftButtonRect.Right - 1, DblLeftButtonRect.Top);

    MoveTo(DblRightButtonRect.Left, DblRightButtonRect.Bottom - 1);
    LineTo(DblRightButtonRect.Left, DblRightButtonRect.Top);
    LineTo(DblRightButtonRect.Right - 1, DblRightButtonRect.Top);

    MoveTo(CancelButtonRect.Left, CancelButtonRect.Bottom - 1);
    LineTo(CancelButtonRect.Left, CancelButtonRect.Top);
    LineTo(CancelButtonRect.Right - 1, CancelButtonRect.Top);

    {Create Embossed effect - Outline right & bottom in gray }
    Pen.Color := clBtnShadow;
    MoveTo(LeftButtonRect.Right - 1, LeftButtonRect.Top);
    LineTo(LeftButtonRect.Right - 1, LeftButtonRect.Bottom - 1);
    LineTo(LeftButtonRect.Left, LeftButtonRect.Bottom - 1);

    MoveTo(RightButtonRect.Right - 1, RightButtonRect.Top);
    LineTo(RightButtonRect.Right - 1, RightButtonRect.Bottom - 1);
    LineTo(RightButtonRect.Left, RightButtonRect.Bottom - 1);

    MoveTo(DblLeftButtonRect.Right - 1, DblLeftButtonRect.Top);
    LineTo(DblLeftButtonRect.Right - 1, DblLeftButtonRect.Bottom - 1);
    LineTo(DblLeftButtonRect.Left, DblLeftButtonRect.Bottom - 1);

    MoveTo(DblRightButtonRect.Right - 1, DblRightButtonRect.Top);
    LineTo(DblRightButtonRect.Right - 1, DblRightButtonRect.Bottom - 1);
    LineTo(DblRightButtonRect.Left, DblRightButtonRect.Bottom - 1);

    MoveTo(CancelButtonRect.Right - 1, CancelButtonRect.Top);
    LineTo(CancelButtonRect.Right - 1, CancelButtonRect.Bottom - 1);
    LineTo(CancelButtonRect.Left, CancelButtonRect.Bottom - 1);

    ArrowWMarg := Button_Width div 4;
    ArrowHMarg := Button_Height div 4;

    {Draw Arrows}
    Brush.Color := (ctlParent as TDateEdit97).ColorArrow;
    OldStyle := Brush.Style;
    Brush.Style := bsSolid;
    Pen.Color := (ctlParent as TDateEdit97).ColorArrow;
{ SUBSTITUITED
    Polygon([Point (LeftButtonRect.Right - ArrowWMarg-1,
                      LeftButtonRect.Top + ArrowHMarg),
             Point (LeftButtonRect.Right - ArrowWMarg-1,
                      LeftButtonRect.Bottom - ArrowHMarg-1),
             Point (LeftButtonRect.Left + ArrowWMarg,
                      RightButtonRect.Top + Button_Height div 2-1)]);

    Polygon([Point (RightButtonRect.Left + ArrowWMarg,
                      RightButtonRect.Top + ArrowHMarg),
             Point (RightButtonRect.Left + ArrowWMarg,
                      RightButtonRect.Bottom - ArrowHMarg-1),
             Point (RightButtonRect.Right - ArrowWMarg-1,
                      RightButtonRect.Top + Button_Height div 2-1)]);
}
    Polygon([Point (LeftButtonRect.Right - ArrowWMarg -3,
                      LeftButtonRect.Top + ArrowHMarg),
             Point (LeftButtonRect.Right - ArrowWMarg -3,
                      LeftButtonRect.Bottom - ArrowHMarg),
             Point (LeftButtonRect.Left+Button_Width div 2 -3,
                      LeftButtonRect.Top + Button_Height div 2)]);

    Polygon([Point (RightButtonRect.Left+Button_Width div 2 -1,
                      RightButtonRect.Top + ArrowHMarg),
             Point (RightButtonRect.Left+Button_Width div 2 -1,
                      RightButtonRect.Bottom - ArrowHMarg),
             Point (RightButtonRect.Right - ArrowWMarg -1,
                      RightButtonRect.Top + Button_Height div 2)]);

    {Draw Double Arrows}
    Brush.Color := (ctlParent as TDateEdit97).ColorArrow;
    OldStyle := Brush.Style;
    Brush.Style := bsSolid;
    Pen.Color := (ctlParent as TDateEdit97).ColorArrow;
{ SUBSTITUITED
    Polygon([Point (DblLeftButtonRect.Right - ArrowWMarg-1,
                      DblLeftButtonRect.Top + ArrowHMarg),
             Point (DblLeftButtonRect.Right - ArrowWMarg-1,
                      DblLeftButtonRect.Bottom - ArrowHMarg),
             Point (DblLeftButtonRect.Left+Button_Width div 2,
                      DblLeftButtonRect.Top + Button_Height div 2-1)]);

    Polygon([Point (DblLeftButtonRect.Left + Button_Width div 2-1,
                      DblLeftButtonRect.Top + ArrowHMarg),
             Point (DblLeftButtonRect.Left + Button_Width div 2-1,
                      DblLeftButtonRect.Bottom - ArrowHMarg),
             Point (DblLeftButtonRect.Left + ArrowWMarg,
                      DblLeftButtonRect.Top + Button_Height div 2-1)]);

    Polygon([Point (DblRightButtonRect.Left+Button_Width div 2,
                      DblRightButtonRect.Top + ArrowHMarg),
             Point (DblRightButtonRect.Left+Button_Width div 2,
                      DblRightButtonRect.Bottom - ArrowHMarg),
             Point (DblRightButtonRect.Right - ArrowWMarg-1,
                      DblRightButtonRect.Top + Button_Height div 2-1)]);

    Polygon([Point (DblRightButtonRect.Left + ArrowWMarg,
                      DblRightButtonRect.Top + ArrowHMarg),
             Point (DblRightButtonRect.Left + ArrowWMarg,
                      DblRightButtonRect.Bottom - ArrowHMarg),
             Point (DblRightButtonRect.Left + Button_Width div 2-1,
                      DblRightButtonRect.Top + Button_Height div 2-1)]);
}
    Polygon([Point (DblLeftButtonRect.Right - ArrowWMarg,
                      DblLeftButtonRect.Top + ArrowHMarg),
             Point (DblLeftButtonRect.Right - ArrowWMarg,
                      DblLeftButtonRect.Bottom - ArrowHMarg),
             Point (DblLeftButtonRect.Left+Button_Width div 2,
                      DblLeftButtonRect.Top + Button_Height div 2)]);

    Polygon([Point (DblLeftButtonRect.Left + Button_Width div 2 - 1,
                      DblLeftButtonRect.Top + ArrowHMarg),
             Point (DblLeftButtonRect.Left + Button_Width div 2 - 1,
                      DblLeftButtonRect.Bottom - ArrowHMarg),
             Point (DblLeftButtonRect.Left + ArrowWMarg - 1,
                      DblLeftButtonRect.Top + Button_Height div 2)]);

    Polygon([Point (DblRightButtonRect.Left+Button_Width div 2,
                      DblRightButtonRect.Top + ArrowHMarg),
             Point (DblRightButtonRect.Left+Button_Width div 2,
                      DblRightButtonRect.Bottom - ArrowHMarg),
             Point (DblRightButtonRect.Right - ArrowWMarg,
                      DblRightButtonRect.Top + Button_Height div 2)]);

    Polygon([Point (DblRightButtonRect.Left + ArrowWMarg - 1,
                      DblRightButtonRect.Top + ArrowHMarg),
             Point (DblRightButtonRect.Left + ArrowWMarg - 1,
                      DblRightButtonRect.Bottom - ArrowHMarg),
             Point (DblRightButtonRect.Left + Button_Width div 2-1,
                      DblRightButtonRect.Top + Button_Height div 2)]);

    {Draw Cancel Button}
{ SUBSTITUITED
    Pen.Color := clMaroon;
    Pen.Width := 2;
    MoveTo(CancelButtonRect.Left + 4, CancelButtonRect.Bottom - 4);
    LineTo(CancelButtonRect.Right - 4, CancelButtonRect.Top + 3);
    Pen.Width := 3;
    MoveTo(CancelButtonRect.Left + 4, CancelButtonRect.Top + 3);
    LineTo(CancelButtonRect.Right - 4, CancelButtonRect.Bottom - 4);
}
    Pen.Color := clMaroon;
    Pen.Width := 2;
    MoveTo(CancelButtonRect.Left + 5, CancelButtonRect.Bottom - 4);
    LineTo(CancelButtonRect.Right - 5, CancelButtonRect.Top + 4);
    Pen.Width := 2;
    MoveTo(CancelButtonRect.Left + 5, CancelButtonRect.Top + 4);
    LineTo(CancelButtonRect.Right - 5, CancelButtonRect.Bottom - 4);

    Brush.Style := OldStyle;
    Brush.Color := clBtnFace;
    Pen.Color := clBlack;
    Pen.Width := 1;
  end;
end;

{*************** Draw Calendar Border *********************
 **********************************************************}
procedure TfrmCalPop97.DrawCalendarBorder;
var
  rectDraw: TRect;
begin
  rectDraw := ClientRect;
  with Canvas do
  begin
    {Select Black Pen to outline Window }
    Pen.Style := psSolid;
    Pen.Width := 1;
    Pen.Color := clBlack;
    Brush.Color := clBtnFace; {added for use clBtnFace instead of clSilver}
    Brush.Style := bsSolid;

    {Outline the window in black }
    Rectangle(rectDraw.Left, rectDraw.Top, rectDraw.Right, rectDraw.Bottom);

    {Create Embossed effect - Outline left & upper in white}
    Pen.Color := clWhite;
    MoveTo(0, rectDraw.Bottom - 1);
    LineTo(0, 0);
    LineTo(rectDraw.Right - 1, 0);

    {Create Embossed effect - Outline right & bottom in gray }
    Pen.Color := clBtnShadow;
    LineTo(rectDraw.Right - 1, rectDraw.Bottom - 1);
    LineTo(0, rectDraw.Bottom - 1);
  end;
end;

{******************* GetGoodColor *************************
 **********************************************************}
Function TfrmCalPop97.GetGoodColor (dtTest : tDateTime) : tColor;
begin
  if (ctlParent as TDateEdit97).DateInList(dtTest) then
    Result := (ctlParent as TDateEdit97).ColorValidDate
  else begin
    if DayOfWeek (dtTest) in [1, 7]
      then Result := (ctlParent as TDateEdit97).ColorWeekEnd
      else Result := (ctlParent as TDateEdit97).ColorDates
  end;
end;

{*********************** Draw Dates ***********************
 **********************************************************}
procedure TfrmCalPop97.DrawDates;
var
   nIndex, nWeek, nDay: Integer;
   pDate: PChar;
   TempRect: Trect;
   dtTest: TDateTime;
begin
  pDate := StrAlloc(3);

  with Canvas do
  begin
    {Define normal font }
    Font := (ctlParent as TDateEdit97).Font;

    {Cycle through the weeks }
    for nWeek := 1 to 6 do
    begin
      {Cycle through the days }
      for nDay := 1 to 7 Do
      begin
        nIndex := nDay + ((nWeek - 1) * 7);

        StrPCopy(pDate, m_DateArray[nIndex]);
        if m_DateArray[nIndex] <> '  ' then
        begin
          dtTest := EncodeDate (m_CurrentYear, m_CurrentMonth,
                                StrToInt(m_DateArray[nIndex]));
          Font.Color := GetGoodColor (dtTest);
        end;

        TempRect := GetCalendarRect;
        with TempRect do
        begin
          Left := Left + ((m_FontWidth * 3) * (nDay - 1));
          Top := (m_FontHeight * nWeek) + m_FontHeight + BORDER;
          Bottom := Top +  m_FontHeight;
          Right := Left + m_fontWidth * 3;
        end;

        DrawText(Handle, pDate, Length(m_DateArray[nIndex]),
                 TempRect, (DT_CENTER or DT_VCENTER or DT_TOP or DT_SINGLELINE));
      end;
    end;
  end;
  StrDispose(pDate);
end;

{*********************** Draw Days ************************
 **********************************************************}
procedure TfrmCalPop97.DrawDaysHeader;
var
  DayNo, I: Integer;
  pDay: PChar;
  TempRect: Trect;
begin
  pDay := StrAlloc(3);

  {Calculate Rect Top.  2nd line = FontHeight * 2}
  TempRect := ClientRect;
  TempRect.Top := m_FontHeight + BORDER;
  TempRect.Bottom := TempRect.Top + m_FontHeight;

  {Calculate each date rect. rect = FontWidth * 3 (width of two chars + space)}
  TempRect.Left := TempRect.Left + BORDER + TEXT_INDENT;
  TempRect.Right := BORDER + TEXT_INDENT + (m_FontWidth * 3);

  {Cycle through the days}
  for I := 1 to 7 do
  begin
    DayNo := ((ctlParent as TDateEdit97).StartOfWeek + I - 2) mod 7 + 1;
    StrPCopy(pDay, (ctlParent as TDateEdit97).DayArray^[DayNo]);
    DrawText(Canvas.Handle, pDay, 2, TempRect,
            (DT_CENTER or DT_TOP or DT_SINGLELINE));
    TempRect.Left := TempRect.Right;
    TempRect.Right := TempRect.Right + m_FontWidth * 3;
 end;

 {Draw line below days }
 with Canvas do
 begin
   TempRect.Top := TempRect.Bottom - 3;
   TempRect.Bottom := TempRect.Top + 2;
   TempRect.Left := ClientRect.Left + BORDER + TEXT_INDENT;
   TempRect.Right := BORDER + TEXT_INDENT + (m_FontWidth * 3 * 7);

   Pen.Color := clBtnShadow;
   MoveTo(TempRect.Left , TempRect.Top);
   LineTo(TempRect.Right, TempRect.Top);
   Pen.Color := clWhite;
   MoveTo(TempRect.Left,  TempRect.Top + 1);
   LineTo(TempRect.Right, TempRect.Top + 1);
 end;

 StrDispose(pDay);
end;

{******************** Draw Month Header *******************
 **********************************************************}
procedure TfrmCalPop97.DrawMonthHeader;
var
   sMonth: String;
   pMonth: PChar;
   TempRect: Trect;
begin
  with Canvas do
  begin
    Font.Style := [fsBold];
    Font.Color := (ctlParent as TDateEdit97).ColorTitle;
    sMonth := (ctlParent as TDateEdit97).MonthArray^[m_CurrentMonth] + ' ' +
               IntToStr(M_CurrentYear);

    pMonth := StrAlloc(Length(sMonth) + 1);
    StrPCopy(pMonth, sMonth);

    TempRect := ClientRect;
    TempRect.Top := BORDER;
    TempRect.Left := BORDER + TEXT_INDENT + BUTTON_WIDTH*2;
    TempRect.Right := TempRect.Right - BORDER - TEXT_INDENT - BUTTON_WIDTH*2;
    TempRect.Bottom := m_FontHeight;

    Brush.Color := clBtnFace;
    Brush.Style := bsSolid;
    FillRect(TempRect);

    DrawText(Handle, pMonth, Length(sMonth), TempRect,
            (DT_CENTER or DT_VCENTER or DT_BOTTOM or DT_SINGLELINE));
  end;

  StrDispose(pMonth);
end;

{******************** Erase Date Frame ********************
 **********************************************************}
procedure TfrmCalPop97.EraseDateFrame(nIndex: Integer);
var
  pDate :PChar;
  TempRect: TRect;
  dtTest: TDateTime;
begin
  if nIndex > 0 then
  begin
    pDate := StrAlloc(3);
    Canvas.Font.Style := [];

    if m_DateArray[nIndex] <> '  ' then
    begin
      dtTest := EncodeDate(m_CurrentYear, m_CurrentMonth,
                           StrToInt(m_DateArray[nIndex]));
      Canvas.Font.Color := GetGoodColor(dtTest);
    end;

    StrPCopy(pDate, m_DateArray[nIndex]);
    Canvas.Brush.Color := clBtnFace;
    TempRect := GetRectFromIndex(nIndex);
    Canvas.FillRect(TempRect);
    DrawText(Canvas.Handle, pDate, Length(m_DateArray[nIndex]),
             TempRect, (DT_CENTER or DT_VCENTER or DT_TOP or DT_SINGLELINE));
    StrDispose(pDate);
  end;
end;

{******************** Draw Focus Frame ********************
 **********************************************************}
procedure TfrmCalPop97.DrawFocusFrame(nIndex: Integer; IsUp : boolean);
{if not Up, then Down ... for button style}
var
  pDate :PChar;
  TempRect: TRect;
  dtTest: TDateTime;
  CoulShadow,
  CoulHighlight : tColor;
begin
  if (nIndex > 0) and (nIndex < 42) then begin
    if (m_DateArray[nIndex] <> '  ') then
    begin
      pDate := StrAlloc(3);
      {Erase Previous Date Focus}
      EraseDateFrame(m_PreviousDateIndex);

      {Draw the Date in Bold font}
      Canvas.Font.Style := [fsBold];
      dtTest := EncodeDate(m_CurrentYear, m_CurrentMonth, StrToInt(m_DateArray[nIndex]));
      Canvas.Font.Color := GetGoodColor (dtTest);

      TempRect := GetRectFromIndex(nIndex);
      StrPCopy(pDate, m_DateArray[nIndex]);
      DrawText(Canvas.Handle, pDate, Length(m_DateArray[nIndex]),
               TempRect, (DT_CENTER or DT_VCENTER or DT_TOP or DT_SINGLELINE));

      if IsUp
      then begin
        CoulShadow := clWhite;
        CoulHighlight := clBtnShadow;
      end
      else begin
        CoulShadow := clBtnShadow;
        CoulHighlight := clWhite;
      end;
      {Frame date with Shadow }
      Canvas.Pen.Color := CoulShadow;
      Canvas.MoveTo(TempRect.Left, TempRect.Bottom - 1);
      Canvas.LineTo(TempRect.Left, TempRect.Top);
      Canvas.LineTo(TempRect.Right - 1, TempRect.Top);

      {Frame date with Highlight }
      Canvas.Pen.Color := CoulHighlight;
      Canvas.LineTo(TempRect.Right - 1, TempRect.Bottom - 1);
      Canvas.LineTo(TempRect.Left, TempRect.Bottom - 1);

      StrDispose(pDate);
    end;
  end;
end;

{********************* Form Cancel ************************
 **********************************************************}
procedure TfrmCalPop97.FormCancel;
begin
  m_MouseDown := False;
  ClosePopup;

  (ctlParent as TDateEdit97).DoEdit;                          
end;

{******************* Form Key Down ************************
 **********************************************************}
procedure TfrmCalPop97.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_Left: begin
      PrevDay;
      if (m_CurrentMonth <> m_PreviousMonth) or
         (m_CurrentYear <> m_PreviousYear) then
        Refresh else DrawFocusFrame(m_CurrentDateIndex, False);
    end;

    VK_Right: begin
      NextDay;
      if (m_CurrentMonth <> m_PreviousMonth) or
         (m_CurrentYear <> m_PreviousYear) then
        Refresh else DrawFocusFrame(m_CurrentDateIndex, False);
    end;

    VK_Up: begin
      PrevWeek;
      if (m_CurrentMonth <> m_PreviousMonth) or
         (m_CurrentYear <> m_PreviousYear) then
        Refresh else DrawFocusFrame(m_CurrentDateIndex, False);
    end;

    VK_Down: begin
      NextWeek;
      if (m_CurrentMonth <> m_PreviousMonth) or
         (m_CurrentYear <> m_PreviousYear) then
        Refresh else DrawFocusFrame(m_CurrentDateIndex, False);
    end;

    VK_Prior: begin
      PrevMonth;
      Refresh;
    end;

    VK_Next: begin
      NextMonth;
      Refresh;
    end;

    VK_Home: begin
      NextYear;
      Refresh;
    end;

    VK_End: begin
      PrevYear;
      Refresh;
    end;

    VK_Return: begin
      (ctlParent as TDateEdit97).Date := m_CurrentDateSelected;
      (ctlParent as TDateEdit97).DoEdit;                      
      ClosePopup;
    end;

    VK_Escape: begin
      FormCancel;
    end;
  end;
end;

{********************** Form Mouse Down *******************
 **********************************************************}
procedure TfrmCalPop97.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  nIndex: Integer;
  Key: Word;
begin
  {Check if mouse was pressed in Left button area}
  if PointInRect(GetLeftButtonRect, X, Y) then
  begin
    Key := VK_Prior;
    FormKeyDown(Sender, Key,Shift);
  end;

  {Check if mouse was pressed in Right button area}
  if PointInRect(GetRightButtonRect, X, Y) then
  begin
    Key := VK_Next;
    FormKeyDown(Sender, Key,Shift);
  end;

  {Check if mouse was pressed in DblLeft button area}
  if PointInRect(GetDblLeftButtonRect, X, Y) then
  begin
    Key := VK_End;
    FormKeyDown(Sender, Key,Shift);
  end;

  {Check if mouse was pressed in DblRight button area}
  if PointInRect(GetDblRightButtonRect, X, Y) then
  begin
    Key := VK_Home;
    FormKeyDown(Sender, Key,Shift);
  end;

  {Check if mouse was pressed in Cancel button area}
  if PointInRect(GetCancelButtonRect, X, Y) then
  begin
    Key := VK_Escape;
    FormKeyDown(Sender, Key,Shift);
  end;

  {Check if mouse was pressed in date area}
  if PointInRect(GetCalendarRect, X, Y) then
  begin
    m_MouseDown := True;
    nIndex := GetIndexFromPoint(X, Y);

    if (nIndex >= GetMonthBegin) and
       (nIndex < (DaysInMonth(m_CurrentMonth) + GetMonthBegin)) then
    begin
      SetDate(nIndex - m_CurrentDateIndex);
      DrawFocusFrame(nIndex, False);
    end
    else
      m_MouseDown := False;
  end;
end;

{******************* Form Mouse Move **********************
 **********************************************************}
procedure TfrmCalPop97.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  nIndex: Integer;
begin
  {Check if mouse was pressed in date area}
  if PointInRect(GetCalendarRect, X, Y) then
  begin
    nIndex := GetIndexFromPoint(X, Y);
    if (nIndex >= GetMonthBegin) and
       (nIndex < (DaysInMonth(m_CurrentMonth) + GetMonthBegin)) and
       (nIndex <> m_CurrentDateIndex) then
    begin
      if not m_MouseDown then
      begin
        if m_PreviousDateHighlight <> nIndex
        then begin
          EraseDateFrame(m_PreviousDateHighlight);
          DrawFocusFrame(nIndex, True);
          m_PreviousDateHighlight := nIndex;
        end;
      end
      else begin
        SetDate(nIndex - m_CurrentDateIndex);
        EraseDateFrame(m_PreviousDateHighlight);
        DrawFocusFrame(nIndex, False);
      end;
    end
    else
    begin
      EraseDateFrame(m_PreviousDateHighlight);
      m_PreviousDateHighlight := 0;
    end;
  end
  else begin
    if m_PreviousDateHighlight <> m_CurrentDateIndex
      then EraseDateFrame(m_PreviousDateHighlight);
    m_PreviousDateHighlight := 0;
  end;
end;

{******************* Form Mouse Up ************************
 **********************************************************}
procedure TfrmCalPop97.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if m_MouseDown then
  begin
    m_MouseDown := False;
    (ctlParent as TDateEdit97).Date := m_CurrentDateSelected;
    (ctlParent as TDateEdit97).DoEdit;                        
    ClosePopup;
  end;
end;

{********************** Form Paint ************************
 **********************************************************}
procedure TfrmCalPop97.FormPaint(Sender: TObject);
begin
  DrawCalendarBorder;
  DrawMonthHeader;
  DrawDaysHeader;
  DrawDates;
  DrawButtons;
  DrawFocusFrame(m_CurrentDateIndex, False);
end;

{********************* Get Left Button Rectangle ******************
 ***** Get the rectangle used for the left button.            *****
 ******************************************************************}
function TfrmCalPop97.GetLeftButtonRect: TRect;
var
  TempRect: TRect;
begin
   {Define Left Button Rectangle}
   TempRect.Top := ClientRect.Top + BORDER;
   TempRect.Bottom := TempRect.Top + BUTTON_HEIGHT;
   TempRect.Left := ClientRect.Left + (BORDER + TEXT_INDENT + BUTTON_WIDTH);
   TempRect.Right := TempRect.Left + BUTTON_WIDTH;

   Result := TempRect;
end;

{******************** Get Right Button Rectangle ******************
 ***** Get the rectangle used for the right button.           *****
 ******************************************************************}
function TfrmCalPop97.GetRightButtonRect: TRect;
var
  TempRect: TRect;
begin
   {Define Right Button Rectangle}
   TempRect.Top := ClientRect.Top + BORDER;
   TempRect.Bottom := TempRect.Top + BUTTON_HEIGHT;
   TempRect.Right := BORDER + TEXT_INDENT + (m_FontWidth * 3 * 7)-BUTTON_WIDTH;
   TempRect.Left := TempRect.Right - BUTTON_WIDTH;

   Result := TempRect;
end;

{********************* Get DblLeft Button Rectangle ***************
 ***** Get the rectangle used for the dblleft button.         *****
 ******************************************************************}
function TfrmCalPop97.GetDblLeftButtonRect: TRect;
var
  TempRect: TRect;
begin
   {Define DblLeft Button Rectangle}
   TempRect.Top := ClientRect.Top + BORDER;
   TempRect.Bottom := TempRect.Top + BUTTON_HEIGHT;
   TempRect.Left := ClientRect.Left + BORDER + TEXT_INDENT;
   TempRect.Right := TempRect.Left + BUTTON_WIDTH;

   Result := TempRect;
end;

{******************** Get DblRight Button Rectangle ***************
 ***** Get the rectangle used for the dblright button.        *****
 ******************************************************************}
function TfrmCalPop97.GetDblRightButtonRect: TRect;
var
  TempRect: TRect;
begin
   {Define DblRight Button Rectangle}
   TempRect.Top := ClientRect.Top + BORDER;
   TempRect.Bottom := TempRect.Top + BUTTON_HEIGHT;
   TempRect.Right := BORDER + TEXT_INDENT + (m_FontWidth * 3 * 7);
   TempRect.Left := TempRect.Right - BUTTON_WIDTH;

   Result := TempRect;
end;

{******************** Get Cancel Button Rectangle *****************
 ***** Get the rectangle used for the Cancel button.          *****
 ******************************************************************}
function TfrmCalPop97.GetCancelButtonRect: TRect;
var
  TempRect: TRect;
begin
   {Define Cancel (Bottom, Right) Button Rectangle}
   TempRect.Top := ClientRect.Bottom - BUTTON_WIDTH - BORDER;
   TempRect.Bottom := TempRect.Top + BUTTON_HEIGHT;
   TempRect.Right := BORDER + TEXT_INDENT + (m_FontWidth * 3 * 7);
   TempRect.Left := TempRect.Right - BUTTON_WIDTH;

   Result := TempRect;
end;

{********************** Get Calendar Rectangle ********************
 ***** Get the rectangle used for the calendar section        *****
 ******************************************************************}
function TfrmCalPop97.GetCalendarRect: TRect;
var
  TempRect: TRect;
begin
  TempRect := ClientRect;

  with TempRect do
  begin
    Left := BORDER + TEXT_INDENT;
    Top := (m_FontHeight * 2) + BORDER;
    Bottom := Top + (m_FontHeight * 6);
    Right := Left + (7 * (m_fontWidth * 3));
  end;

  Result := TempRect;
end;

{******************** Get Rectangle From Index ********************
 ***** Get the rectangle used for the calendar section        *****
 ******************************************************************}
function TfrmCalPop97.GetRectFromIndex(nIndex: Integer): TRect;
var
  TempRect: TRect;
  nWeek: Integer;
  nDay: Integer;
begin
  TempRect := GetCalendarRect;

  with TempRect do
  begin
    case nIndex of
      01..07: nWeek := 1;
      08..14: nWeek := 2;
      15..21: nWeek := 3;
      22..28: nWeek := 4;
      29..35: nWeek := 5;
      36..42: nWeek := 6;
    else {see Delphi Warnings}
      nWeek := 1;
    end;

    nDay := nIndex - ((nWeek - 1) * 7);

    Left := Left + ((m_FontWidth * 3) * (nDay - 1));
    Top := (m_FontHeight * nWeek) + m_FontHeight + BORDER;
    Bottom := Top +  m_FontHeight;
    Right := Left + m_fontWidth * 3;
  end;

  Result := TempRect;
end;

{*************************** Get Month Begin **************************
 ***** This function Gets the index value of the first day of the *****
 ***** month.                                                     *****
 ********************************************************************** }
function TfrmCalPop97.GetMonthBegin: Integer;
var
  DOW: Integer;
begin
  DOW := DayOfWeek(EncodeDate(m_CurrentYear, m_CurrentMonth, 1)) - 1;
  if DOW = 0 then DOW := 7;
  Result := (DOW - (ctlParent as TDateEdit97).StartOfWeek + 7) mod 7 + 1;
end;

{********************** Is Leap Year **********************
 **********************************************************}
function TfrmCalPop97.IsLeapYear: Boolean;
begin
  Result := (m_CurrentYear mod 4 = 0) and
           ((m_CurrentYear mod 100 <> 0) or (m_CurrentYear mod 400 = 0));
end;

{********************** LoadDateArray *********************
 **********************************************************}
procedure TfrmCalPop97.LoadDateArray;
var
  nIndex: Integer;
  nBeginIndex, nEndIndex: Integer;
begin
  nBeginIndex := GetMonthBegin;
  nEndIndex := nBeginIndex + DaysInMonth(m_CurrentMonth) - 1;
  for nIndex := 1 to 42 do
  begin
    if (nIndex < nBeginIndex) or (nIndex > nEndIndex) then
      m_DateArray[nIndex] := '  '
    else
      m_DateArray[nIndex] := IntToStr((nIndex - nBeginIndex) + 1);
  end;
end;

{******************** Get Index From Date *****************
 **********************************************************}
function TfrmCalPop97.GetIndexFromDate: Integer;
begin
  Result := m_CurrentDay + GetMonthBegin;
end;

{****************** Get Index From Point ******************
 **********************************************************}
function TfrmCalPop97.GetIndexFromPoint(nLeft: Integer ; nTop: Integer): Integer;
var
  nIndex, nWeek, nDay: Integer;
  nResult: Real;
  TempRect: Trect;
begin
  TempRect := GetCalendarRect;

  nIndex := -1;
  {Is point in the calendar rectangle?}
  if (nLeft > TempRect.Left) and (nTop > TempRect.Top) and
     (nLeft < TempRect.Right) and (nTop < TempRect.Bottom) then
  begin
    {Determine the week number of the selected date }
    nResult := (nTop - BORDER) / (m_FontHeight) - 1;
    nWeek := Trunc(nResult);

    {Adjust Date Rect }
    TempRect.Top := TempRect.Top + ((nWeek - 1) * m_FontHeight);
    TempRect.Bottom := TempRect.Top + m_FontHeight;
    TempRect.Left := BORDER + TEXT_INDENT;
    TempRect.Right := TempRect.Left + m_FontWidth * 3;

    {Determine the day number of the selected date }
    for nDay := 1 to 7 do        {Cycle through the days}
    begin
      nIndex := nDay + ((nWeek - 1) * 7);
      if (nLeft >= TempRect.Left) and (nLeft <= TempRect.Right) then
        Break
      else
      begin
        TempRect.Left := TempRect.Right;
        TempRect.Right := TempRect.Left + m_FontWidth * 3;
      end;
    end;
  end;

  Result := nIndex;
end;

{******************** Get Previous Day ********************
 **********************************************************}
procedure TfrmCalPop97.PrevDay;
begin
  SetDate(-1);
end;

{********************* Get Next Day ***********************
 **********************************************************}
procedure TfrmCalPop97.NextDay;
begin
  SetDate(+1);
end;

{******************** Get Previous Week *******************
 **********************************************************}
procedure TfrmCalPop97.PrevWeek;
begin
  SetDate(-7);
end;

{******************** Get Next Week ***********************
 **********************************************************}
procedure TfrmCalPop97.NextWeek;
begin
  SetDate(+7);
end;

{******************** GetPreviousMonth ********************
 **********************************************************}
procedure TfrmCalPop97.PrevMonth;
var
   nDays: Integer;
   nMonth: Integer;
begin
  if m_CurrentMonth > 1 then
    nMonth := m_CurrentMonth - 1
  else
    nMonth := 12;

  nDays := DaysInMonth(nMonth);
  SetDate(-nDays);
end;

{******************** Get Next Month **********************
 **********************************************************}
procedure TfrmCalPop97.NextMonth;
begin
  SetDate(DaysInMonth(m_CurrentMonth));
end;

{******************** Get Next Year ***********************
 **********************************************************}
procedure TfrmCalPop97.NextYear;
begin
  {if the current year is a leap year and the date is
   before February 29, add 1 day}
  if IsLeapYear and (m_CurrentMonth < 3) then SetDate(+1);

  SetDate(365);
  {if the current year is a leap year and the date is
   after February 29, add 1 day}
  if IsLeapYear and (m_CurrentMonth > 3) then SetDate(+1);
end;

{******************* GetPrevious Year *********************
 **********************************************************}
procedure TfrmCalPop97.PrevYear;
begin
  {if the current year is a leap year and the date is
   after February 29, subtract 1 day}
  if IsLeapYear and (m_CurrentMonth > 3) then SetDate(-1);

  SetDate(-365);
  {if the Previous year is a leap year and the date is
   before February 29, subtract 1 day}
  if IsLeapYear and (m_CurrentMonth < 3) then SetDate(-1);
end;

{***************** Set Date **************************
 **** This procedure adjusts the date by nDays    ****
 **** nDays can be possitive or negative. It      ****
 **** also populates the vars YEAR, MONTH and DAY ****
 *****************************************************}
procedure TfrmCalPop97.SetDate(nDays: Integer);
begin
  {Save current date information}
  m_PreviousDateIndex := m_CurrentDateIndex;
  m_PreviousDateHighlight := m_CurrentDateIndex;
  DecodeDate(m_CurrentDateSelected, m_PreviousYear, m_PreviousMonth, m_PreviousDay);

  {Change the date and update member variables}
  m_CurrentDateSelected := m_CurrentDateSelected + nDays;
  DecodeDate(m_CurrentDateSelected, m_CurrentYear, m_CurrentMonth, m_CurrentDay);
  m_CurrentDateIndex := (GetMonthBegin + m_CurrentDay) - 1;

  {Reload Date Array if month or year changed}
  if (m_CurrentMonth <> m_PreviousMonth) or
     (m_CurrentYear <> m_PreviousYear) then LoadDateArray;
end;

end.
