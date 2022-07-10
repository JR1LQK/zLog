unit MouseReader;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HidControllerClass, StdCtrls;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    JvHidDeviceController1: TJvHidDeviceController;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Buttons: TLabel;
    DeltaX: TLabel;
    DeltaY: TLabel;
    procedure JvHidDeviceController1DeviceChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DevList: TList;
  end;

  TMouseReport = packed record
    ReportID: Byte;
    Buttons:  Byte;
    DeltaX:   Shortint;
    DeltaY:   Shortint;
    Dummy:    array [0..11] of Byte;
  end;

  TMouseThread = class(TThread)
  private
    Dev:      TJvHidDevice;
    DevIndex: Integer;
    Data:     TMouseReport;
  public
    procedure Execute; override;
    procedure HandleMouseData;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.JvHidDeviceController1DeviceChange(Sender: TObject);
var
  I: Integer;
  Trd: TMouseThread;
  HidDev: TJvHidDevice;
begin
  // an HID device has been plugged or unplugged
  // we kill all threads and create ne ones
  if DevList = nil then
    DevList := TList.Create;
  for i := 0 to DevList.Count - 1 do
  begin
    Trd := DevList.Items[I];
    // freeing the HID device closes its file handles
    // and the pending ReadFileEx will fail allowing
    // the thread to terminate
    // a pending ReadFile would not fail but wait forever
    Trd.Dev.Free;
    Trd.Terminate;
  end;
  DevList.Clear;
  ListBox1.Clear;
  // get all devices we are interested in
  while JvHidDeviceController1.CheckOutByClass(HidDev, cHidMouseClass) do
  begin
    // start a thread for each device
    Trd := TMouseThread.Create(True);
    with Trd do
    begin
      // initialize threads data
      FreeOnTerminate := True;
      Dev := HidDev;
      DevIndex := DevList.Count;
      DevList.Add(Trd);
      ListBox1.Items.Add(HidDev.ProductName);
      // let the thread run
      Resume;
    end;
  end;
end;

procedure TMouseThread.HandleMouseData;
begin
  // select the device the data comes from
  Form1.ListBox1.ItemIndex := DevIndex;
  // show the data read
  Form1.Buttons.Caption := Format('%.2x',[Data.Buttons]);
  Form1.DeltaX.Caption  := Format('%d',  [Data.DeltaX]);
  Form1.DeltaY.Caption  := Format('%d',  [Data.DeltaY]);
end;

procedure TMouseThread.Execute;

  procedure Dummy(ErrorCode: DWORD; Count: DWORD; Ovl: POverlapped); stdcall;
  begin
  end;

begin
  while not Terminated do
  begin
    // read mouse data
    Dev.ReadFileEx(Data, Dev.Caps.InputReportByteLength, @Dummy);
    // wait for read to complete
    while (not Terminated) and (SleepEx(5000, True) <> WAIT_IO_COMPLETION) do
      { nothing };
    // show data read
    if not Terminated then
      Synchronize(HandleMouseData);
  end;
end;

end.
