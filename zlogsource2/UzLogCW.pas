unit UzLogCW;

interface

uses zLogGlobal, BGK32LIB, UOptions, SysUtils;

var CtrlZCQLoop : boolean;
    QTHString : string[255];
    SpeedBefore : integer;

const tabstate_normal = 0;
      tabstate_tabpressedbutnotedited = 1;
      tabstate_tabpressedandedited = 2;

const EditedSinceTABPressed : integer = 0;
      FixedSpeed : boolean = False;

//const FIXWPM : integer = 20;

function LastCallsign : string;
function SetStr(S : string; aQSO : TQSO) : String;
function SetStrNoAbbrev(S : string; aQSO : TQSO) : String; {for QSO.NrSent}
procedure zLogSendStr(S : shortstring);
procedure CtrlZBreak;
procedure IncCWSpeed;
procedure DecCWSpeed;
procedure ToggleFixedSpeed;

implementation

uses Main;

function LastCallsign : string;
var txnr, i : integer;
begin
  Result := '';
  txnr := Options.Settings._txnr;
  for i := Log.TotalQSO downto 1 do
    begin
      if TQSO(Log.List[i]).QSO.TX = txnr then
        Result := TQSO(Log.List[i]).QSO.Callsign;
      exit;
    end;
end;

procedure IncCWSpeed;
var i : integer;
begin
  i := Options.Settings.CW._speed;
  if i < 60 then
    Options.SetSpeed(i+1);
  MainForm.SpeedBar.Position := i+1;
  MainForm.SpeedLabel.Caption := IntToStr(i+1)+' wpm';
end;

procedure DecCWSpeed;
var i : integer;
begin
  i := Options.Settings.CW._speed;
  if i > 2 then
    Options.SetSpeed(i-1);
  MainForm.SpeedBar.Position := i-1;
  MainForm.SpeedLabel.Caption := IntToStr(i-1)+' wpm';
end;

procedure ToggleFixedSpeed;
var i : integer;
begin
  FixedSpeed := not(FixedSpeed);
  if FixedSpeed then
    begin
      i := Options.Settings.CW._fixwpm;
      SpeedBefore := Options.Settings.CW._speed;
    end
  else
    begin
      i := SpeedBefore;
    end;
  if (i > 0) and (i < 61) then
    Options.SetSpeed(i);
  MainForm.SpeedBar.Position := i;
  MainForm.SpeedLabel.Caption := IntToStr(i)+' wpm';
end;

function Abbreviate(S : shortstring) : shortstring;
var ss : shortstring;
    i : integer;
begin
  SS := S;
  for i := 1 to length(SS) do
    case SS[i] of
      '0' : SS[i] := Options.Settings.CW._zero;
      '1' : SS[i] := Options.Settings.CW._one;
      '9' : SS[i] := Options.Settings.CW._nine;
    end;
  Result := SS;
end;

function SetStr(S : string; aQSO : TQSO) : string;
var temp : shortstring;
    i : integer;
begin
  temp := UpperCase(S);
  while Pos('[AR]',temp) > 0 do
    begin
      i := Pos('[AR]',temp);
      Delete(temp, i, 4);
      Insert('a', temp, i);
    end;
  while Pos('[SK]',temp) > 0 do
    begin
      i := Pos('[SK]',temp);
      Delete(temp, i, 4);
      Insert('s', temp, i);
    end;
  while Pos('[VA]',temp) > 0 do
    begin
      i := Pos('[VA]',temp);
      Delete(temp, i, 4);
      Insert('s', temp, i);
    end;
  while Pos('[KN]',temp) > 0 do
    begin
      i := Pos('[KN]',temp);
      Delete(temp, i, 4);
      Insert('k', temp, i);
    end;
  while Pos('[BK]',temp) > 0 do
    begin
      i := Pos('[BK]',temp);
      Delete(temp, i, 4);
      Insert('~', temp, i);
    end;
  while Pos('$B',temp) > 0 do
    begin
      i := Pos('$B',temp);
      Delete(temp, i, 2);
      Insert(Main.CurrentQSO.QSO.Callsign, temp, i);
    end;
  while Pos('$X',temp) > 0 do
    begin
      i := Pos('$X',temp);
      Delete(temp, i, 2);
      Insert(Options.Settings._sentstr, temp, i);
    end;
  while Pos('$R',temp) > 0 do
    begin
      i := Pos('$R',temp);
      Delete(temp, i, 2);
      Insert(Abbreviate(aQSO.RSTSentStr), temp, i);
    end;
  while Pos('$F',temp) > 0 do
    begin
      i := Pos('$F',temp);
      Delete(temp, i, 2);
      Insert(Abbreviate(aQSO.QSO.NrRcvd), temp, i);
    end;
  while Pos('$Z',temp) > 0 do
    begin
      i := Pos('$Z',temp);
      Delete(temp, i, 2);
      //Insert(Abbreviate(QTHString), temp, i);
      Insert(Abbreviate(Options.Settings._cqzone), temp, i);
    end;
  while Pos('$I',temp) > 0 do
    begin
      i := Pos('$I',temp);
      Delete(temp, i, 2);
      //Insert(Abbreviate(QTHString), temp, i);
      Insert(Abbreviate(Options.Settings._iaruzone), temp, i);
    end;
  while Pos('$Q',temp) > 0 do
    begin
      i := Pos('$Q',temp);
      Delete(temp, i, 2);
      Insert(Abbreviate(MyContest.QTHString), temp, i);
    end;
  while Pos('$V',temp) > 0 do
    begin
      i := Pos('$V',temp);
      Delete(temp, i, 2);
      Insert(Abbreviate(Options.Settings._prov), temp, i);
    end;
  while Pos('$O',temp) > 0 do
    begin
      i := Pos('$O',temp);
      Delete(temp, i, 2);
      Insert(aQSO.QSO.Operator, temp, i);
    end;
  while Pos('$S',temp) > 0 do
    begin
      i := Pos('$S',temp);
      Delete(temp, i, 2);
      Insert(Abbreviate(aQSO.SerialStr), temp, i);
    end;
  while Pos('$P',temp) > 0 do
    begin
      i := Pos('$P',temp);
      Delete(temp, i, 2);
      Insert(aQSO.NewPowerStr, temp, i);
    end;

  while Pos('$A',temp) > 0 do   // all asian age
    begin
      i := Pos('$A',temp);
      Delete(temp, i, 2);
      Insert(Abbreviate(UpperCase(Options.GetAge(aQSO))), temp, i);
    end;

  while Pos('$N',temp) > 0 do
    begin
      i := Pos('$N',temp);
      Delete(temp, i, 2);
      Insert(Abbreviate(aQSO.PowerStr), temp, i);
    end;

  while Pos('$L',temp) > 0 do
    begin
      i := Pos('$L',temp);
      Delete(temp, i, 2);
      Insert(LastCallSign, temp, i);
    end;

  while Pos('$C',temp) > 0 do
    begin
      i := Pos('$C',temp);
      Delete(temp, i, 2);
      if aQSO.QSO.mode = mRTTY then
        Insert(aQSO.QSO.Callsign, temp, i)
      else
        Insert(':***************', temp, i);
    end;

  while Pos('$E',temp) > 0 do
    begin
      i := Pos('$E',temp);
      Delete(temp, i, 2);
      if aQSO.QSO.Callsign = '' then
        insert(LastCallsign, temp, i);
      if EditedSinceTABPressed = tabstate_tabpressedandedited then
        Insert(aQSO.QSO.Callsign, temp, i);
{
      if EditedSinceTABPressed = tabstate_tabpressedandedited then
        Insert(':************', temp, i);
}
    end;
  while Pos('$M',temp) > 0 do
    begin
      i := Pos('$M',temp);
      Delete(temp, i, 2);
      Insert(UpperCase(Options.MyCall), temp, i);
    end;
  Result := temp;
end;

function SetStrNoAbbrev(S : string; aQSO : TQSO) : string;
var temp : shortstring;
    i : integer;
begin
  temp := UpperCase(S);
  if pos('$X', Options.Settings._sentstr) = 0 then
    while Pos('$X',temp) > 0 do
      begin
        i := Pos('$X',temp);
        Delete(temp, i, 2);
        Insert(Options.Settings._sentstr, temp, i);
      end;
  while Pos('$Z',temp) > 0 do
    begin
      i := Pos('$Z',temp);
      Delete(temp, i, 2);
      Insert(Options.Settings._cqzone, temp, i);
      //Insert(QTHString, temp, i);
    end;
  while Pos('$I',temp) > 0 do
    begin
      i := Pos('$I',temp);
      Delete(temp, i, 2);
      Insert(Options.Settings._iaruzone, temp, i);
      //Insert(QTHString, temp, i);
    end;
  while Pos('$R',temp) > 0 do
    begin
      i := Pos('$R',temp);
      Delete(temp, i, 2);
      Insert(aQSO.RSTSentStr, temp, i);
    end;
  while Pos('$F',temp) > 0 do
    begin
      i := Pos('$F',temp);
      Delete(temp, i, 2);
      Insert(aQSO.QSO.NrRcvd, temp, i);
    end;
  while Pos('$O',temp) > 0 do
    begin
      i := Pos('$O',temp);
      Delete(temp, i, 2);
      Insert(aQSO.QSO.Operator, temp, i);
    end;

  while Pos('$A',temp) > 0 do   // all asian age
    begin
      i := Pos('$A',temp);
      Delete(temp, i, 2);
      Insert(UpperCase(Options.GetAge(aQSO)), temp, i);
    end;

  while Pos('$P',temp) > 0 do
    begin
      i := Pos('$P',temp);
      Delete(temp, i, 2);
      Insert(aQSO.NewPowerStr, temp, i);
    end;
  while Pos('$N',temp) > 0 do
    begin
      i := Pos('$N',temp);
      Delete(temp, i, 2);
      Insert(aQSO.PowerStr, temp, i);
    end;
  while Pos('$Q',temp) > 0 do
    begin
      i := Pos('$Q',temp);
      Delete(temp, i, 2);
      Insert(MyContest.QTHString, temp, i);
    end;
  while Pos('$V',temp) > 0 do
    begin
      i := Pos('$V',temp);
      Delete(temp, i, 2);
      Insert(Options.Settings._prov, temp, i);
    end;
  while Pos('$S',temp) > 0 do
    begin
      i := Pos('$S',temp);
      Delete(temp, i, 2);
      Insert(aQSO.SerialStr, temp, i);
    end;
  while Pos('$C',temp) > 0 do
    begin
      i := Pos('$C',temp);
      Delete(temp, i, 2);
      Insert(aQSO.QSO.Callsign, temp, i);
    end;
  while Pos('$M',temp) > 0 do
    begin
      i := Pos('$M',temp);
      Delete(temp, i, 2);
      Insert(UpperCase(Options.MyCall), temp, i);
    end;
  Result := (temp);
end;

procedure zLogSendStr(S : shortstring);
begin
  PauseCW;
  if Options.FIFO then
    SendStrFIFO(S)
  else
    SendStr(S);
  BGK32LIB.SetCallSign(ShortString(Main.CurrentQSO.QSO.Callsign));
  ResumeCW;
end;

procedure CtrlZBreak;
begin
  CtrlZCQLoop := False;
  BGK32LIB.ClrBuffer;
end;

initialization
  CtrlZCQLoop := False;
  QTHString := '';
end.
