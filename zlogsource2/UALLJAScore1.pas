unit UALLJAScore1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UBasicScore, zLogGlobal, StdCtrls, ExtCtrls;

type
  TALLJAScore1 = class(TBasicScore)
    Panel1: TPanel;
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
    TotalQSOLabel: TLabel;
    TotalMultiLabel: TLabel;
    Button1: TButton;
    TotalScoreLabel: TLabel;
    Label12: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    QSOLabels : array[b35..b50] of TLabel;
    MultiLabels : array[b35..b50] of TLabel;
  public
    { Public declarations }
    procedure Update; override;
    procedure AddNoUpdate(var aQSO : TQSO); override; {calculates points}
    procedure Add(var aQSO : TQSO); override; {calculates points}
    procedure Reset; override;
  end;

var
  ALLJAScore1: TALLJAScore1;

implementation

{$R *.DFM}
procedure TALLJAScore1.Update;
var B : TBand;
    TotQSO, TotMulti : LongInt;
begin
  TotQSO := 0; TotMulti := 0;
  for B := b35 to b50 do
    begin
      QSOLabels[B].Caption := IntToStr(QSO[B]);
      TotQSO := TotQSO + QSO[B];
      MultiLabels[B].Caption := IntToStr(Multi[B]);
      TotMulti := TotMulti + Multi[B];
    end;
  TotalQSOLabel.Caption := IntToStr(TotQSO);
  TotalMultiLabel.Caption := IntToStr(TotMulti);
  TotalScoreLabel.Caption := IntToStr(TotQSO*TotMulti);
end;

procedure TALLJAScore1.AddNoUpdate(var aQSO : TQSO);
var band : TBand;
begin
  inherited;
  band := aQSO.QSO.band;
  aQSO.QSO.points := 1;
  inc(Points[band]);
end;

procedure TALLJAScore1.Add(var aQSO : TQSO);
begin
  inherited;
end;

procedure TALLJAScore1.FormCreate(Sender: TObject);
var band : TBand;
begin
  inherited;
  for band := b35 to b50 do begin
    QSOLabels[band] := TLabel.Create(Self);
    QSOLabels[band].Parent := Panel1;
    QSOLabels[band].Left := 64;
    QSOLabels[band].Top := 28+16*(ord(band)-1);
    QSOLabels[band].Caption := '0';
    QSOLabels[band].Alignment := taRightJustify;
    MultiLabels[band] := TLabel.Create(Self);
    MultiLabels[band].Parent := Panel1;
    MultiLabels[band].Left := 104;
    MultiLabels[band].Top := 28+16*(ord(band)-1);
    MultiLabels[band].Caption := '0';
    MultiLabels[band].Alignment := taRightJustify;
  end;
  Update;
end;

procedure TALLJAScore1.Button1Click(Sender: TObject);
begin
  inherited;
  if Self.FormStyle = fsStayOnTop then
    begin
      Self.FormStyle := fsNormal;
      Button1.Caption := 'Stay on Top';
    end
  else
    begin
      Self.FormStyle := fsStayOnTop;
      Button1.Caption := 'Normal';
    end;
end;

procedure TALLJAScore1.Reset;
begin
  inherited;
end;

end.
