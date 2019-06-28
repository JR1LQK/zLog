program HidClassDemo;

uses
  Forms,
  Unit1 in 'Unit1.pas' {HidClassDemoForm},
  SetupApi in '..\..\SetupApi.pas',
  Hid in '..\..\Hid.pas',
  HidControllerClass in '..\..\HidControllerClass.pas',
  DBT in '..\..\DBT.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(THidClassDemoForm, HidClassDemoForm);
  Application.Run;
end.
