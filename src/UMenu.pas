unit UMenu;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, BGK32Lib, UzLogCW, zLogGlobal, Dialogs,
  FngSingleInst, Buttons, UMMTTY, UzLogVoice;


const SaveInBackGround : boolean = False;

type
  TMenuForm = class(TForm)
    OKButton: TButton;
    CancelButton: TButton;
    Button3: TButton;
    ContestGroup: TGroupBox;
    OpGroup: TRadioGroup;
    BandGroup: TRadioGroup;
    rbALLJA: TRadioButton;
    rb6D: TRadioButton;
    rbFD: TRadioButton;
    rbACAG: TRadioButton;
    ModeGroup: TRadioGroup;
    CallsignEdit: TEdit;
    Label1: TLabel;
    OpenDialog: TOpenDialog;
    rbCQWW: TRadioButton;
    rbJIDXJA: TRadioButton;
    rbCQWPX: TRadioButton;
    rbPedi: TRadioButton;
    rbJIDXDX: TRadioButton;
    rbGeneral: TRadioButton;
    CFGOpenDialog: TOpenDialog;
    SelectButton: TSpeedButton;
    CheckBox1: TCheckBox;
    rbARRLDX: TRadioButton;
    rbARRLW: TRadioButton;
    rbAPSprint: TRadioButton;
    rbJA0in: TRadioButton;
    rbJA0out: TRadioButton;
    TXNrEdit: TEdit;
    Label2: TLabel;
    ScoreCoeffEdit: TEdit;
    Label3: TLabel;
    rbIARU: TRadioButton;
    rbAllAsian: TRadioButton;
    rbIOTA: TRadioButton;
    rbARRL10: TRadioButton;
    rbKCJ: TRadioButton;
    rbWAE: TRadioButton;
    {procedure CreateParams(var Params: TCreateParams); override;}
    procedure OKButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MyIdleEvent(Sender: TObject; var Done: Boolean);
    procedure MyMessageEvent(var Msg: TMsg; var Handled: Boolean);
    procedure rbCQWWClick(Sender: TObject);
    procedure rbGeneralEnter(Sender: TObject);
    procedure rbGeneralExit(Sender: TObject);
    procedure SelectButtonClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure rbALLJAClick(Sender: TObject);
    procedure rbPediClick(Sender: TObject);
    procedure rbACAGClick(Sender: TObject);
    procedure rb6DClick(Sender: TObject);
    procedure rbFDClick(Sender: TObject);
    procedure rbJA0inClick(Sender: TObject);
    procedure rbARRLWClick(Sender: TObject);
    procedure rbAPSprintClick(Sender: TObject);
    procedure OpGroupClick(Sender: TObject);
    procedure TXNrEditKeyPress(Sender: TObject; var Key: Char);
    procedure UserDefClick(Sender: TObject);
    procedure rbIARUClick(Sender: TObject);
    procedure rbIOTAClick(Sender: TObject);
    procedure rbARRL10Click(Sender: TObject);
    procedure rbARRL10Exit(Sender: TObject);
    procedure FnugrySingleInstance1AlreadyRunning(Sender: TObject;
      hPrevInst, hPrevWnd: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure rbKCJClick(Sender: TObject);
    procedure rbWAEClick(Sender: TObject);
    public
      BandTemp : integer; // temporary storage for bandgroup.itemindex
      TabPressed : boolean;
      TabPressed2 : boolean; // for moving focus to numberedit
      CFGFileName : string;
    procedure EnableEveryThing;
  end;

var
  MenuForm: TMenuForm;
  LastTabPress : TDateTime;

implementation

uses Main, UOptions, UACAGMulti, UALLJAMulti, UALLJAScore1, UACAGScore,
  UALLJAEditDialog, UALLJAScore, UWWMulti, UWWScore, UWWZone, UJIDXScore,
  UJIDXMulti, UJIDXScore2, UWPXMulti, UWPXScore, UZLinkForm, UPediScore,
  UJIDX_DX_Multi, UJIDX_DX_Score, UGeneralMulti2, UGeneralScore, UFDMulti,
  UARRLDXMulti, UARRLDXScore, UARRLWMulti, UAPSprintScore, UJA0Multi,
  UJA0Score, USixDownMulti, USixDownScore, UIARUMulti, UIARUScore,
  UAllAsianScore, UAgeDialog, UIOTAMulti, UUTCDialog, UARRL10Score, UARRL10Multi,
  USummaryInfo, UKCJMulti, UKCJScore, UKCJZone, UMultipliers, UTTYConsole,
  UWAEScore, UWAEMulti, UELogJapanese;

{$R *.DFM}

{procedure TMenuForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Caption := PChar('zLog');
end; }

procedure TMenuForm.OKButtonClick(Sender: TObject);
var i : integer;
    E : Extended;
begin
  Main.CurrentQSO.QSO.Serial := 1;
  MainForm.mPXListWPX.Visible := False;

  Options.SetMultiOp(OpGroup.ItemIndex);

  case BandGroup.ItemIndex of
    0..3 : Options.SetBand(BandGroup.ItemIndex);
    4 : Options.SetBand(BandGroup.ItemIndex+1);
    5 : Options.SetBand(BandGroup.ItemIndex+2);
    6..13 : Options.SetBand(BandGroup.ItemIndex+3);
  end;

  // Options.SetBand(BandGroup.ItemIndex);

  Options.SetMode(ModeGroup.ItemIndex);

  Options.SetMyCall(CallsignEdit.Text);

  for i := 0 to ContestGroup.ControlCount - 1 do
    begin
      if ContestGroup.Controls[i] is TRadioButton then
        if TRadioButton(ContestGroup.Controls[i]).Checked then
          break;
    end;

  Options.SetCurrentContestNo(i);

  try
    i := StrToInt(TXNrEdit.Text);
  except
    on EConvertError do
      i := 0;
  end;

  if OpGroup.ItemIndex > 0 then
    begin
      Options.SetTXNr(i);
      if Options.Settings._pcname = '' then
        Options.Settings._pcname := 'PC'+IntToStr(i);
    end;

  if ScoreCoeffEdit.Enabled then
    begin
      try
        E := StrToFloat(ScoreCoeffEdit.Text);
      except
        on EConvertError do
          E := 1;
      end;
      Options.SetScoreCoeff(E);
    end
  else
    Options.SetScoreCoeff(0);

  Options.SaveCurrentSettings;

{Open New Contest from main menu}
  if MyContest <> nil then
    MyContest.Free;
  if Log <> nil then
    begin
      Log.Destroy;
      Log := TQSOList.Create('default');
    end;
  if MainForm.EditScreen <> nil then
    MainForm.EditScreen.Free;

  if rbKCJ.Checked then
    begin
      Application.CreateForm(TKCJMulti, KCJMulti);
      //Application.CreateForm(TACAGScore, ACAGScore);
      Application.CreateForm(TKCJScore, KCJScore);
      Application.CreateForm(TKCJZone, KCJZone);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TKCJContest.Create('KCJ コンテスト');
      QTHString := Options.Settings._prov;
      //TQSO(Log.List[0]).QSO.memo := 'ALL JA コンテスト';
      Options.Settings._sentstr := 'TK';
    end;

  if rbALLJA.Checked then
    begin
      Application.CreateForm(TALLJAMulti, ALLJAMulti);
      Application.CreateForm(TALLJAScore, ALLJAScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TALLJAContest.Create('ALL JA コンテスト');
      QTHString := Options.Settings._prov;
      //TQSO(Log.List[0]).QSO.memo := 'ALL JA コンテスト';
      Options.Settings._sentstr := '$V$P';
    end;
  if rbACAG.Checked then
    begin
      Application.CreateForm(TACAGMulti, ACAGMulti);
      Application.CreateForm(TACAGScore, ACAGScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TACAGContest.Create('全市全郡コンテスト');
      QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'ACAG Contest';
      Options.Settings._sentstr := '$Q$P';
    end;
  if rbFD.Checked then
    begin
      Application.CreateForm(TACAGMulti, ACAGMulti);
      Application.CreateForm(TFDMulti, FDMulti);
      Application.CreateForm(TACAGScore, ACAGScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TFDContest.Create('フィールドデーコンテスト');
      QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'ACAG Contest';
      Options.Settings._sentstr := '$Q$P';
    end;
  if rb6D.Checked then
    begin
      Application.CreateForm(TACAGMulti, ACAGMulti);
      Application.CreateForm(TFDMulti, FDMulti);
      Application.CreateForm(TSixDownMulti, SixDownMulti);
      Application.CreateForm(TSixDownScore, SixDownScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TSixDownContest.Create('6m and DOWNコンテスト');
      QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'ACAG Contest';
      Options.Settings._sentstr := '$Q$P';
    end;
  if rbGeneral.Checked then
    begin
      Application.CreateForm(TACAGMulti, ACAGMulti);
      Application.CreateForm(TGeneralMulti2, GeneralMulti2);
      Application.CreateForm(TGeneralScore, GeneralScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'ACAG Contest';
      Options.Settings._sentstr := '$Q';
      MyContest := TGeneralContest.Create(rbGeneral.Caption);
    end;
  if rbCQWW.Checked then
    begin
      Application.CreateForm(TWWScore, WWScore);
      Application.CreateForm(TWWZone, WWZone);
      Application.CreateForm(TWWMulti, WWMulti);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TCQWWContest.Create('CQWW DX Contest');
      //QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'CQWW Contest';
      Options.Settings._sentstr := '$Z';
      QTHString := {WWMulti.}UMultipliers.MyZone;
    end;
  if rbIARU.Checked then
    begin
      Application.CreateForm(TIARUScore, IARUScore);
      Application.CreateForm(TWWZone, WWZone);
      Application.CreateForm(TWWMulti, WWMulti);
      Application.CreateForm(TIARUMulti, IARUMulti);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TIARUContest.Create('IARU HF World Championship');
      //QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'CQWW Contest';
      Options.Settings._sentstr := '$I';
      QTHString := {IARUMulti.}MyZone;
    end;

  if rbJIDXJA.Checked then // now determines JA/DX from callsign
    begin
      Application.CreateForm(TWWZone, WWZone);
      Application.CreateForm(TWWMulti, WWMulti);
      if {WWMulti.}MyCountry = 'JA' then
        begin
          Application.CreateForm(TJIDXMulti, JIDXMulti);
          Application.CreateForm(TJIDXScore2, JIDXScore2);
          Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
          MyContest := TJIDXContest.Create('JIDX Contest (JA)');
          QTHString := Options.Settings._prov;
          Options.Settings._sentstr := '$V';
        end
      else
        begin
          WWMulti.Release;
          WWZone.Release;
          Application.ProcessMessages;
          Application.CreateForm(TJIDX_DX_Multi, JIDX_DX_Multi);
          Application.CreateForm(TJIDX_DX_Score, JIDX_DX_Score);
          Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
          MyContest := TJIDXContestDX.Create('JIDX Contest (DX)');
          QTHString := Options.Settings._prov;
          Options.Settings._sentstr := '$V';
        end;
    end;

{
  if rbJIDXJA.Checked then
    begin
      Application.CreateForm(TWWZone, WWZone);
      Application.CreateForm(TWWMulti, WWMulti);
      Application.CreateForm(TJIDXMulti, JIDXMulti);
      Application.CreateForm(TJIDXScore2, JIDXScore2);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TJIDXContest.Create('JIDX Contest (JA)');
      QTHString := Options.Settings._prov;
      Options.Settings._sentstr := '$V';
    end;
  if rbJIDXDX.Checked then
    begin
      Application.CreateForm(TJIDX_DX_Multi, JIDX_DX_Multi);
      Application.CreateForm(TJIDX_DX_Score, JIDX_DX_Score);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TJIDXContestDX.Create('JIDX Contest (DX)');
      QTHString := Options.Settings._prov;
      Options.Settings._sentstr := '$V';
    end;
}
  if rbARRLDX.Checked then
    begin
      {Application.CreateForm(TWWScore, WWScore);}
      Application.CreateForm(TACAGMulti, ACAGMulti);
      Application.CreateForm(TARRLDXMulti, ARRLDXMulti);
      //Application.CreateForm(TJIDX_DX_Score, JIDX_DX_Score);
      Application.CreateForm(TARRLDXScore, ARRLDXScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TARRLDXContestDX.Create('ARRL International DX Contest (DX)');
      QTHString := Options.Settings._prov;
      //TQSO(Log.List[0]).QSO.memo := 'JIDX Contest';
      Options.Settings._sentstr := '$N';
    end;
  if rbARRLW.Checked then
    begin
      {Application.CreateForm(TWWScore, WWScore);}
      Application.CreateForm(TWWZone, WWZone);
      Application.CreateForm(TWWMulti, WWMulti);
      Application.CreateForm(TARRLWMulti, ARRLWMulti);
      //Application.CreateForm(TJIDX_DX_Score, JIDX_DX_Score);
      Application.CreateForm(TARRLDXScore, ARRLDXScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TARRLDXContestW.Create('ARRL International DX Contest (W/VE)');
      QTHString := Options.Settings._prov;
      //TQSO(Log.List[0]).QSO.memo := 'JIDX Contest';
      Options.Settings._sentstr := '$V';
    end;

  if rbWAE.Checked then
    begin
      {Application.CreateForm(TWWScore, WWScore);}
      Application.CreateForm(TWWZone, WWZone);
      Application.CreateForm(TWWMulti, WWMulti);
      Application.CreateForm(TARRLWMulti, ARRLWMulti);
      Application.CreateForm(TWAEMulti, WAEMulti);
      //Application.CreateForm(TJIDX_DX_Score, JIDX_DX_Score);
      Application.CreateForm(TWAEScore, WAEScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TWAEContest.Create('WAEDC Contest');
      //QTHString := Options.Settings._prov;
      //TQSO(Log.List[0]).QSO.memo := 'JIDX Contest';
      Options.Settings._sentstr := '$S';
    end;

  if rbCQWPX.Checked then
    begin
      {Application.CreateForm(TWWScore, WWScore);}
      Application.CreateForm(TWWZone, WWZone);
      Application.CreateForm(TWWMulti, WWMulti);
      Application.CreateForm(TWPXMulti, WPXMulti);
      Application.CreateForm(TWPXScore, WPXScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TCQWPXContest.Create('CQ WPX Contest');
      if OpGroup.ItemIndex = 1 then
        SerialContestType := SER_BAND;
      if OpGroup.ItemIndex = 2 then
        SerialContestType := SER_MS;
      QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'WPX Contest';
      Options.Settings._sentstr := '$S';
      MainForm.mPXListWPX.Visible := True;
    end;

  if rbAPSprint.Checked then
    begin
      {Application.CreateForm(TWWScore, WWScore);}
      Application.CreateForm(TWWZone, WWZone);
      Application.CreateForm(TWWMulti, WWMulti);
      Application.CreateForm(TWPXMulti, WPXMulti);
      Application.CreateForm(TWPXScore, WPXScore);
      Application.CreateForm(TAPSprintScore, APSprintScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TAPSprint.Create('Asia Pacific Sprint');
      QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'WPX Contest';
      Options.Settings._sentstr := '$S';
    end;

  if rbJA0in.Checked then
    begin
      {Application.CreateForm(TWWScore, WWScore);}
      Application.CreateForm(TJA0Multi, JA0Multi);
      Application.CreateForm(TJA0Score, JA0Score);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TJA0ContestZero.Create('ALL JA0 コンテスト (JA0)');
      case BandGroup.ItemIndex of
        2 : MyContest.SetBand(b35);
        3 : MyContest.SetBand(b7);
        5, 6 : begin
                 MyContest.SetBand(b21);
                 Options.Settings._band := 0;
               end;
      end;
      QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'WPX Contest';
      Options.Settings._sentstr := '$S';
    end;

  if rbJA0out.Checked then
    begin
      {Application.CreateForm(TWWScore, WWScore);}
      Application.CreateForm(TJA0Multi, JA0Multi);
      Application.CreateForm(TJA0Score, JA0Score);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TJA0Contest.Create('ALL JA0 コンテスト (Others)');
      case BandGroup.ItemIndex of
        2 : MyContest.SetBand(b35);
        3 : MyContest.SetBand(b7);
        5, 6 : begin
                 MyContest.SetBand(b21);
                 Options.Settings._band := 0;
               end;
      end;
      QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'WPX Contest';
      Options.Settings._sentstr := '$S';
    end;

  if rbAllAsian.Checked then
    begin
      {Application.CreateForm(TWWScore, WWScore);}
      Application.CreateForm(TWWZone, WWZone);
      Application.CreateForm(TWWMulti, WWMulti);
      Application.CreateForm(TARRLWMulti, ARRLWMulti);
      //Application.CreateForm(TJIDX_DX_Score, JIDX_DX_Score);
      Application.CreateForm(TIARUScore, IARUScore);
      Application.CreateForm(TAllAsianScore, AllAsianScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);
      MyContest := TAllAsianContest.Create('All Asian DX Contest (Asia)');
      QTHString := Options.Settings._prov;
      //TQSO(Log.List[0]).QSO.memo := 'JIDX Contest';
      Options.Settings._sentstr := '$A';

      Application.CreateForm(TAgeDialog, AgeDialog);
      AgeDialog.ShowModal;
      AgeDialog.Free;

    end;

  if rbPedi.Checked then
    begin
      Application.CreateForm(TALLJAMulti, ALLJAMulti);
      Application.CreateForm(TPediScore, PediScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);

      Application.CreateForm(TUTCDialog, UTCDialog);
      UTCDialog.ShowModal;
      UTCDialog.Free;

      MyContest := TPedi.Create('Pedition mode');

      QTHString := Options.Settings._prov;
      //TQSO(Log.List[0]).QSO.memo := 'Pedition mode';
      Options.Settings._sentstr := '';
    end;

  if rbIOTA.Checked then
    begin
      Application.CreateForm(TACAGMulti, ACAGMulti);
      Application.CreateForm(TIOTAMulti, IOTAMulti);
      Application.CreateForm(TIARUScore, IARUScore);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);

      MyContest := TIOTAContest.Create('IOTA Contest');
      //QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'ACAG Contest';
      Options.Settings._sentstr := '$S$Q';
    end;

  if rbARRL10.Checked then
    begin
      Application.CreateForm(TWWZone, WWZone);
      Application.CreateForm(TWWMulti, WWMulti);
      Application.CreateForm(TARRL10Multi, ARRL10Multi);
      Application.CreateForm(TARRL10Score, ARRL10Score);
      Application.CreateForm(TALLJAEditDialog, ALLJAEditDialog);

      Options.Settings._sentstr := '$S';
      MyContest := TARRL10Contest.Create('ARRL 10m Contest');
      //QTHString := Options.Settings._city;
      //TQSO(Log.List[0]).QSO.memo := 'ACAG Contest';
    end;


  if ModeGroup.ItemIndex = 1 then
    begin
      Main.CurrentQSO.QSO.mode := mCW;
      Main.CurrentQSO.QSO.RSTRcvd := 599;
      Main.CurrentQSO.QSO.RSTSent := 599;
    end
  else
    begin
      Main.CurrentQSO.QSO.mode := mSSB;
      Main.CurrentQSO.QSO.RSTRcvd := 59;
      Main.CurrentQSO.QSO.RSTSent := 59;
    end;

  if CurrentFileName = '' then
    begin
      OpenDialog.InitialDir := Options.Settings._logspath;
      if OpenDialog.Execute then
        begin
          CurrentFileName := OpenDialog.FileName;
          if FileExists(CurrentFileName) then
            begin
              MainForm.LoadNewContestFromFile(CurrentFileName);
              {MyContest.Renew;
              MainForm.EditScreen.Renew; }
            end;
        end
      else // user hit cancel
        begin
           MessageDlg('Data will NOT be saved until you enter the file name', mtWarning,
                    [mbOK], 0); {HELP context 0}
        end;
      end
    else
      begin
      end;

  {Options.Settings.CW.CWStrBank[1, 2] := Options.Settings._sentstr; }

  MyContest.Renew;

  if ModeGroup.ItemIndex = 0 then
    MyContest.ScoreForm.CWButton.Visible := True
  else
    MyContest.ScoreForm.CWButton.Visible := False;

  // MainForm.EditScreen.Renew;  called from TContest.Renew;

  if TQSO(Log.List[0]).QSO.RSTSent = 0 then //JST = 0; UTC = $FFFF
    SummaryInfo.DecJapanese
  else
    SummaryInfo.DecEnglish;

  MainForm.Show;

  Hide;
  ELogJapanese.InitializeFields;
  MainForm.CallsignEdit.SetFocus;


end;

procedure TMenuForm.CancelButtonClick(Sender: TObject);
begin
  CloseBGK;
  Close;
end;

procedure TMenuForm.FormDestroy(Sender: TObject);
begin
  CloseBGK;
end;

procedure TMenuForm.FormCreate(Sender: TObject);
var s : string;
    i : integer;
begin
  if HiWord(GetKeyState(VK_SPACE)) <> 0 then
    begin
      zLogGlobal.DEBUGMODE := TRUE;
      BGK32LIB.DEBUGMODE := TRUE;
    end;
  LastTabPress := Now;
  ShowWindow(MenuForm.Handle, SW_HIDE);
  s := '';
  for i := 0 to ParamCount do
    s := s +' '+ ParamStr(i);
  Application.OnIdle := MyIdleEvent;
  Application.OnMessage := MyMessageEvent;
{  if pos('/NOBGK', UpperCase(s)) = 0 then
    InitializeBGK; }
  TabPressed := False;
  TabPressed2 := False;
  CFGFileName := '';
  MAINPATH := ExtractFilePath(Application.EXEName);
end;

procedure TMenuForm.FormShow(Sender: TObject);
var i : integer;
begin
  if Options.Band = 0 then
    BandGroup.ItemIndex := 0
  else
    BandGroup.ItemIndex := OldBandOrd(TBand(Options.Band - 1)) + 1;
  ModeGroup.ItemIndex := Options.Mode;

  if Options.MultiOp > 0 then
    begin
      OpGroup.ItemIndex := Options.MultiOp;
      TXNrEdit.Enabled := True;
    end
  else
    begin
      OpGroup.ItemIndex := 0;
      TXNrEdit.Enabled := False;
    end;

  TXNrEdit.Text := IntToStr(Options.GetTXNr);

  CallsignEdit.Text := Options.MyCall;

  EnableEverything;
  if Options.ContestMenuNo < ContestGroup.ControlCount then
    if ContestGroup.Controls[Options.ContestMenuNo] is TRadioButton then
      TRadioButton(ContestGroup.Controls[Options.ContestMenuNo]).Checked := True;

  if rbGeneral.Checked then
    SelectButton.Enabled := True;

  OpGroup.OnClick(Self); // enables or disables TXNrEdit


end;

procedure TMenuForm.MyIdleEvent(Sender: TObject; var Done: Boolean);
var A : word;
    boo : boolean;

begin
  //PaddleProcess;
  {
  if Options.Speed <> BGK32LIB.GetWPM then
    begin
     Options.Setting.CW._speed := BGK32LIB.GetWPM;
     SpeedBar.Position := Options.Settings.CW._speed;
     SpeedLabel.Caption := IntToStr(SpeedBar.Position)+' wpm';
    end;
  }

  boo := BGK32LIB.IsPlaying;
  if boo then
    begin
      if Main.CurrentQSO.QSO.Mode = mCW then
        begin
          MainForm.CWPauseButton.Enabled := true;
          MainForm.CWPauseButton.Visible := true;
          MainForm.CWPlayButton.Visible := false;
          MainForm.CWStopButton.Enabled := true;
        end
      else
        begin
        end;
    end
  else
    begin
     //if Paused = False then
      if Main.CurrentQSO.QSO.Mode = mCW then
        TabPressed := False;
      if SaveInBackGround = True then
        begin
          MainForm.SaveFileAndBackUp;
          SaveInBackGround := False;
        end;
      MainForm.CWPauseButton.Enabled := false;
      if not(BGK32LIB.Paused) then
        MainForm.CWStopButton.Enabled := false
      else
        MainForm.CWStopButton.Enabled := true;
   end;

  if Main.CurrentQSO.QSO.Mode = mRTTY then
    if TTYConsole <> nil then
      if TTYConsole.Sending = false then
        begin
          TabPressed := False;
        end;

  if HiWord(GetKeyState(VK_TAB))<>0 then
    begin
      if not(TabPressed) and (MainForm.CallsignEdit.Focused or MainForm.NumberEdit.Focused) then
        begin
          if Trunc((Now-LastTabPress)*24*60*60*1000) > 100 then
            MainForm.OnTabPress;
          LastTabPress := Now;
        end;
    end;

  //ZLinkForm.ProcessCommand;

  //MainForm.MonitorPort;
  //MainForm.Caption := BGK32LIB.GetPRTPort;

  Done := True;

end;

procedure TMenuForm.MyMessageEvent(var Msg: TMsg; var Handled: Boolean);
begin
  if MMTTYInitialized then
    UMMTTY.ProcessMMTTYMessage(Msg, Handled);
end;

procedure TMenuForm.rbCQWWClick(Sender: TObject);
begin
  if ModeGroup.ItemIndex in [0, 3] then
    ModeGroup.ItemIndex := 1;
end;



procedure TMenuForm.rbGeneralEnter(Sender: TObject);
begin
//  SelectButton.Enabled := True;
end;

procedure TMenuForm.rbGeneralExit(Sender: TObject);
begin
  OKButton.Enabled := True;
//  SelectButton.Enabled := False;
end;

procedure TMenuForm.SelectButtonClick(Sender: TObject);
begin
  CFGOpenDialog.InitialDir := Options.Settings._cfgdatpath;
  if CFGOpenDialog.Execute then
    begin
      CFGFileName := CFGOpenDialog.FileName;
      rbGeneral.Caption := GetContestName(CFGFileName);
      if UsesCoeff(CFGFileName) then
        ScoreCoeffEdit.Enabled := True
      else
        ScoreCoeffEdit.Enabled := False;
      OKButton.Enabled := True;
    end;
end;

procedure TMenuForm.CheckBox1Click(Sender: TObject);
begin
  PostContest := CheckBox1.Checked;
end;

procedure TMenuForm.EnableEveryThing;
var i : integer;
begin
  for i := 0 to BandGroup.Items.Count-1 do
    BandGroup.Controls[i].Enabled := True;
  for i := 0 to OpGroup.Items.Count-1 do
    OpGroup.Controls[i].Enabled := True;
  for i := 0 to ModeGroup.Items.Count-1 do
    ModeGroup.Controls[i].Enabled := True;
  TXNrEdit.Enabled := True;
  OpGroup.OnClick(Self);
  SelectButton.Enabled := False;
  ScoreCoeffEdit.Enabled := False;
  OKButton.Enabled := True;
end;

procedure TMenuForm.rbALLJAClick(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  BandGroup.Controls[1].Enabled := False;
  for i := 8 to 13 do
    BandGroup.Controls[i].Enabled := False;
  //ModeGroup.Controls[2].Enabled := False;
  ModeGroup.Controls[3].Enabled := False;
end;

procedure TMenuForm.rbPediClick(Sender: TObject);
begin
  EnableEveryThing;
end;

procedure TMenuForm.rbACAGClick(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  BandGroup.Controls[1].Enabled := False;
  //ModeGroup.Controls[2].Enabled := False;
  ModeGroup.Controls[3].Enabled := False;
end;

procedure TMenuForm.rb6DClick(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  for i := 1 to 6 do
    BandGroup.Controls[i].Enabled := False;
  //ModeGroup.Controls[2].Enabled := False;
  ModeGroup.Controls[3].Enabled := False;
end;

procedure TMenuForm.rbFDClick(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  ScoreCoeffEdit.Enabled := True;
  BandGroup.Controls[1].Enabled := False;
  //ModeGroup.Controls[2].Enabled := False;
  ModeGroup.Controls[3].Enabled := False;
end;

procedure TMenuForm.rbJA0inClick(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  for i := 0 to 1 do
    BandGroup.Controls[i].Enabled := False;
  BandGroup.Controls[4].Enabled := False;
  for i := 7 to 13 do
    BandGroup.Controls[i].Enabled := False;
  ModeGroup.Controls[2].Enabled := False;
  ModeGroup.Controls[3].Enabled := False;
  OpGroup.Controls[1].Enabled := False;
  TXNrEdit.Enabled := False;
end;

procedure TMenuForm.rbARRLWClick(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  for i := 7 to 13 do
    BandGroup.Controls[i].Enabled := False;
  ModeGroup.Controls[0].Enabled := False;
  ModeGroup.Controls[3].Enabled := False;
end;

procedure TMenuForm.rbAPSprintClick(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  for i := 1 to 13 do
    BandGroup.Controls[i].Enabled := False;
  ModeGroup.Controls[0].Enabled := False;
  ModeGroup.Controls[3].Enabled := False;
  OpGroup.Controls[1].Enabled := False;
  TXNrEdit.Enabled := False;
end;

procedure TMenuForm.OpGroupClick(Sender: TObject);
begin
  if OpGroup.ItemIndex = 0 then
    TXNrEdit.Enabled := False
  else
    TXNrEdit.Enabled := True;
end;

procedure TMenuForm.TXNrEditKeyPress(Sender: TObject; var Key: Char);
begin
  if not(Key in ['0'..'9']) then
    Key := #0;
end;

procedure TMenuForm.UserDefClick(Sender: TObject);
begin
  EnableEverything;
  if CFGFileName <> '' then
    if UsesCoeff(CFGFileName) then
     ScoreCoeffEdit.Enabled := True;
  if CFGFileName = '' then
    OKButton.Enabled := False;
  SelectButton.Enabled := True;

end;



procedure TMenuForm.rbIARUClick(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  for i := 7 to 13 do
    BandGroup.Controls[i].Enabled := False;
  ModeGroup.Controls[3].Enabled := False;
end;

procedure TMenuForm.rbIOTAClick(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  BandGroup.Controls[1].Enabled := False;
  for i := 7 to 13 do
    BandGroup.Controls[i].Enabled := False;
  ModeGroup.Controls[3].Enabled := False;
end;


procedure TMenuForm.rbARRL10Click(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  for i := 0 to 5 do
    BandGroup.Controls[i].Enabled := False;
  for i := 7 to 13 do
    BandGroup.Controls[i].Enabled := False;

  BandTemp := BandGroup.ItemIndex;

  BandGroup.ItemIndex := 6;
  ModeGroup.Controls[3].Enabled := False;
end;

procedure TMenuForm.rbARRL10Exit(Sender: TObject);
begin
  BandGroup.ItemIndex := BandTemp;
end;


procedure TMenuForm.FnugrySingleInstance1AlreadyRunning(Sender: TObject;
  hPrevInst, hPrevWnd: Integer);
begin
  close;
end;


procedure TMenuForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ^X then
    rbKCJ.Visible := True;
  if Key = ^T then
    rbKCJ.Visible := True;
end;

procedure TMenuForm.rbKCJClick(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  //BandGroup.Controls[1].Enabled := False;
  for i := 8 to 13 do
    BandGroup.Controls[i].Enabled := False;
  ModeGroup.Controls[0].Enabled := False;
  ModeGroup.Controls[2].Enabled := False;
  ModeGroup.Controls[3].Enabled := False;
  OpGroup.Controls[1].Enabled := False;
  OpGroup.Controls[2].Enabled := False;
end;

procedure TMenuForm.rbWAEClick(Sender: TObject);
var i : integer;
begin
  EnableEveryThing;
  BandGroup.Controls[1].Enabled := False;
  for i := 7 to 13 do
    BandGroup.Controls[i].Enabled := False;
  ModeGroup.Controls[0].Enabled := False;
  ModeGroup.Controls[3].Enabled := False;
end;

end.
