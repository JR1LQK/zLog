unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  audio, StdCtrls, ExtCtrls, mmsystem;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Panel1: TPanel;
    WaveIn1: TWaveIn;
    WaveOut1: TWaveOut;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure WaveIn1WaveInData(Data: PChar; Size: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure WaveOut1WaveOutDone(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses msacm32;

Var
 i : integer;
 PAudioBuf, AudioBuf : PChar;

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
 GetMem(AudioBuf, 200000);
 PAudioBuf := AudioBuf;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 FreeMem(AudioBuf);
end;

procedure TForm1.WaveIn1WaveInData(Data: PChar; Size: Integer);
begin
  inc(I, Size);
  Panel1.Caption := Format('%d Bytes recorded', [i]);
  move(Data^, PAudioBuf^, size);
  inc(PAudioBuf, Size);
end;

procedure TForm1.Button3Click(Sender: TObject);
Var
 Size : Integer;
begin
  Size := Abs(Integer(PAudioBuf) - Integer(AudioBuf) ) ;
  PAudioBuf := AudioBuf;
  WaveOut1.Open;
  WaveOut1.PlayBack(AudioBuf, Size);
end;

procedure TForm1.WaveOut1WaveOutDone(Sender: TObject);
begin
  WaveOut1.Close;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 i := 0;
 // You may use WaveIn1.Open method also 
 wavein1.Recording := True;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 wavein1.Recording := False;
end;


end.
