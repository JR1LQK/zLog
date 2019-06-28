unit zLogGlobal;

interface

{uses
  Windows, SysUtils, Classes;}
uses SysUtils, Windows, Classes;

var CurrentFileName : string;
    _Japanese : Boolean;

    MAINPATH : string; // stores the path for zlog.exe

    DEBUGMODE : boolean = false;

const CONTESTNAME : string = '';

  ZLOG_WIN2KMODE : boolean = false;

const
  // SerialContestType
  _USEUTC = 32767;
  _CR = Chr($0d); // carriage return
  _LF = Chr($0a);
  SER_ALL = 1;
  SER_BAND = 2;
  SER_MS = 3;    // separate serial for run/multi stns

  CountDownStartTime : TDateTime = 0.0;
  QSYCount : integer = 0;

  ZLinkHeader = '#ZLOG#';
  actAdd = $0A;
  actDelete = $0D;
  actInsert = $07;
  actEdit = $0E;
  actLock = $AA;
  actUnlock = $BB;

  CWid : byte = 9; {11}
  MaxQSO = 500; {initial capacity for the log}

  MAXLOGCAPACITY = 20000;

  MemoLength = 64; {max length of a memo}

  LineBreakCode : array [0..2] of string[2]
    = (Chr($0d)+Chr($0a), Chr($0d), Chr($0a));
  _sep = '~'; {separator character}
  UseUTC : boolean = False;
  PostContest : boolean = False;

  OperatorCategory : integer = 0; // 0 = single op, 1 = multiop 2 = m/s

  DupeGracePeriod : integer = 99999999; // minutes after which qso is treated as NOT dupe;

var AllowDupe : boolean;  // enables user to log dupe qsos. Changed in UOptions

type
  TMode = (mCW, mSSB, mFM, mAM, mRTTY, mOther);
  TBand = (b19, b35, b7, b10, b14, b18, b21, b24, b28, b50, b144, b430, b1200, b2400, b5600, b10g);
  TPower = (p001, p002, p005, p010, p020, p025, p050, p100, p200, p500, p1000);

const  HiBand = b10g;

var
  SerialContestType : integer;  // 0 if no serial # or SER_ALL, SER_BAND
  SerialArray : array [b19..HiBand] of integer;  // initialized in TContest.Create;
  SerialArrayTX : array[0..64] of integer;
type

  TFastSortedList = class
  private
    List : array[0..MAXLOGCAPACITY] of string[20];
    items : integer;
  public
    constructor Create;
    procedure Add(S : string);
    function Exists(S : string) : boolean;
  end;

  TQSOData = record
    Time : TDateTime;
    CallSign : string[12];  {13 bytes}
    NrSent : string[30];
    NrRcvd : string[30];
    RSTSent : Smallint;//word;  {2 bytes}
    RSTRcvd : word;
    Serial : integer;  {4 bytes ?}
    Mode : TMode;  {1 byte}
    Band : TBand;  {1 byte}
    Power : TPower; {1 byte}
    Multi1 : string[30];
    Multi2 : string[30];
    NewMulti1 : boolean;
    NewMulti2 : boolean;
    Points : byte;
    Operator : string[14]; {Operator's name}
    Memo : string[MemoLength]; {max 64 char = 65 bytes}
    CQ : boolean; {not used yet}
    Dupe : boolean;
    Reserve : byte; {used for z-link commands}
    TX : byte; {Transmitter number for 2 TX category}
    Power2 : integer; {used by ARRL DX side only}
    Reserve2 : integer; { $FF when forcing to log}
    Reserve3 : integer; {QSO ID#}
                        {TTSSSSRRCC   TT:TX#(00-21) SSSS:Serial counter
                                      RR:Random(00-99) CC:Edit counter 00 and up}

  end;

  TBandBool = array[b19..HiBand] of boolean;

  TQSO = class
    QSO : TQSOData;
    constructor Create;
    procedure IncTime;
    procedure DecTime;
    function SerialStr : string;
    function TimeStr : string;
    function DateStr : string;
    function BandStr : string;
    function ModeStr : string;
    function PowerStr : string;
    function NewPowerStr : string;
    function PointStr : string;
    function RSTStr : string;
    function RSTSentStr : string;
    function PartialSummary(DispDate: boolean) : string;
    function CheckCallSummary : string;
    procedure UpdateTime;
    function zLogALL : string;
    //function QSO_ADIF(FieldName : string) : string;
    function DOSzLogText : string;
    function DOSzLogTextShort : string;
    function QSOinText : string; {for data transfer}
    procedure TextToQSO(str : string); {convert text to bin}
    function QTCStr : string;
  end;

  TQSOList = class
    //ADIF_FieldName : string; // for exchange received
    Saved : boolean;
    List : TList;
    QueList : TList;
    QueOK : boolean;
    AcceptDifferentMode : Boolean;
    CountHigherPoints : Boolean;
    DifferentModePointer : integer; //points to a qso on a different mode but not dupe
    DupeCheckList : array[b19..HiBand] of TStringList;
    function Year: integer; //returns the year of the 1st qso
    function TotalQSO : integer;
    function TotalPoints : integer;
    function TotalCW : integer;
    function TotalMulti1 : integer;
    function TotalMulti2 : integer;
    constructor Create(memo : string);
    destructor Destroy; override;
    procedure Add(aQSO : TQSO);
    procedure Delete(i : integer);
    procedure Insert(i : integer; aQSO : TQSO);
    procedure SaveToFile(Filename : string);
    procedure SaveToFilezLogDOSTXT(Filename : string);
    procedure SaveToFilezLogALL(Filename : string);
    //procedure SaveToFileADIF(Filename : string);
    procedure SaveToFileByTX(Filename : string);
    procedure LoadFromFile(Filename : string);
    function IsDupe(aQSO : TQSO) : integer;
    function IsDupe2(aQSO : TQSO; index : integer; var dupeindex : integer) : boolean;
    function GetPartials(aQSO : TQSO; ALLBand : boolean) : TStrings;
    procedure AddQue(aQSO : TQSO);
    procedure ProcessQue;
    procedure Clear; // deletes all QSOs without destroying the List. Keeps List[0] intact
    procedure SortByTime;
    function ContainBand : TBandBool;
    procedure SetDupeFlags;
    procedure DeleteBand(B : TBand);
    function CheckQSOID(i : integer) : boolean;
    procedure RebuildDupeCheckList;
    procedure ClearDupeCheckList;
    function QuickDupe(aQSO : TQSO) : TQSO;
    procedure RemoveDupes;
    function OpQSO(OpName : string) : integer;
  end;

const
      PowerString : array[p001..p1000] of string[5]  =('1W',
                                                      '2W',
                                                      '5W',
                                                      '10W',
                                                      '20W',
						      '25W',
						      '50W',
						      '100W',
						      '200W',
						      '500W',
						      '1kW');

      NewPowerString : array[p001..p1000] of string[5]  =
                                                     ('P',
                                                      'L',
                                                      'M',
                                                      'H',
                                                      '',
						      '',
						      '',
						      '',
						      '',
						      '',
						      '');

const MHzString : array[b19..HiBand] of string[4] = ('1.9','3.5','7','10','14',
                                             '18','21','24','28','50','144',
                                             '430','1200','2400','5600','10G');

      BandString : array[b19..HiBand] of string[11] = ('1.9 MHz','3.5 MHz','7 MHz','10 MHz',
                                             '14 MHz', '18 MHz','21 MHz','24 MHz','28 MHz',
                                             '50 MHz','144 MHz','430 MHz','1200 MHz','2400 MHz',
                                             '5600 MHz','10 GHz & up');

      ADIFBandString : array[b19..HiBand] of string[4] = ('160m','80m','40m','30m',
                                             '20m', '17m','15m','12m','10m',
                                             '6m','2m','70cm','23cm','13cm',
                                             '6cm','3cm');

      ModeString : array[mCW..mOther] of string[5] =
          ('CW','SSB','FM','AM','RTTY','Other');

      pwrP = TPower(0);
      pwrL = TPower(1);
      pwrM = TPower(2);
      pwrH = TPower(3);

      TrueFalse : array[0..1] of boolean = (False, True);

var BandModeSelect : array[0..1] of TQSOData; // contains band/mode for two tx;

//function FreqKHzToBand(KHz : LongInt) : TBand;

function Random10 : integer;
function UTCOffset : integer;   //in minutes; utc = localtime + utcoffset
function ContainsDoubleByteChar(S : string) : boolean;
function kHzStr(Hz : integer) : string;
procedure IncEditCounter(var aQSO : TQSO);
function ExtractKenNr(S : string) : string; //extracts ken nr from aja#+power
function ExtractPower(S : string) : string;
function IsSHF(B : TBand) : boolean; // true if b >= 2400MHz
function PartialMatch(A, B : string) : boolean; // true if b matches pattern a
function IsMM(S : string) : boolean; // return true if Marine Mobile S is a callsign
function IsWVE(S : string) : boolean; // returns true if W/VE/KH6/KL7 S is country px NOT callsign
function GetHour(T : TDateTime) : integer;
function CurrentTime : TDateTime; {returns in UTC or local time }
function LowCase(C : Char) : Char;
function OldBandOrd(band : TBand) : integer;
function NotWARC(band : TBand) : boolean;
function SameQSO(aQSO, bQSO : TQSO) : boolean;
function SameQSOID(aQSO, bQSO : TQSO) : boolean;
function StrMore(a, b : string) : boolean; // true if a>b
function PXMore(a, b : string) : boolean; // JA1 > XE
function PXIndex(s : string) : integer; // AA = 0 AB = 1 etc
function PXMoreX(a, b : string) : boolean; // double char index
function HexStrToInt(str : string) : integer;
function Less(x, y : integer): integer;
function More(x, y : integer): integer;
function FillRight(s : string; len : integer) : string;
function FillLeft(s : string; len : integer) : string;
function GetUTC: TDateTime;
function GetContestName(Filename: string) : string;
function CoreCall(call : string) : string;
function UsesCoeff(Filename: string) : boolean;
function SameMode2(aMode, bMode : TMode) : boolean;

var Log : TQSOList;
    //SubLog : array[b19..HiBand] of TQSOList;

implementation

(*function ExecuteFile(const FileName, Params, DefaultDir: string;
  ShowCmd: Integer): THandle;
var
  zFileName, zParams, zDir: array[0..79] of Char;
begin
  Result := ShellExecute(MainForm.Handle, nil,
    StrPCopy(zFileName, FileName), StrPCopy(zParams, Params),
    StrPCopy(zDir, DefaultDir), ShowCmd);
end;  *)

function Random10 : integer;
var H, M, S, ms : word;
begin
  DecodeTime(SysUtils.Now, H, M, S, ms);
  Result := S mod 10;
end;

function UTCOffset : integer;
var TZinfo : TTimeZoneInformation;
begin
  GetTimeZoneInformation(TZinfo);
  Result := TZinfo.Bias;
end;

function ContainsDoubleByteChar(S : string) : boolean;
var i : integer;
begin
  Result := False;
  for i := 1 to length(S) do
    if ByteType(S, i) <> mbSingleByte then
      begin
        Result := True;
        break;
      end;
end;

function kHzStr(Hz : integer) : string;
var k, kk : integer;
begin
  k := Hz div 1000;
  kk := Hz mod 1000;
  kk := kk div 100;
  if k > 100000 then
    Result := IntToStr(k)
  else
    Result := IntToStr(k) + '.' + IntToStr(kk);
end;

procedure IncEditCounter(var aQSO : TQSO);
begin
  if aQSO.QSO.Reserve3 mod 100 < 99 then
    inc(aQSO.QSO.Reserve3);
end;

function ExtractKenNr(S : string) : string; //extracts ken nr from aja#+power
var str : string;
begin
  Result := '';
  str := copy(S, 1, 2);
  Result := str;
end;

function ExtractPower(S : string) : string; //extracts power code. returns '' if no power
begin
  Result := '';
  if S = '' then
    exit;
  if S[Length(S)] in ['H', 'M', 'L', 'P'] then
    Result := S[Length(S)];
end;

function IsSHF(B : TBand) : boolean; // true if b >= 2400MHz
begin
  Result := (B >= b2400);
end;

function PartialMatch(A, B : string) : boolean; // true if b matches pattern a
var i : integer;
begin
  Result := False;
  if (Pos('.', A) = 0) {and (Pos('?',A)=0)} then
    Result := (Pos(A, B) > 0)
  else
    begin
      if length(A) > length(B) then
        exit;
      for i := 1 to length(A) do
        if A[i] <> '.' then
          if A[i] <> B[i] then
            exit;
      Result := True;
    end;
end;

function IsMM(S : string) : boolean;
begin
  if pos('/MM',S) > 0 then
    Result := True
  else
    Result := False;
end;

function IsWVE(S : string) : boolean;
begin
  if (S = 'K') or (S = 'W') or (S = 'N') or (S = 'KH6') or
     (S = 'KL7') or (S = 'KL') or (S = 'VE') then
    Result := True
  else
    Result := False;
end;

function GetLocale: String;
var
  Buf: PChar;
begin
  Buf := StrAlloc(256);
  GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SENGCOUNTRY, Buf, 256);
  Result := StrPas(Buf);
  StrDisPose(Buf);
end;

function GetHour(T : TDateTime) : integer;
var H, M, S, ms : word;
begin
  DecodeTime(T, H, M, S, ms);
  Result := H;
end;

function CurrentTime : TDateTime;
begin
  if UseUTC then
    Result := GetUTC
  else
    Result := SysUtils.Now;
end;

function LowCase(C : Char) : Char;
begin
  if C in ['A'..'Z'] then
    Result := Chr(ord(C)-ord('A')+ord('a'))
  else
    Result := C;
end;

function OldBandOrd(band : TBand) : integer;
begin
  case band of
    b19..b7 : Result := ord(band);
    b14 : Result := ord(band)-1;
    b21 : Result := ord(band)-2;
    b28..HiBand : Result := ord(band)-3;
  else
    Result := 0;
  end;
end;

function NotWARC(band : TBand) : boolean;
begin
  if band in [b10, b18, b24] then
    Result := False
  else
    Result := True;
end;

function GetUTC: TDateTime;
var
  stUTC: TSystemTime;
begin
  GetSystemTime(stUTC);
//TDateTimes are doubles with the time expressed as the
//fractional component so we can add them together in
//this situation
  result := EncodeDate(stUTC.wYear, stUTC.wMonth, stUTC.wDay) +
            EncodeTime(stUTC.wHour, stUTC.wMinute,
                       stUTC.wSecond, stUTC.wMilliseconds);
end;

function SameQSO(aQSO, bQSO : TQSO) : boolean;
begin
  if (aQSO.QSO.Band = bQSO.QSO.Band) and
     (aQSO.QSO.Callsign = bQSO.QSO.Callsign) and
     (aQSO.QSO.Mode = bQSO.QSO.Mode) and
     (aQSO.QSO.Dupe = bQSO.QSO.Dupe) and
     (aQSO.QSO.Serial = bQSO.QSO.Serial) then
    Result := True
  else
    Result := False;
end;

function SameQSOID(aQSO, bQSO : TQSO) : boolean;
begin
  if (aQSO.QSO.Reserve3 div 100) = (bQSO.QSO.Reserve3 div 100) then
    Result := True
  else
    Result := False;
end;

function StrMore(a, b : string) : boolean;  {true if a>b}
var i, j : integer;
begin
  for i := 1 to Less(length(a), length(b)) do
    begin
      if ord(a[i]) > ord(b[i]) then
        begin
          Result := True;
          exit;
        end;
      if ord(a[i]) < ord(b[i]) then
        begin
          Result := False;
          exit;
        end;
    end;
  if length(a) > length(b) then
    Result := True
  else
    Result := False;
end;

function PXMore(a, b : string) : boolean;  {true if a>b}
var i, j : integer;
begin
  if a[1] = b[1] then
    begin
      if length(a) > length(b) then
        begin
          Result := False;
          exit;
        end;
      if length(a) < length(b) then
        begin
          Result := True;
          exit;
        end;
      Result := StrMore(a, b);
      exit;
    end;
  Result := StrMore(a, b);
end;

function PXIndex(s : string) : integer;
var i, j : integer;
begin
  result := 0;
  if length(s) = 0 then
    exit;
  if length(s) = 1 then
    begin
      case s[1] of
        'A'..'Z' : Result := ord(s[1]) - ord('A') + 37*37;
        '0'..'9' : Result := ord(s[1]) - ord('0') + 37*37 + 26;
        '/' : Result := 37*37 + 36;
      end;
    end
  else
    begin
      i := 0; j := 0;
      case s[1] of
        'A'..'Z' : i := ord(s[1]) - ord('A');
        '0'..'9' : i := ord(s[1]) - ord('0') + 26;
        '/' : i := 36;
      end;
      case s[2] of
        'A'..'Z' : i := ord(s[2]) - ord('A');
        '0'..'9' : i := ord(s[2]) - ord('0') + 26;
        '/' : i := 36;
      end;
      Result := i*37 + j;
    end;
end;

function PXMoreX(a, b : string) : boolean;  {true if a>b}
var i, j, PXA, PXB : integer;
begin
  PXA := PXIndex(a);
  PXB := PXIndex(b);
  if PXA = PXB then
    begin
      if length(a) > length(b) then
        begin
          Result := False;
          exit;
        end;
      if length(a) < length(b) then
        begin
          Result := True;
          exit;
        end;
      Result := StrMore(a, b);
      exit;
    end;
  Result := PXA > PXB;
end;

procedure TQSO.IncTime;
var T : TDateTime;
begin
  Self.QSO.Time := Self.QSO.Time + 1.0 / (24*60);
end;

procedure TQSO.DecTime;
var T : TDateTime;
begin
  Self.QSO.Time := Self.QSO.Time - 1.0 / (24*60);
end;

function TQSO.QSOinText : string; {for data transfer}
var str : string;
begin
  str := 'ZLOGQSODATA:'+_sep;
  //str := str + DateTimeToStr(QSO.Time) + _sep;
  str := str + FloatToStr(QSO.Time) + _sep;
  str := str + QSO.CallSign + _sep;
  str := str + QSO.NrSent + _sep;
  str := str + QSO.NrRcvd + _sep;
  str := str + IntToStr(QSO.RSTSent) + _sep;
  str := str + IntToStr(QSO.RSTRcvd) + _sep;
  str := str + IntToStr(QSO.Serial) + _sep;
  str := str + IntToStr(ord(QSO.Mode)) + _sep;
  str := str + IntToStr(ord(QSO.Band)) + _sep;
  str := str + IntToStr(ord(QSO.Power)) + _sep;
  str := str + QSO.Multi1 + _sep;
  str := str + QSO.Multi2 + _sep;
  if QSO.NewMulti1 then
    str := str + '1' + _sep
  else
    str := str + '0' + _sep;
  if QSO.NewMulti2 then
    str := str + '1' + _sep
  else
    str := str + '0' + _sep;
  str := str + IntToStr(QSO.Points) + _sep;
  str := str + QSO.Operator + _sep;
  str := str + QSO.Memo + _sep;
  if QSO.CQ then
    str := str + '1' + _sep
  else
    str := str + '0' + _sep;
  if QSO.Dupe then
    str := str + '1' + _sep
  else
    str := str + '0' + _sep;
  str := str + IntToStr(QSO.Reserve) + _sep;
  str := str + IntToStr(QSO.TX) + _sep;
  str := str + IntToStr(QSO.Power2) + _sep;
  str := str + IntToStr(QSO.Reserve2) + _sep;
  str := str + IntToStr(QSO.Reserve3);

  Result := str;
end;

procedure TQSO.TextToQSO(str : string); {convert text to bin}
var _Items : array[0..25] of string;
    i, j : integer;
begin
  for i := 0 to 25 do
    _Items[i] := '';
  j := 0;
  for i := 1 to length(str) do
    begin
      if str[i] = _sep then
        inc(j)
      else
        _Items[j] := _Items[j] + str[i];
    end;

  if _Items[0] <> 'ZLOGQSODATA:' then exit;
  //QSO.Time := StrToDateTime(_Items[1]);
  try
    QSO.Time := StrToFloat(_Items[1]);
    QSO.CallSign := _Items[2];
    QSO.NrSent := _Items[3];
    QSO.NrRcvd := _Items[4];
    QSO.RSTSent := StrToInt(_Items[5]);
    QSO.RSTRcvd := StrToInt(_Items[6]);
    QSO.Serial := StrToInt(_Items[7]);
    QSO.Mode := TMode(StrToInt(_Items[8]));
    QSO.Band := TBand(StrToInt(_Items[9]));
    QSO.Power := TPower(StrToInt(_Items[10]));
    QSO.Multi1 := _Items[11];
    QSO.Multi2 := _Items[12];
    QSO.NewMulti1 := StrToInt(_Items[13]) = 1;
    QSO.NewMulti2 := StrToInt(_Items[14]) = 1;
    QSO.Points := StrToInt(_Items[15]);
    QSO.Operator := _Items[16];
    QSO.Memo := _Items[17];
    QSO.CQ := StrToInt(_Items[18]) = 1;
    QSO.Dupe := StrToInt(_Items[19]) = 1;
    QSO.Reserve := StrToInt(_Items[20]);
    QSO.TX := StrToInt(_Items[21]);
    QSO.Power2 := StrToInt(_Items[22]);
    QSO.Reserve2 := StrToInt(_Items[23]);
    QSO.Reserve3 := StrToInt(_Items[24]);
  except
    on EConvertError do
      QSO.Memo := 'Convert Error!';
  end;
{ if QSO.Dupe then
    str := str + '1' + _sep
  else
    str := str + '0' + _sep;
  str := str + IntToStr(QSO.Reserve);}
end;

function Power(base, power : integer) : integer;
var i, j : integer;
begin
  j := 1;
  for i := 1 to power do
    j := j * base;
  Result := j;
end;

function HexStrToInt(str : string) : integer;
var i, j, digit : integer;
begin
  i := 0;
  for j := length(str) downto 1 do
    begin
      case str[j] of
        '0'..'9' : digit := ord(str[j])-ord('0');
        'a'..'f' : digit := ord(str[j])-ord('a')+10;
        'A'..'F' : digit := ord(str[j])-ord('A')+10;
      else
        begin
          Result := -1;
          exit;
        end;
      end;
      i := i + Power(16,length(str)-j)*digit;
    end;
  Result := i;
end;

function Less(x, y : integer): integer;
begin
  if x > y then
    result := y
  else
    result := x;
end;

function More(x, y : integer): integer;
begin
  if x > y then
    result := x
  else
    result := y;
end;

function FillRight(s : string; len : integer) : string;
var str : string;
begin
  str := s;
  while Length(str) < len do
    str := str + ' ';
  Result := str;
end;

function FillLeft(s : string; len : integer) : string;
var str : string;
begin
  str := s;
  while Length(str) < len do
    str := ' ' + str;
  Result := str;
end;

constructor TFastSortedList.Create;
var i : integer;
begin
  for i := 0 to MAXLOGCAPACITY do
    List[i] := '';
  items := 0;
end;

procedure TFastSortedList.Add(S : string);
begin
end;

function TFastSortedList.Exists(S : string) : boolean;
begin
end;

constructor TQSO.Create;
begin
  with QSO do
  begin
    Time := SysUtils.Date + SysUtils.Time;
    CallSign := '';
    {NrSent := '';}
    NrRcvd := '';
    if Mode = mCW then
      begin
        RSTSent := 599;
        RSTRcvd := 599;
      end
    else
      begin
        RSTSent := 59;
        RSTRcvd := 59;
      end;

    Serial := 1;
    {Mode := mCW;
    Band := b7;}
    Multi1 := '';
    Multi2 := '';
    NewMulti1 := false;
    NewMulti2 := false;
    Points := 1;
    {Operator := '';}
    Memo := '';
    CQ := False;
    Dupe := False;
    Reserve := 0;
    TX := 0;
    Power2 := 500;
    Reserve2 := 0;
    Reserve3 := 0;
  end;
end;

procedure TQSO.UpdateTime;
begin
  if UseUTC then
    QSO.Time := GetUTC
  else
    QSO.Time := SysUtils.Now;
end;

function TQSO.SerialStr : string;
var s : string;
begin
  s := IntToStr(Self.QSO.Serial);
  case Length(s) of
    1 : s := '00'+s;
    2 : s := '0' +s;
  end;
  Result := s;
end;

function TQSO.QTCStr : string;
begin
  Result := FormatDateTime('hhnn',Self.QSO.Time)+' '+ Self.QSO.Callsign
                           + ' ' + Self.QSO.NrRcvd;
end;

function TQSO.TimeStr : string;
begin
  Result := FormatDateTime('hh:nn',Self.QSO.Time);
end;

function TQSO.DateStr : string;
begin
  Result := FormatDateTime('yy/mm/dd',Self.QSO.Time);
end;

function TQSO.BandStr : string;
begin
  Result := MHzString[Self.QSO.Band];
end;

function TQSO.ModeStr : string;
begin
  Result := ModeString[Self.QSO.Mode];
end;

function TQSO.PowerStr : string;
var i : integer;
begin
  i := Self.QSO.power2;
  case i of
    9999 : Result := 'KW';
    10000 : Result := '1KW';
    10001 : Result := 'K';
  else
    Result := IntToStr(i);
  end;
end;

function TQSO.NewPowerStr : string;
begin
  Result := NewPowerString[Self.QSO.power];
end;

function TQSO.PointStr : string;
begin
  Result := IntToStr(Self.QSO.points);
end;

function TQSO.RSTStr : string;
begin
  Result := IntToStr(Self.QSO.RSTrcvd);
end;

function TQSO.RSTSentStr : string;
begin
  Result := IntToStr(Self.QSO.RSTsent);
end;

function TQSO.PartialSummary(DispDate: boolean) : string;
var S : string;
begin
  if DispDate then S := DateStr+' ' else
    S := '';
  S := S + TimeStr + ' ';
  S := S + FillRight(Self.QSO.Callsign, 12);
  S := S + FillRight(Self.QSO.NrRcvd, 15);
  S := S + FillRight(BandStr, 5);
  S := S + FillRight(ModeStr, 5);
  Result := S;
end;

function TQSO.CheckCallSummary : string;
var S : string;
begin
  S := '';
  S := S + FillRight(BandStr, 5);
  S := S + TimeStr + ' ';
  S := S + FillRight(Self.QSO.Callsign, 12);
  S := S + FillRight(Self.QSO.NrRcvd, 15);
  S := S + FillRight(ModeStr, 5);
  Result := S;
end;

function TQSO.DOSzLogText : string;
var S, temp : string;
    Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  S := '';
  DecodeDate(Self.QSO.Time, Year, Month, Day);
  DecodeTime(Self.QSO.Time, Hour, Min, Sec, MSec);
  S := S + FillLeft(IntToStr(Month), 3) +  ' ' +
           FillLeft(IntToStr(Day), 3) + ' ';

  temp := IntToStr(Hour*100+Min);
  case length(temp) of
    1 : temp := '000' + temp;
    2 : temp := '00' + temp;
    3 : temp := '0' + temp;
  end;

  S := S + temp + ' ';
  S := S + FillRight(Self.QSO.Callsign, 11);
  S := S + FillLeft(IntToStr(Self.QSO.RSTsent), 3);
  S := S + FillRight(Self.QSO.NrSent, 31);
  S := S + FillLeft(IntToStr(Self.QSO.RSTrcvd), 3);
  S := S + FillRight(Self.QSO.NrRcvd, 31);

  if Self.QSO.NewMulti1 then
     S := S + FillLeft(Self.QSO.Multi1, 6)
  else
     S := S + '      ';
  S := S + '  ' + FillLeft(MHzString[Self.QSO.Band], 4);
  S := S + '  ' + FillRight(ModeString[Self.QSO.Mode], 3);
  S := S + ' ' + FillRight(IntToStr(Self.QSO.Points), 2);
  if Self.QSO.Operator <> '' then
    //S := S + ' ' + '%%'+ Self.QSO.Operator +'%%';
    S := S + '%%'+ Self.QSO.Operator +'%%';
  // S := S + ' ' + Self.QSO.memo;
  S := S + Self.QSO.memo;
  Result := S;
end;

function TQSO.DOSzLogTextShort : string;
var S, temp : string;
    Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  S := '';
  DecodeDate(Self.QSO.Time, Year, Month, Day);
  DecodeTime(Self.QSO.Time, Hour, Min, Sec, MSec);
  S := S + FillLeft(IntToStr(Month), 3) +  ' ' +
           FillLeft(IntToStr(Day), 3) + ' ';

  temp := IntToStr(Hour*100+Min);
  case length(temp) of
    1 : temp := '000' + temp;
    2 : temp := '00' + temp;
    3 : temp := '0' + temp;
  end;

  S := S + temp + ' ';
  S := S + FillRight(Self.QSO.Callsign, 11);
  S := S + FillLeft(IntToStr(Self.QSO.RSTsent), 3);
  S := S + FillRight(Self.QSO.NrSent, 10);
  S := S + FillLeft(IntToStr(Self.QSO.RSTrcvd), 3);
  S := S + FillRight(Self.QSO.NrRcvd, 10);

  if Self.QSO.NewMulti1 then
     S := S + FillLeft(Self.QSO.Multi1, 6)
  else
     S := S + '      ';
  S := S + '  ' + FillLeft(MHzString[Self.QSO.Band], 4);
  S := S + '  ' + FillRight(ModeString[Self.QSO.Mode], 3);
  S := S + ' ' + FillRight(IntToStr(Self.QSO.Points), 2);
  if Self.QSO.Operator <> '' then
    S := S + '  ' + '%%'+ Self.QSO.Operator +'%%';
  S := S + '  ' + Self.QSO.memo;
  Result := S;
end;

function TQSO.zLogALL : string;
var S, temp : string;
    nrlen : integer;
begin
  nrlen := 7;
  S := '';
  S := S + FormatDateTime('yyyy/mm/dd hh":"nn ',Self.QSO.Time);
  S := S + FillRight(Self.QSO.Callsign, 13);
  S := S + FillRight(IntToStr(Self.QSO.RSTsent), 4);
  S := S + FillRight(Self.QSO.NrSent, nrlen+1);
  S := S + FillRight(IntToStr(Self.QSO.RSTrcvd), 4);
  S := S + FillRight(Self.QSO.NrRcvd, nrlen+1);

  if Self.QSO.NewMulti1 then
     S := S + FillRight(Self.QSO.Multi1, 6)
  else
     S := S + '-     ';
  if Self.QSO.NewMulti2 then
     S := S + FillRight(Self.QSO.Multi2, 6)
  else
     S := S + '-     ';
  S := S + FillRight(MHzString[Self.QSO.Band], 5);
  S := S + FillRight(ModeString[Self.QSO.Mode], 5);
  S := S + FillRight(IntToStr(Self.QSO.Points), 3);
  if Self.QSO.Operator <> '' then
    S := S + FillRight('%%'+Self.QSO.Operator+'%%', 19);
  if OperatorCategory > 0 then
    S := S + FillRight('TX#'+IntToStr(Self.QSO.TX), 6);
  S := S + Self.QSO.memo;
  Result := S;
end;


function TQSOList.ContainBand : TBandBool;
var R : TBandBool;
    B : TBand;
    i : Integer;
begin
  for B := b19 to HiBand do
    R[B] := False;
  for i := 1 to TotalQSO do
    R[TQSO(List[i]).QSO.Band] := True;
  Result := R;
end;

constructor TQSOList.Create(memo : string);
var Q : TQSO;
    B : TBand;
begin
  //ADIF_FieldName := 'qth';
  List := TList.Create;
  QueList := TList.Create;

  for B := b19 to HiBand do
    begin
      DupeCheckList[B] := TStringList.Create;
      DupeCheckList[B].Sorted := True;
      DupeCheckList[B].Duplicates := dupAccept;
    end;

  Q := TQSO.Create;
  List.Add(Q);
  TQSO(List[0]).QSO.memo := memo;
  TQSO(List[0]).QSO.Time := 1.0000;
  TQSO(List[0]).QSO.Time := -1;
  Saved := True;
  QueOK := True;
  AcceptDifferentMode := False;
  CountHigherPoints := False;
  DifferentModePointer := 0;
end;

function TQSOList.Year : integer;
var T : TDateTime;
    y, m, d : word;
begin
  Result := 0;
  if TotalQSO > 0 then
    T := TQSO(List[1]).QSO.Time
  else
    exit;
  DecodeDate(T, y, m, d);
  Result := y;
end;

procedure TQSOList.SortByTime;
var i : integer;
    boo : boolean;
begin
  if TotalQSO < 2 then exit;
  boo := true;
  while boo do
    begin
      boo := false;
      for i := 1 to TotalQSO - 1 do
        if TQSO(List[i]).QSO.Time > TQSO(List[i+1]).QSO.Time then
          begin
            List.Exchange(i, i+1);
            boo := true;
          end;
    end;
end;

procedure TQSOList.Clear;
var i, max : integer;
    aQSO : TQSO;
begin
  max := List.Count - 1;
  For i := 1 to max do
    begin
      aQSO := List[1];
      aQSO.Free;
      List.Delete(1);
    end;
  List.Pack;
  ClearDupeCheckList;
  Saved := False;
end;

procedure TQSOList.ClearDupeCheckList;
var B : TBand;
begin
  for B := b19 to HiBand do
    DupeCheckList[B].Clear;
end;

procedure TQSOList.Add(aQSO : TQSO);
var xQSO : TQSO;
begin
  xQSO := TQSO.Create;
  xQSO.QSO := aQSO.QSO;
  List.Add(xQSO);

  DupeCheckList[xQSO.QSO.Band].AddObject(CoreCall(xQSO.QSO.Callsign),xQSO);

  Saved := False;
end;

procedure TQSOList.AddQue(aQSO : TQSO);
var xQSO : TQSO;
begin
  xQSO := TQSO.Create;
  xQSO.QSO := aQSO.QSO;
  //xQSO.QSO.Reserve := actAdd;
  QueList.Add(xQSO);
  Saved := False;
end;

procedure TQSOList.ProcessQue;
var xQSO, yQSO, zQSO, wQSO : TQSO;
    i, j, id : integer;
begin
  if QueList.Count = 0 then
    exit;
  Repeat until QueOK;
  while QueList.Count > 0 do
    begin
      xQSO := TQSO(QueList[0]);
      case xQSO.QSO.Reserve of
        actAdd : Add(xQSO);
        actDelete :
          begin
            for i := 1 to TotalQSO do
              begin
                yQSO := TQSO(List[i]);
                if SameQSOID(xQSO, yQSO) then
                  begin
                    Self.Delete(i);
                    break;
                  end;
              end;
          end;
        actEdit :
          begin
            for i := 1 to TotalQSO do
              begin
                yQSO := TQSO(List[i]);
                if SameQSOID(xQSO, yQSO) then
                  begin
                    //TQSO(List[i]).QSO := xQSO.QSO;
                    yQSO.QSO := xQSO.QSO;
                    RebuildDupeCheckList;
                    break;
                  end;
              end;
            {
            if QueList.Count = 1 then
              exit;
            for j := 1 to QueList.Count - 1 do
              if TQSO(QueList[j]).QSO.Reserve = actEdit then
                break;
            yQSO := TQSO(QueList[j]);
            if yQSO.QSO.Reserve <> actEdit then exit;

            for i := 1 to TotalQSO do
              begin
                zQSO := TQSO(List[i]);
                if SameQSO(xQSO, zQSO) then
                  begin
                    TQSO(List[i]).QSO := yQSO.QSO;
                    break;
                  end;
              end;

            QueList.Delete(j);}
          end;
        actInsert :
          begin
            for i := 1 to TotalQSO do
              begin
                yQSO := TQSO(List[i]);
                id := xQSO.QSO.Reserve2 div 100;
                if id = (yQSO.QSO.Reserve3 div 100) then
                  begin
                    wQSO := TQSO.Create;
                    wQSO.QSO := xQSO.QSO;
                    Insert(i, wQSO);
                    break;
                  end;
              end;
            {
            if QueList.Count = 1 then
              exit;
            for j := 1 to QueList.Count - 1 do
              if TQSO(QueList[j]).QSO.Reserve = actInsert then
                break;
            yQSO := TQSO(QueList[j]);
            if yQSO.QSO.Reserve <> actInsert then exit;


            for i := 1 to TotalQSO do
              begin
                zQSO := TQSO(List[i]);
                if SameQSO(xQSO, zQSO) then
                  begin
                    wQSO := TQSO.Create;
                    wQSO.QSO := yQSO.QSO;
                    Insert(i, wQSO);
                    break;
                  end;
              end;
            QueList.Delete(j); }
          end;
        actLock :
          begin
            for i := 1 to TotalQSO do
              begin
                zQSO := TQSO(List[i]);
                if SameQSOID(xQSO, zQSO) then
                  begin
                    TQSO(List[i]).QSO.Reserve := actLock;
                    break;
                  end;
              end;
          end;
        actUnLock :
          begin
            for i := 1 to TotalQSO do
              begin
                zQSO := TQSO(List[i]);
                if SameQSOID(xQSO, zQSO) then
                  begin
                    TQSO(List[i]).QSO.Reserve := 0;
                    break;
                  end;
              end;
          end;
      end;
      TQSO(QueList[0]).Free;  //added 0.23
      QueList.Delete(0);
      QueList.Pack;
    end;
  Saved := False;
end;

procedure TQSOList.Delete(i : integer);
var aQSO : TQSO;
begin
  if i <= TotalQSO then
    begin
      aQSO := TQSO(List[i]);
      aQSO.Free;
      List.Delete(i);
      List.Pack;
      {List[i]:=nil;
      List.Pack;}
      Saved := False;
      RebuildDupeCheckList;
    end;
end;

procedure TQSOList.RemoveDupes;
var i : integer;
    aQSO : TQSO;
begin
  for i := 1 to TotalQSO do
    begin
      aQSO := TQSO(List[i]);
      if pos('-DUPE-', aQSO.QSO.Memo) > 0 then
        begin
          List[i] := nil;
          aQSO.Free;
        end;
    end;
  List.Pack;
  Saved := False;
  RebuildDupeCheckList;
end;


procedure TQSOList.DeleteBand(B : TBand);
var i : integer;
begin
  for i := 1 to TotalQSO do
    if TQSO(List[i]).QSO.Band = B then
      begin
        TQSO(List[i]).Free;
        List[i] := nil;
        Saved := False;
      end;
  RebuildDupeCheckList;
  List.Pack;
end;

function TQSOList.CheckQSOID(i : integer) : boolean;
var j, id : integer;
begin
  Result := False;
  id := i div 100; // last two digits are edit counter
  for j := 1 to TotalQSO do
    begin
      if id = (TQSO(List[j]).QSO.Reserve3 div 100) then
        begin
          Result := True;
          break;
        end;
    end;
end;

procedure TQSOList.Insert(i : integer; aQSO : TQSO);
begin
  List.Insert(i, aQSO);
  RebuildDupeCheckList;
  Saved := False;
end;

procedure TQSOList.SaveToFile(Filename : string);
var f : file of TQSOdata;
    //D : TQSOdata;
    i : word;
    back : string;
begin
  back := filename;
  back := copy(back,1,length(back)-4) + '.BAK'; // change the extension
  if FileExists(back) then
    begin
       AssignFile(f, Filename);
      if FileSize(f) = 0 then
        begin
          RenameFile(back, back + '.bak');
        end
      else
        SysUtils.DeleteFile(back);
    end;
  RenameFile(filename, back);
  AssignFile(f, Filename);
  rewrite(f);
  //D.memo := 'test';
  //write(f,D);
  for i := 0 to TotalQSO do // changed from 1 to TotalQSO to 0 to TotalQSO
    write(f,TQSO(List[i]).QSO);
  closefile(f);
  Saved := True;
end;

procedure TQSOList.SaveToFilezLogDOSTXT(Filename : string);
var f : textfile;
    str : string;
    i, j, max : integer;
const LongHeader = 'mon day time  callsign      sent                              rcvd                           multi   MHz mode pts memo';
      ShortHeader ='mon day time  callsign      sent         rcvd      multi   MHz mode pts memo';
begin
  assignfile(f, Filename);
  rewrite(f);
  {str := 'zLog for Windows Text File';}
  max := 0;
  for i := 1 to TotalQSO do
    begin
      j := length(TQSO(List[i]).QSO.NrRcvd);
      if j > max then
        max := j;
      j := length(TQSO(List[i]).QSO.NrSent);
      if j > max then
        max := j;
    end;
  if j >= 10 then
    begin
      writeln(f, LongHeader);
      for i := 1 to TotalQSO do
        writeln(f, TQSO(List[i]).DOSzLogText);
    end
  else
    begin
      writeln(f, ShortHeader);
      for i := 1 to TotalQSO do
        writeln(f, TQSO(List[i]).DOSzLogTextShort);
    end;
  closefile(f);
end;

procedure TQSOList.SaveToFilezLogALL(Filename : string);
var f : textfile;
    Header : string;
    i, max : integer;
begin
  Header := 'zLog for Windows '; //+Options.Settings._mycall;
  assignfile(f, Filename);
  rewrite(f);
  {str := 'zLog for Windows Text File';}
  max := 0;
  writeln(f, Header);
  for i := 1 to TotalQSO do
    writeln(f, TQSO(List[i]).zLogALL);
  closefile(f);
end;

procedure TQSOList.SaveToFileByTX(Filename : string);
var f : textfile;
    Header : string;
    i, j : integer;
    txset : set of byte;
begin
  txset := [];
  for i := 1 to TotalQSO do
    txset := txset + [TQSO(List[i]).QSO.TX];
  Header := 'zLog for Windows '; //+Options.Settings._mycall;
  System.Delete(FileName,Length(FileName)-2,3);
  for i := 0 to 255 do
    if i in txset then
      begin
        assignfile(f, Filename+'.'+IntToStr(i)+'.TX');
        rewrite(f);
        writeln(f, Header+' TX# '+IntToStr(i));
        for j := 1 to TotalQSO do
          if TQSO(List[j]).QSO.TX = i then
            writeln(f, TQSO(List[j]).zLogALL);
        closefile(f);
      end;
end;

procedure TQSOList.LoadFromFile(Filename : string);
begin
end;

destructor TQSOList.Destroy;
var i : integer;
begin
  for i := 0 to List.Count - 1 do
    begin
      if List[i] <> nil then
        TQSO(List[i]).Free;
    end;
  List.Free;
end;

procedure TQSOList.RebuildDupeCheckList;
var i : integer;
    Q : TQSO;
begin
  ClearDupeCheckList;
  for i := 0 to List.Count - 1 do
    begin
      Q := TQSO(List[i]);
      DupeCheckList[Q.QSO.Band].AddObject(CoreCall(Q.QSO.Callsign),Q);
    end;
end;

function TQSOList.QuickDupe(aQSO : TQSO) : TQSO;
var i : integer;
    s : string;
    Q, Q2 : TQSO;
begin
  Result := nil;
  Q := nil;
  s := CoreCall(aQSO.QSO.Callsign);
  i := DupeCheckList[aQSO.QSO.Band].IndexOf(s);
  if (i >= 0) and (i < DupeCheckList[aQSO.QSO.Band].Count) then
    begin
      Q := TQSO(DupeCheckList[aQSO.QSO.Band].Objects[i]);
      if Q.QSO.Band = aQSO.QSO.Band then
        Result := Q;
    end;

  if AcceptDifferentMode and (Q <> nil) then
    begin
      if aQSO.QSO.Mode <> Q.QSO.Mode then
        begin
          Result := nil;
          for i := 0 to DupeCheckList[aQSO.QSO.Band].Count - 1 do
            begin
              if s = DupeCheckList[aQSO.QSO.Band][i] then
                begin
                  Q2 := TQSO(DupeCheckList[aQSO.QSO.Band].Objects[i]);
                  if aQSO.QSO.Mode = Q2.QSO.Mode then
                    begin
                      Result := Q2;
                      exit;
                    end;
                end;
            end;
        end;
    end;
end;

function TQSOList.OpQSO(OpName : string) : integer;
var i, j : integer;
begin
  j := 0;
  for i := 1 to TotalQSO do
    if TQSO(List[i]).QSO.Operator = OpName then
      inc(j);
  Result := j;
end;

function CoreCall(call : string) : string;
var p : integer;
    str : string;
begin
  str := call;
  p:=Pos('/',str);
  if p > 4 then
    Delete(str, p, 255);
  Result := str;
end;

function SameMode(aQSO, bQSO : TQSO) : boolean;
begin
  Result := False;
  case aQSO.QSO.Mode of
    mCW : if bQSO.QSO.Mode = mCW then
            Result := True;
    mSSB, mFM, mAM :
          if bQSO.QSO.Mode in [mSSB, mFM, mAM] then
            Result := True;
    mRTTY :
          if bQSO.QSO.Mode = mRTTY then
            Result := True;
    mOther :
          if bQSO.QSO.Mode = mOther then
            Result := True;
  end;
end;

function SameMode2(aMode, bMode : TMode) : boolean;
begin
  Result := False;
  case aMode of
    mCW : if bMode = mCW then
            Result := True;
    mSSB, mFM, mAM :
          if bMode in [mSSB, mFM, mAM] then
            Result := True;
    mRTTY :
          if bMode = mRTTY then
            Result := True;
    mOther :
          if bMode = mOther then
            Result := True;
  end;
end;

function TQSOList.IsDupe(aQSO : TQSO) : integer;
var x : integer;
    i : word;
    str : string;
begin
  DifferentModePointer := 0;
  x := 0;
  str := CoreCall(aQSO.QSO.Callsign);
  for i := 1 to TotalQSO do
    begin
      if (aQSO.QSO.band = TQSO(List[i]).QSO.band) and (str = CoreCall(TQSO(List[i]).QSO.Callsign)) then
        begin
          if Not(AcceptDifferentMode) then
            begin
              x := i;
              break;
            end
          else
            begin
              if SameMode(aQSO, TQSO(List[i])) then
                begin
                  x := i;
                  break;
                end
              else {different mode qso exists but not dupe}
                begin
                  DifferentModePointer := i;
                end;
            end;
        end;
    end;
  Result := x;
end;

function TQSOList.IsDupe2(aQSO : TQSO; index : integer; var dupeindex : integer) : boolean;
var boo : boolean;
    i : word;
    str : string;
begin
  boo := false;
  str := CoreCall(aQSO.QSO.Callsign);
  for i := 1 to TotalQSO do
    begin
      if (aQSO.QSO.band = TQSO(List[i]).QSO.band) and
         (str = CoreCall(TQSO(List[i]).QSO.Callsign)) and
         ((index <= 0) or (index <> i)) then
        begin
          if Not(AcceptDifferentMode) or
             (AcceptDifferentMode and SameMode(aQSO, TQSO(List[i])) ) then
            begin
              boo := True;
              if index > 0 then
                dupeindex := i;
              break;
            end;
        end;
    end;
  Result := boo;
end;

procedure TQSOList.SetDupeFlags;
var i, j : integer;
    str, temp : string;
    aQSO : TQSO;
    TempList : array[ord('A')..ord('Z')] of TStringList;
    ch : char;
    core : string;
begin
  if TotalQSO = 0 then
    exit;
  for i := ord('A') to ord('Z') do
    begin
      TempList[i] := TStringList.Create;
      TempList[i].Sorted := True;
      TempList[i].Capacity := 200;
    end;

  for i := 1 to TotalQSO do
    begin
      aQSO := TQSO(List[i]);
      core := CoreCall(aQSO.QSO.Callsign);
      if AcceptDifferentMode then
        str := core + aQSO.BandStr + aQSO.ModeStr
      else
        str := core + aQSO.BandStr;

      if core = '' then
        ch := 'Z'
      else
        ch := core[length(core)];

      if not(ch in ['A'..'Z']) then
        ch := 'Z';

      if TempList[ord(ch)].Find(str, j) = True then
        begin
          aQSO.QSO.Points := 0;
          aQSO.QSO.Dupe := True;
          temp := aQSO.QSO.memo;
          if Pos('-DUPE-',temp) = 0 then
            aQSO.QSO.memo := '-DUPE- '+temp;
        end
      else
        begin
          aQSO.QSO.Dupe := False;
          temp := aQSO.QSO.memo;
          if Pos('-DUPE-',temp) = 1 then
            aQSO.QSO.memo := Copy(temp, 8, 255);
          TempList[ord(ch)].Add(str);
        end;
    end;
  for i := ord('A') to ord('Z') do
    begin
      TempList[i].Clear;
      TempList[i].Free;
    end;
end;

function TQSOList.GetPartials(aQSO : TQSO; ALLBand : boolean) : TStrings;
begin  {function moved to UPartials}
end;

function TQSOList.TotalQSO : integer;
begin
  Result := List.Count - 1;
end;

function TQSOList.TotalPoints : integer;
var count, i : integer;
begin
  count := 0;
  for i := 1 to TotalQSO do
    count := TQSO(List.Items[i]).QSO.Points + count;
  Result := count;
end;

function TQSOList.TotalCW : integer;
var count, i : integer;
begin
  count := 0;
  for i := 1 to TotalQSO do
    if TQSO(List.Items[i]).QSO.Mode = mCW then
      inc(count);
  Result := count;
end;

function TQSOList.TotalMulti1 : integer;
var count, i : integer;
begin
  count := 0;
  for i := 1 to TotalQSO do
    if TQSO(List.Items[i]).QSO.NewMulti1 then
      inc(count);
  Result := count;
end;

function TQSOList.TotalMulti2 : integer;
var count, i : integer;
begin
  count := 0;
  for i := 1 to TotalQSO do
    if TQSO(List.Items[i]).QSO.NewMulti2 then
      inc(count);
  Result := count;
end;

function GetContestName(Filename: string) : string;
var zfile : textfile;
    str, rstr : string;
    check : boolean;
begin
 str := ExtractFileName(FileName);

 if FileExists(FileName) = False then
   begin
     Result := str+' does not exist';
     exit;
   end;

 System.Assign(zfile, FIlename);
 System.reset(zfile);
 while not(eof(zfile)) do
   begin
     readln(zfile,rstr);
     if rstr[1]='#' then
       begin
         Delete(rstr, 1, 1);
         str := rstr;
         break;
       end;
   end;
 System.closefile(zfile);
 Result := str;
end;

function UsesCoeff(Filename: string) : boolean;
var zfile : textfile;
    str, rstr : string;
    check : boolean;
begin
 Result := False;
 str := ExtractFileName(FileName);
 System.Assign(zfile, FIlename);
 {$I-}
 System.reset(zfile);
 {$I+}
 check := (IOresult=0);
 if check then
   begin
     while not(eof(zfile)) do
       begin
         readln(zfile,rstr);
         rstr := Uppercase(rstr);
         if pos('COEFF',rstr) = 1 then
           begin
             if pos('ON', rstr) > 0 then
               Result := True;
           end;
       end;
     System.closefile(zfile);
   end;
end;

var B : TBand;

initialization
  Log := TQSOList.Create('default');
  Log.List.Capacity := MaxQSO;

{
  for B := b19 to HiBand do
    SubLog[B] := TQSOList.Create('sublog'); //0.23
}

  CurrentFileName := '';
  if GetLocale = 'Japan' then
    _Japanese := True
  else
    _Japanese := False;
finalization
  // Log.Destroy;

end.
