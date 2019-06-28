program SockTest;

uses
  Forms,
  Sock,
  Main in 'Main.pas' {Frm_Main};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Socket Tester';
  Application.CreateForm(TFrm_Main, Frm_Main);
  Application.Run;
end.
