unit formMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CommInt, StdCtrls, ComCtrls;

type
  TfrmMain = class(TForm)
    Comm1: TComm;
    Memo1: TMemo;
    Memo2: TMemo;
    ButtonOpen: TButton;
    ButtonClose: TButton;
    ButtonReset: TButton;
    EditTransmit: TEdit;
    CheckBoxAddLinefeed: TCheckBox;
    ButtonTransmit: TButton;
    StatusBar1: TStatusBar;
    LabelBaudrate: TLabel;
    LabelDataBits: TLabel;
    LabelStopbits: TLabel;
    LabelParity: TLabel;
    ComboBaudrate: TComboBox;
    ComboDatabits: TComboBox;
    ComboStopbits: TComboBox;
    ComboParity: TComboBox;
    Button1: TButton;
    LabelDevName: TLabel;
    EditDevName: TEdit;
    CheckBoxRTS: TCheckBox;
    CheckBoxDTR: TCheckBox;
    CheckBoxBREAK: TCheckBox;
    CheckBoxXON: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOpenClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonResetClick(Sender: TObject);
    procedure ButtonTransmitClick(Sender: TObject);
    procedure Comm1RxChar(Sender: TObject; Count: Integer);
    procedure Comm1RxFlag(Sender: TObject);
    procedure Comm1TxEmpty(Sender: TObject);
    procedure Comm1Break(Sender: TObject);
    procedure Comm1Cts(Sender: TObject);
    procedure Comm1Dsr(Sender: TObject);
    procedure Comm1Error(Sender: TObject; Errors: Integer);
    procedure Comm1Ring(Sender: TObject);
    procedure Comm1Rlsd(Sender: TObject);
    procedure ComboBaudrateChange(Sender: TObject);
    procedure ComboDatabitsChange(Sender: TObject);
    procedure ComboStopbitsChange(Sender: TObject);
    procedure ComboParityChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBoxRTSClick(Sender: TObject);
    procedure CheckBoxDTRClick(Sender: TObject);
    procedure CheckBoxBREAKClick(Sender: TObject);
    procedure CheckBoxXONClick(Sender: TObject);
  private
    LineData: string;
    procedure HandleException(Sender: TObject; E: Exception);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}


const
  OnOff: array[0..1] of string = ('Off', 'On');

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Application.OnException := HandleException;

  with ComboBaudrate do
    ItemIndex := Items.IndexOf('cbr38400');
  with ComboDataBits do
    ItemIndex := Items.IndexOf('da8');
  with ComboParity do
    ItemIndex := Items.IndexOf('paNone');
  with ComboStopbits do
    ItemIndex := Items.IndexOf('sb10');

  Comm1.BaudRate := TBaudrate(ComboBaudrate.ItemIndex);
  Comm1.Databits := TDataBits(ComboDatabits.ItemIndex);
  Comm1.Parity := TParity(ComboParity.ItemIndex);
  Comm1.StopBits := TStopBits(ComboStopbits.ItemIndex);

  EditDevName.Text := Comm1.DeviceName;
end;

procedure TfrmMain.HandleException(Sender: TObject; E: Exception);
begin
  if E is ECommError then
    with E as ECommError do
      ShowMessage('Async32 error: ' + Message);
end;

procedure TfrmMain.ButtonOpenClick(Sender: TObject);
begin
  Comm1.DeviceName := EditDevName.Text;
  Comm1.Open;
  Comm1.SetRTSState(true);
  Comm1.SetDTRState(true);
  Memo1.Lines.add('Device ready: ' + Comm1.DeviceName);
//Memo1.Lines.add(GetProviderSubtypeName(Comm1.ProviderSubtype));
//UpdateControls;
end;

procedure TfrmMain.ButtonCloseClick(Sender: TObject);
begin
  Comm1.Close;
  Memo1.Lines.Add('Device closed: ' + Comm1.DeviceName);
end;

procedure TfrmMain.ButtonResetClick(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;
end;

procedure TfrmMain.ButtonTransmitClick(Sender: TObject);
var
  S: string;
  Count: Integer;
begin
  S := EditTransmit.Text;
  if CheckBoxAddLinefeed.Checked then
    S := S + #13#10;
  Count := Length(S);
  Count := Comm1.Write(S[1], Count);
  if Count = -1 then
    Memo1.Lines.add('Error writing to: ' + Comm1.DeviceName)
  else Memo1.Lines.add('Transmitting ' + IntToStr(Count) + ' characters');
end;

procedure TfrmMain.Comm1RxChar(Sender: TObject; Count: Integer);
type
  CharBuf = array[0..9999] of Char;
var
  Buffer: ^CharBuf;
  Bytes, P: Integer;
begin
  GetMem(Buffer, Comm1.ReadBufSize);
  try
    Memo1.Lines.add('RxChar signal detected...');
    Fillchar(Buffer^, Comm1.ReadBufSize, 0);
    Bytes := Comm1.Read(Buffer^, Count);
    if Bytes = -1 then
      Memo1.Lines.add('Error reading incoming data...')
    else
    begin
      Memo1.Lines.add('Reading ' + IntToStr(Bytes) + ' characters');
      for P := 0 to Bytes - 1 do
      begin
        case Buffer^[P] of
           #0, #10:;
          #13: begin

                 Memo2.Lines.Add(LineData);
                 LineData := '';
               end;
           else
             begin
               LineData := LineData + CharBuf(Buffer^)[P];
             end;
        end; //case
      end; //for do
    end;

  Application.ProcessMessages;
  finally
    FreeMem(Buffer);
  end;
end;

procedure TfrmMain.Comm1RxFlag(Sender: TObject);
begin
  Memo1.Lines.add('RxFlag signal detected...');
end;

procedure TfrmMain.Comm1TxEmpty(Sender: TObject);
begin
  Memo1.Lines.add('TxEmpty signal detected...');
end;

procedure TfrmMain.Comm1Break(Sender: TObject);
begin
  Memo1.Lines.add('Break signal detected...');
end;

procedure TfrmMain.Comm1Cts(Sender: TObject);
begin
  Memo1.Lines.add('CTS: ' + OnOff[ord(Comm1.CTS)]);
end;

procedure TfrmMain.Comm1Dsr(Sender: TObject);
begin
  Memo1.Lines.add('DSR: ' + OnOff[ord(Comm1.DSR)]);
end;

procedure TfrmMain.Comm1Ring(Sender: TObject);
begin
  Memo1.Lines.add('RING: ' + OnOff[ord(Comm1.Ring)]);
end;

procedure TfrmMain.Comm1Rlsd(Sender: TObject);
begin
  Memo1.Lines.add('RLSD: ' + OnOff[ord(Comm1.RLSD)]);
end;

procedure TfrmMain.Comm1Error(Sender: TObject; Errors: Integer);
begin
  if (Errors and CE_BREAK > 0) then
    Memo1.Lines.add('The hardware detected a break condition.');
  if (Errors and CE_DNS > 0) then
    Memo1.Lines.add('Windows 95 only: A parallel device is not selected.');
  if (Errors and CE_FRAME > 0) then
    Memo1.Lines.add('The hardware detected a framing error.');
  if (Errors and CE_IOE > 0) then
    Memo1.Lines.add('An I/O error occurred during communications with the device.');
  if (Errors and CE_MODE > 0) then
  begin
    Memo1.Lines.add('The requested mode is not supported, or the hFile parameter');
    Memo1.Lines.add('is invalid. If this value is specified, it is the only valid error.');
  end;
  if (Errors and CE_OOP > 0) then
    Memo1.Lines.add('Windows 95 only: A parallel device signaled that it is out of paper.');
  if (Errors and CE_OVERRUN > 0) then
    Memo1.Lines.add('A character-buffer overrun has occurred. The next character is lost.');
  if (Errors and CE_PTO > 0) then
    Memo1.Lines.add('Windows 95 only: A time-out occurred on a parallel device.');
  if (Errors and CE_RXOVER > 0) then
  begin
    Memo1.Lines.add('An input buffer overflow has occurred. There is either no');
    Memo1.Lines.add('room in the input buffer, or a character was received after');
    Memo1.Lines.add('the end-of-file (EOF) character.');
  end;
  if (Errors and CE_RXPARITY > 0) then
    Memo1.Lines.add('The hardware detected a parity error.');
  if (Errors and CE_TXFULL > 0) then
  begin
    Memo1.Lines.add('The application tried to transmit a character, but the output');
    Memo1.Lines.add('buffer was full.');
  end;
end;

procedure TfrmMain.ComboBaudrateChange(Sender: TObject);
begin
  Comm1.BaudRate := TBaudrate(ComboBaudrate.ItemIndex);
  Memo1.Lines.add('Baudrate: ' + ComboBaudrate.Text);
end;

procedure TfrmMain.ComboDatabitsChange(Sender: TObject);
begin
  Comm1.Databits := TDataBits(ComboDatabits.ItemIndex);
  Memo1.Lines.add('Databits: ' + ComboDatabits.Text);
end;

procedure TfrmMain.ComboStopbitsChange(Sender: TObject);
begin
  Comm1.StopBits := TStopBits(ComboStopbits.ItemIndex);
  Memo1.Lines.add('StopBits: ' + ComboStopbits.Text);
end;

procedure TfrmMain.ComboParityChange(Sender: TObject);
begin
  Comm1.Parity := TParity(ComboParity.ItemIndex);
  Memo1.Lines.add('Parity: ' + ComboParity.Text);
end;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  I: Integer;
  S: string;
begin
  if MessageDlg('This will sent the input a thousand times, continue?',
    mtConfirmation, [mbOk, mbCancel], 0) <> mrOk then exit;
  S := EditTransmit.Text;
  if CheckBoxAddLinefeed.Checked then
    S := S + #13#10;
  for I := 0 to 1000 do
  begin
    Comm1.Write(S[1], Length(S));
    application.ProcessMessages;
  end;
end;

procedure TfrmMain.CheckBoxRTSClick(Sender: TObject);
begin
  Comm1.SetRTSState(CheckBoxRTS.Checked);
end;

procedure TfrmMain.CheckBoxDTRClick(Sender: TObject);
begin
  Comm1.SetDTRState(CheckBoxDTR.Checked);
end;

procedure TfrmMain.CheckBoxBREAKClick(Sender: TObject);
begin
  Comm1.SetBREAKState(CheckBoxBREAK.Checked);
end;

procedure TfrmMain.CheckBoxXONClick(Sender: TObject);
begin
  Comm1.SetXONState(CheckBoxXON.Checked);
end;

end.
