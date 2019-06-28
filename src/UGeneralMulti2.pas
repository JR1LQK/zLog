unit UGeneralMulti2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UACAGMulti, StdCtrls, JLLabel, ExtCtrls, zLogGlobal, checklst, Grids,
  Cologrid, UWPXMulti, UMultipliers, Menus;

const  MAXLOCAL = 31;
       PX_WPX    = 1;
       PX_NORMAL = 2;
       BANDLABELMAX = 30;
type
  TGeneralMulti2 = class(TACAGMulti)
    procedure FormCreate(Sender: TObject);
    procedure GridSetting(ARow, Acol: Integer; var Fcolor: Integer;
      var Bold, Italic, underline: Boolean);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    BandLabelArray : array[0..BANDLABELMAX] of TRotateLabel;

    PXMulti : integer;

    _DXTEST : boolean;
    NoCTYMulti : string; // use citylist for these countries
    LocalCTY, LocalCONT : string;

    LocalString : array[0..MAXLOCAL] of string[30];
    MinLocalLen : integer;
    _cut, _lcut, _tail, _ltail : integer;
    UndefMulti : boolean; //
    CountOnce : boolean; // count multi once regardless of band
    CutTailingAlphabets : boolean; // JARL/CUTTAILABT
    AllowUnlistedMulti : boolean; // allows unlisted multi to be logged but not counted as a multi.
    NoMulti : boolean;
    function IsLocal(aQSO : TQSO) : boolean;
    procedure SetActiveBands;
    procedure LoadDAT(Filename : string);
    procedure LoadCTY(CTYTYPE : string);
    function ExtractMulti(aQSO : TQSO) : string; override;
    procedure AddNoUpdate(var aQSO : TQSO); override;
    function ValidMulti(aQSO : TQSO) : boolean; override;
    procedure CheckMulti(aQSO : TQSO); override;
    procedure Reset; override;
    procedure Update; override;
    { Public declarations }

  end;

var
  GeneralMulti2: TGeneralMulti2;

implementation

uses Main, UGeneralScore;

{$R *.DFM}

procedure TGeneralMulti2.SetActiveBands;
var band : TBand;
    mb : TMenuItem;
begin
  for band := b19 to HiBand do
    begin
      ActiveBands[band] := False;
      if ((GeneralScore.WARC = False) and NotWARC(band)) or
         (GeneralScore.WARC=True) then
        begin
          mb := MainForm.BandMenu.Items[ord(band)];
          if mb.Visible and mb.Enabled then
            ActiveBands[band] := True
        end;
    end;
end;

function GetPX(aQSO : TQSO) : string;
var s, px : string;
    i, slash : integer;
begin
  Result := '';
  s := aQSO.QSO.Callsign;
  if s = '' then
    exit;
  slash := pos('/',s);
  if GeneralMulti2.PXMulti = PX_WPX then
    begin
      Result := UWPXMulti.GetWPXPrefix(aQSO);
      exit;
    end
  else
    begin
      if slash > 4 then
        s := copy(s, 1, slash-1);
      if slash in [1..4] then
      Delete(s, 1, slash);
      i := length(s) + 1;
      repeat
        dec(i)
      until (i = 0) or (s[i] in ['0'..'9']);
      Result := copy(s,1,i);
      exit;
    end;
end;

(*     CCC function for reference
Function GetPX(ywxQSO : QSOdata) : string;
var st : string;
    pr,prr : string;
    slash : byte;
    n : integer;
    label xyz,xqv;
begin
  pr:='';
  st:=CallStr(ywxQSO);

  xyz :
  if Pos('/',st) = 0 then
    begin
      n:=length(st)+1;
      repeat
        Dec(n);
      until IsNumber(st[n]);
      pr:=Copy(st,1,n);   { 1•¶Žš–Ú‚©‚çÅŒã‚Ì”Žš‚Ü‚Å }
      {if IsNumber(st[3]) then
        begin
          pr:=Copy(st,1,3);
        end
      else
        begin
          pr:=st[1]+st[2];
        end;}
    end
  else { / ‚ ‚è }
    begin
      slash:=Pos('/',st);
      if slash>=5 then
        begin
          if IsNumber(st[length(st)]) and (length(st)=slash+1) then {/0,1...}
            begin
	      n:=slash-1;
	      repeat
		Dec(n);
	      until IsNumber(st[n]);
	      pr:=Copy(st,1,n-1);
              pr:=pr+st[length(st)];
              goto xqv;
            end;
          if IsNumber(st[length(st)]) then
            pr:=Copy(st,slash+1,5)
          else
            begin
	      prr:=Copy(st,slash+1,5);
 	      if((prr='AT') or (prr='AG') or (prr='AA') or (prr='AE') or 
	         (prr='MM') or (prr='M')  or (prr='P') or (prr='QRP') or
	         (prr='A') or (prr='KT'))  then
                    begin
                      st:=Copy(st,1,slash-1);
                      goto xyz;
                    end
              else
                begin
                  if (length(prr)=3) and IsNumber(prr[2]) then
                    pr:=prr[1]+prr[2] { /C6A, /U0C etc }
                  else pr:=prr+'0';
                end;
            end;
        end
      else { slash < 5 }
        begin
          if IsNumber(st[slash-1]) then
            pr:=Copy(st,1,slash-1)
          else
            begin
              if (slash=4) and IsNumber(st[2]) then
                pr:=st[1]+st[2] { C6A/, U0C/ etc }
              else pr:=Copy(st,1,slash-1)+'0';
            end;
        end;
    end;
xqv :
GetPX:=pr;
end;
*)

procedure TGeneralMulti2.Update;
var i, j : integer;
    C : TCity;
    str : string;
    B : TBand;
begin
  SetActiveBands;

  i := 0;
  for B := b19 to Hiband do
    begin
      if ActiveBands[B] then
        begin
          BandLabelArray[i].Caption := MHzString[B];
          j := BandLabelArray[i].Height;
          //BandLabelArray[i].Caption := IntToStr(j);
          BandLabelArray[i].Top := 35 - j;
          inc(i);
        end;
    end;
  for j := i to BANDLABELMAX do
    BandLabelArray[i].Caption := '';

  if Grid.RowCount < CityList.List.Count then
    Grid.RowCount := CityList.List.Count;

  if _DXTEST then
    if CountryList.List.Count > 0 then
      if NoCTYMulti <> '*' then
        Grid.RowCount := CityList.List.Count + CountryList.List.Count;

  for i := 0 to CityList.List.Count-1 do
    begin
      C := TCity(CityList.List[i]);
      str := C.SummaryGeneral;
      Grid.Cells[0,i] := str;
    end;

  if CityList.List.Count = 0 then
    i := 0;

  if _DXTEST and (NoCTYMulti <> '*') then
    for j := 0 to CountryList.List.Count - 1 do
      begin
        Grid.Cells[0, i + j] := TCountry(CountryLIst.List[j]).SummaryGeneral;
      end;

  Grid.TopRow := LatestMultiAddition;
end;

procedure TGeneralMulti2.Reset;
var i, j : integer;
    B : TBand;
    str : string;
begin
  if CountryList <> nil then
    CountryList.Reset;
  if CityList <> nil then
    CityList.Reset;

{  if CityList.List.Count = 0 then exit;
  j := Grid.TopRow;
  Grid.RowCount := 0;
  Grid.RowCount := CityList.List.Count;
  for i := 0 to CityList.List.Count-1 do
    begin
      for B := b19 to HiBand do
        TCity(CityList.List[i]).Worked[B] := false;
      str := TCity(CityList.List[i]).Summary;
      Grid.Cells[0,i] := str;
    end;
  Grid.TopRow := j;}

end;


function TGeneralMulti2.ValidMulti(aQSO : TQSO) : boolean;
var str : string;
    B : TBand;
    i : integer;
    C : TCity;
    boo : boolean;
begin
  //CAPTION := INTTOSTR(PXMULTI);
  if UndefMulti or AllowUnlistedMulti or (PXMulti <> 0) or _DXTEST or NoMulti then
    begin
      Result := True;
      exit;
    end;
  str := ExtractMulti(aQSO);
  boo := false;
  for i := 0 to CityList.List.Count-1 do
    begin
      C := TCity(CityList.List[i]);
      if pos(','+str+',', ','+C.CityNumber+',') > 0 then
        begin
           boo := true;
           break;
        end;
    end;
  Result := boo;
end;



function TGeneralMulti2.ExtractMulti(aQSO : TQSO) : string;
var  str : string;
     i : integer;
begin
  str := aQSO.QSO.NrRcvd;

  if PXMulti <> 0 then
    begin
      Result := GetPX(aQSO);
      exit;
    end;

  if CutTailingAlphabets then // deletes any tailing non-digits
    begin
      for i := length(str) downto 1 do
        if str[i] in ['0'..'9'] then
          break;
      if (i = 1) and (str[1] in ['0'..'9']) then
        str := ''
      else
        str := copy(str, 1, i);
    end;

  if IsLocal(aQSO) then
    begin
      if _lcut <> 0 then
        begin
          if _lcut > 0 then
            Delete(str, length(str)-_lcut+1, _lcut)
          else
            Delete(str, 1, _lcut * -1);
        end
      else {lcut = 0}
        begin
          if _ltail <> 0 then
            if _ltail > 0 then
              str := copy(str, length(str)-_ltail+1, _ltail)
            else
              str := copy(str, 1, -1*_ltail);
        end;
    end
  else  {not local}
    begin
      if _cut <> 0 then
        begin
          if _cut > 0 then
            Delete(str, length(str)-_cut+1, _cut)
          else
            Delete(str, 1, _cut * -1);
        end
      else {cut = 0}
        begin
          if _tail <> 0 then
            if _tail > 0 then
              str := copy(str, length(str)-_tail+1, _tail)
            else
              str := copy(str, 1, -1*_tail);
        end;
    end;
  Result := str;
end;

procedure TGeneralMulti2.AddNoUpdate(var aQSO : TQSO);
var str, str2 : string;
    B : TBand;
    i, j : integer;
    C : TCity;
    Cty : TCountry;
    boo : Boolean;
label aaa;
begin
  aQSO.QSO.NewMulti1 := False;
  if NoMulti then exit;
  aQSO.QSO.Power2 := 2; // not local CTY

  if _DXTEST then
    begin
      i := GetCountryIndex(aQSO);
      if i > 0 then
        begin
          Cty := TCountry(CountryList.List[i]);

          aQSO.QSO.Power2 := i;
          {
          if LocalCTY <> '' then
            begin
              if pos(','+Cty.Country+',', ','+LocalCTY+',') > 0 then
                begin
                  aQSO.QSO.Power2 := 22; // tells IsLocal that this is Local CTY
                end;
            end;
          }
          if NoCtyMulti = '*' then
            goto aaa;

          if pos(','+Cty.Country+',', ','+NoCTYMulti+',') > 0 then
            goto aaa;


          aQSO.QSO.Multi1 := Cty.Country;

          if aQSO.QSO.Dupe then
            exit;

          LatestMultiAddition := CityList.List.Count + i;

          if CountOnce then // multi once regardless of band
            begin
              boo := false;
              for B := b19 to HiBand do
                if Cty.Worked[B] then
                  begin
                    boo := true;
                    break;
                  end;
              if boo = false then
                 begin
                   aQSO.QSO.NewMulti1 := True;
                   Cty.Worked[aQSO.QSO.Band] := True;
                 end;
            end
          else // new multi each band
            begin
              if Cty.Worked[aQSO.QSO.Band] = False then
                begin
                  aQSO.QSO.NewMulti1 := True;
                  Cty.Worked[aQSO.QSO.Band] := True;
                end;
            end;

          exit;
        end;
    end;

aaa:
  str := ExtractMulti(aQSO);
  aQSO.QSO.Multi1 := str;

  if aQSO.QSO.Dupe then
    exit;

  for i := 0 to CityList.List.Count-1 do
    begin
      C := TCity(CityList.List[i]);

      str2 := ','+C.CityNumber+',';         //  for alternative exchange
      if pos (','+str+',', str2) > 0 then   //
      //if str = C.CityNumber then
        begin
          if C.Worked[aQSO.QSO.band] = False then
            begin
              C.Worked[aQSO.QSO.band] := True;
              //j := Grid.TopRow;
              //Grid.Cells[0,i] := C.Summary; //
              //Grid.TopRow := j;             //
              aQSO.QSO.NewMulti1 := True;
            end;
          //if (i < Grid.TopRow) or (i > Grid.TopRow+Grid.VisibleRowCount-1) then
            //Grid.TopRow := i;  //
          LatestMultiAddition := C.Index;
          exit;
        end;
    end;

  // no match with CityList

  if AllowUnlistedMulti then
    begin
      exit;
    end;

  if UndefMulti or (PXMulti <> 0) then
    begin
      C := TCity.Create;
      C.CityNumber := str;
      C.Worked[aQSO.QSO.Band] := True;
      i := CityList.AddAndSort(C);
      aQSO.QSO.NewMulti1 := True;
      LatestMultiAddition := C.Index;
      //Update;
      //if (i < Grid.TopRow) or (i > Grid.TopRow+Grid.VisibleRowCount-1) then
        //Grid.TopRow := i;
    end;
end;



function TGeneralMulti2.IsLocal(aQSO : TQSO) : boolean;
var i : integer;
begin
  Result := False;

  if _DXTEST then
    begin
      if LocalCTY <> '' then
        begin
          i := aQSO.QSO.Power2;
          if i < CountryList.List.Count then
            if pos(','+TCountry(CountryList.List[i]).Country+',', ','+LocalCTY+',') > 0 then
              begin
                Result := True;
                exit;
              end;
        end;
      if LocalCONT <> '' then
        begin
          i := aQSO.QSO.Power2;
          if i < CountryList.List.Count then
            if pos(','+TCountry(CountryList.List[i]).Continent+',', ','+LocalCONT+',') > 0 then
              begin
                Result := True;
                exit;
              end;
        end;
    end;

  for i := 0 to MAXLOCAL do
    if LocalString[i] = '' then
      exit
    else
      if (Pos(LocalString[i], aQSO.QSO.NrRcvd) = 1) and
         (Length(aQSO.QSO.NrRcvd) >= MinLocalLen) then
        begin
          Result := True;
          exit;
        end;
end;

procedure TGeneralMulti2.LoadDAT(Filename : string);
var i : integer;
begin
  CityList.LoadFromFile(FileName);
  Reset;
end;

procedure TGeneralMulti2.LoadCTY(CTYTYPE : string);
var str : string;
begin
  if (CTYTYPE <> 'CQ') and (CTYTYPE <> 'IARU') and (CTYTYPE <> 'DXCC') then
    begin
      if pos('.DAT', CTYTYPE) = 0 then
        str := CTYTYPE+'.DAT';
      if FileExists(str) then
        begin
          CountryList := TCountryList.Create;
          PrefixList := TPrefixList.Create;
          _DXTEST := True;
          LoadCountryDataFromFile(str, CountryList, PrefixList);
        end
      else
        MainForm.WriteStatusLine(str+ ' not found', true);
      exit;
    end;

  CountryList := TCountryList.Create;
  PrefixList := TPrefixList.Create;
  _DXTEST := True;

  if CTYTYPE = 'CQ' then
    begin
      if FileExists('CTY.DAT') then
        begin
          MainForm.WriteStatusLine('Loading CTY.DAT...', true);
          LoadCTY_DAT(testCQWW, CountryList, PrefixList);
          MainForm.WriteStatusLine('Loaded CTY.DAT', true);
        end
      else
        LoadCountryDataFromFile('CQWW.DAT', CountryList, PrefixList);
    end;
  if CTYTYPE = 'DXCC' then
    begin
      if FileExists('CTY.DAT') then
        begin
          MainForm.WriteStatusLine('Loading CTY.DAT...', true);
          LoadCTY_DAT(testDXCCWWZone, CountryList, PrefixList);
          MainForm.WriteStatusLine('Loaded CTY.DAT', true);
        end
      else
        LoadCountryDataFromFile('DXCC.DAT', CountryList, PrefixList);
    end;
  if CTYTYPE = 'IARU' then
    begin
      if FileExists('CTY.DAT') then
        begin
          MainForm.WriteStatusLine('Loading CTY.DAT...', true);
          LoadCTY_DAT(testIARU, CountryList, PrefixList);
          MainForm.WriteStatusLine('Loaded CTY.DAT', true);
        end
      else
        LoadCountryDataFromFile('IARU.DAT', CountryList, PrefixList);
    end;
  AnalyzeMyCountry;
end;

procedure TGeneralMulti2.FormCreate(Sender: TObject);
var i : integer;
begin
  //inherited;
  LatestMultiAddition := 0;
  Label1R9.Visible := True;
  CityList := TCityList.Create;
  UndefMulti := False;
  NoMulti := False;
  CountOnce := False;
  CutTailingAlphabets := False;
  AllowUnlistedMulti := False;
  PXMulti := 0;
  _DXTEST := false;
  NoCtyMulti := '';
  LocalCTY := '';
  LocalCONT := '';
  //SetActiveBands;

  Label1R9.Visible := False;
  Label3R5.Visible := False;
  Label7.Visible := False;
  Label14.Visible := False;
  Label21.Visible := False;
  Label28.Visible := False;
  Label50.Visible := False;
  Label144.Visible := False;
  Label430.Visible := False;
  Label1200.Visible := False;
  Label2400.Visible := False;
  Label5600.Visible := False;
  Label10G.Visible := False;

  for i := 0 to BANDLABELMAX do
    begin
      BandLabelArray[i] := TRotateLabel.Create(Self);
      BandLabelArray[i].Parent := Panel;
      BandLabelArray[i].Escapement := 90;
      BandLabelArray[i].Alignment := taleftjustify;
      BandLabelArray[i].Font := Label1R9.Font;
      BandLabelArray[i].TextStyle := tsNone;
      BandLabelArray[i].Left := Label1R9.Left + Trunc(12.15*i);
      BandLabelArray[i].Top := 10;
      //BandLabelArray[i].Height := 1;
      BandLabelArray[i].AutoSize := True;
      BandLabelArray[i].Caption := '';
    end;

end;

procedure TGeneralMulti2.CheckMulti(aQSO : TQSO);
var str : string;
    B : TBand;
    i : integer;
    C : TCity;
begin
  if ValidMulti(aQSO) then
    str := ExtractMulti(aQSO)
  else
    str := aQSO.QSO.NrRcvd;

  if str = '' then
    exit;

  for i := 0 to CityList.List.Count-1 do
    begin
      C := TCity(CityList.List[i]);
      if pos(','+str+',', ','+C.CityNumber+',') > 0 then
        begin
          //ListBox.TopIndex := i;
          Grid.TopRow := i;
          str := C.Summary2;
          if C.Worked[aQSO.QSO.Band] then
            Insert('Worked on this band. ',str, 27)
          else
            Insert('Needed on this band. ',str, 27);
          MainForm.WriteStatusLine(str, false);
          exit;
        end;
    end;
  if UndefMulti then
    MainForm.WriteStatusLine(str+ ' : '+'Not worked on any band', false)
  else
    MainForm.WriteStatusLine('Invalid number', false);
end;

procedure TGeneralMulti2.GridSetting(ARow, Acol: Integer;
  var Fcolor: Integer; var Bold, Italic, underline: Boolean);
var B, B2 : TBand;
    C : TCountry;
begin
  //inherited;
  B := Main.CurrentQSO.QSO.Band;
  if _DXTEST then
    begin
      if ARow > CityList.List.Count - 1 then
        begin
          C := TCountry(CountryList.List[ARow - CityList.List.Count]);
          if C.Worked[B] then
            FColor := clRed
          else
            begin
              if CountOnce then
                begin
                  for B2 := b19 to HiBand do
                    if C.Worked[B2] then
                      begin
                        FColor := clRed;
                        exit;
                      end;
                end;
              FColor := clBlack;
            end;
          exit;
        end;
    end;
  if ARow > CityList.List.Count - 1 then
    exit;
  if TCity(CityList.List[ARow]).Worked[B] then
    FColor := clRed
  else
    begin
      FColor := clBlack;

      if CountOnce then
        begin
          for B2 := b19 to HiBand do
            if TCity(CityList.List[ARow]).Worked[B2] then
              begin
                FColor := clRed;
                exit;
              end;
        end;
    end;
end;

procedure TGeneralMulti2.FormShow(Sender: TObject);
begin
  //inherited;
  SetActiveBands;
  Update;
end;

end.
