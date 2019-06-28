unit UJIDXMulti;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UWWMulti, UMultipliers, StdCtrls, JLLabel, ExtCtrls, zLogGlobal, Grids, Cologrid;

type
  TJIDXMulti = class(TWWMulti)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddNoUpdate(var aQSO : TQSO); override;
  end;

var
  JIDXMulti: TJIDXMulti;

implementation

uses UWWZone, UOptions, Main;

{$R *.DFM}

procedure TJIDXMulti.FormCreate(Sender: TObject);
var i : integer;
    aQSO : TQSO;
begin
  {inherited; }
  CountryList := TCountryList.Create;
  PrefixList := TPrefixList.Create;

  if FileExists('CTY.DAT') then
    begin
      LoadCTY_DAT(testDXCCWWZone, CountryList, PrefixList);
      MainForm.WriteStatusLine('Loaded CTY.DAT', true);
    end
  else
    LoadCountryDataFromFile('DXCC.DAT', CountryList, PrefixList);

//  LoadCountryDataFromFile('DXCC.DAT');
  if CountryList.List.Count = 0 then exit;

  {for i := 0 to CountryList.List.Count-1 do
    begin
      ListBox.Items.Add(TCountry(CountryList.List[i]).Summary);
    end; }

  Reset;
  MyContinent := 'AS';
  MyCountry := 'JA';

  if (Options.Settings._mycall <> '') and (Options.Settings._mycall <> 'Your callsign') then
    begin
      aQSO := TQSO.Create;
      aQSO.QSO.callsign := UpperCase(Options.Settings._mycall);
      i := GetCountryIndex(aQSO);
      if i > 0 then
        begin
          MyCountry := TCountry(CountryList.List[i]).Country;
          MyContinent := TCountry(CountryList.List[i]).Continent;
        end;
      aQSO.Free;
    end;

  WWZone.Reset;
end;

procedure TJIDXMulti.AddNoUpdate(var aQSO : TQSO);
var str : string;
    B : TBand;
    i, j : integer;
    C : TCountry;
begin
  aQSO.QSO.NewMulti1 := False;
  aQSO.QSO.NewMulti2 := False;
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
  if i in [1..MAXCQZONE] then
    if Zone[B,i] = False then
      begin
        Zone[B,i] := True;
        aQSO.QSO.NewMulti1 := True;
        WWZone.Mark(B,i);
      end;

  i := GetCountryIndex(aQSO);

  C := TCountry(CountryList.List[i]);
  MostRecentCty := C;

  aQSO.QSO.Multi2 := C.Country;

  if i = 0 then // unknown cty. e.g. MM
    exit;

  if C.Worked[B] = False then
    begin
      C.Worked[B] := True;
      aQSO.QSO.NewMulti2 := True;
      //j := ListBox.TopIndex;
      Grid.Cells[0,C.GridIndex] := C.Summary;
      //ListBox.Items.Delete(i);
      //ListBox.Items.insert(i, C.Summary);
      //ListBox.TopIndex := j;
    end;
end;

end.
