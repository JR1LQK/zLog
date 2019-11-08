unit UClusterCOMSet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TformClusterCOMSet = class(TForm)
    Bevel1: TBevel;
    comboLineBreak: TComboBox;
    checkLocalEcho: TCheckBox;
    buttonOK: TButton;
    buttonCancel: TButton;
    comboBaudRate: TComboBox;
    Label35: TLabel;
    Label1: TLabel;
  private
    { Private declarations }
    function GetBaudRate(): Integer;
    procedure SetBaudRate(v: Integer);
    function GetLineBreak(): Integer;
    procedure SetLineBreak(v: Integer);
    function GetLocalEcho(): Boolean;
    procedure SetLocalEcho(v: Boolean);
  public
    { Public declarations }
    property BaudRate: Integer read GetBaudRate write SetBaudRate;
    property LineBreak: Integer read GetLineBreak write SetLineBreak;
    property LocalEcho: Boolean read GetLocalEcho write SetLocalEcho;
  end;

implementation

{$R *.DFM}

function TformClusterCOMSet.GetBaudRate(): Integer;
begin
   Result := comboBaudRate.ItemIndex;
end;

procedure TformClusterCOMSet.SetBaudRate(v: Integer);
begin
   comboBaudRate.ItemIndex := v;
end;

function TformClusterCOMSet.GetLineBreak(): Integer;
begin
   Result := comboLineBreak.ItemIndex;
end;

procedure TformClusterCOMSet.SetLineBreak(v: Integer);
begin
   comboLineBreak.ItemIndex := v;
end;

function TformClusterCOMSet.GetLocalEcho(): Boolean;
begin
   Result := checkLocalEcho.Checked;
end;

procedure TformClusterCOMSet.SetLocalEcho(v: Boolean);
begin
   checkLocalEcho.Checked := v;
end;

end.
