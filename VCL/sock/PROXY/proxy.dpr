program Proxy;

uses
  Forms,
  main in 'main.pas' {Frm_Main},
  ip in 'ip.pas' {Frm_IP};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Simple Proxy Server';
  Application.CreateForm(TFrm_Main, Frm_Main);
  Application.CreateForm(TFrm_IP, Frm_IP);
  Application.Run;
end.
