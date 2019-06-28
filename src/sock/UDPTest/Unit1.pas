unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Sock;

type
  TForm1 = class(TForm)
    Sock1: TSock;
    Memo1: TMemo;
    Memo2: TMemo;
    Edit2: TEdit;
    Label2: TLabel;
    Label1: TLabel;
    Lbl_From: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Sock1Read(Sender: TObject; Count: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
   Sock1.open;
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin
   Sock1.SendDatagram(Memo1.Text, edit2.text);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
   sock1.hostname := edit2.text;
end;

procedure TForm1.Sock1Read(Sender: TObject; Count: Integer);
Var Addr : String;
begin
   Memo2.Text := Sock1.ReceiveDatagram(Addr);
   Lbl_From.Caption := Addr;
end;

end.
