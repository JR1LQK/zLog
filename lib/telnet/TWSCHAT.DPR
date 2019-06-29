program twschat;

uses
  Forms,
  twschat1 in 'twschat1.pas' {TWSChatForm};

{$R *.RES}

begin
  Application.CreateForm(TTWSChatForm, TWSChatForm);
  Application.Run;
end.
