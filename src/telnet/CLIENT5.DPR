program client5;

uses
  Forms,
  cli5 in 'CLI5.PAS' {ClientForm};

{$R *.RES}

begin
  Application.CreateForm(TClientForm, ClientForm);
  Application.Run;
end.
