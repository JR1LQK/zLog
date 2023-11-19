unit UELogJapanese;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, zLogGlobal;

type
  TELogJapanese = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label23: TLabel;
    mOath: TMemo;
    edContestName: TEdit;
    edCategoryName: TEdit;
    edCallsign: TEdit;
    edOpCallsign: TEdit;
    edCategoryCode: TEdit;
    edFDCoefficient: TEdit;
    edTEL: TEdit;
    edOPName: TEdit;
    edEMail: TEdit;
    edLicense: TEdit;
    edPower: TEdit;
    rPowerType: TRadioGroup;
    edQTH: TEdit;
    edClubID: TEdit;
    edPowerSupply: TEdit;
    mComments: TMemo;
    edClubName: TEdit;
    edDate: TEdit;
    edSignature: TEdit;
    btnCreateLog: TButton;
    btnSave: TButton;
    btnCancel: TButton;
    mAddress: TMemo;
    mEquipment: TMemo;
    Label12: TLabel;
    procedure btnCreateLogClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
    procedure RemoveBlankLines(M : TMemo);
    procedure InitializeFields;
  end;

var
  ELogJapanese: TELogJapanese;

implementation

uses Main, UOptions;

{$R *.dfm}

procedure TELogJapanese.RemoveBlankLines(M : TMemo);
var i : integer;
begin
  i := M.Lines.Count-1;
  while i >= 0 do
    begin
      if M.Lines[i] = '' then
        M.Lines.Delete(i)
      else
        break;
      dec(i);
    end;
end;

procedure TELogJapanese.InitializeFields;

begin

  edContestName.Text := MyContest.Name;
  edCategoryCode.Text := Options.Ini.GetString('SummaryInfo', 'CategoryCode', '');
  edCategoryName.Text := Options.Ini.GetString('SummaryInfo', 'CategoryName', '');
  edCallsign.Text := Options.MyCall;
  edOpCallsign.Text := Options.Ini.GetString('SummaryInfo', 'OperatorCallsign', '');
  edFDCoefficient.Text := Options.Ini.GetString('SummaryInfo', 'FDCoefficient', '1');

  mAddress.Clear;
  mAddress.Lines[0] := Options.Ini.GetString('SummaryInfo', 'Address1', '〒');
  mAddress.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Address2', ''));
  mAddress.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Address3', ''));
  mAddress.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Address4', ''));
  mAddress.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Address5', ''));
  RemoveBlankLines(mAddress);

  edTEL.Text := Options.Ini.GetString('SummaryInfo', 'Telephone', '');
  edOPName.Text := Options.Ini.GetString('SummaryInfo', 'OperatorName', '');
  edEMail.Text := Options.Ini.GetString('SummaryInfo', 'EMail', '');
  edLicense.Text := Options.Ini.GetString('SummaryInfo', 'License', '');
  edPower.Text := Options.Ini.GetString('SummaryInfo', 'Power', '');
  rPowerType.ItemIndex := Options.Ini.GetInteger('SummaryInfo','PowerType',0);
  edQTH.Text := Options.Ini.GetString('SummaryInfo', 'QTH', '');
  edPowerSupply.Text := Options.Ini.GetString('SummaryInfo', 'PowerSupply', '');

  mEquipment.Clear;
  mEquipment.Lines[0] := Options.Ini.GetString('SummaryInfo', 'Equipment1', '');
  mEquipment.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Equipment2', ''));
  mEquipment.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Equipment3', ''));
  mEquipment.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Equipment4', ''));
  mEquipment.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Equipment5', ''));
  RemoveBlankLines(mEquipment);

  mComments.Clear;
  mComments.Lines[0] := Options.Ini.GetString('SummaryInfo', 'Comment1', '');
  mComments.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Comment2', ''));
  mComments.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Comment3', ''));
  mComments.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Comment4', ''));
  mComments.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Comment5', ''));
  mComments.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Comment6', ''));
  mComments.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Comment7', ''));
  mComments.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Comment8', ''));
  mComments.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Comment9', ''));
  mComments.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Comment10', ''));
  RemoveBlankLines(mComments);

  edClubID.Text := Options.Ini.GetString('SummaryInfo', 'ClubID', '');
  edClubName.Text := Options.Ini.GetString('SummaryInfo', 'ClubName', '');

  mOath.Clear;
  mOath.Lines[0] := Options.Ini.GetString('SummaryInfo', 'Oath1', '私は、JARL制定'+
  'のコンテスト規約および電波法令にしたがい運用した結果、ここ'+
  'に提出するサマリーシートおよびログシートなどが事実と相違な'+
  'いものであることを、私の名誉において誓います。');

  mOath.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Oath2', ''));
  mOath.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Oath3', ''));
  mOath.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Oath4', ''));
  mOath.Lines.Add(Options.Ini.GetString('SummaryInfo', 'Oath5', ''));
  RemoveBlankLines(mOath);

  edDate.Text := FormatDateTime('yyyy"年"m"月"d"日"',Now);

end;

procedure TELogJapanese.btnCreateLogClick(Sender: TObject);
var f : textfile;
    S, str, fname : string;
    i : integer;
    B : TBand;
begin
  MainForm.GeneralSaveDialog.DefaultExt := 'em';
  MainForm.GeneralSaveDialog.Filter := 'JARL E-log files (*.em)|*.em';
  MainForm.GeneralSaveDialog.Title := 'Save E-Log file';
  if CurrentFileName <> '' then
    begin
      str := CurrentFileName;
      str := Copy(str, 0, length(str) - length(ExtractFileExt(str)));
      str := str + '.em';
      MainForm.GeneralSaveDialog.FileName := str;
    end;
   if MainForm.GeneralSaveDialog.Execute then
     fname := MainForm.GeneralSaveDialog.FileName
   else
     exit;

  assignfile(f, fname);
  rewrite(f);

  writeln(f, '<SUMMARYSHEET VERSION=R1.0>');
  writeln(f, '<CONTESTNAME>'+edContestName.Text+'</CONTESTNAME>');
  writeln(f, '<CATEGORYCODE>'+edCategoryCode.Text+'</CATEGORYCODE>');
  writeln(f, '<CATEGORYNAME>'+edCategoryName.Text+'</CATEGORYNAME>');
  writeln(f, '<CALLSIGN>'+edCallsign.Text+'</CALLSIGN>');
  writeln(f, '<OPCALLSIGN>'+edOpCallsign.Text+'</OPCALLSIGN>');

  for b := b19 to HiBand do
    begin
      if MyContest.ScoreForm.QSO[b] > 0 then
        begin
          if b = b10G then
            writeln(f, '<SCORE BAND=10.1GHz>'+MyContest.ScoreForm.QPMStr(b)+'</SCORE>')
          else
            writeln(f, '<SCORE BAND='+MHzString[B]+'MHz>'+MyContest.ScoreForm.QPMStr(b)+'</SCORE>');
        end;
    end;
  writeln(f, '<SCORE BAND=TOTAL>'+MyContest.ScoreForm.TotalQPMStr+'</SCORE>');

  try
    i := StrToInt(edFDCoefficient.Text);
  except
    on EConvertError do
      i := 1
  end;
  if i <> 0 then
    writeln(f, '<FDCOEFF>'+IntToStr(i)+'</FDCOEFF>');

  writeln(f, '<TOTALSCORE>' + IntToStr(MyContest.ScoreForm._TotalMulti*MyContest.ScoreForm._TotalPoints*i)+
             '</TOTALSCORE>');

  writeln(f, '<ADDRESS>');
  writeln(f, mAddress.Text);
  writeln(f, '</ADDRESS>');

  writeln(f, '<TEL>'+edTEL.Text+'</TEL>');
  writeln(f, '<NAME>'+edOPName.Text+'</NAME>');
  writeln(f, '<EMAIL>'+edEMAIL.Text+'</EMAIL>');
  writeln(f, '<LICENSECLASS>'+edLicense.Text+'</LICENSECLASS>');
  writeln(f, '<POWER>'+edPOWER.Text+'</POWER>');

  if rPowerType.ItemIndex = 0 then
    writeln(f,'<POWERTYPE>定格出力</POWERTYPE>')
  else
    writeln(f,'<POWERTYPE>実測出力</POWERTYPE>');

  writeln(f, '<OPPLACE>'+edQTH.Text+'</OPPLACE>');
  writeln(f, '<POWERSUPPLY>'+edPowerSupply.Text+'</POWERSUPPLY>');

  writeln(f, '<EQUIPMENT>');
  writeln(f, mEquipment.Text);
  writeln(f, '</EQUIPMENT>');

  writeln(f, '<COMMENTS>');
  writeln(f, mComments.Text);
  writeln(f, '</COMMENTS>');

  writeln(f, '<REGCLUBNUMBER>'+edClubID.Text+'</REGCLUBNUMBER>');
  writeln(f, '<REGCLUBNAME>'+edClubName.Text+'</REGCLUBNAME>');

  writeln(f, '<OATH>');
  writeln(f, mOath.Text);
  writeln(f, '</OATH>');

  writeln(f, '<DATE>'+edDate.Text+'</DATE>');
  writeln(f, '<SIGNATURE>'+edSignature.Text+'</SIGNATURE>');

  writeln(f, '</SUMMARYSHEET>');

  writeln(f, '<LOGSHEET TYPE=ZLOG.ALL>');

  writeln(f, 'Date       Time  Callsign    RSTs ExSent RSTr ExRcvd  Mult  Mult2 MHz  Mode Pt Memo');
  for i := 1 to Log.TotalQSO do
    writeln(f, TQSO(Log.List[i]).zLogALL);

  writeln(f, '</LOGSHEET>');



  {for i := 1 to TotalQSO do
    writeln(f, TQSO(List[i]).zLogALL);}
  closefile(f);
end;

procedure TELogJapanese.FormCreate(Sender: TObject);
begin
  //InitializeFields;
end;

procedure TELogJapanese.btnSaveClick(Sender: TObject);
begin

  Options.Ini.SetString('SummaryInfo', 'CategoryCode', edCategoryCode.Text);
  Options.Ini.SetString('SummaryInfo', 'CategoryName', edCategoryName.Text);
  Options.Ini.SetString('SummaryInfo', 'OperatorCallsign', edOpCallsign.Text);
  Options.Ini.SetString('SummaryInfo', 'FDCoefficient', edFDCoefficient.Text);

  Options.Ini.SetString('SummaryInfo', 'Address1', mAddress.Lines[0]);
  Options.Ini.SetString('SummaryInfo', 'Address2', mAddress.Lines[1]);
  Options.Ini.SetString('SummaryInfo', 'Address3', mAddress.Lines[2]);
  Options.Ini.SetString('SummaryInfo', 'Address4', mAddress.Lines[3]);
  Options.Ini.SetString('SummaryInfo', 'Address5', mAddress.Lines[4]);

  Options.Ini.SetString('SummaryInfo', 'Telephone', edTEL.Text);
  Options.Ini.SetString('SummaryInfo', 'OperatorName', edOPName.Text);
  Options.Ini.SetString('SummaryInfo', 'EMail', edEMail.Text);

  Options.Ini.SetString('SummaryInfo', 'License', edLicense.Text);

  Options.Ini.SetString('SummaryInfo', 'Power', edPower.Text);
  Options.Ini.SetInteger('SummaryInfo','PowerType',rPowerType.ItemIndex);
  Options.Ini.SetString('SummaryInfo', 'QTH', edQTH.Text);
  Options.Ini.SetString('SummaryInfo', 'PowerSupply', edPowerSupply.Text);

  Options.Ini.SetString('SummaryInfo', 'Equipment1', mEquipment.Lines[0]);
  Options.Ini.SetString('SummaryInfo', 'Equipment2', mEquipment.Lines[1]);
  Options.Ini.SetString('SummaryInfo', 'Equipment3', mEquipment.Lines[2]);
  Options.Ini.SetString('SummaryInfo', 'Equipment4', mEquipment.Lines[3]);
  Options.Ini.SetString('SummaryInfo', 'Equipment5', mEquipment.Lines[4]);

  Options.Ini.SetString('SummaryInfo', 'Comment1', mComments.Lines[0]);
  Options.Ini.SetString('SummaryInfo', 'Comment2', mComments.Lines[1]);
  Options.Ini.SetString('SummaryInfo', 'Comment3', mComments.Lines[2]);
  Options.Ini.SetString('SummaryInfo', 'Comment4', mComments.Lines[3]);
  Options.Ini.SetString('SummaryInfo', 'Comment5', mComments.Lines[4]);
  Options.Ini.SetString('SummaryInfo', 'Comment6', mComments.Lines[5]);
  Options.Ini.SetString('SummaryInfo', 'Comment7', mComments.Lines[6]);
  Options.Ini.SetString('SummaryInfo', 'Comment8', mComments.Lines[7]);
  Options.Ini.SetString('SummaryInfo', 'Comment9', mComments.Lines[8]);
  Options.Ini.SetString('SummaryInfo', 'Comment10', mComments.Lines[9]);

  Options.Ini.SetString('SummaryInfo', 'ClubID', edClubID.Text);
  Options.Ini.SetString('SummaryInfo', 'ClubName', edClubName.Text);

  Options.Ini.SetString('SummaryInfo', 'Oath1', mOath.Lines[0]);
  Options.Ini.SetString('SummaryInfo', 'Oath2', mOath.Lines[1]);
  Options.Ini.SetString('SummaryInfo', 'Oath3', mOath.Lines[2]);
  Options.Ini.SetString('SummaryInfo', 'Oath4', mOath.Lines[3]);
  Options.Ini.SetString('SummaryInfo', 'Oath5', mOath.Lines[4]);

end;

procedure TELogJapanese.btnCancelClick(Sender: TObject);
begin
  Close;
end;

end.
