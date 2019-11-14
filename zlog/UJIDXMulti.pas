unit UJIDXMulti;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UWWMulti, UMultipliers, StdCtrls, JLLabel, ExtCtrls, Grids, Cologrid,
  UzLogGlobal;

type
  TJIDXMulti = class(TWWMulti)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddNoUpdate(var aQSO : TQSO); override;
  end;

implementation

uses
  Main;

{$R *.DFM}

procedure TJIDXMulti.FormCreate(Sender: TObject);
var
   i : integer;
   aQSO : TQSO;
begin
   {inherited; }
   CountryList := TCountryList.Create;
   PrefixList := TPrefixList.Create;

   if FileExists('CTY.DAT') then begin
      LoadCTY_DAT(testDXCCWWZone, CountryList, PrefixList);
      MainForm.WriteStatusLine('Loaded CTY.DAT', true);
   end
   else begin
      LoadCountryDataFromFile('DXCC.DAT', CountryList, PrefixList);
   end;

   if CountryList.List.Count = 0 then begin
      exit;
   end;

   Reset;
   MyContinent := 'AS';
   MyCountry := 'JA';

   if (dmZlogGlobal.Settings._mycall <> '') and (dmZlogGlobal.Settings._mycall <> 'Your callsign') then begin
      aQSO := TQSO.Create;
      aQSO.QSO.callsign := UpperCase(dmZlogGlobal.Settings._mycall);
      i := GetCountryIndex(aQSO);
      if i > 0 then begin
         MyCountry := TCountry(CountryList.List[i]).Country;
         MyContinent := TCountry(CountryList.List[i]).Continent;
      end;
      aQSO.Free;
   end;
end;

procedure TJIDXMulti.AddNoUpdate(var aQSO : TQSO);
var
   str : string;
   B: TBand;
   i: integer;
   C: TCountry;
begin
   aQSO.QSO.NewMulti1 := False;
   aQSO.QSO.NewMulti2 := False;
   str := aQSO.QSO.NrRcvd;
   aQSO.QSO.Multi1 := str;

   if aQSO.QSO.Dupe then begin
      exit;
   end;

   B := aQSO.QSO.band;
   i := StrToIntDef(str, 0);

   if i in [1..MAXCQZONE] then begin
      if Zone[B,i] = False then begin
         Zone[B,i] := True;
         aQSO.QSO.NewMulti1 := True;
         FZoneForm.Mark(B,i);
      end;
   end;

   i := GetCountryIndex(aQSO);

   C := TCountry(CountryList.List[i]);
   MostRecentCty := C;

   aQSO.QSO.Multi2 := C.Country;

   if i = 0 then begin // unknown cty. e.g. MM
      exit;
   end;

   if C.Worked[B] = False then begin
      C.Worked[B] := True;
      aQSO.QSO.NewMulti2 := True;
      Grid.Cells[0,C.GridIndex] := C.Summary;
   end;
end;

end.
