program Test64;

uses
  Forms,
  Test in 'Test.pas' {Frm_Test};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFrm_Test, Frm_Test);
  Application.Run;
end.
