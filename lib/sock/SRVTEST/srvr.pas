unit srvr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Sock, Winsock;

type
  TFrm_Srvr = class(TForm)
    Memo_Status: TMemo;
    Edit_Port: TEdit;
    Label1: TLabel;
    Btn_Start: TButton;
    Btn_Stop: TButton;
    Sock1: TSock;
    procedure Btn_StartClick(Sender: TObject);
    procedure Btn_StopClick(Sender: TObject);
    procedure Sock1AutoAccept(Sender: TObject; NewSock: TSock);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FOutput : TextFile;
  end;

var
  Frm_Srvr: TFrm_Srvr;

implementation

{$R *.DFM}

procedure TFrm_Srvr.Btn_StartClick(Sender: TObject);
begin
   Sock1.PortName := Edit_Port.Text;
   Sock1.StartListen;
   Btn_Start.Enabled := False;
   Btn_Stop.Enabled := True;
end;

procedure TFrm_Srvr.Btn_StopClick(Sender: TObject);
begin
   Sock1.StopListen;
   Btn_Start.Enabled := True;
   Btn_Stop.Enabled := False;
end;

procedure TFrm_Srvr.Sock1AutoAccept(Sender: TObject; NewSock: TSock);
Var Temp : String;
begin
   Memo_Status.Text := Memo_Status.Text + 'Incoming...' + #13 + #10;
   Memo_Status.Text := Memo_Status.Text + 'Port: ' + NewSock.PortName + #13 + #10;
   Memo_Status.Text := Memo_Status.Text + 'Address: ' + NewSock.HostName + #13 + #10;
   Repeat
      Try
         Temp := NewSock.Text;
         Write(FOutput, Temp);
         If (Temp <> '') Then NewSock.Text := Temp;
         Memo_Status.Text := Memo_Status.Text + Temp;
      Except
         On E:ESockException Do Memo_Status.Text := Memo_Status.Text + #13 + #10 + E.Message + #13 + #10;
      End;
   Until Not NewSock.Connected;
   Memo_Status.Text := Memo_Status.Text + '[End Connect]' + #13 + #10;
end;

procedure TFrm_Srvr.FormCreate(Sender: TObject);
begin
   AssignFile(FOutput, 'C:\SRVLOG.TXT');
   Rewrite(FOutput);
end;

procedure TFrm_Srvr.FormDestroy(Sender: TObject);
begin
   CloseFile(FOutput);
end;

end.
