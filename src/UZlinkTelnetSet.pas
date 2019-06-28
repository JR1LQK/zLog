unit UZlinkTelnetSet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UClusterTelnetSet, StdCtrls, ExtCtrls, Spin;

type
  TZLinkTelnetSet = class(TClusterTelnetSet)
  private
    { Private declarations }
  public
    procedure SetVisuals; override;
    { Public declarations }
  end;

var
  ZLinkTelnetSet: TZLinkTelnetSet;

implementation

uses UOptions;

{$R *.DFM}

procedure TZLinkTelnetSet.SetVisuals;
begin
  HostName.Text := Options.Settings._zlinkhost;
  LineBreak.ItemIndex := Options.Settings._zlinklinebreakTELNET;
  LocalEcho.Checked := Options.Settings._zlinklocalechoTELNET;
end;

end.
