unit UClusterTelnetSet;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Spin;

type
  TClusterTelnetSet = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    HostName: TComboBox;
    LineBreak: TComboBox;
    LocalEcho: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    spPortNumber: TSpinEdit;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetVisuals; virtual;
    { Public declarations }
  end;

var
  ClusterTelnetSet: TClusterTelnetSet;

implementation

uses UOptions;

{$R *.DFM}


procedure TClusterTelnetSet.SetVisuals;
begin
  HostName.Text := Options.Settings._clusterhost;
  LineBreak.ItemIndex := Options.Settings._clusterlinebreakTELNET;
  LocalEcho.Checked := Options.Settings._clusterlocalechoTELNET;
  sPportNumber.Value := Options.Settings._clustertelnetport;
end;

procedure TClusterTelnetSet.FormShow(Sender: TObject);
begin
  {SetVisuals;}
end;

procedure TClusterTelnetSet.CancelBtnClick(Sender: TObject);
begin
  SetVisuals;
  Close;
end;

procedure TClusterTelnetSet.OKBtnClick(Sender: TObject);
begin
  Close;
end;

end.
