unit UALLJAEditDialog;
    
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  UEditDialog, StdCtrls, ExtCtrls, zLogGlobal, Menus;

type
  TALLJAEditDialog = class(TEditDialog)
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ALLJAEditDialog: TALLJAEditDialog;

implementation

uses UOptions, Main;

{$R *.DFM}

procedure TALLJAEditDialog.FormShow(Sender: TObject);
var i : integer;
begin
  inherited;
{  rcvdRSTEdit.Left := 14*CWid + 3 + offset;
  rcvdRSTEdit.Width := 3*CWid+1;

  NumberEdit.Left := 17*CWid + 4 + offset;
  NumberEdit.Width := 5*CWid+1;

  BandEdit.Left := 22*CWid + 5 + offset;
  BandEdit.Width := 4*CWid+1;

  ModeEdit.Left := 26*CWid + 6 + offset;
  ModeEdit.Width := 3*CWid+1; }

  {PowerEdit.Left := 40*CWid + 7 + offset;
  PowerEdit.Width := 3*CWid+1;}

  {PointEdit.Left := 29*CWid + 7 + offset;
  PointEdit.Width := 3*CWid+1;

  OpEdit.Left := 35*Cwid + 8 + offset;
  OpEdit.Width := 6*Cwid + 1;

  MemoEdit.Left := 41*CWid + 9 + offset;
  MemoEdit.Width := 7*CWid + 1;

  if Options.MultiOp = false then
    begin
      OpEdit.Visible := false;
      MemoEdit.Left := (38-3)*Cwid + 9 + offset;
      MemoEdit.Width := (10+6)*CWid + 1;
    end; }
end;

end.
