program server5;

uses
  Forms,
  srv5 in 'srv5.pas' {ServerForm};

{$R *.RES}

begin
  Application.CreateForm(TServerForm, ServerForm);
  Application.Run;
end.
