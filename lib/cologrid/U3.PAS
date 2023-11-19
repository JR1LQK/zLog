unit U3;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, Cologrid, ExtCtrls, StdCtrls, Moneybar, Menus;

type
  TForm2 = class(TForm)
    Mgrid1: TMgrid;
    PopupMenu1: TPopupMenu;
    Selectoption11: TMenuItem;
    SelectOption21: TMenuItem;
    Option31: TMenuItem;
    procedure Mgrid1Setting(ARow, Acol: Longint; var Fcolor: Longint;
      var Bold, Italic, underline: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.DFM}

procedure TForm2.Mgrid1Setting(ARow, Acol: Longint; var Fcolor: Longint;
  var Bold, Italic, underline: Boolean);
begin
if acol = 0 then
 begin
   fcolor := clblue;
   bold := true;
 end;
if arow = 0 then
 begin
   fcolor := clblue;
   bold := true;
 end;
if (acol = 2) and (arow> 0) then
 begin
   fcolor := clred;
   bold := true;
   italic := true;
 end;
if (acol = 4) and (arow> 0) then
 begin
   fcolor := clgreen;
   bold := true;
   italic := true;
   underline := true
 end;
end;

procedure TForm2.FormCreate(Sender: TObject);
var i,f : byte;
begin
for i := 0 to 9 do
 for f := 0 to 9 do
   Mgrid1.cells[f,i] := inttostr(i) + 'x' + inttostr(f);

end;

end.

pallete
