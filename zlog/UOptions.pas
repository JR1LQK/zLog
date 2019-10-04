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

  TCommParam = record
    FHostName: string;
    FPortNumber: Integer;
    FBaudRate: Integer;
    FLineBreak: Integer;
    FLocalEcho: Boolean;
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

    _autobandmap: boolean;
    _activebands : array[b19..HiBand] of boolean;
    CW : TCWSettingsParam;
    _clusterport : integer; {0 : none 1-4 : com# 5 : telnet}
    _rig1port : integer; {0 : none 1-4 : com#}
    _rig1name : integer;
    _rig2port : integer; {0 : none 1-4 : com#}
    _rig2name : integer;
    _zlinkport : integer; {0 : none 1-4 : com# 5: telnet}
    _clusterbaud : integer; {}
    _icombaudrate : integer;

    _cluster_telnet: TCommParam;
    _cluster_com: TCommParam;
    _zlink_telnet: TCommParam;

    _multistationwarning : boolean; // true by default. turn off not new mult warning dialog
    _lptnr : integer; {1 : LPT1; 2 : LPT2;  11:COM1; 12 : COM2;  21: USB}
    _sentstr : string; {exchanges sent $Q$P$O etc. Set at menu select}

    _backuppath : string;
    _cfgdatpath : string;
    _logspath : string;

    _pttenabled : boolean;
    _pttbefore : word;
    _pttafter  : word;
    _txnr : byte;
    _pcname : string;
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
    buttonOK: TButton;
    buttonCancel: TButton;
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
    buttonClusterSettings: TButton;
    OpenDialog1: TOpenDialog;
    Label32: TLabel;
    ZLinkCombo: TComboBox;
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
    checkUseMultiStationWarning: TCheckBox;
    Label55: TLabel;
    editZLinkPcName: TEdit;
    checkZLinkSyncSerial: TCheckBox;
    procedure MultiOpRadioBtnClick(Sender: TObject);
    procedure SingleOpRadioBtnClick(Sender: TObject);
    procedure buttonOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AddClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure buttonCancelClick(Sender: TObject);
    procedure OpEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OpEditEnter(Sender: TObject);
    procedure OpEditExit(Sender: TObject);
    procedure SpeedBarChange(Sender: TObject);
    procedure WeightBarChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vButtonClick(Sender: TObject);
    procedure ClusterComboChange(Sender: TObject);
    procedure buttonClusterSettingsClick(Sender: TObject);
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

    FTempClusterTelnet: TCommParam;
    FTempClusterCom: TCommParam;
    FTempZLinkTelnet: TCommParam;

    procedure LoadIniFile; {loads Settings from zlog.ini}
    procedure LoadIniFileBS(ini: TIniFile); // called from loadinifile

    function GetMyCall(): string;
    procedure SetMyCall(s: string);
    function GetBand(): Integer;
    procedure SetBand(b: Integer);
    function GetMode(): Integer;
    procedure SetMode(m: Integer);
    function GetMultiOp(): Integer;
    procedure SetMultiOp(i: Integer);
    function GetContestMenuNo() : Integer;
    procedure SetContestMenuNo(i: Integer);
    function GetSpeed(): Integer;
    procedure SetSpeed(i: Integer);
    function GetFIFO(): Boolean;
    procedure SetFIFO(b: Boolean);
    function GetSideTone(): Boolean;
    procedure SetSideTone(b: Boolean);
    function GetTXNr(): Byte;
    procedure SetTXNr(i: Byte);
    function GetPTTEnabled(): Boolean;

    procedure SetPaddle(boo : boolean);      // unuse
    procedure SetCQMax(i : integer);
    procedure SetCQRepeat(r : double);
    procedure SetSendFreq(r : double);
    procedure SetPaddleReverse(boo : boolean);
    procedure ReadWin2(WinName : string; var F : TForm);  // unuse
    procedure RenewCWStrBankDisp();
  public
    OpList : TStringList;
    Settings : TSettingsParam;
    CurrentPower : array[b19..HiBand] of TPower;
    CurrentPower2 : array[b19..HiBand] of integer; {Power2 for ARRLDX}

    procedure SaveCurrentSettings; {saves Settings to zlog.ini}

    property MyCall: string read GetMyCall write SetMyCall;
    property Band: Integer read GetBand write SetBand;
    property Mode: Integer read GetMode write SetMode;
    property MultiOp: Integer read GetMultiOp write SetMultiOp;
    property ContestMenuNo: Integer read GetContestMenuNo write SetContestMenuNo;
    property Speed: Integer read GetSpeed write SetSpeed;
    property FIFO: Boolean read GetFIFO write SetFIFO;
    property SideTone: Boolean read GetSideTone write SetSideTone;
    property TXNr: Byte read GetTXNr write SetTXNr;
    property PTTEnabled: Boolean read GetPTTEnabled;

    procedure SetOpPower(var aQSO : TQSO);
    procedure SetWeight(i : integer);
    procedure SetTonePitch(i : integer);
    procedure SetScoreCoeff(E : Extended);

    function CWMessage(bank, i : integer) : shortstring;
    procedure ImplementSettings(_OnCreate : boolean); {Sets various parameters according to Settings}
    procedure RenewSettings; {Reads controls and updates Settings}
    procedure ReversePaddle;
    function GetAge(aQSO : TQSO) : string;
    function Rig1NameStr : string; // returns the selected rig name
    function Rig2NameStr : string; // returns the selected rig name

    procedure RecordSuperCheckColumns(c : integer);
    function GetSuperCheckColumns : integer;

    procedure ReadWin(WinName : string; var Open : boolean; var X, Y, H, W : integer);
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

   if aQSO.QSO.Operator = '' then begin
      Result := Settings._age;
   end
   else begin
      for i := 0 to OpList.Count - 1 do begin
         if TrimRight(Copy(OpList.Strings[i], 1, 20)) = aQSO.QSO.Operator then begin
            str := OpList.Strings[i];
            if length(str) <= 20 then begin
               exit;
            end;

            System.Delete(str, 1, 20);

            str := Trim(str);
            Result := str;
         end;
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
         if length(str) <= 20 then begin
            exit;
         end;

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

procedure TOptions.SetScoreCoeff(E: extended);
begin
   Settings._scorecoeff := E;
   TQSO(Log.List[0]).QSO.RSTRcvd := Trunc(E * 100);
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

procedure TOptions.SetWeight(i: integer);
begin
   if i in [0 .. 100] then
      Settings.CW._weight := i;
   BGK32Lib.SetWeight(Settings.CW._weight);
end;

function TOptions.GetMyCall(): string;
begin
   Result := Settings._mycall;
end;

procedure TOptions.SetMyCall(s: string);
begin
   Settings._mycall := s;
end;

function TOptions.GetBand: integer;
begin
   Result := Settings._band;
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

function TOptions.GetMode: integer;
begin
   Result := Settings._mode;
end;

procedure TOptions.SetMode(m: integer);
begin
   Settings._mode := m;
end;

function TOptions.GetMultiOp(): Integer;
begin
   Result := Settings._multiop;
end;

procedure TOptions.SetMultiOp(i: integer);
begin
   Settings._multiop := i;
end;

function TOptions.GetContestMenuNo(): Integer;
begin
   Result := Settings._contestmenuno;
end;

procedure TOptions.SetContestMenuNo(i: integer);
begin
   Settings._contestmenuno := i;
end;

function TOptions.GetSpeed(): Integer;
begin
   Result := Settings.CW._speed;
end;

procedure TOptions.SetSpeed(i: integer);
begin
   if i in [0 .. 60] then begin
      Settings.CW._speed := i;
   end;

   BGK32Lib.SetCWSpeed(Settings.CW._speed);
end;

function TOptions.GetFIFO(): Boolean;
begin
   Result := Settings.CW._FIFO;
end;

procedure TOptions.SetFIFO(b: boolean);
begin
   Settings.CW._FIFO := b;
end;

function TOptions.GetSideTone: boolean;
begin
   Result := Settings.CW._sidetone;
end;

procedure TOptions.SetSideTone(b: boolean);
begin
   BGK32Lib.SetSideTone(b);
   Settings.CW._sidetone := b;
end;

function TOptions.GetTXNr(): Byte;
begin
   Result := Settings._txnr;
end;

procedure TOptions.SetTXNr(i: Byte);
begin
   Settings._txnr := i;
end;

function TOptions.GetPTTEnabled: Boolean;
begin
   Result := Settings._pttenabled;
end;

procedure TOptions.SetPaddle(boo: boolean);
begin
   Settings.CW._paddle := boo;
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

procedure TOptions.MultiOpRadioBtnClick(Sender: TObject);
begin
   OpListBox.Enabled := True;
end;

procedure TOptions.SingleOpRadioBtnClick(Sender: TObject);
begin
   OpListBox.Enabled := False;
end;

procedure TOptions.SaveCurrentSettings;
var
   i: integer;
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      //
      // Preferences
      //

      // Active bands
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

      // Automatically enter exchange from SuperCheck
      ini.WriteBool('Preferences', 'AutoEnterSuper', Settings._entersuperexchange);

      // Display exchange on other bands
      ini.WriteBool('Preferences', 'SameExchange', Settings._sameexchange);

      // Multi Station Warning
      ini.WriteBool('Preferences', 'MultiStationWarning', Settings._multistationwarning);

      // 10 min count down
      ini.WriteBool('Preferences', 'CountDown', Settings._countdown);

      // QSY count / hr
      ini.WriteBool('Preferences', 'QSYCount', Settings._qsycount);

      // J-mode
      ini.WriteBool('Preferences', 'JMode', Settings._jmode);

      // Allow to log dupes
      ini.WriteBool('Preferences', 'AllowDupe', Settings._allowdupe);

      // Save when not sending CW
      ini.WriteBool('Preferences', 'SaveWhenNoCW', Settings._savewhennocw);

      // Save every N QSOs
      ini.WriteInteger('Preferences', 'SaveEvery', Settings._saveevery);

      // Back up path
      ini.WriteString('Preferences', 'BackUpPath', Settings._backuppath);

      //
      // Categories
      //

      // Operator
      ini.WriteInteger('Categories', 'Operator2', Settings._multiop);

      // Band
      ini.WriteInteger('Categories', 'Band', Settings._band);

      // Mode
      ini.WriteInteger('Categories', 'Mode', Settings._mode);

      // Prov/State($V)
      ini.WriteString('Profiles', 'Province/State', Settings._prov);

      // CITY
      ini.WriteString('Profiles', 'City', Settings._city);

      // CQ Zone
      ini.WriteString('Profiles', 'CQZone', Settings._cqzone);

      // ITU Zone
      ini.WriteString('Profiles', 'IARUZone', Settings._iaruzone);

      // Sent

      // Multi Station
      ini.WriteBool('Categories', 'MultiStn', Settings._multistation);

      //
      // CW/RTTY
      //

      // Messages
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

      // Switch TAB/; with CW bank
      ini.WriteBool('CW', 'CQSP', Settings._switchcqsp);

      // Speed
      ini.WriteInteger('CW', 'Speed', Settings.CW._speed);
      ini.WriteInteger('CW', 'FixedSpeed', Settings.CW._fixwpm);

      // Weight
      ini.WriteInteger('CW', 'Weight', Settings.CW._weight);

      // Paddle enabled
      ini.WriteBool('CW', 'PaddleEnabled', Settings.CW._paddle);

      // Paddle reverse
      ini.WriteBool('CW', 'PaddleReverse', Settings.CW._paddlereverse);

      // Side tone
      ini.WriteBool('CW', 'SideTone', Settings.CW._sidetone);

      // Que messages
      ini.WriteBool('CW', 'FIFO', Settings.CW._FIFO);

      // Tone Pitch (Hz)
      ini.WriteInteger('CW', 'Pitch', Settings.CW._tonepitch);

      // CQ max
      ini.WriteInteger('CW', 'CQMax', Settings.CW._cqmax);

      // Abbreviation (019)
      ini.WriteString('CW', 'Zero', Settings.CW._zero);
      ini.WriteString('CW', 'One', Settings.CW._one);
      ini.WriteString('CW', 'Nine', Settings.CW._nine);

      // CQ repeat interval (sec)
      ini.WriteFloat('CW', 'CQRepeat', Settings.CW._cqrepeat);

      //
      // Hardware
      //

      // Ports

      // PacketCluster
      ini.WriteInteger('Hardware', 'PacketCluster', Settings._clusterport);

      // COM
      ini.WriteInteger('Hardware', 'PacketClusterBaud', Settings._clusterbaud);
      ini.WriteInteger('PacketCluster', 'COMlinebreak', Settings._cluster_com.FLineBreak);
      ini.WriteBool('PacketCluster', 'COMlocalecho', Settings._cluster_com.FLocalEcho);

      // TELNET
      ini.WriteString('PacketCluster', 'TELNEThost', Settings._cluster_telnet.FHostName);
      ini.WriteInteger('PacketCluster', 'TELNETport', Settings._cluster_telnet.FPortNumber);
      ini.WriteInteger('PacketCluster', 'TELNETlinebreak', Settings._cluster_telnet.FLineBreak);
      ini.WriteBool('PacketCluster', 'TELNETlocalecho', Settings._cluster_telnet.FLocalEcho);

      // Z-Link (Z-Server)
      ini.WriteInteger('Hardware', 'Z-Link', Settings._zlinkport);

      // PC Name
      ini.WriteString('Z-Link', 'PCName', Settings._pcname);

      // Sync. SerialNumber
      ini.WriteBool('Z-Link', 'SyncSerial', Settings._syncserial);

      // COM(unuse)
//      ini.WriteInteger('Z-Link', 'COMlinebreak', Settings._zlinklinebreakCOM);
//      ini.WriteBool('Z-Link', 'COMlocalecho', Settings._zlinklocalechoCOM);

      // TELNET
      ini.WriteString('Z-Link', 'TELNEThost', Settings._zlink_telnet.FHostName);
      ini.WriteInteger('Z-Link', 'TELNETlinebreak', Settings._zlink_telnet.FLineBreak);
      ini.WriteBool('Z-Link', 'TELNETlocalecho', Settings._zlink_telnet.FLocalEcho);

      // RIG1
      ini.WriteInteger('Hardware', 'Rig', Settings._rig1port);
      ini.WriteInteger('Hardware', 'RigName', Settings._rig1name);
      ini.WriteBool('Hardware', 'Transverter1', Settings._transverter1);
      ini.WriteInteger('Hardware', 'Transverter1Offset', Settings._transverteroffset1);

      // RIG2
      ini.WriteInteger('Hardware', 'Rig2', Settings._rig2port);
      ini.WriteInteger('Hardware', 'RigName2', Settings._rig2name);
      ini.WriteBool('Hardware', 'Transverter2', Settings._transverter2);
      ini.WriteInteger('Hardware', 'Transverter2Offset', Settings._transverteroffset2);

      // CW/PTT port
      ini.WriteInteger('Hardware', 'CWLPTPort', Settings._lptnr);

      // ICOM baud rate
      ini.WriteInteger('Hardware', 'IcomBaudRate', Settings._icombaudrate);

      // CW PTT control

      // Enable PTT control
      ini.WriteBool('Hardware', 'PTTEnabled', Settings._pttenabled);

      // Before TX (ms)
      ini.WriteInteger('Hardware', 'PTTBefore', Settings._pttbefore);

      // After TX paddle/keybd (ms)
      ini.WriteInteger('Hardware', 'PTTAfter', Settings._pttafter);

      //
      // Rig control
      //

      // Band data (LPT)
      ini.WriteInteger('Rig', 'BandDataMode', Settings._banddatamode);

      // Clear RIT after each QSO
      ini.WriteBool('Hardware', 'RitClear', Settings._ritclear);

      // Do not allow two rigs to be on same band
      ini.WriteBool('Rig', 'DontAllowSameBand', Settings._dontallowsameband);

      // Record rig frequency in memo
      ini.WriteBool('Rig', 'RecordFreqInMemo', Settings._recrigfreq);

      // Use AFSK mode for RTTY
      ini.WriteBool('Rig', 'UseAFSK', Settings._AFSK);

      // Automatically create band scope
      ini.WriteBool('Rig', 'AutoBandMap', Settings._autobandmap);

      // Send current freq every
      ini.WriteFloat('Rig', 'SendFreq', Settings._sendfreq);

      //
      // Path
      //

      // CFG/DAT
      ini.WriteString('Preferences', 'CFGDATPath', Settings._cfgdatpath);

      // Logs
      ini.WriteString('Preferences', 'LogsPath', Settings._logspath);

      //
      // Misc
      //

      // Start search after
      ini.WriteInteger('Misc', 'SearchAfter', Settings._searchafter);

      // Max super check search
      ini.WriteInteger('Misc', 'MaxSuperHit', Settings._maxsuperhit);

      // Delete band scope data after
      ini.WriteInteger('Misc', 'BandScopeExpire', Settings._bsexpire);

      // Delete spot data after
      ini.WriteInteger('Misc', 'SpotExpire', Settings._spotexpire);

      // Display date in partial check
      ini.WriteBool('Misc', 'DisplayDatePartialCheck', Settings._displaydatepartialcheck);

      // Update using a thread
      ini.WriteBool('Misc', 'UpdateUsingThread', Settings._renewbythread);

      //
      // ここから隠し設定
      //

      ini.WriteBool('Preferences', 'MoveToMemoWithSpace', Settings._movetomemo);

      ini.WriteInteger('Categories', 'Contest', Settings._contestmenuno);
      ini.WriteInteger('Categories', 'TXNumber', Settings._txnr);
      ini.WriteString('Categories', 'MyCall', Settings._mycall);

      ini.WriteInteger('CW', 'Interval', Settings.CW._interval);

      ini.WriteInteger('Preferences', 'FontSize', Settings._mainfontsize);
      ini.WriteInteger('Preferences', 'RowHeight', Settings._mainrowheight);

      OpList.SaveToFile(MAINPATH + 'ZLOG.OP');
   finally
      ini.Free();
   end;
end;

procedure TOptions.LoadIniFileBS(ini: TIniFile);
var
   b: TBand;
   m: TMode;
begin
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
      // Band Scope
      LoadIniFileBS(ini);

      //
      // Preferences
      //

      // Active bands
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

      // Automatically enter exchange from SuperCheck
      Settings._entersuperexchange := ini.ReadBool('Preferences', 'AutoEnterSuper', False);

      // Display exchange on other bands
      Settings._sameexchange := ini.ReadBool('Preferences', 'SameExchange', False);

      // Multi Station Warning
      Settings._multistationwarning := ini.ReadBool('Preferences', 'MultiStationWarning', True);

      // 10 min count down
      Settings._countdown := ini.ReadBool('Preferences', 'CountDown', False);

      // QSY count / hr
      Settings._qsycount := ini.ReadBool('Preferences', 'QSYCount', False);

      // J-mode
      Settings._jmode := ini.ReadBool('Preferences', 'JMode', False);

      // Allow to log dupes
      Settings._allowdupe := ini.ReadBool('Preferences', 'AllowDupe', False);

      // Save when not sending CW
      Settings._savewhennocw := ini.ReadBool('Preferences', 'SaveWhenNoCW', False);

      // Save every N QSOs
      Settings._saveevery := ini.ReadInteger('Preferences', 'SaveEvery', 3);

      // Back up path
      Settings._backuppath := ini.ReadString('Preferences', 'BackUpPath', '');

      //
      // Categories
      //

      // Operator
      Settings._multiop := ini.ReadInteger('Categories', 'Operator2', 0);

      // Band
      Settings._band := ini.ReadInteger('Categories', 'Band', 0);

      // Mode
      Settings._mode := ini.ReadInteger('Categories', 'Mode', 0);

      // Prov/State($V)
      Settings._prov := ini.ReadString('Profiles', 'Province/State', '');

      // CITY
      Settings._city := ini.ReadString('Profiles', 'City', '');

      // CQ Zone
      Settings._cqzone := ini.ReadString('Profiles', 'CQZone', '');

      // ITU Zone
      Settings._iaruzone := ini.ReadString('Profiles', 'IARUZone', '');

      // Sent

      // Multi Station
      Settings._multistation := ini.ReadBool('Categories', 'MultiStn', False);

      //
      // CW/RTTY
      //

      // Messages
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

      // Switch TAB/; with CW bank
      Settings._switchcqsp := ini.ReadBool('CW', 'CQSP', False);

      // Speed
      Settings.CW._speed := ini.ReadInteger('CW', 'Speed', 25);
      Settings.CW._fixwpm := ini.ReadInteger('CW', 'FixedSpeed', 20);

      // Weight
      Settings.CW._weight := ini.ReadInteger('CW', 'Weight', 50);

      // Paddle enabled
      Settings.CW._paddle := ini.ReadBool('CW', 'PaddleEnabled', True);

      // Paddle reverse
      Settings.CW._paddlereverse := ini.ReadBool('CW', 'PaddleReverse', False);

      // Side tone
      Settings.CW._sidetone := ini.ReadBool('CW', 'SideTone', True);

      // Que messages
      Settings.CW._FIFO := ini.ReadBool('CW', 'FIFO', True);

      // Tone Pitch (Hz)
      Settings.CW._tonepitch := ini.ReadInteger('CW', 'Pitch', 800);

      // CQ max
      Settings.CW._cqmax := ini.ReadInteger('CW', 'CQMax', 15);

      // Abbreviation (019)
      s := ini.ReadString('CW', 'Zero', 'O');
      Settings.CW._zero := char(s[1]);

      s := ini.ReadString('CW', 'One', 'A');
      Settings.CW._one := char(s[1]);

      s := ini.ReadString('CW', 'Nine', 'N');
      Settings.CW._nine := char(s[1]);

      // CQ repeat interval (sec)
      Settings.CW._cqrepeat := ini.ReadFloat('CW', 'CQRepeat', 2.0);

      //
      // Hardware
      //

      // Ports

      // PacketCluster
      Settings._clusterport := ini.ReadInteger('Hardware', 'PacketCluster', 0);

      // COM
      Settings._clusterbaud := ini.ReadInteger('Hardware', 'PacketClusterBaud', 6);
      Settings._cluster_com.FLineBreak := ini.ReadInteger('PacketCluster', 'COMlinebreak', 0);
      Settings._cluster_com.FLocalEcho := ini.ReadBool('PacketCluster', 'COMlocalecho', False);

      // TELNET
      Settings._cluster_telnet.FHostName := ini.ReadString('PacketCluster', 'TELNEThost', '');
      Settings._cluster_telnet.FPortNumber := ini.ReadInteger('PacketCluster', 'TELNETport', 23);
      Settings._cluster_telnet.FLineBreak := ini.ReadInteger('PacketCluster', 'TELNETlinebreak', 0);
      Settings._cluster_telnet.FLocalEcho := ini.ReadBool('PacketCluster', 'TELNETlocalecho', False);

      // Z-Link (Z-Server)
      Settings._zlinkport := ini.ReadInteger('Hardware', 'Z-Link', 0);

      // PC Name
      Settings._pcname := ini.ReadString('Z-Link', 'PCName', '');

      // Sync. SerialNumber
      Settings._syncserial := ini.ReadBool('Z-Link', 'SyncSerial', False);

      // COM(unuse)
//      Settings._zlinklinebreakCOM := ini.ReadInteger('Z-Link', 'COMlinebreak', 0);
//      Settings._zlinklocalechoCOM := ini.ReadBool('Z-Link', 'COMlocalecho', False);

      // TELNET
      Settings._zlink_telnet.FHostName := ini.ReadString('Z-Link', 'TELNEThost', '');
      Settings._zlink_telnet.FLineBreak := ini.ReadInteger('Z-Link', 'TELNETlinebreak', 0);
      Settings._zlink_telnet.FLocalEcho := ini.ReadBool('Z-Link', 'TELNETlocalecho', False);

      // RIG1
      Settings._rig1port := ini.ReadInteger('Hardware', 'Rig', 0);
      Settings._rig1name := ini.ReadInteger('Hardware', 'RigName', 0);
      Settings._transverter1 := ini.ReadBool('Hardware', 'Transverter1', False);
      Settings._transverteroffset1 := ini.ReadInteger('Hardware', 'Transverter1Offset', 0);

      // RIG2
      Settings._rig2port := ini.ReadInteger('Hardware', 'Rig2', 0);
      Settings._rig2name := ini.ReadInteger('Hardware', 'RigName2', 0);
      Settings._transverter2 := ini.ReadBool('Hardware', 'Transverter2', False);
      Settings._transverteroffset2 := ini.ReadInteger('Hardware', 'Transverter2Offset', 0);

      // CW/PTT port
      Settings._lptnr := ini.ReadInteger('Hardware', 'CWLPTPort', 0);

      // ICOM baud rate
      Settings._icombaudrate := ini.ReadInteger('Hardware', 'IcomBaudRate', 1);

      // CW PTT control

      // Enable PTT control
      Settings._pttenabled := ini.ReadBool('Hardware', 'PTTEnabled', False);

      // Before TX (ms)
      Settings._pttbefore := ini.ReadInteger('Hardware', 'PTTBefore', 25);

      // After TX paddle/keybd (ms)
      Settings._pttafter := ini.ReadInteger('Hardware', 'PTTAfter', 0);

      //
      // Rig control
      //

      // Band data (LPT)
      Settings._banddatamode := ini.ReadInteger('Rig', 'BandDataMode', 1);

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

      // Clear RIT after each QSO
      Settings._ritclear := ini.ReadBool('Hardware', 'RitClear', False);

      // Do not allow two rigs to be on same band
      Settings._dontallowsameband := ini.ReadBool('Rig', 'DontAllowSameBand', False);

      // Record rig frequency in memo
      Settings._recrigfreq := ini.ReadBool('Rig', 'RecordFreqInMemo', False);

      // Use AFSK mode for RTTY
      Settings._AFSK := ini.ReadBool('Rig', 'UseAFSK', False);

      // Automatically create band scope
      Settings._autobandmap := ini.ReadBool('Rig', 'AutoBandMap', False);

      // Send current freq every
      Settings._sendfreq := ini.ReadFloat('Rig', 'SendFreq', 1.0);

      //
      // Path
      //

      // CFG/DAT
      Settings._cfgdatpath := ini.ReadString('Preferences', 'CFGDATPath', '');

      // Logs
      Settings._logspath := ini.ReadString('Preferences', 'LogsPath', '');

      //
      // Misc
      //

      // Start search after
      Settings._searchafter := ini.ReadInteger('Misc', 'SearchAfter', 0);

      // Max super check search
      Settings._maxsuperhit := ini.ReadInteger('Misc', 'MaxSuperHit', 100);

      // Delete band scope data after
      Settings._bsexpire := ini.ReadInteger('Misc', 'BandScopeExpire', 60);

      // Delete spot data after
      Settings._spotexpire := ini.ReadInteger('Misc', 'SpotExpire', 90);

      // Display date in partial check
      Settings._displaydatepartialcheck := ini.ReadBool('Misc', 'DisplayDatePartialCheck', False);

      // Update using a thread
      Settings._renewbythread := ini.ReadBool('Misc', 'UpdateUsingThread', False);

      //
      // ここから隠し設定
      //

      Settings._movetomemo := ini.ReadBool('Preferences', 'MoveToMemoWithSpace', False);

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

      Settings._txnr := ini.ReadInteger('Categories', 'TXNumber', 0);
      Settings._contestmenuno := ini.ReadInteger('Categories', 'Contest', 1);
      Settings._mycall := ini.ReadString('Categories', 'MyCall', 'Your call sign');

      Settings.CW._interval := ini.ReadInteger('CW', 'Interval', 1);

//      Settings._specificcwport := ini.ReadInteger('Hardware', 'UseCWPort', 0 { $037A } );

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

   FTempClusterTelnet := Settings._cluster_telnet;
   FTempClusterCom := Settings._cluster_com;
   FTempZLinkTelnet := Settings._zlink_telnet;
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

   Settings._bsexpire := spBSExpire.Value;
   Settings._spotexpire := spSpotExpire.Value;

   Settings._icombaudrate := cbIcomBaudRate.ItemIndex;

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
//   Settings._clusterbaud := ClusterCOMSet.BaudCombo.ItemIndex;
   Settings._rig1port := Rig1PortCombo.ItemIndex;
   Settings._ritclear := cbRITClear.Checked;
   Settings._rig1name := Rig1Combo.ItemIndex;

   Settings._rig2port := Rig2PortCombo.ItemIndex;
   Settings._rig2name := Rig2Combo.ItemIndex;

   Settings._zlinkport := ZLinkCombo.ItemIndex;
   Settings._pcname := editZLinkPcName.Text;
   Settings._syncserial := checkZLinkSyncSerial.Checked;

   Settings._pttenabled := PTTEnabledCheckBox.Checked;
   Settings._saveevery := SaveEvery.Value;
   Settings._countdown := cbCountDown.Checked;
   Settings._qsycount := cbQSYCount.Checked;

   i := Settings._pttbefore;
   Settings._pttbefore := StrToIntDef(BeforeEdit.Text, i);

   i := Settings._pttafter;
   Settings._pttafter := StrToIntDef(AfterEdit.Text, i);

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

   Settings._cluster_telnet := FTempClusterTelnet;
   Settings._cluster_com := FTempClusterCom;
   Settings._zlink_telnet := FTempZLinkTelnet;
end;

procedure TOptions.buttonOKClick(Sender: TObject);
begin
   RenewSettings;
   ImplementSettings(False);
   SaveCurrentSettings();
   Close;
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
   editZLinkPcName.Text := Settings._pcname;
   checkZLinkSyncSerial.Checked := Settings._syncserial;

   Rig1PortCombo.ItemIndex := Settings._rig1port;
   cbRITClear.Checked := Settings._ritclear;
   Rig1Combo.ItemIndex := Settings._rig1name;

   Rig2PortCombo.ItemIndex := Settings._rig2port;
   cbRITClear.Checked := Settings._ritclear;
   Rig2Combo.ItemIndex := Settings._rig2name;

   cbIcomBaudRate.ItemIndex := Settings._icombaudrate;

   // Packet Cluster通信設定ボタン
   buttonClusterSettings.Enabled := True;
   ClusterComboChange(nil);

   // ZLink通信設定ボタン
   buttonZLinkSettings.Enabled := True;
   ZLinkComboChange(nil);

   SaveEvery.Value := Settings._saveevery;

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
      if OpPowerEdit.Text <> '' then begin
         str := FillRight(str, 20) + OpPowerEdit.Text;
      end;

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
begin
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

procedure TOptions.buttonCancelClick(Sender: TObject);
begin
   Close;
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
   buttonOK.Default := True;
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
   buttonClusterSettings.Enabled := True;
   case ClusterCombo.ItemIndex of
      0:
         buttonClusterSettings.Enabled := False;
      1 .. 6:
         buttonClusterSettings.Caption := 'COM port settings';
      7:
         buttonClusterSettings.Caption := 'TELNET settings';
   end;
end;

procedure TOptions.buttonClusterSettingsClick(Sender: TObject);
var
   f: TForm;
begin
   if (ClusterCombo.ItemIndex >= 1) and (ClusterCombo.ItemIndex <= 6) then begin
      f := TformClusterCOMSet.Create(Self);
      try
         TformClusterCOMSet(f).BaudRate  := FTempClusterCom.FBaudRate;
         TformClusterCOMSet(f).LineBreak := FTempClusterCom.FLineBreak;
         TformClusterCOMSet(f).LocalEcho := FTempClusterCom.FLocalEcho;

         if f.ShowModal() <> mrOK then begin
            Exit;
         end;

         FTempClusterCom.FBaudRate  := TformClusterCOMSet(f).BaudRate;
         FTempClusterCom.FLineBreak := TformClusterCOMSet(f).LineBreak;
         FTempClusterCom.FLocalEcho := TformClusterCOMSet(f).LocalEcho;
      finally
         f.Release();
      end;
   end
   else if ClusterCombo.ItemIndex = 7 then begin
      f := TformClusterTelnetSet.Create(Self);
      try
         TformClusterTelnetSet(f).HostName   := FTempClusterTelnet.FHostName;
         TformClusterTelnetSet(f).LineBreak  := FTempClusterTelnet.FLineBreak;
         TformClusterTelnetSet(f).LocalEcho  := FTempClusterTelnet.FLocalEcho;
         TformClusterTelnetSet(f).PortNumber := FTempClusterTelnet.FPortNumber;

         if f.ShowModal() <> mrOK then begin
            Exit;
         end;

         FTempClusterTelnet.FHostName   := TformClusterTelnetSet(f).HostName;
         FTempClusterTelnet.FLineBreak  := TformClusterTelnetSet(f).LineBreak;
         FTempClusterTelnet.FLocalEcho  := TformClusterTelnetSet(f).LocalEcho;
         FTempClusterTelnet.FPortNumber := TformClusterTelnetSet(f).PortNumber;
      finally
         f.Release();
      end;
   end;
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
      F.HostName  := FTempZLinkTelnet.FHostName;
      F.LineBreak := FTempZLinkTelnet.FLineBreak;
      F.LocalEcho := FTempZLinkTelnet.FLocalEcho;

      if F.ShowModal() <> mrOK then begin
         exit;
      end;

      FTempZLinkTelnet.FHostName  := F.HostName;
      FTempZLinkTelnet.FLineBreak := F.LineBreak;
      FTempZLinkTelnet.FLocalEcho := F.LocalEcho;
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
