unit UOptions;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, ComCtrls, zLogGlobal, Spin, IniFiles,
  BGK32Lib, Dialogs, Menus, FileCtrl, UPaddleThread,
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

//var   LPTport : array[1..LPTMAX] of word; // holds the base port + 2

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
    buttonZLinkSettings: TButton;
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
    radioCwCom1: TRadioButton;
    radioCwCom2: TRadioButton;
    rbRTTY: TRadioButton;
    cbCQSP: TCheckBox;
    radioCwUsb: TRadioButton;
    cbAFSK: TCheckBox;
    cbAutoEnterSuper: TCheckBox;
    Label52: TLabel;
    Label53: TLabel;
    spSpotExpire: TSpinEdit;
    cbDisplayDatePartialCheck: TCheckBox;
    cbAutoBandMap: TCheckBox;
    cbIcomBaudRate: TComboBox;
    Label54: TLabel;
    radioCwNone: TRadioButton;
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
    procedure buttonZLinkSettingsClick(Sender: TObject);
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

function TOptions.Rig1NameStr: string; // returns the selected rig name
begin
   Result := Rig1Combo.Items[Settings._rig1name];
end;

function TOptions.Rig2NameStr: string; // returns the selected rig name
begin
   Result := Rig2Combo.Items[Settings._rig2name];
end;

function TOptions.GetAge(aQSO: TQSO): string;
var
   str: string;
   i: integer;
begin
   Result := '??';
   if aQSO.QSO.Operator = '' then
      Result := Settings._age
   else
      for i := 0 to OpList.Count - 1 do begin
         if TrimRight(Copy(OpList.Strings[i], 1, 20)) = aQSO.QSO.Operator then begin
            str := OpList.Strings[i];
            if length(str) <= 20 then
               exit;
            System.Delete(str, 1, 20);
            str := TrimLeft(TrimRight(str));
            Result := str;
         end;
      end;
end;

procedure TOptions.SetOpPower(var aQSO: TQSO);
var
   str: string;
   i: integer;
   P: char;
begin
   for i := 0 to OpList.Count - 1 do begin
      if TrimRight(Copy(OpList.Strings[i], 1, 20)) = aQSO.QSO.Operator then begin
         str := OpList.Strings[i];
         if length(str) <= 20 then
            exit;
         System.Delete(str, 1, 20);
         if OldBandOrd(aQSO.QSO.Band) + 1 <= length(str) then
            P := str[OldBandOrd(aQSO.QSO.Band) + 1]
         else
            P := UpCase(str[1]);
         case P of
            'P':
               aQSO.QSO.Power := pwrP;
            'L':
               aQSO.QSO.Power := pwrL;
            'M':
               aQSO.QSO.Power := pwrM;
            'H':
               aQSO.QSO.Power := pwrH;
         end;
      end;
   end;
end;

procedure TOptions.CreateParams(var Params: TCreateParams);
begin
   inherited CreateParams(Params);
   Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TOptions.SetMyCall(s: string);
begin
   Settings._mycall := s;
end;

function TOptions.MyCall: shortstring;
begin
   Result := Settings._mycall;
end;

procedure TOptions.SetTXNr(i: byte);
begin
   Settings._txnr := i;
end;

procedure TOptions.SetScoreCoeff(E: extended);
begin
   Settings._scorecoeff := E;
   TQSO(Log.List[0]).QSO.RSTRcvd := Trunc(E * 100);
end;

function TOptions.GetTXNr: byte;
begin
   Result := Settings._txnr;
end;

procedure TOptions.SetTonePitch(i: integer);
begin
   Settings.CW._tonepitch := i;
   BGK32Lib.SetPitch(i);
end;

procedure TOptions.SetCQMax(i: integer);
begin
   Settings.CW._cqmax := i;
   BGK32Lib.SetLoopMax(i);
end;

procedure TOptions.SetCQRepeat(r: double);
begin
   Settings.CW._cqrepeat := r;
   BGK32Lib.SetLoopTime(r);
end;

procedure TOptions.SetSendFreq(r: double);
begin
   Settings._sendfreq := r;
   RigControl.Timer1.Interval := Trunc(r * 60000);
   RigControl.Timer1.Enabled := False;
   if r = 0 then
      exit;
   if Settings._rig1port <> 0 then
      if Settings._zlinkport <> 0 then
         if Settings._rig1name <> 0 then
            RigControl.Timer1.Enabled := True;
end;

function TOptions.CWMessage(bank, i: integer): shortstring;
begin
   Result := Settings.CW.CWStrBank[bank, i];
end;

procedure TOptions.SetSpeed(i: integer);
begin
   if i in [0 .. 60] then
      Settings.CW._speed := i;
   BGK32Lib.SetCWSpeed(Settings.CW._speed);
end;

procedure TOptions.SetWeight(i: integer);
begin
   if i in [0 .. 100] then
      Settings.CW._weight := i;
   BGK32Lib.SetWeight(Settings.CW._weight);
end;

procedure TOptions.SetSideTone(boo: boolean);
begin
   BGK32Lib.SetSideTone(boo);
   Settings.CW._sidetone := boo;
end;

function TOptions.FIFO: boolean;
begin
   Result := Settings.CW._FIFO;
end;

function TOptions.Speed: integer;
begin
   Result := Settings.CW._speed;
end;

function TOptions.SideTone: boolean;
begin
   Result := Settings.CW._sidetone;
end;

function TOptions.MultiOp: integer;
begin
   Result := Settings._multiop;
end;

function TOptions.Band: integer;
begin
   Result := Settings._band;
end;

function TOptions.Mode: integer;
begin
   Result := Settings._mode;
end;

function TOptions.ContestMenuNo: integer;
begin
   Result := Settings._contestmenuno;
end;

procedure TOptions.SetMultiOp(i: integer);
begin
   Settings._multiop := i;
   zLogGlobal.OperatorCategory := i;
end;

procedure TOptions.SetBand(b: integer);
var
   BB: TBand;
begin
   Settings._band := b;
   if b > 0 then begin
      Main.CurrentQSO.QSO.Band := TBand(b - 1);
      MainForm.BandEdit.Text := Main.CurrentQSO.BandStr;
      for BB := b19 to HiBand do
         MainForm.BandMenu.Items[ord(BB)].Enabled := False;
      MainForm.BandMenu.Items[b - 1].Enabled := True;
   end
   else begin
      for BB := b19 to HiBand do
         MainForm.BandMenu.Items[ord(BB)].Enabled := True;
   end;
end;

procedure TOptions.SetMode(m: integer);
begin
   Settings._mode := m;
end;

procedure TOptions.SetPaddleReverse(boo: boolean);
begin
   Settings.CW._paddlereverse := boo;
   BGK32Lib.ReversePaddle(boo);
end;

procedure TOptions.ReversePaddle;
begin
   SetPaddleReverse(not(Settings.CW._paddlereverse));
end;

procedure TOptions.SetCurrentContestNo(i: integer);
begin
   Settings._contestmenuno := i;
end;

procedure TOptions.SetFIFO(boo: boolean);
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

procedure TOptions.SetPaddle(boo: boolean);
begin
   Settings.CW._paddle := boo;
end;

procedure TOptions.SaveCurrentSettings;
var
   i: integer;
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      ini.WriteBool('Preferences', 'SaveWhenNoCW', Settings._savewhennocw);
      ini.WriteBool('Preferences', 'MultiStationWarning', Settings._multistationwarning);
      ini.WriteBool('Preferences', 'JMode', Settings._jmode);
      ini.WriteBool('Preferences', 'MoveToMemoWithSpace', Settings._movetomemo);
      ini.WriteBool('Preferences', 'AutoEnterSuper', Settings._entersuperexchange);

      ini.WriteInteger('Misc', 'SearchAfter', Settings._searchafter);

      ini.WriteInteger('Misc', 'MaxSuperHit', Settings._maxsuperhit);
      ini.WriteInteger('Misc', 'BandScopeExpire', Settings._bsexpire);
      ini.WriteInteger('Misc', 'SpotExpire', Settings._spotexpire);
      ini.WriteBool('Misc', 'UpdateUsingThread', Settings._renewbythread);
      ini.WriteBool('Misc', 'DisplayDatePartialCheck', Settings._displaydatepartialcheck);

      ini.WriteInteger('Rig', 'BandDataMode', Settings._banddatamode);
      ini.WriteBool('Rig', 'DontAllowSameBand', Settings._dontallowsameband);
      ini.WriteBool('Rig', 'AutoBandMap', Settings._autobandmap);
      ini.WriteBool('Rig', 'UseAFSK', Settings._AFSK);

      ini.WriteBool('Profiles', 'Active1.9MHz', Settings._activebands[b19]);
      ini.WriteBool('Profiles', 'Active3.5MHz', Settings._activebands[b35]);
      ini.WriteBool('Profiles', 'Active7MHz', Settings._activebands[b7]);
      ini.WriteBool('Profiles', 'Active10MHz', Settings._activebands[b10]);
      ini.WriteBool('Profiles', 'Active14MHz', Settings._activebands[b14]);
      ini.WriteBool('Profiles', 'Active18MHz', Settings._activebands[b18]);
      ini.WriteBool('Profiles', 'Active21MHz', Settings._activebands[b21]);
      ini.WriteBool('Profiles', 'Active24MHz', Settings._activebands[b24]);
      ini.WriteBool('Profiles', 'Active28MHz', Settings._activebands[b28]);
      ini.WriteBool('Profiles', 'Active50MHz', Settings._activebands[b50]);
      ini.WriteBool('Profiles', 'Active144MHz', Settings._activebands[b144]);
      ini.WriteBool('Profiles', 'Active430MHz', Settings._activebands[b430]);
      ini.WriteBool('Profiles', 'Active1200MHz', Settings._activebands[b1200]);
      ini.WriteBool('Profiles', 'Active2400MHz', Settings._activebands[b2400]);
      ini.WriteBool('Profiles', 'Active5600MHz', Settings._activebands[b5600]);
      ini.WriteBool('Profiles', 'Active10GHz', Settings._activebands[b10g]);

      ini.WriteString('Preferences', 'BackUpPath', Settings._backuppath);
      ini.WriteString('Preferences', 'CFGDATPath', Settings._cfgdatpath);
      ini.WriteString('Preferences', 'LogsPath', Settings._logspath);

      ini.WriteInteger('Preferences', 'SaveEvery', Settings._saveevery);
      ini.WriteBool('Preferences', 'AllowDupe', Settings._allowdupe);
      ini.WriteBool('Preferences', 'CountDown', Settings._countdown);
      ini.WriteBool('Preferences', 'QSYCount', Settings._qsycount);
      ini.WriteBool('Categories', 'MultiStn', Settings._multistation);
      ini.WriteInteger('Categories', 'Operator2', Settings._multiop);
      ini.WriteInteger('Categories', 'Band', Settings._band);
      ini.WriteInteger('Categories', 'Contest', Settings._contestmenuno);
      ini.WriteInteger('Categories', 'Mode', Settings._mode);
      ini.WriteInteger('Categories', 'TXNumber', Settings._txnr);
      ini.WriteString('Categories', 'MyCall', Settings._mycall);

      ini.WriteString('Profiles', 'Province/State', Settings._prov);
      ini.WriteString('Profiles', 'City', Settings._city);
      ini.WriteString('Profiles', 'CQZone', Settings._cqzone);
      ini.WriteString('Profiles', 'IARUZone', Settings._iaruzone);

      { ini.WriteString('Profiles', 'CQCountry', Settings._cqcountry);
        ini.WriteString('Profiles', 'CQZone', Settings._cqzone);
        ini.WriteString('Profiles', 'DXCCCountry', Settings._dxcccountry);
        ini.WriteString('Profiles', 'IARUZone', Settings._iaruzone);
        ini.WriteString('Profiles', 'Continent', Settings._continent); }

      ini.WriteInteger('CW', 'Speed', Settings.CW._speed);
      ini.WriteInteger('CW', 'FixedSpeed', Settings.CW._fixwpm);
      ini.WriteInteger('CW', 'Weight', Settings.CW._weight);
      ini.WriteInteger('CW', 'CQMax', Settings.CW._cqmax);
      ini.WriteInteger('CW', 'Pitch', Settings.CW._tonepitch);
      ini.WriteBool('CW', 'PaddleReverse', Settings.CW._paddlereverse);

      ini.WriteBool('CW', 'PaddleEnabled', Settings.CW._paddle);

      ini.WriteBool('CW', 'SideTone', Settings.CW._sidetone);
      ini.WriteFloat('CW', 'CQRepeat', Settings.CW._cqrepeat);
      ini.WriteFloat('Rig', 'SendFreq', Settings._sendfreq);
      ini.WriteBool('Rig', 'RecordFreqInMemo', Settings._recrigfreq);
      ini.WriteBool('CW', 'FIFO', Settings.CW._FIFO);
      ini.WriteBool('CW', 'CQSP', Settings._switchcqsp);
      ini.WriteString('CW', 'Zero', Settings.CW._zero);
      ini.WriteString('CW', 'One', Settings.CW._one);
      ini.WriteString('CW', 'Nine', Settings.CW._nine);

      for i := 1 to maxstr do begin
         ini.WriteString('CW', 'F' + IntToStr(i), Settings.CW.CWStrBank[1, i]);
         ini.WriteString('CW', 'F' + IntToStr(i) + 'B', Settings.CW.CWStrBank[2, i]);
         ini.WriteString('RTTY', 'F' + IntToStr(i), Settings.CW.CWStrBank[3, i]);
      end;

      for i := 11 to 12 do begin
         ini.WriteString('CW', 'F' + IntToStr(i), Settings.CW.CWStrBank[1, i]);
         ini.WriteString('CW', 'F' + IntToStr(i) + 'B', Settings.CW.CWStrBank[2, i]);
         ini.WriteString('RTTY', 'F' + IntToStr(i), Settings.CW.CWStrBank[3, i]);
      end;

      ini.WriteString('CW', 'CQ2', Settings.CW.CQStrBank[1]);
      ini.WriteString('CW', 'CQ3', Settings.CW.CQStrBank[2]);

      for i := 1 to maxstr do begin
         ini.WriteString('Voice', 'F' + IntToStr(i), Settings._SoundFiles[i]);
      end;
      ini.WriteString('Voice', 'CQ2', Settings._SoundFiles[9]);
      ini.WriteString('Voice', 'CQ3', Settings._SoundFiles[10]);

      for i := 1 to maxstr do begin
         ini.WriteString('Voice', 'F' + IntToStr(i) + '_Comment', Settings._SoundComments[i]);
      end;
      ini.WriteString('Voice', 'CQ2_Comment', Settings._SoundComments[9]);
      ini.WriteString('Voice', 'CQ3_Comment', Settings._SoundComments[9]);

      ini.WriteInteger('Hardware', 'PacketCluster', Settings._clusterport);
      ini.WriteInteger('Hardware', 'Rig', Settings._rig1port);
      ini.WriteBool('Hardware', 'RitClear', Settings._ritclear);
      ini.WriteInteger('Hardware', 'RigName', Settings._rig1name);

      ini.WriteBool('Hardware', 'Transverter1', Settings._transverter1);
      ini.WriteInteger('Hardware', 'Transverter1Offset', Settings._transverteroffset1);
      ini.WriteBool('Hardware', 'Transverter2', Settings._transverter2);
      ini.WriteInteger('Hardware', 'Transverter2Offset', Settings._transverteroffset2);

      ini.WriteInteger('Hardware', 'Rig2', Settings._rig2port);
      ini.WriteInteger('Hardware', 'RigName2', Settings._rig2name);

      ini.WriteInteger('Hardware', 'Z-Link', Settings._zlinkport);

      ini.WriteInteger('Hardware', 'PacketClusterBaud', Settings._clusterbaud);
      ini.WriteInteger('Hardware', 'RigBaud', Settings._rigbaud);
      ini.WriteInteger('Hardware', 'IcomBaudRate', Settings._icombaudrate);

      ini.WriteInteger('Hardware', 'Z-LinkBaud', Settings._zlinkbaud);

      ini.WriteBool('Hardware', 'PTTEnabled', Settings._pttenabled);
      ini.WriteInteger('Hardware', 'PTTBefore', Settings._pttbefore);
      ini.WriteInteger('Hardware', 'PTTAfter', Settings._pttafter);

      ini.WriteString('PacketCluster', 'TELNEThost', Settings._clusterhost);
      ini.WriteInteger('PacketCluster', 'TELNETport', Settings._clustertelnetport);
      ini.WriteInteger('PacketCluster', 'TELNETlinebreak', Settings._clusterlinebreakTELNET);
      ini.WriteBool('PacketCluster', 'TELNETlocalecho', Settings._clusterlocalechoTELNET);
      ini.WriteInteger('PacketCluster', 'COMlinebreak', Settings._clusterlinebreakCOM);
      ini.WriteBool('PacketCluster', 'COMlocalecho', Settings._clusterlocalechoCOM);

      ini.WriteString('Z-Link', 'TELNEThost', Settings._zlinkhost);
      ini.WriteInteger('Z-Link', 'TELNETlinebreak', Settings._zlinklinebreakTELNET);
      ini.WriteBool('Z-Link', 'TELNETlocalecho', Settings._zlinklocalechoTELNET);
      ini.WriteInteger('Z-Link', 'COMlinebreak', Settings._zlinklinebreakCOM);
      ini.WriteBool('Z-Link', 'COMlocalecho', Settings._zlinklocalechoCOM);

      ini.WriteBool('Z-Link', 'SyncSerial', Settings._syncserial);

      ini.WriteInteger('Hardware', 'UseCWPort', Settings._specificcwport);
      ini.WriteInteger('Hardware', 'CWLPTPort', Settings._lptnr);
      // ini.WriteBoolean('Hardware','CWUseData',Settings._usedata);
      ini.WriteBool('Hardware', 'CWInvLogic', Settings._reverselogic);
      ini.WriteBool('Hardware', 'RigInvLogic', Settings._rigreverse);
      ini.WriteBool('Hardware', 'PTTInvLogic', Settings._pttreverse);

      ini.WriteInteger('Preferences', 'FontSize', Settings._mainfontsize);
      ini.WriteInteger('Preferences', 'RowHeight', Settings._mainrowheight);

      OpList.SaveToFile(MAINPATH + 'ZLOG.OP');
   finally
      ini.Free();
   end;
end;

procedure TOptions.LoadIniFileBS;
var
   b: TBand;
   m: TMode;
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      Settings._bsminfreqarray[b19, mCW] := ini.ReadInteger('BandScope', '1.9MHzCWmin', 1800);
      Settings._bsminfreqarray[b19, mSSB] := ini.ReadInteger('BandScope', '1.9MHzPHmin', 1800);
      Settings._bsmaxfreqarray[b19, mCW] := ini.ReadInteger('BandScope', '1.9MHzCWmax', 1950);
      Settings._bsmaxfreqarray[b19, mSSB] := ini.ReadInteger('BandScope', '1.9MHzPHmax', 1950);
      Settings._bsminfreqarray[b35, mCW] := ini.ReadInteger('BandScope', '3.5MHzCWmin', 3500);
      Settings._bsminfreqarray[b35, mSSB] := ini.ReadInteger('BandScope', '3.5MHzPHmin', 3500);
      Settings._bsmaxfreqarray[b35, mCW] := ini.ReadInteger('BandScope', '3.5MHzCWmax', 3800);
      Settings._bsmaxfreqarray[b35, mSSB] := ini.ReadInteger('BandScope', '3.5MHzPHmax', 3800);
      Settings._bsminfreqarray[b7, mCW] := ini.ReadInteger('BandScope', '7MHzCWmin', 7000);
      Settings._bsminfreqarray[b7, mSSB] := ini.ReadInteger('BandScope', '7MHzPHmin', 7000);
      Settings._bsmaxfreqarray[b7, mCW] := ini.ReadInteger('BandScope', '7MHzCWmax', 7200);
      Settings._bsmaxfreqarray[b7, mSSB] := ini.ReadInteger('BandScope', '7MHzPHmax', 7200);
      Settings._bsminfreqarray[b10, mCW] := ini.ReadInteger('BandScope', '10MHzCWmin', 10100);
      Settings._bsminfreqarray[b10, mSSB] := ini.ReadInteger('BandScope', '10MHzPHmin', 10100);
      Settings._bsmaxfreqarray[b10, mCW] := ini.ReadInteger('BandScope', '10MHzCWmax', 10150);
      Settings._bsmaxfreqarray[b10, mSSB] := ini.ReadInteger('BandScope', '10MHzPHmax', 10150);
      Settings._bsminfreqarray[b14, mCW] := ini.ReadInteger('BandScope', '14MHzCWmin', 14000);
      Settings._bsminfreqarray[b14, mSSB] := ini.ReadInteger('BandScope', '14MHzPHmin', 14000);
      Settings._bsmaxfreqarray[b14, mCW] := ini.ReadInteger('BandScope', '14MHzCWmax', 14350);
      Settings._bsmaxfreqarray[b14, mSSB] := ini.ReadInteger('BandScope', '14MHzPHmax', 14350);
      Settings._bsminfreqarray[b18, mCW] := ini.ReadInteger('BandScope', '18MHzCWmin', 18060);
      Settings._bsminfreqarray[b18, mSSB] := ini.ReadInteger('BandScope', '18MHzPHmin', 18060);
      Settings._bsmaxfreqarray[b18, mCW] := ini.ReadInteger('BandScope', '18MHzCWmax', 18170);
      Settings._bsmaxfreqarray[b18, mSSB] := ini.ReadInteger('BandScope', '18MHzPHmax', 18170);
      Settings._bsminfreqarray[b21, mCW] := ini.ReadInteger('BandScope', '21MHzCWmin', 21000);
      Settings._bsminfreqarray[b21, mSSB] := ini.ReadInteger('BandScope', '21MHzPHmin', 21000);
      Settings._bsmaxfreqarray[b21, mCW] := ini.ReadInteger('BandScope', '21MHzCWmax', 21450);
      Settings._bsmaxfreqarray[b21, mSSB] := ini.ReadInteger('BandScope', '21MHzPHmax', 21450);
      Settings._bsminfreqarray[b24, mCW] := ini.ReadInteger('BandScope', '24MHzCWmin', 24890);
      Settings._bsminfreqarray[b24, mSSB] := ini.ReadInteger('BandScope', '24MHzPHmin', 24890);
      Settings._bsmaxfreqarray[b24, mCW] := ini.ReadInteger('BandScope', '24MHzCWmax', 24990);
      Settings._bsmaxfreqarray[b24, mSSB] := ini.ReadInteger('BandScope', '24MHzPHmax', 24990);
      Settings._bsminfreqarray[b28, mCW] := ini.ReadInteger('BandScope', '28MHzCWmin', 28000);
      Settings._bsminfreqarray[b28, mSSB] := ini.ReadInteger('BandScope', '28MHzPHmin', 28000);
      Settings._bsmaxfreqarray[b28, mCW] := ini.ReadInteger('BandScope', '28MHzCWmax', 28500);
      Settings._bsmaxfreqarray[b28, mSSB] := ini.ReadInteger('BandScope', '28MHzPHmax', 28500);

      Settings._bsminfreqarray[b50, mCW] := ini.ReadInteger('BandScope', '50MHzCWmin', 50000);
      Settings._bsminfreqarray[b50, mSSB] := ini.ReadInteger('BandScope', '50MHzPHmin', 50000);
      Settings._bsmaxfreqarray[b50, mCW] := ini.ReadInteger('BandScope', '50MHzCWmax', 51000);
      Settings._bsmaxfreqarray[b50, mSSB] := ini.ReadInteger('BandScope', '50MHzPHmax', 51000);
      Settings._bsminfreqarray[b144, mCW] := ini.ReadInteger('BandScope', '144MHzCWmin', 144000);
      Settings._bsminfreqarray[b144, mSSB] := ini.ReadInteger('BandScope', '144MHzPHmin', 144600);
      Settings._bsmaxfreqarray[b144, mCW] := ini.ReadInteger('BandScope', '144MHzCWmax', 145600);
      Settings._bsmaxfreqarray[b144, mSSB] := ini.ReadInteger('BandScope', '144MHzPHmax', 145600);
      Settings._bsminfreqarray[b430, mCW] := ini.ReadInteger('BandScope', '430MHzCWmin', 430000);
      Settings._bsminfreqarray[b430, mSSB] := ini.ReadInteger('BandScope', '430MHzPHmin', 430000);
      Settings._bsmaxfreqarray[b430, mCW] := ini.ReadInteger('BandScope', '430MHzCWmax', 434000);
      Settings._bsmaxfreqarray[b430, mSSB] := ini.ReadInteger('BandScope', '430MHzPHmax', 434000);

      Settings._bsminfreqarray[b1200, mCW] := ini.ReadInteger('BandScope', '1200MHzCWmin', 1294000);
      Settings._bsminfreqarray[b1200, mSSB] := ini.ReadInteger('BandScope', '1200MHzPHmin', 1294600);
      Settings._bsmaxfreqarray[b1200, mCW] := ini.ReadInteger('BandScope', '1200MHzCWmax', 1294500);
      Settings._bsmaxfreqarray[b1200, mSSB] := ini.ReadInteger('BandScope', '1200MHzPHmax', 1295000);
      Settings._bsminfreqarray[b2400, mCW] := ini.ReadInteger('BandScope', '2400MHzCWmin', 2400000);
      Settings._bsminfreqarray[b2400, mSSB] := ini.ReadInteger('BandScope', '2400MHzPHmin', 2400000);
      Settings._bsmaxfreqarray[b2400, mCW] := ini.ReadInteger('BandScope', '2400MHzCWmax', 2410000);
      Settings._bsmaxfreqarray[b2400, mSSB] := ini.ReadInteger('BandScope', '2400MHzPHmax', 2410000);
      Settings._bsminfreqarray[b5600, mCW] := ini.ReadInteger('BandScope', '5600MHzCWmin', 5600000);
      Settings._bsminfreqarray[b5600, mSSB] := ini.ReadInteger('BandScope', '5600MHzPHmin', 5600000);
      Settings._bsmaxfreqarray[b5600, mCW] := ini.ReadInteger('BandScope', '5600MHzCWmax', 5610000);
      Settings._bsmaxfreqarray[b5600, mSSB] := ini.ReadInteger('BandScope', '5600MHzPHmax', 5610000);

      for b := b19 to HiBand do begin
         for m := mFM to mOther do begin
            Settings._bsminfreqarray[b, m] := Settings._bsminfreqarray[b, mSSB];
            Settings._bsmaxfreqarray[b, m] := Settings._bsmaxfreqarray[b, mSSB];
         end;
      end;
   finally
      ini.Free();
   end;
end;

procedure TOptions.LoadIniFile;
var
   i: integer;
   b: TBand;
   s: string;
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      LoadIniFileBS;

      Settings._pcname := ini.ReadString('Z-Link', 'PCName', '');
      Settings._multistationwarning := ini.ReadBool('Preferences', 'MultiStationWarning', True);

      Settings._recrigfreq := ini.ReadBool('Rig', 'RecordFreqInMemo', False);
      Settings._bsexpire := ini.ReadInteger('Misc', 'BandScopeExpire', 60);
      Settings._spotexpire := ini.ReadInteger('Misc', 'SpotExpire', 90);

      Settings._savewhennocw := ini.ReadBool('Preferences', 'SaveWhenNoCW', False);
      Settings._jmode := ini.ReadBool('Preferences', 'JMode', False);
      Settings._movetomemo := ini.ReadBool('Preferences', 'MoveToMemoWithSpace', False);

      Settings._searchafter := ini.ReadInteger('Misc', 'SearchAfter', 0);
      Settings._maxsuperhit := ini.ReadInteger('Misc', 'MaxSuperHit', 100);
      Settings._renewbythread := ini.ReadBool('Misc', 'UpdateUsingThread', False);
      Settings._displaydatepartialcheck := ini.ReadBool('Misc', 'DisplayDatePartialCheck', False);

      Settings._banddatamode := ini.ReadInteger('Rig', 'BandDataMode', 1);
      Settings._dontallowsameband := ini.ReadBool('Rig', 'DontAllowSameBand', False);
      Settings._autobandmap := ini.ReadBool('Rig', 'AutoBandMap', False);
      Settings._AFSK := ini.ReadBool('Rig', 'UseAFSK', False);

      Settings._BandData[b19] := ini.ReadInteger('Hardware', 'BandData1.9MHz', 0);
      Settings._BandData[b35] := ini.ReadInteger('Hardware', 'BandData3.5MHz', 1);
      Settings._BandData[b7] := ini.ReadInteger('Hardware', 'BandData7MHz', 2);
      Settings._BandData[b10] := ini.ReadInteger('Hardware', 'BandData10MHz', 3);
      Settings._BandData[b14] := ini.ReadInteger('Hardware', 'BandData14MHz', 4);
      Settings._BandData[b18] := ini.ReadInteger('Hardware', 'BandData18MHz', 5);
      Settings._BandData[b21] := ini.ReadInteger('Hardware', 'BandData21MHz', 6);
      Settings._BandData[b24] := ini.ReadInteger('Hardware', 'BandData24MHz', 7);
      Settings._BandData[b28] := ini.ReadInteger('Hardware', 'BandData28MHz', 8);
      Settings._BandData[b50] := ini.ReadInteger('Hardware', 'BandData50MHz', 9);
      Settings._BandData[b144] := ini.ReadInteger('Hardware', 'BandData144MHz', 10);
      Settings._BandData[b430] := ini.ReadInteger('Hardware', 'BandData430MHz', 11);
      Settings._BandData[b1200] := ini.ReadInteger('Hardware', 'BandData1200MHz', 12);
      Settings._BandData[b2400] := ini.ReadInteger('Hardware', 'BandData2400MHz', 13);
      Settings._BandData[b5600] := ini.ReadInteger('Hardware', 'BandData5600MHz', 14);
      Settings._BandData[b10g] := ini.ReadInteger('Hardware', 'BandData10GHz', 15);

      Settings._activebands[b19] := ini.ReadBool('Profiles', 'Active1.9MHz', True);
      Settings._activebands[b35] := ini.ReadBool('Profiles', 'Active3.5MHz', True);
      Settings._activebands[b7] := ini.ReadBool('Profiles', 'Active7MHz', True);
      Settings._activebands[b10] := ini.ReadBool('Profiles', 'Active10MHz', True);
      Settings._activebands[b14] := ini.ReadBool('Profiles', 'Active14MHz', True);
      Settings._activebands[b18] := ini.ReadBool('Profiles', 'Active18MHz', True);
      Settings._activebands[b21] := ini.ReadBool('Profiles', 'Active21MHz', True);
      Settings._activebands[b24] := ini.ReadBool('Profiles', 'Active24MHz', True);
      Settings._activebands[b28] := ini.ReadBool('Profiles', 'Active28MHz', True);
      Settings._activebands[b50] := ini.ReadBool('Profiles', 'Active50MHz', True);
      Settings._activebands[b144] := ini.ReadBool('Profiles', 'Active144MHz', True);
      Settings._activebands[b430] := ini.ReadBool('Profiles', 'Active430MHz', True);
      Settings._activebands[b1200] := ini.ReadBool('Profiles', 'Active1200MHz', True);
      Settings._activebands[b2400] := ini.ReadBool('Profiles', 'Active2400MHz', True);
      Settings._activebands[b5600] := ini.ReadBool('Profiles', 'Active5600MHz', True);
      Settings._activebands[b10g] := ini.ReadBool('Profiles', 'Active10GHz', True);

      s := ini.ReadString('Profiles', 'Power', '');
      b := b19;
      if length(s) > 13 then begin
         s := Copy(s, 1, 13);
      end;

      for i := 1 to length(s) do begin
         case UpCase(s[i]) of
            'P':
               CurrentPower[b] := pwrP;
            'L':
               CurrentPower[b] := pwrL;
            'M':
               CurrentPower[b] := pwrM;
            'H':
               CurrentPower[b] := pwrH;
         end;

         repeat
            inc(b);
         until NotWARC(b);
      end;

      Settings._multiop := ini.ReadInteger('Categories', 'Operator2', 0);
      Settings._multistation := ini.ReadBool('Categories', 'MultiStn', False);
      Settings._band := ini.ReadInteger('Categories', 'Band', 0);
      Settings._mode := ini.ReadInteger('Categories', 'Mode', 0);
      Settings._txnr := ini.ReadInteger('Categories', 'TXNumber', 0);
      Settings._contestmenuno := ini.ReadInteger('Categories', 'Contest', 1);
      Settings._mycall := ini.ReadString('Categories', 'MyCall', 'Your call sign');

      Settings._backuppath := ini.ReadString('Preferences', 'BackUpPath', '');
      Settings._cfgdatpath := ini.ReadString('Preferences', 'CFGDATPath', '');
      Settings._logspath := ini.ReadString('Preferences', 'LogsPath', '');

      Settings._allowdupe := ini.ReadBool('Preferences', 'AllowDupe', False);
      Settings._saveevery := ini.ReadInteger('Preferences', 'SaveEvery', 3);

      Settings._entersuperexchange := ini.ReadBool('Preferences', 'AutoEnterSuper', False);

      Settings._countdown := ini.ReadBool('Preferences', 'CountDown', False);
      Settings._qsycount := ini.ReadBool('Preferences', 'QSYCount', False);

      Settings._prov := ini.ReadString('Profiles', 'Province/State', '');
      Settings._city := ini.ReadString('Profiles', 'City', '');
      Settings._cqzone := ini.ReadString('Profiles', 'CQZone', '');
      Settings._iaruzone := ini.ReadString('Profiles', 'IARUZone', '');

      Settings._clusterport := ini.ReadInteger('Hardware', 'PacketCluster', 0);

      Settings._rig1port := ini.ReadInteger('Hardware', 'Rig', 0);
      Settings._ritclear := ini.ReadBool('Hardware', 'RitClear', False);
      Settings._rig1name := ini.ReadInteger('Hardware', 'RigName', 0);

      Settings._rig2port := ini.ReadInteger('Hardware', 'Rig2', 0);
      Settings._rig2name := ini.ReadInteger('Hardware', 'RigName2', 0);

      Settings._zlinkport := ini.ReadInteger('Hardware', 'Z-Link', 0);

      Settings._clusterbaud := ini.ReadInteger('Hardware', 'PacketClusterBaud', 6);
      Settings._rigbaud := ini.ReadInteger('Hardware', 'RigBaud', 6);
      Settings._icombaudrate := ini.ReadInteger('Hardware', 'IcomBaudRate', 1);

      Settings._zlinkbaud := ini.ReadInteger('Hardware', 'Z-LinkBaud', 6);

      Settings._pttenabled := ini.ReadBool('Hardware', 'PTTEnabled', False);
      Settings._pttbefore := ini.ReadInteger('Hardware', 'PTTBefore', 25);
      Settings._pttafter := ini.ReadInteger('Hardware', 'PTTAfter', 0);

      Settings._clusterhost := ini.ReadString('PacketCluster', 'TELNEThost', '');
      Settings._clustertelnetport := ini.ReadInteger('PacketCluster', 'TELNETport', 23);

      Settings._clusterlinebreakTELNET := ini.ReadInteger('PacketCluster', 'TELNETlinebreak', 0);
      Settings._clusterlocalechoTELNET := ini.ReadBool('PacketCluster', 'TELNETlocalecho', False);
      Settings._clusterlinebreakCOM := ini.ReadInteger('PacketCluster', 'COMlinebreak', 0);
      Settings._clusterlocalechoCOM := ini.ReadBool('PacketCluster', 'COMlocalecho', False);

      Settings._zlinkhost := ini.ReadString('Z-Link', 'TELNEThost', '');
      Settings._zlinklinebreakTELNET := ini.ReadInteger('Z-Link', 'TELNETlinebreak', 0);
      Settings._zlinklocalechoTELNET := ini.ReadBool('Z-Link', 'TELNETlocalecho', False);
      Settings._zlinklinebreakCOM := ini.ReadInteger('Z-Link', 'COMlinebreak', 0);
      Settings._zlinklocalechoCOM := ini.ReadBool('Z-Link', 'COMlocalecho', False);

      Settings._syncserial := ini.ReadBool('Z-Link', 'SyncSerial', False);

      Settings.CW._interval := ini.ReadInteger('CW', 'Interval', 1);
      Settings.CW._speed := ini.ReadInteger('CW', 'Speed', 25);
      Settings.CW._weight := ini.ReadInteger('CW', 'Weight', 50);
      Settings.CW._cqmax := ini.ReadInteger('CW', 'CQMax', 15);
      Settings.CW._tonepitch := ini.ReadInteger('CW', 'Pitch', 800);
      Settings.CW._paddlereverse := ini.ReadBool('CW', 'PaddleReverse', False);
      Settings.CW._paddle := ini.ReadBool('CW', 'PaddleEnabled', True);
      Settings.CW._FIFO := ini.ReadBool('CW', 'FIFO', True);
      Settings._switchcqsp := ini.ReadBool('CW', 'CQSP', False);
      Settings.CW._sidetone := ini.ReadBool('CW', 'SideTone', True);
      Settings.CW._cqrepeat := ini.ReadFloat('CW', 'CQRepeat', 2.0);
      Settings._sendfreq := ini.ReadFloat('Rig', 'SendFreq', 1.0);

      s := ini.ReadString('CW', 'Zero', 'O');
      Settings.CW._zero := char(s[1]);

      s := ini.ReadString('CW', 'One', 'A');
      Settings.CW._one := char(s[1]);

      s := ini.ReadString('CW', 'Nine', 'N');
      Settings.CW._nine := char(s[1]);

      Settings.CW.CWStrBank[1, 1] := ini.ReadString('CW', 'F1', 'CQ TEST $M $M TEST');
      Settings.CW.CWStrBank[1, 2] := ini.ReadString('CW', 'F2', '$C 5NN$X');
      Settings.CW.CWStrBank[1, 3] := ini.ReadString('CW', 'F3', 'TU $M TEST');
      Settings.CW.CWStrBank[1, 4] := ini.ReadString('CW', 'F4', 'QSO B4 TU');
      Settings.CW.CWStrBank[1, 5] := ini.ReadString('CW', 'F5', 'NR?');

      for i := 6 to maxstr do begin
         Settings.CW.CWStrBank[1, i] := ini.ReadString('CW', 'F' + IntToStr(i), '');
      end;

      Settings.CW.CWStrBank[3, 1] := ini.ReadString('RTTY', 'F1', 'CQ CQ CQ TEST $M $M $M TEST K');
      Settings.CW.CWStrBank[3, 2] := ini.ReadString('RTTY', 'F2', '$C DE $M 599$X 599$X BK');
      Settings.CW.CWStrBank[3, 3] := ini.ReadString('RTTY', 'F3', 'TU DE $M TEST');
      Settings.CW.CWStrBank[3, 4] := ini.ReadString('RTTY', 'F4', 'QSO B4 TU');
      Settings.CW.CWStrBank[3, 5] := ini.ReadString('RTTY', 'F5', 'NR? NR? AGN BK');

      for i := 6 to maxstr do begin
         Settings.CW.CWStrBank[3, i] := ini.ReadString('RTTY', 'F' + IntToStr(i), '');
      end;

      Settings._transverter1 := ini.ReadBool('Hardware', 'Transverter1', False);
      Settings._transverteroffset1 := ini.ReadInteger('Hardware', 'Transverter1Offset', 0);
      Settings._transverter2 := ini.ReadBool('Hardware', 'Transverter2', False);
      Settings._transverteroffset2 := ini.ReadInteger('Hardware', 'Transverter2Offset', 0);

      for i := 1 to maxstr do begin
         Settings.CW.CWStrBank[2, i] := ini.ReadString('CW', 'F' + IntToStr(i) + 'B', '');
      end;

      for i := 11 to 12 do begin
         Settings.CW.CWStrBank[1, i] := ini.ReadString('CW', 'F' + IntToStr(i), '');
         Settings.CW.CWStrBank[2, i] := ini.ReadString('CW', 'F' + IntToStr(i) + 'B', '');
         Settings.CW.CWStrBank[3, i] := ini.ReadString('RTTY', 'F' + IntToStr(i), '');
      end;

      Settings.CW.CQStrBank[1] := ini.ReadString('CW', 'CQ2', '');
      Settings.CW.CQStrBank[2] := ini.ReadString('CW', 'CQ3', '');
      Settings.CW._fixwpm := ini.ReadInteger('CW', 'FixedSpeed', 20);

      for i := 1 to maxstr do begin
         Settings._SoundFiles[i] := ini.ReadString('Voice', 'F' + IntToStr(i), 'select');
         Settings._SoundComments[i] := ini.ReadString('Voice', 'F' + IntToStr(i) + '_Comment', '');
      end;
      Settings._SoundFiles[9] := ini.ReadString('Voice', 'CQ2', 'select');
      Settings._SoundFiles[10] := ini.ReadString('Voice', 'CQ3', 'select');

      Settings._SoundComments[9] := ini.ReadString('Voice', 'CQ2_Comment', '');
      Settings._SoundComments[10] := ini.ReadString('Voice', 'CQ3_Comment', '');

      Settings._specificcwport := ini.ReadInteger('Hardware', 'UseCWPort', 0 { $037A } );
      Settings._lptnr := ini.ReadInteger('Hardware', 'CWLPTPort', 0);
      // Settings._usedata := ini.ReadBool('Hardware','CWUseData',false);

      Settings._reverselogic := ini.ReadBool('Hardware', 'CWInvLogic', False);
      Settings._rigreverse := ini.ReadBool('Hardware', 'RigInvLogic', False);
      Settings._pttreverse := ini.ReadBool('Hardware', 'PTTInvLogic', False);

      Settings._mainfontsize := ini.ReadInteger('Preferences', 'FontSize', 9);
      Settings._mainrowheight := ini.ReadInteger('Preferences', 'RowHeight', 18);

      Settings.CW._spacefactor := ini.ReadInteger('CW', 'SpaceFactor', 100);
      Settings.CW._eispacefactor := ini.ReadInteger('CW', 'EISpaceFactor', 100);
   finally
      ini.Free();
   end;
end;

procedure TOptions.ImplementSettings(_OnCreate: boolean);
var
   m: TMenuItem;
   i, j: integer;
   b: TBand;
begin
   if _OnCreate = False then begin
      for b := b19 to HiBand do begin
         MainForm.BandMenu.Items[ord(b)].Enabled := Settings._activebands[b];
      end;

      if Settings._band > 0 then begin // single band
         SetBand(Settings._band); // resets the bandmenu.items.enabled for the single band entry
      end;
   end;

   if MyContest <> nil then begin
      Main.MyContest.SameExchange := Settings._sameexchange;
   end;

   RigControl.SetBandMask;
   // BGK32LIB.UpdateDataPort;

   if Settings._zlinkport in [1 .. 6] then begin // zlinkport rs232c
      // ZLinkForm.Transparent := True;
      // no rs232c anymore
   end;

   CommForm.EnableConnectButton(Settings._clusterport = 7);

   CommForm.ImplementOptions;
   ZLinkForm.ImplementOptions;

   // ver 1,3
   // BGK32LIB.SetCWPortDirect(Settings._cwport);
   if Settings._lptnr in [1 .. LPTMAX] then begin
      // RigControl.ZCom3.Disconnect;
      // BGK32LIB.KeyingPort := tkpParallel;
      // BGK32LIB.SetCWPortDirect(LPTport[Settings._lptnr]);
      // if Settings._specificcwport > 0 then
      // BGK32LIB.SetCWPortDirect(Settings._specificcwport);
      // if Settings._reverselogic then
      // BGK32LIB.ReverseLogicKeying(True);
      // if Settings._rigreverse then
      // BGK32LIB.ReverseRigOut(True);
      // if Settings._pttreverse then
      // BGK32LIB.ReversePTTOut(True);
      //
      // if Settings.CW._paddle then
      // begin
      // BGK32LIB.SetPaddlePortDirect(LPTport[Settings._lptnr]-1);
      // if PaddleThread = nil then // ver 1.3
      // PaddleThread := TPaddleThread.Create(False);
      // end
      // else
      // begin
      // if PaddleThread <> nil then
      // PaddleThread.Terminate;
      // BGK32LIB.SetPaddlePortDirect($00);
      // end;
      //
      // BGK32LIB.SetPTTportDirect(LPTport[Settings._lptnr] - 2);
   end
   else begin // Settings._lptnr <> parallel ports
      Case Settings._lptnr of
         0: begin
               BGK32Lib.KeyingPort := tkpNone;
            end;
         11: begin
               RigControl.SetSerialCWKeying(1);
               BGK32Lib.KeyingPort := tkpSerial1;
            end;

         12: begin
               RigControl.SetSerialCWKeying(2);
               BGK32Lib.KeyingPort := tkpSerial2;
            end;

         21: begin // usb
               BGK32Lib.KeyingPort := tkpUSB;

               if Settings.CW._paddle then begin
                  BGK32Lib.SetPaddlePortDirect($99);
                  if PaddleThread = nil then begin
                     PaddleThread := TPaddleThread.Create(True);
                  end;
               end
               else begin
                  BGK32Lib.SetPaddlePortDirect($00);
                  if PaddleThread = nil then begin
                     PaddleThread := TPaddleThread.Create(True);
                  end;
               end;
            end;
      end;
   end;

   RigControl.ImplementOptions;
   BGK32Lib.SetPTTDelay(Settings._pttbefore, Settings._pttafter);
   BGK32Lib.SetPTT(Settings._pttenabled);

   // SetBand(Settings._band);
   SetMode(Settings._mode);
   SetPaddleReverse(Settings.CW._paddlereverse);
   SetSpeed(Settings.CW._speed);
   SetSideTone(Settings.CW._sidetone);
   SetWeight(Settings.CW._weight);
   SetCQMax(Settings.CW._cqmax);
   SetCQRepeat(Settings.CW._cqrepeat);
   SetSendFreq(Settings._sendfreq);
   SetTonePitch(Settings.CW._tonepitch);
   BGK32Lib.SetRandCQStr(SetStr(Settings.CW.CQStrBank[1], CurrentQSO), SetStr(Settings.CW.CQStrBank[2], CurrentQSO));

   BGK32Lib.SetSpaceFactor(Settings.CW._spacefactor);
   BGK32Lib.SetEISpaceFactor(Settings.CW._eispacefactor);

   AllowDupe := Settings._allowdupe;

   if Settings._backuppath = '' then begin
      MainForm.BackUp1.Enabled := False;
   end
   else begin
      MainForm.BackUp1.Enabled := True;
   end;

   if Settings._multistation = True then begin
      Settings._txnr := 2;
   end;

   if not(_OnCreate) then begin
      j := MainForm.OpMenu.Items.Count;
      if j > 0 then begin
         for i := 1 to j do begin
            MainForm.OpMenu.Items.Delete(0);
         end;
      end;

      if OpList.Count > 0 then begin
         m := TMenuItem.Create(Self);
         m.Caption := 'Clear';
         m.OnClick := MainForm.OpMenuClick;
         MainForm.OpMenu.Items.Add(m);
         for i := 0 to OpList.Count - 1 do begin
            m := TMenuItem.Create(Self);
            m.Caption := TrimRight(Copy(OpList.Strings[i], 1, 20));
            m.OnClick := MainForm.OpMenuClick;
            MainForm.OpMenu.Items.Add(m);
         end;
      end;
   end;
end;

procedure TOptions.RenewSettings;
var
   r: double;
   i, j: integer;
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

   Settings._activebands[b19] := act19.Checked;
   Settings._activebands[b35] := act35.Checked;
   Settings._activebands[b7] := act7.Checked;
   Settings._activebands[b10] := act10.Checked;
   Settings._activebands[b14] := act14.Checked;
   Settings._activebands[b18] := act18.Checked;
   Settings._activebands[b21] := act21.Checked;
   Settings._activebands[b24] := act24.Checked;
   Settings._activebands[b28] := act28.Checked;
   Settings._activebands[b50] := act50.Checked;
   Settings._activebands[b144] := act144.Checked;
   Settings._activebands[b430] := act430.Checked;
   Settings._activebands[b1200] := act1200.Checked;
   Settings._activebands[b2400] := act2400.Checked;
   Settings._activebands[b5600] := act5600.Checked;
   Settings._activebands[b10g] := act10g.Checked;

   OpList.Free;
   OpList := TStringList.Create;
   OpList.Assign(OpListBox.Items);

   // Settings._band := BandGroup.ItemIndex;
   case BandGroup.ItemIndex of
      0 .. 3:
         Settings._band := BandGroup.ItemIndex;
      4:
         Settings._band := BandGroup.ItemIndex + 1;
      5:
         Settings._band := BandGroup.ItemIndex + 2;
      6 .. 13:
         Settings._band := BandGroup.ItemIndex + 3;
   end;

   Settings._mode := ModeGroup.ItemIndex;
   // Settings._multiop := MultiOpRadioBtn.Checked;

   Settings._prov := ProvEdit.Text;
   Settings._city := CItyEdit.Text;
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
         Settings.CW.CWStrBank[i, j] := TempCWStrBank[i, j];

   Settings.CW.CQStrBank[0] := TempCWStrBank[1, 1];

   Settings.CW.CQStrBank[1] := Edit9.Text;
   Settings.CW.CQStrBank[2] := Edit10.Text;

   for i := 1 to 10 do begin
      Settings._SoundFiles[i] := TempVoiceFiles[i];
   end;

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

   r := Settings.CW._cqrepeat;
   Settings.CW._cqrepeat := StrToFloatDef(CQRepEdit.Text, r);

   r := Settings._sendfreq;
   Settings._sendfreq := StrToFloatDef(SendFreqEdit.Text, r);

   Settings.CW._speed := SpeedBar.Position;
   Settings.CW._weight := WeightBar.Position;
   Settings.CW._paddlereverse := PaddleCheck.Checked;
   Settings.CW._sidetone := SideToneCheck.Checked;
   Settings.CW._FIFO := FIFOCheck.Checked;
   Settings.CW._tonepitch := ToneSpinEdit.Value;
   Settings.CW._cqmax := CQmaxSpinEdit.Value;
   Settings.CW._paddle := PaddleEnabledCheck.Checked;

   Settings._switchcqsp := cbCQSP.Checked;

   if length(AbbrevEdit.Text) >= 3 then begin
      Settings.CW._zero := AbbrevEdit.Text[1];
      Settings.CW._one := AbbrevEdit.Text[2];
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
   // Settings._zlinkbaud := ZLinkCOMSet.BaudCombo.ItemIndex;

   // Settings._zlinkhost := ZLinkTelnetSet.HostName.Text;
   // Settings._zlinklinebreakTELNET := ZLinkTelnetSet.LineBreak.ItemIndex;
   // Settings._zlinklocalechoTELNET := ZLinkTelnetSet.LocalEcho.Checked;
   // Settings._zlinklinebreakCOM := ZLinkCOMSet.LineBreak.ItemIndex;
   // Settings._zlinklocalechoCOM := ZLinkCOMSet.LocalEcho.Checked;

   Settings._pttenabled := PTTEnabledCheckBox.Checked;
   Settings._saveevery := SaveEvery.Value;
   Settings._countdown := cbCountDown.Checked;
   Settings._qsycount := cbQSYCount.Checked;

   i := Settings._pttbefore;
   Settings._pttbefore := StrToIntDef(BeforeEdit.Text, i);

   i := Settings._pttafter;
   Settings._pttafter := StrToIntDef(AfterEdit.Text, i);

   { i := HexStrToInt(CWPortEdit.Text);
     if i > 0 then
     Settings._cwport := i; }

   // if rbLPT1.Checked then
   // Settings._lptnr := 1;
   // if rbLPT2.Checked then
   // Settings._lptnr := 2;

   if radioCwNone.Checked = True then begin
      Settings._lptnr := 0;
   end;
   if radioCwCom1.Checked then begin
      Settings._lptnr := 11;
   end;
   if radioCwCom2.Checked then begin
      Settings._lptnr := 12;
   end;
   if radioCwUsb.Checked then begin
      Settings._lptnr := 21;
   end;

   Settings._sentstr := SentEdit.Text;

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
   SaveCurrentSettings();

   MainForm.RenewCWToolBar;
   MainForm.RenewVoiceToolBar;

   Close;
   MainForm.LastFocus.SetFocus;
end;

procedure TOptions.RenewCWStrBankDisp;
begin
   Edit1.Text := TempCWStrBank[TempCurrentBank, 1];
   Edit2.Text := TempCWStrBank[TempCurrentBank, 2];
   Edit3.Text := TempCWStrBank[TempCurrentBank, 3];
   Edit4.Text := TempCWStrBank[TempCurrentBank, 4];
   Edit5.Text := TempCWStrBank[TempCurrentBank, 5];
   Edit6.Text := TempCWStrBank[TempCurrentBank, 6];
   Edit7.Text := TempCWStrBank[TempCurrentBank, 7];
   Edit8.Text := TempCWStrBank[TempCurrentBank, 8];
end;

procedure TOptions.FormShow(Sender: TObject);
var
   i, j: integer;
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
      BandGroup.ItemIndex := OldBandOrd(TBand(Settings._band - 1)) + 1;
   ModeGroup.ItemIndex := Settings._mode;
   { OpListBox.Items := OpList; }

   for i := 1 to maxbank do
      for j := 1 to maxstr do
         TempCWStrBank[i, j] := Settings.CW.CWStrBank[i, j];

   TempCurrentBank := Settings.CW.CurrentBank;
   case TempCurrentBank of
      1:
         rbBankA.Checked := True;
      2:
         rbBankB.Checked := True;
      3:
         rbRTTY.Checked := True;
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

   for i := 1 to 10 do
      TempVoiceFiles[i] := Settings._SoundFiles[i];

   CQRepEdit.Text := FloatToStrF(Settings.CW._cqrepeat, ffFixed, 3, 1);
   SendFreqEdit.Text := FloatToStrF(Settings._sendfreq, ffFixed, 3, 1);
   SpeedBar.Position := Settings.CW._speed;
   SpeedLabel.Caption := IntToStr(Settings.CW._speed) + ' wpm';
   WeightBar.Position := Settings.CW._weight;
   WeightLabel.Caption := IntToStr(Settings.CW._weight) + ' %';
   PaddleCheck.Checked := Settings.CW._paddlereverse;
   PaddleEnabledCheck.Checked := Settings.CW._paddle;
   SideToneCheck.Checked := Settings.CW._sidetone;
   FIFOCheck.Checked := Settings.CW._FIFO;
   ToneSpinEdit.Value := Settings.CW._tonepitch;
   CQmaxSpinEdit.Value := Settings.CW._cqmax;
   AbbrevEdit.Text := Settings.CW._zero + Settings.CW._one + Settings.CW._nine;

   ProvEdit.Text := Settings._prov;
   CItyEdit.Text := Settings._city;
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

   PCsetButton.Enabled := True;
   case ClusterCombo.ItemIndex of
      0:
         PCsetButton.Enabled := False;
      1 .. 6:
         PCsetButton.Caption := 'COM port settings';
      7:
         PCsetButton.Caption := 'TELNET settings';
   end;

   buttonZLinkSettings.Enabled := True;
   case ZLinkCombo.ItemIndex of
      0:
         buttonZLinkSettings.Enabled := False;
      1:
         buttonZLinkSettings.Caption := 'TELNET settings';
   end;

   SaveEvery.Value := Settings._saveevery;

   ClusterCOMSet.SetVisuals;
   ClusterTelnetSet.SetVisuals;

   // ZLinkCOMSet.SetVisuals;
   // ZLinkTelnetSet.SetVisuals;

   // if LPTport[1] = 0 then
   // rbLPT1.Enabled := False
   // else
   // rbLPT1.Enabled := True;

   // if LPTport[2] = 0 then
   // rbLPT2.Enabled := False
   // else
   // rbLPT2.Enabled := True;

   // if Settings._lptnr = 1 then
   // rbLPT1.Checked := True;
   // if Settings._lptnr = 2 then
   // rbLPT2.Checked := True;

   if Settings._lptnr = 0 then begin
      radioCwNone.Checked := True;
   end;
   if Settings._lptnr = 11 then begin
      radioCwCom1.Checked := True;
   end;
   if Settings._lptnr = 12 then begin
      radioCwCom2.Checked := True;
   end;
   if Settings._lptnr = 21 then begin
      radioCwUsb.Checked := True;
   end;

   SentEdit.Text := Settings._sentstr;

   BackUpPathEdit.Text := Settings._backuppath;
   edCFGDATPath.Text := Settings._cfgdatpath;
   edLogsPath.Text := Settings._logspath;

   PTTEnabledCheckBox.Checked := Settings._pttenabled;
   BeforeEdit.Text := IntToStr(Settings._pttbefore);
   AfterEdit.Text := IntToStr(Settings._pttafter);
   if PTTEnabledCheckBox.Checked then begin
      BeforeEdit.Enabled := True;
      AfterEdit.Enabled := True;
   end
   else begin
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
var
   str: string;
begin
   if OpEdit.Text <> '' then begin
      str := OpEdit.Text;
      if OpPowerEdit.Text <> '' then
         str := FillRight(str, 20) + OpPowerEdit.Text;
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
var
   filename: string;
   b: TBand;
   i: integer;
   VerInfo: TOSVersionInfo;
begin
   VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
   GetVersionEx(VerInfo);

   if VerInfo.dwPlatformId = VER_PLATFORM_WIN32_NT then begin
      ZLOG_WIN2KMODE := True;
      BGK32Lib._WIN2KMODE := ZLOG_WIN2KMODE;
   end;

   for b := b19 to b10g do begin
      CurrentPower[b] := pwrP;
      CurrentPower2[b] := 500;
   end;

   LoadIniFile;
   Settings.CW.CurrentBank := 1;
   TempCurrentBank := 1;

   // オペレーターリスト
   Options.OpList := TStringList.Create;
   try
      filename := MAINPATH + 'ZLOG.OP';
      if FileExists(filename) then begin
         OpList.LoadFromFile(filename);
      end;
   except
      on EFOpenError do begin
      end;
   end;

   OpListBox.Items.Assign(OpList);

   PageControl.ActivePage := PrefTabSheet;

   Rig1Combo.Items.Clear;
   Rig2Combo.Items.Clear;

   for i := 0 to RIGNAMEMAX do begin
      Rig1Combo.Items.Add(RIGNAMES[i]);
      Rig2Combo.Items.Add(RIGNAMES[i]);
   end;
end;

procedure TOptions.Button2Click(Sender: TObject);
begin
   Close;
   MainForm.LastFocus.SetFocus;
end;

procedure TOptions.OpEditKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
   case Key of
      VK_RETURN:
         AddClick(Self);
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
   SaveCurrentSettings; { Writes Settings to Inifile }
   MainForm.RenewCWToolBar;
   MainForm.RenewVoiceToolBar;
end;

procedure TOptions.SpeedBarChange(Sender: TObject);
begin
   SpeedLabel.Caption := IntToStr(SpeedBar.Position) + ' wpm';
end;

procedure TOptions.WeightBarChange(Sender: TObject);
begin
   WeightLabel.Caption := IntToStr(WeightBar.Position) + ' %';
end;

procedure TOptions.FormDestroy(Sender: TObject);
begin
   OpList.Free;
end;

procedure TOptions.vButtonClick(Sender: TObject);
begin
   if OpenDialog.Execute then begin
      TempVoiceFiles[TButton(Sender).Tag] := OpenDialog.filename;
      TLabel(Sender).Caption := ExtractFileName(OpenDialog.filename);
   end;
end;

procedure TOptions.ClusterComboChange(Sender: TObject);
begin
   PCsetButton.Enabled := True;
   case ClusterCombo.ItemIndex of
      0:
         PCsetButton.Enabled := False;
      1 .. 6:
         PCsetButton.Caption := 'COM port settings';
      7:
         PCsetButton.Caption := 'TELNET settings';
   end;
end;

procedure TOptions.PCsetButtonClick(Sender: TObject);
begin
   if PCsetButton.Caption = 'COM port settings' then
      ClusterCOMSet.ShowModal
   else
      ClusterTelnetSet.ShowModal;
end;

procedure TOptions.ZLinkComboChange(Sender: TObject);
begin
   if ZLinkCombo.ItemIndex = 0 then begin
      buttonZLinkSettings.Enabled := False;
   end
   else begin
      buttonZLinkSettings.Enabled := True;
   end;
end;

procedure TOptions.buttonZLinkSettingsClick(Sender: TObject);
var
   F: TformZLinkTelnetSet;
begin
   F := TformZLinkTelnetSet.Create(Self);
   try
      F.HostName := Options.Settings._zlinkhost;
      F.LineBreak := Options.Settings._zlinklinebreakTELNET;
      F.LocalEcho := Options.Settings._zlinklocalechoTELNET;

      if F.ShowModal() <> mrOK then begin
         exit;
      end;

      Options.Settings._zlinkhost := F.HostName;
      Options.Settings._zlinklinebreakTELNET := F.LineBreak;
      Options.Settings._zlinklocalechoTELNET := F.LocalEcho;
   finally
      F.Release();
   end;
end;

procedure TOptions.BrowsePathClick(Sender: TObject);
var
   strDir: string;
begin
   case TButton(Sender).Tag of
      0:
         strDir := BackUpPathEdit.Text;
      10:
         strDir := edCFGDATPath.Text;
      20:
         strDir := edLogsPath.Text;
   end;

   if SelectDirectory('フォルダの参照', '', strDir, [sdNewFolder, sdNewUI, sdValidateDir], Self) = False then begin
      exit;
   end;

   case TButton(Sender).Tag of
      0:
         BackUpPathEdit.Text := strDir;
      10:
         edCFGDATPath.Text := strDir;
      20:
         edLogsPath.Text := strDir;
   end;
end;

procedure TOptions.PTTEnabledCheckBoxClick(Sender: TObject);
begin
   if PTTEnabledCheckBox.Checked then begin
      BeforeEdit.Enabled := True;
      AfterEdit.Enabled := True;
   end
   else begin
      BeforeEdit.Enabled := False;
      AfterEdit.Enabled := False;
   end;
end;

procedure TOptions.CQRepEditKeyPress(Sender: TObject; var Key: char);
begin
   if not(SysUtils.CharInSet(Key, ['0' .. '9', '.'])) then begin
      Key := #0;
   end;
end;

procedure TOptions.Edit1Change(Sender: TObject);
var
   i: integer;
begin
   i := TEdit(Sender).Tag;
   TempCWStrBank[TempCurrentBank, i] := TEdit(Sender).Text;
end;

procedure TOptions.CWBankClick(Sender: TObject);
begin
   TempCurrentBank := TRadioButton(Sender).Tag;
   RenewCWStrBankDisp;
end;

function TOptions.PTTEnabled: boolean;
begin
   Result := Settings._pttenabled;
end;

procedure TOptions.ReadWin(WinName: string; var Open: boolean; var X, Y, H, W: integer);
var
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      Open := ini.ReadBool('Windows', WinName + '_Open', False);
      X := ini.ReadInteger('Windows', WinName + '_X', 10);
      Y := ini.ReadInteger('Windows', WinName + '_Y', 10);
      H := ini.ReadInteger('Windows', WinName + '_H', 10);
      W := ini.ReadInteger('Windows', WinName + '_W', 10);
   finally
      ini.Free();
   end;
end;

procedure TOptions.ReadWin2(WinName: string; var F: TForm);
var
   i: integer;
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      i := ini.ReadInteger('Windows', WinName + '_X', -1);
      if i > 0 then begin
         F.Left := i;
      end;

      i := ini.ReadInteger('Windows', WinName + '_Y', -1);
      if i > 0 then begin
         F.Top := i;
      end;

      i := ini.ReadInteger('Windows', WinName + '_W', -1);
      if i > 0 then begin
         F.Width := i;
      end;

      i := ini.ReadInteger('Windows', WinName + '_H', -1);
      if i > 0 then begin
         F.Height := i;
      end;

      F.Visible := ini.ReadBool('Windows', WinName + '_Open', False);
   finally
      ini.Free();
   end;
end;

procedure TOptions.RecordWin(WinName: string; Open: boolean; X, Y: integer);
var
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      ini.WriteBool('Windows', WinName + '_Open', Open);
      ini.WriteInteger('Windows', WinName + '_X', X);
      ini.WriteInteger('Windows', WinName + '_Y', Y);
   finally
      ini.Free();
   end;
end;

procedure TOptions.RecordSuperCheckColumns(c: integer);
var
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      ini.WriteInteger('Windows', 'SuperCheckColumns', c);
   finally
      ini.Free();
   end;
end;

function TOptions.GetSuperCheckColumns: integer;
var
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      Result := ini.ReadInteger('Windows', 'SuperCheckColumns', 0);
   finally
      ini.Free();
   end;
end;

procedure TOptions.RecordWin2(WinName: string; F: TForm);
var
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      ini.WriteBool('Windows', WinName + '_Open', F.Visible);
      ini.WriteInteger('Windows', WinName + '_X', F.Left);
      ini.WriteInteger('Windows', WinName + '_Y', F.Top);
      ini.WriteInteger('Windows', WinName + '_H', F.Height);
      ini.WriteInteger('Windows', WinName + '_W', F.Width);
   finally
      ini.Free();
   end;
end;

procedure TOptions.RestoreMainForm(var X, Y, W, H: integer; var TB1, TB2: boolean);
var
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      X := ini.ReadInteger('Windows', 'Main_X', 0);
      Y := ini.ReadInteger('Windows', 'Main_Y', 0);
      W := ini.ReadInteger('Windows', 'Main_W', 0);
      H := ini.ReadInteger('Windows', 'Main_H', 0);
      TB1 := ini.ReadBool('Windows', 'Main_ToolBar1', False);
      TB2 := ini.ReadBool('Windows', 'Main_ToolBar2', False);
   finally
      ini.Free();
   end;
end;

procedure TOptions.RecordMainForm(X, Y, W, H: integer; TB1, TB2: boolean);
var
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      ini.WriteInteger('Windows', 'Main_X', X);
      ini.WriteInteger('Windows', 'Main_Y', Y);
      ini.WriteInteger('Windows', 'Main_W', W);
      ini.WriteInteger('Windows', 'Main_H', H);
      ini.WriteBool('Windows', 'Main_ToolBar1', TB1);
      ini.WriteBool('Windows', 'Main_ToolBar2', TB2);
   finally
      ini.Free();
   end;
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
var
   i, r: integer;
begin
   r := TCheckBox(Sender).Tag;
   r := r - 100;

   if TCheckBox(Sender).Checked then begin
      i := 0;
      if r = 1 then
         i := Settings._transverteroffset1;
      if r = 2 then
         i := Settings._transverteroffset2;

      IntegerDialog.Init(i, 'Please input the offset frequency in kHz');
      IntegerDialog.ShowModal;
      i := IntegerDialog.GetValue;
      if i <> -1 then begin
         if r = 1 then
            Settings._transverteroffset1 := i;
         if r = 2 then
            Settings._transverteroffset2 := i;
      end;
   end;

end;

procedure TOptions.Rig1ComboChange(Sender: TObject);
begin
   if Rig1Combo.ItemIndex = RIGNAMEMAX then begin
      Rig2Combo.ItemIndex := RIGNAMEMAX;
      Rig1PortCombo.ItemIndex := 0;
      Rig1PortCombo.Enabled := False;
      Rig2PortCombo.Enabled := False;
   end
   else begin
      Rig1PortCombo.Enabled := True;
      if Rig2Combo.ItemIndex = RIGNAMEMAX then begin
         Rig2PortCombo.ItemIndex := 0;
         Rig2Combo.ItemIndex := 0;
         Rig2PortCombo.Enabled := True;
      end;
   end;
end;

procedure TOptions.Rig2ComboChange(Sender: TObject);
begin
   if Rig2Combo.ItemIndex = RIGNAMEMAX then begin
      Rig1Combo.ItemIndex := RIGNAMEMAX;
      Rig2PortCombo.ItemIndex := 0;
      Rig2PortCombo.Enabled := False;
      Rig1PortCombo.Enabled := False;
   end
   else begin
      Rig2PortCombo.Enabled := True;
      if Rig1Combo.ItemIndex = RIGNAMEMAX then begin
         Rig1PortCombo.ItemIndex := 0;
         Rig1Combo.ItemIndex := 0;
         Rig1PortCombo.Enabled := True;
      end;
   end;
end;

end.
