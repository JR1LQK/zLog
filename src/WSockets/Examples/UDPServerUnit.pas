unit UDPServerUnit;

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
    StatusBar1: TStatusBar;
    procedure Edit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    UDPServer1: TUDPServer;
    procedure UDPServer1Error(Sender: TObject; Error: integer; Msg: string);
    procedure UDPServer1Data(Sender: TObject; Socket: TSocket);
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

procedure TForm1.UDPServer1Error(Sender: TObject; Error: integer; Msg: string);
begin
  MessageDlg(Msg, mtError, [mbOK], 0);
end;

procedure TForm1.UDPServer1Data(Sender: TObject; Socket: TSocket);
var
  Data: string;
  SockAddrIn: TSockAddrIn;
begin
  with UDPServer1 do
    begin
      Data:= Read(Socket, SockAddrIn);
      TTY('<'+SockAddrInToAddress(SockAddrIn)+':'+SockAddrInToPort(SockAddrIn)+'> '+Data);
      Write(Socket, '<SERVER-ECHO> '+Data, SockAddrIn);
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  UDPServer1:= TUDPServer.Create(Self);
  with UDPServer1 do
    begin
      OnError:= UDPServer1Error;
      OnData:= UDPServer1Data;
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
  UDPServer1.Free;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  Button1.Enabled:= (Edit1.Text <> '');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  with UDPServer1 do
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
  UDPServer1.Close;
  Edit1.Enabled:= true;
  Button1.Enabled:= true;
  Button2.Enabled:= false;
  Memo1.Lines.Clear;
  StatusBar1.SimpleText:= '';
end;

end.
