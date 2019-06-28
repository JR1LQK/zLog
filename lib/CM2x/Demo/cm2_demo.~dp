program cm2_demo;

uses
  Forms,
  cm_pasc in 'cm_pasc.pas' {FrmPascalDemo},
  cm_html in 'cm_html.pas' {FrmHTMLDemo},
  Main in 'Main.pas' {MainForm},
  cm_even in 'cm_even.pas' {FrmEventsDemo},
  cm_hyper in 'cm_hyper.pas' {FrmHyperTextDemo};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFrmPascalDemo, FrmPascalDemo);
  Application.CreateForm(TFrmHTMLDemo, FrmHTMLDemo);
  Application.CreateForm(TFrmEventsDemo, FrmEventsDemo);
  Application.CreateForm(TFrmHyperTextDemo, FrmHyperTextDemo);
  Application.Run;
end.
