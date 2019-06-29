unit UOptions;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, ComCtrls, zLogGlobal, Ini, Spin,
  BGK32Lib, Dialogs, Menus, PathDialog, UPaddleThread, Vic_Res,
  UIntegerDialog;


const
  RIGNAMEMAX = 39;
  RIGNAMES : array[0..RIGNAMEMAX] of string =
('None',
 'TS-690/450',
 'TS-850',
 'TS-790',
 'TS-2000',
 'TS-2000/P',
 'FT-817',
 'FT-847',
 'FT-920',
 'FT-100',
 'FT-1000',
 'FT-1000MP',
 'MarkV/FT-1000MP',
 'FT-1000MP Mark-V Field',
 'IC-706',
 'IC-706MkII',
 'IC-706MkII-G',
 'IC-721',
 'IC-726',

 'IC-731',
 'IC-736',
 'IC-746',
 'IC-746PRO',
 'IC-7400',
 'IC-750',
 'IC-756',

 'IC-756PRO',
 'IC-760',
 'IC-760PRO',
 'IC-775',
 'IC-780',
 'IC-820',
 'IC-821',
 'IC-910',
 'IC-970',

 'IC-275',
 'IC-375',
 'JST-145',
 'JST-245',
 'Omni-Rig');


const maxbank = 3; // bank 3 reserved for rtty
      maxstr = 8;
      maxmaxstr = 12; // f11 and f12 only accessible via zlog.ini

      LPTMAX = 2;

var   LPTport : array[1..LPTMAX] of word; // holds the base port + 2

type
  TCWSettingsParam = record
    _speed : integer;
    _weight : integer;
    _fixwpm : integer;
    _paddlereverse : boolean;
    _sidetone : boolean;
    _tonepitch : integer;
    _cqmax : integer;
    _cqrepeat : double;
    _FIFO : boolean;
    _interval : integer;
    _paddle : boolean;
    _zero : char;
    _one : char;
    _nine : char;
    CWStrBank : array[1..maxbank,1..maxmaxstr] of string[255]; //bank 3 is for rtty
    CQStrBank : array[0..2] of string[255];
    CurrentBank : integer; {for future use?}
    _spacefactor : word; {factor in % for default space between characters}
    _eispacefactor : word;

  end;

  TSettingsParam = record
    _AFSK : boolean; // Use AFSK instead of RTTY for rig control
    _dontallowsameband : boolean; // same band on two rigs?
    _BandData : array[b19..b10g] of byte; {band data output}
    _multiop : integer;  {multi op/ single op}
    _band : integer; {0 = all band; 1 = 1.9MHz 2 = 3.5MHz ...}
    _mode : integer; {0 = Ph/CW; 1 = CW; 2=Ph; 3 = Other}
    _contestmenuno : integer; {selected contest in the menu}
    _mycall : string[15];
    _prov : string[15];
    _city : string[50];
    _cqzone : string[3];
    _iaruzone : string[3];
    _sendfreq : double;

 {  _cqcountry : string[50];
    _dxcccountry : string[50];
    _cqzone : string[3];
    _iaruzone : string[3];
    _continent : string[20];  }

    _autobandmap: boolean;
    _activebands : array[b19..HiBand] of boolean;
    _SoundFiles : array[1..10] of string;
    _SoundComments : array[1..10] of string;
    CW : TCWSettingsParam;
    _clusterport : integer; {0 : none 1-4 : com# 5 : telnet}
    _rig1port : integer; {0 : none 1-4 : com#}
    _rig1name : integer;
    _rig2port : integer; {0 : none 1-4 : com#}
    _rig2name : integer;
    _zlinkport : integer; {0 : none 1-4 : com# 5: telnet}
    _clusterbaud : integer; {}
    _rigbaud : integer; //not used
    _zlinkbaud : integer;
    _icombaudrate : integer;
    _clusterhost : string;
    _clustertelnetport : integer;
    _clusterlinebreakTELNET : integer; {0 : CRLF, 1 : CR, 2 : LF}
    _clusterlocalechoTELNET : boolean;
    _clusterlinebreakCOM : integer;
    _clusterlocalechoCOM : boolean;
    _zlinkhost : string;
    _zlinklinebreakTELNET : integer; {0 : CR, 1 : CR+LF, 2 : LF}
    _zlinklocalechoTELNET : boolean;
    _zlinklinebreakCOM : integer;
    _zlinklocalechoCOM : boolean;
    _multistationwarning : boolean; // true by default. turn off not new mult warning dialog
    _specificcwport : word; {specific assignment of cw out port#}
    _lptnr : integer; {1 : LPT1; 2 : LPT2;  11:COM1; 12 : COM2;  21: USB}
    //_usedata : boolean; {default = False; use data out if true}
                        {not supported now}
    _reverselogic : boolean; {default = false. reverse logic for keying}
    _rigreverse : boolean; //  default = false
    _pttreverse : boolean;

    _sentstr : string; {exchanges sent $Q$P$O etc. Set at menu select}

    _backuppath : string;
    _cfgdatpath : string;
    _logspath : string;

    _pttenabled : boolean;
    _pttbefore : word;
    _pttafter  : word;
    _txnr : byte;
    _pcname : string[32];
    _saveevery : word;
    _scorecoeff : extended;
    _age : string[3]; // all asian
    _allowdupe : boolean;
    _countdown : boolean;
    _qsycount : boolean;

    _sameexchange : boolean; //true if exchange is same for all bands. false if serial etc.
    _entersuperexchange : boolean;
    _jmode : boolean;
    _mainfontsize : integer;
    _mainrowheight : integer;
    //_updatetimeonenter : boolean;
    _ritclear : boolean; // clear rit after each qso
    _searchafter : integer; // 0 default. for super / partial check
    _banddatamode : integer; // 0 : none, 1 : radio1, 2 : radio2, 3 : active
    _savewhennocw : boolean; // def=false. save when cw is not being sent
    _multistation : boolean; // warn when logging non-newmulti qso
    _maxsuperhit : integer; // max # qso hit
    _bsexpire : integer; // bandscope expiration time in minutes
    _spotexpire : integer; // spot expiration time in minutes
    _renewbythread : boolean;
    _movetomemo : boolean; // move to memo w/ spacebar when editing past qsos
    _bsminfreqarray : array[b19..HiBand, mCW..mOther] of Integer; // kHz
    _bsmaxfreqarray : array[b19..HiBand, mCW..mOther] of Integer; // kHz
    _recrigfreq : boolean; // record rig freq in memo

    _transverter1 : boolean;
    _transverter2 : boolean;
    _transverteroffset1 : integer;
    _transverteroffset2 : integer;
    _syncserial : boolean; // synchronize serial # over network
    _switchcqsp : boolean; // switch cq/sp modes by shift+F
    _displaydatepartialcheck : boolean;
  end;



type
  TOptions = class(TForm)
    PageControl: TPageControl;
    PrefTabSheet: TTabSheet;
    TabSheet2: TTabSheet;
    CWTabSheet: TTabSheet;
    VoiceTabSheet: TTabSheet;
    TabSheet5: TTabSheet;
    tbRigControl: TTabSheet;
    Panel1: TPanel;
    OKButton: TButton;
    Button2: TButton;
    Button3: TButton;
    GroupBox1: TGroupBox;
    SingleOpRadioBtn: TRadioButton;
    MultiOpRadioBtn: TRadioButton;
    BandGroup: TRadioGroup;
    OpListBox: TListBox;
    ModeGroup: TRadioGroup;
    OpEdit: TEdit;
    Add: TButton;
    Delete: TButton;
    Ini: TIni;
    GroupBox2: TGroupBox;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit9: TEdit;
    Edit8: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Edit10: TEdit;
    Edit1: TEdit;
    SpeedBar: TTrackBar;
    Label11: TLabel;
    SpeedLabel: TLabel;
    Label13: TLabel;
    WeightBar: TTrackBar;
    WeightLabel: TLabel;
    CQmaxSpinEdit: TSpinEdit;
    ToneSpinEdit: TSpinEdit;
    Label15: TLabel;
    Label16: TLabel;
    SideToneCheck: TCheckBox;
    PaddleCheck: TCheckBox;
    CQRepEdit: TEdit;
    Label17: TLabel;
    FIFOCheck: TCheckBox;
    PaddleEnabledCheck: TCheckBox;
    AbbrevEdit: TEdit;
    Label12: TLabel;
    ProvEdit: TEdit;
    CItyEdit: TEdit;
    Label14: TLabel;
    Label18: TLabel;
    SentEdit: TEdit;
    Label19: TLabel;
    GroupBox3: TGroupBox;
    act19: TCheckBox;
    act35: TCheckBox;
    act7: TCheckBox;
    act14: TCheckBox;
    act21: TCheckBox;
    act28: TCheckBox;
    act50: TCheckBox;
    act144: TCheckBox;
    act430: TCheckBox;
    act1200: TCheckBox;
    act2400: TCheckBox;
    act5600: TCheckBox;
    act10g: TCheckBox;
    GroupBox4: TGroupBox;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    vEdit2: TEdit;
    vEdit3: TEdit;
    vEdit4: TEdit;
    vEdit5: TEdit;
    vEdit6: TEdit;
    vEdit7: TEdit;
    vEdit9: TEdit;
    vEdit8: TEdit;
    vEdit10: TEdit;
    vEdit1: TEdit;
    memo: TLabel;
    OpenDialog: TOpenDialog;
    GroupBox6: TGroupBox;
    Label30: TLabel;
    ClusterCombo: TComboBox;
    Port: TLabel;
    PCsetButton: TButton;
    OpenDialog1: TOpenDialog;
    Label32: TLabel;
    ZLinkCombo: TComboBox;
    Button1: TButton;
    ZLinkSetButton: TButton;
    vButton1: TButton;
    vButton2: TButton;
    vButton3: TButton;
    vButton4: TButton;
    vButton5: TButton;
    vButton6: TButton;
    vButton7: TButton;
    vButton8: TButton;
    vButton9: TButton;
    vButton10: TButton;
    act24: TCheckBox;
    act18: TCheckBox;
    act10: TCheckBox;
    PathDialog: TPathDialog;
    GroupBox5: TGroupBox;
    Button4: TButton;
    BackUpPathEdit: TEdit;
    CQZoneEdit: TEdit;
    IARUZoneEdit: TEdit;
    Label34: TLabel;
    Label35: TLabel;
    OpPowerEdit: TEdit;
    Label36: TLabel;
    Label37: TLabel;
    GroupBox7: TGroupBox;
    Label38: TLabel;
    PTTEnabledCheckBox: TCheckBox;
    Label39: TLabel;
    BeforeEdit: TEdit;
    AfterEdit: TEdit;
    AllowDupeCheckBox: TCheckBox;
    SaveEvery: TSpinEdit;
    Label40: TLabel;
    Label41: TLabel;
    cbCountDown: TCheckBox;
    rbBankA: TRadioButton;
    rbBankB: TRadioButton;
    cbDispExchange: TCheckBox;
    gbCWPort: TGroupBox;
    rbLPT1: TRadioButton;
    rbLPT2: TRadioButton;
    cbJMode: TCheckBox;
    Label33: TLabel;
    Rig1PortCombo: TComboBox;
    Label42: TLabel;
    Rig1Combo: TComboBox;
    Label43: TLabel;
    Label31: TLabel;
    Rig2PortCombo: TComboBox;
    Rig2Combo: TComboBox;
    Label44: TLabel;
    tbMisc: TTabSheet;
    cbRITClear: TCheckBox;
    rgBandData: TRadioGroup;
    cbDontAllowSameBand: TCheckBox;
    SendFreqEdit: TEdit;
    Label45: TLabel;
    Label46: TLabel;
    cbSaveWhenNoCW: TCheckBox;
    cbMultiStn: TCheckBox;
    rgSearchAfter: TRadioGroup;
    spMaxSuperHit: TSpinEdit;
    Label47: TLabel;
    spBSExpire: TSpinEdit;
    Label48: TLabel;
    Label49: TLabel;
    cbUpdateThread: TCheckBox;
    cbQSYCount: TCheckBox;
    cbRecordRigFreq: TCheckBox;
    cbTransverter1: TCheckBox;
    cbTransverter2: TCheckBox;
    TabSheet1: TTabSheet;
    Label50: TLabel;
    edCFGDATPath: TEdit;
    btnBrowseCFGDATPath: TButton;
    Label51: TLabel;
    edLogsPath: TEdit;
    btnBrowseLogsPath: TButton;
    rbCOM1: TRadioButton;
    rbCOM2: TRadioButton;
    rbRTTY: TRadioButton;
    cbCQSP: TCheckBox;
    rbUSB: TRadioButton;
    cbAFSK: TCheckBox;
    cbAutoEnterSuper: TCheckBox;
    Label52: TLabel;
    Label53: TLabel;
    spSpotExpire: TSpinEdit;
    cbDisplayDatePartialCheck: TCheckBox;
    cbAutoBandMap: TCheckBox;
    cbIcomBaudRate: TComboBox;
    Label54: TLabel;
    procedure MultiOpRadioBtnClick(Sender: TObject);
    procedure SingleOpRadioBtnClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AddClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure OpEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OpEditEnter(Sender: TObject);
    procedure OpEditExit(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure SpeedBarChange(Sender: TObject);
    procedure WeightBarChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vButtonClick(Sender: TObject);
    procedure ClusterComboChange(Sender: TObject);
    procedure PCsetButtonClick(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ZLinkComboChange(Sender: TObject);
    procedure ZLinkSetButtonClick(Sender: TObject);
    procedure BrowsePathClick(Sender: TObject);
    procedure PTTEnabledCheckBoxClick(Sender: TObject);
    procedure CQRepEditKeyPress(Sender: TObject; var Key: Char);
    procedure Edit1Change(Sender: TObject);
    procedure CWBankClick(Sender: TObject);
    procedure cbCountDownClick(Sender: TObject);
    procedure cbQSYCountClick(Sender: TObject);
    procedure cbTransverter1Click(Sender: TObject);
    procedure Rig1ComboChange(Sender: TObject);
    procedure Rig2ComboChange(Sender: TObject);
  private
    TempVoiceFiles : array[1..10] of string;
    TempCurrentBank : integer;
    TempCWStrBank : array[1..maxbank,1..maxmaxstr] of string[255]; // used temporarily while options window is open
  public
    OpList : TStringList;
    Settings : TSettingsParam;
    CurrentPower : array[b19..HiBand] of TPower;
    CurrentPower2 : array[b19..HiBand] of integer; {Power2 for ARRLDX}
    procedure SetOpPower(var aQSO : TQSO);
    procedure SaveCurrentSettings; {saves Settings to zlog.ini}
    procedure LoadIniFileBS; // called from loadinifile
    procedure LoadIniFile; {loads Settings from zlog.ini}
    function MultiOp : integer;
    function Band : integer;
    function Mode : integer;
    function ContestMenuNo : integer;
    function Speed : integer;
    function FIFO : boolean;
    function SideTone : boolean;
    procedure SetMultiOp(i : integer);
    procedure SetBand(b : integer);
    procedure SetWeight(i : integer);
    procedure SetMode(m : integer);
    procedure SetCurrentContestNo(i : integer);
    procedure SetFIFO(boo : boolean);
    procedure SetSpeed(i : integer);
    procedure SetSideTone(boo : boolean);
    procedure SetPaddle(boo : boolean);
    procedure SetTonePitch(i : integer);
    procedure SetCQMax(i : integer);
    procedure SetCQRepeat(r : double);
    procedure SetSendFreq(r : double);
    procedure SetMyCall(s : string);
    function MyCall : shortstring;
    procedure SetTXNr(i : byte);
    procedure SetScoreCoeff(E : Extended);
    function GetTXNr : byte;
    function CWMessage(bank, i : integer) : shortstring;
    procedure ImplementSettings(_OnCreate : boolean); {Sets various parameters according to Settings}
    procedure RenewSettings; {Reads controls and updates Settings}
    procedure SetPaddleReverse(boo : boolean);
    procedure ReversePaddle;
    function GetAge(aQSO : TQSO) : string;
    procedure RenewCWStrBankDisp;
    function PTTEnabled : boolean;
    function Rig1NameStr : string; // returns the selected rig name
    function Rig2NameStr : string; // returns the selected rig name
    procedure ReadWin(WinName : string; var Open : boolean; var X, Y, H, W : integer);
    procedure RecordSuperCheckColumns(c : integer);
    function GetSuperCheckColumns : integer;
    procedure ReadWin2(WinName : string; var F : TForm);
    procedure RecordWin(WinName : string; Open : boolean; X, Y : integer);
    procedure RestoreMainForm(var X, Y, W, H : integer; var TB1, TB2 : boolean);
    procedure RecordWin2(WinName : string; F : TForm);
    procedure RecordMainForm(X, Y, W, H : integer; TB1, TB2 : boolean);
  end;

var
  Options: TOptions;

implementation

uses Main, UzLogCW, UComm, UClusterTelnetSet, UClusterCOMSet,
  UZlinkTelnetSet, UZLinkForm, URigControl;

{$R *.DFM}


function TOptions.Rig1NameStr : string; // returns the selected rig name
begin
  Result := Rig1Combo.Items[Settings._rig1name];
end;

function TOptions.Rig2NameStr : string; // returns the selected rig name
begin
  Result := Rig2Combo.Items[Settings._rig2name];
end;

function TOptions.GetAge(aQSO : TQSO) : string;
var str : string;
    i : integer;
begin
  Result := '??';
  if aQSO.QSO.Operator = '' then
    Result := Settings._age
  else
    for i := 0 to OpList.Count - 1 do
      begin
        if TrimRight(Copy(OpList.Strings[i],1,20)) = aQSO.QSO.Operator then
          begin
            str := OpList.Strings[i];
            if length(str) <= 20 then
              exit;
            System.Delete(str,1,20);
            str := TrimLeft(TrimRight(str));
            Result := str;
          end;
      end;
end;

procedure TOptions.SetOpPower(var aQSO : TQSO);
var str : string;
    i : integer;
    P : Char;
begin
  for i := 0 to OpList.Count - 1 do
    begin
      if TrimRight(Copy(OpList.Strings[i],1,20)) = aQSO.QSO.Operator then
        begin
          str := OpList.Strings[i];
          if length(str) <= 20 then
            exit;
          System.Delete(str,1,20);
          if OldBandOrd(aQSO.QSO.Band)+1 <= length(str) then
            P := str[OldBandOrd(aQSO.QSO.Band)+1]
          else
            P := UpCase(str[1]);
          case P of
            'P' : aQSO.QSO.Power := pwrP;
            'L' : aQSO.QSO.Power := pwrL;
            'M' : aQSO.QSO.Power := pwrM;
            'H' : aQSO.QSO.Power := pwrH;
          end;
        end;
    end;
end;

procedure TOptions.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TOptions.SetMyCall(s : string);
begin
  Settings._mycall := s;
end;

function TOptions.MyCall : shortstring;
begin
  Result := Settings._mycall;
end;

procedure TOptions.SetTXNr(i : byte);
begin
  Settings._txnr := i;
end;

procedure TOptions.SetScoreCoeff(E : Extended);
begin
  Settings._scorecoeff := E;
  TQSO(Log.List[0]).QSO.RSTRcvd := Trunc(E*100);
end;

function TOptions.GetTXNr : byte;
begin
  Result := Settings._txnr;
end;

procedure TOptions.SetTonePitch(i : integer);
begin
  Settings.CW._tonepitch := i;
  BGK32LIB.SetPitch(i);
end;

procedure TOptions.SetCQMax(i : integer);
begin
  Settings.CW._cqmax := i;
  BGK32LIB.SetLoopMax(i);
end;

procedure TOptions.SetCQRepeat(r : double);
begin
  Settings.CW._cqrepeat := r;
  BGK32LIB.SetLoopTime(r);
end;

procedure TOptions.SetSendFreq(r : double);
begin
  Settings._sendfreq := r;
  RigControl.Timer1.Interval := Trunc(r*60000);
  RigControl.Timer1.Enabled := False;
  if r = 0 then
    exit;
  if Settings._rig1port <> 0 then
    if Settings._zlinkport <> 0 then
      if Settings._rig1name <> 0 then
        RigControl.Timer1.Enabled := True;
end;

function TOptions.CWMessage(bank, i : integer) : shortstring;
begin
  Result := Settings.CW.CWStrBank[bank, i];
end;

procedure TOptions.SetSpeed(i : integer);
begin
  if i in [0..60] then
    Settings.CW._speed := i;
  BGK32LIB.SetCWSpeed(Settings.CW._speed);
end;

procedure TOptions.SetWeight(i : integer);
begin
  if i in [0..100] then
    Settings.CW._weight := i;
  BGK32LIB.SetWeight(Settings.CW._weight);
end;

procedure TOptions.SetSideTone(boo : boolean);
begin
  BGK32LIB.SetSideTone(boo);
  Settings.CW._sidetone := boo;
end;

function TOptions.FIFO : boolean;
begin
  Result := Settings.CW._FIFO;
end;

function TOptions.Speed : integer;
begin
  Result := Settings.CW._speed;
end;

function TOptions.SideTone : boolean;
begin
  Result := Settings.CW._sidetone;
end;

function TOptions.MultiOp : integer;
begin
  Result := Settings._multiop;
end;

function TOptions.Band : integer;
begin
  Result := Settings._band;
end;

function TOptions.Mode : integer;
begin
  Result := Settings._mode;
end;

function TOptions.ContestMenuNo : integer;
begin
  Result := Settings._contestmenuno;
end;

procedure TOptions.SetMultiOp(i : integer);
begin
  Settings._multiop := i;
  zLogGlobal.OperatorCategory := i;
end;

procedure TOptions.SetBand(b : integer);
var BB : TBand;
begin
  Settings._band := b;
  if b > 0 then
    begin
      Main.CurrentQSO.QSO.Band := TBand(b-1);
      MainForm.BandEdit.Text := Main.CurrentQSO.BandStr;
      for BB := b19 to HiBand do
        MainForm.BandMenu.Items[ord(BB)].Enabled := False;
      MainForm.BandMenu.Items[b-1].Enabled := TRUE;
    end
  else
    begin
      for BB := b19 to HiBand do
        MainForm.BandMenu.Items[ord(BB)].Enabled := True;
    end;
end;

procedure TOptions.SetMode(m : integer);
begin
  Settings._mode := m;
end;

procedure TOptions.SetPaddleReverse(boo : boolean);
begin
  Settings.CW._paddlereverse := boo;
  BGK32LIB.ReversePaddle(boo);
end;

procedure TOptions.ReversePaddle;
begin
  SetPaddleReverse(not(Settings.CW._paddlereverse));
end;

procedure TOptions.SetCurrentContestNo(i : integer);
begin
  Settings._contestmenuno := i;
end;

procedure TOptions.SetFIFO(boo : boolean);
begin
  Settings.CW._FIFO := boo;
end;

procedure TOptions.MultiOpRadioBtnClick(Sender: TObject);
begin
  OpListBox.Enabled := True;
end;

procedure TOptions.SingleOpRadioBtnClick(Sender: TObject);
begin
  OpListBox.Enabled := False;
end;

procedure TOptions.SetPaddle(boo : boolean);
begin
  Settings.CW._paddle := boo;
end;

procedure TOptions.SaveCurrentSettings;
var i : integer;
    P : PChar;
begin
  P := StrAlloc(256);



  Ini.SetBoolean('Preferences', 'SaveWhenNoCW', Settings._savewhennocw);
  Ini.SetBoolean('Preferences', 'MultiStationWarning', Settings._multistationwarning);
  Ini.SetBoolean('Preferences', 'JMode', Settings._jmode);
  Ini.SetBoolean('Preferences', 'MoveToMemoWithSpace', Settings._movetomemo);
  Ini.SetBoolean('Preferences', 'AutoEnterSuper', Settings._entersuperexchange);

  Ini.SetInteger('Misc', 'SearchAfter', Settings._searchafter);

  Ini.SetInteger('Misc', 'MaxSuperHit', Settings._maxsuperhit);
  Ini.SetInteger('Misc', 'BandScopeExpire', Settings._bsexpire);
  Ini.SetInteger('Misc', 'SpotExpire', Settings._spotexpire);
  Ini.SetBoolean('Misc', 'UpdateUsingThread', Settings._renewbythread);
  Ini.SetBoolean('Misc', 'DisplayDatePartialCheck', Settings._displaydatepartialcheck);

  Ini.SetInteger('Rig', 'BandDataMode', Settings._banddatamode);
  Ini.SetBoolean('Rig', 'DontAllowSameBand', Settings._dontallowsameband);
  Ini.SetBoolean('Rig', 'AutoBandMap', Settings._autobandmap);
  Ini.SetBoolean('Rig', 'UseAFSK', Settings._AFSK);

  Ini.SetBoolean('Profiles', 'Active1.9MHz', Settings._activebands[b19]);
  Ini.SetBoolean('Profiles', 'Active3.5MHz', Settings._activebands[b35]);
  Ini.SetBoolean('Profiles', 'Active7MHz', Settings._activebands[b7]);
  Ini.SetBoolean('Profiles', 'Active10MHz', Settings._activebands[b10]);
  Ini.SetBoolean('Profiles', 'Active14MHz', Settings._activebands[b14]);
  Ini.SetBoolean('Profiles', 'Active18MHz', Settings._activebands[b18]);
  Ini.SetBoolean('Profiles', 'Active21MHz', Settings._activebands[b21]);
  Ini.SetBoolean('Profiles', 'Active24MHz', Settings._activebands[b24]);
  Ini.SetBoolean('Profiles', 'Active28MHz', Settings._activebands[b28]);
  Ini.SetBoolean('Profiles', 'Active50MHz', Settings._activebands[b50]);
  Ini.SetBoolean('Profiles', 'Active144MHz', Settings._activebands[b144]);
  Ini.SetBoolean('Profiles', 'Active430MHz', Settings._activebands[b430]);
  Ini.SetBoolean('Profiles', 'Active1200MHz', Settings._activebands[b1200]);
  Ini.SetBoolean('Profiles', 'Active2400MHz', Settings._activebands[b2400]);
  Ini.SetBoolean('Profiles', 'Active5600MHz', Settings._activebands[b5600]);
  Ini.SetBoolean('Profiles', 'Active10GHz', Settings._activebands[b10g]);

  Ini.SetString('Preferences', 'BackUpPath', Settings._backuppath);
  Ini.SetString('Preferences', 'CFGDATPath', Settings._cfgdatpath);
  Ini.SetString('Preferences', 'LogsPath', Settings._logspath);


  Ini.SetInteger('Preferences', 'SaveEvery', Settings._saveevery);
  Ini.SetBoolean('Preferences', 'AllowDupe', Settings._allowdupe);
  Ini.SetBoolean('Preferences', 'CountDown', Settings._countdown);
  Ini.SetBoolean('Preferences', 'QSYCount', Settings._qsycount);
  Ini.SetBoolean('Categories', 'MultiStn', Settings._multistation);
  Ini.SetInteger('Categories', 'Operator2', Settings._multiop);
  Ini.SetInteger('Categories', 'Band', Settings._band);
  Ini.SetInteger('Categories', 'Contest', Settings._contestmenuno);
  Ini.SetInteger('Categories', 'Mode', Settings._mode);
  Ini.SetInteger('Categories', 'TXNumber', Settings._txnr);
  Ini.SetString('Categories','MyCall', Settings._mycall);

  Ini.SetString('Profiles', 'Province/State', Settings._prov);
  Ini.SetString('Profiles', 'City', Settings._city);
  Ini.SetString('Profiles', 'CQZone', Settings._cqzone);
  Ini.SetString('Profiles', 'IARUZone', Settings._iaruzone);

{  Ini.SetString('Profiles', 'CQCountry', Settings._cqcountry);
  Ini.SetString('Profiles', 'CQZone', Settings._cqzone);
  Ini.SetString('Profiles', 'DXCCCountry', Settings._dxcccountry);
  Ini.SetString('Profiles', 'IARUZone', Settings._iaruzone);
  Ini.SetString('Profiles', 'Continent', Settings._continent); }

  Ini.SetInteger('CW','Speed',Settings.CW._speed);
  Ini.SetInteger('CW','FixedSpeed',Settings.CW._fixwpm);
  Ini.SetInteger('CW','Weight',Settings.CW._weight);
  Ini.SetInteger('CW','CQMax',Settings.CW._cqmax);
  Ini.SetInteger('CW','Pitch',Settings.CW._tonepitch);
  Ini.SetBoolean('CW','PaddleReverse',Settings.CW._paddlereverse);

  Ini.SetBoolean('CW','PaddleEnabled',Settings.CW._paddle);

  Ini.SetBoolean('CW','SideTone',Settings.CW._sidetone);
  Ini.SetFloat('CW','CQRepeat',Settings.CW._cqrepeat);
  Ini.SetFloat('Rig','SendFreq',Settings._sendfreq);
  Ini.SetBoolean('Rig', 'RecordFreqInMemo', Settings._recrigfreq);
  Ini.SetBoolean('CW','FIFO',Settings.CW._FIFO);
  Ini.SetBoolean('CW','CQSP',Settings._switchcqsp);
  Ini.SetString('CW','Zero',Settings.CW._zero);
  Ini.SetString('CW','One',Settings.CW._one);
  Ini.SetString('CW','Nine',Settings.CW._nine);
  for i := 1 to maxstr do
    begin
      StrPCopy(P, 'F'+IntToStr(i));
      Ini.SetString('CW',P, Settings.CW.CWStrBank[1,i]);
    end;
  for i := 1 to maxstr do
    begin
      StrPCopy(P, 'F'+IntToStr(i)+'B');
      Ini.SetString('CW',P, Settings.CW.CWStrBank[2,i]);
    end;
  for i := 1 to maxstr do
    begin
      StrPCopy(P, 'F'+IntToStr(i));
      Ini.SetString('RTTY',P, Settings.CW.CWStrBank[3,i]);
    end;
  for i := 11 to 12 do
    begin
      StrPCopy(P, 'F'+IntToStr(i));
      Ini.SetString('CW',P, Settings.CW.CWStrBank[1,i]);
    end;
  for i := 11 to 12 do
    begin
      StrPCopy(P, 'F'+IntToStr(i)+'B');
      Ini.SetString('CW',P, Settings.CW.CWStrBank[2,i]);
    end;
  for i := 11 to 12 do
    begin
      StrPCopy(P, 'F'+IntToStr(i));
      Ini.SetString('RTTY',P, Settings.CW.CWStrBank[3,i]);
    end;
  Ini.SetString('CW','CQ2',Settings.CW.CQStrBank[1]);
  Ini.SetString('CW','CQ3',Settings.CW.CQStrBank[2]);

  for i := 1 to maxstr do
    begin
      StrPCopy(P, 'F'+IntToStr(i));
      Ini.SetString('Voice',P, Settings._soundfiles[i]);
    end;
  Ini.SetString('Voice','CQ2', Settings._soundfiles[9]);
  Ini.SetString('Voice','CQ3', Settings._soundfiles[10]);

  for i := 1 to maxstr do
    begin
      StrPCopy(P, 'F'+IntToStr(i)+'_Comment');
      Ini.SetString('Voice',P, Settings._soundcomments[i]);
    end;
  Ini.SetString('Voice','CQ2_Comment', Settings._soundcomments[9]);
  Ini.SetString('Voice','CQ3_Comment', Settings._soundcomments[9]);

  Ini.SetInteger('Hardware','PacketCluster',Settings._clusterport);
  Ini.SetInteger('Hardware','Rig',Settings._rig1port);
  Ini.SetBoolean('Hardware','RitClear', Settings._ritclear);
  Ini.SetInteger('Hardware', 'RigName', Settings._rig1name);

  Ini.SetBoolean('Hardware', 'Transverter1', Settings._transverter1);
  Ini.SetInteger('Hardware', 'Transverter1Offset', Settings._transverteroffset1);
  Ini.SetBoolean('Hardware', 'Transverter2', Settings._transverter2);
  Ini.SetInteger('Hardware', 'Transverter2Offset', Settings._transverteroffset2);

  Ini.SetInteger('Hardware','Rig2',Settings._rig2port);
  Ini.SetInteger('Hardware', 'RigName2', Settings._rig2name);

  Ini.SetInteger('Hardware','Z-Link',Settings._zlinkport);

  Ini.SetInteger('Hardware','PacketClusterBaud',Settings._clusterbaud);
  Ini.SetInteger('Hardware','RigBaud',Settings._rigbaud);
  Ini.SetInteger('Hardware','IcomBaudRate',Settings._icombaudrate);

  Ini.SetInteger('Hardware','Z-LinkBaud',Settings._zlinkbaud);

  Ini.SetBoolean('Hardware','PTTEnabled',Settings._pttenabled);
  Ini.SetInteger('Hardware','PTTBefore',Settings._pttbefore);
  Ini.SetInteger('Hardware','PTTAfter',Settings._pttafter);

  Ini.SetString('PacketCluster','TELNEThost', Settings._clusterhost);
  Ini.SetInteger('PacketCluster','TELNETport', Settings._clustertelnetport);
  Ini.SetInteger('PacketCluster','TELNETlinebreak', Settings._clusterlinebreakTELNET);
  Ini.SetBoolean('PacketCluster','TELNETlocalecho',Settings._clusterlocalechoTELNET);
  Ini.SetInteger('PacketCluster','COMlinebreak', Settings._clusterlinebreakCOM);
  Ini.SetBoolean('PacketCluster','COMlocalecho',Settings._clusterlocalechoCOM);

  Ini.SetString('Z-Link','TELNEThost', Settings._zlinkhost);
  Ini.SetInteger('Z-Link','TELNETlinebreak', Settings._zlinklinebreakTELNET);
  Ini.SetBoolean('Z-Link','TELNETlocalecho',Settings._zlinklocalechoTELNET);
  Ini.SetInteger('Z-Link','COMlinebreak', Settings._zlinklinebreakCOM);
  Ini.SetBoolean('Z-Link','COMlocalecho',Settings._zlinklocalechoCOM);

  Ini.SetBoolean('Z-Link','SyncSerial',Settings._syncserial);

  Ini.SetInteger('Hardware','UseCWPort',Settings._specificcwport);
  Ini.SetInteger('Hardware','CWLPTPort',Settings._lptnr);
  //Ini.SetBoolean('Hardware','CWUseData',Settings._usedata);
  Ini.SetBoolean('Hardware','CWInvLogic', Settings._reverselogic);
  Ini.SetBoolean('Hardware','RigInvLogic', Settings._rigreverse);
  Ini.SetBoolean('Hardware','PTTInvLogic', Settings._pttreverse);

  Ini.SetInteger('Preferences','FontSize', Settings._mainfontsize);
  Ini.SetInteger('Preferences','RowHeight', Settings._mainrowheight);

  StrDispose(P);

  OpList.SaveToFile(MAINPATH+'ZLOG.OP');

end;

procedure TOptions.LoadIniFileBS;
var B : TBand;
    M : TMode;
begin
  Settings._bsminfreqarray[b19, mCW]  := Ini.GetInteger('BandScope','1.9MHzCWmin', 1800);
  Settings._bsminfreqarray[b19, mSSB] := Ini.GetInteger('BandScope','1.9MHzPHmin', 1800);
  Settings._bsmaxfreqarray[b19, mCW]  := Ini.GetInteger('BandScope','1.9MHzCWmax', 1950);
  Settings._bsmaxfreqarray[b19, mSSB] := Ini.GetInteger('BandScope','1.9MHzPHmax', 1950);
  Settings._bsminfreqarray[b35, mCW]  := Ini.GetInteger('BandScope','3.5MHzCWmin', 3500);
  Settings._bsminfreqarray[b35, mSSB] := Ini.GetInteger('BandScope','3.5MHzPHmin', 3500);
  Settings._bsmaxfreqarray[b35, mCW]  := Ini.GetInteger('BandScope','3.5MHzCWmax', 3800);
  Settings._bsmaxfreqarray[b35, mSSB] := Ini.GetInteger('BandScope','3.5MHzPHmax', 3800);
  Settings._bsminfreqarray[b7,  mCW]  := Ini.GetInteger('BandScope','7MHzCWmin', 7000);
  Settings._bsminfreqarray[b7,  mSSB] := Ini.GetInteger('BandScope','7MHzPHmin', 7000);
  Settings._bsmaxfreqarray[b7,  mCW]  := Ini.GetInteger('BandScope','7MHzCWmax', 7200);
  Settings._bsmaxfreqarray[b7,  mSSB] := Ini.GetInteger('BandScope','7MHzPHmax', 7200);
  Settings._bsminfreqarray[b10, mCW]  := Ini.GetInteger('BandScope','10MHzCWmin', 10100);
  Settings._bsminfreqarray[b10, mSSB] := Ini.GetInteger('BandScope','10MHzPHmin', 10100);
  Settings._bsmaxfreqarray[b10, mCW]  := Ini.GetInteger('BandScope','10MHzCWmax', 10150);
  Settings._bsmaxfreqarray[b10, mSSB] := Ini.GetInteger('BandScope','10MHzPHmax', 10150);
  Settings._bsminfreqarray[b14, mCW]  := Ini.GetInteger('BandScope','14MHzCWmin', 14000);
  Settings._bsminfreqarray[b14, mSSB] := Ini.GetInteger('BandScope','14MHzPHmin', 14000);
  Settings._bsmaxfreqarray[b14, mCW]  := Ini.GetInteger('BandScope','14MHzCWmax', 14350);
  Settings._bsmaxfreqarray[b14, mSSB] := Ini.GetInteger('BandScope','14MHzPHmax', 14350);
  Settings._bsminfreqarray[b18, mCW]  := Ini.GetInteger('BandScope','18MHzCWmin', 18060);
  Settings._bsminfreqarray[b18, mSSB] := Ini.GetInteger('BandScope','18MHzPHmin', 18060);
  Settings._bsmaxfreqarray[b18, mCW]  := Ini.GetInteger('BandScope','18MHzCWmax', 18170);
  Settings._bsmaxfreqarray[b18, mSSB] := Ini.GetInteger('BandScope','18MHzPHmax', 18170);
  Settings._bsminfreqarray[b21, mCW]  := Ini.GetInteger('BandScope','21MHzCWmin', 21000);
  Settings._bsminfreqarray[b21, mSSB] := Ini.GetInteger('BandScope','21MHzPHmin', 21000);
  Settings._bsmaxfreqarray[b21, mCW]  := Ini.GetInteger('BandScope','21MHzCWmax', 21450);
  Settings._bsmaxfreqarray[b21, mSSB] := Ini.GetInteger('BandScope','21MHzPHmax', 21450);
  Settings._bsminfreqarray[b24, mCW]  := Ini.GetInteger('BandScope','24MHzCWmin', 24890);
  Settings._bsminfreqarray[b24, mSSB] := Ini.GetInteger('BandScope','24MHzPHmin', 24890);
  Settings._bsmaxfreqarray[b24, mCW]  := Ini.GetInteger('BandScope','24MHzCWmax', 24990);
  Settings._bsmaxfreqarray[b24, mSSB] := Ini.GetInteger('BandScope','24MHzPHmax', 24990);
  Settings._bsminfreqarray[b28, mCW]  := Ini.GetInteger('BandScope','28MHzCWmin', 28000);
  Settings._bsminfreqarray[b28, mSSB] := Ini.GetInteger('BandScope','28MHzPHmin', 28000);
  Settings._bsmaxfreqarray[b28, mCW]  := Ini.GetInteger('BandScope','28MHzCWmax', 28500);
  Settings._bsmaxfreqarray[b28, mSSB] := Ini.GetInteger('BandScope','28MHzPHmax', 28500);

  Settings._bsminfreqarray[b50, mCW]  := Ini.GetInteger('BandScope','50MHzCWmin', 50000);
  Settings._bsminfreqarray[b50, mSSB] := Ini.GetInteger('BandScope','50MHzPHmin', 50000);
  Settings._bsmaxfreqarray[b50, mCW]  := Ini.GetInteger('BandScope','50MHzCWmax', 51000);
  Settings._bsmaxfreqarray[b50, mSSB] := Ini.GetInteger('BandScope','50MHzPHmax', 51000);
  Settings._bsminfreqarray[b144, mCW]  := Ini.GetInteger('BandScope','144MHzCWmin', 144000);
  Settings._bsminfreqarray[b144, mSSB] := Ini.GetInteger('BandScope','144MHzPHmin', 144600);
  Settings._bsmaxfreqarray[b144, mCW]  := Ini.GetInteger('BandScope','144MHzCWmax', 145600);
  Settings._bsmaxfreqarray[b144, mSSB] := Ini.GetInteger('BandScope','144MHzPHmax', 145600);
  Settings._bsminfreqarray[b430, mCW]  := Ini.GetInteger('BandScope','430MHzCWmin', 430000);
  Settings._bsminfreqarray[b430, mSSB] := Ini.GetInteger('BandScope','430MHzPHmin', 430000);
  Settings._bsmaxfreqarray[b430, mCW]  := Ini.GetInteger('BandScope','430MHzCWmax', 434000);
  Settings._bsmaxfreqarray[b430, mSSB] := Ini.GetInteger('BandScope','430MHzPHmax', 434000);

  Settings._bsminfreqarray[b1200, mCW]  := Ini.GetInteger('BandScope','1200MHzCWmin', 1294000);
  Settings._bsminfreqarray[b1200, mSSB] := Ini.GetInteger('BandScope','1200MHzPHmin', 1294600);
  Settings._bsmaxfreqarray[b1200, mCW]  := Ini.GetInteger('BandScope','1200MHzCWmax', 1294500);
  Settings._bsmaxfreqarray[b1200, mSSB] := Ini.GetInteger('BandScope','1200MHzPHmax', 1295000);
  Settings._bsminfreqarray[b2400, mCW]  := Ini.GetInteger('BandScope','2400MHzCWmin', 2400000);
  Settings._bsminfreqarray[b2400, mSSB] := Ini.GetInteger('BandScope','2400MHzPHmin', 2400000);
  Settings._bsmaxfreqarray[b2400, mCW]  := Ini.GetInteger('BandScope','2400MHzCWmax', 2410000);
  Settings._bsmaxfreqarray[b2400, mSSB] := Ini.GetInteger('BandScope','2400MHzPHmax', 2410000);
  Settings._bsminfreqarray[b5600, mCW]  := Ini.GetInteger('BandScope','5600MHzCWmin', 5600000);
  Settings._bsminfreqarray[b5600, mSSB] := Ini.GetInteger('BandScope','5600MHzPHmin', 5600000);
  Settings._bsmaxfreqarray[b5600, mCW]  := Ini.GetInteger('BandScope','5600MHzCWmax', 5610000);
  Settings._bsmaxfreqarray[b5600, mSSB] := Ini.GetInteger('BandScope','5600MHzPHmax', 5610000);

  for B := b19 to HiBand do
    for M := mFM to mOther do
      begin
        Settings._bsminfreqarray[B, M] := Settings._bsminfreqarray[B, mSSB];
        Settings._bsmaxfreqarray[B, M] := Settings._bsmaxfreqarray[B, mSSB];
      end;
end;

procedure TOptions.LoadIniFile;
var i : integer;
    B : TBand;
    P : PChar;
    S : string[255];
begin
  P := StrAlloc(256);

  LoadIniFileBS;

  Settings._pcname := Ini.GetString('Z-Link', 'PCName', '');
  Settings._multistationwarning := Ini.GetBoolean('Preferences', 'MultiStationWarning', True);

  Settings._recrigfreq := Ini.GetBoolean('Rig', 'RecordFreqInMemo', False);
  Settings._bsexpire := Ini.GetInteger('Misc', 'BandScopeExpire', 60);
  Settings._spotexpire := Ini.GetInteger('Misc', 'SpotExpire', 90);

  Settings._savewhennocw := Ini.GetBoolean('Preferences', 'SaveWhenNoCW', False);
  Settings._jmode := Ini.GetBoolean('Preferences', 'JMode', False);
  Settings._movetomemo := Ini.GetBoolean('Preferences', 'MoveToMemoWithSpace', False);

  Settings._searchafter := Ini.GetInteger('Misc', 'SearchAfter', 0);
  Settings._maxsuperhit := Ini.GetInteger('Misc', 'MaxSuperHit', 100);
  Settings._renewbythread := Ini.GetBoolean('Misc', 'UpdateUsingThread', False);
  Settings._displaydatepartialcheck := Ini.GetBoolean('Misc', 'DisplayDatePartialCheck', False);

  Settings._banddatamode := Ini.GetInteger('Rig', 'BandDataMode', 1);
  Settings._dontallowsameband := Ini.GetBoolean('Rig', 'DontAllowSameBand', False);
  Settings._autobandmap := Ini.GetBoolean('Rig', 'AutoBandMap', False);
  Settings._AFSK := Ini.GetBoolean('Rig', 'UseAFSK', False);

  Settings._BandData[b19] := Ini.GetInteger('Hardware','BandData1.9MHz', 0);
  Settings._BandData[b35] := Ini.GetInteger('Hardware','BandData3.5MHz', 1);
  Settings._BandData[b7] := Ini.GetInteger('Hardware','BandData7MHz', 2);
  Settings._BandData[b10] := Ini.GetInteger('Hardware','BandData10MHz', 3);
  Settings._BandData[b14] := Ini.GetInteger('Hardware','BandData14MHz', 4);
  Settings._BandData[b18] := Ini.GetInteger('Hardware','BandData18MHz', 5);
  Settings._BandData[b21] := Ini.GetInteger('Hardware','BandData21MHz', 6);
  Settings._BandData[b24] := Ini.GetInteger('Hardware','BandData24MHz', 7);
  Settings._BandData[b28] := Ini.GetInteger('Hardware','BandData28MHz', 8);
  Settings._BandData[b50] := Ini.GetInteger('Hardware','BandData50MHz', 9);
  Settings._BandData[b144] := Ini.GetInteger('Hardware','BandData144MHz', 10);
  Settings._BandData[b430] := Ini.GetInteger('Hardware','BandData430MHz', 11);
  Settings._BandData[b1200] := Ini.GetInteger('Hardware','BandData1200MHz', 12);
  Settings._BandData[b2400] := Ini.GetInteger('Hardware','BandData2400MHz', 13);
  Settings._BandData[b5600] := Ini.GetInteger('Hardware','BandData5600MHz', 14);
  Settings._BandData[b10g] := Ini.GetInteger('Hardware','BandData10GHz', 15);


  Settings._activebands[b19] := Ini.GetBoolean('Profiles', 'Active1.9MHz', True);
  Settings._activebands[b35] := Ini.GetBoolean('Profiles', 'Active3.5MHz', True);
  Settings._activebands[b7] := Ini.GetBoolean('Profiles', 'Active7MHz', True);
  Settings._activebands[b10] := Ini.GetBoolean('Profiles', 'Active10MHz', True);
  Settings._activebands[b14] := Ini.GetBoolean('Profiles', 'Active14MHz', True);
  Settings._activebands[b18] := Ini.GetBoolean('Profiles', 'Active18MHz', True);
  Settings._activebands[b21] := Ini.GetBoolean('Profiles', 'Active21MHz', True);
  Settings._activebands[b24] := Ini.GetBoolean('Profiles', 'Active24MHz', True);
  Settings._activebands[b28] := Ini.GetBoolean('Profiles', 'Active28MHz', True);
  Settings._activebands[b50] := Ini.GetBoolean('Profiles', 'Active50MHz', True);
  Settings._activebands[b144] := Ini.GetBoolean('Profiles', 'Active144MHz', True);
  Settings._activebands[b430] := Ini.GetBoolean('Profiles', 'Active430MHz', True);
  Settings._activebands[b1200] := Ini.GetBoolean('Profiles', 'Active1200MHz', True);
  Settings._activebands[b2400] := Ini.GetBoolean('Profiles', 'Active2400MHz', True);
  Settings._activebands[b5600] := Ini.GetBoolean('Profiles', 'Active5600MHz', True);
  Settings._activebands[b10g] := Ini.GetBoolean('Profiles', 'Active10GHz', True);

  S := Ini.GetString('Profiles', 'Power', '');
  B := b19;
  if Length(S) > 13 then
    System.Delete(S, 14, 255);
  for i := 1 to length(S) do
    begin
      case UpCase(S[i]) of
        'P' :  CurrentPower[B] :=  pwrP;
        'L' :  CurrentPower[B] :=  pwrL;
        'M' :  CurrentPower[B] :=  pwrM;
        'H' :  CurrentPower[B] :=  pwrH;
      end;
      repeat
        inc(B);
      until NotWARC(B);
    end;

  Settings._multiop := Ini.GetInteger('Categories','Operator2', 0);
  Settings._multistation := Ini.GetBoolean('Categories','MultiStn',False);
  Settings._band := Ini.GetInteger('Categories', 'Band', 0);
  Settings._mode := Ini.GetInteger('Categories', 'Mode', 0);
  Settings._txnr := Ini.GetInteger('Categories', 'TXNumber', 0);
  Settings._contestmenuno := Ini.GetInteger('Categories', 'Contest', 1);
  Settings._mycall := Ini.GetString('Categories', 'MyCall', 'Your call sign');

  Settings._backuppath := Ini.GetString('Preferences', 'BackUpPath', '');
  Settings._cfgdatpath := Ini.GetString('Preferences', 'CFGDATPath', '');
  Settings._logspath := Ini.GetString('Preferences', 'LogsPath', '');


  Settings._allowdupe := Ini.GetBoolean('Preferences', 'AllowDupe', False);
  Settings._saveevery := Ini.GetInteger('Preferences', 'SaveEvery', 3);


  Settings._entersuperexchange := Ini.GetBoolean('Preferences', 'AutoEnterSuper', False);

  Settings._countdown := Ini.GetBoolean('Preferences', 'CountDown', False);
  Settings._qsycount := Ini.GetBoolean('Preferences', 'QSYCount', False);

  Settings._prov := Ini.GetString('Profiles', 'Province/State', '');
  Settings._city := Ini.GetString('Profiles', 'City', '');
  Settings._cqzone := Ini.GetString('Profiles', 'CQZone', '');
  Settings._iaruzone := Ini.GetString('Profiles', 'IARUZone', '');

  Settings._clusterport := Ini.GetInteger('Hardware','PacketCluster', 0);

  Settings._rig1port := Ini.GetInteger('Hardware','Rig', 0);
  Settings._ritclear := Ini.GetBoolean('Hardware','RitClear',False);
  Settings._rig1name := Ini.GetInteger('Hardware','RigName', 0);

  Settings._rig2port := Ini.GetInteger('Hardware','Rig2', 0);
  Settings._rig2name := Ini.GetInteger('Hardware','RigName2', 0);

  Settings._zlinkport := Ini.GetInteger('Hardware','Z-Link', 0);

  Settings._clusterbaud := Ini.GetInteger('Hardware','PacketClusterBaud', 6);
  Settings._rigbaud := Ini.GetInteger('Hardware','RigBaud', 6);
  Settings._icombaudrate := Ini.GetInteger('Hardware', 'IcomBaudRate', 1);

  Settings._zlinkbaud := Ini.GetInteger('Hardware','Z-LinkBaud', 6);

  Settings._pttenabled := Ini.GetBoolean('Hardware','PTTEnabled', False);
  Settings._pttbefore := Ini.GetInteger('Hardware','PTTBefore', 25);
  Settings._pttafter := Ini.GetInteger('Hardware','PTTAfter', 0);

  Settings._clusterhost := Ini.GetString('PacketCluster','TELNEThost', '');
  Settings._clustertelnetport := Ini.GetInteger('PacketCluster','TELNETport',23);

  Settings._clusterlinebreakTELNET := Ini.GetInteger('PacketCluster','TELNETlinebreak',0);
  Settings._clusterlocalechoTELNET := Ini.GetBoolean('PacketCluster','TELNETlocalecho',False);
  Settings._clusterlinebreakCOM := Ini.GetInteger('PacketCluster','COMlinebreak',0);
  Settings._clusterlocalechoCOM := Ini.GetBoolean('PacketCluster','COMlocalecho',False);

  Settings._zlinkhost := Ini.GetString('Z-Link','TELNEThost', '');
  Settings._zlinklinebreakTELNET := Ini.GetInteger('Z-Link','TELNETlinebreak',0);
  Settings._zlinklocalechoTELNET := Ini.GetBoolean('Z-Link','TELNETlocalecho',False);
  Settings._zlinklinebreakCOM := Ini.GetInteger('Z-Link','COMlinebreak',0);
  Settings._zlinklocalechoCOM := Ini.GetBoolean('Z-Link','COMlocalecho',False);

  Settings._syncserial := Ini.GetBoolean('Z-Link','SyncSerial',False);

  Settings.CW._interval := Ini.GetInteger('CW','Interval',1);
  Settings.CW._speed := Ini.GetInteger('CW','Speed',25);
  Settings.CW._weight := Ini.GetInteger('CW','Weight',50);
  Settings.CW._cqmax := Ini.GetInteger('CW','CQMax',15);
  Settings.CW._tonepitch := Ini.GetInteger('CW','Pitch',800);
  Settings.CW._paddlereverse := Ini.GetBoolean('CW','PaddleReverse',False);
  Settings.CW._paddle := Ini.GetBoolean('CW','PaddleEnabled',True);
  Settings.CW._FIFO := Ini.GetBoolean('CW','FIFO',True);
  Settings._switchcqsp := Ini.GetBoolean('CW','CQSP',False);
  Settings.CW._sidetone := Ini.GetBoolean('CW','SideTone',True);
  Settings.CW._cqrepeat := Ini.GetFloat('CW','CQRepeat',2.0);
  Settings._sendfreq := Ini.GetFloat('Rig','SendFreq', 1.0);
  S := Ini.GetString('CW', 'Zero', 'O');
  Settings.CW._zero := S[1];
  S := Ini.GetString('CW', 'One',  'A');
  Settings.CW._one  := S[1];
  S := Ini.GetString('CW', 'Nine', 'N');
  Settings.CW._nine := S[1];

  Settings.CW.CWStrBank[1,1] := Ini.GetString('CW','F1', 'CQ TEST $M $M TEST');
  Settings.CW.CWStrBank[1,2] := Ini.GetString('CW','F2', '$C 5NN$X');
  Settings.CW.CWStrBank[1,3] := Ini.GetString('CW','F3', 'TU $M TEST');
  Settings.CW.CWStrBank[1,4] := Ini.GetString('CW','F4', 'QSO B4 TU');
  Settings.CW.CWStrBank[1,5] := Ini.GetString('CW','F5', 'NR?');

  Settings.CW.CWStrBank[3,1] := Ini.GetString('RTTY','F1', 'CQ CQ CQ TEST $M $M $M TEST K');
  Settings.CW.CWStrBank[3,2] := Ini.GetString('RTTY','F2', '$C DE $M 599$X 599$X BK');
  Settings.CW.CWStrBank[3,3] := Ini.GetString('RTTY','F3', 'TU DE $M TEST');
  Settings.CW.CWStrBank[3,4] := Ini.GetString('RTTY','F4', 'QSO B4 TU');
  Settings.CW.CWStrBank[3,5] := Ini.GetString('RTTY','F5', 'NR? NR? AGN BK');

  Settings._transverter1 := Ini.GetBoolean('Hardware', 'Transverter1', False);
  Settings._transverteroffset1 := Ini.GetInteger('Hardware', 'Transverter1Offset',0);
  Settings._transverter2 := Ini.GetBoolean('Hardware', 'Transverter2', False);
  Settings._transverteroffset2 := Ini.GetInteger('Hardware', 'Transverter2Offset',0);

  for i := 6 to maxstr do
    begin
      StrPCopy(P, 'F'+IntToStr(i));
      Settings.CW.CWStrBank[1,i] := Ini.GetString('CW',P, '');
    end;

  for i := 6 to maxstr do
    begin
      StrPCopy(P, 'F'+IntToStr(i));
      Settings.CW.CWStrBank[3,i] := Ini.GetString('RTTY',P, '');
    end;

  for i := 1 to maxstr do
    begin
      StrPCopy(P, 'F'+IntToStr(i)+'B');
      Settings.CW.CWStrBank[2,i] := Ini.GetString('CW',P, '');
    end;

  for i := 11 to 12 do
    begin
      StrPCopy(P, 'F'+IntToStr(i));
      Settings.CW.CWStrBank[1,i] := Ini.GetString('CW',P, '');
    end;

  for i := 11 to 12 do
    begin
      StrPCopy(P, 'F'+IntToStr(i));
      Settings.CW.CWStrBank[3,i] := Ini.GetString('RTTY',P, '');
    end;

  for i := 11 to 12 do
    begin
      StrPCopy(P, 'F'+IntToStr(i)+'B');
      Settings.CW.CWStrBank[2,i] := Ini.GetString('CW',P, '');
    end;

  Settings.CW.CQStrBank[1] := Ini.GetString('CW','CQ2','');
  Settings.CW.CQStrBank[2] := Ini.GetString('CW','CQ3','');
  Settings.CW._fixwpm := Ini.GetInteger('CW', 'FixedSpeed', 20);

  for i := 1 to maxstr do
    begin
      StrPCopy(P, 'F'+IntToStr(i));
      Settings._soundfiles[i] := Ini.GetString('Voice',P, 'select');
    end;
  Settings._soundfiles[9] := Ini.GetString('Voice','CQ2', 'select');
  Settings._soundfiles[10] := Ini.GetString('Voice','CQ3', 'select');

  for i := 1 to maxstr do
    begin
      StrPCopy(P, 'F'+IntToStr(i)+'_Comment');
      Settings._soundcomments[i] := Ini.GetString('Voice',P, '');
    end;
  Settings._soundcomments[9] := Ini.GetString('Voice','CQ2_Comment', '');
  Settings._soundcomments[10] := Ini.GetString('Voice','CQ3_Comment', '');

  Settings._specificcwport := Ini.GetInteger('Hardware','UseCWPort',0{ $037A});
  Settings._lptnr  := Ini.GetInteger('Hardware','CWLPTPort', 1);
  //Settings._usedata := Ini.GetBoolean('Hardware','CWUseData',false);

  Settings._reverselogic := Ini.GetBoolean('Hardware', 'CWInvLogic', false);
  Settings._rigreverse := Ini.GetBoolean('Hardware','RigInvLogic', false);
  Settings._pttreverse := Ini.GetBoolean('Hardware','PTTInvLogic', false);

  Settings._mainfontsize := Ini.GetInteger('Preferences', 'FontSize',9);
  Settings._mainrowheight := Ini.GetInteger('Preferences', 'RowHeight',18);

  Settings.CW._spacefactor := Ini.GetInteger('CW','SpaceFactor',100);
  Settings.CW._eispacefactor := Ini.GetInteger('CW','EISpaceFactor',100);

  StrDispose(P);
end;

procedure TOptions.ImplementSettings(_OnCreate : boolean);
var M : TMenuItem;
    i, j : integer;
    B : TBand;
begin
  if _OnCreate = False then
    begin
      for B := b19 to HiBand do
        MainForm.BandMenu.Items[ord(B)].Enabled := Settings._activebands[B];
      if Settings._band > 0 then // single band
        SetBand(Settings._band); // resets the bandmenu.items.enabled for the single band entry
    end;
  if MyContest <> nil then
    Main.MyContest.SameExchange := Settings._sameexchange;

  RigControl.SetBandMask;
  //BGK32LIB.UpdateDataPort;

  if Settings._zlinkport in [1..6] then  // zlinkport rs232c
    begin
      //ZLinkForm.Transparent := True;
      // no rs232c anymore
    end;


  CommForm.EnableConnectButton(Settings._clusterport = 7);

  CommForm.ImplementOptions;
  ZLinkForm.ImplementOptions;

// ver 1,3
  //BGK32LIB.SetCWPortDirect(Settings._cwport);
  if Settings._lptnr in [1..LPTMAX] then
    begin
      RigControl.ZCom3.Disconnect;
      BGK32LIB.KeyingPort := tkpParallel;
      BGK32LIB.SetCWPortDirect(LPTport[Settings._lptnr]);
      if Settings._specificcwport > 0 then
        BGK32LIB.SetCWPortDirect(Settings._specificcwport);
      if Settings._reverselogic then
        BGK32LIB.ReverseLogicKeying(True);
      if Settings._rigreverse then
        BGK32LIB.ReverseRigOut(True);
      if Settings._pttreverse then
        BGK32LIB.ReversePTTOut(True);

      if Settings.CW._paddle then
        begin
          BGK32LIB.SetPaddlePortDirect(LPTport[Settings._lptnr]-1);
          if PaddleThread = nil then // ver 1.3
            PaddleThread := TPaddleThread.Create(False);
        end
      else
        begin
          if PaddleThread <> nil then
            PaddleThread.Terminate;
          BGK32LIB.SetPaddlePortDirect($00);
        end;

      BGK32LIB.SetPTTportDirect(LPTport[Settings._lptnr] - 2);
    end
  else //  Settings._lptnr <> parallel ports
    begin
      Case Settings._lptnr of
        11 : begin
               RigControl.SetSerialCWKeying(1);
               BGK32LIB.KeyingPort := tkpSerial1;
             end;
        12 : begin
               RigControl.SetSerialCWKeying(2);
               BGK32LIB.KeyingPort := tkpSerial2;
             end;
        21 : begin // usb
               BGK32LIB.KeyingPort := tkpUSB;
               (*                 ver 2.2a
               if Settings.CW._paddle then
                 begin
                   if PaddleThread = nil then
                   PaddleThread := TPaddleThread.Create(True);
                 end
               else
                 begin
                   if PaddleThread <> nil then
                     PaddleThread.Terminate;
                   BGK32LIB.SetPaddlePortDirect($00);
                 end;
                *)

               if Settings.CW._paddle then
                 begin
                   BGK32LIB.SetPaddlePortDirect($99);
                   if PaddleThread = nil then
                   PaddleThread := TPaddleThread.Create(True);
                 end
               else
                 begin
                   BGK32LIB.SetPaddlePortDirect($00);
                   if PaddleThread = nil then
                   PaddleThread := TPaddleThread.Create(True);
                 end;

             end;
      end;
    end;

  RigControl.ImplementOptions;
  BGK32LIB.SetPTTDelay(Settings._pttbefore, Settings._pttafter);
  BGK32LIB.SetPTT(Settings._pttenabled);

  //SetBand(Settings._band);
  SetMode(Settings._mode);
  SetPaddleReverse(Settings.CW._paddlereverse);
  SetSpeed(Settings.CW._speed);
  SetSideTone(Settings.CW._sidetone);
  SetWeight(Settings.CW._weight);
  SetCQMax(Settings.CW._cqmax);
  SetCQRepeat(Settings.CW._cqrepeat);
  SetSendFreq(Settings._sendfreq);
  SetTonePitch(Settings.CW._tonepitch);
  BGK32LIB.SetRandCQStr(SetStr(Settings.CW.CQStrBank[1], CurrentQSO),
                        SetStr(Settings.CW.CQStrBank[2], CurrentQSO));

  BGK32LIB.SetSpaceFactor(Settings.CW._spacefactor);
  BGK32LIB.SetEISpaceFactor(Settings.CW._eispacefactor);

  AllowDupe := Settings._allowdupe;

  if Settings._backuppath = '' then
    MainForm.BackUp1.Enabled := False
  else
    MainForm.BackUp1.Enabled := True;

  if Settings._multistation = True then
    Settings._txnr := 2;


  if not(_OnCreate) then
    begin
      j := MainForm.OpMenu.Items.Count;
      if j > 0 then
        for i := 1 to j do
          MainForm.OpMenu.Items.Delete(0);
      if OpList.Count > 0 then
        begin
          M := TMenuItem.Create(Self);
          M.Caption := 'Clear';
          M.OnClick := MainForm.OpMenuClick;
          MainForm.OpMenu.Items.Add(M);
          for i := 0 to OpList.Count-1 do
            begin
              M := TMenuItem.Create(Self);
              M.Caption := TrimRight(Copy(OpList.Strings[i], 1, 20));
              M.OnClick := MainForm.OpMenuClick;
              MainForm.OpMenu.Items.Add(M);
            end;
        end;
    end;
end;

procedure TOptions.RenewSettings;
var R : double;
    i,j : integer;
begin

  Settings._recrigfreq := cbRecordRigFreq.Checked;
  Settings._multistation := cbMultiStn.Checked;
  Settings._savewhennocw := cbSaveWhenNoCW.Checked;
  Settings._jmode := cbJMode.Checked;
  Settings._searchafter := rgSearchAfter.ItemIndex;
  Settings._renewbythread := cbUpdateThread.Checked;
  Settings._displaydatepartialcheck := cbDisplayDatePartialCheck.Checked;
  
  Settings._banddatamode := rgBandData.ItemIndex;
  Settings._AFSK := cbAFSK.Checked;
  Settings._maxsuperhit := spMaxSuperHit.Value;

  Settings._activebands[b19]  := act19.Checked;
  Settings._activebands[b35]  := act35.Checked;
  Settings._activebands[b7]   := act7.Checked;
  Settings._activebands[b10]  := act10.Checked;
  Settings._activebands[b14]  := act14.Checked;
  Settings._activebands[b18]  := act18.Checked;
  Settings._activebands[b21]  := act21.Checked;
  Settings._activebands[b24]  := act24.Checked;
  Settings._activebands[b28]  := act28.Checked;
  Settings._activebands[b50]  := act50.Checked;
  Settings._activebands[b144] := act144.Checked;
  Settings._activebands[b430] := act430.Checked;
  Settings._activebands[b1200]:= act1200.Checked;
  Settings._activebands[b2400]:= act2400.Checked;
  Settings._activebands[b5600]:= act5600.Checked;
  Settings._activebands[b10g] := act10g.Checked;

  OpList.Free;
  OpList := TStringList.Create;
  OpList.Assign(OpListBox.Items);

//  Settings._band := BandGroup.ItemIndex;
  case BandGroup.ItemIndex of
    0..3 : Settings._band := BandGroup.ItemIndex;
    4 : Settings._band := BandGroup.ItemIndex+1;
    5 : Settings._band := BandGroup.ItemIndex+2;
    6..13 : Settings._band := BandGroup.ItemIndex+3;
  end;



  Settings._mode := ModeGroup.ItemIndex;
  //Settings._multiop := MultiOpRadioBtn.Checked;

  Settings._prov := ProvEdit.Text;
  Settings._city := CityEdit.Text;
  Settings._cqzone := CQZoneEdit.Text;
  Settings._iaruzone := IARUZoneEdit.Text;

  {
  Settings.CW.CWStrBank[1,1] := Edit1.Text;
  Settings.CW.CWStrBank[1,2] := Edit2.Text;
  Settings.CW.CWStrBank[1,3] := Edit3.Text;
  Settings.CW.CWStrBank[1,4] := Edit4.Text;
  Settings.CW.CWStrBank[1,5] := Edit5.Text;
  Settings.CW.CWStrBank[1,6] := Edit6.Text;
  Settings.CW.CWStrBank[1,7] := Edit7.Text;
  Settings.CW.CWStrBank[1,8] := Edit8.Text;

  Settings.CW.CQStrBank[0] := Edit1.Text;
  }

  for i := 1 to maxbank do
    for j := 1 to maxstr do
      Settings.CW.CWStrBank[i,j] := TempCWStrBank[i,j];
  Settings.CW.CQStrBank[0] := TempCWStrBank[1,1];

  Settings.CW.CQStrBank[1] := Edit9.Text;
  Settings.CW.CQStrBank[2] := Edit10.Text;

  for i := 1 to 10 do
    Settings._SoundFiles[i]:= TempVoiceFiles[i];

  Settings._bsexpire := spBSExpire.Value;
  Settings._spotexpire := spSpotExpire.Value;

  Settings._icombaudrate := cbIcomBaudRate.ItemIndex;

  Settings._SoundComments[1] := vEdit1.Text;
  Settings._SoundComments[2] := vEdit2.Text;
  Settings._SoundComments[3] := vEdit3.Text;
  Settings._SoundComments[4] := vEdit4.Text;
  Settings._SoundComments[5] := vEdit5.Text;
  Settings._SoundComments[6] := vEdit6.Text;
  Settings._SoundComments[7] := vEdit7.Text;
  Settings._SoundComments[8] := vEdit8.Text;
  Settings._SoundComments[9] := vEdit9.Text;
  Settings._SoundComments[10] := vEdit10.Text;

  try
    R := Settings.CW._cqrepeat;
    Settings.CW._cqrepeat := StrToFloat(CQRepEdit.Text);
  except
    on EConvertError do
      Settings.CW._cqrepeat := R;
  end;

  try
    R := Settings._sendfreq;
    Settings._sendfreq := StrToFloat(SendFreqEdit.Text);
  except
    on EConvertError do
      Settings._sendfreq := R;
  end;

  Settings.CW._speed := SpeedBar.Position;
  Settings.CW._weight := WeightBar.Position;
  Settings.CW._paddlereverse := PaddleCheck.Checked;
  Settings.CW._sidetone := SideToneCheck.Checked;
  Settings.CW._FIFO := FIFOCheck.Checked;
  Settings.CW._tonepitch := ToneSpinEdit.Value;
  Settings.CW._cqmax := CQMaxSpinEdit.Value;
  Settings.CW._paddle := PaddleEnabledCheck.Checked;

  Settings._switchcqsp := cbCQSP.Checked;
  if Length(AbbrevEdit.Text) >= 3 then
    begin
      Settings.CW._zero := AbbrevEdit.Text[1];
      Settings.CW._one  := AbbrevEdit.Text[2];
      Settings.CW._nine := AbbrevEdit.Text[3];
    end;

  Settings._clusterport := ClusterCombo.ItemIndex;
  Settings._clusterbaud := ClusterCOMSet.BaudCombo.ItemIndex;
  Settings._rig1port := Rig1PortCombo.ItemIndex;
  Settings._ritclear := cbRITClear.Checked;
  Settings._rig1name := Rig1Combo.ItemIndex;

  Settings._rig2port := Rig2PortCombo.ItemIndex;
  Settings._rig2name := Rig2Combo.ItemIndex;


  Settings._clusterhost := ClusterTelnetSet.HostName.Text;
  Settings._clustertelnetport := ClusterTelnetSet.spPortNumber.Value;
  Settings._clusterlinebreakTELNET := ClusterTelnetSet.LineBreak.ItemIndex;
  Settings._clusterlocalechoTELNET := ClusterTelnetSet.LocalEcho.Checked;
  Settings._clusterlinebreakCOM := ClusterCOMSet.LineBreak.ItemIndex;
  Settings._clusterlocalechoCOM := ClusterCOMSet.LocalEcho.Checked;

  Settings._zlinkport := ZLinkCombo.ItemIndex;
  //Settings._zlinkbaud := ZLinkCOMSet.BaudCombo.ItemIndex;

  Settings._zlinkhost := ZLinkTelnetSet.HostName.Text;
  Settings._zlinklinebreakTELNET := ZLinkTelnetSet.LineBreak.ItemIndex;
  Settings._zlinklocalechoTELNET := ZLinkTelnetSet.LocalEcho.Checked;
  //Settings._zlinklinebreakCOM := ZLinkCOMSet.LineBreak.ItemIndex;
  //Settings._zlinklocalechoCOM := ZLinkCOMSet.LocalEcho.Checked;

  Settings._pttenabled := PTTEnabledCheckBox.Checked;
  Settings._saveevery := SaveEvery.Value;
  Settings._countdown := cbCountDown.Checked;
  Settings._qsycount := cbQSYCount.Checked;

  try
    i := Settings._pttbefore;
    Settings._pttbefore := StrToInt(BeforeEdit.Text);
  except
    on EConvertError do
      Settings._pttbefore := i;
  end;

  try
    i := Settings._pttafter;
    Settings._pttafter := StrToInt(AfterEdit.Text);
  except
    on EConvertError do
      Settings._pttafter := i;
  end;

{ i := HexStrToInt(CWPortEdit.Text);
  if i > 0 then
    Settings._cwport := i; }

  if rbLPT1.Checked then
    Settings._lptnr := 1;
  if rbLPT2.Checked then
    Settings._lptnr := 2;
  if rbCOM1.Checked then
    Settings._lptnr := 11;
  if rbCOM2.Checked then
    Settings._lptnr := 12;
  if rbUSB.Checked then
    Settings._lptnr := 21;

  settings._sentstr := SentEdit.Text;

  Settings._backuppath := BackUpPathEdit.Text;
  Settings._cfgdatpath := edCFGDATPath.Text;
  Settings._logspath := edLogsPath.Text;


  Settings._allowdupe := AllowDupeCheckBox.Checked;
  Settings._sameexchange := cbDispExchange.Checked;
  Settings._entersuperexchange := cbAutoEnterSuper.Checked;

  Settings._transverter1 := cbTransverter1.Checked;
  Settings._transverter2 := cbTransverter2.Checked;
  Settings._autobandmap := cbAutoBandMap.Checked;

end;

procedure TOptions.OKButtonClick(Sender: TObject);
begin
  RenewSettings;

  ImplementSettings(False);

  MainForm.RenewCWToolBar;

  MainForm.RenewVoiceToolBar;

  Close;
  MainForm.LastFocus.SetFocus;
end;

procedure TOptions.RenewCWStrBankDisp;
begin
  Edit1.Text := TempCWStrBank[TempCurrentBank,1];
  Edit2.Text := TempCWStrBank[TempCurrentBank,2];
  Edit3.Text := TempCWStrBank[TempCurrentBank,3];
  Edit4.Text := TempCWStrBank[TempCurrentBank,4];
  Edit5.Text := TempCWStrBank[TempCurrentBank,5];
  Edit6.Text := TempCWStrBank[TempCurrentBank,6];
  Edit7.Text := TempCWStrBank[TempCurrentBank,7];
  Edit8.Text := TempCWStrBank[TempCurrentBank,8];
end;

procedure TOptions.FormShow(Sender: TObject);
var i, j : integer;
begin

  cbSaveWhenNoCW.Checked := Settings._savewhennocw;
  cbJMode.Checked := Settings._jmode;

  rgSearchAfter.ItemIndex := Settings._searchafter;
  spMaxSuperHit.Value := Settings._maxsuperhit;
  spBSExpire.Value := Settings._bsexpire;
  spSpotExpire.Value := Settings._spotexpire;
  cbUpdateThread.Checked := Settings._renewbythread;
  cbDisplayDatePartialCheck.Checked := Settings._displaydatepartialcheck;

  rgBandData.ItemIndex := Settings._banddatamode;
  cbDontAllowSameBand.Checked := Settings._dontallowsameband;
  cbAutoBandMap.Checked := Settings._autobandmap;
  cbAFSK.Checked := Settings._AFSK;

  cbRecordRigFreq.Checked := Settings._recrigfreq;
  cbMultiStn.Checked := Settings._multistation;
  act19.Checked := Settings._activebands[b19];
  act35.Checked := Settings._activebands[b35];
  act7.Checked := Settings._activebands[b7];
  act10.Checked := Settings._activebands[b10];
  act14.Checked := Settings._activebands[b14];
  act18.Checked := Settings._activebands[b18];
  act21.Checked := Settings._activebands[b21];
  act24.Checked := Settings._activebands[b24];
  act28.Checked := Settings._activebands[b28];
  act50.Checked := Settings._activebands[b50];
  act144.Checked := Settings._activebands[b144];
  act430.Checked := Settings._activebands[b430];
  act1200.Checked := Settings._activebands[b1200];
  act2400.Checked := Settings._activebands[b2400];
  act5600.Checked := Settings._activebands[b5600];
  act10g.Checked := Settings._activebands[b10g];

  if Settings._multiop <> 0 then
    MultiOpRadioBtn.Checked := True
  else
    SingleOpRadioBtn.Checked := True;

  if Settings._band = 0 then
    BandGroup.ItemIndex := 0
  else
    BandGroup.ItemIndex := OldBandOrd(TBand(Settings._band-1))+1
    ;
  ModeGroup.ItemIndex := Settings._mode;
  {OpListBox.Items := OpList;}

  for i := 1 to maxbank do
    for j := 1 to maxstr do
      TempCWStrBank[i, j] := Settings.CW.CWStrBank[i,j];

  TempCurrentBank := Settings.CW.CurrentBank;
  case TempCurrentBank of
    1 : rbBankA.Checked := true;
    2 : rbBankB.Checked := true;
    3 : rbRTTY.Checked := true;
  end;

  RenewCWStrBankDisp;
  {
  Edit1.Text := Settings.CW.CWStrBank[1,1];
  Edit2.Text := Settings.CW.CWStrBank[1,2];
  Edit3.Text := Settings.CW.CWStrBank[1,3];
  Edit4.Text := Settings.CW.CWStrBank[1,4];
  Edit5.Text := Settings.CW.CWStrBank[1,5];
  Edit6.Text := Settings.CW.CWStrBank[1,6];
  Edit7.Text := Settings.CW.CWStrBank[1,7];
  Edit8.Text := Settings.CW.CWStrBank[1,8];
  }
  Edit9.Text := Settings.CW.CQStrBank[1];
  Edit10.Text := Settings.CW.CQStrBank[2];

  vEdit1.Text := Settings._SoundComments[1];
  vEdit2.Text := Settings._SoundComments[2];
  vEdit3.Text := Settings._SoundComments[3];
  vEdit4.Text := Settings._SoundComments[4];
  vEdit5.Text := Settings._SoundComments[5];
  vEdit6.Text := Settings._SoundComments[6];
  vEdit7.Text := Settings._SoundComments[7];
  vEdit8.Text := Settings._SoundComments[8];
  vEdit9.Text := Settings._SoundComments[9];
  vEdit10.Text := Settings._SoundComments[10];

  vButton1.Caption := ExtractFileName(Settings._SoundFiles[1]);
  vButton2.Caption := ExtractFileName(Settings._SoundFiles[2]);
  vButton3.Caption := ExtractFileName(Settings._SoundFiles[3]);
  vButton4.Caption := ExtractFileName(Settings._SoundFiles[4]);
  vButton5.Caption := ExtractFileName(Settings._SoundFiles[5]);
  vButton6.Caption := ExtractFileName(Settings._SoundFiles[6]);
  vButton7.Caption := ExtractFileName(Settings._SoundFiles[7]);
  vButton8.Caption := ExtractFileName(Settings._SoundFiles[8]);
  vButton9.Caption := ExtractFileName(Settings._SoundFiles[9]);
  vButton10.Caption := ExtractFileName(Settings._SoundFiles[10]);

  for i := 1 to 10
    do TempVoiceFiles[i] := Settings._SoundFiles[i];

  CQRepEdit.Text := FloatToStrF(Settings.CW._cqrepeat, ffFixed, 3, 1);
  SendFreqEdit.Text := FloatToStrF(Settings._sendfreq, ffFixed, 3, 1);
  SpeedBar.Position := Settings.CW._speed;
  SpeedLabel.Caption := IntToStr(Settings.CW._speed)+' wpm';
  WeightBar.Position := Settings.CW._weight;
  WeightLabel.Caption := IntToStr(Settings.CW._weight)+' %';
  PaddleCheck.Checked := Settings.CW._paddlereverse;
  PaddleEnabledCheck.Checked := Settings.CW._paddle;
  SideToneCheck.Checked := Settings.CW._sidetone;
  FIFOCheck.Checked := Settings.CW._FIFO;
  ToneSpinEdit.Value := Settings.CW._tonepitch;
  CQMaxSpinEdit.Value := Settings.CW._cqmax;
  AbbrevEdit.Text := Settings.CW._zero + Settings.CW._one + Settings.CW._nine;

  ProvEdit.Text := Settings._prov;
  CityEdit.Text := Settings._city;
  CQZoneEdit.Text := Settings._cqzone;
  IARUZoneEdit.Text := Settings._iaruzone;

  AllowDupeCheckBox.Checked := Settings._allowdupe;

  ClusterCombo.ItemIndex := Settings._clusterport;
  ZLinkCombo.ItemIndex := Settings._zlinkport;
  Rig1PortCombo.ItemIndex := Settings._rig1port;
  cbRITClear.Checked := Settings._ritclear;
  Rig1Combo.ItemIndex := Settings._rig1name;

  Rig2PortCombo.ItemIndex := Settings._rig2port;
  cbRITClear.Checked := Settings._ritclear;
  Rig2Combo.ItemIndex := Settings._rig2name;

  cbIcomBaudRate.ItemIndex := Settings._icombaudrate;

  PCSetButton.Enabled := True;
  case ClusterCombo.ItemIndex of
    0 : PCSetButton.Enabled := False;
    1..6 : PCSetButton.Caption := 'COM port settings';
    7 : PCSetButton.Caption := 'TELNET settings';
  end;

  ZLinkSetButton.Enabled := True;
  case ZLinkCombo.ItemIndex of
    0 : ZLinkSetButton.Enabled := False;
    1 : ZLinkSetButton.Caption := 'TELNET settings';
  end;

  SaveEvery.Value := Settings._saveevery;

  ClusterCOMSet.SetVisuals;
  ClusterTelnetSet.SetVisuals;

  //ZLinkCOMSet.SetVisuals;
  ZLinkTelnetSet.SetVisuals;

  if LPTport[1] = 0 then
    rbLPT1.Enabled := False
  else
    rbLPT1.Enabled := True;
  if LPTport[2] = 0 then
    rbLPT2.Enabled := False
  else
    rbLPT2.Enabled := True;
  if Settings._lptnr = 1 then
    rbLPT1.Checked := True;
  if Settings._lptnr = 2 then
    rbLPT2.Checked := True;
  if Settings._lptnr = 11 then
    rbCOM1.Checked := True;
  if Settings._lptnr = 12 then
    rbCOM2.Checked := True;
  if Settings._lptnr = 21 then
    rbUSB.Checked := True;

{$IFNDEF W95}
  rbUSB.Enabled := True;
{$ENDIF}

  SentEdit.Text := Settings._sentstr;

  BackUpPathEdit.Text := Settings._backuppath;
  edCFGDATPath.Text := Settings._cfgdatpath;
  edLogsPath.Text := Settings._logspath;


  PTTEnabledCheckBox.Checked := Settings._pttenabled;
  BeforeEdit.Text := IntToStr(Settings._pttbefore);
  AfterEdit.Text := IntToStr(Settings._pttafter);
  if PTTEnabledCheckBox.Checked then
    begin
      BeforeEdit.Enabled := True;
      AfterEdit.Enabled := True;
    end
  else
    begin
      BeforeEdit.Enabled := False;
      AfterEdit.Enabled := False;
    end;
  cbCQSP.Checked := Settings._switchcqsp;
  cbCountDown.Checked := Settings._countdown;
  cbQSYCount.Checked := Settings._qsycount;

  cbDispExchange.Checked := Settings._sameexchange;
  cbAutoEnterSuper.Checked := Settings._entersuperexchange;

  cbTransverter1.Checked := Settings._transverter1;
  cbTransverter2.Checked := Settings._transverter2;

end;

procedure TOptions.AddClick(Sender: TObject);
var str : string;
begin
  if OpEdit.Text <> '' then
    begin
      str := OpEdit.Text;
      if OpPowerEdit.Text <> '' then
        str := FillRight(str, 20)+OpPowerEdit.Text;
      OpListBox.Items.Add(str);
    end;
  OpEdit.Text := '';
  OpPowerEdit.Text := '';
  OpEdit.SetFocus;
end;

procedure TOptions.DeleteClick(Sender: TObject);
begin

  OpListBox.Items.Delete(OpListBox.ItemIndex);
end;

procedure TOptions.FormCreate(Sender: TObject);
var f : textfile;
    str, filename : string;
    B : TBand;
    i, n : integer;
    Res : TVicRes;
    VerInfo : TOSVersionInfo;
begin

  for i := 1 to LPTMAX do
    LPTPort[i] := 0;

  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(VerInfo);

  if VerInfo.dwPlatformId = VER_PLATFORM_WIN32_NT then
    begin
      ZLOG_WIN2KMODE := TRUE;
      BGK32LIB._WIN2KMODE := ZLOG_WIN2KMODE;
    end;

  if ZLOG_WIN2KMODE = False then
    begin
      Res := TVicRes.Create;
      Res.SearchByClassName('Ports');
      n := Res.Devices;
      for i := 1 to n do
        begin
          if pos('LPT1',Res.DeviceDescriptor[i]) > 0 then
            LPTPort[1] := Res.PortBase[i] + 2;
          if pos('LPT2',Res.DeviceDescriptor[i]) > 0 then
            LPTPort[2] := Res.PortBase[i] + 2;
        end;
    end;

  for B := b19 to b10G do
    begin
      CurrentPower[B] := pwrP;
      CurrentPower2[B] := 500;
    end;

  LoadIniFile;
  Settings.CW.CurrentBank := 1;
  TempCurrentBank := 1;
  Options.OpList := TStringList.Create;


 try
    OpList.LoadFromFile(MAINPATH+'ZLOG.OP');
  except
    on EFOpenError do
      begin
      end;
  end;

  OpListBox.Items.Assign(OpList);

  PageControl.ActivePage := PrefTabSheet;

  Rig1Combo.Items.Clear;
  Rig2Combo.Items.Clear;
  for i := 0 to RIGNAMEMAX do
    begin
      Rig1Combo.Items.Add(RIGNAMES[i]);
      Rig2Combo.Items.Add(RIGNAMES[i]);
    end;

end;

procedure TOptions.Button2Click(Sender: TObject);
begin
  Close;
  MainForm.LastFocus.SetFocus;
end;

procedure TOptions.OpEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN : AddClick(Self);
  end;
end;

procedure TOptions.OpEditEnter(Sender: TObject);
begin
  Add.Default := True;
end;

procedure TOptions.OpEditExit(Sender: TObject);
begin
  OKButton.Default := True;
end;

procedure TOptions.Button3Click(Sender: TObject);
begin
  RenewSettings;
  ImplementSettings(False);
  SaveCurrentSettings; {Writes Settings to Inifile}
  MainForm.RenewCWToolBar;
  MainForm.RenewVoiceToolBar;
end;

procedure TOptions.SpeedBarChange(Sender: TObject);
begin
  SpeedLabel.Caption := IntToStr(SpeedBar.Position) + ' wpm';
end;

procedure TOptions.WeightBarChange(Sender: TObject);
begin
  WeightLabel.Caption := IntToStr(WeightBar.Position)+' %';
end;

procedure TOptions.FormDestroy(Sender: TObject);
begin
  OpList.Free;
end;

procedure TOptions.vButtonClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    begin
      TempVoiceFiles[TButton(Sender).Tag] := OpenDialog.FileName;
      Tlabel(Sender).Caption := ExtractFileName(OpenDialog.FileName);
    end;
end;

procedure TOptions.ClusterComboChange(Sender: TObject);
begin
  PCsetButton.Enabled := True;
  case ClusterCombo.ItemIndex of
    0 : PCsetButton.Enabled := False;
    1..6 : PCsetButton.Caption := 'COM port settings';
    7 : PCsetButton.Caption := 'TELNET settings';
  end;
end;


procedure TOptions.PCsetButtonClick(Sender: TObject);
begin
  if PCSetButton.Caption = 'COM port settings' then
    ClusterComSet.ShowModal
  else
    ClusterTelnetSet.ShowModal;
end;

procedure TOptions.ZLinkComboChange(Sender: TObject);
begin
  if ZLinkCombo.ItemIndex = 0 then
    ZLinksetButton.Enabled := False
  else
    ZLinksetButton.Enabled := True;
end;

procedure TOptions.ZLinkSetButtonClick(Sender: TObject);
begin
{  if ZLinkSetButton.Caption = 'COM port settings' then
    ZLinkComSet.ShowModal
  else }
    ZLinkTelnetSet.ShowModal;
end;

procedure TOptions.BrowsePathClick(Sender: TObject);
var p : string;
begin
  If PathDialog.Execute then
    begin
      p := PathDialog.Directory;
      if p[Length(p)] <> '\' then
        p := p + '\';
      case TButton(Sender).Tag of
        0 : BackUpPathEdit.Text := p;
        10 : edCFGDATPath.Text := p;
        20 : edLogsPath.Text := p;
      end;
    end;
end;

procedure TOptions.PTTEnabledCheckBoxClick(Sender: TObject);
begin
  if PTTEnabledCheckBox.Checked then
    begin
      BeforeEdit.Enabled := True;
      AfterEdit.Enabled := True;
    end
  else
    begin
      BeforeEdit.Enabled := False;
      AfterEdit.Enabled := False;
    end;
end;

procedure TOptions.CQRepEditKeyPress(Sender: TObject; var Key: Char);
begin
  if not(Key in ['0'..'9','.']) then
    Key := #0;
end;

procedure TOptions.Edit1Change(Sender: TObject);
var i : integer;
begin
  i := TEdit(Sender).Tag;
  TempCWStrBank[TempCurrentBank,i] := TEdit(Sender).Text;
end;

procedure TOptions.CWBankClick(Sender: TObject);
begin
  TempCurrentBank := TRadioButton(Sender).Tag;
  RenewCWStrBankDisp;
end;

function TOptions.PTTEnabled : boolean;
begin
  Result := Settings._pttenabled;
end;

procedure TOptions.ReadWin(WinName : string; var Open : boolean; var X, Y, H, W: integer);
var P : PChar;
begin
  P := StrAlloc(256);
  StrPCopy(P, WinName+'_Open');
  Open := Ini.GetBoolean('Windows', P, False);
  StrPCopy(P, WinName+'_X');
  X := Ini.GetInteger('Windows', P, 10);
  StrPCopy(P, WinName+'_Y');
  Y := Ini.GetInteger('Windows', P, 10);
  StrPCopy(P, WinName+'_H');
  H := Ini.GetInteger('Windows', P, 10);
  StrPCopy(P, WinName+'_W');
  W := Ini.GetInteger('Windows', P, 10);
  StrDispose(P);
end;

procedure TOptions.ReadWin2(WinName : string; var F : TForm);
var P : PChar;
    i : integer;
begin
  P := StrAlloc(256);
  StrPCopy(P, WinName+'_X');
  i := Ini.GetInteger('Windows', P, -1);
  if i > 0 then
    F.Left := i;
  StrPCopy(P, WinName+'_Y');
  i := Ini.GetInteger('Windows', P, -1);
  if i > 0 then
    F.Top := i;
  StrPCopy(P, WinName+'_W');
  i := Ini.GetInteger('Windows', P, -1);
  if i > 0 then
    F.Width := i;
  StrPCopy(P, WinName+'_H');
  i := Ini.GetInteger('Windows', P, -1);
  if i > 0 then
    F.Height := i;
  StrPCopy(P, WinName+'_Open');
  F.Visible := Ini.GetBoolean('Windows', P, False);
  StrDispose(P);
end;

procedure TOptions.RecordWin(WinName : string; Open : boolean; X, Y : integer);
var P : PChar;
begin
  P := StrAlloc(256);
  StrPCopy(P, WinName+'_Open');
  Ini.SetBoolean('Windows', P, Open);
  StrPCopy(P, WinName+'_X');
  Ini.SetInteger('Windows', P, X);
  StrPCopy(P, WinName+'_Y');
  Ini.SetInteger('Windows', P, Y);
  StrDispose(P);
end;

procedure TOptions.RecordSuperCheckColumns(c : integer);
var P : PChar;
begin
  P := StrAlloc(256);
  StrPCopy(P, 'SuperCheckColumns');
  Ini.SetInteger('Windows', P, C);
  StrDispose(P);
end;

function TOptions.GetSuperCheckColumns : integer;
var P : PChar;
begin
  P := StrAlloc(256);
  StrPCopy(P, 'SuperCheckColumns');
  Result := Ini.GetInteger('Windows', P, 0);
  StrDispose(P);
end;

procedure TOptions.RecordWin2(WinName : string; F : TForm);
var P : PChar;
begin
  P := StrAlloc(256);
  StrPCopy(P, WinName+'_Open');
  Ini.SetBoolean('Windows', P, F.Visible);
  StrPCopy(P, WinName+'_X');
  Ini.SetInteger('Windows', P, F.Left);
  StrPCopy(P, WinName+'_Y');
  Ini.SetInteger('Windows', P, F.Top);
  StrPCopy(P, WinName+'_H');
  Ini.SetInteger('Windows', P, F.Height);
  StrPCopy(P, WinName+'_W');
  Ini.SetInteger('Windows', P, F.Width);
  StrDispose(P);
end;

procedure TOptions.RestoreMainForm(var X, Y, W, H : integer; var TB1, TB2 : boolean);
begin
  X := Ini.GetInteger('Windows', 'Main_X', 0);
  Y := Ini.GetInteger('Windows', 'Main_Y', 0);
  W := Ini.GetInteger('Windows', 'Main_W', 0);
  H := Ini.GetInteger('Windows', 'Main_H', 0);
  TB1 := Ini.GetBoolean('Windows', 'Main_ToolBar1', False);
  TB2 := Ini.GetBoolean('Windows', 'Main_ToolBar2', False);
end;

procedure TOptions.RecordMainForm(X, Y, W, H : integer; TB1, TB2 : boolean);
begin
  Ini.SetInteger('Windows', 'Main_X', X);
  Ini.SetInteger('Windows', 'Main_Y', Y);
  Ini.SetInteger('Windows', 'Main_W', W);
  Ini.SetInteger('Windows', 'Main_H', H);
  Ini.SetBoolean('Windows', 'Main_ToolBar1', TB1);
  Ini.SetBoolean('Windows', 'Main_ToolBar2', TB2);
end;



procedure TOptions.cbCountDownClick(Sender: TObject);
begin
  if cbCountDown.Checked then
    cbQSYCount.Checked := False;
end;

procedure TOptions.cbQSYCountClick(Sender: TObject);
begin
  if cbQSYCount.Checked then
    cbCountDown.Checked := False;
end;


procedure TOptions.cbTransverter1Click(Sender: TObject);
var i, r : integer;
begin
  r := TCheckBox(Sender).Tag;
  r := r - 100;


  if TCheckBox(Sender).Checked then
    begin
      i := 0;
      if r = 1 then
        i := Settings._transverteroffset1;
      if r = 2 then
        i := Settings._transverteroffset2;

      IntegerDialog.Init(i, 'Please input the offset frequency in kHz');
      IntegerDialog.ShowModal;
      i := IntegerDialog.GetValue;
      if i <> -1 then
        begin
          if r = 1 then
             Settings._transverteroffset1 := i;
          if r = 2 then
             Settings._transverteroffset2 := i;
        end;
    end;

end;


procedure TOptions.Rig1ComboChange(Sender: TObject);
begin
  if Rig1Combo.ItemIndex = RIGNAMEMAX then
    begin
      Rig2Combo.ItemIndex := RIGNAMEMAX;
      Rig1PortCombo.ItemIndex := 0;
      Rig1PortCombo.Enabled := False;
      Rig2PortCombo.Enabled := False;
    end
  else
    begin
      Rig1PortCombo.Enabled := True;
      if Rig2Combo.ItemIndex = RIGNAMEMAX then
        begin
          Rig2PortCombo.ItemIndex := 0;
          Rig2Combo.ItemIndex := 0;
          Rig2PortCombo.Enabled := True;
        end;
    end;
end;

procedure TOptions.Rig2ComboChange(Sender: TObject);
begin
  if Rig2Combo.ItemIndex = RIGNAMEMAX then
    begin
      Rig1Combo.ItemIndex := RIGNAMEMAX;
      Rig2PortCombo.ItemIndex := 0;
      Rig2PortCombo.Enabled := False;
      Rig1PortCombo.Enabled := False;
    end
  else
    begin
      Rig2PortCombo.Enabled := True;
      if Rig1Combo.ItemIndex = RIGNAMEMAX then
        begin
          Rig1PortCombo.ItemIndex := 0;
          Rig1Combo.ItemIndex := 0;
          Rig1PortCombo.Enabled := True;
        end;
    end;
end;

end.
