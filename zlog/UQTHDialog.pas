unit UQTHDialog;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, UzLogGlobal;

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

{$R *.DFM}

procedure TQTHDialog.OKBtnClick(Sender: TObject);
begin
  dmZLogGlobal.Settings._prov := ProvEdit.Text;
  dmZLogGlobal.Settings._city := CityEdit.Text;
  dmZLogGlobal.Settings._cqzone := CQZoneEdit.Text;
  dmZLogGlobal.Settings._iaruzone := IARUZoneEdit.Text;
  dmZLogGlobal.SaveCurrentSettings; {Writes Settings to Inifile}
end;

procedure TQTHDialog.FormShow(Sender: TObject);
begin
  ProvEdit.Text := dmZLogGlobal.Settings._prov;
  CityEdit.Text := dmZLogGlobal.Settings._city;
  CQZoneEdit.Text := dmZLogGlobal.Settings._cqzone;
  IARUZoneEdit.Text := dmZLogGlobal.Settings._iaruzone;
end;

end.
