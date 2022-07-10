unit UEditDialog;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, zLogGlobal, Menus, UzLogCW, UzLogVoice, BGK32LIB;


const _ActInsert = 0;
      _ActChange = 1;

type
  TEditDialog = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Panel1: TPanel;
    TimeEdit: TEdit;
    CallsignEdit: TEdit;
    RcvdRSTEdit: TEdit;
    NumberEdit: TEdit;
    BandEdit: TEdit;
    ModeEdit: TEdit;
    MemoEdit: TEdit;
    PointEdit: TEdit;
    PowerEdit: TEdit;
    BandMenu: TPopupMenu;
    OpEdit: TEdit;
    ModeMenu: TPopupMenu;
    OpMenu: TPopupMenu;
    SerialEdit: TEdit;
    SerialLabel: TLabel;
    TimeLabel: TLabel;
    rcvdRSTLabel: TLabel;
    CallsignLabel: TLabel;
    PointLabel: TLabel;
    BandLabel: TLabel;
    NumberLabel: TLabel;
    ModeLabel: TLabel;
    PowerLabel: TLabel;
    OpLabel: TLabel;
    MemoLabel: TLabel;
    DateEdit: TEdit;
    NewPowerMenu: TPopupMenu;
    NewPowerEdit: TEdit;
    MainMenu1: TMainMenu;
    edit1: TMenuItem;
    op1: TMenuItem;
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CallsignEditChange(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure NumberEditChange(Sender: TObject);
    procedure NumberEditKeyPress(Sender: TObject; var Key: Char);
    procedure BandEditClick(Sender: TObject);
    procedure OpMenuClick(Sender: TObject);
    procedure BandMenuClick(Sender: TObject);
    procedure ModeMenuClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RcvdRSTEditChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MemoEditChange(Sender: TObject);
    procedure TimeEditChange(Sender: TObject);
    procedure DateEditChange(Sender: TObject);
    procedure DateEditDblClick(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure NewPowerMenuClick(Sender: TObject);
    procedure NewPowerEditClick(Sender: TObject);
    procedure ModeEditClick(Sender: TObject);
    procedure PowerEditChange(Sender: TObject);
    procedure op1Click(Sender: TObject);
    procedure OpEditClick(Sender: TObject);
  private
    { Private declarations }
  public
    index :  integer;
    workQSO : TQSO;
    origQSO : TQSO;
    Action : integer;
    procedure Init(aQSO : TQSO; index_ : integer; Action_ : integer); virtual;
    procedure ChangePower; virtual;
    { Public declarations }
  end;

var
  EditDialog: TEditDialog;

implementation

uses Main, UOptions, UZLinkForm, UPartials, URigControl;
{$R *.DFM}

procedure TEditDialog.ChangePower;
begin
  if workQSO.QSO.Power = pwrH then
    workQSO.QSO.Power := pwrP
  else
    inc(workQSO.QSO.Power);
  NewPowerEdit.Text := workQSO.NewPowerStr;
end;

procedure TEditDialog.Init(aQSO : TQSO; index_ :integer; Action_ : integer);
begin
  Action := Action_;
  ZLinkForm.LockQSO(aQSO); // lock it anyway
  {if Action = _ActChange then
    begin
      ZLinkForm.LockQSO(aQSO);
    end;}
  case Action of
    _ActChange : EditDialog.Caption := 'Edit QSO';
    _ActInsert : EditDialog.Caption := 'Insert QSO';
  end;
  index := index_;

  workQSO := TQSO.Create;
  origQSO := TQSO.Create;
  workQSO.QSO := aQSO.QSO;
  origQSO.QSO := aQSO.QSO;

  if Action = _ActInsert then
    begin
      workQSO.QSO.Callsign := '';
      workQSO.QSO.NRRcvd := '';
      workQSO.QSO.memo := '';
    end;

  TimeEdit.Visible := True;
  DateEdit.Visible := False;
  TimeLabel.Caption := 'time';

  SerialEdit.Text := workQSO.SerialStr;
  TimeEdit.Text := workQSO.TimeStr;
  DateEdit.Text := workQSO.DateStr;
  CallsignEdit.Text := workQSO.QSO.callsign;
  RcvdRSTEdit.Text := workQSO.RSTStr;
  NumberEdit.Text := workQSO.QSO.NrRcvd;
  ModeEdit.Text := workQSO.ModeStr;
  BandEdit.Text := workQSO.BandStr;
  PowerEdit.Text := workQSO.PowerStr;
  NewPowerEdit.Text := workQSO.NewPowerStr;
  PointEdit.Text := workQSO.PointStr;
  MemoEdit.Text := workQSO.QSO.memo;
  OpEdit.Text := workQSO.QSO.Operator;
end;

procedure TEditDialog.CancelBtnClick(Sender: TObject);
begin
  workQSO.Free;
  MainForm.LastFocus.SetFocus;
  ZLinkForm.UnlockQSO(origQSO);
  origQSO.Free;
  ModalResult := mrCancel;
  Close;
end;

procedure TEditDialog.OKBtnClick(Sender: TObject);
var i, j : integer;
    aQSO : TQSO;
begin

//  Main.StartDebugTimer;

  MyContest.SetNrSent(workQSO);

  try
    i := StrToInt(SerialEdit.Text);
  except
    on EConvertError do
      i := 0;
  end;
  if i > 0 then
    workQSO.QSO.Serial := i;

  if Action = _ActChange then
    begin
      IncEditCounter(workQSO);
      //ZLinkForm.EditQSO(origQSO, workQSO); {ZLinkForm takes care of Z-Link availability}
      ZLinkForm.EditQSObyID(workQSO);
      //ZLinkForm.EditQSO(TQSO(Log.List[index]), workQSO); {ZLinkForm takes care of Z-Link availability}
      //TQSO(Log.List[index]).QSO := workQSO.QSO;
      origQSO.QSO.Reserve := actEdit;
      workQSO.QSO.Reserve := actEdit;
      //Log.AddQue(origQSO);
      Log.AddQue(workQSO);
      Log.ProcessQue;
      {
      for i := 1 to Log.TotalQSO do
        begin
          if SameQSO(TQSO(Log.List[i]), origQSO) then
            TQSO(Log.List[i]).QSO := workQSO.QSO;
          break;
        end; }
      workQSO.Free;
      ZLinkForm.UnlockQSO(origQSO);
      //Main.EndDebugTimer;
    end;
  if Action = _ActInsert then
    begin
      //ZLinkForm.InsertQSO(origQSO, workQSO);
      origQSO.QSO.Reserve := actInsert;
      workQSO.QSO.Reserve := actInsert;
      repeat
        j := MainForm.NewQSOID;
      until Log.CheckQSOID(j) = False;

      workQSO.QSO.Reserve2 := origQSO.QSO.Reserve3;
      workQSO.QSO.Reserve3 := j;

      ZLinkForm.InsertQSO(workQSO);
      //Log.AddQue(origQSO);
      Log.AddQue(workQSO);
      Log.ProcessQue;
      workQSO.Free;
      ZLinkForm.UnlockQSO(origQSO);


      {aQSO := TQSO.Create;
      aQSO.QSO := workQSO.QSO;
      Log.Insert(index, aQSO);
      ZLinkForm.InsertQSO(workQSO, index);
      workQSO.Free;}
    end;
  origQSO.Free;
//  Main.StartDebugTimer;
  MyContest.Renew;
//  Main.EndDebugTimer;
  //MainForm.EditScreen.RefreshScreen;
  MainForm.Grid.SetFocus;
  ModalResult := mrOK;
  close;
  //close;
  //MainForm.LastFocus.SetFocus;

  {if Log.IsDupe2(workQSO, index, dupeindex) then
    begin
      x := More(index, dupeindex);
      y := Less(index, dupeindex);
      TQSO(Log.List[x]).QSO.Points := 0;
      TQSO(Log.List[x]).QSO.memo := '-DUPE- '+TQSO(Log.List[x]).QSO.memo;
    end }
end;

procedure TEditDialog.CallsignEditChange(Sender: TObject);
begin
  workQSO.QSO.Callsign := CallsignEdit.Text;
end;

procedure TEditDialog.EditKeyPress(Sender: TObject; var Key: Char);
var dupeindex : integer;
    j : integer;
begin
  MainForm.CommonEditKeyProcess(Sender, Key);
  case Key of
    '\' :
      begin
        ControlPTT(not(PTTIsOn)); // toggle PTT;
        Key := #0;
      end;
    'X','x' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            RigControl.ToggleCurrentRig;
            Key := #0;
          end;
      end;
    'V','v' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            if RigControl.Rig <> nil then
              RigControl.Rig.ToggleVFO;
            Key := #0;
          end;
      end;
    ^O :
      begin
        workQSO.DecTime;
        //TimeEdit.Text := CurrentQSO.TimeStr;
        //DateEdit.Text := CurrentQSO.DateStr;
        TimeEdit.Text := workQSO.TimeStr;
        DateEdit.Text := workQSO.DateStr;
        Key := #0;
      end;
    ^P :
      begin
        workQSO.IncTime;
        TimeEdit.Text := workQSO.TimeStr;
        DateEdit.Text := workQSO.DateStr;
        Key := #0;
      end;
    ^W :
      begin
        TEdit(Sender).Clear;
        Key := #0;
      end;
    ^R :
      begin
        Options.ReversePaddle;
        Key := #0;
      end;
    ^K :
      begin
        CallsignEdit.Clear;
        NumberEdit.Clear;
        MemoEdit.Clear;
        CallsignEdit.SetFocus;
        Key := #0;
      end;
    'Z' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            if Main.CurrentQSO.QSO.mode = mCW then
              begin
                MainForm.CQRepeatClick1(Sender);
              end
            else
              begin
              end;
            Key := #0;
          end;
      end;
    ^Z :
       begin
         if Main.CurrentQSO.QSO.mode = mCW then
           MainForm.CQRepeatClick2(Sender);
         Key := #0;
       end;
   (*Chr($1B) :  {ESC}
      begin
        MainForm.CWStopButtonClick(Self);
        MainForm.VoiceStopButtonClick(Self);
        Key := #0;
      end;*)
    ' ' :
      begin
        if TEdit(Sender).Name = 'MemoEdit' then
          begin
            if Options.Settings._movetomemo then
              begin
                Key := #0;
                CallsignEdit.SetFocus;
              end;
            exit;
          end;
        if (TEdit(Sender).Name = 'NumberEdit') or (TEdit(Sender).Name = 'TimeEdit') then
          begin
            Key := #0;
            if Options.Settings._movetomemo then
              MemoEdit.SetFocus
            else
              CallsignEdit.SetFocus;
          end
        else {if space is pressed when Callsign edit is in focus}
          begin
            if NumberEdit.Text = '' then
              begin
              end;
            Key := Chr(0);
            if Log.IsDupe2(workQSO, index, dupeindex) then
              begin
                CallsignEdit.SelectAll;
                exit;
              end;
            NumberEdit.SetFocus;
          end;
       end;
    'Y','y' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            IncCWSpeed;
            Key := #0;
          end;
      end;
    'T','t' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            workQSO.UpdateTime;
            TimeEdit.Text := workQSO.TimeStr;
            DateEdit.Text := workQSO.DateStr;
            Key := #0;
          end;
      end;
    'U','u' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            DecCWSpeed;
            Key := #0;
          end;
      end;
    'B','b' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            // ChangeBand(True);
            //MainForm.SetQSOBand(workQSO, True);
            workQSO.QSO.Band := MainForm.GetNextBand(workQSO.QSO.Band, True);
            BandEdit.Text := MHzString[workQSO.QSO.Band];
            Key := #0;
          end;
      end;
    'R','r' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            MainForm.SetR(workQSO);
            RcvdRSTEdit.Text := workQSO.RSTStr;
            Key := #0;
          end;
      end;
    'S','s' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            MainForm.SetS(workQSO);
            RcvdRSTEdit.Text := workQSO.RSTStr;
            Key := #0;
          end;
      end;
    'M','m' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            // ChangeMode;
            MainForm.SetQSOMode(workQSO);
            ModeEdit.Text := ModeString[workQSO.QSO.Mode];
            if workQSO.QSO.Mode in [mSSB, mFM, mAM] then
              begin
                workQSO.QSO.RSTrcvd := 59;
                workQSO.QSO.RSTsent := 59;
                RcvdRSTEdit.Text := '59';
              end
            else
              begin
                workQSO.QSO.RSTrcvd := 599;
                workQSO.QSO.RSTsent := 599;
                RcvdRSTEdit.Text := '599';
              end;
            Key := #0;
          end;
      end;
   'P','p' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            ChangePower;
            Key := #0;
          end;
      end;
    Chr($0D) :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
          end;
        OKBtnClick(Self);
        Key := #0;
      end;
    end;
 { of case }
end;





procedure TEditDialog.NumberEditChange(Sender: TObject);
begin
  workQSO.QSO.NrRcvd := NumberEdit.Text;
end;

procedure TEditDialog.NumberEditKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    ' ' : begin
      Key := Chr(0);
      CallsignEdit.SetFocus;
    end;
    Chr($0D) : begin
      OKBtnClick(Self);
      Key := #0;
    end;
  end; { of case }
end;

procedure TEditDialog.BandEditClick(Sender: TObject);
begin
  BandMenu.Popup(Self.Left+Panel1.Left+BandEdit.Left + 10, Self.Top+Panel1.Top+BandEdit.Top + 40);
end;

procedure TEditDialog.OpMenuClick(Sender: TObject);
var O : string;
begin
  O := TMenuItem(Sender).Caption;
  if O = 'Clear' then O := '';
  OpEdit.Text := O;
  workQSO.QSO.Operator := O;
end;

procedure TEditDialog.BandMenuClick(Sender: TObject);
var T : byte;
    B : TBand;
begin
  T := TMenuItem(Sender).Tag;
  B := TBand(T);
  BandEdit.Text := MHzString[B];
  workQSO.QSO.band := B;
end;

procedure TEditDialog.ModeMenuClick(Sender: TObject);
var T : byte;
    M : TMode;
begin
  ModeEdit.Text := ModeString[TMode(TMenuItem(Sender).Tag)];
  workQSO.QSO.mode := TMode(TMenuItem(Sender).Tag);
  If TMenuItem(Sender).Tag in [1..3] then
    begin
      workQSO.QSO.RSTrcvd := 59;
      workQSO.QSO.RSTsent := 59;
      RcvdRSTEdit.Text := '59';
    end
  else
    begin
      workQSO.QSO.RSTrcvd := 599;
      workQSO.QSO.RSTsent := 599;
      RcvdRSTEdit.Text := '599';
    end;
end;

procedure TEditDialog.FormShow(Sender: TObject);
var i : integer;
    M : TMenuItem;
const offset = 3;
begin
  CallsignEdit.SetFocus;
  for i := 0 to MainForm.BandMenu.Items.Count-1 do
    begin
      BandMenu.Items[i].Enabled := MainForm.BandMenu.Items[i].Enabled;
      BandMenu.Items[i].Visible := MainForm.BandMenu.Items[i].Visible;
    end;
  for i := 0 to MainForm.ModeMenu.Items.Count-1 do
    begin
      ModeMenu.Items[i].Enabled := MainForm.ModeMenu.Items[i].Enabled;
      ModeMenu.Items[i].Visible := MainForm.ModeMenu.Items[i].Visible;
    end;
  for i := 0 to MainForm.NewPowerMenu.Items.Count-1 do
    begin
      NewPowerMenu.Items[i].Enabled := MainForm.ModeMenu.Items[i].Enabled;
      NewPowerMenu.Items[i].Visible := MainForm.ModeMenu.Items[i].Visible;
    end;

  OpEdit.Visible := (Options.MultiOp > 0);
  OpLabel.Visible := OpEdit.Visible;

  if MainForm.OpMenu.Items.Count > 0 then    // update op menu 1.31
    begin
      if OpMenu.Items.Count > 0 then
        for i := 0 to OpMenu.Items.Count-1 do
          OpMenu.Items.Delete(0);
      for i := 0 to MainForm.OpMenu.Items.Count-1 do
        begin
          M := TMenuItem.Create(Self);
          M.Caption := MainForm.OpMenu.Items[i].Caption;
          M.OnClick := OpMenuClick;
          M.Enabled := MainForm.OpMenu.Items[i].Enabled;
          M.Visible := MainForm.OpMenu.Items[i].Visible;
          M.Tag := MainForm.OpMenu.Items[i].Tag;
          OpMenu.Items.Add(M);
        end;
    end;

  SerialEdit.Visible := MainForm.SerialEdit.Visible;
  SerialEdit.Left := MainForm.SerialEdit.Left + offset;
  SerialEdit.Width := MainForm.SerialEdit.Width;
  SerialLabel.Visible := SerialEdit.Visible;
  SerialLabel.Left := SerialEdit.Left+1;

  TimeEdit.Left := MainForm.TimeEdit.Left + offset;
  TimeEdit.Width := MainForm.TimeEdit.Width;
  TimeLabel.Left := TimeEdit.Left+1;

  DateEdit.Left := TimeEdit.Left;
  DateEdit.Width := TimeEdit.Width;

  CallsignEdit.Left := MainForm.CallsignEdit.Left + offset;
  CallsignEdit.Width := MainForm.CallsignEdit.Width;
  CallsignLabel.Left := CallsignEdit.Left+1;

  rcvdRSTEdit.Left := MainForm.rcvdRSTEdit.Left + offset;
  rcvdRSTEdit.Width := MainForm.rcvdRSTEdit.Width;
  rcvdRSTLabel.Left := rcvdRSTEdit.Left+1;

  NumberEdit.Left := MainForm.NumberEdit.Left + offset;
  NumberEdit.Width := MainForm.NumberEdit.Width;
  NumberLabel.Left := NumberEdit.Left+1;

  BandEdit.Left :=  MainForm.BandEdit.Left + offset;
  BandEdit.Width := MainForm.BandEdit.Width;
  BandLabel.Left := BandEdit.Left+1;

  ModeEdit.Left := MainForm.ModeEdit.Left + offset;
  ModeEdit.Width := MainForm.ModeEdit.Width;
  ModeEdit.Visible := MainForm.ModeEdit.Visible;
  ModeLabel.Visible := ModeEdit.Visible;
  ModeLabel.Left := ModeEdit.Left+1;

  PowerEdit.Left := MainForm.PowerEdit.Left + offset;
  PowerEdit.Width := MainForm.PowerEdit.Width;
  PowerEdit.Visible := MainForm.PowerEdit.Visible;
  PowerLabel.Visible := PowerEdit.Visible;
  PowerLabel.Left := PowerEdit.Left+1;

  NewPowerEdit.Left := MainForm.NewPowerEdit.Left + offset;
  NewPowerEdit.Width := MainForm.NewPowerEdit.Width;
  NewPowerEdit.Visible := MainForm.NewPowerEdit.Visible;
  PowerLabel.Visible := NewPowerEdit.Visible;
  PowerLabel.Left := NewPowerEdit.Left+1;

  PointEdit.Left := MainForm.PointEdit.Left + offset;
  PointEdit.Width := MainForm.PointEdit.Width;
  PointLabel.Left := PointEdit.Left+1;

  OpEdit.Left := MainForm.OpEdit.Left + offset;
  OpEdit.Width := MainForm.OpEdit.Width;
  OpLabel.Left := OpEdit.Left+1;

  MemoEdit.Left := MainForm.MemoEdit.Left + offset;
  MemoEdit.Width := MainForm.MemoEdit.Width;
  MemoLabel.Left := MemoEdit.Left+1;

  Width := MainForm.Width;
end;

procedure TEditDialog.RcvdRSTEditChange(Sender: TObject);
var i : word;
begin
  try
    I := StrToInt(RcvdRSTEdit.Text);
  except
    on EConvertError do
      begin
        if workQSO.QSO.mode in [mCW, mRTTY] then
          I := 599
        else
          I := 59;
      end;
   end;
   workQSO.QSO.RSTRcvd := I;
end;

procedure TEditDialog.FormCreate(Sender: TObject);
var i : integer;
    M : TMenuItem;
begin
  if MainForm.OpMenu.Items.Count > 0 then
    for i := 0 to MainForm.OpMenu.Items.Count-1 do
      begin
        M := TMenuItem.Create(Self);
        M.Caption := MainForm.OpMenu.Items[i].Caption;
        M.OnClick := OpMenuClick;
        M.Enabled := MainForm.OpMenu.Items[i].Enabled;
        M.Visible := MainForm.OpMenu.Items[i].Visible;
        M.Tag := MainForm.OpMenu.Items[i].Tag;
        OpMenu.Items.Add(M);
      end;

  for i := 0 to MainForm.BandMenu.Items.Count-1 do
    begin
      M := TMenuItem.Create(Self);
      M.Caption := MainForm.BandMenu.Items[i].Caption;
      M.OnClick := BandMenuClick;
      M.Enabled := MainForm.BandMenu.Items[i].Enabled;
      M.Visible := MainForm.BandMenu.Items[i].Visible;
      M.Tag := MainForm.BandMenu.Items[i].Tag;
      BandMenu.Items.Add(M);
    end;
  for i := 0 to MainForm.ModeMenu.Items.Count-1 do
    begin
      M := TMenuItem.Create(Self);
      M.Caption := MainForm.ModeMenu.Items[i].Caption;
      M.OnClick := ModeMenuClick;
      M.Enabled := MainForm.ModeMenu.Items[i].Enabled;
      M.Visible := MainForm.ModeMenu.Items[i].Visible;
      M.Tag := MainForm.ModeMenu.Items[i].Tag;
      ModeMenu.Items.Add(M);
    end;
  for i := 0 to MainForm.NewPowerMenu.Items.Count-1 do
    begin
      M := TMenuItem.Create(Self);
      M.Caption := MainForm.NewPowerMenu.Items[i].Caption;
      M.OnClick := NewPowerMenuClick;
      M.Enabled := MainForm.NewPowerMenu.Items[i].Enabled;
      M.Visible := MainForm.NewPowerMenu.Items[i].Visible;
      M.Tag := MainForm.NewPowerMenu.Items[i].Tag;
      NewPowerMenu.Items.Add(M);
    end;


end;

procedure TEditDialog.MemoEditChange(Sender: TObject);
begin
  workQSO.QSO.memo := MemoEdit.Text;
end;

procedure TEditDialog.TimeEditChange(Sender: TObject);
var T : TDateTime;
begin
  try
    T := StrToTime(TimeEdit.Text);
  except
    on EConvertError do
      begin
        T := workQSO.QSO.Time;
        exit;
      end;
  end;
  if workQSO.TimeStr = FormatDateTime('hh:nn',T) then
    exit;
  workQSO.QSO.Time := Trunc(workQSO.QSO.Time)+Frac(T); //(T-Trunc(T));
end;

procedure TEditDialog.DateEditChange(Sender: TObject);
var T : TDateTime;
begin
  ShortDateFormat := 'y/m/d';
  try
    T := StrToDate(DateEdit.Text);
  except
    on EConvertError do
      begin
        T := workQSO.QSO.Time;
        exit;
      end;
  end;
  if workQSO.DateStr = FormatDateTime('yy/mm/dd',T) then
    exit;
  workQSO.QSO.Time := Int(T) + Frac(workQSO.QSO.Time);
end;


procedure TEditDialog.DateEditDblClick(Sender: TObject);
begin
  if TEdit(Sender).Name = 'TimeEdit' then
    begin
      TimeEdit.Visible := False;
      DateEdit.Visible := True;
      TimeLabel.Caption := 'date';
    end
  else
    begin
      TimeEdit.Visible := True;
      DateEdit.Visible := False;
      TimeLabel.Caption := 'time';
    end;
end;

procedure TEditDialog.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var i, cb : integer;
    S : string[255];
begin
  case Key of
    29 : {MUHENKAN KEY}
      begin
        ControlPTT(not(PTTIsOn)); // toggle PTT;
      end;
    VK_F1..VK_F8, VK_F11, VK_F12 :
      begin
        i := Key - VK_F1 + 1;
        if workQSO.QSO.Mode = mCW then
          begin

            cb := Options.Settings.CW.CurrentBank;

            if GetAsyncKeyState(VK_SHIFT) < 0 then
              begin
                if cb = 1 then
                  cb := 2
                else
                  cb := 1;
              end;


            S := Options.CWMessage(cb,i);
            S := SetStr(S, CurrentQSO);
            zLogSendStr(S);
          end
        else
          begin
            SendVoice(i);
          end;
      end;
    VK_F10 :
      begin
        //MessageBeep(0);
        PartialCheck.Show;
        //Label1.Caption := TEdit(Sender).Name;
        if TEdit(Sender).Name = 'NumberEdit' then
          begin
            PartialCheck.CheckPartialNumber(workQSO);
          end
        else
          PartialCheck.CheckPartial(workQSO);
        TEdit(Sender).SetFocus;
        Key := 0;
      end;
   Ord('O') :
      begin
        if Shift = [ssAlt] then
          OpEditClick(Self);
        //Key := 0;
      end;
   Ord('M') :
      begin
        if Shift = [ssAlt] then
          begin
            MemoEdit.SetFocus;
            Key := 0;
          end;
      end;
   Ord('N') :
      begin
        if Shift = [ssAlt] then
          NumberEdit.SetFocus;
      end;
   Ord('R') :
      begin
        if Shift = [ssAlt] then
          RcvdRSTEdit.SetFocus;
      end;
   Ord('C') :
      begin
        if Shift = [ssAlt] then
          CallsignEdit.SetFocus;
      end;
   VK_ESCAPE :
     begin
       Key := 0;
       CancelBtnClick(Self);
     end;
  end;
end;




procedure TEditDialog.NewPowerMenuClick(Sender: TObject);
var T : byte;
    M : TMode;
begin
  NewPowerEdit.Text := NewPowerString[TPower(TMenuItem(Sender).Tag)];
  workQSO.QSO.power := TPower(TMenuItem(Sender).Tag);
end;

procedure TEditDialog.NewPowerEditClick(Sender: TObject);
begin
  NewPowerMenu.Popup(Self.Left+Panel1.Left+NewPowerEdit.Left + 10, Self.Top+Panel1.Top+NewPowerEdit.Top + 40);
end;

procedure TEditDialog.ModeEditClick(Sender: TObject);
begin
  ModeMenu.Popup(Self.Left+Panel1.Left+ModeEdit.Left + 10, Self.Top+Panel1.Top+ModeEdit.Top + 40);
end;

procedure TEditDialog.PowerEditChange(Sender: TObject);
var i : integer;
begin
  i := 0;
  if (PowerEdit.Text = 'KW') then
    i := 9999;
  if (PowerEdit.Text = '1KW') then
    i := 10000;
  if (PowerEdit.Text = 'K') then
    i := 10001;

  if i > 0 then
    begin
      workQSO.QSO.Power2 := i;
      exit;
    end;

  try
    i := StrToInt(PowerEdit.Text);
  except
    i := 0;
  end;
  workQSO.QSO.Power2 := i;
end;

procedure TEditDialog.op1Click(Sender: TObject);
begin
  OpEditClick(Self);
end;

procedure TEditDialog.OpEditClick(Sender: TObject);
begin
  OpMenu.Popup(Left + OpEdit.Left + 20, Top + OpEdit.Top);
end;

end.
