unit UAbout;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ShellApi, UzLogGlobal, BGK32LIB;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    OKButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel2: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    LinkLabel1: TLinkLabel;
    Label5: TLabel;
    procedure OKButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
   Close;
end;

procedure TAboutBox.FormShow(Sender: TObject);
var
   temp : string;
begin
   Label2.Caption := TQSO(Log.List[0]).QSO.memo;
   Str(BGK32LIB.GetVersion : 3:2, temp);
   //BGK32DLL.Caption := 'BGK32.DLL version '+temp;
end;

procedure TAboutBox.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
   ShellExecute(Handle, 'open', PChar(Link), nil, nil, SW_SHOW);
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
   if USB_Detected then begin
      Label4.Caption := 'USBIF4CW detected';
   end
   else begin
      Label4.Caption := '';
   end;

end;

end.

