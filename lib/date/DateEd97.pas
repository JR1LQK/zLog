unit DateEd97;

(******************************************************************************
TDateEdit97 version 3.5

Derived from
    tCustomEdit

Properties
    BorderStyle,
    Font,
    TabOrder,
    TabStop         : inherited from tCustomEdit
    ButtonDateStyle : style of popup button (drop down or calendar)
    ButtonStyle     : select button style (new, win31, autodetect)
    ButtonTabStop   : choose if buttons are TabStop
    CanClear        : show (or hide) clear button
    CanPopup        : enable (or disable) popup calendar button
    CanValidate     : Show (or hide) validate button
    ColorArrow      : Color for arrow buttons of calendar
    ColorDates      : Color for dates of calendar
    ColorWeekEnd    : Color for week-end dates of calendar
    ColorError      : Color when date isn't correct
    ColorTitle      : Color for title of calendar
    ColorValidDate  : Color for valid dates of calendar
    Date            : Selected date as DateTime
    DayNames        : Names of each days
    EmptyAsToday    : If true (and canclear is false), empty date is "today"
    FocusOnError    : If date is invalid, keep focus or not
    IsMasked        : choose if you want to use mask-edit for input
    IsModal         : choose if you want a modal popup calendar (or not)
    MonthNames      : Names of each monthes
    PopupToday      : If true, popup calendar always start with today's date
    ShortCutAddAlt  : Use Alt key for Shortcuts
    ShortCutAddCtrl : Use Ctrl key for Shortcuts
    ShortCutClear   : Shortcut key for Clear button
    ShortCutPopup   : Shortcut key for Popup button
    ShortCutValidate: Shortcut key for Validate button
    StartOfWeek     : First day of week
    Text            : Selected date as String

procedures
    AddValidDate: Add a ValidDate
    DateInList: Check if a date is in ValidDates list
    ClearValidDates: Clear ValidDates list
    ClearDate: Clear date
    PopupCalendar: Popup the calendar
    SetDateValid : Set if entered date is valid or not (change drawed color)
    AfterClick : function calling OnAfterClick event;
    ValidateDate : Function calling OnValidateClick event.

events
    OnChange,
    OnEnter,
    OnExit          : inherited from tCustomEdit
    OnAfterClick    : When a user click for select a date.
    OnValidateClick : Used for validate an entered date.


Author name=BOURMAD Mehdi
Author E-mail=bourmad@mygale.org
Author URL=www.mygale.org/~bourmad
******************************************************************************)

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Dialogs, Forms, StdCtrls, Buttons, DsgnIntf, CalPop97;

{******************** Misc. types *************************}
type
  PTDateTime = ^TDateTime;
  TDay = string[2];
  PDayArray=^TDayArray;
  TDayArray = array[1..7] of TDay;
  TDayOfWeek = 1..7;
  TDayName = class(TPersistent)
  private
    FMonday: TDay;
    FTuesday: TDay;
    FWednesday: TDay;
    FThursday: TDay;
    FFriday: TDay;
    FSaturday: TDay;
    FSunday: TDay;
  protected
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Monday: TDay read FMonday write FMonday;
    property Tuesday: TDay read FTuesday write FTuesday;
    property Wednesday: TDay read FWednesday write FWednesday;
    property Thursday: TDay read FThursday write FThursday;
    property Friday: TDay read FFriday write FFriday;
    property Saturday: TDay read FSaturday write FSaturday;
    property Sunday: TDay read FSunday write FSunday;
  end;

  TMonth = string[15];
  PMonthArray = ^TMonthArray;
  TMonthArray = array[1..12] of TMonth;
  TMonthName = class(TPersistent)
  private
    FJanuary: TMonth;
    FFebruary: TMonth;
    FMarch: TMonth;
    FApril: TMonth;
    FMay: TMonth;
    FJune: TMonth;
    FJuly: TMonth;
    FAugust: TMonth;
    FSeptember: TMonth;
    FOctober: TMonth;
    FNovember: TMonth;
    FDecember: TMonth;
  protected
  public
    constructor Create;
    destructor Destroy; override;
  published
    property January: TMonth read FJanuary write FJanuary;
    property February: TMonth read FFebruary write FFebruary;
    property March: TMonth read FMarch write FMarch;
    property April: TMonth read FApril write FApril;
    property May: TMonth read FMay write FMay;
    property June: TMonth read FJune write FJune;
    property July: TMonth read FJuly write FJuly;
    property August: TMonth read FAugust write FAugust;
    property September: TMonth read FSeptember write FSeptember;
    property October: TMonth read FOctober write FOctober;
    property November: TMonth read FNovember write FNovember;
    property December: TMonth read FDecember write FDecember;
  end;

  TDateBtnStyle = (btsDropDown, btsCalendar);

  {*********** tAboutMeProperty ************}
  TAboutMeProperty = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
  end;

{******************** DateEdit97 Component *************************}
  TDateEdit97 = class(TCustomEdit)
  private
    FAbout : TAboutMeProperty;
    FEmptyAsToday : boolean;
    FIsMasked, 
    FIsModal : boolean;
    FCanPopup,
    FCanClear,
    FCanValidate : boolean;
    FBtnDateStyle : tDateBtnStyle;
    FBtnStyle : tButtonStyle;
    FBtnTabStop : boolean;
    FFocusOnError : boolean;
    FColorArrow,
    FColorDates,
    FColorWeekEnd,
    FColorError,
    FColorTitle,
    FColorVal : TColor;
    FDate : TDateTime;
    FDateValid : boolean;
    FDayName : TDayName;
    FMonthName : TMonthName;
    FPopupToday : boolean;
    FStartOfWeek : TDayOfWeek;
    FDayArray : TDayArray;
    FMonthArray : TMonthArray;
    lstDates : TList;
    frmCalendar : TfrmCalPop97;
    FOnAfterClick,
    FOnValidated: TNotifyEvent;
    FShortCutClear: Word;
    FShortCutPopup: Word;
    FShortCutValidate: Word;
    FShortCutAlt: Boolean;
    FShortCutCtrl: Boolean;
    procedure SetStartOfWeek(Value: TDayOfWeek);
  protected
    FBtnPopup,
    FBtnValidate,
    FBtnClear : tBitBtn;
    NewShortDateFormat : string;
    procedure SetAltOn(value : boolean);
    procedure SetCtrlOn(value : boolean);
    function RemoveChr (aChar : Char; aStr : String) : String;
    function PadTo4Year (aStr : String) : String;
    procedure AdjustEdit;
    procedure AdjustDate;
    procedure SetCanClear (value : boolean);
    procedure SetCanPopup (value : boolean);
    procedure SetCanValidate (value : boolean);
    procedure SetDate(dtArg: TDateTime);
    function GetDayArray: PDayArray;
    function GetMonthArray: PMonthArray;
    procedure SetBtnDateStyle (value : tDateBtnStyle);
    procedure SetBtnStyle (value : tButtonStyle);
    procedure SetBtnTabStop (value : boolean);
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure WMSize(var message: TWMSize); message WM_SIZE;
    procedure KeyPress(var Key: char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
  public
    procedure Loaded; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateParams(var Params: TCreateParams); override;
    function DateInList(dt: TDateTime): Boolean;
    procedure AddValidDate(dt: TDateTime);
    procedure ClearValidDates;
    procedure ClearDate(Sender: TObject);
    procedure PopupCalendar(Sender: TObject);
    procedure SetDateValid(pValue : boolean);
    procedure AfterClick(Sender: TObject);
    procedure ValidateDate(Sender: TObject);
    property Date: TDateTime read FDate write SetDate;
    property DateValid : boolean read FDateValid;
    property DayArray: PDayArray read GetDayArray;
    property MonthArray: PMonthArray read GetMonthArray;
    procedure DoDate;
    procedure DoEdit;
  published
    property BorderStyle;
    property Font;
    property TabOrder;
    property TabStop;
    property About : TAboutMeProperty read FAbout write FAbout;
    property ButtonDateStyle : tDateBtnStyle read FBtnDateStyle write SetBtnDateStyle default btsCalendar;
    property ButtonStyle : tButtonstyle read FBtnStyle write SetBtnStyle default bsAutodetect;
    property ButtonTabStop : boolean read FBtnTabStop write SetBtnTabStop default true;
    property CanClear : boolean read FCanClear write SetCanClear default true;
    property CanPopup : boolean read FCanPopup write SetCanPopup default true;
    property CanValidate : boolean read FCanValidate write SetCanValidate default false;
    property ColorArrow : tColor read FColorArrow write FColorArrow default clBlack;
    property ColorDates : tColor read FColorDates write FColorDates default clBlack;
    property ColorWeekEnd : tColor read FColorWeekEnd write FColorWeekEnd default clRed;
    property ColorError : tColor read FColorError write FColorError default clRed;
    property ColorTitle : tColor read FColorTitle write FColorTitle default clNavy;
    property ColorValidDate : TColor read FColorVal write FColorVal default clMaroon;
    property DayNames : TDayName read FDayName write FDayName;
    property EmptyAsToday : boolean read FEmptyAsToday write FEmptyAsToday default false;
    property FocusOnError : boolean read FFocusOnError write FFocusOnError default false;
    property IsMasked : boolean read FIsMasked write FIsMasked default true;
    property IsModal : boolean read FIsModal write FIsModal default false;
    property MonthNames : TMonthName read FMonthName write FMonthName;
    property PopupToday : boolean read FPopupToday write FPopupToday default false;
    property ShortCutAddAlt: Boolean read FShortCutAlt write SetAltOn default False;
    property ShortCutAddCtrl: Boolean read FShortCutCtrl write SetCtrlOn default False;
    property ShortCutClear: Word read FShortCutClear write FShortCutClear default 0;
    property ShortCutPopup: Word read FShortCutPopup write FShortCutPopup default 0;
    property ShortCutValidate: Word read FShortCutValidate write FShortCutValidate default 0;
    property StartOfWeek : TDayOfWeek read FStartOfWeek write SetStartOfWeek default 1;
    property OnChange;
    property OnEnter;
    property OnExit;
    property OnAfterClick : TNotifyEvent read FOnAfterClick write FOnAfterClick;
    property OnValidateClick: TNotifyEvent read FOnValidated write FOnValidated;
  end;

{$IFDEF VER90}
  const
    OBM_COMBO = 32738;
{$ENDIF}
{$IFDEF VER93}
  const
    OBM_COMBO = 32738;
{$ENDIF}

const
{  ErrDateTooShort = 'Date too short';}
  ErrDateTooShort = 'Date trop courte';

implementation

{$R *.RES}

{-------------------------------------------------------------}
{---------------------- TDayName -----------------------------}
{-------------------------------------------------------------}
constructor TDayName.Create;
begin
  inherited Create;
  FSunday := ShortDayNames[1];
  FMonday := ShortDayNames[2];
  FTuesday := ShortDayNames[3];
  FWednesday := ShortDayNames[4];
  FThursday := ShortDayNames[5];
  FFriday := ShortDayNames[6];
  FSaturday := ShortDayNames[7];
end;

destructor TDayName.Destroy;
begin
  inherited Destroy;
end;

{-------------------------------------------------------------}
{---------------------- TMonthName ---------------------------}
{-------------------------------------------------------------}
constructor TMonthName.Create;
begin
  inherited Create;
  FJanuary := LongMonthNames[1];
  FFebruary := LongMonthNames[2];
  FMarch := LongMonthNames[3];
  FApril := LongMonthNames[4];
  FMay := LongMonthNames[5];
  FJune := LongMonthNames[6];
  FJuly := LongMonthNames[7];
  FAugust := LongMonthNames[8];
  FSeptember := LongMonthNames[9];
  FOctober := LongMonthNames[10];
  FNovember := LongMonthNames[11];
  FDecember := LongMonthNames[12];
end;

destructor TMonthName.Destroy;
begin
  inherited Destroy;
end;

{************************* tAboutMeProperty component *************************}
procedure TAboutMeProperty.Edit;
begin
  Application.MessageBox ('tDatePack97 components v3.5.'
                         +#13#10'These components are freeware.'
                         +#13#10'© 1997 BOURMAD Mehdi'
                         +#13#10'http://www.mygale.org/~bourmad'
                         +#13#10'mailto:bourmad@mygale.org',
                         'About',
                         MB_OK+ MB_ICONINFORMATION);
end;

function TAboutMeProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paDialog, paReadOnly];
end;

function TAboutMeProperty.GetValue: string;
begin
  Result := '(about)';
end;

{-------------------------------------------------------------}
{---------------------- TDateEdit97 --------------------------}
{-------------------------------------------------------------}
constructor TDateEdit97.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FEmptyAsToday := false;
  FBtnDateStyle := btsCalendar;
  FBtnStyle := bsAutodetect;
  FBtnTabStop := true;
  FCanClear := true;
  FCanPopup := true;
  FCanValidate := false;
  FColorArrow := clBlack;
  FColorDates := clBlack;
  FColorWeekEnd := clRed;
  FColorError := clRed;
  FColorTitle := clNavy;
  FColorVal := clBlue;
  FFocusOnError := false;
  FIsMasked := true;
  FIsModal := false;
  FPopupToday := false;
  FStartOfWeek := 1;

  NewShortDateFormat := PadTo4Year (RemoveChr (DateSeparator, ShortDateFormat));

  FDate := 0;
  SetDateValid(True);

  FDayName := TDayName.Create;
  FMonthName := TMonthName.Create;

  if FCanClear
  then begin
    FBtnClear := tBitBtn.Create (Self);
    FBtnClear.Visible := True;
    FBtnClear.Parent := Self;
    FBtnClear.Glyph.Handle := LoadBitmap(hInstance, 'BTNCLEAR');
    FBtnClear.NumGlyphs := 2;
    FBtnClear.OnClick := ClearDate;
    FBtnClear.TabStop := FBtnTabStop;
  end;

  if FCanValidate
  then begin
    FBtnValidate := tBitBtn.Create (Self);
    FBtnValidate.Visible := True;
    FBtnValidate.Parent := Self;
    FBtnValidate.Glyph.Handle := LoadBitmap(hInstance, 'BTNVALIDATE');
    FBtnValidate.NumGlyphs := 2;
    FBtnValidate.OnClick := ValidateDate;
    FBtnValidate.TabStop := FBtnTabStop;
  end;

  FBtnPopup := tBitBtn.Create (Self);
  FBtnPopup.Visible := True;
  FBtnPopup.Parent := Self;
  FBtnPopup.Glyph.Handle := LoadBitmap(hInstance, 'BTNPOPUP');
  FBtnPopup.NumGlyphs := 2;
  FBtnPopup.OnClick := PopupCalendar;
  FBtnPopup.TabStop := FBtnTabStop;

  ControlStyle := ControlStyle - [csSetCaption];
  lstDates := TList.Create;
end;

{ create the Calendar }
procedure TDateEdit97.Loaded;
begin
  frmCalendar := TfrmCalPop97.Create(self);
  frmCalendar.Visible := False;
end;

procedure TDateEdit97.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

destructor TDateEdit97.Destroy;
begin
  if Assigned(fBtnClear)
  then begin
    FBtnClear.Free;
    FBtnClear := nil;
  end;
  if Assigned(fBtnValidate)
  then begin
    FBtnValidate.Free;
    FBtnValidate := nil;
  end;
  if Assigned(fBtnPopup)
  then begin
    FBtnPopup.Free;
    FBtnPopup := nil;
  end;
  FDayName.Free;
  FMonthName.Free;
  ClearValidDates;
  lstDates.Free;
  frmCalendar.Free;

  inherited Destroy;
end;

(*********************************************
Show (or hide) Popup Calendar when click
*********************************************)
procedure TDateEdit97.PopupCalendar (Sender: TObject);
begin
  Click;
  if not frmCalendar.Visible
  then begin
    AfterClick(Sender);
{    DoExit; {a tester}  
    if FIsModal
      then begin
        frmCalendar.ShowModal;
        ValidateDate(Sender);
        SetFocus;
      end
      else begin
        frmCalendar.Show;
        SendMessage(Handle,WM_KILLFOCUS,0,0);
      end;
  end
  else begin
    frmCalendar.Hide;
    ValidateDate(Sender);
    SetFocus;
  end;
end;

(*********************************************
Clear the Date field
*********************************************)
procedure TDateEdit97.ClearDate(Sender: TObject);
begin
  Click;
  FDate := 0;
  ValidateDate(Sender);
  SetDateValid(True);
  Text := '';
  SetFocus;
end;

procedure TDateEdit97.ValidateDate(Sender: TObject);
begin
  if Assigned(FOnValidated)
    then FOnValidated(Sender);
end;

procedure TDateEdit97.AfterClick(Sender: TObject);
begin
  if Assigned(FOnAfterClick)
    then FOnAfterClick(Self);
end;

procedure TDateEdit97.CMEnabledChanged(var Message: TMessage);
begin
  if Assigned (FBtnClear)
    then FBtnClear.Enabled := Enabled;
  if Assigned (FBtnPopup)
    then FBtnPopup.Enabled := Enabled;
  if Assigned (FBtnValidate)
    then FBtnValidate.Enabled := Enabled;
  inherited;
end;

procedure TDateEdit97.WMSize(var message: TWMSize);
var
  aLeft : integer;
begin
  aLeft := ClientWidth - ClientHeight - 2 ;
  if Assigned(FBtnValidate)
  then begin
    FBtnValidate.Height := ClientHeight;
    FBtnValidate.Width := ClientHeight + 2;
    FBtnValidate.Left := aLeft;
    FBtnValidate.Refresh;
    aLeft := aLeft-FBtnValidate.Width;
  end;
  if Assigned(FBtnPopup)
  then begin
    FBtnPopup.Height := ClientHeight;
    FBtnPopup.Width := ClientHeight + 2;         
    FBtnPopup.Left := aLeft;
    FBtnPopup.Refresh;
    aLeft := aLeft-FBtnPopup.Width;
  end;
  if Assigned(fBtnClear)
  then begin
    FBtnClear.Height := ClientHeight;
    FBtnClear.Width := ClientHeight + 2;
    FBtnClear.Left := aLeft;
    FBtnClear.Refresh;
  end;
end;

procedure TDateEdit97.SetDate(dtArg: TDateTime);
var
  FullYear : boolean;
  jj, mm, aa : word;
begin
  FDate := dtArg;
  SetDateValid(True);
  Modified := True;
  if FDate = 0 then
    Text := ''
  else begin
    DecodeDate (FDate, aa, mm, jj);
    if aa>1999
    then FullYear := true
    else FullYear := false;

    if (FullYear and (Length(ShortDateFormat) <= 8))
      then Text := FormatDateTime(PadTo4Year (ShortDateFormat), FDate)
      else Text := FormatDateTime(ShortDateFormat, FDate);
  end;
end;

procedure TDateEdit97.SetDateValid (pValue : boolean);
begin
  FDateValid := pValue;
  if FDateValid then
    Font.Color := clWindowText
  else
    Font.Color := FColorError;
end;

function TDateEdit97.GetDayArray: PDayArray;
begin
  FDayArray[1] := DayNames.FMonday;
  FDayArray[2] := DayNames.FTuesday;
  FDayArray[3] := DayNames.FWednesday;
  FDayArray[4] := DayNames.FThursday;
  FDayArray[5] := DayNames.FFriday;
  FDayArray[6] := DayNames.FSaturday;
  FDayArray[7] := DayNames.FSunday;
  Result := @FDayArray;
end;

function TDateEdit97.GetMonthArray: PMonthArray;
begin
  FMonthArray[01] := MonthNames.FJanuary;
  FMonthArray[02] := MonthNames.FFebruary;
  FMonthArray[03] := MonthNames.FMarch;
  FMonthArray[04] := MonthNames.FApril;
  FMonthArray[05] := MonthNames.FMay;
  FMonthArray[06] := MonthNames.FJune;
  FMonthArray[07] := MonthNames.FJuly;
  FMonthArray[08] := MonthNames.FAugust;
  FMonthArray[09] := MonthNames.FSeptember;
  FMonthArray[10] := MonthNames.FOctober;
  FMonthArray[11] := MonthNames.FNovember;
  FMonthArray[12] := MonthNames.FDecember;
  Result := @FMonthArray;
end;

procedure TDateEdit97.SetBtnStyle (value : tButtonStyle);
begin
  FBtnStyle := value;
  if Assigned (FBtnClear)
    then FBtnClear.Style := FBtnStyle;
  if Assigned (FBtnPopup)
    then FBtnPopup.Style := FBtnStyle;
  if Assigned (FBtnValidate)
    then FBtnValidate.Style := FBtnStyle;
end;

procedure TDateEdit97.SetBtnTabStop (value : boolean);
begin
  FBtnTabStop := value;
  if Assigned (FBtnClear)
    then FBtnClear.TabStop := FBtnTabStop;
  if Assigned (FBtnPopup)
    then FBtnPopup.TabStop := FBtnTabStop;
  if Assigned (FBtnValidate)
    then FBtnValidate.TabStop := FBtnTabStop;
end;

procedure TDateEdit97.SetBtnDateStyle (value : tDateBtnStyle);
begin
  if value<>FBtnDateStyle
  then begin
    FBtnDateStyle := value;
    Case value of
      btsDropDown : begin
                      FBtnPopup.Glyph.Handle := LoadBitmap(0, pChar(OBM_COMBO));
                      FBtnPopup.NumGlyphs := 1;
                    end;
      btsCalendar : begin
                      FBtnPopup.Glyph.Handle := LoadBitmap(hInstance, 'BTNPOPUP');
                      FBtnPopup.NumGlyphs := 2;
                    end;
    end;
  end;
end;


procedure TDateEdit97.DoEnter;
begin
  AdjustEdit;
  { Act like standard edit controls }
  SelectAll;
  inherited DoEnter;
end;

procedure TDateEdit97.DoExit;
var PrevText: String;
begin
  PrevText := Text;
  DoDate;
  inherited DoExit;
end;


(*********************************************
Like DoEnter without Selectall
*********************************************)
procedure TDateEdit97.DoEdit;
begin
  AdjustEdit;
  inherited DoEnter;
end;


(*********************************************
Transform number in date and assign values
*********************************************)
procedure TDateEdit97.DoDate;
begin
  if Pos(DateSeparator, Text) = 0
  then begin
    if (Length(Text) = 0)
    then begin
      if FEmptyAsToday
        then FDate := Date
        else FDate := 0;
      SetDateValid(True);
    end
    else begin
      try
        if (Length(Text) < 6) then
          raise EConvertError.Create(ErrDateTooShort);

        AdjustDate;

        FDate := StrToDate(Text);
        SetDateValid(True);

      except
        if FFocusOnError
          then SetFocus;

        SetDateValid(False);
      end;
    end;
  end;
end;

(*********************************************
Set ALT or CTRL or none
*********************************************)
procedure TDateEdit97.SetAltOn(value : boolean);
begin
  FShortCutAlt := value;

  if value
    then FShortCutCtrl := (not value);
end;


(*********************************************
Set ALT or CTRL or none
*********************************************)
procedure TDateEdit97.SetCtrlOn(value : boolean);
begin
  FShortCutCtrl := value;

  if value
    then FShortCutAlt := (not value);
end;


(*********************************************
Remove a character from a string
*********************************************)
function TDateEdit97.RemoveChr (aChar : Char; aStr : String) : String;
var
  i : Integer;
begin
  Result := aStr;
  i := Pos(aChar, Result);
  while i<>0 do
  begin
    Result := Copy (Result, 1, i-1) + Copy (Result, i+1, Length(Result)-i+1);
    i := Pos(aChar, Result);
  end;
end;

(*********************************************
Update local ShortDateFormat with 4digits years
*********************************************)
Function TDateEdit97.PadTo4Year (aStr : String) : String;
var
  Count,
  i : integer;
  AddStr : String[3];
begin
  Count := 0;
  for i:=1 to Length(aStr) do
    if aStr[i] in ['y', 'Y']
      then inc(Count);
  AddStr := '';
  for i:=Count+1 to 4 do
    AddStr := AddStr + 'y';
  i := pos ('Y', UpperCase(aStr));
  Result := Copy (aStr, 1, i-1)+AddStr+Copy (aStr, i+1, Length(aStr)-i+1);
end;

(*********************************************
Transform date in number
*********************************************)
procedure TDateEdit97.AdjustEdit;
begin
  if IsMasked
    then Text := FormatDateTime (NewShortDateFormat, FDate);
end;

(*********************************************
Transform number in date
*********************************************)
procedure TDateEdit97.AdjustDate;
Var
  su, sv, sw,
  u, v, w: string;
  lu, lv, lw,
  i, j: integer;
begin
  if IsMasked
  then if Pos(DateSeparator, Text) = 0
  then begin
    i := Pos(DateSeparator, ShortDateFormat);
    j := Pos(DateSeparator, Copy(ShortDateFormat, i + 1, Length(ShortDateFormat)-i)) + i;
    {extract day, month and year from ShortDateFormat}
    su := Copy(ShortDateFormat, 1, i - 1);
    sv := Copy(ShortDateFormat, i + 1, j - i - 1);
    sw := Copy(ShortDateFormat, j + 1, 4);

   {Because we don't know where is year in DateFormat, we need to check it}
   {in all 3 values}
    if (su[1] in ['y', 'Y'])
    then lu := 4
    else lu := 2;
    if (sv[1] in ['y', 'Y'])
    then lv := 4
    else lv := 2;
    if (sw[1] in ['y', 'Y'])
    then lw := 4
    else lw := 2;

    u := Copy(Text, 1, lu);
    v := Copy(Text, lu + 1, lv);
    w := Copy(Text, lu + lv + 1, lw);

    Text := u + DateSeparator + v + DateSeparator + w;
  end;
end;

(*********************************************
Is the supplied data in the date list?
*********************************************)
function TDateEdit97.DateInList(dt: TDateTime): Boolean;
var
  pDate: PTDateTime;
  I: Integer;
begin
  Result := False;
  for I := 0 to lstDates.Count - 1 do
  begin
    pDate := lstDates[I];
    if pDate^ = dt then
    begin
      Result := True;
      Break;
    end;
  end;
end;

(*********************************************
Maintain list of valid dates.
*********************************************)
procedure TDateEdit97.AddValidDate(dt: TDateTime);
var
  pDate: PTDateTime;
begin
  New(pDate);
  pDate^ := dt;
  lstDates.Add(PDate);
end;

procedure TDateEdit97.ClearValidDates;
var
  pDate: PTDateTime;
begin
  if not Assigned (lstDates)
    then Exit;
  while lstDates.Count > 0 do
  begin
    pDate := lstDates[0];
    Dispose(pDate);
    lstDates.Delete(0);
  end;
end;

procedure TDateEdit97.KeyPress(var Key: Char);
begin
  if not (Key in ['0'..'9', #8, #27, #13])
    then Key := #0;

  inherited KeyPress(Key);
end;

(*********************************************
handling procedure (SHORTCUTKEYS)
*********************************************)
procedure TDateEdit97.KeyDown(var Key: Word; Shift: TShiftState);
var AltPressed, CtrlPressed: Boolean;
    NotShift: Boolean;
begin

  AltPressed := (FShortCutAlt) and (ssAlt in Shift);
  CtrlPressed := (FShortCutCtrl) and (ssCtrl in Shift);
  NotShift := (not FShortCutAlt) and (not FShortCutCtrl);

  if Enabled
  then begin
    if (AltPressed or CtrlPressed) or NotShift
    then begin
      if (Key = FShortCutClear) and (Assigned(fBtnClear))
        then FBtnClear.Click
        else
          if (Key = FShortCutPopup) and (Assigned(fBtnPopup))
            then FBtnPopup.Click
            else
              if (Key = FShortCutValidate) and (Assigned(fBtnValidate))
                then FBtnValidate.Click;
    end;
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TDateEdit97.SetStartOfWeek(Value: TDayOfWeek);
begin
  if FStartOfWeek <> Value then FStartOfWeek := Value;
end;

(*********************************************
Set Buttons
*********************************************)
procedure TDateEdit97.SetCanPopup (value : boolean);
begin
  FCanPopup := value;
  FBtnPopup.Enabled := value;
  Update;
end;

procedure TDateEdit97.SetCanClear (value : boolean);
begin
  if FCanClear<>value
  then begin
    FCanClear := value;
    if FCanClear
    then begin
      if not Assigned (FBtnClear)
        then FBtnClear := tBitBtn.Create (Self);
      FBtnClear.Visible := True;
      FBtnClear.Parent := Self;
      FBtnClear.Glyph.Handle := LoadBitmap(hInstance, 'BTNCLEAR');
      FBtnClear.NumGlyphs := 2;
      FBtnClear.OnClick := ClearDate;
      FBtnClear.TabStop := FBtnTabStop;
      Perform (WM_SIZE, SIZE_RESTORED, MAKELONG(width, height));
    end
    else begin
      if Assigned(fBtnClear)
      then begin
        FBtnClear.Free;
        FBtnClear := nil;
      end;
    end;
    Perform (WM_SIZE, SIZE_RESTORED, MAKELONG(width, height));
  end;
end;

procedure TDateEdit97.SetCanValidate (value : boolean);
begin
  if FCanValidate<>value
  then begin
    FCanValidate := value;
    if FCanValidate
    then begin
      if not Assigned (FBtnValidate)
        then FBtnValidate := tBitBtn.Create (Self);
      FBtnValidate.Visible := True;
      FBtnValidate.Parent := Self;
      FBtnValidate.Glyph.Handle := LoadBitmap(hInstance, 'BTNVALIDATE');
      FBtnValidate.NumGlyphs := 2;
      FBtnValidate.OnClick := ValidateDate;
      FBtnValidate.TabStop := FBtnTabStop;
    end
    else begin
      if Assigned(FBtnValidate)
      then begin
        FBtnValidate.Free;
        FBtnValidate := nil;
      end;
    end;
    Perform (WM_SIZE, SIZE_RESTORED, MAKELONG(width, height));
  end;
end;

end.
