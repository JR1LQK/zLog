unit UPaddleThread;

interface

uses
  Classes, BGK32LIB, Windows;


type
  TPaddleThread = class(TThread)
  private
    { Private declarations }
    WaitMS : integer; // wait time in ms
  protected
    procedure Execute; override;
  public
    Count : integer;
    Stop : Boolean;
    constructor Create(UseUSB : boolean);
  end;

var PaddleThread : TPaddleThread;

implementation

{ Important: Methods and properties of objects in VCL can only be used in a
  method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TPaddleThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TPaddleThread }

constructor TPaddleThread.Create(UseUSB : boolean);
begin
  Count := 0;
  if UseUSB then
    WaitMS := 1
  else
    WaitMS := 2;
  FreeOnTerminate := True;
  //Priority := tpLower;
  inherited Create(False);
end;

procedure TPaddleThread.Execute;
begin
  Stop := False;
  repeat
    SleepEx(WaitMS, False);

{$ifndef w95}
if KeyingPort = tkpUSB then
  PaddleProcessUSB
else
  PaddleProcess;
{$else}
  PaddleProcess;
{$endif}

  until Terminated;
end;

initialization
  PaddleThread := nil;
end.
