program Demo;

uses
  Forms,
  DemoForm1 in 'DemoForm1.pas' {MainfForm},
  DemoForm2 in 'DemoForm2.pas' {PaperSizeForm},
  DemoForm3 in 'DemoForm3.pas' {PrintQualityForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainfForm, MainfForm);
  Application.CreateForm(TPaperSizeForm, PaperSizeForm);
  Application.CreateForm(TPrintQualityForm, PrintQualityForm);
  Application.Run;
end.
