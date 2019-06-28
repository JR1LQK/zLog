unit UARRL10Multi;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  zLogGlobal,UARRLDXMulti, UWWMulti, UMultipliers, Grids, Cologrid, StdCtrls, ExtCtrls, JLLabel;

type
  TARRL10Multi = class(TWWMulti)
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridSetting(ARow, Acol: Integer; var Fcolor: Integer;
      var Bold, Italic, underline: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    StateList : TStateList;
    IsUSA : boolean;
    LastMulti : integer; // grid top
    procedure Update; override;
    procedure Add(var aQSO : TQSO); override;
    procedure SortDefault; override;
    procedure SortZone; override;
    procedure Reset; override;
    procedure RefreshGrid; override;
    procedure AddNoUpdate(var aQSO : TQSO); override;
    function ValidMulti(aQSO : TQSO) : boolean; override;
    procedure CheckMulti(aQSO : TQSO); override;
    function GetInfoAA(aQSO : TQSO) : string; // called from spacebarproc in TAllAsianContest
    function ExtractMulti(aQSO : TQSO) : string; override;
  end;

var
  ARRL10Multi: TARRL10Multi;

implementation

uses Main, UOptions;

{$R *.DFM}

function TARRL10Multi.GetInfoAA(aQSO : TQSO) : string;
begin
  Result := TCountry(CountryList.List[GetCountryIndex(aQSO)]).JustInfo;
end;

procedure TARRL10Multi.CheckMulti(aQSO : TQSO);
var S : TState;
    str : string;
begin
  S := GetState(aQSO, StateList);
  if S = nil then
    str := 'Invalid state'
  else
    begin
      str := S.StateAbbrev + ' ' + S.StateName + ' Worked in : ';
      if S.Worked[b19] then str := str + 'Ph ';
      if S.Worked[b35] then str := str + 'CW ';
    end;
  MainForm.WriteStatusLine(str, false);
end;

function TARRL10Multi.ValidMulti(aQSO : TQSO) : boolean;
var i, j : integer;
begin
  Result := False;

  if aQSO.QSO.NrRcvd = '' then
    exit;

  if IsMM(aQSO.QSO.Callsign) then
    begin
      if (aQSO.QSO.NrRcvd = '1') or (aQSO.QSO.NrRcvd = '2') or (aQSO.QSO.NrRcvd = '3') then
        Result := True
      else
        Result := False;
      exit;
    end;

  i := GetCountryIndex(aQSO);

  if (i > 0) then
    if IsWVE(TCountry(CountryList.List[i]).Country) then
      begin
        if GetState(aQSO,StateList) <> nil then
          Result := True;
      end
    else // not W/VE serial number
      begin
        try
          j := StrToInt(aQSO.QSO.NrRcvd);
        except
          on EConvertError do
            j := 0;
        end;
        if j > 0 then
          Result := True;
      end;
end;

procedure TARRL10Multi.AddNoUpdate(var aQSO : TQSO);
var str : string;
    B : TBand;
    i, j : integer;
    C : TCountry;
    S : TState;
begin
  aQSO.QSO.NewMulti1 := False;
  aQSO.QSO.NewMulti2 := False;

  i := GetCountryIndex(aQSO);

  C := TCountry(CountryList.List[i]);

  if aQSO.QSO.Mode = mCW then
    B := b35
  else
    B := b19;

  if aQSO.QSO.Dupe then
    exit;

  if IsWVE(C.Country) or IsMM(aQSO.QSO.Callsign) then
    begin
      S := GetState(aQSO, StateList);
      if S = nil then
        begin
          aQSO.QSO.Multi1 := '';
          aQSO.QSO.Memo := 'INVALID EXCHANGE '+aQSO.QSO.Memo;
        end
      else
        begin
          aQSO.QSO.Multi1 := S.StateAbbrev;
          if S.Worked[B] = False then
            begin
              S.Worked[B] := True;
              aQSO.QSO.NewMulti1 := True;
              LastMulti := S.Index;
            end;
        end;
    end
  else
    begin
      aQSO.QSO.Multi1 := C.Country;
      if C.Worked[B] = False then
        begin
          C.Worked[B] := True;
          aQSO.QSO.NewMulti1 := True;
          LastMulti := C.GridIndex;
          //Grid.Cells[0,C.GridIndex] := C.SummaryARRL10;
        end;
    end;

end;



procedure TARRL10Multi.FormCreate(Sender: TObject);
var i : integer;
    aQSO : TQSO;
    S : TState;
begin
  {inherited; }
  LastMulti := 0;
  StateList := TStateList.Create;
  StateList.LoadFromFile('ARRL10.DAT');

  S := TState.Create;
  S.StateAbbrev := '1';
  S.AltAbbrev := '1';
  S.StateName := 'ITU Reg. 1';
  S.Index := StateList.List.Count;
  StateList.List.Add(S);
  S := TState.Create;
  S.StateAbbrev := '2';
  S.AltAbbrev := '2';
  S.StateName := 'ITU Reg. 2';
  S.Index := StateList.List.Count;
  StateList.List.Add(S);
  S := TState.Create;
  S.StateAbbrev := '3';
  S.AltAbbrev := '3';
  S.StateName := 'ITU Reg. 3';
  S.Index := StateList.List.Count;
  StateList.List.Add(S);

  CountryList := TCountryList.Create;
  PrefixList := TPrefixList.Create;

  //LoadCountryDataFromFile('DXCC.DAT');

  if FileExists('CTY.DAT') then
    begin
      LoadCTY_DAT(testIARU, CountryList, PrefixList);
      MainForm.WriteStatusLine('Loaded CTY.DAT', true);
    end
  else
    LoadCountryDataFromFile('DXCC.DAT', CountryList, PrefixList);


  if CountryList.List.Count = 0 then exit;
  {for i := 0 to CountryList.List.Count-1 do
    begin
      ListBox.Items.Add(TCountry(CountryList.List[i]).Summary);
    end;}
  Reset;
  MyContinent := 'AS';
  MyCountry := 'JA';
  IsUSA := False;
  if (Options.Settings._mycall <> '') and (Options.Settings._mycall <> 'Your callsign') then
    begin
      aQSO := TQSO.Create;
      aQSO.QSO.callsign := Uppercase(Options.Settings._mycall);
      i := GetCountryIndex(aQSO);
      if i > 0 then
        begin
          MyCountry := TCountry(CountryList.List[i]).Country;
          MyContinent := TCountry(CountryList.List[i]).Continent;
          if (MyCountry = 'K') or (MyCountry = 'N') or (MyCountry = 'W') then
            IsUSA := True;
        end;
      aQSO.Free;
    end;
end;

procedure TARRL10Multi.SortZone;
begin
end;

procedure TARRL10Multi.SortDefault;
var B : TBand;
    i, j, offset : integer;
    S : string;
begin
  if StateList.List.Count = 0 then exit;
  j := Grid.TopRow;
  Grid.RowCount := 0;
  Grid.RowCount := StateList.List.Count + CountryList.List.Count;

  for i := 0 to StateList.List.Count-1 do
    begin
      S := TState(StateList.List[i]).SummaryARRL10;
      //Grid.Cells[0,i] := S;
      TState(StateList.List[i]).Index := i;
      GridReverse[i] := i;
    end;

  offset := StateList.List.Count;

  if CountryList.List.Count = 0 then exit;
  for i := 0 to CountryList.List.Count - 1 do
    begin
      //Grid.Cells[0,i + offset] := TCountry(CountryList.List[i]).SummaryARRL10;
      TCountry(CountryList.List[i]).GridIndex := i + offset;
      GridReverse[i + offset] := i;
    end;
  Grid.TopRow := j;
end;

procedure TARRL10Multi.Update;
begin
  SortDefault;
  RefreshGrid;
  //RefreshZone;
  RenewCluster;
  RenewBandScope;
end;

procedure TARRL10Multi.Add(var aQSO : TQSO);
begin
  AddNoUpdate(aQSO);
  Grid.TopRow := LastMulti;
{
  if (aQSO.QSO.Reserve2 <> $AA) and (MostRecentCty <> nil) then
    Grid.TopRow := MostRecentCty.GridIndex;
}
  RefreshGrid;
  //RefreshZone;
  AddSpot(aQSO);

end;



procedure TARRL10Multi.Reset;
var B : TBand;
    i : integer;
begin
  for i := 0 to StateList.List.Count-1 do
    for B := b19 to HiBand do
      TState(StateList.List[i]).Worked[B] := false;
  for i := 0 to CountryList.List.Count-1 do
    for B := b19 to HiBand do
      TCountry(CountryList.List[i]).Worked[B] := false;
{ case SortBy.ItemIndex of
    0 : SortDefault;
    1 : SortZone;
  end; }
  SortDefault;
end;



procedure TARRL10Multi.FormShow(Sender: TObject);
begin
//  inherited;
  RefreshGrid;
end;

procedure TARRL10Multi.GridSetting(ARow, Acol: Integer;
  var Fcolor: Integer; var Bold, Italic, underline: Boolean);
var B : TBand;
begin
  if Main.CurrentQSO.QSO.Mode = mCW then
    B := b35
  else
    B := b19;
  if ARow < StateList.List.Count then
    begin
      if TState(StateList.List[ARow]).Worked[B] then
        FColor := clRed
      else
        FColor := clBlack;
    end
  else
    begin
      if pos('N/A',Grid.Cells[ACol, ARow]) > 2 then
        FColor := clGray
      else
        if TCountry(CountryList.List[GridReverse[ARow]]).Worked[B] then
          FColor := clRed
        else
          FColor := clBlack;
    end;
end;

procedure TARRL10Multi.RefreshGrid;
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
          if (i >= 0) and (i < StateList.List.Count) then
            begin
              Grid.Cells[0, i] := TState(StateList.List[k]).SummaryARRL10;
            end
          else
            if (i >= StateList.List.Count) and (i < CountryList.List.Count + StateList.List.Count) then
              begin
                Grid.Cells[0, i] := TCountry(CountryList.List[k]).Summary
              end
            else
              Grid.Cells[0, i] := '';
        end;
    end;
end;

function TARRL10Multi.ExtractMulti(aQSO : TQSO) : string;
var i : integer;
    C : TCountry;
    S : TState;
begin
  Result := '';
  i := GetCountryIndex(aQSO);
  C := TCountry(CountryList.List[i]);
  if IsWVE(C.Country) or IsMM(aQSO.QSO.Callsign) then
    begin
      S := GetState(aQSO, StateList);
      if S <> nil then
        Result := S.StateAbbrev;
    end
  else
    begin
      Result := C.Country;
    end;
end;

end.
