unit UIARUMulti;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UWWMulti, UMultipliers, StdCtrls, ExtCtrls, JLLabel, zLogGlobal, Grids, Cologrid;

type

  TIARUZone = class
    Multi : string[30];
    Worked : array[b19..b28] of boolean;
    function Summary : string;
    constructor Create;
  end;

  TIARUZoneList = class
    List : TList;
    constructor Create;
    procedure Add(M : TIARUZone);
  end;

  TIARUMulti = class(TWWMulti)
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GoButtonClick(Sender: TObject);
    procedure GridSetting(ARow, Acol: Integer; var Fcolor: Integer;
      var Bold, Italic, underline: Boolean);
    procedure GridTopLeftChanged(Sender: TObject);
  private
    ZoneList : TIARUZoneList;
    { Private declarations }
  public
    procedure Reset; override;
    procedure AddNoUpdate(var aQSO : TQSO); override;
    procedure Add(var aQSO : TQSO); override;
    function ValidMulti(aQSO : TQSO) : boolean; override;
    function GuessZone(aQSO : TQSO) : string; override;
    procedure Update; override;
    procedure RefreshGrid; override;
    function GetInfo(aQSO : TQSO) : string; override;
    procedure CheckMulti(aQSO : TQSO); override;
    { Public declarations }
  end;


var
  IARUMulti: TIARUMulti;

implementation

uses Main, UOptions;

{$R *.DFM}

constructor TIARUZone.Create;
var B : TBand;
begin
  for B := b19 to b28 do
    Worked[B] := False;
  Multi := '';
end;

function TIARUZone.Summary : string;
var i : integer;
    str : string;
    B : TBand;
begin
  str := '';

  if (Multi[1] in ['0'..'9']) then
    try
      i := StrToInt(Multi);
    except
      on EConvertError do
        i := 0;
    end;

  if (i in [1..90]) then
    str := 'ITU Zone '+FillLeft(Multi,2)
  else
    if (Multi = 'AC') then
      str := 'Admin. Council AC'
    else
      if (Multi = 'R1') or (Multi = 'R2') or (Multi = 'R3') then
        str := 'Reg. Exec. Committee '+Multi
      else
        str := 'IARU HQ Station '+Multi;

  str := FillRight(str, 24);

  for B := b19 to b28 do
    if NotWARC(B) then
      if Worked[B] then
        str := str + '* '
      else
        str := str + '. ';

  Result := str;
end;

constructor TIARUZoneList.Create;
var M : TIARUZone;
    i : integer;
begin
  List := TList.Create;
  for i := 1 to 90 do
    begin
      M := TIARUZone.Create;
      M.Multi := IntToStr(i);
      List.Add(M);
    end;
  M := TIARUZone.Create;
  M.Multi := 'AC';
  List.Add(M);
  M := TIARUZone.Create;
  M.Multi := 'R1';
  List.Add(M);
  M := TIARUZone.Create;
  M.Multi := 'R2';
  List.Add(M);
  M := TIARUZone.Create;
  M.Multi := 'R3';
  List.Add(M);
end;

procedure TIARUZoneList.Add(M : TIARUZone);
var i, j : integer;
begin
//  List.Add(M);
  j := List.Count;
  if j > 94 then
    begin
      for i := 94 to j-1 do
        if StrMore(M.Multi, TIARUZone(List[i]).Multi) = False then
          begin
            List.Insert(i,M);
            exit;
          end;
      List.Add(M);
      exit;
    end
  else
    List.Add(M);
end;

procedure TIARUMulti.CheckMulti(aQSO : TQSO);
var str, str2 : string;
    i, j, z : integer;
    B : TBand;
    boo : boolean;
begin
  str := aQSO.QSO.NrRcvd;
  B := aQSO.QSO.band;
  boo := false;
  for j := 0 to ZoneList.List.Count - 1 do
    begin
      if TIARUZone(ZoneList.List[j]).Multi = str then
        begin
          boo := true;
          break;
        end;
    end;
  if boo = False then
    begin
      MainForm.WriteStatusLine('HQ '+str+' is not worked on any band', false);
      exit;
    end;


  try
    z := StrToInt(str);
  except
    on EConvertError do
      z := 0;
  end;

  if z = 0 then
    begin
      if str = 'AC' then
        str2 := 'Admin. Council '
      else
        if (str = 'R1') or (str = 'R2') or (str = 'R3') then
          str2 := 'Reg. Exec. Committee '
        else
          str2 := 'HQ ';
    end
  else
    str2 := 'Zone ';
  str2 := str2 + str+ ' : ';
  if TIARUZone(ZoneList.List[j]).Worked[aQSO.QSO.Band] then
    str2 := str2 + 'Worked on this band. '
  else
    str2 := str2 + 'Needed on this band. ';
  str2 := str2 + 'Worked on : ';
  for B := b19 to b28 do
    if TIARUZone(ZoneList.List[j]).Worked[B] then
      str2 := str2 + MHzString[B]+' ';

  MainForm.WriteStatusLine(str2, false);
end;

function TIARUMulti.GuessZone(aQSO : TQSO) : string;
var i, k : integer;
    C : TCountry;
    P : TPrefix;
    str : string;
begin
  P := GetPrefix(aQSO);
  if P = nil then
    begin
      Result := '';
      exit;
    end;
  C := TCountry(CountryList.List[P.Index]);
  str := aQSO.QSO.CallSign;
  i := C.Zone;

  if (C.Country = 'W') or (C.Country = 'K') then
    begin
      k := GetArea(str);
      case k of
        1..4    : i := 8;
        5,8,9,0 : i := 7;
        6,7     : i := 6;
      end;
    end;

  if C.Country = 'VE' then
    begin
      k := GetArea(str);
      case k of
        1,2     : i := 8;
        3..6    : i := 3;
        7       : i := 2;
        8       : i := 2;
        9       : i := 9;
        0       : i := 4;
      end;
    end;

  if C.Country = 'VK' then
    begin
      k := GetArea(str);
      case k of
        1..5,7  : i := 55;
        6,8     : i := 58;
        9,0     : i := 30;{Should not happen}
      end;
    end;

{
  if C.Country = 'BY' then
    begin
      k := GetArea(str);
      case k of
        1..8    : i := 33;
        9,0     : i := 33;
      end;
    end;
}

  if P.OvrZone > 0 then
    i := P.OvrZone;

  if i = 0 then
    Result := ''
  else
    Result := IntToStr(i);
end;


function TIARUMulti.ValidMulti(aQSO : TQSO) : boolean;
begin
  if aQSO.QSO.NrRcvd <> '' then
    Result := True
  else
    Result := False;
end;

procedure TIARUMulti.Reset;
var i : integer;
    B : TBand;
begin
  for i := 0 to ZoneList.List.Count-1 do
    for B := b19 to b28 do
      TIARUZone(ZoneList.List[i]).Worked[B] := False;
  Grid.RowCount := ZoneList.List.Count;
  for i := 0 to ZoneList.List.Count-1 do
    Grid.Cells[0, i] := (TIARUZone(ZoneList.List[i]).Summary);
    //ListBox.Items[i] := (TIARUZone(ZoneList.List[i]).Summary);
end;

procedure TIARUMulti.FormCreate(Sender: TObject);
var i : integer;
    aQSO : TQSO;
    P : TPrefix;
    C : TCountry;
begin
  //inherited;
  CountryList := TCountryList.Create;
  PrefixList := TPrefixList.Create;
  if FileExists('CTY.DAT') then
    begin
      LoadCTY_DAT(testIARU, CountryList, PrefixList);
      MainForm.WriteStatusLine('Loaded CTY.DAT', true);
    end
  else
    LoadCountryDataFromFile('IARU.DAT', CountryList, PrefixList);

 {if CountryList.List.Count = 0 then exit;
  for i := 0 to CountryList.List.Count-1 do
    begin
      ListBox.Items.Add(TCountry(CountryList.List[i]).Summary);
    end;}
  ZoneList := TIARUZoneList.Create;
  {for i := 0 to ZoneList.List.Count-1 do
    ListBox.Items.Add(TIARUZone(ZoneList.List[i]).Summary);}

  Reset;

  MyContinent := 'AS';
  MyCountry := 'JA';
  MyZone := '25';

  if (Options.Settings._mycall <> '') and (Options.Settings._mycall <> 'Your call sign') then
    begin
      aQSO := TQSO.Create;
      aQSO.QSO.callsign := Uppercase(Options.Settings._mycall);

      P := GetPrefix(aQSO);
      //i := GetCountryIndex(aQSO);
      if P = nil then
        i := 0
      else
        i := P.Index;
      if i > 0 then
        begin
          MyCountry := TCountry(CountryList.List[i]).Country;
          //MyZone := IntToStr(TCountry(CountryList.List[i]).Zone);

          if Options.Settings._iaruzone = '' then
            Options.Settings._iaruzone := GuessZone(aQSO);
          MyZone := Options.Settings._iaruzone;

          //MyContinent := TCountry(CountryList.List[i]).Continent;
          if P.OvrContinent = '' then
            MyContinent := TCountry(CountryList.List[i]).Continent
          else
            MyContinent := P.OvrContinent;
        end;
      aQSO.Free;
    end;

  //WWZone.Reset;
end;

function TIARUMulti.GetInfo(aQSO : TQSO) : string;
var i, k : integer;
    C : TCountry;
    P : TPrefix;
    str, z : string;
    B : TBand;
begin
  P := GetPrefix(aQSO);
  if P = nil then
    begin
      Result := 'Unknown prefix';
      exit;
    end;
  C := TCountry(CountryList.List[P.Index]);
  str := 'Continent: ';
  if P.OvrContinent <> '' then
    str := str + P.OvrContinent
  else
    str := str + C.Continent;
  z := GuessZone(aQSO);
  str := str + '   ITU Zone/Multi: '+z+ '  Worked on: ';
  for i := 0 to ZoneList.List.Count - 1 do
    begin
      if TIARUZone(ZoneList.List[i]).Multi = z then
        begin
          for B := b19 to b28 do
            if NotWARC(B) then
              if TIARUZone(ZoneList.List[i]).Worked[B] then
                str := str + MHzString[B] + ' '
              else
                for k := 1 to length(MHzString[B]) do
                  str := str + ' ';
        end;
    end;
  Result := str;
end;

procedure TIARUMulti.Update;
var j, k : integer;
begin
  Grid.RowCount := ZoneList.List.Count;
  for j := 0 to ZoneList.List.Count - 1 do
    Grid.Cells[0, j] {ListBox.Items[j]} := TIARUZone(ZoneList.List[j]).Summary;
  RenewCluster;
  RenewBandScope;
end;

procedure TIARUMulti.AddNoUpdate(var aQSO : TQSO);
var str : string;
    B : TBand;
    i, j : integer;
    C : TCountry;
    P : TPrefix;
    _cont : string[3];
    boo, HQ : boolean;
    M : TIARUZone;
begin
  aQSO.QSO.NewMulti1 := False;
  str := aQSO.QSO.NrRcvd;
  aQSO.QSO.Multi1 := str;

  if aQSO.QSO.Dupe then
    exit;

  B := aQSO.QSO.band;
  try
    i := StrToInt(str);
  except
    on EConvertError do
      i := 0;
  end;

  HQ := True;
  if i in [1..90] then
    begin
      str := IntToStr(i);
      HQ := false;
    end;


  boo := false;
  for j := 0 to ZoneList.List.Count - 1 do
    begin
      if TIARUZone(ZoneList.List[j]).Multi = str then
        begin
          boo := true;
          if TIARUZone(ZoneList.List[j]).Worked[aQSO.QSO.Band] = False then
            begin
              TIARUZone(ZoneList.List[j]).Worked[aQSO.QSO.Band] := True;
              aQSO.QSO.NewMulti1 := True;
              break;
            end;
        end;
    end;

  if boo = false then
    begin
      M := TIARUZone.Create;
      M.Multi := str;
      M.Worked[aQSO.QSO.Band] := True;
      aQSO.QSO.NewMulti1 := True;
      ZoneList.Add(M);
      Update;
      //Grid.Cells[0,ZoneList.List.Count-1] := M.Summary;
    end;

  P := GetPrefix(aQSO);
  if P = nil then  // /MM results in p = nil !!
    i := 0
  else
    i := P.Index;

  C := TCountry(CountryList.List[i]);

  if P = nil then
    _cont := C.Continent
  else
    if P.OvrContinent = '' then
      _cont := C.Continent
    else
      _cont := P.OvrContinent;

  if (MyZone = str) or (HQ = True) then
    aQSO.QSO.Points := 1
  else
    if MyContinent = _cont then
      aQSO.QSO.Points := 3
    else
      aQSO.QSO.points := 5;

end;



procedure TIARUMulti.FormShow(Sender: TObject);
begin
  // inherited;
end;

procedure TIARUMulti.GoButtonClick(Sender: TObject);
var i : integer;
    temp : string;
begin
  temp := Edit1.Text;
  for i := 0 to ZoneList.List.Count-1 do
    begin
      if pos(temp,TIARUZone(ZoneList.List[i]).Multi) = 1 then
        begin
          //ListBox.TopIndex := i;
          Grid.TopRow := i;
          break;
        end;
    end;
end;

procedure TIARUMulti.GridSetting(ARow, Acol: Integer; var Fcolor: Integer;
  var Bold, Italic, underline: Boolean);
var B : TBand;
begin
  //inherited;
  B := Main.CurrentQSO.QSO.Band;
  if TIARUZone(ZoneList.List[ARow]).Worked[B] then
    FColor := clRed
  else
    FColor := clBlack;
end;

procedure TIARUMulti.RefreshGrid;
begin
  //inherit
  Update;
end;

procedure TIARUMulti.GridTopLeftChanged(Sender: TObject);
begin
  //inherited;
  //Update;
end;

procedure TIARUMulti.Add(var aQSO : TQSO);
begin
  AddNoUpdate(aQSO);
  {
  if (aQSO.QSO.Reserve2 <> $AA) and (MostRecentCty <> nil) then
    Grid.TopRow := MostRecentCty.GridIndex;
  }
  RefreshGrid;
  //RefreshZone;
  AddSpot(aQSO);
end;


end.
