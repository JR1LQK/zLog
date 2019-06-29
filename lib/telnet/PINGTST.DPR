program PingTst;

uses
  Forms,
  PingTst1 in 'PingTst1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TPingTstForm, PingTstForm);
  Application.Run;
end.
