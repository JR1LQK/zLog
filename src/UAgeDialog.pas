unit UAgeDialog;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAgeDialog = class(TForm)
    OKBtn: TButton;
    Bevel2: TBevel;
    Edit1: TEdit;
    Label1: TLabel;
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AgeDialog: TAgeDialog;

implementation

uses UOptions;

{$R *.DFM}


procedure TAgeDialog.OKBtnClick(Sender: TObject);
begin
  Options.Settings._age := Edit1.Text;
  Close;
end;

procedure TAgeDialog.FormShow(Sender: TObject);
begin
  Edit1.SetFocus;
end;

end.
