program test_res;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  Vic_Res in 'Vic_Res.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
