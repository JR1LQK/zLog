program Tnsrv;

uses
  Forms,
  Tnsrv1 in 'TNSRV1.PAS' {ServerForm},
  Tnsrv2 in 'TNSRV2.PAS' {ClientForm};

{$R *.RES}

begin
  Application.CreateForm(TServerForm, ServerForm);
  Application.Run;
end.
