unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Sock, ExtCtrls;

type
  TFrm_Main = class(TForm)
    Btn_Start: TButton;
    Label1: TLabel;
    Edit_Port: TEdit;
    Sock: TSock;
    Label2: TLabel;
    Lbl_Threads: TLabel;
    Label3: TLabel;
    Lbl_HeapFree: TLabel;
    Button1: TButton;
    Timer1: TTimer;
    procedure Btn_StartClick(Sender: TObject);
    procedure SockAutoAccept(Sender: TObject; NewSock: TSock);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Threadcount : Integer;
  end;

var
  Frm_Main: TFrm_Main;

implementation

uses ip;

{$R *.DFM}

procedure TFrm_Main.Btn_StartClick(Sender: TObject);
begin
   If Btn_Start.Caption = 'Start' Then
      Begin
         Sock.PortName := Edit_Port.Text;
         Sock.StartListen;
         Btn_Start.Caption :='Stop';
      End
   Else
      Begin
         Sock.StopListen;
         Btn_Start.Caption := 'Start';
      End;
end;

procedure TFrm_Main.SockAutoAccept(Sender: TObject; NewSock: TSock);
Var Content : String;
    Temp    : String;
    CSock   : TSock;
    NSock   : TSock;
    SL      : String;
    HN,PT   : String;
    Rm      : String;
    Pl      : Integer;
begin
   Inc(ThreadCount);
   Lbl_Threads.Caption := IntToStr(ThreadCount);
   CSock := TSock.Create(Self);
   Nsock := TSock.Create(Self);
   Try
      Try
         Content := '';
         SL := '';
         Rm := '';
         Repeat
            Temp := NewSock.Text;
            If Temp <> '' Then
               Begin
                  // Incoming Data
                  Content := Content + Temp;
                  Temp := '';
                  If (SL = '') And (Pos('HTTP/', Content) > 0) Then
                     Begin
                        SL := Copy(Content, 1, Pos('HTTP/', Content)+1);
                        Delete(Content, 1, Length(SL));
                        // Parse SL To Connect To The Server
                        Rm := Copy(Sl, 1, Pos('http://', Sl)-1);
                        Delete(Sl, 1, Pos('http://', Sl)+6); // Don't Need http://
                        PT := '80';
                        Pl := Pos(':', Sl);
                        If (Pl > 0) And (Pl < Pos('/', Sl)) Then
                           Begin
                              // There's A Port Number
                              HN := Copy(Sl, 1, Pos(':', Sl)-1);
                              Delete(Sl, 1, Pos(':', Sl));
                              PT := Copy(Sl, 1, Pos('/', Sl)-1);
                              Delete(Sl, 1, Pos('/', Sl)-1);
                           End
                        Else
                           Begin
                              HN := Copy(Sl, 1, Pos('/', Sl)-1);
                              Delete(Sl, 1, Pos('/', Sl)-1);
                           End;
                        Content := Rm + Sl+ Content;
                        CSock.HostName := HN;
                        CSock.PortName := PT;
                        CSock.Blocking := True;
                        CSock.Open;
                     End;
                  If (SL <> '') And (CSock.Connected) Then
                     Begin
                        CSock.Text := Content;
                        Content := '';
                     End;
               End;
            If SL <> '' Then
               Begin
                  Temp := CSock.Text;
                  If (Temp <> '') And (NewSock.Connected) Then
                     NewSock.Text := Temp;
                  Temp := '';
               End;
         Until ((SL <> '') And (Not CSock.Connected)) Or (Not NewSock.Connected);
      Except
         On Exception Do Begin End;
      End;
   Finally
      Content := '';
      UniqueString(Temp);
      SL := '';
      HN := '';
      PT := '';
      Rm := '';
      NewSock.Free;
      CSock.Free;
      NSock.Free;
      Dec(ThreadCount);
      Lbl_Threads.Caption := IntToStr(ThreadCount);
      EndThread(0);
   End;
end;

procedure TFrm_Main.FormCreate(Sender: TObject);
begin
   Lbl_HeapFree.Caption := IntToStr(GetHeapStatus.TotalAllocated) + '/' + IntToStr(GetHeapStatus.TotalFree);
end;

procedure TFrm_Main.Button1Click(Sender: TObject);
begin
   Frm_IP.Memo1.Lines := IPCache;
   Frm_IP.ShowModal;
end;

procedure TFrm_Main.Timer1Timer(Sender: TObject);
begin
   Lbl_HeapFree.Caption := IntToStr(GetHeapStatus.TotalAllocated) + '/' + IntToStr(GetHeapStatus.TotalFree);
end;

end.
