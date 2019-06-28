program P2;

uses
  Forms,
  U3 in 'U3.PAS' {Form2};

{$R *.RES}

begin
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
