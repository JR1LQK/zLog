unit UWAEMulti;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UARRLWMulti, Grids, Cologrid, StdCtrls, ExtCtrls, JLLabel, UMultipliers,
  zLogGlobal;

type
  TWAEMulti = class(TARRLWMulti)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddNoUpdate(var aQSO : TQSO); override;
    function GetInfo(aQSO : TQSO) : string; override;
    procedure Update; override;
  end;

var
  WAEMulti: TWAEMulti;

implementation

{$R *.DFM}



procedure TWAEMulti.FormCreate(Sender: TObject);
begin
  inherited;
  //ShowContinent('EU');
end;

procedure TWAEMulti.AddNoUpdate(var aQSO : TQSO);
var str : string;
    B : TBand;
    i, j : integer;
    C : TCountry;
begin
  aQSO.QSO.NewMulti1 := False;
  aQSO.QSO.NewMulti2 := False;

  i := GetCountryIndex(aQSO);

  C := TCountry(CountryList.List[i]);
  if C.Continent <> 'EU' then
    begin
      aQSO.QSO.Points := 0;
      aQSO.QSO.Multi1 := 'Non-EU';
      exit;
    end;
  aQSO.QSO.Multi1 := C.Country;

  if aQSO.QSO.Dupe then
    exit;


  B := aQSO.QSO.Band;

  if C.Worked[B] = False then
    begin
      C.Worked[B] := True;
      aQSO.QSO.NewMulti1 := True;
      //Grid.Cells[0,C.GridIndex] := C.Summary;
    end;
end;

function TWAEMulti.GetInfo(aQSO : TQSO) : string;
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

  if C.Continent <> 'EU' then
    begin
      temp := 'NOT EUROPE '+temp;
      Result := temp;
      exit;
    end;

  temp2 := '';
  if C.Worked[aQSO.QSO.Band] = false then
    temp2 := 'CTY';

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



procedure TWAEMulti.Update;
begin
  ShowContinent('EU');
  RefreshGrid;
  //RefreshZone;
  RenewCluster;
  RenewBandScope;
end;

end.
