program Project1;

uses
  Forms,
  ccczlogconv in 'ccczlogconv.pas' {Form1},
  zLogGlobal in 'zLogGlobal.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
