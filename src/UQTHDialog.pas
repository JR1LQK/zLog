unit UQTHDialog;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls;

type
  TQTHDialog = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Label14: TLabel;
    Label18: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    ProvEdit: TEdit;
    CItyEdit: TEdit;
    CQZoneEdit: TEdit;
    IARUZoneEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  QTHDialog: TQTHDialog;

implementation

uses UOptions;

{$R *.DFM}



procedure TQTHDialog.OKBtnClick(Sender: TObject);
begin
  Options.Settings._prov := ProvEdit.Text;
  Options.Settings._city := CityEdit.Text;
  Options.Settings._cqzone := CQZoneEdit.Text;
  Options.Settings._iaruzone := IARUZoneEdit.Text;

  Options.ImplementSettings(False);
  Options.SaveCurrentSettings; {Writes Settings to Inifile}
end;

procedure TQTHDialog.FormShow(Sender: TObject);
begin
  ProvEdit.Text := Options.Settings._prov;
  CityEdit.Text := Options.Settings._city;
  CQZoneEdit.Text := Options.Settings._cqzone;
  IARUZoneEdit.Text := Options.Settings._iaruzone;
end;

end.
