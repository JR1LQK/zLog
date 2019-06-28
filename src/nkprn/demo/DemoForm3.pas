unit DemoForm3;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TPrintQualityForm = class(TForm)
    Label1: TLabel;
    YResolution: TLabel;
    Button1: TButton;
    Button2: TButton;
    rgQuality: TRadioGroup;
    lblXRes: TLabel;
    lblYRes: TLabel;
    lbQualities: TListBox;
    Label2: TLabel;
    procedure rgQualityClick(Sender: TObject);
    procedure lbQualitiesClick(Sender: TObject);
  private
    { Private éŒ¾ }
    Updating: Boolean;
  public
    { Public éŒ¾ }
  end;

var
  PrintQualityForm: TPrintQualityForm;

implementation

{$R *.DFM}
uses NkPrinters;

procedure TPrintQualityForm.rgQualityClick(Sender: TObject);
begin
  UpDating := True;
  try
    case rgQuality.ItemIndex of
    0: lblXRes.Caption := '-4';
    1: lblXRes.Caption := '-3';
    2: lblXRes.Caption := '-2';
    3: lblXRes.Caption := '-1';
    end;
    if rgQuality.ItemIndex in [0..3] then lblYRes.Caption := '0';
  finally
    Updating := false;
  end;
end;

procedure TPrintQualityForm.lbQualitiesClick(Sender: TObject);
var Quality: TSize;
begin
  with PrintQualityForm do
    if lbQualities.ItemIndex >= 0 then begin
      Quality := NkPrinter.Qualities[lbQualities.ItemIndex];
      lblXRes.Caption := IntToStr(Quality.cx);
      lblYRes.Caption := IntToStr(Quality.cy);
      rgQuality.ItemIndex := -1;
    end;
end;

end.
