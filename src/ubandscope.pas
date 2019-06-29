unit ubandscope;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, zLogGlobal, USpotClass;


//var

type

  TBandScope = class(TForm)
    BSMenu: TPopupMenu;
    mnSetMinMax: TMenuItem;
    mnDelete: TMenuItem;
    cbStayOnTop: TCheckBox;
    Refresh1: TMenuItem;
    Mode1: TMenuItem;
    mnCurrentRig: TMenuItem;
    Rig11: TMenuItem;
    Rig21: TMenuItem;
    Fixedband1: TMenuItem;
    N19MHz1: TMenuItem;
    N35MHz1: TMenuItem;
    N7MHz1: TMenuItem;
    N14MHz1: TMenuItem;
    N21MHz1: TMenuItem;
    N28MHz1: TMenuItem;
    N50MHz1: TMenuItem;
    Deleteallworkedstations1: TMenuItem;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure mnSetMinMaxClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mnDeleteClick(Sender: TObject);
    procedure BSMenuPopup(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure cbStayOnTopClick(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mnDispModeClick(Sender: TObject);
    procedure mnFixedBandClicked(Sender: TObject);
    procedure Deleteallworkedstations1Click(Sender: TObject);
  private
    { Private declarations }
    BarWidth, BarHeight : LongInt;
    BarTopLeft, BarBottomRight : TPoint;
    MinFreq, MaxFreq : Integer; // in Hz

    curr : integer; // test variable
    ClickedIndex : integer; // points to the bsdata clicked by mouse

    currFreq : Integer;
    currBand : TBand;
    currMode : TMode;

    procedure AddBSList(D : TBSData);
  public
    { Public declarations }
    // BSList : TList;   moved to UBandScope

//  MinFreqArray : array[b19..HiBand, mCW..mOther] of Integer; // kHz
//  MaxFreqArray : array[b19..HiBand, mCW..mOther] of Integer; // kHz

//    procedure CheckWorked;
    ArrayNumber : integer;
    DisplayMode : integer; // 0 : current rig; 1 : rig 1; 2 : rig 2; 9 : fixed band
    FixedBand : TBand;
    procedure DrawBar;
    procedure DrawLabel;
    procedure DrawBSList;
    procedure SetMinMaxFreq(min, max : LongInt);
    procedure MarkCurrentFreq(Hz : integer);
    procedure SetSizes;
    procedure SetBandMode(B : TBand; M : TMode);
//    procedure InitFreqArrays;
    procedure AddAndDisplay(D : TBSData);
    //procedure Refresh;
    procedure DeleteFromBSList(i : integer);
    procedure CreateBSData(aQSO : TQSO; Hz : Integer);
    procedure ProcessBSDataFromNetwork(BSText : string);
    //procedure InsertQSO(Q : TQSO; FreqHz : integer);
    procedure AddNewQSO(aQSO : TQSO);
  end;

procedure BSRefresh(Sender : TObject);

const BSMax = 15;
var
  BandScope: TBandScope;
  BandScopeArray : array[1..BSMax] of TBandscope;

implementation

uses UMinMaxFreqDlg, Main, UOptions, URigControl, UZLinkForm;

{$R *.DFM}

procedure BSRefresh(Sender : TObject);
var i : integer;
    DispMode : integer;
    RR : TRig;
begin
  BandScope.FormPaint(Sender);
  for i := 1 to BSMax do
    if BandScopeArray[i] <> nil then
      begin
        DispMode := BandScopeArray[i].DisplayMode;
        RR := nil;
        case DispMode of
          1 : RR := RigControl.Rig1;
          2 : RR := RigControl.Rig2;
        end;
        if RR <> nil then
          BandScopeArray[i].SetBandMode(RR._currentband, RR._currentmode)
        else
          BandScopeArray[i].FormPaint(Sender);
      end;
end;

procedure TBandScope.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

function PointInRect(P : TPoint; R : TRect) : boolean;
begin
  if (P.x >= R.Left) and (P.x <= R.Right) and
     (P.y >= R.Top)  and (P.y <= R.Bottom) then
     Result := True
  else
    Result := False;
end;

{
procedure TBandScope.InitFreqArrays;
var B : TBand;
    M : TMode;
begin
  for B := b19 to HiBand do
    for M := mCW to mOther do
      begin
        MinFreqArray[B, M] := 0;
        MaxFreqArray[B, M] := 0;
      end;
  MinFreqArray[b19, mCW] := 1800;
  MaxFreqArray[b19, mCW] := 1950;

  MinFreqArray[b35, mCW] := 3500;
  MaxFreqArray[b35, mCW] := 3800;

  MinFreqArray[b7, mCW] := 7000;
  MaxFreqArray[b7, mCW] := 7200;

  MinFreqArray[b10, mCW] := 10100;
  MaxFreqArray[b10, mCW] := 10150;

  MinFreqArray[b14, mCW] := 14000;
  MaxFreqArray[b14, mCW] := 14350;

  MinFreqArray[b18, mCW] := 18060;
  MaxFreqArray[b18, mCW] := 18170;

  MinFreqArray[b21, mCW] := 21000;
  MaxFreqArray[b21, mCW] := 21450;

  MinFreqArray[b24, mCW] := 24890;
  MaxFreqArray[b24, mCW] := 24990;

  MinFreqArray[b28, mCW] := 28000;
  MaxFreqArray[b28, mCW] := 28500;

  MinFreqArray[b50, mCW] := 50000;
  MaxFreqArray[b50, mCW] := 51000;

  MinFreqArray[b144, mCW] := 144000;
  MaxFreqArray[b144, mCW] := 145650;

  MinFreqArray[b430, mCW] := 430000;
  MaxFreqArray[b430, mCW] := 434000;

  for B := b19 to HiBand do
    for m := mSSB to mOther do
      begin
        MinFreqArray[B, m] := MinFreqArray[B, mCW];
        MaxFreqArray[B, m] := MaxFreqArray[B, mCW];
      end;
end;
}

procedure TBandScope.AddBSList(D : TBSData);
var i : integer;
begin
  if BSList.Count = 0 then
    begin
      BSList.Add(D);
      exit;
    end;
  for i := 0 to BSList.Count - 1 do
    if TBSData(BSList[i]).FreqHz < D.FreqHz then
      break;
  if i = BSList.Count - 1 then
    begin
      if TBSData(BSList[i]).FreqHz > D.FreqHz then
        BSList.Add(D)
      else
        BSList.Insert(i, D);
      exit;
    end;
  BSList.Insert(i, D);
end;

procedure TBandScope.DrawBar;
var R : TRect;
begin
  with Canvas do
    begin
      Brush.Style := bsSolid;
      Brush.Color := clBlue;
      R.TopLeft := BarTopLeft;
      R.BottomRight := BarBottomRight;
      FillRect(R);
    end;
end;

procedure TBandScope.DrawLabel;
var str : string;
    wid : integer;
begin
  with Canvas do
    begin
      Brush.Color := Color;
      str := kHzStr(MinFreq);
      wid := TextWidth(str);
      Canvas.Font.Color := clBlack;
      TextOut(BarTopLeft.x - wid div 2, BarBottomRight.y + 3, str);
      str := kHzStr(MaxFreq);
      wid := TextWidth(str);
      TextOut(BarBottomRight.x - wid div 2, BarBottomRight.y + 3, str);
    end;
end;

procedure TBandScope.DrawBSList;
var D, DD : TBSData;
    i, maxx : integer;
    r : double;
    str : string;
begin
  with Canvas do
    begin
      Pen.Width := 2;
      Brush.Color := Color;
      for i := 0 to BSList.Count - 1 do
        begin
          D := TBSData(BSList[i]);
          if (D.FreqHz >= MinFreq) and (D.FreqHz <= MaxFreq) then
            begin
              r := (D.FreqHz - MinFreq) / (MaxFreq - MinFreq);
              str := D.LabelStr;
              D.LabelRect.Left := BarTopLeft.x + Trunc(BarWidth*r);

              D.LabelRect.Top := BarTopLeft.y - TextHeight(str)-2;

              if i > 0 then
                begin
                  maxx := D.LabelRect.Left + TextWidth(str);
                  DD := TBSData(BSList[i-1]);
                  if (DD.Band = D.Band) and (maxx >= DD.LabelRect.Left) then
                    D.LabelRect.Top := DD.LabelRect.Top - TextHeight(str);
                end;

              D.LabelRect.Right := D.LabelRect.Left + TextWidth(str);
              D.LabelRect.Bottom := D.LabelRect.Top + TextHeight(str);

              if D.NewMulti then
                Canvas.Font.Color := clRed
              else
                if D.Worked then
                  Canvas.Font.Color := clBlack
                else
                  Canvas.Font.Color := clGreen;

              TextOut(D.LabelRect.Left, D.LabelRect.Top, str);

              Pen.Style := psSolid;
              Pen.Color := clBlack;
              MoveTo(D.LabelRect.Left, D.LabelRect.Bottom);
              LineTo(D.LabelRect.Left, BarBottomRight.y - 2);
            end
          else  // out of scope
            begin
              D.LabelRect.Left := 999999;
            end;
        end;
    end;
end;

procedure TBandScope.MarkCurrentFreq(Hz : integer);
var x : integer;
    r : double;
begin
  if (MaxFreq = 0) or (MinFreq = 0) or (Hz <= 0) or (MinFreq=MaxFreq) then
    exit;
  if (Hz < MinFreq) or (Hz > MaxFreq) then
    exit;
  //CurrFreq := Hz;
  r := (Hz - MinFreq) / (MaxFreq - MinFreq);
  x := BarTopLeft.x + Trunc(BarWidth*r);
  Canvas.Pen.Width := 3;
  Canvas.Pen.Color := clRed;
  Canvas.MoveTo(x, BarTopLeft.y + 1);
  Canvas.LineTo(x, BarBottomRight.y - 2);
end;

procedure TBandScope.SetMinMaxFreq(min, max : LongInt);
begin
  MinFreq := min;
  MaxFreq := max;
  Options.Settings._bsMinFreqArray[currBand, currMode] := min div 1000;
  Options.Settings._bsMaxFreqArray[currBand, currMode] := max div 1000;
end;

procedure TBandScope.FormPaint(Sender: TObject);
var R : TRect;
begin
  if not(Visible) then
    exit;
  R.Left := 0;
  R.Top := 0;
  R.Right := ClientWidth;
  R.Bottom := ClientHeight;
  Canvas.Brush.Color := Color;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(R);
  DrawBar;
  DrawLabel;

  //CheckWorked;
  DrawBSList;

  //MarkCurrentFreq(currFreq);
end;

procedure TBandScope.SetSizes;
begin
  BarHeight := 10;
  BarTopLeft.x := 25;
  BarTopLeft.y := ClientHeight - 32;
  BarBottomRight.x := ClientWidth - 25;
  BarWidth := BarBottomRight.x - BarTopLeft.x;
  BarBottomRight.y := BarTopLeft.y + BarHeight;
end;

procedure TBandScope.FormCreate(Sender: TObject);
var D : TBSData;
begin
  //TimeLimitMin := 60;
  //TimeLimit := TimeLimitMin/(60*24);
  //InitFreqArrays;
  // BSList := TList.Create;

  //SetMinMaxFreq(14000000, 14100000);

  FixedBand := b19;
  ArrayNumber := 0;
  DisplayMode := 0; // current rig
  SetSizes;
  //SetBandMode(b14, mCW);

  {
  D := TBSData.Create;
  D.Callsign := 'JJ1MED';
  D.Freq := 14035000;
  AddBSList(D);
  D := TBSData.Create;
  D.Callsign := 'P41Z';
  D.Freq := 14050000;
  AddBSList(D);
  D := TBSData.Create;
  D.Callsign := 'KF7AG';
  D.Freq := 14100000;
  AddBSList(D);
  curr := 14050; }
end;

procedure TBandScope.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_UP : begin
              inc(curr);
            end;
    VK_DOWN : begin
              dec(curr);
            end;
    VK_ESCAPE : MainForm.LastFocus.SetFocus;
  end;
  FormPaint(Self);
  //MarkCurrentFreq(curr*1000);
end;

procedure TBandScope.FormResize(Sender: TObject);
begin
  SetSizes;
  FormPaint(Self);
  //cbStayOnTop.Top := ClientHeight - 22;
end;

procedure TBandScope.mnSetMinMaxClick(Sender: TObject);
begin
  MinMaxFreqDlg.SetMinMax(MinFreq div 1000, MaxFreq div 1000);
  MinMaxFreqDlg.ShowModal;
  SetMinMaxFreq(MinMaxFreqDlg.MinFreq*1000, MinMaxFreqDlg.MaxFreq*1000);
  FormPaint(Self);
end;

procedure TBandScope.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i : integer;
begin
  ClickedIndex := -1;
  for i := 0 to BSList.Count - 1 do
    begin
      if PointInRect(Point(X,Y), TBSData(BSList[i]).LabelRect) = True then
        begin
          ClickedIndex := i;
          exit;
        end;
    end;
end;

procedure TBandScope.DeleteFromBSList(i : integer);
begin
  if (i >= 0) and (i < BSList.Count) then
    begin
      TBSData(BSList[i]).Free;
      BSList[i] := nil;
      BSList.Pack;
      //FormPaint(Self);
    end;
end;

procedure TBandScope.mnDeleteClick(Sender: TObject);
begin
  if ClickedIndex >= 0 then
    begin
      DeleteFromBSList(ClickedIndex);
      FormPaint(Self);
    end;
end;

procedure TBandScope.BSMenuPopup(Sender: TObject);
begin
  if ArrayNumber = 0 then
    mnCurrentRig.Enabled := True
  else
    mnCurrentRig.Enabled := False;

  if ClickedIndex >= 0 then
    mnDelete.Enabled := True
  else
    mnDelete.Enabled := False;
end;

procedure TBandScope.FormDblClick(Sender: TObject);
var i : integer;
    D : TBSData;
begin
  if ClickedIndex >= 0 then
    begin
      i := ClickedIndex;
      if (i >= 0) and (i < BSList.Count) then
        begin
          D := TBSData(BSList[i]);
          MainForm.CallsignEdit.Text := D.Call;
          if RigControl.Rig <> nil then
            RigControl.Rig.SetFreq(D.FreqHz);
          //FormPaint(Self);
          MainForm.NumberEdit.SetFocus;
        end;
    end;
end;

procedure TBandScope.SetBandMode(B : TBand; M : TMode);
var min, max : integer;
begin
  currBand := B;
  currMode := M;
  Caption := 'Band scope '+BandString[B];
  min := Options.Settings._bsMinFreqArray[B, M];
  max := Options.Settings._bsMaxFreqArray[B, M];
  if B >= b2400
   then
    begin
      exit;  // integer overflow.
    end;
  if (min > 0) and (max > 0) and (max > min) then
    begin
      SetMinMaxFreq(min*1000, max*1000);
      FormPaint(Self);
    end;
end;

procedure TBandScope.AddAndDisplay(D : TBSData);
var i : integer;
    BS : TBSData;
    Diff : TDateTime;
label endofloop;
begin
  for i := 0 to BSList.Count - 1 do
    begin
      BS := TBSData(BSList[i]);
      if BS.Call = D.Call then
        begin
          BS.Free;
          BSList[i] := nil;
          goto endofloop;
        end;
      if round(BS.FreqHz / 100) = round(D.FreqHz / 100) then
        begin
          BS.Free;
          BSList[i] := nil;
          goto endofloop;
        end;
      Diff := Now - BS.Time;
      if Diff*24*60 > 1.00*Options.Settings._bsexpire then
        begin
          BS.Free;
          BSList[i] := nil;
        end;
      endofloop:
    end;
  BSList.Pack;
  AddBSList(D);
  //FormPaint(Self);
  BSRefresh(Self);

end;

procedure TBandScope.CreateBSData(aQSO : TQSO; Hz : Integer);
var D : TBSData;
begin
  D := TBSData.Create;
  D.FreqHz := Hz;
  D.Band := aQSO.QSO.Band;
  D.Mode := aQSO.QSO.Mode;
  D.Call := aQSO.QSO.Callsign;
  //D.Time := Now;
  Main.MyContest.MultiForm.ProcessSpotData(TBaseSpot(D));
  AddAndDisplay(D);
  ZLinkForm.SendBandScopeData(D.InText);
  //Send spot data to other radios!
end;

procedure TBandScope.ProcessBSDataFromNetwork(BSText : string);
var D : TBSData;
begin
  D := TBSData.Create;
  D.FromText(BSText);
  Main.MyContest.MultiForm.ProcessSpotData(TBaseSpot(D));
  AddAndDisplay(D);
end;

{procedure TBandScope.CheckWorked;
var i : integer;
    Q : TQSO;
    D : TBSData;
begin
  Q := TQSO.Create;
  for i := 0 to BSList.Count - 1 do
    begin
      D := TBSData(BSList[i]);
      if (D.FreqHz >= MinFreq) and (D.FreqHz <= MaxFreq) then
        begin
          Q.QSO.CallSign := D.Call;
          Q.QSO.Band := D.Band;
          //Q.QSO.Mode := D.Mode;
          if Log.IsDupe(Q) > 0 then
            D.Worked := True
          else
            D.Worked := False;
        end;
    end;
  Q.Free;
end;}


procedure TBandScope.cbStayOnTopClick(Sender: TObject);
begin
  If cbStayOnTop.Checked then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

procedure TBandScope.Refresh1Click(Sender: TObject);
begin
  Main.MyContest.MultiForm.RenewBandScope;
end;

procedure TBandScope.AddNewQSO(aQSO : TQSO);
var i : integer;
    boo : boolean;
    D : TBSData;
begin
  boo := False;
  for i := 0 to BSList.Count - 1 do
    begin
      D := TBSData(BSList[i]);
      if D.Band = aQSO.QSO.Band then
        if CoreCall(D.Call) = CoreCall(aQSO.QSO.Callsign) then
          if Log.AcceptDifferentMode then
            begin
              if SameMode2(D.Mode, aQSO.QSO.Mode) then
                begin
                  D.Worked := True;
                  boo := True;
                end;
            end
          else
            begin
              D.Worked := True;
              boo := True;
            end;
    end;

  if (aQSO.QSO.NewMulti1) or (aQSO.QSO.NewMulti2) then
    begin
    end;

  if boo then
    Refresh;
end;


var i : integer;

procedure TBandScope.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ArrayNumber > 0 then
    begin
      BandScopeArray[ArrayNumber] := nil;
      Free;
    end;
end;

procedure TBandScope.mnDispModeClick(Sender: TObject);
begin
  DisplayMode := TMenuItem(Sender).Tag;
end;

procedure TBandScope.mnFixedBandClicked(Sender: TObject);
begin
  DisplayMode := 3;
  FixedBand := TBand(TMenuItem(Sender).Tag);
  SetBandMode(FixedBand, Main.CurrentQSO.QSO.Mode);
  BSRefresh(Self);
end;

procedure TBandScope.Deleteallworkedstations1Click(Sender: TObject);
var i : integer;
    B : TBSData;
begin
  for i := 0 to BSList.Count - 1 do
    begin
      B := TBSData(BSList[i]);
      if B.Worked then
        begin
          B.Free;
          BSList[i] := nil;
        end;
    end;
  BSList.Pack;
  Main.MyContest.MultiForm.RenewBandScope;
end;

initialization
  for i := 1 to BSMax do
    BandScopeArray[i] := nil;
end.
