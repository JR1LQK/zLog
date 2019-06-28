program testscope;

uses
  Forms,
  testmain in 'testmain.pas' {Form1},
  ubandscope in 'ubandscope.pas' {BandScope},
  UMinMaxFreqDlg in 'UMinMaxFreqDlg.pas' {MinMaxFreqDlg};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TBandScope, BandScope);
  Application.CreateForm(TMinMaxFreqDlg, MinMaxFreqDlg);
  Application.Run;
end.
