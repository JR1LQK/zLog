unit vsscomdemo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, VSSComm32, ComCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    VSSComm321: TVSSComm32;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure VSSComm321ReceiveData(Buffer: Pointer; BufferLength: Word);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
VSSComm321.startcomm;
StatusBar1.Panels.Items[0].Text :='Comm Open';
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
VSSComm321.stopcomm;
StatusBar1.Panels.Items[0].Text :='Comm Closed';
StatusBar1.Panels.Items[1].Text :='';
memo1.lines.clear;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   sendstring: String;
begin
sendstring:='This is a test to see if the data is returned from the Comm Port';

VSSComm321.writecommdata(pchar(sendstring),length(sendstring));
StatusBar1.Panels.Items[1].Text :='Sending Data';
end;

procedure TForm1.VSSComm321ReceiveData(Buffer: Pointer;
  BufferLength: Word);
begin
StatusBar1.Panels.Items[1].Text :='Receiving Data';
memo1.lines.add(strpas(buffer));
StatusBar1.Panels.Items[1].Text :='Received Data';
end;

end.
