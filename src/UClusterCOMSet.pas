unit UClusterCOMSet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TClusterCOMSet = class(TForm)
    Bevel1: TBevel;
    LineBreak: TComboBox;
    LocalEcho: TCheckBox;
    OKBtn: TButton;
    CancelBtn: TButton;
    BaudCombo: TComboBox;
    Label35: TLabel;
    Label1: TLabel;
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetVisuals; virtual;
    { Public declarations }
  end;

var
  ClusterCOMSet: TClusterCOMSet;

implementation

uses UOptions;

{$R *.DFM}

procedure TClusterCOMSet.SetVisuals;
begin
  BaudCombo.ItemIndex := Options.Settings._clusterbaud;
  LineBreak.ItemIndex := Options.Settings._clusterlinebreakCOM;
  LocalEcho.Checked := Options.Settings._clusterlocalechoCOM;
end;


procedure TClusterCOMSet.OKBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TClusterCOMSet.CancelBtnClick(Sender: TObject);
begin
  SetVisuals;
  Close;
end;

procedure TClusterCOMSet.FormShow(Sender: TObject);
begin
  {SetVisuals;}
end;

end.
