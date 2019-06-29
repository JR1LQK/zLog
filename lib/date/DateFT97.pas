unit DateFT97;

(******************************************************************************
TDateFromTo97 

Derived from
    tCustomPanel

Properties
    TabOrder, BevelInner, BevelOuter,
    BorderStyle, BorderWidth : Derived from tCustomPanel
    DateFrom, DateTo : Dates selected
    PanelOrientation : select type of panel (horizontal or vertical)
    TextFrom : Caption 'From'
    TextTo : Caption 'To'
    and all properties from DateEdit97

procedures
    ClearDate: Clear dates from DateFrom and DateTo

Event
    OnChangeFrom : when DateFrom is changed
    OnChangeTo   : when DateTo is changed

Author name=BOURMAD Mehdi
Author E-mail=bourmad@mygale.org
Author URL=www.mygale.org/~bourmad
******************************************************************************)

interface

uses
  Buttons, Classes, Controls, ExtCtrls, Forms, Graphics, Messages, StdCtrls,
  SysUtils, DateEd97;


type
  TOrientation = (oHorizontal, oVertical);

  TDateFromTo97 = class(TCustomPanel)
  private
    { Private declarations }
    FAbout : TAboutMeProperty;
    FDateFrom,
    FDateTo   : TDateEdit97;
    FLabelFrom,
    FLabelTo   : TLabel;
    FOrientation : tOrientation;
    procedure PlaceComponents;
    function GetOnChangeFrom : tNotifyEvent;
    procedure SetOnChangeFrom (value : tNotifyEvent);
    function GetOnChangeTo : tNotifyEvent;
    procedure SetOnChangeTo (value : tNotifyEvent);
    procedure SetOrientation (value : tOrientation);
    function GetLabelFrom : string;
    function GetLabelTo : string;
    procedure SetLabelFrom (value : string);
    procedure SetLabelTo (value : string);
    function GetDateFrom : tDateTime;
    function GetDateTo : tDateTime;
    procedure SetDateFrom (value : tDateTime);
    procedure SetDateTo (value : tDateTime);
    function GetColorVal : tColor;
    function GetColorArrow : tColor;
    function GetColorDates : tColor;
    function GetColorWeekEnd : tColor;
    function GetColorError : tColor;
    function GetColorTitle : tColor;
    procedure SetColorVal (value : tColor);
    procedure SetColorArrow (value : tColor);
    procedure SetColorDates (value : tColor);
    procedure SetColorWeekEnd (value : tColor);
    procedure SetColorError (value : tColor);
    procedure SetColorTitle (value : tColor);
    function GetBtnDateStyle : tDateBtnStyle;
    procedure SetBtnDateStyle (value : tDateBtnStyle);
    function GetBtnBorderStyle : tBorderStyle;
    procedure SetBtnBorderStyle (value : tBorderStyle);
    function GetBtnStyle : tButtonStyle;
    procedure SetBtnStyle (value : tButtonstyle);
    function GetBtnTabStop : boolean;
    procedure SetBtnTabStop (value : boolean);
    function GetCanClear : boolean;
    procedure SetCanClear (value : boolean);
    function GetCanPopup : boolean;
    procedure SetCanPopup (value : boolean);
    function GetCanValidate : boolean;
    procedure SetCanValidate (value : boolean);
    function GetEmptyAsToday : boolean;
    procedure SetEmptyAsToday (value : boolean);
    function GetFocusOnError : boolean;
    procedure SetFocusOnError (value : boolean);
    function GetIsMasked : boolean;
    procedure SetIsMasked (value : boolean);
    function GetIsModal : boolean;
    procedure SetIsModal (value : boolean);
    function GetDayName : tDayName;
    procedure SetDayName (value : tDayName);
    function GetMonthName : tMonthName;
    procedure SetMonthName (value : tMonthName);
    function GetPopupToday : boolean;
    procedure SetPopupToday (value : boolean);
    function GetShortCutAlt : boolean;
    procedure SetShortCutAlt (value : boolean);
    function GetShortCutCtrl : boolean;
    procedure SetShortCutCtrl (value : boolean);
    function GetShortCutClear : word;
    procedure SetShortCutClear (value : word);
    function GetShortCutPopup : word;
    procedure SetShortCutPopup (value : word);
    function GetShortCutValidate : word;
    procedure SetShortCutValidate (value : word);
    function GetStartOfWeek : tDayOfWeek;
    procedure SetStartOfWeek (value : tDayOfWeek);
  protected
    { Protected declarations }
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
  public
    { Public declarations }
    Constructor Create(AOwner:TComponent); override;
    Destructor Destroy; override;
    Procedure Loaded; override;
    procedure ClearDate (Sender: TObject);
    property DateFrom: tDateTime read GetDateFrom write SetDateFrom;
    property DateTo: tDateTime read GetDateTo write SetDateTo;
  published
    { Published declarations }
    Property BevelInner;
    Property BevelOuter;
    Property BorderStyle;
    Property BorderWidth;
    Property Font;
    Property TabOrder;
    Property TabStop;
    property About: TAboutMeProperty read FAbout write FAbout;
    property ButtonBorderStyle: tBorderStyle read GetBtnBorderStyle write SetBtnBorderStyle default bsSingle;
    property ButtonDateStyle: tDateBtnStyle read GetBtnDateStyle write SetBtnDateStyle default btsCalendar;
    property ButtonStyle : tButtonStyle read GetBtnStyle write SetBtnStyle default bsAutodetect;
    property ButtonTabStop: boolean read GetBtnTabStop write SetBtnTabStop default true;
    property CanClear: boolean read GetCanClear write SetCanClear default true;
    property CanPopup: boolean read GetCanPopup write SetCanPopup default true;
    property CanValidate : boolean read GetCanValidate write SetCanValidate default false;
    property ColorArrow : tColor read GetColorArrow write SetColorArrow default clBlack;
    property ColorDates : tColor read GetColorDates write SetColorDates default clBlack;
    property ColorWeekEnd : tColor read GetColorWeekEnd write SetColorWeekEnd default clRed;
    property ColorError : tColor read GetColorError write SetColorError default clRed;
    property ColorTitle : tColor read GetColorTitle write SetColorTitle default clNavy;
    property ColorValidDate : TColor read GetColorVal write SetColorVal default clMaroon;
    property DayNames: TDayName read GetDayName write SetDayName;
    property EmptyAsToday : boolean read GetEmptyAsToday write SetEmptyAsToday default false;
    property FocusOnError : boolean read GetFocusOnError write SetFocusOnError default false;
    property IsMasked : boolean read GetIsMasked write SetIsMasked default true;
    property IsModal: boolean read GetIsModal write SetIsModal default false;
    property MonthNames: TMonthName read GetMonthName write SetMonthName;
    property PopupToday : boolean read GetPopupToday write SetPopupToday default false;
    property ShortCutAddAlt: Boolean read GetShortCutAlt write SetShortCutAlt default False;
    property ShortCutAddCtrl: Boolean read GetShortCutCtrl write SetShortCutCtrl default False;
    property ShortCutClear: Word read GetShortCutClear write SetShortCutClear default 0;
    property ShortCutPopup: Word read GetShortCutPopup write SetShortCutPopup default 0;
    property ShortCutValidate: Word read GetShortCutValidate write SetShortCutValidate default 0;
    property StartOfWeek: TDayOfWeek read GetStartOfWeek write SetStartOfWeek default 1;
    property OnChangeFrom : TNotifyEvent read GetOnChangeFrom write SetOnChangeFrom;
    property OnChangeTo : TNotifyEvent read GetOnChangeTo write SetOnChangeTo;
    property PanelOrientation : tOrientation read FOrientation write SetOrientation default oHorizontal;
    property TextFrom: String read GetLabelFrom write SetLabelFrom;
    property TextTo: String read GetLabelTo write SetLabelTo;
  end;

implementation

const
  IdsFrom = 'From';
  IdsTo   = 'To';

Constructor TDateFromTo97.Create(AOwner:TComponent);
Begin
  inherited Create(AOwner);

  ParentFont := true;

  FLabelFrom:=TLabel.Create(Self);
  FLabelFrom.Parent := Self;
  FLabelFrom.Caption:=IdsFrom;

  FDateFrom:=TDateEdit97.Create(Self);
  FDateFrom.Parent := Self;
  FDateFrom.Date := Date;

  FLabelTo:=TLabel.Create(Self);
  FLabelTo.Parent := Self;
  FLabelTo.Caption:=IdsTo;

  FDateTo:=TDateEdit97.Create(Self);
  FDateTo.Parent := Self;
  FDateTo.Date := Date;

  ControlStyle := ControlStyle - [csSetCaption];

  PanelOrientation := oHorizontal;
End;

Procedure TDateFromTo97.Loaded;
Begin
  inherited Loaded;
  FDateFrom.Loaded;
  FDateTo.Loaded;
  PlaceComponents;
  Caption:='';
end;

destructor TDateFromTo97.Destroy;
begin
  FDateFrom.Free;
  FDateTo.Free;
  FLabelFrom.Free;
  FLabelTo.Free;
  inherited Destroy;
end;

procedure TDateFromTo97.CMEnabledChanged(var Message: TMessage);
begin
  FDateFrom.Enabled := Enabled;
  FDateTo.Enabled := Enabled;
  Invalidate;
end;

procedure TDateFromTo97.ClearDate (Sender: TObject);
begin
  FDateFrom.ClearDate (Sender);
  FDateTo.ClearDate (Sender);
end;

procedure TDateFromTo97.PlaceComponents;
begin
  Case FOrientation of
    oHorizontal : begin
                    FLabelFrom.Top := 8;
                    FLabelFrom.Left := 8;
                    FDateFrom.Top := 8;
                    FDateFrom.Left := FLabelFrom.Left+FLabelFrom.Width+8;
                    FLabelTo.Top := 8;
                    FLabelTo.Left := FDateFrom.Left+FDateFrom.Width+8;
                    FDateTo.Top := 8;
                    FDateTo.Left := FLabelTo.Left+FLabelTo.Width+8;
                  end;
    oVertical   : begin
                    FLabelFrom.Top := 8;
                    FLabelFrom.Left := 8;
                    FDateFrom.Top := FLabelFrom.Top+FLabelFrom.Height+8;
                    FDateFrom.Left := 16;
                    FLabelTo.Top := FDateFrom.Top+FDateFrom.Height+8;
                    FLabelTo.Left := 8;
                    FDateTo.Top := FLabelTo.Top+FLabelTo.Height+8;
                    FDateTo.Left := 16;
                  end;
  end;
  Width := FDateTo.Left+FDateTo.Width+8;
  Height := FDateTo.Top+FDateTo.Height+8;
end;

function TDateFromTo97.GetOnChangeFrom : tNotifyEvent;
begin
  Result := FDateFrom.Onchange;
end;

procedure TDateFromTo97.SetOnChangeFrom (value : tNotifyEvent);
begin
  FDateFrom.OnChange := value;
end;

function TDateFromTo97.GetOnChangeTo : tNotifyEvent;
begin
  Result := FDateTo.Onchange;
end;

procedure TDateFromTo97.SetOnChangeTo (value : tNotifyEvent);
begin
  FDateTo.OnChange := value;
end;

procedure TDateFromTo97.SetOrientation (value : tOrientation);
begin
  if FOrientation <> value
  then begin
    FOrientation := value;
    PlaceComponents;
  end;
end;

function TDateFromTo97.GetLabelFrom : string;
begin
  Result := FLabelFrom.Caption;
end;

function TDateFromTo97.GetLabelTo : string;
begin
  Result := FLabelTo.Caption;
end;

procedure TDateFromTo97.SetLabelFrom (value : string);
begin
  FLabelFrom.Caption := value;
  PlaceComponents;
end;

procedure TDateFromTo97.SetLabelTo (value : string);
begin
  FLabelTo.Caption := value;
  PlaceComponents;
end;

function TDateFromTo97.GetDateFrom : tDateTime;
begin
  Result := FDateFrom.Date;
end;

function TDateFromTo97.GetDateTo : tDateTime;
begin
  Result := FDateTo.Date;
end;

procedure TDateFromTo97.SetDateFrom (value : tDateTime);
begin
  FDateFrom.Date := value;
  Update;
end;

procedure TDateFromTo97.SetDateTo (value : tDateTime);
begin
  FDateTo.Date := value;
  Update;
end;

function TDateFromTo97.GetColorVal : tColor;
begin
  Result := FDateFrom.ColorValidDate;
end;

function TDateFromTo97.GetColorArrow : tColor;
begin
  Result := FDateFrom.ColorArrow;
end;

function TDateFromTo97.GetColorDates : tColor;
begin
  Result := FDateFrom.ColorDates;
end;

function TDateFromTo97.GetColorWeekEnd : tColor;
begin
  Result := FDateFrom.ColorWeekEnd;
end;

function TDateFromTo97.GetColorError : tColor;
begin
  Result := FDateFrom.ColorError;
end;

function TDateFromTo97.GetColorTitle : tColor;
begin
  Result := FDateFrom.ColorTitle;
end;

procedure TDateFromTo97.SetColorVal (value : tColor);
begin
  FDateFrom.ColorValidDate := value;
  FDateTo.ColorValidDate := value;
  PlaceComponents;
end;

procedure TDateFromTo97.SetColorArrow (value : tColor);
begin
  FDateFrom.ColorArrow := value;
  FDateTo.ColorArrow := value;
  PlaceComponents;
end;

procedure TDateFromTo97.SetColorDates (value : tColor);
begin
  FDateFrom.ColorDates := value;
  FDateTo.ColorDates := value;
  PlaceComponents;
end;

procedure TDateFromTo97.SetColorWeekEnd (value : tColor);
begin
  FDateFrom.ColorWeekEnd := value;
  FDateTo.ColorWeekEnd := value;
  PlaceComponents;
end;

procedure TDateFromTo97.SetColorError (value : tColor);
begin
  FDateFrom.ColorError := value;
  FDateTo.ColorError := value;
  PlaceComponents;
end;

procedure TDateFromTo97.SetColorTitle (value : tColor);
begin
  FDateFrom.ColorTitle := value;
  FDateTo.ColorTitle := value;
  PlaceComponents;
end;

function TDateFromTo97.GetBtnBorderStyle : tBorderStyle;
begin
  Result := FDateFrom.BorderStyle;
end;

procedure TDateFromTo97.SetBtnBorderStyle (value : tBorderStyle);
begin
  FDateFrom.BorderStyle := value;
  FDateTo.BorderStyle := value;
end;

function TDateFromTo97.GetBtnDateStyle : tDateBtnStyle;
begin
  Result := FDateFrom.ButtonDateStyle;
end;

procedure TDateFromTo97.SetBtnDateStyle (value : tDateBtnStyle);
begin
  FDateFrom.ButtonDateStyle := value;
  FDateTo.ButtonDateStyle := value;
end;

function TDateFromTo97.GetBtnStyle : tButtonstyle;
begin
  Result := FDateFrom.ButtonStyle;
end;

procedure TDateFromTo97.SetBtnStyle (value : tButtonstyle);
begin
  FDateFrom.ButtonStyle := value;
  FDateTo.ButtonStyle := value;
end;

function TDateFromTo97.GetBtnTabStop : boolean;
begin
  Result := FDateFrom.ButtonTabStop;
end;

procedure TDateFromTo97.SetBtnTabStop (value : boolean);
begin
  FDateFrom.ButtonTabStop := value;
  FDateTo.ButtonTabStop := value;
end;

function TDateFromTo97.GetCanClear : boolean;
begin
  Result := FDateFrom.CanClear;
end;

procedure TDateFromTo97.SetCanClear (value : boolean);
begin
  FDateFrom.CanClear := value;
  FDateTo.CanClear := value;
end;

function TDateFromTo97.GetCanPopup : boolean;
begin
  Result := FDateFrom.CanPopup;
end;

procedure TDateFromTo97.SetCanPopup (value : boolean);
begin
  FDateFrom.CanPopup := value;
  FDateTo.CanPopup := value;
end;

function TDateFromTo97.GetCanValidate : boolean;
begin
  Result := FDateFrom.CanValidate;
end;

procedure TDateFromTo97.SetCanValidate (value : boolean);
begin
  FDateFrom.CanValidate := value;
  FDateTo.CanValidate := value;
end;

function TDateFromTo97.GetEmptyAsToday : boolean;
begin
  Result := FDateFrom.EmptyAsToday;
end;

procedure TDateFromTo97.SetEmptyAsToday (value : boolean);
begin
  FDateFrom.EmptyAsToday := value;
  FDateTo.EmptyAsToday := value;
end;

function TDateFromTo97.GetFocusOnError : boolean;
begin
  Result := FDateFrom.FocusOnError;
end;

procedure TDateFromTo97.SetFocusOnError (value : boolean);
begin
  FDateFrom.FocusOnError := value;
  FDateTo.FocusOnError := value;
end;

function TDateFromTo97.GetIsMasked : boolean;
begin
  Result := FDateFrom.IsMasked;
end;

procedure TDateFromTo97.SetIsMasked (value : boolean);
begin
  FDateFrom.IsMasked := value;
  FDateTo.IsMasked := value;
end;

function TDateFromTo97.GetIsModal : boolean;
begin
  Result := FDateFrom.IsModal;
end;

procedure TDateFromTo97.SetIsModal (value : boolean);
begin
  FDateFrom.IsModal := value;
  FDateTo.IsModal := value;
end;

function TDateFromTo97.GetDayName : tDayName;
begin
  Result := FDateFrom.DayNames;
end;

procedure TDateFromTo97.SetDayName (value : tDayName);
begin
  FDateFrom.DayNames := value;
  FDateTo.DayNames := value;
end;

function TDateFromTo97.GetMonthName : tMonthName;
begin
  Result := FDateFrom.MonthNames;
end;

procedure TDateFromTo97.SetMonthName (value : tMonthName);
begin
  FDateFrom.MonthNames := value;
  FDateTo.MonthNames := value;
end;

function TDateFromTo97.GetPopupToday : boolean;
begin
  Result := FDateFrom.PopupToday;
end;

procedure TDateFromTo97.SetPopupToday (value : boolean);
begin
  FDateFrom.PopupToday := value;
  FDateTo.PopupToday := value;
end;

function TDateFromTo97.GetShortCutAlt : boolean;
begin
  Result := FDateFrom.ShortCutAddAlt;
end;

procedure TDateFromTo97.SetShortCutAlt (value : boolean);
begin
  FDateFrom.ShortCutAddAlt := value;
  FDateTo.ShortCutAddAlt := value;
end;

function TDateFromTo97.GetShortCutCtrl : boolean;
begin
  Result := FDateFrom.ShortCutAddCtrl;
end;

procedure TDateFromTo97.SetShortCutCtrl (value : boolean);
begin
  FDateFrom.ShortCutAddCtrl := value;
  FDateTo.ShortCutAddCtrl := value;
end;

function TDateFromTo97.GetShortCutClear : word;
begin
  Result := FDateFrom.ShortCutClear;
end;

procedure TDateFromTo97.SetShortCutClear (value : word);
begin
  FDateFrom.ShortCutClear := value;
  FDateTo.ShortCutClear := value;
end;

function TDateFromTo97.GetShortCutPopup : word;
begin
  Result := FDateFrom.ShortCutPopup;
end;

procedure TDateFromTo97.SetShortCutPopup (value : word);
begin
  FDateFrom.ShortCutPopup := value;
  FDateTo.ShortCutPopup := value;
end;

function TDateFromTo97.GetShortCutValidate : word;
begin
  Result := FDateFrom.ShortCutValidate;
end;

procedure TDateFromTo97.SetShortCutValidate (value : word);
begin
  FDateFrom.ShortCutValidate := value;
  FDateTo.ShortCutValidate := value;
end;

function TDateFromTo97.GetStartOfWeek : tDayOfWeek;
begin
  Result := FDateFrom.StartOfWeek;
end;

procedure TDateFromTo97.SetStartOfWeek (value : tDayOfWeek);
begin
  FDateFrom.StartOfWeek := value;
  FDateTo.StartOfWeek := value;
end;

end.

