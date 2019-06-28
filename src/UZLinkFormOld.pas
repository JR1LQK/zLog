unit UZLinkFormOld;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Console2, StdCtrls, ComCtrls, TnCnx, zLogGlobal,
  ComDrv32;

const ZLinkHeader = '#ZLOG#';

type
  TZLinkForm = class(TForm)
    StatusLine: TStatusBar;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Edit: TEdit;
    Button: TButton;
    Console: TColorConsole2;
    Timer1: TTimer;
    Telnet: TTnCnx;
    CommPort: TCommPortDriver;
    Label1: TLabel;
    Label2: TLabel;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TelnetDataAvailable(Sender: TTnCnx; Buffer: PChar;
      Len: Integer);
    procedure TelnetDisplay(Sender: TTnCnx; Str: String);
    procedure ButtonClick(Sender: TObject);
    procedure TelnetSessionConnected(Sender: TTnCnx; Error: Word);
    procedure TelnetSessionClosed(Sender: TTnCnx; Error: Word);
    procedure CommPortReceiveData(Sender: TObject; DataPtr: Pointer;
      DataSize: Integer);
    procedure CommPortReceivePacket(Sender: TObject; Packet: Pointer;
      DataSize, ElapsedTime: Integer);
  private
    { Private declarations }
    CommTemp : string; {command work string}
    CommStarted : boolean;
  public
    { Public declarations }
    CommBuffer : TStringList;
    procedure CommProcess;
    procedure ImplementOptions;
    procedure WriteData(str : string);
    procedure ProcessCommand(S : string);
    procedure SendQSO(aQSO : TQSO);
    procedure EditQSO(aQSO : TQSO; index : integer);
    procedure InsertQSO(aQSO : TQSO; index : integer);
  end;

var
  ZLinkForm: TZLinkForm;

implementation

uses Main, UOptions;

{$R *.DFM}

procedure TZLinkForm.WriteData(str : string);
begin
  case Options.Settings._zlinkport of
    1..4 : if CommPort.Connected then
             CommPort.SendData(PChar(str), Length(str));
    5 : Telnet.SendStr(str);
  end;
end;

procedure TZLinkForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TZLinkForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TZLinkForm.Button2Click(Sender: TObject);
begin
  if Self.FormStyle = fsStayOnTop then
    begin
      Self.FormStyle := fsNormal;
      Button2.Caption := 'Stay on Top';
    end
  else
    begin
      Self.FormStyle := fsStayOnTop;
      Button2.Caption := 'Normal';
    end;
end;

procedure TZLinkForm.Timer1Timer(Sender: TObject);
begin
  CommProcess;
end;

procedure TZLinkForm.ProcessCommand(S : string);
var temp : string;
    aQSO : TQSO;
begin
  temp := copy(S, length(ZLinkHeader)+2, 255);
  MainForm.StatusLine.SimpleText := temp;
  if pos('PUTQSO', temp) = 1 then
    begin
      aQSO := TQSO.Create;
      temp := copy(temp, 8, 255);
      aQSO.TextToQSO(temp);
      MyContest.LogQSO(aQSO);
      aQSO.Free;
    end;
end;

procedure TZLinkForm.SendQSO(aQSO : TQSO);
var str : string;
begin
  if Options.Settings._zlinkport in [1..5] then
    begin
      str := ZLinkHeader + ' PUTQSO '+aQSO.QSOinText;
      WriteData(str+LineBreakCode[ord(Console.LineBreak)]);
    end;
end;

procedure TZLinkForm.EditQSO(aQSO : TQSO; index : integer);
var str : string;
begin
  if Options.Settings._zlinkport in [1..5] then
    begin
      str := ZLinkHeader + ' EDITQSO '+IntToStr(index)+ ' ' +aQSO.QSOinText;
      WriteData(str);
    end;
end;

procedure TZLinkForm.InsertQSO(aQSO : TQSO; index : integer);
var str : string;
begin
  if Options.Settings._zlinkport in [1..5] then
    begin
      str := ZLinkHeader + ' INSQSO '+IntToStr(index)+ ' ' +aQSO.QSOinText;
      WriteData(str);
    end;
end;

procedure TZLinkForm.CommProcess;
var max , i, j, x : integer;
    str, currstr : string;
begin
  max := CommBuffer.Count - 1;
  if max < 0 then exit;
  label1.caption := 'commprocess';
  for i := 0 to max do
    Console.WriteString(CommBuffer.Strings[i]);

  for i := 0 to max do
    begin
      str := CommBuffer.Strings[0];
      for j := 1 to length(str) do
        begin
          if str[j] = Chr($0D) then
            begin
              x := Pos(ZLinkHeader, CommTemp);
              if x > 0 then
                begin
                  CommTemp := copy(CommTemp, x, 255);
                  ProcessCommand(CommTemp);
                end;
              CommTemp := '';
            end
          else
            CommTemp := CommTemp + str[j];
        end;
      CommBuffer.Delete(0);
    end;
end;

procedure TZLinkForm.FormCreate(Sender: TObject);
begin
  CommStarted := False;
  CommBuffer := TStringList.Create;
  CommTemp := '';
  Timer1.Enabled := True;
  ImplementOptions;
{  if Options.Settings._zlinkport in [1..4] then
    begin
      try
        Comm.StartComm;
      except
        on ECommsError do
          begin
          end;
      end;
      CommStarted := True;
    end; }
end;

procedure TZLinkForm.ImplementOptions;
begin
  if CommPort.Connected then
    CommPort.Disconnect;
  if Options.Settings._zlinkbaud <> 99 then
    CommPort.ComPortSpeed := TComPortBaudRate(Options.Settings._zlinkbaud);
  if Options.Settings._zlinkport in [1..4] then
    begin
      CommPort.ComPort := TComPortNumber(Options.Settings._zlinkport-1);
      CommPort.Connect;
    end
  else
    begin
    end;


  case Options.Settings._zlinkport of
    1..4 : Console.LineBreak := TConsole2LineBreak(Options.Settings._zlinklinebreakCOM);
    5 :    Console.LineBreak := TConsole2LineBreak(Options.Settings._zlinklinebreakTELNET);
  end;
  Telnet.Host := Options.Settings._zlinkhost;
  { if Options.Settings._zlinkport in [1..4] then
    begin
      if CommStarted then exit;
      try
        Comm.StartComm;
      except
        on ECommsError do
          begin
            Comm.StopComm;
            Comm.StartComm;
          end;
      end;
      CommStarted := True;
    end; }
end;


procedure TZLinkForm.EditKeyPress(Sender: TObject; var Key: Char);
var boo : boolean;
begin
  case Options.Settings._zlinkport of
    1..4 : boo := Options.Settings._zlinklocalechoCOM;
    5 : boo := Options.Settings._zlinklocalechoTELNET;
  end;
  if Key = Chr($0D) then
    begin
      WriteData(Edit.Text+LineBreakCode[ord(Console.LineBreak)]);
      if boo then
        Console.WriteString(Edit.Text+LineBreakCode[ord(Console.LineBreak)]);
      Key := Chr($0);
      Edit.Text := '';
    end;
end;

procedure TZLinkForm.FormDestroy(Sender: TObject);
begin
  inherited;
  {Timer1.Enabled := False;}
  {if CommStarted then }
  if CommPort.Connected then
    CommPort.Disconnect;
end;

procedure TZLinkForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : MainForm.LastFocus.SetFocus;
  end;
end;


procedure TZLinkForm.TelnetDataAvailable(Sender: TTnCnx; Buffer: PChar;
  Len: Integer);
var str : string;
begin
  str := strpas(Buffer);
  CommBuffer.Add(str);
end;

procedure TZLinkForm.TelnetDisplay(Sender: TTnCnx; Str: String);
begin
  CommBuffer.Add(str);
end;


procedure TZLinkForm.ButtonClick(Sender: TObject);
begin
  if Telnet.IsConnected then
    begin
      Telnet.Close;
      Button.Caption := 'Disconnecting...';
    end
  else
    begin
      Telnet.Connect;
      Button.Caption := 'Connecting...';
    end;
end;

procedure TZLinkForm.TelnetSessionConnected(Sender: TTnCnx; Error: Word);
begin
  Button.Caption := 'Disconnect';
  Console.WriteString('connected to '+Telnet.Host);
end;

procedure TZLinkForm.TelnetSessionClosed(Sender: TTnCnx; Error: Word);
begin
  Console.WriteString('disconnected...');
  Button.Caption := 'Connect';
end;

procedure TZLinkForm.CommPortReceiveData(Sender: TObject;
  DataPtr: Pointer; DataSize: Integer);
var str : string;
    p : PChar;
begin
(*  p := DataPtr;
  str := '';
  while DataSize > 0 do
  begin
    case p^ of
      {#10:; // LF
      #13: // CR - cursor to next line
        begin
          if ComBuffer.Count <> 0 then
            ComBuffer.Strings[CommBuffer.Count-1] := s
          else
            RxMemo.Lines.Add( s );
          RxMemo.Lines.Add( '' );
          s := '';
        end;}
      #8: // Backspace - delete last char
        delete( str, length(str), 1 );
      else // Any other char - add it to the current line
        str := str + p^;
    end;
    dec( DataSize );
    inc( p );
  end;
  {str := strpas(DataPtr);}
  CommBuffer.Add(str);
  Label2.Caption := IntToStr(DataSize);  *)
end;

procedure TZLinkForm.CommPortReceivePacket(Sender: TObject;
  Packet: Pointer; DataSize, ElapsedTime: Integer);
var str : string;
    p : PChar;
begin
  p := Packet;
  str := '';
  while DataSize > 0 do
  begin
    case p^ of
      {#10:; // LF
      #13: // CR - cursor to next line
        begin
          if ComBuffer.Count <> 0 then
            ComBuffer.Strings[CommBuffer.Count-1] := s
          else
            RxMemo.Lines.Add( s );
          RxMemo.Lines.Add( '' );
          s := '';
        end;}
      #8: // Backspace - delete last char
        delete( str, length(str), 1 );
      else // Any other char - add it to the current line
        str := str + p^;
    end;
    dec( DataSize );
    inc( p );
  end;
  {str := strpas(DataPtr);}
  CommBuffer.Add(str);
end;

end.
