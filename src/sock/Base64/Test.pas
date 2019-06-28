unit Test;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrm_Test = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Test: TFrm_Test;

implementation

Uses Sock;

{$R *.DFM}

procedure TFrm_Test.Button1Click(Sender: TObject);
begin
   Memo2.Text := Base64Encode(Memo1.Text);
end;

procedure TFrm_Test.Button2Click(Sender: TObject);
begin
   Memo1.Text := Base64Decode(Memo2.Text);
end;

end.
