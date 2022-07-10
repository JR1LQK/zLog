unit UPartials;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, zLogGlobal, ExtCtrls, Buttons, Spin;

const sortTime = 1;
      sortBand = 2;
      sortCall = 3;

type
  TPartialCheck = class(TForm)
    ListBox: TListBox;
    Panel: TPanel;
    Button3: TButton;
    CheckBox1: TCheckBox;
    ShowMaxEdit: TSpinEdit;
    Label1: TLabel;
    SortByGroup: TGroupBox;
    rbTime: TRadioButton;
    rbBand: TRadioButton;
    rbCall: TRadioButton;
    MoreButton: TSpeedButton;
    StayOnTop: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CheckBox1Click(Sender: TObject);
    procedure MoreButtonClick(Sender: TObject);
    procedure ShowMaxEditChange(Sender: TObject);
    procedure rbSortClick(Sender: TObject);
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxDblClick(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);

  private
    TempQSO : TQSO;
    DispMax : word;
    { Private declarations }
    function SortBy : byte;
  public
    _CheckCall : boolean;
    AllBand : boolean;
    HitNumber : integer;
    HitCall : string;
    procedure RenewListBox(QSOList : TList);
    procedure CheckPartial(aQSO : TQSO);
    procedure CheckPartialNumber(aQSO : TQSO);
    procedure SortByCall(var QSOList : TList);
    procedure SortByTime(var QSOList : TList);
    procedure SortByBand(var QSOList : TList);
    procedure Update(aQSO : TQSO); // calls either checkpartial or checkpartialnumber
                                   // depending on _CheckCall value;
    { Public declarations }
  end;

var
  PartialCheck: TPartialCheck;

implementation

uses Main, UOptions;

{$R *.DFM}

(*
procedure TQuickSort.Sort(var A: array of Integer);

  procedure QuickSort(var A: array of Integer; iLo, iHi: Integer);
  var
    Lo, Hi, Mid, T: Integer;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while A[Lo] < Mid do Inc(Lo);
      while A[Hi] > Mid do Dec(Hi);
      if Lo <= Hi then
      begin
        VisualSwap(A[Lo], A[Hi], Lo, Hi);
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSort(A, iLo, Hi);
    if Lo < iHi then QuickSort(A, Lo, iHi);
    if Terminated then Exit;
  end;

begin
  QuickSort(A, Low(A), High(A));
end;
*)

procedure TPartialCheck.SortByCall(var QSOList : TList);

  procedure QuickSortCall(var QSOList : TList; iLo, iHi : integer);
  var Lo, Hi : integer;
      Mid : string;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := TQSO(QSOList[(Lo + Hi) div 2]).QSO.Callsign;
    repeat
      while CompareText(TQSO(QSOList[Lo]).QSO.CallSign, Mid) < 0 do
        inc(Lo);
      while CompareText(TQSO(QSOList[Hi]).QSO.CallSign, Mid) > 0 do
        dec(Hi);
      if Lo <= Hi then
        begin
          QSOList.Exchange(Lo, Hi);
          inc(Lo);
          dec(Hi);
        end;
    until Lo > Hi;
    if Hi > iLo then QuickSortCall(QSOList, iLo, Hi);
    if Lo < iHi then QuickSortCall(QSOList, Lo, iHi);
  end;

begin
  QuickSortCall(QSOList,0,QSOList.Count-1);
end;

procedure TPartialCheck.SortByTime(var QSOList : TList);

  procedure QuickSortTime(var QSOList : TList; iLo, iHi : integer);
  var Lo, Hi : integer;
      Mid : TDateTime;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := TQSO(QSOList[(Lo + Hi) div 2]).QSO.Time;
    repeat
      while (TQSO(QSOList[Lo]).QSO.Time < Mid) do
        inc(Lo);
      while (TQSO(QSOList[Hi]).QSO.Time > Mid) do
        dec(Hi);
      if Lo <= Hi then
        begin
          QSOList.Exchange(Lo, Hi);
          inc(Lo);
          dec(Hi);
        end;
    until Lo > Hi;
    if Hi > iLo then QuickSortTime(QSOList, iLo, Hi);
    if Lo < iHi then QuickSortTime(QSOList, Lo, iHi);
  end;

begin
  QuickSortTime(QSOList,0,QSOList.Count-1);
end;

procedure TPartialCheck.SortByBand(var QSOList : TList);
var BandOrder : array[b19..b10g] of integer;
    b : TBand;

  procedure QuickSortBand(var QSOList : TList; iLo, iHi : integer);
  var Lo, Hi : integer;
      Mid : integer{TBand};
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := BandOrder[TQSO(QSOList[(Lo + Hi) div 2]).QSO.Band];
    repeat
      while (BandOrder[TQSO(QSOList[Lo]).QSO.Band] < Mid) do
        inc(Lo);
      while (BandOrder[TQSO(QSOList[Hi]).QSO.Band] > Mid) do
        dec(Hi);
      if Lo <= Hi then
        begin
          QSOList.Exchange(Lo, Hi);
          inc(Lo);
          dec(Hi);
        end;
    until Lo > Hi;
    if Hi > iLo then QuickSortBand(QSOList, iLo, Hi);
    if Lo < iHi then QuickSortBand(QSOList, Lo, iHi);
  end;

begin
  for b := b19 to b10g do
    BandOrder[b] := ord(b)+1;
  BandOrder[Main.CurrentQSO.QSO.Band] := 0;

  QuickSortBand(QSOList,0,QSOList.Count-1);
end;



function TPartialCheck.SortBy : Byte;
begin
  Result := sortTime;
  if rbBand.Checked then
    Result := sortBand;
  if rbCall.Checked then
    Result := sortCall;
end;

procedure TPartialCheck.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;


procedure TPartialCheck.CheckPartialNumber(aQSO : TQSO);
var PartialStr : string;
    i : LongInt;
    B : TBand;
    _count : integer;
    TempList : TList;
label disp;
begin
  _CheckCall := False;
  _count := 0;
  TempQSO := aQSO;
  TempList := TList.Create;
  // ListBox.Items.Clear;
  PartialStr := aQSO.QSO.NrRcvd;
  if PartialStr <> '' then
    begin

{
      for B := b19 to HiBand do // added 0.23
        for i := 1 to SubLog[B].TotalQSO do
          if Pos(PartialStr, TQSO(SubLog[B].List[i]).QSO.NrRcvd) > 0 then
            if AllBand or (not(AllBand) and (aQSO.QSO.band = TQSO(SubLog[B].List[i]).QSO.band)) then
              begin
                TempList.Add(TQSO(SubLog[B].List[i]));
                if _count >= DispMax then
                  //exit
                  goto disp
                else
                  inc(_count);
              end;
}

      for i := 1 to Log.TotalQSO do
        if Pos(PartialStr, TQSO(Log.List[i]).QSO.NrRcvd) > 0 then
          if AllBand or (not(AllBand) and (aQSO.QSO.band = TQSO(Log.List[i]).QSO.band)) then
            begin
              TempList.Add(TQSO(Log.List[i]));
              if _count >= DispMax then
                goto disp
                //exit
              else
                inc(_count);
            end;
    end
  else
    begin
      ListBox.Clear;
      TempList.Free;
      exit;
    end;
disp :
  if TempList.Count = 0 then
    begin
      ListBox.Clear;
      TempList.Free;
      exit;
    end;
  case SortBy of
    sortTime : SortByTime(TempList);
    sortBand : begin
                 SortByBand(TempList);
                 //PushUpCurrentBand(TempList,aQSO.QSO.Band);
               end;
    sortCall : SortByCall(TempList);
  end;

  RenewListBox(TempList);
  TempList.Free;
end;

procedure TPartialCheck.RenewListBox(QSOList : TList);
var i : integer;
    S : string;
begin
  ListBox.Items.Clear;
  if QSOList.Count = 0 then
    exit;
  for i := 0 to QSOList.Count-1 do
    begin
      S := TQSO(QSOList[i]).PartialSummary(Options.Settings._displaydatepartialcheck);
      if TQSO(QSOList[i]).QSO.Band = Main.CurrentQSO.QSO.Band then
        S := '*' + S;
      ListBox.Items.Add(S);
    end;
end;

procedure TPartialCheck.CheckPartial(aQSO : TQSO);
var PartialStr : string;
    i : LongInt;
    B : TBand;
    _count : integer;
    TempList : TList;
label disp;
begin
  HitNumber := 0;
  HitCall := '';
  _CheckCall := True;
  _count := 0;
  TempQSO := aQSO;
  //ListBox.Items.Clear;
  PartialStr := aQSO.QSO.Callsign;
  if Options.Settings._searchafter >= length(PartialStr) then
    begin
      ListBox.Items.Clear;
      exit;
    end;

  if pos(',',PartialStr) = 1 then
    exit;

  TempList := TList.Create;
  if (PartialStr <> '') then
    begin
      for i := 1 to Log.TotalQSO do
//      if Pos(PartialStr, TQSO(Log.List[i]).QSO.Callsign) > 0 then
        if PartialMatch(PartialStr, TQSO(Log.List[i]).QSO.Callsign) then
          if AllBand or (not(AllBand) and (aQSO.QSO.band = TQSO(Log.List[i]).QSO.band)) then
            begin
              //ListBox.Items.Add(TQSO(Log.List[i]).PartialSummary);
              TempList.Add(TQSO(Log.List[i]));
              if _count >= DispMax then
                goto disp
                //exit
              else
                inc(_count);
            end;
    end
  else  {PartialStr = ''}
    begin
      ListBox.Clear;
      TempList.Free;
      exit;
    end;

disp :
  if TempList.Count = 0 then
    begin
      ListBox.Clear;
      TempList.Free;
      exit;
    end;

  HitNumber := TempList.Count;

  case SortBy of
    sortTime : SortByTime(TempList);
    sortBand : SortByBand(TempList);
    sortCall : SortByCall(TempList);
  end;

  RenewListBox(TempList);

  HitCall := TQSO(TempList.Items[0]).QSO.Callsign;

  TempList.Free;
end;

procedure TPartialCheck.FormCreate(Sender: TObject);
begin
  AllBand := True;
  //CheckBox1.Checked := AllBand;
  _CheckCall := True;
  DispMax := 200;
  ShowMaxEdit.Value := DispMax;
end;

procedure TPartialCheck.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TPartialCheck.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : MainForm.LastFocus.SetFocus;
  end;
end;

{procedure TPartialCheck.CheckBox1Click(Sender: TObject);
begin
end; }

procedure TPartialCheck.CheckBox1Click(Sender: TObject);
begin
  AllBand := CheckBox1.Checked;
  if _CheckCall then
    CheckPartial(TempQSO)
  else
    CheckPartialNumber(TempQSO);
end;



procedure TPartialCheck.MoreButtonClick(Sender: TObject);
begin
  if MoreButton.Caption = 'More..' then
    begin
      MoreButton.Caption := 'Hide';
      Panel.Height := 64;
    end
  else
    begin
      MoreButton.Caption := 'More..';
      Panel.Height := 32;
    end;
end;

procedure TPartialCheck.ShowMaxEditChange(Sender: TObject);
begin
  DispMax := ShowMaxEdit.Value;
end;

procedure TPartialCheck.Update(aQSO : TQSO);
begin
  //MainForm.PartialClick(Self);
  {if MainForm.ActiveControl = MainForm.NumberEdit then
    CheckPartialNumber(Main.CurrentQSO)
  else
    CheckPartial(Main.CurrentQSO);}
  if _CheckCall then
    CheckPartial(aQSO)
  else
    CheckPartialNumber(aQSO);
end;

procedure TPartialCheck.rbSortClick(Sender: TObject);
begin
  Update(Main.CurrentQSO);
end;

procedure TPartialCheck.ListBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var OffSet : integer;
    S : string;
begin
with (Control as TListBox).Canvas do
  begin
    FillRect(Rect);								{ clear the rectangle }
    Offset := 2;								{ provide default offset }
    S := (Control as TListBox).Items[Index];
    if S[1] = '*' then
      begin
        Delete(S, 1, 1);
        Font.Color := clPurple;
        //Font.Style := [fsBold];
      end
    else
      Font.Color := clWindowText;
      //Font.Style := [];
      {if Index = ListBox.ItemIndex then
        Font.Color := clHighlightText
      else
        Font.Color := clWindowText;}
    TextOut(Rect.Left + Offset, Rect.Top, S)								{ display the text }
  end;
end;

procedure TPartialCheck.ListBoxDblClick(Sender: TObject);
var i : integer;
    str : string;
begin
  i := ListBox.ItemIndex;
  str := copy(ListBox.Items[i], 7, 12);
  str := TrimRight(str);
  MainForm.CallsignEdit.Text := str;
end;


procedure TPartialCheck.StayOnTopClick(Sender: TObject);
begin
  If StayOnTop.Checked then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

end.
