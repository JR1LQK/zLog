program Ftptst;

uses
  Forms,
  Ftptst1 in 'FTPTST1.PAS' {FtpReceiveForm},
  Ftptst2 in 'Ftptst2.pas' {DirectoryForm};

{$R *.RES}
 
begin
  Application.CreateForm(TFtpReceiveForm, FtpReceiveForm);
  Application.CreateForm(TDirectoryForm, DirectoryForm);
  Application.Run;
end.
