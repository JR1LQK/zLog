unit UAbout;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, zLogGlobal, BGK32LIB;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    OKButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure OKButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutBox.FormShow(Sender: TObject);
var temp : string;
begin
  Label2.Caption := TQSO(Log.List[0]).QSO.memo;
  Str(BGK32LIB.GetVersion : 3:2, temp);
  //BGK32DLL.Caption := 'BGK32.DLL version '+temp;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
{$ifdef w95}
  Version.Caption := Version.Caption + ' /w95';
{$endif}
end;

end.

