unit Unit1;

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls,
   Forms, Dialogs, StdCtrls, Registry, Menus,
   HidControllerClass, Hid;

type
   // the simple form we show
   THidClassDemoForm = class(TForm)
      ListBox1:     TListBox;
      MainMenu:     TMainMenu;
      QuitMenuItem: TMenuItem;
      FileMenu:     TMenuItem;
      procedure DeviceChanges    (Sender: TObject);
      procedure DeviceUnplug     (HidDev: TJvHidDevice);
      function  Enumeration      (HidDev: TJvHidDevice; Index: Integer): Boolean;
      procedure FormCreate       (Sender: TObject);
      procedure QuitMenuItemClick(Sender: TObject);
    private
      { Private declarations }
    public
      { Public declarations }
       HidController: TJvHidDeviceController;
   end;

var
   HidClassDemoForm: THidClassDemoForm;

implementation

{$R *.DFM}

procedure THidClassDemoForm.DeviceChanges(Sender: TObject);
begin
   ListBox1.Clear;
   HidController.Enumerate;
end;

procedure THidClassDemoForm.DeviceUnplug(HidDev: TJvHidDevice);
var
   p: String;
begin
   p := HidDev.VendorName;
   if p = '' then
      p := HidDev.RegDescr;
   ShowMessage('Unplug of ' + Format('%x %x %s: %s',[HidDev.Attributes.VendorID,HidDev.Attributes.ProductID,p,HidDev.ProductName]));
end;

function THidClassDemoForm.Enumeration(HidDev: TJvHidDevice; Index: Integer): Boolean;
var
   p: string;
begin
   with HidDev do
   begin
      p := VendorName;
      if p = '' then
         p := RegDescr;
      ListBox1.Items.Add(Format('VendorID=%x ProductID=%x %s: %s',[Attributes.VendorID,Attributes.ProductID,p,ProductName]));
   end;
   Result := True;
end;

procedure THidClassDemoForm.FormCreate(Sender: TObject);
begin
   // the HidController handles all HidDevices
   // later this will be replaced by a placeable component
   HidController := TJvHidDeviceController.Create(Self);
   with HidController do
   begin
      OnDeviceChange := DeviceChanges;
      OnEnumerate    := Enumeration;
      OnDeviceUnplug := DeviceUnplug;
      Enumerate;
   end;
end;

procedure THidClassDemoForm.QuitMenuItemClick(Sender: TObject);
begin
   Close;
end;

end.
