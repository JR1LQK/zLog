unit TCPServerUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WSockets, WinSock, StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Button3: TButton;
    Edit3: TEdit;
    UpDown1: TUpDown;
    Label3: TLabel;
    StatusBar1: TStatusBar;
    procedure Edit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit3Exit(Sender: TObject);
  private
    { Private declarations }
    TCPServer1: TTCPServer;
    procedure TCPServer1Error(Sender: TObject; Error: integer; Msg: string);
    procedure TCPServer1Accept(Sender: TObject; Socket: TSocket);
    procedure TCPServer1Data(Sender: TObject; Socket: TSocket);
    procedure TCPServer1Close(Sender: TObject; Socket: TSocket);
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

procedure TForm1.TCPServer1Error(Sender: TObject; Error: integer; Msg: string);
begin
  MessageDlg(Msg, mtError, [mbOK], 0);
end;

procedure TForm1.TCPServer1Accept(Sender: TObject; Socket: TSocket);
begin
  with TCPServer1 do
    begin
      if Clients.Count > StrToInt(Edit3.Text) then
        begin
          Write(Socket, 'Sorry! TTCPServer Demo reached max client limit...');
          TTY('New connection rejected for '+PeerToAddress(Socket)+' on port '+PeerToPort(Socket));
          Disconnect(Socket);
        end
      else
        begin
          Write(Socket, 'Hello! Connection accepted by TTCPServer Demo');
          TTY('New connection accepted for '+PeerToAddress(Socket)+' on port '+PeerToPort(Socket));
          StatusBar1.SimpleText:= IntToStr(Clients.Count)+' Client(s) connected';
          Button3.Enabled:= true;
        end;
    end;
end;

procedure TForm1.TCPServer1Data(Sender: TObject; Socket: TSocket);
var
  Data: string;
begin
  with TCPServer1 do
    begin
      Data:= Read(Socket);
      TTY('<'+PeerToAddress(Socket)+':'+PeerToPort(Socket)+'> '+Data);
      Write(Socket, '<SERVER-ECHO> '+Data);
    end;
end;

procedure TForm1.TCPServer1Close(Sender: TObject; Socket: TSocket);
begin
  with TCPServer1 do
    begin
      TTY('Connection closed by '+PeerToAddress(Socket)+' on port '+PeerToPort(Socket));
      StatusBar1.SimpleText:= IntToStr(Clients.Count-1)+' Client(s) connected';
      Button3.Enabled:= (Clients.Count > 1);
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TCPServer1:= TTCPServer.Create(Self);
  with TCPServer1 do
    begin
      OnError:= TCPServer1Error;
      OnAccept:= TCPServer1Accept;
      OnData:= TCPServer1Data;
      OnClose:= TCPServer1Close;
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
  TCPServer1.Free;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  Button1.Enabled:= (Edit1.Text <> '');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  with TCPServer1 do
    begin
      Port:= Edit1.Text;
      Open;
      if SocketState = ssListening then
        begin
          Memo1.Lines.Clear;
          StatusBar1.SimpleText:= LocalHostAddress+' Listening on port: '+Port;
          Edit1.Enabled:= false;
          Button1.Enabled:= false;
          Button2.Enabled:= true;
        end;
    end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  TCPServer1.Close;
  Edit1.Enabled:= true;
  Button1.Enabled:= true;
  Button2.Enabled:= false;
  Button3.Enabled:= false;
  Memo1.Lines.Clear;
  StatusBar1.SimpleText:= '';
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i: integer;
begin
  with TCPServer1 do
    for i:= 0 to Clients.Count-1 do
      Write(Clients[i], Edit2.Text);
end;

procedure TForm1.Edit3Exit(Sender: TObject);
var
  i: integer;
begin
  try
    i:= StrToInt(Edit3.Text);
  except
    on EConvertError do
      Edit3.Text:= '1';
  end;
end;

end.
