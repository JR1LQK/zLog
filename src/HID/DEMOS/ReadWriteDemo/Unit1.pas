unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HidControllerClass, StdCtrls;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    WriteButton: TButton;
    ReportID: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Label3: TLabel;
    ReadButton: TButton;
    InfoButton: TButton;
    JvHidDeviceController1: TJvHidDeviceController;
    procedure JvHidDeviceController1DeviceChange(Sender: TObject);
    function JvHidDeviceController1Enumerate(HidDev: TJvHidDevice;
      Index: Integer): Boolean;
    procedure WriteButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ReadButtonClick(Sender: TObject);
    procedure InfoButtonClick(Sender: TObject);
  private
    { Private declarations }
    DevList: TList;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  TheDev: TJvHidDevice;

implementation

uses Unit2;

{$R *.DFM}

procedure TForm1.JvHidDeviceController1DeviceChange(Sender: TObject);
var
  I: Integer;
begin
  if DevList <> nil then
  begin
    for I := 0 to DevList.Count-1 do
    begin
      TheDev := DevList.Items[I];
      TheDev.Free;
    end;
    DevList.Clear;
  end
  else
    DevList := TList.Create;
  ListBox1.Clear;
  JvHidDeviceController1.Enumerate;
  if ListBox1.Items.Count > 0 then
    ListBox1.ItemIndex := 0;
end;

function TForm1.JvHidDeviceController1Enumerate(HidDev: TJvHidDevice;
  Index: Integer): Boolean;
var
  Dev: TJvHidDevice;
begin
  if HidDev.ProductName <> '' then
    ListBox1.Items.Add(HidDev.ProductName)
  else
    ListBox1.Items.Add(Format('Device VID=%x PID=%x',[HidDev.Attributes.VendorID,HidDev.Attributes.ProductID]));
  JvHidDeviceController1.CheckOutByIndex(Dev,Index);
  DevList.Add(Dev);
  Result := True;
end;

function ToInt(str: string): Cardinal;
begin
  Result := 0;
  if str <> '' then
    Result := StrToInt('$'+str);
end;

procedure TForm1.WriteButtonClick(Sender: TObject);
var
  buf: array [0..8] of Byte;
  written: Cardinal;
  towrite: Cardinal;
begin
  buf[0] := ToInt(ReportID.Text);
  buf[1] := ToInt(Edit1.Text);
  buf[2] := ToInt(Edit2.Text);
  buf[3] := ToInt(Edit3.Text);
  buf[4] := ToInt(Edit4.Text);
  buf[5] := ToInt(Edit5.Text);
  buf[6] := ToInt(Edit6.Text);
  buf[7] := ToInt(Edit7.Text);
  buf[8] := ToInt(Edit8.Text);
  towrite := 1;
  if Edit1.Text <> '' then
    towrite := 2;
  if Edit2.Text <> '' then
    towrite := 3;
  if Edit3.Text <> '' then
    towrite := 4;
  if Edit4.Text <> '' then
    towrite := 5;
  if Edit5.Text <> '' then
    towrite := 6;
  if Edit6.Text <> '' then
    towrite := 7;
  if Edit7.Text <> '' then
    towrite := 8;
  if Edit8.Text <> '' then
    towrite := 9;
  written := 0;
  if (Edit1.Text = '') and (towrite > 2) then
     Edit1.Text := '00';
  if (Edit2.Text = '') and (towrite > 3) then
     Edit2.Text := '00';
  if (Edit3.Text = '') and (towrite > 4) then
     Edit3.Text := '00';
  if (Edit4.Text = '') and (towrite > 5) then
     Edit4.Text := '00';
  if (Edit5.Text = '') and (towrite > 6) then
     Edit5.Text := '00';
  if (Edit6.Text = '') and (towrite > 7) then
     Edit6.Text := '00';
  if (Edit7.Text = '') and (towrite > 8) then
     Edit7.Text := '00';

  if (ListBox1.Items.Count > 0) and (ListBox1.ItemIndex >= 0) and (towrite > 1) then
  begin
    TheDev := DevList.Items[ListBox1.ItemIndex];
    Label3.Caption := Format('Writing %d Bytes...',[towrite]);
    HidCheck(TheDev.WriteFile(buf,towrite,written));
    Label3.Caption := Format('%d Bytes written',[written]);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  JvHidDeviceController1.OnDeviceChange := JvHidDeviceController1DeviceChange;
  JvHidDeviceController1.OnEnumerate    := JvHidDeviceController1Enumerate;
  JvHidDeviceController1.Enumerate;
  if ListBox1.Items.Count > 0 then
    ListBox1.ItemIndex := 0;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to DevList.Count-1 do
  begin
    TheDev := DevList.Items[I];
    JvHidDeviceController1.CheckIn(TheDev);
  end;
  DevList.Free;
end;

procedure TForm1.ReadButtonClick(Sender: TObject);
var
  buf: array [0..8] of Byte;
  toread: Cardinal;
  read: Cardinal;
begin
  if (ListBox1.Items.Count > 0) and (ListBox1.ItemIndex >= 0) then
  begin
    TheDev := DevList.Items[ListBox1.ItemIndex];
    toread := TheDev.Caps.InputReportByteLength;
    buf[0] := ToInt(ReportID.Text);
    Label3.Caption := Format('Reading %d Bytes...',[toread]);
    Update;
    HidCheck(TheDev.ReadFile(buf,toread,read));
    Label3.Caption := Format('%d Bytes read',[read]);
    Edit1.Text := '';
    Edit2.Text := '';
    Edit3.Text := '';
    Edit4.Text := '';
    Edit5.Text := '';
    Edit6.Text := '';
    Edit7.Text := '';
    Edit8.Text := '';
    if read > 1 then
      Edit1.Text := Format('%x',[buf[1]]);
    if read > 2 then
      Edit2.Text := Format('%x',[buf[2]]);
    if read > 3 then
      Edit3.Text := Format('%x',[buf[3]]);
    if read > 4 then
      Edit4.Text := Format('%x',[buf[4]]);
    if read > 5 then
      Edit5.Text := Format('%x',[buf[5]]);
    if read > 6 then
      Edit6.Text := Format('%x',[buf[6]]);
    if read > 7 then
      Edit7.Text := Format('%x',[buf[7]]);
    if read > 8 then
      Edit8.Text := Format('%x',[buf[8]]);
  end;
end;

procedure TForm1.InfoButtonClick(Sender: TObject);
var
  Form: TInfoForm;
begin
  if (ListBox1.Items.Count > 0) and (ListBox1.ItemIndex >= 0) then
  begin
    TheDev := DevList.Items[ListBox1.ItemIndex];
    Form := TInfoForm.Create(Self);
    Form.ShowModal;
    Form.Free;
  end;
end;

end.
