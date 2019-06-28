unit UZlinkComSet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UClusterCOMSet, StdCtrls, ExtCtrls;

type
  TZLinkCOMSet = class(TClusterCOMSet)
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetVisuals; override;
  end;

var
  ZLinkCOMSet: TZLinkCOMSet;

implementation

uses UOptions;

{$R *.DFM}

procedure TZLinkCOMSet.SetVisuals;
begin
  BaudCombo.ItemIndex := Options.Settings._zlinkbaud;
  LineBreak.ItemIndex := Options.Settings._zlinklinebreakCOM;
  LocalEcho.Checked := Options.Settings._zlinklocalechoCOM;
end;

end.
