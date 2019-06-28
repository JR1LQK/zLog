program smtptst;

uses
  Forms,
  smtptst1 in 'smtptst1.pas' {SmtpTestForm};

{$R *.RES}

begin
  Application.CreateForm(TSmtpTestForm, SmtpTestForm);
  Application.Run;
end.
