unit USummaryInfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, zLogGlobal, UOptions;

type
  TSummaryInfo = class(TForm)
    CategoryEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    NameEdit: TEdit;
    Label4: TLabel;
    ContestNameEdit: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label6: TLabel;
    RemMemo: TMemo;
    Label8: TLabel;
    CountryEdit: TEdit;
    Label5: TLabel;
    DecMemo: TMemo;
    Label9: TLabel;
    Label10: TLabel;
    MiscMemo: TMemo;
    AddrMemo: TMemo;
    CallEdit: TEdit;
    procedure FormShow(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure DecEnglish;
    procedure DecJapanese;
  end;

var
  SummaryInfo: TSummaryInfo;

implementation

{$R *.DFM}


procedure TSummaryInfo.DecEnglish;
begin
  DecMemo.Clear;
  DecMemo.Lines.Add('This is to certify that in this contest I have operated my transmitter');
  DecMemo.Lines.Add('within the limitations of my license and have fully observed the');
  DecMemo.Lines.Add('rules and regulations of the contest.');
end;

procedure TSummaryInfo.DecJapanese;
begin
  DecMemo.Clear;
  DecMemo.Lines.Add('私は、コンテスト規約および電波法令にしたがい運用した結果');
  DecMemo.Lines.Add('ここに提出するサマリーシートおよびログシートが事実と相違');
  DecMemo.Lines.Add('ないものであることを、私の名誉において誓います。');
end;

procedure TSummaryInfo.FormShow(Sender: TObject);
var str : string;
    i : integer;
    Y, M, D : word;
begin
  if Log.TotalQSO > 0 then
    DecodeDate(TQSO(Log.List[1]).QSO.Time, Y, M, D)
  else
    DecodeDate(Date, Y, M, D);
  if ContestNameEdit.Text = '' then
    ContestNameEdit.Text := TQSO(Log.List[0]).QSO.memo + ' ' + IntToStr(Y);
  if CallEdit.Text = '' then
    CallEdit.Text := Options.Settings._mycall;
  if Options.Settings._multiop > 0 then
    str := 'Multi-op '
  else
    str := 'Single-op ';
  if Options.Settings._band = 0 then
    str := str + 'All band '
  else
    str := str + BandString[TBand(Options.Settings._band - 1)] + ' ';
  case Options.Settings._mode of
    0 : str := str + 'Mixed';
    1 : str := str + 'CW';
    2 : str := str + 'Ph';
  end;
  if CategoryEdit.Text = '' then
    CategoryEdit.Text := str;
end;


procedure TSummaryInfo.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;


end.
