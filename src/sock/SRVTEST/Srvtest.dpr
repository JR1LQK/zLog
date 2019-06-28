program SrvTest;

uses
  Forms,
  srvr in 'srvr.pas' {Frm_Srvr};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Echo Server Test';
  Application.CreateForm(TFrm_Srvr, Frm_Srvr);
  Application.Run;
end.
