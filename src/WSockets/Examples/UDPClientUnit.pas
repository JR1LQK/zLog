unit UDPClientUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WSockets, WinSock, StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label3: TLabel;
    Edit3: TEdit;
    Button3: TButton;
    StatusBar1: TStatusBar;
    procedure Edit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    UDPClient1: TUDPClient;
    procedure UDPClient1Error(Sender: TObject; Error: integer; Msg: string);
    procedure UDPClient1Data(Sender: TObject; Socket: TSocket);
  public
    { Public declarations }
    procedure TTY(Msg: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.TTY(Msg: string);
begin
  with Memo1.Lines do
    begin
      if Count > 100 then
        Delete(0);
      Add(Msg);
    end;
end;

procedure TForm1.UDPClient1Error(Sender: TObject; Error: integer; Msg: string);
begin
  MessageDlg(Msg, mtError, [mbOK], 0);
end;

procedure TForm1.UDPClient1Data(Sender: TObject; Socket: TSocket);
begin
  TTY(UDPClient1.Read);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  UDPClient1:= TUDPClient.Create(Self);
  with UDPClient1 do
    begin
      OnError:= UDPClient1Error;
      OnData:= UDPClient1Data;
      TTY('WinSocket Version: '+Version);
      TTY('Description: '+Description);
      TTY('SystemStatus: '+SystemStatus);
      TTY(IntToStr(MaxUDPSize));
      TTY('');
      TTY('Local Host Name: '+LocalHostName);
      TTY('Local Host Address: '+LocalHostAddress);
      TTY('');
    end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  UDPClient1.Free;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  Button1.Enabled:= (Edit1.Text <> '') and (Edit2.Text <> '');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  with UDPClient1 do
    begin
      Host:= Edit1.Text;
      Port:= Edit2.Text;
      Open;
      if SocketState = ssOpen then
        begin
          Edit1.Enabled:= false;
          Edit2.Enabled:= false;
          Button1.Enabled:= false;
          Button2.Enabled:= true;
          Button3.Enabled:= true;
          Memo1.Lines.Clear;
          StatusBar1.SimpleText:= 'Opened on local port '+SocketToPort(LocalSocket);
        end;
    end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  UDPClient1.Close;
  Edit1.Enabled:= true;
  Edit2.Enabled:= true;
  Button1.Enabled:= true;
  Button2.Enabled:= false;
  Button3.Enabled:= false;
  Memo1.Lines.Clear;
  StatusBar1.SimpleText:= '';
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  UDPClient1.Write(Edit3.Text);
end;

end.
