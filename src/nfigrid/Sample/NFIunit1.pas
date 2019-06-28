// Simple Control useage sample by James Tallent
unit NFIunit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  NFIGrid, StdCtrls;

type
  TForm1 = class(TForm)
    NFIGrid1: TNFIGrid;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure NFIGrid1ButtonClick(Sender: TNFIGridItem; Button: TButton);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure NFIGrid1ComboBoxChange(Sender: TNFIGridItem;
      ComboBox: TComboBox);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

//----------------------------------------
procedure TForm1.Button1Click(Sender: TObject);
 var Item1:TNFIGridItem;
begin
  Item1 := NFIGrid1.items.itemforcell[1,1];
  if item1.checkbox.checked = true  then item1.checkbox.checked := false else
  if item1.checkbox.checked = false then item1.checkbox.checked := true;
end;
//------------------------------------------
procedure TForm1.Button2Click(Sender: TObject);
 var Item1:TNFIGridItem;
begin
  Item1 := NFIGrid1.items.itemforcell[0,2];
  item1.checkbox.text := 'Caption 2';
end;
//-----------------------------------------
procedure TForm1.Button3Click(Sender: TObject);
 var Item1:TNFIGridItem;
 var j:word;
begin
  NFIGrid1.rowcount := NFIGrid1.rowcount + 1;
  j := NFIGrid1.rowcount-1;
  NFIGrid1.items.Add(0, j, grtCheckBox);
  Item1 := NFIGrid1.items.itemforcell[0,j];
  item1.checkbox.checked := true;
  item1.checkbox.text    := 'Caption '+inttostr(j);

end;
//-------------------------------------
procedure TForm1.Button4Click(Sender: TObject);
 var Item1:TNFIGridItem;
begin
  Item1 := NFIGrid1.items.itemforcell[1,3];
  item1.combobox.itemindex := 1;
end;
//-----------------------------------
procedure TForm1.NFIGrid1ButtonClick(Sender: TNFIGridItem;
  Button: TButton);
begin
   MessageDlg('You Clicked the NFI Button in Col: '+inttostr(NFIGrid1.col)+' Row: '+inttostr(NFIGrid1.row), mtInformation,[mbOk], 0);

end;
//-------------------------------------
procedure TForm1.Button5Click(Sender: TObject);
 var Item1:TNFIGridItem;
begin
  Item1 := NFIGrid1.items.itemforcell[1,6];
  Item1.text := 'Hello World';
end;
//------------------------------------
procedure TForm1.FormCreate(Sender: TObject);
 var Item1:TNFIGridItem;
begin
  Item1 := NFIGrid1.items.itemforcell[1,3];
  item1.combobox.itemindex := 0;

  Item1 := NFIGrid1.items.itemforcell[0,2];
  item1.combobox.itemindex := 2;
end;
//------------------------------------
procedure TForm1.Button6Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.NFIGrid1ComboBoxChange(Sender: TNFIGridItem;
  ComboBox: TComboBox);
begin
  MessageDlg('You Clicked the NFI Button in Col: '+inttostr(NFIGrid1.col)+' Row: '+inttostr(NFIGrid1.row), mtInformation,[mbOk], 0);
end;

end.
