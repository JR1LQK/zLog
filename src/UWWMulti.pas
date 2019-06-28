unit UWWMulti;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicMulti, StdCtrls, JLLabel, ExtCtrls, zLogGlobal, Grids, Cologrid,
  USpotClass, UComm, UMultipliers;


type
  TWWMulti = class(TBasicMulti)
    Panel: TPanel;
    Panel1: TPanel;
    Button1: TButton;
    Button3: TButton;
    Edit1: TEdit;
    RotateLabel1: TRotateLabel;
    RotateLabel2: TRotateLabel;
    RotateLabel3: TRotateLabel;
    RotateLabel4: TRotateLabel;
    RotateLabel5: TRotateLabel;
    RotateLabel6: TRotateLabel;
    SortBy: TRadioGroup;
    StayOnTop: TCheckBox;
    Grid: TMgrid;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GoButtonClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure SortByClick(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);
    procedure GridSetting(ARow, Acol: Integer; var Fcolor: Integer;
      var Bold, Italic, underline: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure GridTopLeftChanged(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    MostRecentCty : TCountry;

    GridReverse : array[0..500] of integer; {pointer from grid row to countrylist index}
    //CountryList : TCountryList;
    //PrefixList : TPrefixList;
    Zone : array[b19..HiBand, 1..40] of boolean;
    //MyCountry : string;
    //MyZone : string;
    //MyContinent : string;
    procedure AddNewPrefixToFile(NewPX : string; CtyIndex : integer);
    procedure AddNewPrefix(PX : string; CtyIndex : integer); override;
    procedure SelectAndAddNewPrefix(Call : string); override;
    //function GetCountryIndex(aQSO : TQSO) : integer;
    //function GetPrefix(aQSO : TQSO) : TPrefix;
    procedure Reset; override;
    procedure AddNoUpdate(var aQSO : TQSO); override;
    procedure Add(var aQSO : TQSO); override; // only calls addnoupdate but no update
    procedure Update; override;
    function ValidMulti(aQSO : TQSO) : boolean; override;
    function GuessZone(aQSO : TQSO) : string; override;
    function GetInfo(aQSO : TQSO): string; override;
    procedure ProcessCluster(var Sp : TBaseSpot); override;
    procedure SortZone; virtual;
    procedure SortContinent; virtual;
    procedure SortDefault; virtual;
    procedure ShowContinent(CT: string);
    procedure CheckMulti(aQSO : TQSO); override;
    //function GetArea(str : string) : integer;
    //procedure RenewCluster; override;
    procedure RefreshGrid; virtual;
    procedure RefreshZone;
    procedure ProcessSpotData(var S : TBaseSpot); override;
  end;

var
  WWMulti: TWWMulti;
  //PrefixList : TPrefixList;
  //CountryList : TCountryList;

implementation

uses UWWZone, {UComm,} UOptions, Main, UNewPrefix;

{$R *.DFM}

procedure TWWMulti.AddNewPrefixToFile(NewPX : string; CtyIndex : integer);
var L : TStringList;
    C : TCountry;
    cname, s : string;
    i, j, p : integer;
label xxx;
begin
      L := TStringList.Create;
      L.LoadFromFile(_DATFileName);
      C := TCountry(CountryList.List[CtyIndex]);
      cname := TrimRight(C.CountryName);
      if _DATFileName = 'CTY.DAT' then
        begin
          for i := 0 to L.Count - 1 do
            begin
              s := L[i];
               if s[1] <> ' ' then
                 begin
                   p := pos(':', s);
                   if p > 0 then
                     s := TrimRight(copy(s, 1, p - 1))
                   else
                     s := '';
                   if cname = s then
                      begin
                        for j := i + 1 to L.Count - 1 do
                          begin
                            s := TrimRight(L[j]);
                            if pos(';', s) = length(s) then
                              begin
                                s := copy(s, 1, length(s) - 1);
                                s := s + ',' + NewPX + ';';
                                L[j] := s;
                                goto xxx;
                              end;
                          end;
                      end;
                  end;
            end;
        end
      else
        begin
          for i := 0 to L.Count - 1 do
            begin
              s := L[i];
              if s[1] <> ' ' then
                begin
                  s := copy(s, 1, 26);
                  s := TrimRight(s);
                  if cname = s then
                    begin
                      for j := i + 1 to L.Count - 1 do
                        begin
                          s := TrimRight(L[j]);
                          if pos(';', s) = length(s) then
                            begin
                              s := copy(s, 1, length(s) - 1);
                              s := s + ',' + NewPX + ';';
                              L[j] := s;
                              goto xxx;
                            end;
                        end;
                    end;
                end;
            end;
        end;
xxx:
      L.SaveToFile(_DATFileName);
      L.Free;
end;

procedure TWWMulti.AddNewPrefix(PX : string; CtyIndex : integer);
var  P : TPrefix;
begin
  P := TPrefix.Create;
  P.Prefix := PX;
  P.Index := CtyIndex;
  P.Length := Length(PX);
  PrefixList.AddListX(P);
  PrefixList.InitIndexX;
  AddNewPrefixToFile(P.Prefix, P.Index);
  Main.MyContest.Renew;
end;

procedure TWWMulti.SelectAndAddNewPrefix(Call : string);
var PX : TPrefix;
begin
  if _DATFileName = '' then
    exit;
  NewPrefix.Init(CountryList, Call);
  NewPrefix.ShowModal;
  if (NewPrefix.Prefix <> '') and (NewPrefix.CtyIndex >= 0) then
    begin
      AddNewPrefix(NewPrefix.Prefix, NewPrefix.CtyIndex);
    end;
end;

procedure TWWMulti.Add(var aQSO : TQSO);
begin
  AddNoUpdate(aQSO);
  if (aQSO.QSO.Reserve2 <> $AA) and (MostRecentCty <> nil) then
    Grid.TopRow := MostRecentCty.GridIndex;
  RefreshGrid;
  RefreshZone;

  AddSpot(aQSO);
end;

procedure TWWMulti.Update;
begin
  case SortBy.ItemIndex of
    0 : SortDefault;
    1 : SortZone;
  end;
  RefreshGrid;
  RefreshZone;
  RenewCluster;
  RenewBandScope;
end;

procedure TWWMulti.SortDefault;
var B : TBand;
    i, j : integer;
begin
  if CountryList.List.Count = 0 then exit;
  for i := 0 to CountryList.List.Count-1 do
    begin
      TCountry(CountryList.List[i]).GridIndex := i;
      GridReverse[i] := i;
    end;
end;

procedure TWWMulti.SortZone;
var B : TBand;
    i, j, x, _top: integer;
begin
  if CountryList.List.Count = 0 then exit;
  GridReverse[0] := 0;
  x := 1;
  for i := 1 to 40 do
    begin
      for j := 1 to CountryList.List.Count - 1 do
        begin
          if TCountry(CountryList.List[j]).Zone = i then
            begin
              TCountry(CountryList.List[j]).GridIndex := x;
              GridReverse[x] := j;
              inc(x);
            end;
        end;
    end;
end;

procedure TWWMulti.SortContinent;
var B : TBand;
    i, j, x, _top: integer;
    cont : array[0..5] of string[3];
begin
  cont[0] := 'AS';
  cont[1] := 'AF';
  cont[2] := 'EU';
  cont[3] := 'NA';
  cont[4] := 'SA';
  cont[5] := 'OC';
  if CountryList.List.Count = 0 then exit;
  GridReverse[0] := 0;
  x := 1;
  for i := 0 to 5 do
    begin
      for j := 1 to CountryList.List.Count - 1 do
        begin
          if TCountry(CountryList.List[j]).Continent = cont[i] then
            begin
              TCountry(CountryList.List[j]).GridIndex := x;
              GridReverse[x] := j;
              inc(x);
            end;
        end;
    end;
end;

procedure TWWMulti.ShowContinent(CT: string);
var B : TBand;
    i, j, x: integer;
    cont : array[0..5] of string[3];
begin
  cont[0] := 'AS';
  cont[1] := 'AF';
  cont[2] := 'EU';
  cont[3] := 'NA';
  cont[4] := 'SA';
  cont[5] := 'OC';

  if CountryList.List.Count = 0 then exit;
  GridReverse[0] := 0;

  for i := 1 to 500 do
    GridReverse[i] := -1;

  x := 1;

  for j := 1 to CountryList.List.Count - 1 do
    begin
      if TCountry(CountryList.List[j]).Continent = CT then
        begin
          TCountry(CountryList.List[j]).GridIndex := x;
          GridReverse[x] := j;
          inc(x);
        end
      else
        begin
          TCountry(CountryList.List[j]).GridIndex := 0;
          //GridReverse[x] := -1;
          //inc(x);
        end;
    end;

Grid.RowCount := x;

end;

procedure TWWMulti.Reset;
var B : TBand;
    i : integer;
begin
  WWZone.Reset;
  for B := b19 to HiBand do
    for i := 1 to MAXCQZONE do
      Zone[B, i] := false;
  if CountryList.List.Count = 0 then exit;
  for i := 0 to CountryList.List.Count-1 do
    begin
      for B := b19 to HiBand do
        TCountry(CountryList.List[i]).Worked[B] := false;
    end;
  case SortBy.ItemIndex of
    0 : SortDefault;
    1 : SortZone;
  end;
  Grid.RowCount := CountryList.List.Count;
  //RefreshGrid;
end;

procedure TWWMulti.RefreshGrid;
var i , k : integer;
begin
  for i := Grid.TopRow to Grid.TopRow + Grid.VisibleRowCount - 1 do
    begin
      if (i > Grid.RowCount - 1) then
        begin
          exit;
        end
      else
        begin
          k := GridReverse[i];
          if (k >= 0) and (k < CountryList.List.Count) then
            begin
              Grid.Cells[0, i] := TCountry(CountryList.List[k]).Summary
            end
          else
            Grid.Cells[0, i] := '';
        end;
    end;
  //Caption := IntToStr(Grid.TopRow);
end;


procedure TWWMulti.RefreshZone;
var i : integer;
    B : TBand;
begin
  WWZone.Reset;
  for B := b19 to b28 do
    if NotWARC(B) then
      for i := 1 to 40 do
        if Zone[B, i] then
          WWZone.Mark(B,i);
end;


procedure TWWMulti.FormCreate(Sender: TObject);
var i : integer;
    aQSO : TQSO;
    P : TPrefix;
    C : TCountry;
begin
  inherited;
  MostRecentCty := nil;
  MainForm.mnGridAddNewPX.Visible := True;
  CountryList := TCountryList.Create;
  PrefixList := TPrefixList.Create;
  {CountryList.LoadFromFile('CQWW.DAT');}
  if FileExists('CTY.DAT') then
    begin
      LoadCTY_DAT(testCQWW, CountryList, PrefixList);
      MainForm.WriteStatusLine('Loaded CTY.DAT', true);
    end
  else
    LoadCountryDataFromFile('CQWW.DAT', CountryList, PrefixList);


  if CountryList.List.Count = 0 then exit;

  Reset;

  AnalyzeMyCountry;

  WWZone.Reset;
end;

procedure TWWMulti.Button1Click(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TWWMulti.AddNoUpdate(var aQSO : TQSO);
var str : string;
    B : TBand;
    i, j : integer;
    C : TCountry;
    P : TPrefix;
    _cont : string[3];
begin
  aQSO.QSO.NewMulti1 := False;
  aQSO.QSO.NewMulti2 := False;
  str := aQSO.QSO.NrRcvd;
  aQSO.QSO.Multi1 := str;
  aQSO.QSO.Multi2 := '';

  if aQSO.QSO.Dupe then
    exit;

  B := aQSO.QSO.band;
  try
    i := StrToInt(str);
  except
    on EConvertError do
      i := 0;
  end;
  if i in [1..MAXCQZONE] then
    if Zone[B,i] = False then
      begin
        Zone[B,i] := True;
        aQSO.QSO.NewMulti1 := True;
        //WWZone.Mark(B,i);
      end;

  P := GetPrefix(aQSO);

  if P = nil then
    begin
      aQSO.QSO.Points := 0;
      aQSO.QSO.Multi1 := 'Unknown';
      aQSO.QSO.Memo := '** UNKNOWN CTY ** '+aQSO.QSO.Memo;
      exit;
    end;

  //i := P.Index;

  C := TCountry(CountryList.List[P.Index]);
  MostRecentCty := C;

  aQSO.QSO.Multi2 := C.Country;

  if C.Worked[B] = False then
    begin
      C.Worked[B] := True;
      aQSO.QSO.NewMulti2 := True;
      //Grid.Cells[0,C.GridIndex] := C.Summary;
    end;

  if P.OvrContinent = '' then
    _cont := C.Continent
  else
    _cont := P.OvrContinent;

  if MyCountry = C.Country then
    aQSO.QSO.points := 0
  else
    if MyContinent = _cont then
      begin
        if MyContinent = 'NA' then
          aQSO.QSO.points := 2
        else
          aQSO.QSO.points := 1;
      end
    else
      aQSO.QSO.points := 3;
end;

function TWWMulti.ValidMulti(aQSO : TQSO) : boolean;
var str : string;
    B : TBand;
    i : integer;
begin
  str := aQSO.QSO.NrRcvd;
  try
    i := StrToInt(str);
  except
    on EConvertError do
      i := 0;
  end;
  if i in [1..MAXCQZONE] then
    Result := True
  else
    Result := False;
end;

procedure TWWMulti.FormShow(Sender: TObject);
begin
  inherited;
  WWZone.Show;
end;

function TWWMulti.GuessZone(aQSO : TQSO) : string;
begin
  Result := GuessCQZone(aQSO);
end;

function TWWMulti.GetInfo(aQSO : TQSO) : string;
var temp, temp2 : string;
    B : TBand;
    i : integer;
    C : TCountry;
begin
  C := TCountry(CountryList.List[GetCountryIndex(aQSO)]);
  if C.CountryName = 'Unknown' then
    begin
      Result := 'Unknown CTY';
      exit;
    end;
  temp := '';
  temp := C.Country+' '+C.Continent+ ' ';

  temp2 := '';
  if C.Worked[aQSO.QSO.Band] = false then
    temp2 := 'CTY';

  i := 0;
  try
    i := StrToInt(aQSO.QSO.NrRcvd);
  except
    on EConvertError do
      i := 0;
  end;

  if i in [1..40] then
    begin
      if Zone[aQSO.QSO.Band, i] = False then
        temp2 := temp2 + ' ZONE';
    end
  else
    begin
    end;

  if temp2 <> '' then
    temp2 := 'NEW '+temp2;

  temp := temp + temp2 + ' ';

  temp := temp + 'needed on : ';
  for B := b19 to b28 do
    if NotWARC(B) then
      if C.Worked[B]=False then
        temp := temp + MHzString[B] + ' ';
  Result := temp;
end;


procedure TWWMulti.GoButtonClick(Sender: TObject);
var temp : string;
    i : integer;
begin
  temp := Edit1.Text;
  for i := 0 to CountryList.List.Count-1 do
    begin
      if pos(temp,TCountry(CountryList.List[i]).Country) = 1 then
        begin
          // ListBox.TopIndex := i;
          // ListBox.TopIndex := TCountry(CountryList.List[i]).GridIndex;
          Grid.TopRow := TCountry(CountryList.List[i]).GridIndex;
          break;
        end;
    end;
end;

procedure TWWMulti.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = Chr($0D) then
    begin
      GoButtonClick(Self);
      Key := #0;
    end;
end;

procedure TWWMulti.ProcessCluster(var Sp : TBaseSpot);
var Z, C : integer;
    temp : string;
    aQSO : TQSO;
begin
  aQSO := TQSO.Create;
  aQSO.QSO.Callsign := Sp.Call;
  aQSO.QSO.Band := Sp.Band;

  Sp.NewCty := False;
  Sp.NewZone := False;
  Sp.Worked := False;
  if Log.IsDupe(aQSO) > 0 then
    begin
      Sp.Worked := True;
      aQSO.Free;
      exit;
    end;

  temp := GuessZone(aQSO);
  if temp <> '' then
    Z := StrToInt(GuessZone(aQSO))
  else
    Z := 0;

  C := GetCountryIndex(aQSO);

  Sp.Zone := Z;
  if C > 0 then
    Sp.CtyIndex := C;

  temp := aQSO.QSO.CallSign;
  if (Z > 0) and (Zone[aQSO.QSO.band, Z] = False) then{and not singlebander on other band}
    begin
      temp := temp + '  new zone : ' + GuessZone(aQSO);
      Sp.NewZone := True;
    end;
  if (C > 0) and (TCountry(CountryList.List[C]).Worked[aQSO.QSO.Band] = false) then
    begin
      temp := temp + '  new country : ' + (TCountry(CountryList.List[C]).Country);
      Sp.NewCty := True;
    end;
  if Sp.NewMulti{Pos('new', temp) > 0} then
    begin
      temp := temp + ' at ' + MHzString[aQSO.QSO.band]+ 'MHz';
      CommForm.WriteStatusLine(temp);
      MainForm.WriteStatusLineRed(temp, true);
      //CommForm.Show;
      {if CommForm.Visible then
        CommForm.FormStyle := fsStayOnTop;}
    end;
  aQSO.Free;
end;

procedure TWWMulti.SortByClick(Sender: TObject);
begin
  inherited;
  case SortBy.ItemIndex of
    0 : SortDefault;
    1 : SortZone;
    2 : SortContinent;
  end;
  RefreshGrid;
end;

procedure TWWMulti.CheckMulti(aQSO : TQSO);
var str : string;
    i : integer;
    B : TBand;
begin
  str := aQSO.QSO.NrRcvd;
  try
    i := StrToInt(str);
  except
    on EConvertError do
      i := 0;
  end;

  if i in [1..MAXCQZONE] then
    begin
      str := 'Zone '+IntToStr(i)+ ' : ';
      if Zone[aQSO.QSO.Band, i] then
        str := str + 'Worked on this band. '
      else
        str := str + 'Needed on this band. ';
      str := str + 'Worked on : ';
      for B := b19 to b28 do
        if Zone[B, i] then
          str := str + MHzString[B]+' ';
      MainForm.WriteStatusLine(str, false);
    end
  else
    MainForm.WriteStatusLine('Invalid zone', false);
end;

procedure TWWMulti.StayOnTopClick(Sender: TObject);
begin
  if StayOnTop.Checked then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;



procedure TWWMulti.GridSetting(ARow, Acol: Integer; var Fcolor: Integer;
  var Bold, Italic, underline: Boolean);
var B : TBand;
begin
  inherited;
  B := Main.CurrentQSO.QSO.Band;
  if GridReverse[ARow] < 0 then
    exit;
  if TCountry(CountryList.List[GridReverse[ARow]]).Worked[B] then
    FColor := clRed
  else
    FColor := clBlack;
end;

procedure TWWMulti.FormDestroy(Sender: TObject);
begin
  inherited;
  {
  if CountryList <> nil then
    CountryList.Free;
  if PrefixList <> nil then
    PrefixList.Free;}
end;

procedure TWWMulti.ProcessSpotData(var S : TBaseSpot);
var ctyidx, zn : integer;
begin
  ProcessCluster(S);
{
  inherited;
  if S.Worked then
    exit;
  ctyidx := S.CtyIndex;
  zn := S.Zone;
  if ctyidx > 0 then
    if TCountry(CountryList.List[ctyidx]).Worked[S.Band] then
      S.NewCty := False
    else
      S.NewCty := True;
  if zn > 0 then
    if Zone[S.Band, zn] then
      S.NewZone := False
    else
      S.NewZone := True;
}
end;

procedure TWWMulti.GridTopLeftChanged(Sender: TObject);
begin
  //inherited;
  RefreshGrid;
end;

procedure TWWMulti.FormResize(Sender: TObject);
begin
  inherited;
  RefreshGrid;
end;

end.
