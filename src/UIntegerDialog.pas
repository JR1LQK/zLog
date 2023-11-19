unit UIntegerDialog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TIntegerDialog = class(TForm)
    Label1: TLabel;
    Edit: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    //Value : integer;
    Cancelled : boolean;
  public
    procedure Init(i : integer; S : string);
    function GetValue : integer;
    function GetValueExtended : extended;
    procedure SetLabel(S : string);
    { Public declarations }
  end;

var
  IntegerDialog: TIntegerDialog;

implementation

{$R *.DFM}

procedure TIntegerDialog.Init(i : integer; S : string);
begin
  Edit.Text := IntToStr(i);
  SetLabel(S);
end;

function TIntegerDialog.GetValue : integer;
var v : integer;
begin
  if Cancelled then
    begin
      Result := 0;
      exit;
    end;
  v := -1;
  try
    v := StrToInt(Edit.Text);
  except
    on EConvertError do
      v := -1;
  end;
  Result := v;
end;

function TIntegerDialog.GetValueExtended : extended;
var v : extended;
begin
  v := -1;
  try
    v := StrToFloat(Edit.Text);
  except
    on EConvertError do
      v := -1;
  end;
  Result := v;
end;

procedure TIntegerDialog.SetLabel(S : string);
var w : integer;
begin
  Label1.Caption := S;
  w := IntegerDialog.Width - Label1.Width;
  if w > 0 then
    Label1.Left := w div 2
  else
    w := 2;
end;

procedure TIntegerDialog.FormCreate(Sender: TObject);
begin
  Caption := ' ';
end;

procedure TIntegerDialog.FormShow(Sender: TObject);
begin
  Edit.Left := (IntegerDialog.Width - Edit.Width) div 2;
  Button1.Left := Edit.Left - 16;
  Button2.Left := Edit.Left + Edit.Width + 16 - Button2.Width;
  Cancelled := False;
end;

procedure TIntegerDialog.Button2Click(Sender: TObject);
begin
  Cancelled := True;
  Edit.Text := '';
end;

end.
