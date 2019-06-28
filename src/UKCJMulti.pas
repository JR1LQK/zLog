unit UKCJMulti;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicMulti, Grids, Aligrid, StdCtrls, ExtCtrls, zLogGlobal{, Grids, StrCGrid};

const maxindex = 70;

const KenNames : array[0..maxindex] of string[15] =
('SY �@�J','RM ���G','KK ���','AB �ԑ�','SC ��m','IS �Ύ�','NM ����',
 'SB ��u','TC �\��','KR ���H','HD ����','IR �_�U','HY �O�R','OM �n��',
 'AM �X','IT ���','AT �H�c','YM �R�`','MG �{��','FS ����','NI �V��',
 'NN ����','TK ����','KN �_�ސ�','CB ��t','ST ���','IB ���','TG �Ȗ�',
 'GM �Q�n','YN �R��','OH �哇','MY �O��','HJ ����',
 'SO �É�','GF ��','AC ���m','ME �O�d','KT ���s',
 'SI ����','NR �ޗ�','OS ���','WK �a�̎R','HG ����','TY �x�R','FI ����',
 'IK �ΐ�','OY ���R','SN ����','YG �R��','TT ����','HS �L��','KA ����',
 'TS ����','EH ���Q','KC ���m','FO ����','SG ����','NS ����','KM �F�{',
 'OT �啪','MZ �{��','KG ������','TM �Δn','ON ����','OG ���}��',
 'AS �A�W�A','NA �k�A�����J','SA ��A�����J','EU ���[���b�p','AF �A�t���J',
 'OC �I�Z�A�j�A');

type
  TKCJMulti = class(TBasicMulti)
    Grid: TStringAlignGrid;
    Panel1: TPanel;
    Button1: TButton;
    cbStayOnTop: TCheckBox;
    combBand: TComboBox;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure combBandChange(Sender: TObject);
    procedure cbStayOnTopClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    MultiArray : array[b19..b50, 0..maxindex] of boolean;
    procedure UpdateBand(B : TBand);
    procedure Update; override;
    procedure AddNoUpdate(var aQSO : TQSO); override;
    procedure Reset; override;
    procedure CheckMulti(aQSO : TQSO); override;
    function ValidMulti(aQSO : TQSO) : boolean; override;
  end;


var
  KCJMulti: TKCJMulti;

implementation

uses Main, UKCJZone;

{$R *.DFM}

function GetCurrentBand : TBand;
begin
  Result := b19;
  case KCJMulti.combBand.ItemIndex of
    0 : Result := b19;
    1 : Result := b35;
    2 : Result := b7;
    3 : Result := b14;
    4 : Result := b21;
    5 : Result := b28;
    6 : Result := b50;
  end;
end;

function KCJCode(S : string) : integer;
var i : integer;
begin
  Result := -1;
  if length(S) = 2 then
    begin
      for i := 0 to maxindex do
        if pos(S, KenNames[i]) = 1 then
          begin
            Result := i;
            exit;
          end;
    end;
end;

function WorkedColor(Worked : boolean) : TColor;
begin
  if Worked then
    Result := clRed
  else
    Result := clBlack;
end;

procedure TKCJMulti.UpdateBand(B : TBand);
var i : integer;
begin
  for i := 0 to maxindex do
    begin
      case i of
        0..6   : Grid.CellFont[0, i+1].Color := WorkedColor(MultiArray[B,i]);
        7..13  : Grid.CellFont[1, i-6].Color := WorkedColor(MultiArray[B,i]);
        14..19 : Grid.CellFont[2, i-13].Color := WorkedColor(MultiArray[B,i]);
        20..21 : Grid.CellFont[3, i-19].Color := WorkedColor(MultiArray[B,i]);
        22..32 : Grid.CellFont[4, i-21].Color := WorkedColor(MultiArray[B,i]);
        33..36 : Grid.CellFont[5, i-32].Color := WorkedColor(MultiArray[B,i]);
        37..42 : Grid.CellFont[6, i-36].Color := WorkedColor(MultiArray[B,i]);
        43..45 : Grid.CellFont[7, i-42].Color := WorkedColor(MultiArray[B,i]);
        46..50 : Grid.CellFont[8, i-45].Color := WorkedColor(MultiArray[B,i]);
        51..54 : Grid.CellFont[9, i-50].Color := WorkedColor(MultiArray[B,i]);
        55..63 : Grid.CellFont[10, i-54].Color := WorkedColor(MultiArray[B,i]);
        64..70 : Grid.CellFont[11, i-63].Color := WorkedColor(MultiArray[B,i]);
      end;
    end;
  Grid.ClearSelection;
end;

procedure TKCJMulti.Update;
var B : TBand;
begin
  B := Main.CurrentQSO.QSO.Band;
  case B of
    b19 : combBand.ItemIndex := 0;
    b35 : combBand.ItemIndex := 1;
    b7  : combBand.ItemIndex := 2;
    b14 : combBand.ItemIndex := 3;
    b21 : combBand.ItemIndex := 4;
    b28 : combBand.ItemIndex := 5;
    b50 : combBand.ItemIndex := 6;
  else
    begin
      B := b19;
      combBand.ItemIndex := 0;
    end;
  end;
  UpdateBand(B);
  if KCJZone.Visible then
    KCJZone.Update;
end;

procedure TKCJMulti.AddNoUpdate(var aQSO : TQSO);
var str : string;
    K : integer;
    B : TBand;
    i : integer;
begin
  aQSO.QSO.NewMulti1 := False;
  str := aQSO.QSO.NrRcvd;
  //Delete(str,length(str),1);
  aQSO.QSO.Multi1 := str;

  if aQSO.QSO.Dupe then
    exit;

  if not(NotWARC(aQSO.QSO.Band)) then
    exit;

  K := KCJCode(str);
  if K = -1 then
    exit;

  if MultiArray[aQSO.QSO.band, K] = False then
    begin
      MultiArray[aQSO.QSO.band, K] := True;
      aQSO.QSO.NewMulti1 := True;
    end;
end;

function TKCJMulti.ValidMulti(aQSO : TQSO) : boolean;
var str : string;
begin
  str := aQSO.QSO.NrRcvd;
  Result := (KCJCode(str) >= 0)
end;


procedure TKCJMulti.Reset;
var i : integer;
    B : TBand;
begin
  for i := 0 to maxindex do
    for B := b19 to b50 do
      MultiArray[B, i] := false;
end;

procedure TKCJMulti.CheckMulti(aQSO : TQSO);
var str : string;
    M : integer;
    B : TBand;
begin
  str := aQSO.QSO.NrRcvd;

  if str = '' then
    exit;

  M := KCJCode(str);

  if M = -1 then
    begin
      MainForm.WriteStatusLine('Invalid number', false);
      exit;
    end;

  str := KenNames[M];
  if MultiArray[aQSO.QSO.band,M] = True then
    str := str + '   Worked on this band. Worked on : '
  else
    str := str + '   Needed on this band. Worked on : ';

  for B := b19 to b50 do
    if MultiArray[B, M] then
      str := str + MHzString[B]+' '
    else
      str := str + '';
  MainForm.WriteStatusLine(str, false);

end;


procedure TKCJMulti.FormCreate(Sender: TObject);
var x, i, j, k : word;
begin
  inherited;
  Reset;
  combBand.ItemIndex := 0;
  //Update;
end;




procedure TKCJMulti.Button1Click(Sender: TObject);
begin
  //inherited;
  Close;
end;

procedure TKCJMulti.combBandChange(Sender: TObject);
begin
  UpdateBand(GetCurrentBand);
end;

procedure TKCJMulti.cbStayOnTopClick(Sender: TObject);
begin
  if cbStayOnTop.Checked then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;


procedure TKCJMulti.Button2Click(Sender: TObject);
begin
  KCJZone.Show;
end;

end.
