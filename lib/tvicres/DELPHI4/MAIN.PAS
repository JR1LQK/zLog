unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, Buttons, Vic_Res, ComCtrls, Tabnotbk, ExtCtrls;

type
  TForm1 = class(TForm)
    GPort: TStringGrid;
    GMem: TStringGrid;
    GIRQ: TStringGrid;
    GDMA: TStringGrid;
    BitBtn1: TBitBtn;
    L_Port: TLabel;
    L_Mem: TLabel;
    L_IRQ: TLabel;
    L_DMA: TLabel;
    Panel1: TPanel;
    Label8: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Label3: TLabel;
    Label6: TLabel;
    B_Class: TButton;
    C_Hardw: TComboBox;
    Button1: TButton;
    B_DevDesc: TButton;
    Label9: TLabel;
    C_DevDesc: TComboBox;
    B_GetAllClasses: TButton;
    C_Class: TComboBox;
    Label12: TLabel;
    L_Devices: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure B_ClassClick(Sender: TObject);
    procedure B_HKEY(Sender: TObject);
    procedure B_DevDescClick(Sender: TObject);
    procedure B_GetAllClassesClick(Sender: TObject);
    procedure B_ClearGridsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

var VicRes : TVicRes;

procedure ShowGrids;
var i : Byte;
    w : Word;
    dw: DWORD;
begin

  with Form1,VicRes do
  begin

    L_Devices.Caption := 'Devices: '+IntToStr(VicRes.Devices);

    C_Hardw.Clear;
    C_DevDesc.Clear;
    for i:=1 to Devices do
    begin
      C_Hardw.Items.Add(HardwareKey[i]);
      C_DevDesc.Items.Add(DeviceDescriptor[i]);
    end;
    C_Hardw.ItemIndex := 0;
    C_DevDesc.ItemIndex := 0;
  end;

  with Form1,GPort,VicRes do
  begin
    Cells[0,0] := ' N'; Cells[1,0] := ' Base'; Cells[2,0] := ' End';
    L_Port.Caption := 'Port I/O areas: '+IntToStr(PortCounter);
    for i:= 1 to 8 do
    begin
      Cells[0,i] := ' '+IntToStr(i);
      w := PortBase[i];
      if w = $FFFF then
      begin
        Cells[1,i] := '';
        Cells[2,i] := '';
      end
      else begin
             Cells[1,i] := IntToHex(w,4);
             Cells[2,i] := IntToHex(PortEnd[i],4);
           end;

    end;
  end;
  with Form1,GMem,VicRes do
  begin
    Cells[0,0] := ' N'; Cells[1,0] := '   Base'; Cells[2,0] := '  End';
    L_Mem.Caption := 'Memory areas: '+IntToStr(MemCounter);
    for i:= 1 to 8 do
    begin
      Cells[0,i] := ' '+IntToStr(i);
      dw := MemBase[i];
      if dw=$FFFFFFFF then
      begin
        Cells[1,i] := '';
        Cells[2,i] := '';
      end
      else begin
             Cells[1,i] := IntToHex(dw,8);
             Cells[2,i] := IntToHex(MemEnd[i],8);
           end;
    end;
  end;
  with Form1,GIRQ,VicRes do
  begin
    L_IRQ.Caption := 'IRQs: '+IntToStr(IRQCounter);
    Cells[0,0] := ' N'; Cells[1,0] := ' IRQ';
    for i:= 1 to 8 do
    begin
      w := IRQNumber[i];
      Cells[0,i] := ' '+IntToStr(i);
      if w = $FFFF then Cells[1,i] := ''
                   else Cells[1,i] := IntToStr(w);
    end;
  end;
  with Form1,GDMA,VicRes do
  begin
    Cells[0,0] := ' N'; Cells[1,0] := 'Chan';
    L_DMA.Caption := 'DMAs: '+IntToStr(DMACounter);
    for i:= 1 to 8 do
    begin
      w := DMAChannel[i];
      Cells[0,i] := ' '+IntToStr(i);
      if w = $FFFF then Cells[1,i] := ''
                   else Cells[1,i] := IntToStr(DMAChannel[i]);
    end;
  end;

end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  VicRes := TVicRes.Create;
  ShowGrids;
  if (GetVersion() and $80000000)<>0 then
    Label2.caption := 'Windows 95/98'
  else
    Label2.caption := 'Windows NT';
  C_Class.Clear;
  C_Class.Items.Add('Keyboard');
  C_Class.ItemIndex:=0;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  VicRes.Free;
end;

procedure TForm1.B_ClassClick(Sender: TObject);
begin
  VicRes.SearchByClassName(C_Class.Text);
  ShowGrids;
  If VicRes.Devices>1 then
    ShowMessage('More than one Device ('+IntToStr(VicRes.Devices)+
                ') have founded for this Class Name!');

end;

procedure TForm1.B_HKEY(Sender: TObject);
begin
  VicRes.SearchByHardwareKey(C_Hardw.Items[C_Hardw.ItemIndex]);
  ShowGrids;
  If VicRes.Devices>1 then
    ShowMessage('More than one Device ('+IntToStr(VicRes.Devices)+
                ') have founded for this HardwareKey!');

end;

procedure TForm1.B_DevDescClick(Sender: TObject);
begin
  VicRes.SearchByDeviceDescriptor(C_DevDesc.Items[C_DevDesc.ItemIndex]);
  ShowGrids;
  If VicRes.Devices>1 then
    ShowMessage('More than one Device ('+IntToStr(VicRes.Devices)+
                ') have founded for this Device Descriptor!');
end;

procedure TForm1.B_GetAllClassesClick(Sender: TObject);
begin
  VicRes.GetAllClasses(C_Class.Items);
  C_Class.ItemIndex:=0;
end;

procedure TForm1.B_ClearGridsClick(Sender: TObject);
var i : byte;
begin
  for i:= 1 to 8 do
  begin
    GPort.Cells[1,i] := '';  GPort.Cells[2,i] := '';
    GDMA.Cells[1,i]  := '';  GDMA.Cells[2,i]  := '';
    GMem.Cells[1,i]  := '';  GMem.Cells[2,i]  := '';
    GIRQ.Cells[1,i]  := '';  GIRQ.Cells[2,i]  := '';
  end;
end;

end.
