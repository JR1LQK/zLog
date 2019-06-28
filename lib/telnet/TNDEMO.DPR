program tndemo;

uses
  Forms,
  tndemo1 in 'tndemo1.pas' {TnDemoForm};

{$R *.RES}

begin
  Application.CreateForm(TTnDemoForm, TnDemoForm);
  Application.Run;
end.
