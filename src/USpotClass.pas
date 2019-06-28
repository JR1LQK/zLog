unit USpotClass;

interface

uses SysUtils, Windows, Classes, zLogGlobal;

type
  TBaseSpot = class
    Time : TDateTime; // moved from TBSdata 2.6e
    Call : string;
    Number : string;
    FreqHz : LongInt;
    //ReportedBy : string;
    //TimeStr : string;
    //Comment : string;
    CtyIndex : integer;
    Zone : integer;
    NewCty : boolean;
    NewZone : boolean;
    Worked : boolean;
    Band : TBand;
    Mode : TMode;
    ClusterData : boolean; // true if data from PacketCluster
    constructor Create; virtual;
    //Function Analyze(S : string) : boolean; // true if successful
    Function FreqKHzStr : string;
    //Function Summary : string;
    Function _GetBand : TBand;
    Function NewMulti : boolean; // newcty or newzone
    Function InText : string; virtual; abstract;
    procedure FromText(S : string); virtual; abstract;
    //Function DrawRed : boolean;
  end;

  TSpot = class(TBaseSpot)
    ReportedBy : string;
    TimeStr : string;
    Comment : string;
    constructor Create; override;
    Function Analyze(S : string) : boolean; // true if successful
    Function ClusterSummary : string;
  end;

  TBSData = class(TBaseSpot)
    //Time : TDateTime; 2.6e
    LabelRect : TRect;
    Bold : boolean;
    constructor Create; override;
    function LabelStr : string;
    function InText : string; override;
    procedure FromText(S : string); override;
  end;

var //BSList : TList;
    BSList2 : TList;

implementation

constructor TBaseSpot.Create;
begin
  Time := Now;
  Call := '';
  Number := '';
  FreqHz := 0;
  NewCty := false;
  NewZone := false;
  CtyIndex := 0;
  Zone := 0;
  Worked := False;
  Band := b19;
  Mode := mCW;
  ClusterData := False;
end;

constructor TSpot.Create;
begin
  inherited;
  ReportedBy := '';
  TimeStr := '0000Z';
  Comment := '';
end;

constructor TBSData.Create;
begin
  //Time := Now;
  inherited;
  LabelRect.Top := 0;
  LabelRect.Right := 0;
  LabelRect.Left := 0;
  LabelRect.Bottom := 0;
end;

function TBSData.LabelStr : string;
begin
  Result := FreqkHzStr + ' ' + Call;
  if Number <> '' then
    Result := Result + ' ['+Number+']';
end;


function TSpot.Analyze(S : string) : boolean;
var temp, temp2 : string;
    i : integer;
begin
  Result := False;
  if length(S) < 5 then
    exit;
  temp := TrimRight(TrimLeft(S));

  i := pos('DX de', temp);
  if i > 1 then
    Delete(temp, 1, i);

  if pos('DX de', temp) = 1 then
    begin
      i := pos(':', temp);
      if i > 0 then
        begin
          temp2 := copy(temp, 7, i-7);
          ReportedBy := temp2;
        end
      else
        exit;

      Delete(temp, 1, i);
      temp := TrimLeft(temp);

      i := pos(' ', temp);
      if i > 0 then
        temp2 := copy(temp, 1, i - 1)
      else
        exit;

      try
        FreqHz := Round(StrToFloat(temp2)*1000);
      except
        on EConvertError do
          exit;
      end;
      Band := _getband;

      Delete(temp, 1, i);
      temp := TrimLeft(temp);

      i := pos(' ', temp);
      if i > 0 then
        Call := copy(temp, 1, i - 1)
      else
        exit;

      Delete(temp, 1, i);

      for i := length(temp) downto 1 do
        if temp[i] = ' ' then
          break;

      TimeStr := copy(temp, i + 1, 5);

      Delete(temp, i, 255);
      Comment := temp;
      Result := True;
    end
  else     // check for SH/DX responses
    begin

      i := length(temp);
      if i = 0 then
        exit;
      if temp[i] = '>' then
        begin
          i := pos(' <', temp);
          if i > 0 then
            begin
              ReportedBy := copy(temp, i+2, 255);
              ReportedBy := copy(ReportedBy, 1, length(ReportedBy)-1);
            end
          else
            exit;
          Delete(temp, i, 255);
        end
      else
        exit;

      i := pos(' ', temp);
      if i > 0 then
        temp2 := copy(temp, 1, i - 1)
      else
        exit;
      try
        FreqHz := Round(StrToFloat(temp2)*1000);
      except
        on EConvertError do
          exit;
      end;
      Band := _getband;

      Delete(temp, 1, i);
      temp := TrimLeft(temp);
      i := pos(' ', temp);
      if i > 0 then
        Call := copy(temp, 1, i - 1)
      else
        exit;

      Delete(temp, 1, i);
      temp := TrimLeft(temp);
      i := pos(' ', temp);
      if i > 0 then
        Delete(temp, 1, i)
      else
        exit;

      temp := TrimLeft(temp);
      if pos('Z', temp) = 5 then
        begin
          TimeStr := copy(temp, 1, 5);
          Delete(temp, 1, 6);
          Comment := temp;
        end
      else
        exit;

      Result := True;
    end;
end;

Function TBaseSpot.FreqKHzStr : string;
begin
  Result := kHzStr(FreqHz);
end;

Function TSpot.ClusterSummary : string;
begin
  Result := FillLeft(FreqKHzStr, 8) +  ' ' +
            FillRight(Self.Call, 11) + ' ' + Self.TimeStr + ' ' +
            FillRight(Self.Comment, 30) + '<'+ Self.ReportedBy + '>';
end;

Function TBaseSpot._GetBand : TBand;
begin
  Result := b19;
  case FreqHz div 1000 of
    1800..1999 : Result := b19;
    3000..3999 : Result := b35;
    7000..7999 : Result := b7;
    10000..10999 : Result := b10;
    14000..14999 : Result := b14;
    18000..18999 : Result := b18;
    21000..21999 : Result := b21;
    24000..24999 : Result := b24;
    28000..28999 : Result := b28;
    50000..59999 : Result := b50;
    140000..149999 : Result := b144;
    420000..499999 : Result := b430;
    1200000..1299999 : Result := b1200;
    2400000..2499999 : Result := b2400;
    5600000..5799999 : Result := b5600;
  else
    begin
    end;
  end;
end;

Function TBaseSpot.NewMulti : boolean;
begin
  Result := NewCty or NewZone;
end;

function TBSData.InText : string;
(*  Call : string;
    FreqHz : LongInt;
    CtyIndex : integer;
    Zone : integer;
    NewCty : boolean;
    NewZone : boolean;
    Worked : boolean;
    Band : TBand;
    Mode : TMode;
    Time : TDateTime;
    LabelRect : TRect;  *)
var S : string;
const xx = '%';
begin
  S := Call +xx+ IntToStr(FreqHz) +xx+ IntToStr(Ord(Band)) +xx+ IntToStr(Ord(Mode)) +xx+ FloatToStr(Time);
  Result := S;
end;

procedure TBSData.FromText(S : string);
var str, wstr : string;
    p : integer;
begin
  str := S;

  p := pos('%', str);
  wstr := copy(str, 1, p-1);
  Call := wstr;
  Delete(str, 1, p);

  p := pos('%', str);
  wstr := copy(str, 1, p-1);
  try
    FreqHz := StrToInt(wstr);
  except
    FreqHz := 0;
  end;
  Delete(str, 1, p);

  p := pos('%', str);
  wstr := copy(str, 1, p-1);
  try
    Band := TBand(StrToInt(wstr));
  except
    Band := b19;
  end;
  Delete(str, 1, p);

  p := pos('%', str);
  wstr := copy(str, 1, p-1);
  try
    Mode := TMode(StrToInt(wstr));
  except
    Mode := mCW;
  end;

  wstr := str;
  try
    Time := StrToFloat(wstr);
  except
  end;
end;

initialization
  //BSList := TList.Create;
  BSList2 := TList.Create;
end.
