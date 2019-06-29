program Test;

uses
  Forms,
  Test1 in 'TEST1.PAS' {Form1};

{$R *.RES}


begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
