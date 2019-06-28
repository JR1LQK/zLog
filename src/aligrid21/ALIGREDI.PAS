unit AligrEdi;
{ The component editor for the TStringAlignGrid. }
(*$p+,t+,x+,b-*)
  (*$i ah_def.inc *)
(*@/// interface *)
interface

(*@/// uses *)
uses
  SysUtils,
  typinfo,
(*$ifdef delphi_1 *)
  WinTypes,
  WinProcs,
(*$else *)
  windows,
(*$endif *)
  Messages,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Grids,
  (*$ifdef delphi_ge_6 *)
  designintf,
  designeditors,
  (*$else *)
  dsgnintf,
  (*$endif *)
  stdctrls,
  buttons,
  Spin,
  ExtCtrls,
  menus,
  aligrid;
(*@\\\0000001703*)

type
(*@///   TGridComponentEditor = class(TComponentEditor) *)
TGridComponentEditor = class(TComponentEditor)
public
  procedure Edit; override;
  end;
(*@\\\*)
(*@\\\0000000601*)
(*@/// implementation *)
implementation

{$R aligredi.DFM}

type
(*@///   Taligrid_edit=class(TForm) *)
Taligrid_edit = class(TForm)
  grid: TStringAlignGrid;
  btn_ok: TButton;
  btn_cancel: TButton;
  grp_edit: TGroupBox;
  btn_left: TSpeedButton;
  btn_right: TSpeedButton;
  btn_center: TSpeedButton;
  btn_ww_none: TSpeedButton;
  btn_ww_wrap: TSpeedButton;
  btn_ww_elli: TSpeedButton;
  btn_color: TSpeedButton;
  btn_font: TSpeedButton;
  edt_read: TCheckBox;
  grp_what: TRadioGroup;
  edt_width: TSpinEdit;
  lbl_width: TLabel;
  grp_cell: TRadioGroup;
  FontDialog: TFontDialog;
  ColorDialog: TColorDialog;
  lbl_height: TLabel;
  edt_height: TSpinEdit;
  procedure btn_colorClick(Sender: TObject);
  procedure btn_fontClick(Sender: TObject);
  procedure gridSelectCell(Sender: TObject; Col,Row:Longint; var CanSelect:Boolean);
  procedure grp_whatClick(Sender: TObject);
  procedure grp_cellClick(Sender: TObject);
  procedure btn_alignClick(Sender: TObject);
  procedure btn_wrapClick(Sender: TObject);
  procedure edt_readClick(Sender: TObject);
  procedure edt_wh_Change(Sender: TObject);
public
  component_editor: TGridComponentEditor;
  procedure Update_Group(col,row:longint);
private
  changing: boolean;
  show_cell: integer;
end;
(*@\\\*)
(*@///   THackGrid    =class(TStringAligngrid) *)
(* a nasty hack: to access the protected variables and methods of an object
   it is enough to create an empty descendent of this object and to typecast
   any original object to the descendent - so the compiler then allows to
   access the variables/methods, but as nothing of the VMT etc. is changed by
   this deriving the code produced is absolutely the same. Of course one
   could declare them public in first place, but as modifying the internal
   stuff isn't that easy I dopn't wnat to open it to everyone, but I need it
   here as the TGridComponentEditor brings the unit aligrid above the
   code segment maximum size in 16 bit.                                     *)

THackGrid=class(TStringaligngrid)
  end;
(*@\\\*)

(*@/// Some internal help routines for copying the internal lists *)
(*@/// function CopyStringCell(Source,Target:TList; ColCount,RowCount:integer):boolean; *)
function CopyStringCell(Source,Target:TList; ColCount,RowCount:integer):boolean;
var
  v,w:pstring;
  ACol,ARow: integer;
begin
  result:=false;
  for ACol:=0 to Colcount-1 do
    for ARow:=0 to Rowcount-1 do begin
      v:=GetItemCell(ACol,ARow,Source);
      if v<>NIL then begin
        result:=true;
        w:=NewStr(v^);
        end
      else
        w:=NIL;
      w:=SetItemCell(ACol,ARow, Target, w);
      if w<>NIL then
        DisposeStr(w);
      end;
  end;
(*@\\\0000000A01*)
(*@/// function CopyPropCell(Source,Target:TList; ColCount,RowCount:integer; grid:THackGrid):boolean; *)
function CopyPropCell(Source,Target:TList; ColCount,RowCount:integer; grid:THackGrid):boolean;
var
  v,w:TCellProperties;
  ACol,ARow: integer;
begin
  result:=false;
  for ACol:=0 to Colcount-1 do
    for ARow:=0 to Rowcount-1 do begin
      v:=GetItemCell(ACol,ARow,Source);
      if v<>NIL then begin
        result:=true;
        w:=v.clone;
        if w.font<>NIL then
          w.font.OnChange:=grid.fontchanged;
        if w.brush<>NIL then
          w.brush.OnChange:=grid.brushchanged;
        if w.selfont<>NIL then
          w.selfont.OnChange:=grid.fontchanged;
        if w.selbrush<>NIL then
          w.selbrush.OnChange:=grid.brushchanged;
        end
      else
        w:=NIL;
      w:=SetItemCell(ACol,ARow, Target, w);
      w.free;
      end;
  end;
(*@\\\0000001424*)
(*@/// function CopyPropCol(Source,Target:TList; Count:integer; grid:THackGrid):boolean; *)
function CopyPropCol(Source,Target:TList; Count:integer; grid:THackGrid):boolean;
var
  v,w:TCellProperties;
  ACol: integer;
begin
  result:=false;
  for ACol:=0 to Count-1 do begin
    v:=GetItemCol(ACol,Source);
    if v<>NIL then begin
      result:=true;
      w:=v.clone;
      if w.font<>NIL then
        w.font.OnChange:=grid.fontchanged;
      if w.brush<>NIL then
        w.brush.OnChange:=grid.brushchanged;
      if w.selfont<>NIL then
        w.selfont.OnChange:=grid.fontchanged;
      if w.selbrush<>NIL then
        w.selbrush.OnChange:=grid.brushchanged;
      end
    else
      w:=NIL;
    w:=SetItemCol(ACol, Target, w);
    w.free;
    end;
  end;
(*@\\\0000000D1A*)
(*@\\\0000000201*)

(*@/// TGridComponentEditor = class(TComponentEditor) // The component editor *)
{ TGridComponentEditor }
(*@/// procedure TGridComponentEditor.Edit;                          // OnCreate *)
procedure TGridComponentEditor.Edit;
var
  source: THackgrid;
  _grid: THackgrid;
  _form: Taligrid_edit;
  i: longint;
begin
  source:=THackGrid(component as TStringAlignGrid);
  _form:=Taligrid_edit.Create(NIL);
  _grid:=THackGrid(_form.grid);
  if _grid.FCell=NIL then _grid.FCell:=TList.Create;
(*@///   set grid data *)
_grid.options:=[goVertLine,goHorzLine,goEditing];   {goRowSizing,goColSizing}
_grid.fixedrows:=0;
_grid.fixedcols:=0;
if newstylecontrols then
  _grid.DefaultRowHeight:=18;
_grid.FAlwaysEdit:=true;
if source<>NIL then begin
  _grid.wordwrap:=source.wordwrap;
  _grid.defaultColWidth:=source.defaultColWidth;
  _grid.defaultRowHeight:=source.defaultRowHeight;
  _grid.f_Fixedcols:=source.fixedcols;
  _grid.f_fixedrows:=source.fixedrows;
  _grid.colcount:=source.colcount;
  _grid.rowcount:=source.rowcount;
  for i:=source.colcount-1 downto 0 do
    if source.colwidths[i]<>source.defaultColWidth then
      _grid.ColWidths[i] :=source.colwidths[i];
  for i:=source.rowcount-1 downto 0 do
    if source.rowheights[i]<>source.defaultRowHeight then
      _grid.rowheights[i] :=source.rowheights[i];
  _grid.color:=source.color;
  _grid.fixedcolor:=source.fixedcolor;
  _grid.font:=source.font;
(*@///   copy lists source -> grid *)
CopyPropCell (source.FPropCell,_grid.FPropCell,source.colcount,source.rowcount,_grid);
CopyPropCol  (source.FPropCol ,_grid.FPropCol ,source.colcount,_grid);
CopyPropCol  (source.FFPropCol,_grid.FFPropCol,source.colcount,_grid);
CopyPropCol  (source.FPropRow ,_grid.FPropRow ,source.rowcount,_grid);
CopyPropCol  (source.FFPropRow,_grid.FFPropRow,source.rowcount,_grid);
CopyStringCell(source.FHintCell ,_grid.FHintCell,source.colcount,source.rowcount);
CopyStringCell(source.FCell     ,_grid.FCell,source.colcount,source.rowcount);
(*@\\\000000074F*)
  _grid.ListToCells(_grid.FCell);
  end;
(*@\\\000C001501001501*)
  _form.Update_Group(_grid.col,_grid.row);
  if _form.ShowModal=mrOK then begin
    if _form.show_cell=0 then
      _grid.CellsToList(_grid.FCell)
    else
      _grid.CellsToList(_grid.FHintCell);
    if source<>NIL then begin
(*@///       Data grid -> source *)
for i:=_grid.colcount-1 downto 0 do
  if _grid.colwidths[i]<>_grid.defaultColWidth then
    source.ColWidths[i] :=_grid.colwidths[i];
for i:=_grid.rowcount-1 downto 0 do
  if _grid.rowheights[i]<>_grid.defaultRowHeight then
    source.rowheights[i] :=_grid.rowheights[i];

source.FSaveHint     :=CopyStringCell(_grid.FHintCell ,source.FHintCell,source.colcount,source.rowcount);
source.FSaveCells    :=CopyStringCell(_grid.FCell     ,source.FCell,source.colcount,source.rowcount);
CopyPropCell (_grid.FPropCell,source.FPropCell,source.colcount,source.rowcount,source);
CopyPropCol  (_grid.FPropCol ,source.FPropCol ,source.colcount,source);
CopyPropCol  (_grid.FFPropCol,source.FFPropCol,source.colcount,source);
CopyPropCol  (_grid.FPropRow ,source.FPropRow ,source.rowcount,source);
CopyPropCol  (_grid.FFPropRow,source.FFPropRow,source.rowcount,source);
(*@\\\0032000A01000E01000A01000A01*)
      if source.FCell<>NIL then
        source.ListToCells(source.FCell);
      end;
    if GetParentForm(source).Designer<>NIL then
      GetParentForm(source).Designer.Modified;
    end;
  _form.Free;
  end;
(*@\\\0000001401*)
(*@\\\0000000201*)
(*@/// Taligrid_edit        = class(TForm)            // The edit form itself *)
{ Taligrid_edit }
(*@/// procedure Taligrid_edit.btn_colorClick(Sender: TObject); *)
procedure Taligrid_edit.btn_colorClick(Sender: TObject);
var
  ACol,ARow: longint;
  _grid: THackgrid;
  result: boolean;
begin
  if changing then EXIT;
  try
    changing:=true;
    _grid:=THackgrid(grid);
    ACol:=grid.col;
    ARow:=grid.row;
(*@///     Colordialog.Color:=...; *)
case grp_what.itemindex of
  0: Colordialog.Color:=_grid.GetColorCell(ACol,ARow);
  1: Colordialog.Color:=_grid.GetColorCol(ACol);
  2: Colordialog.Color:=_grid.GetFixColorCol(ACol);
  3: Colordialog.Color:=_grid.GetColorRow(ARow);
  4: Colordialog.Color:=_grid.GetFixColorRow(ARow);
  else ;  (* this cant happen *)
  end;
(*@\\\0000000701*)
    result:=ColorDialog.execute;
    btn_color.down:=result;
    if result then
(*@///       _grid.SetColor...(...,Colordialog.Color); *)
case grp_what.itemindex of
  0: _grid.SetColorCell(ACol,ARow,Colordialog.Color);
  1: _grid.SetColorCol(ACol,Colordialog.Color);
  2: _grid.SetFixColorCol(ACol,Colordialog.Color);
  3: _grid.SetColorRow(ARow,Colordialog.Color);
  4: _grid.SetFixColorRow(ARow,Colordialog.Color);
  else ;  (* this cant happen *)
  end
(*@\\\0000000801*)
    else
(*@///       _grid.ResetColor...(...); *)
case grp_what.itemindex of
  0: _grid.ResetColorCell(ACol,ARow);
  1: _grid.ResetColorCol(ACol);
  2: _grid.ResetColorFixedCol(ACol);
  3: _grid.ResetColorRow(ARow);
  4: _grid.ResetColorFixedRow(ARow);
  else ;  (* this cant happen *)
  end;
(*@\\\0000000801*)
    if _grid.edit_visible then _grid.Update_Edit;
  finally
    changing:=false;
    end;
  end;
(*@\\\0000001301*)
(*@/// procedure Taligrid_edit.btn_fontClick(Sender: TObject); *)
procedure Taligrid_edit.btn_fontClick(Sender: TObject);
var
  ACol,ARow: longint;
  _grid: THackgrid;
  result: boolean;
begin
  if changing then EXIT;
  try
    changing:=true;
    _grid:=THackgrid(grid);
    ACol:=grid.col;
    ARow:=grid.row;
(*@///     Fontdialog.Font:=...; *)
case grp_what.itemindex of
  0: Fontdialog.Font:=_grid.GetFontCell(ACol,ARow);
  1: Fontdialog.Font:=_grid.GetFontCol(ACol);
  2: Fontdialog.Font:=_grid.GetFontFixedCol(ACol);
  3: Fontdialog.Font:=_grid.GetFontRow(ARow);
  4: Fontdialog.Font:=_grid.GetFontFixedRow(ARow);
  else  font:=NIL;  (* this cant happen *)
  end;
(*@\\\0000000701*)
    result:=FontDialog.execute;
    btn_font.down:=result;
    if result then
(*@///       _grid.SetFont...(...,fontdialog.font); *)
case grp_what.itemindex of
  0: _grid.SetFontCell(ACol,ARow,fontdialog.font);
  1: _grid.SetFontCol(ACol,fontdialog.font);
  2: _grid.SetFontFixedCol(ACol,fontdialog.font);
  3: _grid.SetfontRow(ARow,fontdialog.font);
  4: _grid.SetFontFixedRow(ARow,fontdialog.font);
  end
(*@\\\0000000401*)
    else
(*@///       _grid.Resetfont...(...); *)
case grp_what.itemindex of
  0: _grid.ResetfontCell(ACol,ARow);
  1: _grid.ResetfontCol(ACol);
  2: _grid.ResetfontFixedCol(ACol);
  3: _grid.ResetfontRow(ARow);
  4: _grid.ResetfontFixedRow(ARow);
  end;
(*@\\\0000000206*)
    if _grid.edit_visible then _grid.Update_Edit;
  finally
    changing:=false;
    end;
  end;
(*@\\\*)
(*@/// procedure Taligrid_edit.edt_readClick(Sender: TObject); *)
procedure Taligrid_edit.edt_readClick(Sender: TObject);
var
  ACol,ARow: longint;
  _grid: THackgrid;
begin
  if changing then EXIT;
  try
    changing:=true;
    _grid:=THackgrid(grid);
    ACol:=grid.col;
    ARow:=grid.row;
    case edt_read.state of
(*@///       cbUnChecked: *)
cbUnChecked:
  case grp_what.itemindex of
    0: _grid.EditCell[ACol,ARow]:=true;
    1: _grid.EditCol[ACol]:=true;
    3: _grid.EditRow[ARow]:=true;
    end;
(*@\\\0000000105*)
(*@///       cbGrayed: *)
cbGrayed:
  case grp_what.itemindex of
    0: _grid.ResetEditCell(ACol,ARow);
    1: _grid.ResetEditCol(ACol);
    3: _grid.ResetEditRow(ARow);
    end;
(*@\\\*)
(*@///       cbChecked: *)
cbChecked:
  case grp_what.itemindex of
    0: _grid.EditCell[ACol,ARow]:=false;
    1: _grid.EditCol[ACol]:=false;
    2: _grid.EditRow[ARow]:=false;
    end;
(*@\\\0000000103*)
      end;
  finally
    changing:=false;
    end;
  end;
(*@\\\0000000D01*)
(*@/// procedure Taligrid_edit.btn_alignClick(Sender: TObject); *)
procedure Taligrid_edit.btn_alignClick(Sender: TObject);
var
  ACol,ARow: longint;
  _grid: THackgrid;
begin
  if changing then EXIT;
  try
    changing:=true;
    _grid:=THackgrid(grid);
    ACol:=grid.col;
    ARow:=grid.row;
    if false then
(*@///     else if btn_left.down then *)
else if btn_left.down then begin
  case grp_what.itemindex of
    0: _grid.AlignCell[ACol,ARow]:=alLeft;
    1: _grid.AlignCol[ACol]      :=alLeft;
    2: _grid.FixAlignCol[ACol]   :=alLeft;
    3: _grid.AlignRow[ARow]      :=alLeft;
    4: _grid.FixAlignRow[ARow]   :=alLeft;
    end;
  end
(*@\\\*)
(*@///     else if btn_right.down then *)
else if btn_right.down then begin
  case grp_what.itemindex of
    0: _grid.AlignCell[ACol,ARow]:=alRight;
    1: _grid.AlignCol[ACol]      :=alRight;
    2: _grid.FixAlignCol[ACol]   :=alRight;
    3: _grid.AlignRow[ARow]      :=alRight;
    4: _grid.FixAlignRow[ARow]   :=alRight;
    end;
  end
(*@\\\0000000326*)
(*@///     else if btn_center.down then *)
else if btn_center.down then begin
  case grp_what.itemindex of
    0: _grid.AlignCell[ACol,ARow]:=alCenter;
    1: _grid.AlignCol[ACol]      :=alCenter;
    2: _grid.FixAlignCol[ACol]   :=alCenter;
    3: _grid.AlignRow[ARow]      :=alCenter;
    4: _grid.FixAlignRow[ARow]   :=alCenter;
    end;
  end
(*@\\\0000000201*)
(*@///     else ResetAlignment *)
else begin
  case grp_what.itemindex of
    0: _grid.ResetAlignCell(ACol,ARow);
    1: _grid.ResetAlignCol(ACol);
    2: _grid.ResetAlignFixedCol(ACol);
    3: _grid.ResetAlignRow(ARow);
    4: _grid.ResetAlignFixedRow(ARow);
    end;
  end;
(*@\\\*)
    if _grid.edit_visible then _grid.Update_Edit;
  finally
    changing:=false;
    end;
  end;
(*@\\\*)
(*@/// procedure Taligrid_edit.btn_wrapClick(Sender: TObject); *)
procedure Taligrid_edit.btn_wrapClick(Sender: TObject);
var
  ACol,ARow: longint;
  _grid: THackgrid;
begin
  if changing then EXIT;
  try
    changing:=true;
    _grid:=THackgrid(grid);
    ACol:=grid.col;
    ARow:=grid.row;
    if false then
(*@///     else if btn_ww_none.down then *)
else if btn_ww_none.down then begin
  case grp_what.itemindex of
    0: _grid.WordwrapCell[ACol,ARow]:=ww_none;
    1: _grid.WordwrapCol[ACol]      :=ww_none;
    2: _grid.FixWordwrapCol[ACol]   :=ww_none;
    3: _grid.WordwrapRow[ARow]      :=ww_none;
    4: _grid.FixWordwrapRow[ARow]   :=ww_none;
    end;
  end
(*@\\\0000000114*)
(*@///     else if btn_ww_wrap.down then *)
else if btn_ww_wrap.down then begin
  case grp_what.itemindex of
    0: _grid.WordwrapCell[ACol,ARow]:=ww_wordwrap;
    1: _grid.WordwrapCol[ACol]      :=ww_wordwrap;
    2: _grid.FixWordwrapCol[ACol]   :=ww_wordwrap;
    3: _grid.WordwrapRow[ARow]      :=ww_wordwrap;
    4: _grid.FixWordwrapRow[ARow]   :=ww_wordwrap;
    end;
  end
(*@\\\0000000114*)
(*@///     else if btn_ww_elli.down then *)
else if btn_ww_elli.down then begin
  case grp_what.itemindex of
    0: _grid.WordwrapCell[ACol,ARow]:=ww_ellipsis;
    1: _grid.WordwrapCol[ACol]      :=ww_ellipsis;
    2: _grid.FixWordwrapCol[ACol]   :=ww_ellipsis;
    3: _grid.WordwrapRow[ARow]      :=ww_ellipsis;
    4: _grid.FixWordwrapRow[ARow]   :=ww_ellipsis;
    end;
  end
(*@\\\0000000301*)
(*@///     else ResetWordwrap *)
else begin
  case grp_what.itemindex of
    0: _grid.ResetWordwrapCell(ACol,ARow);
    1: _grid.ResetWordwrapCol(ACol);
    2: _grid.ResetWordwrapFixedCol(ACol);
    3: _grid.ResetWordwrapRow(ARow);
    4: _grid.ResetWordwrapFixedRow(ARow);
    end;
  end;
(*@\\\*)
  finally
    changing:=false;
    end;
  end;
(*@\\\0000000119*)
(*@/// procedure Taligrid_edit.grp_cellClick(Sender: TObject); *)
procedure Taligrid_edit.grp_cellClick(Sender: TObject);
var
  _grid: THackgrid;
begin
  _grid:=THackgrid(grid);
  if grp_cell.itemindex=show_cell then EXIT;
  _grid.Hideedit(false);
  show_cell:=grp_cell.itemindex;
  case show_cell of
    0: begin
      _grid.CellsToList(_grid.FHintCell);
      _grid.ListToCells(_grid.FCell);
      end;
    1: begin
      _grid.CellsToList(_grid.FCell);
      _grid.ListToCells(_grid.FHintCell);
      end;
    end;
  end;
(*@\\\0000000711*)
(*@/// procedure Taligrid_edit.gridSelectCell(Sender: TObject; Col,  Row: Longint...); *)
procedure Taligrid_edit.gridSelectCell(Sender: TObject; Col,
  Row: Longint; var CanSelect: Boolean);
begin
  Update_Group(col,row);
  end;
(*@\\\0000000401*)
(*@/// procedure Taligrid_edit.grp_whatClick(Sender: TObject); *)
procedure Taligrid_edit.grp_whatClick(Sender: TObject);
begin
  Update_Group(grid.col,grid.row);
  end;
(*@\\\0000000301*)
(*@/// procedure Taligrid_edit.edt_wh_Change(Sender: TObject); *)
procedure Taligrid_edit.edt_wh_Change(Sender: TObject);
begin
  if changing then EXIT;
  grid.ColWidths[grid.col]:=edt_width.value;
  grid.RowHeights[grid.row]:=edt_height.value;
  end;
(*@\\\0000000401*)

(*@/// procedure Taligrid_edit.Update_Group(col,row:longint); *)
procedure Taligrid_edit.Update_Group(col,row:longint);
var
  v:TCellProperties;
  Alignment: TMyAlign;
  wordwrap: t_wordwrap;
  editable: byte;
  font,brush: pointer;
  _grid: THackgrid;
begin
  try
    changing:=true;
    _grid:=THackgrid(grid);
    if (Col>=0) or (Row>=0) then begin
      case grp_what.itemindex of
        0: v:=GetItemCell(Col,Row,_grid.FPropCell);
        1: v:=GetItemCol(Col,_grid.FPropCol);
        2: v:=GetItemCol(Col,_grid.FFPropCol);
        3: v:=GetItemCol(Row,_grid.FPropRow);
        4: v:=GetItemCol(Row,_grid.FFPropRow);
        else  v:=NIL;
        end;
(*@///       Set alignment checks *)
if v=NIL then
  Alignment:=alDefault
else
  Alignment:=v.align;

case alignment of
  alRight : btn_right.down:=true;
  alLeft  : btn_left.down:=true;
  alCenter: btn_center.down:=true;
  alDefault: begin
    btn_left.down:=false;
    btn_right.down:=false;
    btn_center.down:=false;
    end;
  end;
(*@\\\0000000201*)
(*@///       Set wordwrap checks *)
if v=NIL then
  Wordwrap:=ww_Default
else
  Wordwrap:=v.wordwrap;

case Wordwrap of
  ww_none     : btn_ww_none.down:=true;
  ww_wordwrap : btn_ww_wrap.down:=true;
  ww_ellipsis : btn_ww_elli.down:=true;
  ww_default  : begin
    btn_ww_none.down:=false;
    btn_ww_wrap.down:=false;
    btn_ww_elli.down:=false;
    end;
  end;
(*@\\\*)
(*@///       Set editable checks *)
edt_read.enabled:=(grp_what.itemindex<>2) and (grp_what.itemindex<>4);

if (v=NIL) or (grp_what.itemindex=2) or (grp_what.itemindex=4) then
  editable:=0
else
  editable:=v.editable;

case editable of
  0: edt_read.state:=cbGrayed;
  2: edt_read.state:=cbUnChecked;
  1: edt_read.state:=cbChecked;
  end;
(*@\\\0000000A04*)
(*@///       Set font checks *)
if v=NIL then
  font:=NIL
else
  font:=v.font;

if (font=NIL) or not TMyFont(font).Haschanged then
  btn_font.down:=false
else
  btn_font.down:=true;
(*@\\\*)
(*@///       Set color/brush checks *)
if v=NIL then
  brush:=NIL
else
  brush:=v.brush;

if (Brush=NIL) or not TMyBrush(Brush).Haschanged then
  btn_color.down:=false
else
  btn_color.down:=true;
(*@\\\0000000801*)
      edt_width.value :=grid.ColWidths[col] ;
      edt_height.value:=grid.RowHeights[row];
      case grp_what.itemindex of
        0: grp_edit.caption:='Cell '+inttostr(col)+'/'+inttostr(row);
        1: grp_edit.caption:='Column '+inttostr(col);
        2: grp_edit.caption:='Fixed column '+inttostr(col);
        3: grp_edit.caption:='Row '+inttostr(row);
        4: grp_edit.caption:='Fixed Row '+inttostr(row);
        end;
      end;
  finally
    changing:=false;
    end;
  end;
(*@\\\0000001801*)
(*@\\\0000000110*)
(*@\\\0000000B01*)
end.
(*@\\\0001000015000601*)
