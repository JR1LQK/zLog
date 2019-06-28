unit UGeneralScore;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, Aligrid, StdCtrls, ExtCtrls, zLogGlobal, Menus, Grids,
  UMultipliers, Buttons;


type
  TPointsTable = array[b19..HiBand, mCW..mOther] of Integer;

  TGeneralScore = class(TBasicScore)
    Grid: TStringAlignGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure ResetParams; // called from LoadCFG
  public
    WARC : boolean;

    SameCTYPoints, SameCONTPoints : boolean;
    PointsTable : TPointsTable;
    LocalPointsTable : TPointsTable;
    SameCTYPointsTable : TPointsTable;
    SameCONTPointsTable : TPointsTable;

    SpecialCallPointsTable : TPointsTable;
    SpecialCalls : string;  // special callsigns for specialcallpointstable

    AlphabetPointsTable : array[ord('0')..ord('Z')] of Integer;
    AlphabetPoints : boolean;
    procedure SetPointsTable(var PT : TPointsTable; str : string);
    procedure CalcPoints(var aQSO : TQSO);
    procedure AddNoUpdate(var aQSO : TQSO); override;
    procedure Update; override;
    procedure Reset; override;
    procedure Add(var aQSO : TQSO); override; {calculates points}
    procedure LoadCFG(Filename : string);
    { Public declarations }
  end;

var
  GeneralScore: TGeneralScore;

implementation

uses UGeneralMulti, UGeneralMulti2, UOptions, Main;

{$R *.DFM}

procedure TGeneralScore.SetPointsTable(var PT : TPointsTable; str : string);
var i, k : integer;
    tempstr, pstr : string;
    B : TBand;
begin
  tempstr := str+',';
  B := b19;

  while pos(',', tempstr) > 0 do
    begin
      i := pos(',',tempstr);
      if i > 0 then
        pstr := copy(tempstr, 1, i-1)
      else
        exit;
      try
        k := StrToInt(pstr);
      except
        on EConvertError do
          k := 0;
      end;
      PT[B, mCW] := k;
      delete(tempstr, 1, i);

      i := pos(',',tempstr);
      if i > 0 then
        pstr := copy(tempstr, 1, i-1)
      else
        exit;
      try
        k := StrToInt(pstr);
      except
        on EConvertError do
          k := 0;
      end;
      PT[B, mSSB] := k;
      PT[B, mFM] := k;
      PT[B, mAM] := k;
      delete(tempstr, 1, i);
      repeat
        inc(B);
      until NotWARC(B);
    end;
end;

procedure TGeneralScore.ResetParams;
var B : TBand;
    M : TMode;
    i : integer;
begin
  for B := b19 to HiBand do
    for M := mCW to mOther do
      begin
        PointsTable[B, M] := 1;
        LocalPointsTable[B, M] := 1;
        SameCTYPointsTable[B, M] := 1;
        SameCONTPointsTable[B, M] := 1;
        SpecialCallPointsTable[B, M] := 1;
      end;
  SameCTYPoints := False;
  SameCONTPoints := False;
  AlphabetPoints := False;
  SpecialCalls := '';
  for i := ord('0') to ord('Z') do
    AlphabetPointsTable[i] := 0;

  SerialContestType := 0;
  for B := b19 to HiBand do
    SerialArray[B] := 1;

  with GeneralMulti2 do
    begin
      for i := 0 to MAXLOCAL do
        LocalString[i] := '';
      MinLocalLen := 0;
      _cut := 0; _lcut := 0; _tail := 0; _ltail := 0;
    end;
end;

procedure TGeneralScore.LoadCFG(Filename : string);
var zfile : textfile;
    check : boolean;
    rstr, tstr, com, opr, tempstr : string;
    p, q, work, i, k : integer;
    _bnd : TBand;
const TAB = #$09;

begin
 ResetParams;
 System.Assign(zfile, FIlename);
 {$I-}
 System.reset(zfile);
 {$I+}
 check := FileExists(FileName); //(IOresult=0);
  case check of
   true  : { file exists }
     begin
       while not(eof(zfile)) do
         begin
           readln(zfile,rstr);
           if (rstr <> '') and (rstr[1]<>';') then
             begin

               q:=Pos(';',rstr);
               if q>0 then rstr:=Copy(rstr,1,q-1);  {Cut out comment}

               p:=0;
               repeat
                 inc(p);
               until (rstr[p] in [' ',tab]) or (p>length(rstr));
               q:=p;
               repeat
                 inc(q);
               until not(rstr[q] in [' ',tab]) or (q>length(rstr));

               com:=Uppercase(copy(rstr,1,p-1));
               opr:=copy(rstr,q,255);

               opr:=Uppercase(opr);

               if pos('PT',com)=1 then
                 begin
                   _bnd:=b19;
                   if copy(com,3,3)='1.9' then _bnd:=b19;
                   if copy(com,3,3)='3.5' then _bnd:=b35;
                   if copy(com,3,3)='7'   then _bnd:=b7;
                   if copy(com,3,3)='10'  then _bnd:=b10;
                   if copy(com,3,3)='14'  then _bnd:=b14;
                   if copy(com,3,3)='18'  then _bnd:=b18;
                   if copy(com,3,3)='21'  then _bnd:=b21;
                   if copy(com,3,3)='24'  then _bnd:=b24;
                   if copy(com,3,3)='28'  then _bnd:=b28;
                   if copy(com,3,3)='50'  then _bnd:=b50;
                   if copy(com,3,3)='144' then _bnd:=b144;
                   if copy(com,3,3)='430' then _bnd:=b430;
                   if copy(com,3,3)='120' then _bnd:=b1200;
                   if copy(com,3,3)='240' then _bnd:=b2400;
                   if copy(com,3,3)='560' then _bnd:=b5600;
                   if copy(com,3,3)='10G' then _bnd:=b10g;
                   if length(opr) >= 2 then
                     begin
                       try
                         work := StrToInt(opr[1]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       PointsTable[_bnd, mSSB] := work;
                       try
                         work := StrToInt(opr[2]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       PointsTable[_bnd, mCW] := work;
                       try
                         work := StrToInt(opr[3]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       PointsTable[_bnd, mFM]  := work;
                       try
                         work := StrToInt(opr[4]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       PointsTable[_bnd, mAM]  := work;
                     end;
                 end;


               if pos('LPT',com)=1 then
                 begin
                   _bnd:=b19;
                   if copy(com,4,3)='1.9' then _bnd:=b19;
                   if copy(com,4,3)='3.5' then _bnd:=b35;
                   if copy(com,4,3)='7'   then _bnd:=b7;
                   if copy(com,4,3)='10'  then _bnd:=b10;
                   if copy(com,4,3)='14'  then _bnd:=b14;
                   if copy(com,4,3)='18'  then _bnd:=b18;
                   if copy(com,4,3)='21'  then _bnd:=b21;
                   if copy(com,4,3)='24'  then _bnd:=b24;
                   if copy(com,4,3)='28'  then _bnd:=b28;
                   if copy(com,4,3)='50'  then _bnd:=b50;
                   if copy(com,4,3)='144' then _bnd:=b144;
                   if copy(com,4,3)='430' then _bnd:=b430;
                   if copy(com,4,3)='120' then _bnd:=b1200;
                   if copy(com,4,3)='240' then _bnd:=b2400;
                   if copy(com,4,3)='560' then _bnd:=b5600;
                   if copy(com,4,3)='10G' then _bnd:=b10g;
                   if length(opr) >= 2 then
                     begin
                       try
                         work := StrToInt(opr[1]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       LocalPointsTable[_bnd, mSSB] := work;
                       try
                         work := StrToInt(opr[2]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       LocalPointsTable[_bnd, mCW] := work;
                       try
                         work := StrToInt(opr[3]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       LocalPointsTable[_bnd, mFM]  := work;
                       try
                         work := StrToInt(opr[4]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       LocalPointsTable[_bnd, mAM]  := work;
                     end;
                 end;

               if pos('XPT',com)=1 then
                 begin
                   _bnd:=b19;
                   if copy(com,4,3)='1.9' then _bnd:=b19;
                   if copy(com,4,3)='3.5' then _bnd:=b35;
                   if copy(com,4,3)='7'   then _bnd:=b7;
                   if copy(com,4,3)='10'  then _bnd:=b10;
                   if copy(com,4,3)='14'  then _bnd:=b14;
                   if copy(com,4,3)='18'  then _bnd:=b18;
                   if copy(com,4,3)='21'  then _bnd:=b21;
                   if copy(com,4,3)='24'  then _bnd:=b24;
                   if copy(com,4,3)='28'  then _bnd:=b28;
                   if copy(com,4,3)='50'  then _bnd:=b50;
                   if copy(com,4,3)='144' then _bnd:=b144;
                   if copy(com,4,3)='430' then _bnd:=b430;
                   if copy(com,4,3)='120' then _bnd:=b1200;
                   if copy(com,4,3)='240' then _bnd:=b2400;
                   if copy(com,4,3)='560' then _bnd:=b5600;
                   if copy(com,4,3)='10G' then _bnd:=b10g;
                   if length(opr) >= 4 then
                     begin
                       try
                         work := StrToInt(opr[1]+opr[2]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       PointsTable[_bnd, mSSB] := work;
                       try
                         work := StrToInt(opr[3]+opr[4]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       PointsTable[_bnd, mCW] := work;
                       try
                         work := StrToInt(opr[5]+opr[6]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       PointsTable[_bnd, mFM]  := work;
                       try
                         work := StrToInt(opr[7]+opr[8]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       PointsTable[_bnd, mAM]  := work;
                     end;
                 end;


               if pos('XLPT',com)=1 then
                 begin
                   _bnd:=b19;
                   if copy(com,5,3)='1.9' then _bnd:=b19;
                   if copy(com,5,3)='3.5' then _bnd:=b35;
                   if copy(com,5,3)='7'   then _bnd:=b7;
                   if copy(com,5,3)='10'  then _bnd:=b10;
                   if copy(com,5,3)='14'  then _bnd:=b14;
                   if copy(com,5,3)='18'  then _bnd:=b18;
                   if copy(com,5,3)='21'  then _bnd:=b21;
                   if copy(com,5,3)='24'  then _bnd:=b24;
                   if copy(com,5,3)='28'  then _bnd:=b28;
                   if copy(com,5,3)='50'  then _bnd:=b50;
                   if copy(com,5,3)='144' then _bnd:=b144;
                   if copy(com,5,3)='430' then _bnd:=b430;
                   if copy(com,5,3)='120' then _bnd:=b1200;
                   if copy(com,5,3)='240' then _bnd:=b2400;
                   if copy(com,5,3)='560' then _bnd:=b5600;
                   if copy(com,5,3)='10G' then _bnd:=b10g;
                   if length(opr) >= 4 then
                     begin
                       try
                         work := StrToInt(opr[1]+opr[2]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       LocalPointsTable[_bnd, mSSB] := work;
                        try
                         work := StrToInt(opr[3]+opr[4]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       LocalPointsTable[_bnd, mCW] := work;
                       try
                         work := StrToInt(opr[5]+opr[6]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       LocalPointsTable[_bnd, mFM]  := work;
                       try
                         work := StrToInt(opr[7]+opr[8]);
                       except
                         on EConvertError do
                           work := 1;
                       end;
                       LocalPointsTable[_bnd, mAM]  := work;

                     end;
                 end;

               if com = 'SAMECTYPT' then
                 begin
                   SetPointsTable(SameCTYPointsTable, opr);
                   SameCTYPoints := True;
                 end;

               if com = 'SAMECONTPT' then
                 begin
                   SetPointsTable(SameCONTPointsTable, opr);
                   SameCONTPoints := True;
                 end;

               if com = 'LOCALPT' then
                 begin
                   SetPointsTable(LocalPointsTable, opr);
                 end;

               if com = 'DEFAULTPT' then
                 begin
                   SetPointsTable(PointsTable, opr);
                 end;

               if com = 'SPECIALCALLPT' then
                 begin
                   SetPointsTable(SpecialCallPointsTable, opr);
                 end;

               if com = 'SPECIALCALLS' then
                 begin
                   if SpecialCalls <> '' then
                     SpecialCalls := SpecialCalls + ',' + opr
                   else
                     SpecialCalls := opr;
                 end;

               if com = 'LOCALCTY' then
                 begin
                   GeneralMulti2.LocalCTY := UpperCase(opr);
                 end;

               if com = 'LOCALCONT' then
                 begin
                   GeneralMulti2.LocalCONT := UpperCase(opr);
                 end;


               if com = 'LOCAL' then
                 begin
                   tstr:=''; k:=0;
                   for i:=1 to length(opr) do
                     begin
                       if opr[i]=',' then
                         begin
                           GeneralMulti2.LocalString[k]:=tstr;
                           if k<MAXLOCAL then inc(k);
                           tstr:='';
                         end
                       else
                         tstr:=tstr+opr[i];
                     end;
                   if k<=MAXLOCAL then GeneralMulti2.LocalString[k]:=tstr;
                 end;



               if pos('ALPHAPT',com) = 1 then
                 begin
                   AlphabetPoints := True;
                   for i:=1 to (length(opr) div 2) do
                     begin
                       if opr[2*i-1] = '?' then
                         begin
                           if opr[2*i] in ['0'..'9'] then
                             for k := ord('0') to ord('Z') do
                               AlphabetPointsTable[k]:=StrToInt(opr[2*i]);
                         end
                     end;
                   for i:=1 to (length(opr) div 2) do
                     begin
                       if opr[2*i-1] in ['0'..'Z'] then
                         begin
                           if opr[2*i] in ['0'..'9'] then
                             AlphabetPointsTable[ord(opr[2*i-1])]:=StrToInt(opr[2*i]);
                         end
                     end;
                 end;

               if com='LOCMIN' then
                 begin
                   try
                     work := StrToInt(opr);
                   except
                     on EConvertError do
                       work := -99;
                   end;
                   if work >= 0 then
                     GeneralMulti2.MinLocalLen := work;
                 end;



               if com='SENDNR' then
                 begin
                   Options.Settings._sentstr := opr;
                 end;

               if com='DAT' then
                 begin
                   tstr := opr;
                   if Pos('.',tstr)=0 then
                     tstr := tstr +'.DAT';
                   GeneralMulti2.LoadDAT(tstr);
                 end;


               if com='TIME' then
                 if opr = 'UTC' then
                   begin
                     UseUTC := True;
                     TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
                   end;

               if com='CTY' then
                 begin
                   GeneralMulti2.LoadCTY(UpperCase(opr));
                 end;

               if com='COUNTMULTIONCE' then
                 begin
                   if opr = 'ON' then
                     GeneralMulti2.CountOnce := True
                   else
                     GeneralMulti2.CountOnce := False;
                 end;

               if com='NOCTYMULTI' then
                 begin
                   GeneralMulti2.NoCTYMulti := UpperCase(opr);
                 end;


               if com='MODE' then
                 begin
                   if opr = 'ON' then
                     begin
                       Log.AcceptDifferentMode := True;
                       {
                       for _bnd := b19 to HiBand do
                         SubLog[_bnd].AcceptDifferentMode := True;}
                     end;
                 end;

               if com='CUT' then
                 begin
                   try
                     work := StrToInt(opr);
                   except
                     on EConvertError do
                       work := -99;
                   end;
                   if work <> -99 then
                     GeneralMulti2._cut := work;
                 end;

               if com='LCUT' then
                 begin
                   try
                     work := StrToInt(opr);
                   except
                     on EConvertError do
                       work := -99;
                   end;
                   if work <> -99 then
                     GeneralMulti2._lcut := work;
                 end;

               if com='TAIL' then
                 begin
                   try
                     work := StrToInt(opr);
                   except
                     on EConvertError do
                       work := -99;
                   end;
                   if work <> -99 then
                     GeneralMulti2._tail := work;
                 end;

               if com='LTAIL' then
                 begin
                   try
                     work := StrToInt(opr);
                   except
                     on EConvertError do
                       work := -99;
                   end;
                   if work <> -99 then
                     GeneralMulti2._ltail := work;
                 end;

               if com = 'UNDEFMULTI' then
                 begin
                   if opr = 'ON' then
                     GeneralMulti2.UndefMulti := True;
                 end;

                if com = 'JARL' then
                 begin
                   if opr = 'ON' then
                     GeneralMulti2.CutTailingAlphabets := True;
                 end;

                if com = 'CUTTAILABT' then //equivalent to JARL
                 begin
                   if opr = 'ON' then
                     GeneralMulti2.CutTailingAlphabets := True;
                 end;

               if com='POWER' then
                 begin
                   _bnd := b19;
                   for i:=1 to length(opr) do
                     begin
                       case opr[i] of
                         'A' : Options.CurrentPower[_bnd]:=p010;
                         'B' : Options.CurrentPower[_bnd]:=p025;
                         'C' : Options.CurrentPower[_bnd]:=p050;
                         'D' : Options.CurrentPower[_bnd]:=p100;
                         'E' : Options.CurrentPower[_bnd]:=p500;
                         'O' : Options.CurrentPower[_bnd]:=p001;
                         'F' : Options.CurrentPower[_bnd]:=p005;
                         'N' : Options.CurrentPower[_bnd]:=p002;
                         'T' : Options.CurrentPower[_bnd]:=p020;
                         'W' : Options.CurrentPower[_bnd]:=p200;
                         'K' : Options.CurrentPower[_bnd]:=p1000;
                         'X' : Options.CurrentPower[_bnd]:=p1000;
                         'P' : Options.CurrentPower[_bnd]:=pwrP;
                         'L' : Options.CurrentPower[_bnd]:=pwrL;
                         'M' : Options.CurrentPower[_bnd]:=pwrM;
                         'H' : Options.CurrentPower[_bnd]:=pwrH;
                         '-' : begin
                                  Options.CurrentPower[_bnd]:=pwrP;
                                  //Options.CurrentPower2[_bnd]:=p010;
                                 MainForm.BandMenu.Items[ord(_bnd)].Visible := False;
                                end;
                       end;
                       if _bnd < HiBand then
                         repeat
                           inc(_bnd);
                         until NotWARC(_bnd);
                     end;
                 end;

               if com='UNLISTEDMULTI' then
                 begin
                   if opr='ON' then GeneralMulti2.AllowUnlistedMulti := True;
                 end;

               if com='NOMULTI' then
                 begin
                   if opr='ON' then GeneralMulti2.NoMulti := True;
                 end;

               if com='PXMULTI' then
                 begin
                   //CAPTION := OPR;
                   if opr='NORMAL' then
                     begin
                       //undefMulti := True;
                       GeneralMulti2.PXMulti := PX_Normal;
                     end;
                   if opr='WPX' then
                     begin
                       //undefMulti := True;
                       GeneralMulti2.PXMulti := PX_WPX;
                     end;
                   if opr='OFF' then
                     begin
                       GeneralMulti2.PXMulti := 0;
                     end;
                 end;

               if com='SERIAL' then
                 begin
                   if opr = 'ALL' then SerialContestType := SER_ALL;
                   if opr = 'BAND' then SerialContestType := SER_BAND;
                 end;

               if com='SERIALSTART' then
                 begin
                   for _bnd := b19 to HiBand do
                     SerialArray[_bnd] := StrToInt(opr);
                 end;

               if com='COUNTHIGH' then
                 begin
                   if opr='ON' then Log.CountHigherPoints := True;
                   {for _bnd := b19 to HiBand do
                     SubLog[_bnd].AcceptDifferentMode := True; }
                 end;

               if com='WARC' then
                 begin
                   if opr = 'ON' then
                     begin
                       WARC := True;
                       MainForm.BandMenu.Items[ord(b10)].Visible := True;
                       MainForm.BandMenu.Items[ord(b18)].Visible := True;
                       MainForm.BandMenu.Items[ord(b24)].Visible := True;
                     end;
                 end;
               {if com='MULCK' then
                 begin
                   if opr='OFF' then _NoCheckNonLocal := True;
                 end;

               if com='LMULCK' then
                 begin
                   if opr='OFF' then _NoCheckLocal := True;
                 end;

               if com='MODE' then
                 begin
                   if opr='ON' then _Mode := True;
                 end;}
             end;
         end;
       System.close(zfile);
     end;

   false :
      begin
        MessageDlg('CFG file cannot be found. Place it in the same folder as ZLOG.EXE', mtError,
                   [mbOK], 0);
      end;
  end;

end;

{
procedure TGeneralScore.Update;
var band : TBand;
    TotQSO, TotPoints, TotMulti : LongInt;
    row : integer;
begin
  TotQSO := 0; TotPoints  := 0; TotMulti := 0;
  row := 1;
  for band := b19 to HiBand do
    begin
      if NotWARC(band) then
        begin
          Grid.Cells[1,row] := IntToStr(QSO[band]);
          TotQSO := TotQSO + QSO[band];
          Grid.Cells[2,row] := IntToStr(Points[band]);
          TotPoints := TotPoints + Points[band];
          Grid.Cells[3,row] := IntToStr(Multi[band]);
          TotMulti := TotMulti + Multi[band];
          inc(row);
        end;
    end;
  Grid.Cells[1, 14] := IntToStr(TotQSO);
  Grid.Cells[2, 14] := IntToStr(TotPoints);
  Grid.Cells[3, 14] := IntToStr(TotMulti);
  Grid.Cells[3, 15] := IntToStr(TotPoints*TotMulti);
end;
}

procedure TGeneralScore.Update;
var band : TBand;
    TotQSO, TotPoints, TotMulti : LongInt;
    row : integer;
    mb : TMenuItem;
begin
  TotQSO := 0; TotPoints  := 0; TotMulti := 0;
  row := 1;
  //Grid.RowFont[0].Color := clGreen;

  if ShowCWRatio then
    begin
      Grid.ColCount := 6;
      Grid.Width :=  Grid.DefaultColWidth * 6;
    end
  else
    begin
      Grid.ColCount := 4;
      Grid.Width := Grid.DefaultColWidth * 4;
    end;

  Grid.Cells[0,0] := 'MHz';
  Grid.Cells[1,0] := 'QSOs';
  Grid.Cells[2,0] := 'Points';
  Grid.Cells[3,0] := 'Mult';

  if ShowCWRatio then
    begin
      Grid.Cells[4,0] := 'CW QSOs';
      Grid.Cells[5,0] := 'CW %';
    end;

  GeneralMulti2.SetActiveBands;
  for band := b19 to HiBand do
    begin
      TotQSO := TotQSO + QSO[band];
      TotPoints := TotPoints + Points[band];
      TotMulti := TotMulti + Multi[band];
      if ActiveBands[band] then
        begin
          Grid.CellFont[0,row].Color := clBlue;
          Grid.Cells[0,row] := MHzString[band];
          Grid.Cells[1,row] := IntToStr(QSO[band]);
          Grid.Cells[2,row] := IntToStr(Points[band]);
          if GeneralMulti2.NoMulti then
            Grid.Cells[3,row] := '-'
          else
            Grid.Cells[3,row] := IntToStr(Multi[band]);

         if ShowCWRatio then
           begin
             Grid.Cells[4,row] := IntToStr(CWQSO[band]);
             if QSO[band] > 0 then
               Grid.Cells[5,row] := FloatToStrF(100*(CWQSO[band] / QSO[band]), ffFixed, 1000, 1)
             else
               Grid.Cells[5,row] := '-';
           end;

         inc(row);
        end;
    end;

  Grid.CellFont[0, row].Color := clBlack;
  Grid.Cells[0, row] := 'Total';
  Grid.Cells[1, row] := IntToStr(TotQSO);
  Grid.Cells[2, row] := IntToStr(TotPoints);
  if GeneralMulti2.NoMulti then
    Grid.Cells[3, row] := '-'
  else
    Grid.Cells[3, row] := IntToStr(TotMulti);

  if ShowCWRatio then
    begin
      Grid.Cells[4, row] := IntToStr(TotalCWQSOs);
      if TotQSO > 0 then
        Grid.Cells[5, row] := FloatToStrF(100*(TotalCWQSOs/TotQSO), ffFixed, 1000, 1)
      else
        Grid.Cells[5, row] := '-';
    end;

  inc(row);
  Grid.CellFont[0, row].Color := clBlack;
  Grid.Cells[0, row] := 'Score';
  Grid.Cells[1, row] := '';
  Grid.Cells[2, row] := '';
  if GeneralMulti2.NoMulti then
    Grid.Cells[3, row] := IntToStr(TotPoints)
  else
    Grid.Cells[3, row] := IntToStr(TotPoints*TotMulti);
  Grid.Height := 16*(row+1);
  GeneralScore.Height := Grid.Height + (333-256);
end;


procedure TGeneralScore.CalcPoints(var aQSO : TQSO);
var i : integer;
    ch : char;
    C : TCountry;
begin
  aQSO.QSO.Points := PointsTable[aQSO.QSO.Band, aQSO.QSO.Mode];

  if GeneralMulti2._DXTEST then
    begin
      if SameCTYPoints or SameCONTPoints then
        begin
          i := aQSO.QSO.Power2;
          if (i < CountryList.List.Count) and (i >= 0) then
            begin
              C := TCountry(CountryList.List[i]);
              if SameCTYPoints and (C.Country = MyCountry) then
                aQSO.QSO.Points := SameCTYPointsTable[aQSO.QSO.Band, aQSO.QSO.Mode]
              else
                if SameCONTPoints and (C.Continent = MyContinent) then
                  aQSO.QSO.Points := SameCONTPointsTable[aQSO.QSO.Band, aQSO.QSO.Mode];
            end;
        end;
    end;

  if GeneralMulti2.IsLocal(aQSO) then
    aQSO.QSO.Points := LocalPointsTable[aQSO.QSO.Band, aQSO.QSO.Mode];

  if AlphabetPoints then
    begin
      aQSO.QSO.Points := 0;
      i := length(aQSO.QSO.NrRcvd);
      if i > 0 then
        begin
          ch := aQSO.QSO.NrRcvd[i];
          if ch in ['0'..'Z'] then
            aQSO.QSO.Points := AlphabetPointsTable[ord(ch)];
        end;
    end;

  if SpecialCalls <> '' then
    begin
      if pos(','+aQSO.QSO.Callsign+',', ','+SpecialCalls+',') > 0 then
        aQSO.QSO.Points := SpecialCallPointsTable[aQSO.QSO.Band, aQSO.QSO.Mode];
    end;
end;

procedure TGeneralScore.AddNoUpdate(var aQSO : TQSO);
var i : integer;
    tempQSO : TQSO;
begin
  inherited;

  if aQSO.QSO.Dupe then
    exit;

  CalcPoints(aQSO);

  if Log.CountHigherPoints = True then
    begin
      i := Log.DifferentModePointer;
      If i > 0 then
        begin
          if TQSO(Log.List[i]).QSO.Points < aQSO.QSO.Points then
            begin
              TempQSO := TQSO(Log.List[i]);
              Dec(Points[TempQSO.QSO.Band], TempQSO.QSO.Points);
              TQSO(Log.List[i]).QSO.Points := 0;
              //NeedRefresh := True;
            end
          else
            aQSO.QSO.Points := 0;
        end;
    end;

  Inc(Points[aQSO.QSO.Band], aQSO.QSO.Points);
end;

procedure TGeneralScore.FormCreate(Sender: TObject);
var B : TBand;
    M : TMode;
begin
  inherited;
  WARC := False;
end;

procedure TGeneralScore.Reset;
begin
  inherited;
end;

procedure TGeneralScore.Add(var aQSO : TQSO);
begin
  inherited;
end;


procedure TGeneralScore.FormShow(Sender: TObject);
begin
  inherited;
  Button1.SetFocus;
  Grid.Col := 1;
  Grid.Row := 1;
end;


end.
