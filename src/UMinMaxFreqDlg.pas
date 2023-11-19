unit UMinMaxFreqDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TMinMaxFreqDlg = class(TForm)
    minEdit: TEdit;
    maxEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    MinFreq, MaxFreq : integer;
    { Public declarations }
    procedure SetMinMax(min, max : integer);
  end;

var
  MinMaxFreqDlg: TMinMaxFreqDlg;

implementation

{$R *.DFM}

procedure TMinMaxFreqDlg.SetMinMax(min, max : integer);
begin
  MinFreq := min;
  MaxFreq := max;
  minEdit.Text := IntToStr(MinFreq);
  maxEdit.Text := IntToStr(MaxFreq);
end;

procedure TMinMaxFreqDlg.Button1Click(Sender: TObject);
var min, max : integer;
begin
  try
    min := StrToInt(MinEdit.Text);
  except
    on EConvertError do
      min := 0;
  end;

  try
    max := StrToInt(MaxEdit.Text);
  except
    on EConvertError do
      max := 0;
  end;

  if (min = 0) or (max = 0) or (min >= max) then
    begin
      close;
      exit;
    end;

  MinFreq := min;
  MaxFreq := max;

  close;

end;

procedure TMinMaxFreqDlg.Button2Click(Sender: TObject);
begin
  Close;
end;

end.
