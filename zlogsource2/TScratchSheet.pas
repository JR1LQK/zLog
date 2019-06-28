unit TScratchSheet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UConsolePad, StdCtrls, ExtCtrls;

type
  TScratchSheet = class(TConsolePad)
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure AddLine(S : string); override;
    { Public declarations }
  end;

var
  ScratchSheet: TScratchSheet;

implementation

{$R *.DFM}

procedure TScratchSheet.EditKeyPress(Sender: TObject; var Key: Char);
var str : string;
begin
  case Key of
    Chr($0D) :
      begin
        str := Edit.Text;
        if str <> '' then
          if str[1] <> ',' then
            str := ',' + str;
        Edit.Text := '';
        //MainForm.ProcessConsoleCommand(str);
        Key := #0;
      end;
    Chr($1B) :
      begin
        MainForm.LastFocus.SetFocus;
        Key := #0;
      end;
  end;

end;

procedure TScratchSheet.AddLine(S : string);
//var _VisRows, _TopRow : integer;
begin
  inherited;
end;


procedure TScratchSheet.FormCreate(Sender: TObject);
begin
  inherited;
  MaxLines := 25;
end;

end.
