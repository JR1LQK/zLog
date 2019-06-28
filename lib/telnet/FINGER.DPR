program Finger;

uses
  Forms,
  finger1 in 'FINGER1.PAS' {FingerDemoForm};

{$R *.RES}

begin
  Application.CreateForm(TFingerDemoForm, FingerDemoForm);
  Application.Run;
end.
