unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, HidControllerClass, Hid;

type
  TForm1 = class(TForm)
    JvHidDeviceController1: TJvHidDeviceController;
    TreeView1: TTreeView;
    procedure JvHidDeviceController1DeviceChange(Sender: TObject);
    function  JvHidDeviceController1Enumerate(HidDev: TJvHidDevice;
      Index: Integer): Boolean;
  private
    { Private declarations }
    FRoot: TTreeNode;
  public
    { Public declarations }
    procedure EnumerateNodes(HidDev: TJvHidDevice; Parent: TTreeNode; Idx: WORD);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.JvHidDeviceController1DeviceChange(Sender: TObject);
begin
  TreeView1.Items.Clear;
  FRoot := TreeView1.Items.Add(nil,'HID-Devices');
  JvHidDeviceController1.Enumerate;
end;

procedure TForm1.EnumerateNodes(HidDev: TJvHidDevice; Parent: TTreeNode; Idx: WORD);
var
  Node: TTreeNode;
begin
  repeat
    Node := TreeView1.Items.AddChild(Parent,
      Format('CollectionType=%d Usage=%d UsagePage=%d',[HidDev.LinkCollectionNodes[Idx].CollectionType,
      HidDev.LinkCollectionNodes[Idx].LinkUsage,
      HidDev.LinkCollectionNodes[Idx].LinkUsagePage]));
    if (HidDev.LinkCollectionNodes[Idx].FirstChild <> 0) and
       (HidDev.LinkCollectionNodes[Idx].FirstChild <> Idx) then
      EnumerateNodes(HidDev, Node, HidDev.LinkCollectionNodes[Idx].FirstChild);
    if Idx = HidDev.LinkCollectionNodes[Idx].NextSibling then
       Break;
    Idx := HidDev.LinkCollectionNodes[Idx].NextSibling;
  until Idx = 0;
end;

function TForm1.JvHidDeviceController1Enumerate(HidDev: TJvHidDevice;
  Index: Integer): Boolean;
var
  Node: TTreeNode;
begin
  Node := TreeView1.Items.AddChild(FRoot, HidDev.ProductName);
  EnumerateNodes(HidDev, Node, 1);
  TreeView1.FullExpand;
  Result := True;
end;

end.
