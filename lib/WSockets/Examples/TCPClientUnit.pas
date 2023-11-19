unit TCPClientUnit;

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
    TCPClient1: TTCPClient;
    procedure TCPClient1Error(Sender: TObject; Error: integer; Msg: string);
    procedure TCPClient1Connect(Sender: TObject; Socket: TSocket);
    procedure TCPClient1Data(Sender: TObject; Socket: TSocket);
    procedure TCPClient1Close(Sender: TObject; Socket: TSocket);
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

procedure TForm1.TCPClient1Error(Sender: TObject; Error: integer; Msg: string);
begin
  MessageDlg(Msg, mtError, [mbOK], 0);
end;

procedure TForm1.TCPClient1Connect(Sender: TObject; Socket: TSocket);
begin
  Memo1.Lines.Clear;
  with TCPClient1 do
    begin
      StatusBar1.SimpleText:= 'Connected on local port '+SocketToPort(LocalSocket);
    end;
  Button3.Enabled:= true;
end;

procedure TForm1.TCPClient1Data(Sender: TObject; Socket: TSocket);
begin
  TTY(TCPClient1.Read);
end;

procedure TForm1.TCPClient1Close(Sender: TObject; Socket: TSocket);
begin
  TCPClient1.Close;
  Edit1.Enabled:= true;
  Edit2.Enabled:= true;
  Button1.Enabled:= true;
  Button2.Enabled:= false;
  Button3.Enabled:= false;
  //Memo1.Lines.Clear;
  StatusBar1.SimpleText:= 'Connection closed by server!';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TCPClient1:= TTCPClient.Create(Self);
  with TCPClient1 do
    begin
      OnError:= TCPClient1Error;
      OnConnect:= TCPClient1Connect;
      OnData:= TCPClient1Data;
      OnClose:= TCPClient1Close;
      TTY('WinSocket Version: '+Version);
      TTY('Description: '+Description);
      TTY('SystemStatus: '+SystemStatus);
      TTY('');
      TTY('Local Host Name: '+LocalHostName);
      TTY('Local Host Address: '+LocalHostAddress);
      TTY('');
    end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  TCPClient1.Free;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  Button1.Enabled:= (Edit1.Text <> '') and (Edit2.Text <> '');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  with TCPClient1 do
    begin
      Host:= Edit1.Text;
      Port:= Edit2.Text;
      StatusBar1.SimpleText:= 'Trying to connect to '+Host+' at port '+Port;
      Open;
      if SocketState = ssOpen then
        begin
          Edit1.Enabled:= false;
          Edit2.Enabled:= false;
          Button1.Enabled:= false;
          Button2.Enabled:= true;
        end;
    end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  TCPClient1.Close;
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
  TCPClient1.Write(Edit3.Text);
end;

end.
