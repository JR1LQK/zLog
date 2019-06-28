unit UQuickRef;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TQuickRef = class(TForm)
    Memo: TMemo;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FormCreate(Sender: TObject);
    procedure MemoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  QuickRef: TQuickRef;

implementation

uses Main;

{$R *.dfm}

procedure TQuickRef.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TQuickRef.FormCreate(Sender: TObject);
begin
  if FileExists('ZLOGHELP.TXT') then
    begin
     Memo.Lines.LoadFromFile('ZLOGHELP.TXT');
    end
  else
     Memo.Lines.Clear;
end;

procedure TQuickRef.MemoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr($1B) then
    MainForm.LastFocus.SetFocus;
end;

end.
