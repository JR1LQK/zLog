unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Sock, StdCtrls, ExtCtrls, ToolWin, ComCtrls;

type
  TFrm_Main = class(TForm)
    Memo_Output: TMemo;
    Memo_Status: TMemo;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Btn_Open: TButton;
    Chk_CR: TCheckBox;
    Chk_LF: TCheckBox;
    Btn_Send: TButton;
    Btn_Close: TButton;
    Edit_Host: TEdit;
    Edit_Port: TEdit;
    Chk_NULL: TCheckBox;
    Edit_Input: TMemo;
    Button1: TButton;
    Sock1: TSock;
    procedure Sock1Read(Sender: TObject; Count: Integer);
    procedure Btn_OpenClick(Sender: TObject);
    procedure Sock1Write(Sender: TObject);
    procedure Sock1Connect(Sender: TObject);
    procedure Btn_CloseClick(Sender: TObject);
    procedure Btn_SendClick(Sender: TObject);
    procedure Sock1Disconnect(Sender: TObject);
    procedure Sock1Info(sender: TObject; SocketInfo: TSocketInfo;
      Msg: string);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_Main: TFrm_Main;

implementation

{$R *.DFM}

procedure TFrm_Main.Sock1Read(Sender: TObject; Count: Integer);
Var Temp : String;
    Cnt  : LongInt;
begin
   Repeat
      SetLength(Temp, 32); // To Test
      Cnt := Sock1.Stream.Read(Temp[1], 32);
      Memo_Output.Text := Memo_Output.Text + Copy(Temp, 1, Cnt);
   Until (Cnt<32);
   //Memo_Output.Text := Memo_Output.Text + Sock1.Text;
end;

procedure TFrm_Main.Btn_OpenClick(Sender: TObject);
begin
   Sock1.HostName := Edit_Host.Text;
   Sock1.PortName := Edit_Port.Text;
   Sock1.Connected := True;
end;

procedure TFrm_Main.Sock1Write(Sender: TObject);
begin
   Memo_Status.Text := Memo_Status.Text + '[ONWRITE!]'#13#10;
end;

procedure TFrm_Main.Sock1Connect(Sender: TObject);
begin
   Memo_Status.Text := Memo_Status.Text + '[ONCONNECT!]'+#13+#10;
end;

procedure TFrm_Main.Btn_CloseClick(Sender: TObject);
begin
   Sock1.Connected := False;
end;

procedure TFrm_Main.Btn_SendClick(Sender: TObject);
Var Temp : String;
begin
   Temp := Edit_Input.Text;
   If Chk_CR.Checked Then Temp := Temp + #13;
   If Chk_LF.Checked Then Temp := Temp + #10;
   If Chk_Null.Checked Then Temp := Temp + #0;
   Sock1.Stream.Write(Temp[1], Length(Temp));
   Edit_Input.Text := '';
end;

procedure TFrm_Main.Sock1Disconnect(Sender: TObject);
begin
   Memo_Status.Text := Memo_Status.Text + '[DISCONNECT!]'#13#10;
end;

procedure TFrm_Main.Sock1Info(sender: TObject; SocketInfo: TSocketInfo;
  Msg: string);
begin
   Memo_Status.Text := Memo_Status.Text + '[' + Msg + ']' + #13 + #10;
end;

procedure TFrm_Main.FormCreate(Sender: TObject);
begin
   Memo_Status.Text := WSDescription + #13 + #10 +
                       WSSystemStatus + #13 + #10 +
                       'Delphi Sock Component V1.0f' + #13 + #10 +
                       'Written By Tom Bradford' + #13 + #10;
end;

procedure TFrm_Main.Button1Click(Sender: TObject);
begin
   Memo_Output.Clear;
end;

end.
