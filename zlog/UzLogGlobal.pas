unit UzLogGlobal;

interface

uses
  System.SysUtils, System.Classes, IniFiles, Forms,
  zLogGlobal, BGK32Lib;

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

    _super_check_columns: Integer;
  end;

type
  TdmZLogGlobal = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private 宣言 }
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
    function GetRig1NameStr() : string; // returns the selected rig name
    function GetRig2NameStr() : string; // returns the selected rig name
    function GetSuperCheckColumns(): Integer;
    procedure SetSuperCheckColumns(v: Integer);
    function GetCQMax(): Integer;
    procedure SetCQMax(i : integer);
    function GetCQRepeat(): Double;
    procedure SetCQRepeat(r : double);
    function GetSendFreq(): Double;
    procedure SetSendFreq(r : double);
    procedure SetPaddle(boo : boolean);      // unuse
public
    { Public 宣言 }
    CurrentPower : array[b19..HiBand] of TPower;
    CurrentPower2 : array[b19..HiBand] of integer; {Power2 for ARRLDX}
    OpList : TStringList;
    Settings : TSettingsParam;

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
    property CQMax: Integer read GetCQMax write SetCQMax;
    property CQRepeat: Double read GetCQRepeat write SetCQRepeat;
    property SendFreq: Double read GetSendFreq write SetSendFreq;
    property Rig1NameStr: string read GetRig1NameStr;
    property Rig2NameStr: string read GetRig2NameStr;
    property SuperCheckColumns: Integer read GetSuperCheckColumns write SetSuperCheckColumns;

    function GetAge(aQSO : TQSO) : string;
    procedure SetOpPower(var aQSO : TQSO);

    procedure SetWeight(i : integer);
    procedure SetTonePitch(i : integer);
    procedure SetScoreCoeff(E : Extended);

    procedure SetPaddleReverse(boo : boolean);
    procedure ReversePaddle();

    function CWMessage(bank, i : integer) : shortstring;

    procedure ReadWindowState(form: TForm; strWindowName: string = ''; fPositionOnly: Boolean = False);
    procedure WriteWindowState(form: TForm; strWindowName: string = '');
    procedure ReadMainFormState(var X, Y, W, H: integer; var TB1, TB2: boolean);
    procedure WriteMainFormState(X, Y, W, H: integer; TB1, TB2: boolean);
  end;

var
  dmZLogGlobal: TdmZLogGlobal;

implementation

uses
  Main, URigControl;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TdmZLogGlobal.DataModuleCreate(Sender: TObject);
var
   filename: string;
   b: TBand;
begin
   for b := b19 to b10g do begin
      CurrentPower[b] := pwrP;
      CurrentPower2[b] := 500;
   end;

   LoadIniFile;
   Settings.CW.CurrentBank := 1;

   // オペレーターリスト
   OpList := TStringList.Create;
   try
      filename := MAINPATH + 'ZLOG.OP';
      if FileExists(filename) then begin
         OpList.LoadFromFile(filename);
      end;
   except
      on EFOpenError do begin
      end;
   end;

end;

procedure TdmZLogGlobal.DataModuleDestroy(Sender: TObject);
begin
   OpList.Free;
end;

procedure TdmZLogGlobal.LoadIniFileBS(ini: TIniFile);
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

procedure TdmZLogGlobal.LoadIniFile;
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

      Settings._super_check_columns := ini.ReadInteger('Windows', 'SuperCheckColumns', 0);
   finally
      ini.Free();
   end;
end;

procedure TdmZLogGlobal.SaveCurrentSettings;
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

      ini.WriteInteger('Windows', 'SuperCheckColumns', Settings._super_check_columns);
   finally
      ini.Free();
   end;
end;

function TdmZLogGlobal.GetAge(aQSO: TQSO): string;
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

procedure TdmZLogGlobal.SetOpPower(var aQSO: TQSO);
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

function TdmZLogGlobal.GetMyCall(): string;
begin
   Result := Settings._mycall;
end;

procedure TdmZLogGlobal.SetMyCall(s: string);
begin
   Settings._mycall := s;
end;

function TdmZLogGlobal.GetBand: integer;
begin
   Result := Settings._band;
end;

procedure TdmZLogGlobal.SetBand(b: integer);
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

function TdmZLogGlobal.GetMode: integer;
begin
   Result := Settings._mode;
end;

procedure TdmZLogGlobal.SetMode(m: integer);
begin
   Settings._mode := m;
end;

function TdmZLogGlobal.GetMultiOp(): Integer;
begin
   Result := Settings._multiop;
end;

procedure TdmZLogGlobal.SetMultiOp(i: integer);
begin
   Settings._multiop := i;
end;

function TdmZLogGlobal.GetContestMenuNo(): Integer;
begin
   Result := Settings._contestmenuno;
end;

procedure TdmZLogGlobal.SetContestMenuNo(i: integer);
begin
   Settings._contestmenuno := i;
end;

function TdmZLogGlobal.GetSpeed(): Integer;
begin
   Result := Settings.CW._speed;
end;

procedure TdmZLogGlobal.SetSpeed(i: integer);
begin
   if i in [0 .. 60] then begin
      Settings.CW._speed := i;
   end;

   BGK32Lib.SetCWSpeed(Settings.CW._speed);
end;

function TdmZLogGlobal.GetFIFO(): Boolean;
begin
   Result := Settings.CW._FIFO;
end;

procedure TdmZLogGlobal.SetFIFO(b: boolean);
begin
   Settings.CW._FIFO := b;
end;

function TdmZLogGlobal.GetSideTone: boolean;
begin
   Result := Settings.CW._sidetone;
end;

procedure TdmZLogGlobal.SetSideTone(b: boolean);
begin
   BGK32Lib.SetSideTone(b);
   Settings.CW._sidetone := b;
end;

function TdmZLogGlobal.GetTXNr(): Byte;
begin
   Result := Settings._txnr;
end;

procedure TdmZLogGlobal.SetTXNr(i: Byte);
begin
   Settings._txnr := i;
end;

function TdmZLogGlobal.GetPTTEnabled: Boolean;
begin
   Result := Settings._pttenabled;
end;

procedure TdmZLogGlobal.SetScoreCoeff(E: extended);
begin
   Settings._scorecoeff := E;
   TQSO(Log.List[0]).QSO.RSTRcvd := Trunc(E * 100);
end;

procedure TdmZLogGlobal.SetWeight(i: integer);
begin
   if i in [0 .. 100] then
      Settings.CW._weight := i;

   BGK32Lib.SetWeight(Settings.CW._weight);
end;

procedure TdmZLogGlobal.SetTonePitch(i: integer);
begin
   Settings.CW._tonepitch := i;
   BGK32Lib.SetPitch(i);
end;

function TdmZLogGlobal.GetRig1NameStr: string; // returns the selected rig name
begin
//   Result := Rig1Combo.Items[Settings._rig1name];
   Result := RIGNAMES[Settings._rig1name];
end;

function TdmZLogGlobal.GetRig2NameStr: string; // returns the selected rig name
begin
//   Result := Rig2Combo.Items[Settings._rig2name];
   Result := RIGNAMES[Settings._rig2name];
end;

function TdmZLogGlobal.GetSuperCheckColumns(): Integer;
begin
   Result := Settings._super_check_columns;
end;

procedure TdmZLogGlobal.SetSuperCheckColumns(v: Integer);
begin
   Settings._super_check_columns := v;
end;

function TdmZLogGlobal.GetCQMax(): Integer;
begin
   Result := Settings.CW._cqmax;
end;

procedure TdmZLogGlobal.SetCQMax(i: integer);
begin
   Settings.CW._cqmax := i;
   BGK32Lib.SetLoopMax(i);
end;

function TdmZLogGlobal.GetCQRepeat(): Double;
begin
   Result := Settings.CW._cqrepeat;
end;

procedure TdmZLogGlobal.SetCQRepeat(r: Double);
begin
   Settings.CW._cqrepeat := r;
   BGK32Lib.SetLoopTime(r);
end;

function TdmZLogGlobal.GetSendFreq(): Double;
begin
   Result := Settings._sendfreq;
end;

procedure TdmZLogGlobal.SetSendFreq(r: double);
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

procedure TdmZLogGlobal.SetPaddle(boo: boolean);
begin
   Settings.CW._paddle := boo;
end;

procedure TdmZLogGlobal.SetPaddleReverse(boo: boolean);
begin
   Settings.CW._paddlereverse := boo;
   BGK32Lib.ReversePaddle(boo);
end;

procedure TdmZLogGlobal.ReversePaddle;
begin
   SetPaddleReverse(not(Settings.CW._paddlereverse));
end;

function TdmZLogGlobal.CWMessage(bank, i: integer): shortstring;
begin
   Result := Settings.CW.CWStrBank[bank, i];
end;

procedure TdmZLogGlobal.ReadWindowState(form: TForm; strWindowName: string; fPositionOnly: Boolean );
var
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      if strWindowName = '' then begin
         strWindowName := form.Name;
      end;

      form.Visible := ini.ReadBool('Windows', strWindowName + '_Open', False);
      form.Left    := ini.ReadInteger('Windows', strWindowName + '_X', 10);
      form.Top     := ini.ReadInteger('Windows', strWindowName + '_Y', 10);
      if fPositionOnly = False then begin
         form.Height  := ini.ReadInteger('Windows', strWindowName + '_H', 10);
         form.Width   := ini.ReadInteger('Windows', strWindowName + '_W', 10);
      end;
   finally
      ini.Free();
   end;
end;

procedure TdmZLogGlobal.WriteWindowState(form: TForm; strWindowName: string);
var
   ini: TIniFile;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      if strWindowName = '' then begin
         strWindowName := form.Name;
      end;

      ini.WriteBool('Windows', strWindowName + '_Open', form.Visible);
      ini.WriteInteger('Windows', strWindowName + '_X', form.Left);
      ini.WriteInteger('Windows', strWindowName + '_Y', form.Top);
      ini.WriteInteger('Windows', strWindowName + '_H', form.Height);
      ini.WriteInteger('Windows', strWindowName + '_W', form.Width);
   finally
      ini.Free();
   end;
end;

procedure TdmZLogGlobal.ReadMainFormState(var X, Y, W, H: integer; var TB1, TB2: boolean);
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

procedure TdmZLogGlobal.WriteMainFormState(X, Y, W, H: integer; TB1, TB2: boolean);
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

end.
