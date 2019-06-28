unit UCheckCountry;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UCheckWin, StdCtrls, ExtCtrls, UWWMulti, UMultipliers, zLogGlobal, Main;

type
  TCheckCountry = class(TCheckWin)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    TempCountry : TCountry; // holds the last country analyzed;
    TempZone : integer;
  public
    { Public declarations }

    ParentMulti : TWWMulti;
    procedure Renew(aQSO : TQSO); override;
    function NotNewMulti(B : TBand) : boolean;
  end;

var
  CheckCountry: TCheckCountry;

implementation

{$R *.DFM}

procedure TCheckCountry.Renew(aQSO : TQSO);
var cty : string;
    i : LongInt;
    z, row : integer;
    B : TBand;
    C : TCountry;
    S, PartialStr : string;
    BoxFlags : array[0..20] of boolean;
begin
  ResetListBox;
  if length(aQSO.QSO.Callsign) = 0 then
    exit;
  for i := 0 to 20 do
    BoxFlags[i] := False;
  i := {ParentMulti.}GetCountryIndex(aQSO);
//  i := Main.MyContest.MultiForm.GetCountryIndex(aQSO);

  C := TCountry({ParentMulti.}CountryList.List[i]);
  TempCountry := C;
  Caption := C.Country+': '+C.CountryName+' '+C.Continent;
  cty := C.Country;
  PartialStr := aQSO.QSO.Callsign;
  if cty <> '' then
    begin
      for i := Log.TotalQSO downto 1 do
        if cty = TQSO(Log.List[i]).QSO.Multi2 then
          begin
            B := TQSO(Log.List[i]).QSO.Band;
            row := BandRow[B];
            if row >= 0 then
              begin
                if BoxFlags[row] = False then
                  begin
                    ListBox.Items.Delete(row);
                    ListBox.Items.Insert(row, Main.MyContest.CheckWinSummary(TQSO(Log.List[i])));
                    BoxFlags[row] := True;
                  end
                else
                  begin
                    if TQSO(Log.List[i]).QSO.Callsign = PartialStr then
                      begin
                        ListBox.Items.Delete(row);
                        ListBox.Items.Insert(row, Main.MyContest.CheckWinSummary(TQSO(Log.List[i])));
                      end;
                    end;
              end;
          end;
    end;
  z := 0;
  try
    z := StrToInt(aQSO.QSO.NrRcvd);
  except
    on EConvertError do
      z := 0;
  end;
  TempZone := z;
  if z in [1..40] then
    begin
      for B := b19 to b28 do
        begin
          if BandRow[B] >= 0 then
            if ParentMulti.Zone[B, z] = false then
              begin
                S := ListBox.Items[BandRow[B]];
                S := FillRight(S, 27) + 'Zone ' +
                     FillRight(IntToStr(z), 2) + ' NEEDED';
                ListBox.Items.Delete(BandRow[B]);
                ListBox.Items.Insert(BandRow[B], S);
              end;
        end;
    end;
end;

procedure TCheckCountry.FormCreate(Sender: TObject);
begin
  inherited;
  TempCountry := nil;
end;

function TCheckCountry.NotNewMulti(B : TBand) : boolean;
var newcountry, newzone : boolean;
begin
  if TempCountry <> nil then
    newcountry := not(TempCountry.Worked[B])
  else
    newcountry := False;
  if TempZone <> 0 then
    newzone := not(ParentMulti.Zone[B, TempZone])
  else
    newzone := False;
  Result := not(newzone or newcountry);
end;

end.
