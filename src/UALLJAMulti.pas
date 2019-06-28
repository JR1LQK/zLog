unit UALLJAMulti;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, ComCtrls, zLogGlobal, UBasicMulti, JLLabel;

type

  TKen = (m101,m102,m103,m104,m105,m106,m107,m108,
  m109,m110,m111,m112,m113,m114,
  m02,m03,m04,m05,m06,m07,m08,m09,m10,m11,
  m12,m13,m14,m15,m16,m17,m18,m19,m20,m21,
  m22,m23,m24,m25,m26,m27,m28,m29,m30,m31,
  m32,m33,m34,m35,m36,m37,m38,m39,m40,m41,
  m42,m43,m44,m45,m46,m47,m48,m49,m50);

  TALLJAMulti = class(TBasicMulti)
    PageControl: TPageControl;
    Tab35: TTabSheet;
    Tab7: TTabSheet;
    Tab14: TTabSheet;
    Tab21: TTabSheet;
    Tab28: TTabSheet;
    Tab50: TTabSheet;
    TabALL: TTabSheet;
    Panel: TPanel;
    RotateLabel2: TRotateLabel;
    RotateLabel3: TRotateLabel;
    RotateLabel4: TRotateLabel;
    RotateLabel5: TRotateLabel;
    RotateLabel6: TRotateLabel;
    RotateLabel7: TRotateLabel;
    ListBox: TListBox;
    Panel1: TPanel;
    Button2: TButton;
    cbStayOnTop: TCheckBox;
    procedure PageControlChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbStayOnTopClick(Sender: TObject);
  private
    KenLabels : array[b35..b50,m101..m50] of TLabel;
    MultiTable : array[b35..b50,m101..m50] of boolean;

   { Private declarations }
  public
    procedure UpdateBand(B : TBand);
    procedure Update; override;
    procedure AddNoUpdate(var aQSO : TQSO); override;
    procedure Add(var aQSO : TQSO); override;
    procedure Reset; override;
    function ValidMulti(aQSO : TQSO) : boolean; override;
    procedure CheckMulti(aQSO : TQSO); override;
    function ExtractMulti(aQSO : TQSO) : string; override;
    function IsNewMulti(aQSO : TQSO) : boolean; override;
    procedure SetNumberEditFocus; override;
    { Public declarations }
  end;

const KenNames : array[m101..m50] of string[15] =
('101 �@�J','102 ���G','103 ���','104 �ԑ�','105 ��m','106 �Ύ�','107 ����',
 '108 ��u','109 �\��','110 ���H','111 ����','112 �_�U','113 �O�R','114 �n��',
 '02  �X','03  ���','04  �H�c','05  �R�`','06  �{��','07  ����','08  �V��',
 '09  ����','10  ����','11  �_�ސ�','12  ��t','13  ���','14  ���','15  �Ȗ�',
 '16  �Q�n','17  �R��','18  �É�','19  ��','20  ���m','21  �O�d','22  ���s',
 '23  ����','24  �ޗ�','25  ���','26  �a�̎R','27  ����','28  �x�R','29  ����',
 '30  �ΐ�','31  ���R','32  ����','33  �R��','34  ����','35  �L��','36  ����',
 '37  ����','38  ���Q','39  ���m','40  ����','41  ����','42  ����','43  �F�{',
 '44  �啪','45  �{��','46  ������','47  ����','48  ���}��','49  ���m����',
 '50  �쒹��');
var
  ALLJAMulti: TALLJAMulti;

implementation

uses Main;

{$R *.DFM}

procedure TALLJAMulti.UpdateBand(B : TBand);
var K : TKen;
begin
  for K := m101 to m50 do
    if MultiTable[B, K] then
      KenLabels[B, K].Font.Color := clRed
    else
      KenLabels[B, K].Font.Color := clBlack;
end;

procedure TALLJAMulti.Update;
var band, B : TBand;
    str : string;
    K : TKen;
begin
  //inherited;
  band := Main.CurrentQSO.QSO.Band;
  if not(band in [b35, b7, b14, b21, b28, b50]) then
    band := b35;
  if PageControl.ActivePage <> TabAll then
    begin
      PageControl.ActivePage := PageControl.Pages[OldBandOrd(band)-1];
      UpdateBand(band);
    end
  else
    begin
      for K := m101 to m50 do
        begin
          str := FillRight(KenNames[K],14);
          for B := b35 to b50 do
            if NotWARC(B) then
              if MultiTable[B,K] then
                str := str + '* '
              else
                str := str + '. ';
          ListBox.Items[ord(K)] := str;
        end;
    end;
end;

function TALLJAMulti.ExtractMulti(aQSO : TQSO) : string;
var str : string;
begin
  Result := '';
  str := aQSO.QSO.NrRcvd;
  if str = '' then
    exit;
  if not(str[length(str)] in ['0'..'9']) then
    Delete(str, length(str),1);
  Result := str;
end;

procedure TALLJAMulti.AddNoUpdate(var aQSO : TQSO);
var str : string;
    M : integer;
    K : TKen;
    B : TBand;
    i : integer;
begin
  aQSO.QSO.NewMulti1 := False;
  str := aQSO.QSO.NrRcvd;
  Delete(str,length(str),1);
  aQSO.QSO.Multi1 := str;

  if aQSO.QSO.Dupe then
    exit;

  if not(NotWARC(aQSO.QSO.Band)) then
    exit;
  M := 0;
  try
    M := StrToInt(str);
  except
    on EConvertError do M := 0;
  end;
  case M of
    101..114 : K := TKen(M-101);
    2..50 :    K := TKen(M - 2 + ord(m02));
  else
    exit;
  end;
  if MultiTable[aQSO.QSO.band,K] = False then
    begin
      MultiTable[aQSO.QSO.band,K] := True;
      aQSO.QSO.NewMulti1 := True;
    end;
end;

procedure TALLJAMulti.Add(var aQSO : TQSO);
begin
  inherited;
end;

procedure TALLJAMulti.PageControlChange(Sender: TObject);
begin
  case PageControl.ActivePage.Tag of
    ord(b35)..ord(b50) : UpdateBand(TBand(PageControl.ActivePage.Tag));
  else
    Update;
  end;
end;

procedure TALLJAMulti.FormCreate(Sender: TObject);
var band : TBand;
    ken : TKen;
    x, y : integer;
begin
  for band := b35 to b50 do
    begin
      for ken := m101 to m50 do
        begin
          MultiTable[band, ken] := false;
        end;
      if NotWARC(band) then
        for x := 1 to 5 do
          for y := 1 to 16 do
            begin
              ken := TKen(16*(x-1)+y-1);
                if ken <= m50 then
                  begin
                    KenLabels[band,ken] := TLabel.Create(Self);
                    KenLabels[band,ken].Font.Size := 9;
                    KenLabels[band,ken].ParentFont := True;
                    KenLabels[band,ken].Parent := PageControl.Pages[OldBandOrd(band)-1];
                    {if MultiTable[TBand(PageControl.ActivePage.Tag),ken] then
                      KenLabels[band,ken].Font.Color := clRed
                    else}
                    KenLabels[band,ken].Font.Color := clBlack;
                    KenLabels[band,ken].Left := 77*(x-1) + 8;
                    KenLabels[band,ken].Top := 8+16*(y-1);
                    KenLabels[band,ken].Caption := KenNames[ken];
                  end;
            end;
    end;

  for ken := m101 to m50 do
    begin
      ListBox.Items.Add(FillRight(KenNames[ken],14)+'. . . . . . ');
    end;

    {Label1.caption := KenLabels[b35,m10].Font.name;}
end;

procedure TALLJAMulti.Reset;
var band : TBand;
    ken : TKen;
begin
  for band := b35 to b50 do
    if NotWARC(band) then
      for ken := m101 to m50 do
        begin
          MultiTable[band, ken] := false;
          //KenLabels[band, ken].Font.Color := clBlack;
        end;
  {ListBox.Items.Clear;
  for ken := m101 to m50 do
    begin
      ListBox.Items.Add(FillRight(KenNames[ken],14)+'. . . . . . ');
    end;}
end;

function TALLJAMulti.ValidMulti(aQSO : TQSO) : boolean;
var str : string;
    M : integer;
    K : TKen;
begin
  Result := False;
  str := aQSO.QSO.NrRcvd;
  if not(length(str) in [3..4]) then
    exit;
  if not(str[length(str)] in ['P','L','M','H']) then
    exit;
  Delete(str, length(str), 1);
  M := 0;
  try
    M := StrToInt(str);
  except
    on EConvertError do M := 0;
  end;
  if M in [2..50, 101..114] then
    Result := True
  else
    Result := False;
end;


procedure TALLJAMulti.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TALLJAMulti.FormShow(Sender: TObject);
begin
  inherited;
  if Main.CurrentQSO.QSO.Band in [b35, b7, b14, b21, b28, b50] then
    PageControl.ActivePage := PageControl.Pages[OldBandOrd(Main.CurrentQSO.QSO.band)-1];
end;


function TALLJAMulti.IsNewMulti(aQSO : TQSO) : boolean;
var M : integer;
    K : TKen;
    B : TBand;
    str : string;
begin
  Result := False;
  str := aQSO.QSO.NrRcvd;
  if str = '' then
    exit;
  if str[length(str)] in ['P', 'L', 'M', 'H'] then
    Delete(str,length(str),1);
  M := 0;
  try
    M := StrToInt(str);
  except
    on EConvertError do M := 0;
  end;
  case M of
    101..114 : K := TKen(M-101);
    2..50 :    K := TKen(M - 2 + ord(m02));
  else
    begin
      exit;
    end;
  end;

  if MultiTable[aQSO.QSO.band,K] = False then
    Result := True;

end;

procedure TALLJAMulti.CheckMulti(aQSO : TQSO);
var str : string;
    M : integer;
    K : TKen;
    B : TBand;
begin
  str := aQSO.QSO.NrRcvd;

  if str = '' then
    exit;

  if str[length(str)] in ['P', 'L', 'M', 'H'] then
    Delete(str,length(str),1);
  M := 0;
  try
    M := StrToInt(str);
  except
    on EConvertError do M := 0;
  end;
  case M of
    101..114 : K := TKen(M-101);
    2..50 :    K := TKen(M - 2 + ord(m02));
  else
    begin
      MainForm.WriteStatusLine('Invalid number', false);
      exit;
    end;
  end;


  str := KenNames[K];
  if MultiTable[aQSO.QSO.band,K] = True then
    str := str + '   Worked on this band. Worked on : '
  else
    str := str + '   Needed on this band. Worked on : ';

  for B := b35 to b50 do
    if MultiTable[B,K] then
      str := str + MHzString[B]+' '
    else
      str := str + '';
  MainForm.WriteStatusLine(str, false);

end;

procedure TALLJAMulti.cbStayOnTopClick(Sender: TObject);
begin
  if cbStayOnTop.Checked then
    Self.FormStyle := fsStayOnTop
  else
    Self.FormStyle := fsNormal;
end;

procedure TALLJAMulti.SetNumberEditFocus;
begin
  SetNumberEditFocusJARL;
end;

initialization
end.
