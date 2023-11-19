unit Aligrid;
(*$p+,t+,x+,b-*)
  { These are needed, especially the p must be the same as in forms }
  (*$i ah_def.inc *)
(*$ifdef Delphi_1 *)
  (*$d- *)   { Sorry, no debugging with Delphi 1, the unit is too complex }
(*$endif *)

{ Copyright 1995-2000 Andreas Hörstemeier            Version 2.0 2000-02-12  }
{ this component is public domain - please check aligrid.hlp for             }
{ detailed info on usage and distributing                                    }

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
  ExtCtrls,
  Grids,
  stdctrls,
{   buttons, }
  menus,
  ah_tool;
(*@\\\0000001401*)

const
  (*@/// control messages from and to the inplace edit *)
    cn_edit_cancel = wm_user+2000;  (* edit finished with ESC *)
    cn_edit_return = wm_user+2001;  (* edit finished with return *)
    cn_edit_exit   = wm_user+2002;  (* edit finished otherwise (cursor) *)
    cn_edit_show   = wm_user+2003;  (* edit is about to be shown *)
    cn_edit_toshow = wm_user+2004;  (* internal: show the editor *)
    cn_edit_update = wm_user+2005;  (* internal: editor position must be updated *)
  (*@\\\*)

type
  TMyAlign=(alRight,alLeft,alCenter,alDefault);
  T_nextcell=(nc_rightdown, nc_downright, nc_leftdown, nc_downleft,
              nc_leftup,    nc_upleft,    nc_rightup,  nc_upright);
  T_lastcell=(lc_newcolrow, lc_stop, lc_first, lc_exit);
  T_Wordwrap=(ww_none, ww_wordwrap, ww_ellipsis,ww_default);
  TCellEvent = procedure (Sender:TObject; col,row:longint) of object;
  TCellEventBool = procedure (Sender:TObject; col,row:longint; var result:boolean) of object;
  TCellDrawEvent = procedure (Sender:TObject; col,row:longint;
    var align:TMyAlign; var Wordwrap: T_Wordwrap);
  TColEvent = procedure (Sender:TObject; col:longint) of object;
  TRowEvent = procedure (Sender:TObject; row:longint) of object;
  TShowHintCellProc = procedure (Sender:TObject; col,row:longint; var HintStr: string;
    var CanShow: Boolean; var HintInfo: THintInfo) of object;
  t_relation = (rel_greater, rel_equal, rel_less);
  t_colrow = (c_column,c_fixed_column, c_row, c_fixed_row);
(*$ifdef delphi_ge_3 *)
  (*@/// THintMessage=record end; *)
  THintMessage=record
    Msg: Cardinal;
    Unused: Integer;
    HintInfo: PHintInfo;
    Result: Longint;
    end;
  (*@\\\0000000401*)
(*$endif *)
  TCompareFunction = function(Sender:TObject; colrow,compare1,compare2:longint):t_relation of object;
  TSortFunction = procedure (ColRow,Min,Max: longint; ByColumn,ascending: boolean) of object;
  TStringAlignGrid=class;  (* forward *)
  (*@/// TCellProperties=class(TObject) *)
  TCellProperties=class(TObject)
  protected
    f_grid: TStringAlignGrid;
    f_brush: TBrush;
    f_selBrush: TBrush;
    f_font: TFont;
    f_selfont: TFont;
    procedure SetFont(value: TFont);
    procedure SetSelFont(value: TFont);
    procedure SetBrush(value: TBrush);
    procedure SetSelBrush(value: TBrush);
    procedure WriteToWriter(writer:TWriter);   virtual;
    procedure ReadFromReader(Reader:TReader; grid:TStringAlignGrid);
    procedure ReadSingleProperty(Proptype:integer; Reader:TReader; grid:TStringAlignGrid);  virtual;
  public
    align: TMyAlign;
    wordwrap: T_Wordwrap;
    editable: byte;
    property brush:TBrush read f_brush write SetBrush;
    property selbrush:TBrush read f_selbrush write SetSelBrush;
    property Font:TFont read f_Font write SetFont;
    property selFont:TFont read f_selFont write SetSelFont;
    constructor Create(Grid:TStringAlignGrid);
    destructor destroy;                      override;
    procedure assign(value:TCellProperties); virtual;
    function isempty: boolean;               virtual;
    function clone:TCellProperties;          virtual;
    end;
  (*@\\\000000130B*)
  TCellPropertiesClass = class of TCellProperties;
  (*@/// TNewInplaceEdit = class(TInplaceEdit) *)
  TNewInplaceEdit = class(TInplaceEdit)
  private
    FAlignment: TMyAlign;
    f_multiline: boolean;
    procedure WMWindowPosChanged(var Message: TMessage); message WM_WINDOWPOSCHANGED;
    procedure EMSetSel(var Message: TMessage); message EM_SETSEL;
  protected
    Clicktime: longint;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SetAlignment(Value:TMyAlign);
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  (*$ifdef delphi_1 *)
    function GetGrid:TCustomGrid;
  (*$endif *)
    procedure UpdateContents;  (*$ifdef delphi_1 *) virtual; (*$else *) override; (*$endif *)
  public
    col, row: longint;  (* col and row of the cell *)
    event: boolean;     (* Before edit event already started? *)
    oldtext: string;    (* The text BEFORE the edit started *)
    { In Delphi 1's VCL the override is missing in TInplaceEdit }
    constructor Create(AOwner:TComponent); (*$ifndef delphi_1 *) override; (*$endif *)
    property Alignment: TMyAlign read FAlignment write SetAlignment;
    property MultiLine: boolean read f_multiline write f_multiline;
  (*$ifdef delphi_1 *)
    property  Grid: TCustomGrid read GetGrid;
  (*$endif *)
  (*$ifdef delphi_ge_3 *)
    property ImeMode;
    property ImeName;
  (*$endif *)
  end;
  (*@\\\0000001001*)
  (*@/// TStringAlignGrid=class(TStringGrid) *)
  TStringAlignGrid = class(TStringGrid)
  (*@/// -  The object creation, destroying and initalizing *)
  protected
    procedure Initialize;  virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  (*@\\\0000000201*)
  (*@/// -  The lists *)
  protected
    FPropCol: TList;
    FPropRow: TList;
    FFPropCol: TList;
    FFPropRow: TList;
    FPropCell: TList;

    FCellPropertiesClass:TCellPropertiesClass;

    function  GetObjectCol(ACol: longint):TCellProperties;
    procedure SetObjectCol(ACol: longint; const Value: TCellProperties);
    function  GetObjectRow(ARow: longint):TCellProperties;
    procedure SetObjectRow(ARow: longint; const Value: TCellProperties);
    function  GetObjectFixedCol(ACol: longint):TCellProperties;
    procedure SetObjectFixedCol(ACol: longint; const Value: TCellProperties);
    function  GetObjectFixedRow(ARow: longint):TCellProperties;
    procedure SetObjectFixedRow(ARow: longint; const Value: TCellProperties);

    function GetObjectCell(ACol,ARow: longint):TCellProperties;
    procedure SetObjectCell(ACol,ARow: longint; const Value: TCellProperties);

  protected
    property CellPropertiesClass:TCellPropertiesClass read FCellPropertiesClass write FCellPropertiesClass;
    property ObjectCell[ACol,ARow:longint]: TCellProperties read GetObjectCell write SetObjectCell;
    property ObjectRow[ACol:longint]: TCellProperties read GetObjectRow write SetObjectRow;
    property ObjectCol[ACol:longint]: TCellProperties read GetObjectCol write SetObjectCol;
    property ObjectFixedRow[ACol:longint]: TCellProperties read GetObjectFixedRow write SetObjectFixedRow;
    property ObjectFixedCol[ACol:longint]: TCellProperties read GetObjectFixedCol write SetObjectFixedCol;
  (*@\\\0000000801*)
  (*@/// +  Routines and variables for the alignments *)
  protected
    FAlign: TMyAlign;
    (*@/// The DFM read procedures (compatibility only) *)
    procedure ReadAlignCell(Stream: TStream);
    procedure ReadAlignCol(Stream: TStream);
    procedure ReadAlignRow(Stream: TStream);
    procedure ReadFixedAlignCol(Stream: TStream);
    procedure ReadFixedAlignRow(Stream: TStream);
    (*@\\\0000000201*)
    (*@/// property read/write for the alignments *)
    procedure SetAlign(const Value: TMyAlign);

    function GetAlignCol(ACol: longint):TMyAlign;
    procedure SetAlignCol(ACol: longint; const Value: TMyAlign);
    function GetFixAlignCol(ACol: longint):TMyAlign;
    procedure SetFixAlignCol(ACol: longint; const Value: TMyAlign);

    function GetAlignRow(ARow:longint):TMyAlign;
    procedure SetAlignRow(ARow:longint; const Value: TMyAlign);
    function GetFixAlignRow(ARow:longint):TMyAlign;
    procedure SetFixAlignRow(ARow:longint; const Value: TMyAlign);

    function GetAlignCell(ACol,ARow: longint):TMyAlign;
    procedure SetAlignCell(ACol,ARow: longint; const Value: TMyAlign);
    (*@\\\0000000301*)
    function ReadAlignColRow(Stream: TStream; colrow:t_colrow):boolean;
  {   procedure WriteAlignColRow(Stream: TStream; count: longint; list:TList); }
  public
    (*@/// property AlignCell/AlignCol/FixAlignCol/AlignRow/FixAlignRow *)
    property AlignCell[ACol,ARow:longint]: TMyAlign read GetAlignCell write SetAlignCell;
    property AlignCol[ACol:longint]: TMyAlign read GetAlignCol write SetAlignCol;
    property FixAlignCol[ACol:longint]: TMyAlign read GetFixAlignCol write SetFixAlignCol;
    property AlignRow[ARow:longint]: TMyAlign read GetAlignRow write SetAlignRow;
    property FixAlignRow[ARow:longint]: TMyAlign read GetFixAlignRow write SetFixAlignRow;
    (*@\\\0000000155*)
    (*@/// procedure ResetAlign...; *)
    procedure ResetAlignment;
    procedure ResetAlignCell(ACol,ARow:longint);
    procedure ResetAlignCol(ACol:longint);
    procedure ResetAlignFixedCol(ACol:longint);
    procedure ResetAlignRow(ARow:longint);
    procedure ResetAlignFixedRow(ARow:longint);

    procedure ResetAlignCellAll;
    procedure ResetAlignColAll;
    procedure ResetAlignRowAll;
    (*@\\\0000000801*)
  published
    property Alignment: TMyAlign read falign write SetAlign default alLeft;
  (*@\\\0000000B15*)
  (*@/// +  Routines and variables for the wordwraps *)
  protected
    f_wordwrap: T_Wordwrap;
    (*@/// property read/write for the wordwraps *)
    procedure SetWordWrap(value: T_Wordwrap);

    function GetWordwrapCol(ACol: longint):t_Wordwrap;
    procedure SetWordwrapCol(ACol: longint; const Value: t_Wordwrap);
    function GetFixWordwrapCol(ACol: longint):t_Wordwrap;
    procedure SetFixWordwrapCol(ACol: longint; const Value: t_Wordwrap);

    function GetWordwrapRow(ARow:longint):t_Wordwrap;
    procedure SetWordwrapRow(ARow:longint; const Value: t_Wordwrap);
    function GetFixWordwrapRow(ARow:longint):t_Wordwrap;
    procedure SetFixWordwrapRow(ARow:longint; const Value: t_Wordwrap);

    function GetWordwrapCell(ACol,ARow: longint):t_Wordwrap;
    procedure SetWordwrapCell(ACol,ARow: longint; const Value: t_Wordwrap);
    (*@\\\*)
  public
    (*@/// property WordwrapCell/WordwrapCol/FixWordwrapCol/WordwrapRow/FixWordwrapRow *)
    property WordwrapCell[ACol,ARow:longint]: t_Wordwrap read GetWordwrapCell write SetWordwrapCell;
    property WordwrapCol[ACol:longint]: t_Wordwrap read GetWordwrapCol write SetWordwrapCol;
    property FixWordwrapCol[ACol:longint]: t_Wordwrap read GetFixWordwrapCol write SetFixWordwrapCol;
    property WordwrapRow[ARow:longint]: t_Wordwrap read GetWordwrapRow write SetWordwrapRow;
    property FixWordwrapRow[ARow:longint]: t_Wordwrap read GetFixWordwrapRow write SetFixWordwrapRow;
    (*@\\\0000000401*)
    (*@/// procedure ResetWordwrap...; *)
    procedure ResetWordwrapCell(ACol,ARow:longint);
    procedure ResetWordwrapCol(ACol:longint);
    procedure ResetWordwrapFixedCol(ACol:longint);
    procedure ResetWordwrapRow(ARow:longint);
    procedure ResetWordwrapFixedRow(ARow:longint);

    procedure ResetWordwrapCellAll;
    procedure ResetWordwrapColAll;
    procedure ResetWordwrapRowAll;
    (*@\\\*)
  published
    property Wordwrap: T_Wordwrap read f_wordwrap write SetWordWrap default ww_none;
  (*@\\\0000000814*)
  (*@/// +  Routines and variables for the edit-enabled *)
  protected
    FEditable: boolean;   { allow switching on editing for single objects only }
    FAlwaysEdit: boolean; { for the component editor to have all cell editable }
    (*@/// The DFM read procedures (compatibility only) *)
    procedure ReadEditCell(Stream: TStream);
    procedure ReadEditCol(Stream: TStream);
    procedure ReadEditRow(Stream: TStream);

    { Utility functions }
    function ReadEditColRow(Stream: TStream; colrow:t_colrow):boolean;
    (*@\\\*)
    (*@/// property read/write for the edit-enabled *)
    function GetEditCol(ACol: longint):Boolean;
    procedure SetEditCol(ACol: longint; const Value: Boolean);

    function GetEditRow(ARow:longint):Boolean;
    procedure SetEditRow(ARow:longint; const Value: Boolean);

    function GetEditCell(ACol,ARow: longint):Boolean;
    procedure SetEditCell(ACol,ARow: longint; const Value: Boolean);
    (*@\\\*)
  public
    (*@/// property EditCell/EditCol/EditRow *)
    property EditCell[ACol,ARow:longint]: Boolean read GetEditCell write SetEditCell;
    property EditCol[ACol:longint]: Boolean read GetEditCol write SetEditCol;
    property EditRow[ARow:longint]: Boolean read GetEditRow write SetEditRow;
    (*@\\\000000010A*)
    (*@/// procedure ResetEdit...; *)
    procedure ResetEditCell(ACol,ARow:longint);
    procedure ResetEditCol(ACol:longint);
    procedure ResetEditRow(ARow:longint);

    procedure ResetEditCellAll;
    procedure ResetEditColAll;
    procedure ResetEditRowAll;
    (*@\\\000000071A*)
  published
    property Editable:boolean read FEditable write FEditable default true;
  (*@\\\0000000714*)
  (*@/// +  Routines and variables for the colors *)
  protected
    (*@/// The DFM read procedures (compatibility) *)
    procedure ReadColorCell(Reader: TReader);
    procedure ReadColorCol(Reader: TReader);
    procedure ReadColorRow(Reader: TReader);
    procedure ReadFixedColorCol(Reader: TReader);
    procedure ReadFixedColorRow(Reader: TReader);

    procedure ReadColorColRow(Reader: TReader; colrow:t_colrow);
    (*@\\\000000073B*)
    (*@/// property read/write for the colors *)
    function GetColorCol(ACol: longint):TColor;
    procedure SetColorCol(ACol: longint; const Value: TColor);
    function GetFixColorCol(ACol: longint):TColor;
    procedure SetFixColorCol(ACol: longint; const Value: TColor);

    function GetColorRow(ARow:longint):TColor;
    procedure SetColorRow(ARow:longint; const Value: TColor);
    function GetFixColorRow(ARow:longint):TColor;
    procedure SetFixColorRow(ARow:longint; const Value: TColor);

    function GetColorCell(ACol,ARow: longint):TColor;
    procedure SetColorCell(ACol,ARow: longint; const Value: TColor);

    procedure SetFixedColor(const Value: TColor);
    (*@\\\*)
    (*@/// variables and property read/write for alternating colors *)
    protected
      f_altcolcolor, f_altrowcolor: TColor;
      f_doaltcolcolor, f_doaltrowcolor: boolean;
      procedure setdoaltrowcolor(value:boolean);
      procedure setdoaltcolcolor(value:boolean);
      procedure setaltcolcolor(value:TColor);
      procedure setaltrowcolor(value:TColor);
    (*@\\\*)
  public
    (*@/// property ColorCell/ColorCol/FixColorCol/ColorRow/FixColorRow *)
    property ColorCell[ACol,ARow:longint]: TColor read GetColorCell write SetColorCell;
    property ColorCol[ACol:longint]: TColor read GetColorCol write SetColorCol;
    property FixColorCol[ACol:longint]: TColor read GetFixColorCol write SetFixColorCol;
    property ColorRow[ARow:longint]: TColor read GetColorRow write SetColorRow;
    property FixColorRow[ARow:longint]: TColor read GetFixColorRow write SetFixColorRow;
    (*@\\\0000000301*)
    (*@/// procedure ResetColor...; *)
    procedure ResetColorCell(ACol,ARow:longint);
    procedure ResetColorCol(ACol:longint);
    procedure ResetColorFixedCol(ACol:longint);
    procedure ResetColorRow(ARow:longint);
    procedure ResetColorFixedRow(ARow:longint);

    procedure ResetColorCellAll;
    procedure ResetColorColAll;
    procedure ResetColorRowAll;
    (*@\\\0000000701*)
    property AlternateColorCol: TColor read f_altcolcolor write setaltcolcolor default clWindow;
    property AlternateColorRow: TColor read f_altrowcolor write setaltrowcolor default clWindow;
    property DoAlternateColorCol: boolean read f_doaltcolcolor write setdoaltcolcolor default false;
    property DoAlternateColorRow: boolean read f_doaltrowcolor write setdoaltrowcolor default false;
  published
    property FixedColor write SetFixedColor;
  (*@\\\0000000A01*)
  (*@/// +  Routines and variables for the selected colors *)
  protected
    (*@/// The DFM read procedures (compatibility) *)
    procedure ReadSelColorCell(Reader: TReader);
    procedure ReadSelColorCol(Reader: TReader);
    procedure ReadSelColorRow(Reader: TReader);

    function ReadSelColorColRow(Reader: TReader; colrow:t_colrow):boolean;
    (*@\\\0000000501*)
  protected
    (*@/// property read/write for the colors *)
    f_SelCellColor: TColor;
    procedure SetSelCellColor(Value: TColor);

    function GetSelColorCol(ACol: longint):TColor;
    procedure SetSelColorCol(ACol: longint; const Value: TColor);

    function GetSelColorRow(ARow:longint):TColor;
    procedure SetSelColorRow(ARow:longint; const Value: TColor);

    function GetSelColorCell(ACol,ARow: longint):TColor;
    procedure SetSelColorCell(ACol,ARow: longint; const Value: TColor);
    (*@\\\0000000301*)
  public
    (*@/// property SelectedColorCell/SelectedColorCol/SelectedColorRow *)
    property SelectedColorCell[ACol,ARow:longint]: TColor read GetSelColorCell write SetSelColorCell;
    property SelectedColorCol[ACol:longint]: TColor read GetSelColorCol write SetSelColorCol;
    property SelectedColorRow[ARow:longint]: TColor read GetSelColorRow write SetSelColorRow;
    (*@\\\*)
    (*@/// procedure ResetColor...; *)
    procedure ResetSelectedColorCell(ACol,ARow:longint);
    procedure ResetSelectedColorCol(ACol:longint);
    procedure ResetSelectedColorRow(ARow:longint);

    procedure ResetSelectedColorCellAll;
    procedure ResetSelectedColorColAll;
    procedure ResetSelectedColorRowAll;
    (*@\\\*)
  published
    property SelectedCellColor:TColor read f_SelCellColor write SetSelCellColor default clActiveCaption;
  (*@\\\0000000901*)
  (*@/// +  Routines and variables for the selected font colors *)
  protected
    (*@/// The DFM read procedures (compatibility) *)
    procedure ReadSelFontColorCell(Reader: TReader);
    procedure ReadSelFontColorCol(Reader: TReader);
    procedure ReadSelFontColorRow(Reader: TReader);
    function ReadSelFontColorColRow(Reader:TReader; colrow:t_colrow):boolean;
    (*@\\\000000040A*)
  protected
    (*@/// property read/write for the colors *)
    f_SelFontColor: TColor;
    procedure SetSelFontColor(Value: TColor);

    function GetSelFontColorCol(ACol: longint):TColor;
    procedure SetSelFontColorCol(ACol: longint; const Value: TColor);

    function GetSelFontColorRow(ARow:longint):TColor;
    procedure SetSelFontColorRow(ARow:longint; const Value: TColor);

    function GetSelFontColorCell(ACol,ARow: longint):TColor;
    procedure SetSelFontColorCell(ACol,ARow: longint; const Value: TColor);
    (*@\\\000000010F*)
  public
    (*@/// property SelectedFontColorCell/SelectedFontColorCol/SelectedFontColorRow *)
    property SelectedFontColorCell[ACol,ARow:longint]: TColor read GetSelFontColorCell write SetSelFontColorCell;
    property SelectedFontColorCol[ACol:longint]: TColor read GetSelFontColorCol write SetSelFontColorCol;
    property SelectedFontColorRow[ARow:longint]: TColor read GetSelFontColorRow write SetSelFontColorRow;
    (*@\\\*)
    (*@/// procedure ResetColor...; *)
    procedure ResetSelectedFontColorCell(ACol,ARow:longint);
    procedure ResetSelectedFontColorCol(ACol:longint);
    procedure ResetSelectedFontColorRow(ARow:longint);

    procedure ResetSelectedFontColorCellAll;
    procedure ResetSelectedFontColorColAll;
    procedure ResetSelectedFontColorRowAll;
    (*@\\\*)
  published
    property SelectedFontColor:TColor read f_SelFontColor write SetSelFontColor default clWhite;
  (*@\\\0000000601*)
  (*@/// +  Routines and variables for the fonts *)
  protected
    FFixedFont: TFont;
    function FixedFontChanged:boolean;
    (*@/// The DFM read procedures (compatibility) *)
    procedure ReadFontCell(Reader: TReader);
    procedure ReadFontCol(Reader: TReader);
    procedure ReadFontRow(Reader: TReader);
    procedure ReadFixedFontCol(Reader: TReader);
    procedure ReadFixedFontRow(Reader: TReader);

    function ReadFontColRow(Reader: TReader; colrow:t_colrow):boolean;
    (*@\\\*)
    (*@/// property read/write for the fonts *)
    function GetFontCell(ACol,ARow: longint):TFont;
    procedure SetFontCell(ACol,ARow: longint; const Value: TFont);

    function GetFontCol(ACol: longint):TFont;
    procedure SetFontCol(ACol: longint; const Value: TFont);
    function GetFontFixedCol(ACol: longint):TFont;
    procedure SetFontFixedCol(ACol: longint; const Value: TFont);
    function GetFontRow(ARow: longint):TFont;
    procedure SetFontRow(ARow: longint; const Value: TFont);
    function GetFontFixedRow(ARow: longint):TFont;
    procedure SetFontFixedRow(ARow: longint; const Value: TFont);
    function GetFontColRowInternal(AColRow: longint; create:boolean; List:TList):TFont;

    procedure SetFixedFont(value: TFont);
    (*@\\\0000000E01*)
    (*@/// utility functions *)
    function GetFontCellComplete(ACol,ARow: longint):TFont;
    function GetFontCellInternal(ACol,ARow: longint; create:boolean):TFont;
    procedure FontChanged(AFont: TObject);
    (*@\\\0000000316*)
  public
    (*@/// property CellFont/ColFont/FixedColFont/RowFont/FixedRowFont *)
    property CellFont[ACol,ARow:longint]: TFont read GetFontCell write SetFontCell;
    property ColFont[ACol:longint]: TFont read GetFontCol write SetFontCol;
    property RowFont[ARow:longint]: TFont read GetFontRow write SetFontRow;
    property FixedColFont[ACol:longint]: TFont read GetFontFixedCol write SetFontFixedCol;
    property FixedRowFont[ARow:longint]: TFont read GetFontFixedRow write SetFontFixedRow;
    (*@\\\*)
    (*@/// procedure Reset...; *)
    procedure ResetFontCell(ACol,ARow:longint);
    procedure ResetFontCol(ACol:longint);
    procedure ResetFontFixedCol(ACol:longint);
    procedure ResetFontRow(ARow:longint);
    procedure ResetFontFixedRow(ARow:longint);

    procedure ResetFontCellAll;
    procedure ResetFontColAll;
    procedure ResetFontRowAll;
    (*@\\\*)
  { published }
    property FixedFont: TFont read FFixedFont write SetFixedFont stored FixedFontChanged;
  (*@\\\0000000901*)
  (*@/// +  Routines and variables for the brushs *)
  protected
    FFixedBrush: TBrush;
    (*@/// The DFM read procedures (compatibility only) *)
    procedure ReadBrushCell(Reader: TReader);
    procedure ReadBrushCol(Reader: TReader);
    procedure ReadBrushRow(Reader: TReader);
    procedure ReadFixedBrushCol(Reader: TReader);
    procedure ReadFixedBrushRow(Reader: TReader);

    function ReadBrushColRow(Reader: TReader; colrow:t_colrow):boolean;
    (*@\\\0000000744*)
    (*@/// property read/write for the brushs *)
    function GetBrushCell(ACol,ARow: longint):TBrush;
    procedure SetBrushCell(ACol,ARow: longint; const Value: TBrush);

    function GetBrushCol(ACol: longint):TBrush;
    procedure SetBrushCol(ACol: longint; const Value: TBrush);
    function GetBrushFixedCol(ACol: longint):TBrush;
    procedure SetBrushFixedCol(ACol: longint; const Value: TBrush);
    function GetBrushRow(ARow: longint):TBrush;
    procedure SetBrushRow(ARow: longint; const Value: TBrush);
    function GetBrushFixedRow(ARow: longint):TBrush;
    procedure SetBrushFixedRow(ARow: longint; const Value: TBrush);
    function GetBrushColRowInternal(AColRow: longint; create:boolean; List:TList):TBrush;
    (*@\\\*)
    (*@/// utility functions *)
    function GetBrushCellComplete(ACol,ARow: longint):TBrush;
    function GetBrushCellInternal(ACol,ARow: longint; create:boolean):TBrush;
    procedure BrushChanged(ABrush: TObject);
    (*@\\\000000032B*)
  public
    (*@/// property CellBrush/ColBrush/FixedColBrush/RowBrush/FixedRowBrush *)
    { The Brush for each cell and for col and row }
    property CellBrush[ACol,ARow:longint]: TBrush read GetBrushCell write SetBrushCell;
    property ColBrush[ACol:longint]: TBrush read GetBrushCol write SetBrushCol;
    property RowBrush[ARow:longint]: TBrush read GetBrushRow write SetBrushRow;
    property FixedColBrush[ACol:longint]: TBrush read GetBrushFixedCol write SetBrushFixedCol;
    property FixedRowBrush[ARow:longint]: TBrush read GetBrushFixedRow write SetBrushFixedRow;
    (*@\\\0000000501*)
    (*@/// procedure ResetBrush...; *)
    procedure ResetBrushCell(ACol,ARow:longint);
    procedure ResetBrushCol(ACol:longint);
    procedure ResetBrushFixedCol(ACol:longint);
    procedure ResetBrushRow(ARow:longint);
    procedure ResetBrushFixedRow(ARow:longint);

    procedure ResetBrushCellAll;
    procedure ResetBrushColAll;
    procedure ResetBrushRowAll;
    (*@\\\*)
  (*@\\\0000000801*)
  (*@/// +  Routines and variables for the hints *)
  protected
    FHintCellLast: TPoint;
    FShowCellHints: Boolean;
    FHintCell: TList;
    FSaveHint: Boolean;
    FOnShowHintCell: TShowHintCellProc;
    procedure ReadHint(Reader: TReader);
    procedure WriteHint(Writer: TWriter);
    function GetHintCell(ACol,ARow: longint):string;
    procedure SetHintCell(ACol,ARow: longint; const Value: string);
    procedure ShowHintCell(var HintStr: (*$ifdef shortstring*)string;(*$else*)ansistring;(*$endif*)
      var CanShow: Boolean; var HintInfo: THintInfo);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  (*$ifdef delphi_ge_3 *)
    procedure CMHintShow(var Message: THintMessage); message CM_HINTSHOW;
  (*$endif *)
  public
    property HintCell[ACol,ARow:longint]:string read GetHintCell write SetHintCell;
    procedure ResetHintCellAll;
  published
    property ShowCellHints: boolean read FShowCellHints write FShowCellHints default true;
    property OnShowHintCell: TShowHintCellProc read FOnShowHintCell write FOnShowHintCell;
  (*@\\\000000161A*)
  (*@/// +  Routines and variables for the cells itself *)
  protected
    FCell: TList;        { Only for loading and saving the cells property }
    FSaveCells: Boolean;
    procedure ReadCells(Reader: TReader);
    procedure WriteCells(Writer: TWriter);
    procedure ListToCells(List:TList);
    procedure CellsToList(var List:TList);
    function GetCellAsDate(ACol,ARow:longint):TDateTime;
    procedure SetCellAsDate(ACol,ARow:longint; value:TDateTime);
    function GetCellAsInt(ACol,ARow:longint):longint;
    procedure SetCellAsInt(ACol,ARow:longint; value:longint);
  public
    property CellsAsDate[ACol,ARow:longint]: TDateTime read GetCellAsDate write SetCellAsDate;
    property CellAsInt[ACol,ARow:longint]:longint read GetCellAsInt write SetCellAsInt;
  (*@\\\0000000D03*)
  (*@/// +  The ResetAll methods as shortcuts *)
  public
    procedure ResetAllCell(ACol,ARow:longint);
    procedure ResetAllCol(ACol:longint);
    procedure ResetAllFixedCol(ACol:longint);
    procedure ResetAllRow(ARow:longint);
    procedure ResetAllFixedRow(ARow:longint);

    procedure ResetAllCellAll;
    procedure ResetAllColAll;
    procedure ResetAllRowAll;
  (*@\\\0000000201*)
  (*@/// +  The Inplace-Edit and it's events sent to the grid *)
  protected
    edit_visible: boolean;
    f_reshow_edit: boolean;
    f_last_sel_pos: longint;
    f_last_sel_len: longint;
    f_on_after_edit: TCellEvent;
    f_on_cancel_edit: TCellEvent;
    f_on_before_edit: TCellEvent;
    f_on_validate: TCellEventBool;
    f_selectall: boolean;
    f_edit_multi: boolean;
    function CreateEditor: TInplaceEdit; override;
    function CanEditShow: Boolean; override;
    procedure mcn_edit_return(var msg:TMessage); message cn_edit_return;
    procedure mcn_edit_cancel(var msg:TMessage); message cn_edit_cancel;
    procedure mcn_edit_exit(var msg:TMessage); message cn_edit_exit;
    procedure mcn_edit_show(var msg:TMessage); message cn_edit_show;
    procedure mcn_edit_show_it(var msg:TMessage); message cn_edit_toshow;
    procedure mcn_edit_update(var msg:TMessage); message cn_edit_update;
    procedure doExit; override;
    procedure doEnter; override;
    procedure KeyPress(var Key: Char); override;
    procedure WMLButtonDown(var Message: TMessage); message WM_LBUTTONDOWN;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure UpdateText_;
    procedure Update_Edit;
  public
    procedure ShowEdit;
    procedure HideEdit(cancel:boolean);
  published
    property OnAfterEdit: TCellEvent read f_on_after_edit write f_on_after_edit;
    property OnCancelEdit: TCellEvent read f_on_cancel_edit write f_on_cancel_edit;
    property OnBeforeEdit: TCellEvent read f_on_before_edit write f_on_before_edit;
    property OnValidateEdit: TCellEventBool read f_on_validate write f_on_validate;
    property SelectEditText: boolean read f_selectall write f_selectall default true;
    property EditMultiline: boolean read f_edit_multi write f_edit_multi default false;
  (*@\\\0000001B01*)
  (*@/// +  Insertion and removing and moving and exchanging of columns and rows *)
  protected
    procedure RowMoved(FromIndex, ToIndex: Longint); override;
    procedure ColumnMoved(FromIndex, ToIndex: Longint); override;
  public
    procedure RemoveCol(ACol:longint);
    procedure RemoveRow(ARow:longint);
    procedure InsertCol(ACol:longint);
    procedure InsertRow(ARow:longint);
    procedure ExchangeRow(FromIndex, ToIndex: Longint);
    procedure ExchangeCol(FromIndex, ToIndex: Longint);
  (*@\\\*)
  (*@/// +  Import and export functions *)
  protected
    f_html_caption: string;
    f_html_border: integer;
  public
    property HTMLCaption: string read f_html_caption write f_html_caption;
    property HTMLBorder: integer read f_html_border write f_html_border default 0;
    function Contents2HTML(data:TMemorystream):TMemorystream;
    procedure Contents2HTMLClipboard;
    function Contents2CSV(data:TMemorystream; csv:char; range:TGridRect):TMemorystream;
    procedure CSV2Contents(data:TStream; csv:char; range:TGridRect);
    procedure Contents2CSVClipboard(csv:char; range:TGridRect);
    procedure ClipboardCSV2Contents(csv:char; range:TGridRect);
    procedure SaveToFile(const filename:string);
    procedure LoadFromFile(const filename:string);
    procedure CopyToClipboard;
    procedure CopyFromClipboard;
  (*@\\\0000000601*)
  (*@/// +  Miscellaneous stuff like internal calculations etc. *)
  protected
    function is_fixed(ACol,ARow: longint):boolean;
    procedure WMChar(var Msg: TWMChar); message WM_CHAR;
    procedure CalcTextSize(ACol,ARow:longint; var Width,height: integer);
    function textheight(ACol,ARow:longint):integer;
    function textwidth(ACol,ARow:longint):integer;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure TopLeftChanged; override;
  public
    procedure ClearSelection;
    procedure NextEditableCell(var ACol,ARow:longint);
    procedure NextCell(direction:t_nextcell; LastCellBehaviour:t_lastcell; Var ACol,ARow:longint);
  (*$ifdef delphi_ge_3 *)
  published
    property ImeMode;
    property ImeName;
  (*$endif *)
  (*@\\\0000000801*)
  (*@/// -  For the DFM read/write *)
  protected
    procedure Loaded; override;
    procedure DefineProperties(Filer: TFiler); override;

    procedure ReadPropCell(Reader: TReader);
    procedure ReadPropCol(Reader: TReader);
    procedure ReadPropRow(Reader: TReader);
    procedure ReadPropFixedCol(Reader: TReader);
    procedure ReadPropFixedRow(Reader: TReader);

    procedure WritePropCell(Writer: TWriter);
    procedure WritePropCol(Writer: TWriter);
    procedure WritePropRow(Writer: TWriter);
    procedure WritePropFixedCol(Writer: TWriter);
    procedure WritePropFixedRow(Writer: TWriter);

    function ReadPropColRow(Reader: TReader; list:TList):boolean;
    function ReadPropCellInt(Reader: TReader; list:TList):boolean;
    procedure WritePropColRow(Writer: TWriter; count: longint; list:TList);
    procedure WritePropCellInt(Writer: TWriter; x,y:longint; list:TList);
  (*@\\\0000000201*)
  (*@/// +  The other properties *)
  protected
    f_nextcell: Boolean;
    f_drawselect: boolean;
    f_nextcell_edit, f_nextcell_tab: T_nextcell;
    f_lastcell_edit, f_lastcell_tab: t_lastcell;
    f_fixedcols, f_fixedrows: longint;
    procedure SetDrawselect(value: boolean);
  published
    property AutoEditNextCell: boolean read f_nextcell write f_nextcell default false;
    property NextCellEdit: T_nextcell read f_nextcell_edit write f_nextcell_edit default nc_rightdown;
    property NextCellTab:  T_nextcell read f_nextcell_tab  write f_nextcell_tab  default nc_rightdown;
    property AfterLastCellEdit: t_lastcell read f_lastcell_edit write f_lastcell_edit default lc_newcolrow;
    property AfterLastCellTab:  t_lastcell read f_lastcell_tab  write f_lastcell_tab  default lc_first;
    property DrawSelection: boolean read f_drawselect write SetDrawselect default true;
  (*@\\\0000000D01*)
  (*@/// +  Sorting *)
  private
    f_compare_col: TCompareFunction;
    f_compare_row: TCompareFunction;
  protected
    fSortMethod: TSortFunction;
    procedure DoSortBubble(ColRow,Min,Max: longint; ByColumn,ascending:boolean);
    procedure DoSortQuick(ColRow,Min,Max: longint; ByColumn,ascending:boolean);
  public
    function CompareColString(Sender: TObject; Column, Row1,Row2: longint):t_relation;
    function CompareRowString(Sender: TObject; RowNr, Col1,Col2: longint):t_relation;
    function CompareColInteger(Sender: TObject; Column, Row1,Row2: longint):t_relation;
    function CompareRowInteger(Sender: TObject; RowNr, Col1,Col2: longint):t_relation;
    procedure SortColumn(Column: longint; Ascending:boolean);
    procedure SortRow(Rownumber: longint; Ascending:boolean);
  published
    property OnCompareRow: TCompareFunction read f_compare_row write f_compare_row;
    property OnCompareCol: TCompareFunction read f_compare_col write f_compare_col;
  (*@\\\000000110C*)
  (*@/// +  Events for col and row resizing *)
  protected
    fwidthschanged: TNotifyEvent;
    fheightschanged: TNotifyEvent;
    procedure ColWidthsChanged; override;
    procedure RowHeightsChanged; override;
  public
    procedure AdjustRowHeight(ARow:longint);
    procedure AdjustColWidth(ACol:longint);
    procedure AdjustRowHeights;
    procedure AdjustColWidths;
  published
    property OnColWidthsChanged: TNotifyEvent read fwidthschanged write fwidthschanged;
    property OnRowHeightsChanged: TNotifyEvent read fheightschanged write fheightschanged;
  { Suggested by Olav Lindkjolen <olav.lind@online.no> }
  protected
    FAutoAdjustLastCol: Boolean;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SetAutoAdjustLastCol(Value: Boolean);
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure SetGridLineWidthNew(Value: Integer);
  public
    procedure AdjustLastCol;
    function GetTotalWidth:Longint;
    function GetTotalHeight:Longint;
  published
    property AutoAdjustLastCol:boolean read FAutoAdjustLastCol write SetAutoAdjustLastCol default false;
    { A virtual SetGridLineWidth would make this be easier... }
    property GridLineWidth write SetGridLineWidthNew;
  (*@\\\0000000601*)
  (*@/// -  The main procedure DrawCell *)
  protected
    f_ondrawcellpar: TCellDrawEvent;
    procedure DrawCell(ACol,ARow:Longint; ARect:TRect; AState:TGridDrawState); override;
    procedure DrawCellBack(ACol,ARow:Longint; var ARect:TRect; AState:TGridDrawState); virtual;
    procedure DrawCellText(ACol,ARow:Longint; var ARect:TRect; AState:TGridDrawState); virtual;
    procedure DrawCellCombo(ACol,ARow:Longint; var ARect:TRect; AState:TGridDrawState); virtual;
  { published }
    (* Last minute access to the text parameters, maybe useful *)
    property OnDrawCellParameters: TCellDrawEvent read f_ondrawcellpar write f_ondrawcellpar;
    procedure Paint;  override;
  (*@\\\0000000A01*)
  (*@/// +  Clicks on the fixed columns/rows *)
  protected
    f_fixedcolclick: TColEvent;
    f_fixedrowclick: TRowEvent;
    procedure MouseDown(Button:TMouseButton; Shift:TShiftState; X,Y:Integer); override;
  published
    property OnFixedColClick:TColEvent read f_fixedcolclick write f_fixedcolclick;
    property OnFixedRowClick:TRowEvent read f_fixedRowclick write f_fixedRowclick;
  (*@\\\*)
  (*@/// +  Allow the scrollbar to act immidiatly *)
  protected
    f_dyn_scroll: boolean;
  public
    procedure WMHScroll(var Msg:TWMHScroll); message wm_hscroll;
    procedure WMVScroll(var Msg:TWMVScroll); message wm_vscroll;
    function VerticalScrollBarVisible: boolean;
    function HorizontalScrollBarVisible: boolean;
  published
    property RedrawWhileScroll:boolean read f_dyn_scroll write f_dyn_scroll default false;
  (*@\\\0000000601*)
  (*@/// +  Cut 'n' Paste *)
  protected
    F_PasteEditableOnly: boolean;
    f_cutnpaste: boolean;
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMCopy(var Message: TMessage); message WM_COPY;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
  public
    property PasteEditableOnly: boolean read F_PasteEditableOnly write F_PasteEditableOnly;
    property AllowCutnPaste: boolean read f_cutnpaste write f_cutnpaste;
  (*@\\\000000090C*)
  (*@/// !  Comboboxes *)
  protected
    function CellHasCombobox(ACol,ARow:longint):boolean;
  (*@\\\*)
    end;
  (*@\\\0000000F01*)

(*@/// Internal routines and objects, just put here to let the be used by aligredi too *)
type
  (*@/// TMyFont = class(TFont) *)
  TMyFont = class(TFont)
  protected
    procedure Changed; override;
  public
    HasChanged: boolean;
    end;
  (*@\\\0000000503*)
  (*@/// TMyBrush = class(TBrush) *)
  TMyBrush = class(TBrush)
  protected
    procedure Changed; override;
  public
    HasChanged: boolean;
    end;
  (*@\\\*)


function GetItemCell(ACol,ARow: longint; List:TList):Pointer;
function SetItemCell(ACol,ARow: longint; List:TList; value:Pointer):pointer;
function GetItemCol(ACol: longint; List:TList):Pointer;
function SetItemCol(ACol: longint; List:TList; value:Pointer):pointer;

procedure WriteFont(Writer: TWriter; v:TFont);
function ReadFont(Reader: TReader):TFont;
procedure WriteBrush(Writer: TWriter; v:TBrush);
function ReadBrush(Reader: TReader):TBrush;
(*@\\\0000000201*)
(*@\\\0000002202*)
(*@/// implementation *)
implementation

(*$ifdef delphi_1 *)
const
  DT_END_ELLIPSIS = $8000;
(*$endif *)

const
  Col_before_Row = true;
  ComboDropDownWidth = 16;

(*@/// Some internal utility procedures for handling the lists *)
{ Clean my internal lists for the three kinds of data }

(*@/// procedure cleanlist(List:TList; size:integer); *)
procedure cleanlist(List:TList; size:integer);
var
  i:longint;
begin
  if list<>NIL then begin
    for i:=0 to List.Count-1 do
      if List.Items[i] <> NIL then
        Freemem(List.Items[i],size);
    end;
  end;
(*@\\\0000000A07*)
(*@/// procedure cleanlist_pstring(List:TList); *)
procedure cleanlist_pstring(List:TList);
var
  i:longint;
begin
  if list<>NIL then begin
    for i:=0 to List.Count-1 do
      if List.Items[i] <> NIL then
        DisposeStr(List.Items[i]);
    end;
  end;
(*@\\\*)
(*@/// procedure cleanlist_object(List:TList); *)
procedure cleanlist_object(List:TList);
var
  i:longint;
begin
  if list<>NIL then begin
    for i:=0 to List.Count-1 do
      TObject(List.Items[i]).Free;
    end;
  end;
(*@\\\*)
(*@\\\*)
(*@/// Reading and writing TFont and TBrush objects to the DFM *)
{ I HATE Borland - here a simple Writer.WriteProperties() would do, but these }
{ idiots have made this method private and only the trivial ones are public.  }
{ They invent such powerfull mechanisms to access properties at design time   }
{ and then they destroy any way to use these for advanced components :-(      }
{ So I have to write every property and not only those that are changed       }
{ from the default, and I have to do the assumption that they won't change    }
{ the TFontStyles and TFontPitch types as that would run this into great      }
{ problems. And of course what to do with a beast like a TButton instead of   }
{ a TFont - then the mechanism below won't be enough.                         }
{ So anyone knowing a better way to do it is greatly welcome!                 }

(*@/// procedure WriteFont(Writer: TWriter; v:TFont); *)
{ I HATE Borland - here a simple Writer.WriteProperties() would do, but these }
{ idiots have made this method private and only the trivial ones are public.  }
{ They invent such powerfull mechanisms to access properties at design time   }
{ and then they destroy any way to use these for advanced components :-(      }
{ So I have to write every property and not only those that are changed       }
{ from the default, and I have to do the assumption that they won't change    }
{ the TFontStyles and TFontPitch types as that would run this into great      }
{ problems. And of course what to do with a beast like a TButton instead of   }
{ a TFont - then the mechanism below won't be enough.                         }
{ So anyone knowing a better way to do it is greatly welcome!                 }

procedure WriteFont(Writer: TWriter; v:TFont);
var
  t: TFontStyles;
begin
  Writer.WriteInteger(v.Color);
  Writer.WriteInteger(v.height);
  Writer.WriteString(v.name);
{ WriteEnum is missing, have to write as an integer }
  Writer.WriteInteger(cardinal(v.Pitch));
{ The WriteSet is also missing, again only savable as an integer }
  t:=v.Style;
{ and why can't I cast a set to an integer directly ? }
  Writer.WriteInteger(cardinal(pointer(@t)^));
  end;
(*@\\\0000000C0B*)
(*@/// function ReadFont(Reader: TReader):TFont; *)
function ReadFont(Reader: TReader):TFont;
var
  t: integer;
begin
{ The same work-around as in WriteFont }
  result:=NIL;
  try
    result:=TMyFont.Create;
    result.Color:=Reader.ReadInteger;
    result.height:=Reader.ReadInteger;
    result.name:=Reader.ReadString;
    result.pitch:=TFontPitch(Reader.ReadInteger);
    t:=reader.readinteger;
    result.style:=TFontStyles(pointer(@t)^);
  except
    result.free;
    RAISE;
    end;
  end;
(*@\\\*)
(*@/// procedure WriteBrush(Writer: TWriter; v:TBrush); *)
{ The same comment as in WriteFont applies here }

procedure WriteBrush(Writer: TWriter; v:TBrush);
begin
  Writer.WriteInteger(v.Color);
{ WriteEnum is missing, have to write as an integer }
  Writer.WriteInteger(cardinal(v.Style));
  end;
(*@\\\*)
(*@/// function ReadBrush(Reader: TReader):TBrush; *)
function ReadBrush(Reader: TReader):TBrush;
begin
  result:=NIL;
  try
    result:=TMyBrush.Create;
    result.Color:=Reader.ReadInteger;
    result.style:=TBrushStyle(Reader.ReadInteger);
  except
    result.free;
    RAISE;
    end;
  end;
(*@\\\0000000B09*)
(*@\\\*)

(*@/// TCellProperties      = class(TObject) *)
const
  prop_end      = 0;
  prop_align    = 1;
  prop_wrap     = 2;
  prop_edit     = 3;
  prop_brush    = 4;
  prop_selbrush = 5;
  prop_font     = 6;
  prop_selfont  = 7;

(*@/// procedure copy_font(var tgt: TFont; src: TFont); *)
procedure copy_font(var tgt: TFont; src: TFont);
begin
  if src=NIL then begin
    tgt.free;
    tgt:=NIL;
    end
  else begin
    if tgt=NIL then
      tgt:=TMyFont.Create;
    tgt.assign(src);
    end;
  end;
(*@\\\0000000301*)
(*@/// procedure copy_brush(var tgt: TBrush; src: TBrush); *)
procedure copy_brush(var tgt: TBrush; src: TBrush);
begin
  if src=NIL then begin
    tgt.free;
    tgt:=NIL;
    end
  else begin
    if tgt=NIL then
      tgt:=TMyBrush.create;
    tgt.assign(src);
    end;
  end;
(*@\\\0000000120*)

{ TCellProperties }
(*@/// constructor TCellProperties.Create(Grid:TStringAlignGrid); *)
constructor TCellProperties.Create(Grid:TStringAlignGrid);
begin
  inherited create;
  align:=alDefault;
  wordwrap:=ww_default;
  f_grid:=grid;
  end;
(*@\\\0000000123*)
(*@/// destructor TCellProperties.destroy; *)
destructor TCellProperties.destroy;
begin
  brush.free;
  selBrush.free;
  font.free;
  selfont.free;
  inherited destroy;
  end;
(*@\\\000000060F*)
(*@/// procedure TCellProperties.assign(value:TCellProperties); *)
procedure TCellProperties.assign(value:TCellProperties);
begin
  if value=NIL then begin
    align:=aldefault;
    wordwrap:=ww_default;
    editable:=0;
    brush:=NIL;
    selbrush:=NIL;
    font:=NIL;
    selfont:=NIL;
    end
  else begin
    align:=value.align;
    wordwrap:=value.wordwrap;
{     copy_brush(f_brush,value.brush); }
{     copy_brush(f_selbrush,value.selbrush); }
{     copy_font(f_font,value.font); }
{     copy_font(f_selfont,value.selfont); }
    Brush:=value.brush;
    SelBrush:=value.selbrush;
    font:=value.font;
    Selfont:=value.selfont;
    editable:=value.editable;
    end;
  end;
(*@\\\0000001601*)
(*@/// procedure TCellProperties.SetFont(value: TFont); *)
procedure TCellProperties.SetFont(value: TFont);
begin
  copy_font(f_font,value);
  if f_font<>NIL then begin
    f_font.OnChange:=f_grid.FontChanged;
    if value is TMyFont then
      TMyFont(f_font).HasChanged:=TMyFont(value).HasChanged
    else
      TMyFont(f_font).HasChanged:=true;
    end;
  end;
(*@\\\0000000927*)
(*@/// procedure TCellProperties.SetSelFont(value: TFont); *)
procedure TCellProperties.SetSelFont(value: TFont);
begin
  copy_font(f_selfont,value);
  if f_selfont<>NIL then begin
    f_selfont.OnChange:=f_grid.FontChanged;
    if value is TMyFont then
      TMyFont(f_selfont).HasChanged:=TMyFont(value).HasChanged
    else
      TMyFont(f_selfont).HasChanged:=true;
    end;
  end;
(*@\\\0000000901*)
(*@/// procedure TCellProperties.SetBrush(value: TBrush); *)
procedure TCellProperties.SetBrush(value: TBrush);
begin
  copy_brush(f_brush,value);
  if f_brush<>NIL then begin
    f_brush.OnChange:=f_grid.BrushChanged;
    if value is TMyBrush then
      TMyBrush(f_Brush).HasChanged:=TMyBrush(value).HasChanged
    else
      TMyBrush(f_Brush).HasChanged:=true;
    end;
  end;
(*@\\\0000000929*)
(*@/// procedure TCellProperties.SetSelBrush(value: TBrush); *)
procedure TCellProperties.SetSelBrush(value: TBrush);
begin
  copy_brush(f_selbrush,value);
  if f_selbrush<>NIL then begin
    f_selbrush.OnChange:=f_grid.BrushChanged;
    if value is TMyBrush then
      TMyBrush(f_selBrush).HasChanged:=TMyBrush(value).HasChanged
    else
      TMyBrush(f_selBrush).HasChanged:=true;
    end;
  end;
(*@\\\000000092C*)
(*@/// function TCellProperties.isempty: boolean; *)
function TCellProperties.isempty: boolean;
begin
  result:=(align=aldefault) and (wordwrap=ww_default) and
          (font=NIL) and (selfont=NIL) and
          (brush=NIL) and (selbrush=NIL) and
          (editable=0);
  end;
(*@\\\0000000601*)
(*@/// function TCellProperties.clone:TCellProperties; *)
function TCellProperties.clone:TCellProperties;
begin
  result:=TCellProperties.Create(self.f_grid);
  result.assign(self);
  end;
(*@\\\0000000301*)

(*@/// procedure TCellProperties.WriteToWriter(writer:TWriter); *)
procedure TCellProperties.WriteToWriter(writer:TWriter);
begin
  (*@/// if self.align<>aldefault     then *)
  if self.align<>aldefault then begin
    writer.writeinteger(prop_align);
    writer.writeinteger(byte(self.align));
    end;
  (*@\\\*)
  (*@/// if self.wordwrap<>ww_default then *)
  if self.wordwrap<>ww_default then begin
    writer.writeinteger(prop_wrap);
    writer.writeinteger(byte(self.wordwrap));
    end;
  (*@\\\*)
  (*@/// if self.editable<>0          then *)
  if self.editable<>0 then begin
    writer.writeinteger(prop_edit);
    writer.writeinteger(self.editable);
    end;
  (*@\\\*)
  (*@/// if self.brush<>NIL           then *)
  if self.brush<>NIL then begin
    writer.writeinteger(prop_brush);
    WriteBrush(writer,self.brush);
    end;
  (*@\\\*)
  (*@/// if self.selbrush<>NIL        then *)
  if self.selbrush<>NIL then begin
    writer.writeinteger(prop_selbrush);
    WriteBrush(writer,self.selbrush);
    end;
  (*@\\\*)
  (*@/// if self.Font<>NIL            then *)
  if self.Font<>NIL then begin
    writer.writeinteger(prop_Font);
    WriteFont(writer,self.Font);
    end;
  (*@\\\*)
  (*@/// if self.selFont<>NIL         then *)
  if self.selFont<>NIL then begin
    writer.writeinteger(prop_selFont);
    WriteFont(writer,self.selFont);
    end;
  (*@\\\*)
  writer.writeinteger(prop_end);
  end;
(*@\\\0000000B01*)
(*@/// procedure TCellProperties.ReadFromReader(Reader:TReader; grid:TStringAlignGrid); *)
procedure TCellProperties.ReadFromReader(Reader:TReader; grid:TStringAlignGrid);
var
  k: integer;
begin
  repeat
    k:=Reader.ReadInteger;
    ReadSingleProperty(k,reader,grid);
  until k=prop_end;
  end;
(*@\\\000000030E*)
(*@/// procedure TCellProperties.ReadSingleProperty(Proptype:integer; Reader:TReader; grid:TStringAlignGrid); *)
procedure TCellProperties.ReadSingleProperty(Proptype:integer; Reader:TReader; grid:TStringAlignGrid);
var
  v: TBrush;
  f: TFont;
begin
  case proptype of
    prop_end     : ;
    prop_align   : self.align:=TMyAlign(reader.readinteger);
    prop_wrap    : self.wordwrap:=T_Wordwrap(reader.readinteger);
    prop_edit    : self.editable:=reader.readinteger;
    (*@/// prop_brush   : self.brush:=ReadBrush(Reader); *)
    prop_brush   : begin
      v:=NIL;
      try
        v:=ReadBrush(Reader);
        self.brush:=v;
        self.brush.OnChange:=grid.brushchanged;
      finally
        v.free;
        end;
      end;
    (*@\\\0000000621*)
    (*@/// prop_selbrush: self.selbrush:=ReadBrush(Reader); *)
    prop_selbrush   : begin
      v:=NIL;
      try
        v:=ReadBrush(Reader);
        self.selbrush:=v;
        self.selbrush.OnChange:=grid.brushchanged;
      finally
        v.free;
        end;
      end;
    (*@\\\0000000624*)
    (*@/// prop_font    : self.font:=ReadFont(Reader); *)
    prop_font   : begin
      f:=NIL;
      try
        f:=ReadFont(Reader);
        self.font:=f;
        self.font.OnChange:=grid.fontchanged;
      finally
        f.free;
        end;
      end;
    (*@\\\0000000620*)
    (*@/// prop_selfont : self.selfont:=ReadFont(Reader); *)
    prop_selfont   : begin
      f:=NIL;
      try
        f:=ReadFont(Reader);
        self.selfont:=f;
        self.selfont.OnChange:=grid.fontchanged;
      finally
        f.free;
        end;
      end;
    (*@\\\0000000623*)
    end;
  end;
(*@\\\0000000E01*)
(*@\\\0000001501*)

(*@/// TMyFont              = class(TFont)            // To remember if changed *)
{ TMyFont }
(*@/// procedure TMyFont.Changed; *)
procedure TMyFont.Changed;
begin
  HasChanged:=true;
  inherited changed;
  end;
(*@\\\*)
(*@\\\0000000201*)
(*@/// TMyBrush             = class(TBrush)           // To remember if changed *)
{ TMyBrush }
(*@/// procedure TMyBrush.Changed; *)
procedure TMyBrush.Changed;
begin
  HasChanged:=true;
  inherited changed;
  end;
(*@\\\*)
(*@\\\*)
(*@/// TNewInplaceEdit      = class(TInplaceEdit)     // The internal cell editor *)
{ TNewInplaceEdit }
(*@/// procedure TNewInplaceEdit.CreateParams(var Params: TCreateParams); *)
procedure TNewInplaceEdit.CreateParams(var Params: TCreateParams);
(*$ifdef delphi_ge_4 *)
const
  Alignments : array[TMyAlign] of longword = (ES_RIGHT,ES_LEFT,ES_CENTER,ES_RIGHT);
(*$else *)
const
  Alignments : array[TMyAlign] of Longint = (ES_RIGHT,ES_LEFT,ES_CENTER,ES_RIGHT);
(*$endif *)
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style
{     and (not ES_MULTILINE)    (* otherwise the passwordchar won't work *) }
{                               (* but makes it behave erratically *)       }
    or Alignments[FAlignment];
  end;
(*@\\\0000000B01*)
(*@/// procedure TNewInplaceEdit.SetAlignment(Value: TMyAlign); *)
procedure TNewInplaceEdit.SetAlignment(Value: TMyAlign);
var
  start,stop: integer;
{   Loc: TRect; }
begin
  if FAlignment <> Value then begin
    FAlignment := Value;
    GetSel(start,stop);
    RecreateWnd;
    SetSel(start,stop);
    UpdateLoc(TStringGrid(parent).CellRect(Col, Row));
    end;
  end;
(*@\\\*)
(*@/// constructor TNewInplaceEdit.Create(AOwner:TComponent); *)
constructor TNewInplaceEdit.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  FAlignment := alLeft;
  end;
(*@\\\*)
(*@/// procedure TNewInplaceEdit.KeyPress(var Key: Char); *)
procedure TNewInplaceEdit.KeyPress(var Key: Char);
begin
  if (col=-1) or (row=-1) then key:=#0;
  if (key=#13) then begin
    if not f_multiline then
      postmessage(TStringAlignGrid(self.owner).handle,cn_edit_return,col,row)
    else if f_multiline then
      if not TStringAlignGrid(self.owner).CanEditModify then
        Key := #0;
    end;
  if (key=#27) and not f_multiline then begin
    self.text:=oldtext;
    postmessage(TStringAlignGrid(self.owner).handle,cn_edit_cancel,col,row);
    key:=#13;
    end;
  if key=#9 then  key:=#0;
  inherited KeyPress(key);
  end;
(*@\\\0000001201*)
(*@/// procedure TNewInplaceEdit.KeyDown(var Key: Word; Shift: TShiftState); *)
procedure TNewInplaceEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if f_multiline and (key in
    [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT,VK_LEFT,
     VK_RIGHT, VK_HOME, VK_END]) then
    { ignore it }
  else  inherited KeyDown(Key, Shift);
end;
(*@\\\*)
(*@/// procedure TNewInplaceEdit.UpdateContents; *)
procedure TNewInplaceEdit.UpdateContents;
var
  g: TStringAlignGrid;
begin
(*$ifdef delphi_1 *)
  Text := '';
  EditMask := Grid.GetEditMask(Grid.Col, Grid.Row);
  Text := Grid.GetEditText(Grid.Col, Grid.Row);
  MaxLength := Grid.GetEditLimit;
(*$else *)
  inherited UpdateContents;
(*$endif *)
  g:=grid as TStringAlignGrid;
  Col:=g.Col;
  Row:=g.Row;
  Alignment:=G.GetAlignCell(Col,Row);
  Font:=G.GetFontCellComplete(Col,Row);
  Color:=G.ColorCell[Col,Row];
  MultiLine:=G.EditMultiline;
  (*$ifdef delphi_ge_3 *)
  ImeMode:=g.ImeMode;
  ImeName:=g.ImeName;
  (*$endif *)
  end;
(*@\\\000000140D*)
(*$ifdef delphi_1 *)
(*@/// function TNewInplaceEdit.GetGrid:TCustomGrid; *)
function TNewInplaceEdit.GetGrid:TCustomGrid;
begin
  result:=parent as TCustomGrid;
  end;
(*@\\\0000000119*)
(*$endif *)
(*@/// procedure TNewInplaceEdit.WMWindowPosChanged(var Message: TMessage); *)
procedure TNewInplaceEdit.WMWindowPosChanged(var Message: TMessage);
begin
  inherited;
  end;
(*@\\\*)
(*@/// procedure TNewInplaceEdit.EMSetSel(var Message: TMessage); *)
procedure TNewInplaceEdit.EMSetSel(var Message: TMessage);
begin
  inherited;
  end;
(*@\\\*)
(*@\\\000C00071B00072900071B*)
(*@/// TStringAlignGrid     = class(TStringGrid)      // The grid itself *)
{ TStringAlignGrid }
(*@/// The component action: create, initialize, destroy the internal data *)
{ The component action: create, initialize, destroy the internal data }
(*@/// constructor TStringAlignGrid.Create(AOwner: TComponent); *)
constructor TStringAlignGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FSaveHint:=false;
  FSaveCells:=false;

  f_reshow_edit:=false;

  FEditable:=true;

  Initialize;
  end;
(*@\\\0000000501*)
(*@/// destructor TStringAlignGrid.Destroy; *)
destructor TStringAlignGrid.Destroy;
var
  i:longint;
begin
  (*@/// FPropCol.Free; *)
  if FPropCol<>NIL then
    cleanlist_object(FPropCol);
  FPropCol.Free;
  FPropCol:=NIL;
  (*@\\\*)
  (*@/// FPropRow.Free; *)
  if FPropRow<>NIL then
    cleanlist_object(FPropRow);
  FPropRow.Free;
  FPropRow:=NIL;
  (*@\\\*)
  (*@/// FFPropCol.Free; *)
  if FFPropCol<>NIL then
    cleanlist_object(FFPropCol);
  FFPropCol.Free;
  FFPropCol:=NIL;
  (*@\\\*)
  (*@/// FFPropRow.Free; *)
  if FFPropRow<>NIL then
    cleanlist_object(FFPropRow);
  FFPropRow.Free;
  FFPropRow:=NIL;
  (*@\\\*)
  (*@/// FPropCell.Free; *)
  if FPropCell<>NIL then
    for i:=FPropCell.Count-1 downto 0 do begin
      cleanlist_object(TList(FPropCell.Items[i]));
      TList(FPropCell.Items[i]).Free;
      end;
  FPropCell.Free;
  FPropCell:=NIL;
  (*@\\\*)

  (*@/// FHintCell.Free; *)
  if FHintCell<>NIL then
    for i:=FHintCell.Count-1 downto 0 do begin
      cleanlist_pstring(TList(FHintCell.Items[i]));
      TList(FHintCell.Items[i]).Free;
      end;
  FHintCell.Free;
  FHintCell:=NIL;
  (*@\\\0000000401*)
  (*@/// FCell.Free; *)
  if FCell<>NIL then
    for i:=FCell.Count-1 downto 0 do begin
      cleanlist_pstring(TList(FCell.Items[i]));
      TList(FCell.Items[i]).Free;
      end;
  FCell.Free;
  FCell:=NIL;
  (*@\\\0000000401*)
  FFixedBrush.free;
  FFixedFont.free;
(*$ifndef delphi_ge_3 *)
  RemoveShowHintProc(ShowHintCell);
(*$endif *)
  inherited Destroy;
  end;
(*@\\\0000000F01*)
(*@/// procedure TStringAlignGrid.Initialize; *)
procedure TStringAlignGrid.Initialize;
begin
  FHintCell:=TList.Create;
  FCell:=TList.Create;

  FPropCell:=TList.Create;
  FPropCol:=TList.Create;
  FFPropCol:=TList.Create;
  FPropRow:=TList.Create;
  FFPropRow:=TList.Create;

  CellPropertiesClass:=TCellProperties;
  FAlign:=alLeft;
  F_Wordwrap:=ww_none;
  FShowCellHints:=true;
  FHintCellLast:=point(-1,-1);
  f_SelCellColor:=clActiveCaption;
  f_SelFontColor:=clWhite;
  f_fixedcols:=0;
  f_fixedrows:=0;
  f_nextcell:=false;
  FAlwaysEdit:=false;
  f_nextcell_edit:=nc_rightdown;
  f_nextcell_tab:=nc_rightdown;
  f_drawselect:=true;
  f_lastcell_edit:=lc_newcolrow;
  f_lastcell_tab:=lc_first;
  FFixedBrush:=TMyBrush.Create;
  FFixedBrush.Color:=FixedColor;
  FFixedBrush.OnChange:=BrushChanged;
  f_compare_col:=self.CompareColString;
  f_compare_row:=self.CompareRowString;
  f_selectall:=true;
  f_altcolcolor:=clWindow;
  f_altrowcolor:=clWindow;
  FFixedFont:=TMyFont.Create;
  FFixedFont.OnChange:=FontChanged;
  AllowCutnPaste:=true;
  fSortMethod:=self.DoSortQuick;
(*$ifndef delphi_ge_3 *)
  AddShowHintProc(ShowHintCell);
(*$endif *)
  end;
(*@\\\*)
(*@\\\0000000401*)

(*@/// Internal routines for saving any data pointer (or a longint) in a List *)
{ Internal routines for saving any data pointer (or a longint) in a List }
(*@/// function GetItemCol(ACol: longint; List:TList):Pointer; *)
function GetItemCol(ACol: longint; List:TList):Pointer;
begin
  if (ACol+1 > List.Count) or (ACol<0) then
    GetItemCol:=NIL
  else
    if List.Items[ACol] = NIL then
      GetItemCol:=NIL
    else begin
      GetItemCol:=List.Items[ACol];
      end;
  end;
(*@\\\*)
(*@/// function SetItemCol(ACol: longint; List:TList; value:Pointer):pointer; *)
function SetItemCol(ACol: longint; List:TList; value:Pointer):pointer;
var
  i:longint;
  t:pointer;
begin
  t:=NIL;
  if ACol+1 > List.Count then
    for i:=List.Count to ACol do
      List.Add(NIL);
  if List.Items[ACol] <> NIL then begin
    t:=List.Items[ACol];
    List.Items[ACol]:=value;
    end
  else
    List.Items[ACol]:=value;
  SetItemCol:=t;
  end;
(*@\\\*)
(*@/// procedure ExchangeItemCol(ACol1,ACol2: longint; List:TList); *)
procedure ExchangeItemCol(ACol1,ACol2: longint; List:TList);
var
  p: pointer;
begin
  p:=SetItemCol(ACol1,List,NIL);
  p:=SetItemCol(ACol2,List,p);
  SetItemCol(ACol1,List,p);
  end;
(*@\\\*)
(*@/// procedure MoveItemCol(FromIndex, ToIndex: longint; list:TList); *)
procedure MoveItemCol(FromIndex, ToIndex: longint; list:TList);
var
  p: pointer;
begin
  p:=SetItemCol(FromIndex,list,NIL);
  list.Delete(FromIndex);
  while ToIndex>list.count do
    list.add(NIL);
  list.Insert(ToIndex,p);
  end;
(*@\\\*)
(*@\\\0000000201*)
(*@/// Internal routines for saving any data pointer in a two-dimensional List *)
{ Internal routines for saving any data pointer in a two-dimensional List }
(*@/// function GetItemCell(ACol,ARow: longint; List:TList):Pointer; *)
function GetItemCell(ACol,ARow: longint; List:TList):Pointer;
var
  sublist: TList;
begin
  if (ACol+1 > List.Count) or (ACol<0) or (ARow<0) then
    GetItemCell:=NIL
  else
    if List.Items[ACol] = NIL then
      GetItemCell:=NIL
    else begin
      sublist:=TList(List.Items[ACol]);
      if ARow+1 > sublist.Count then
        GetItemCell:=NIL
      else
        GetItemCell:=sublist.Items[ARow]
    end;
  end;
(*@\\\*)
(*@/// function SetItemCell(ACol,ARow: longint; List:TList; value:Pointer):pointer; *)
function SetItemCell(ACol,ARow: longint; List:TList; value:Pointer):pointer;
(* give back the pointer to the previously stored element to let the caller dispose it *)
var
  i:longint;
  t:pointer;
  sublist:TList;
begin
  t:=NIL;
  if ACol+1 > List.Count then
    for i:=List.Count to ACol do
      List.Add(NIL);
  if List.Items[ACol] = NIL then
    List.Items[ACol]:=TList.Create;
  sublist:=TList(List.Items[ACol]);
  if ARow+1 > sublist.Count then
    for i:=sublist.Count to ARow do
      sublist.Add(NIL);
  if sublist.items[ARow] <> NIL then begin
    t:=sublist.items[ARow];
{     FreeMem(t,size); }
    sublist.Items[ARow]:=value;
    end
  else
    sublist.Items[ARow]:=value;
  SetItemCell:=t;
  end;
(*@\\\*)
(*@/// procedure ExchangeItemColRow(ARow1,ARow2:longint; list:TList); *)
procedure ExchangeItemColRow(ARow1,ARow2:longint; list:TList);
var
  i:longint;
  sublist:TList;
begin
  for i:=List.Count-1 downto 0 do begin
    sublist:=TList(List.Items[i]);
    if sublist=NIL then begin
      sublist:=TList.Create;
      List.Items[i]:=sublist;
      end;
    ExchangeItemCol(ARow1,ARow2,sublist);
    end;
  end;
(*@\\\*)
(*@/// procedure MoveItemColRow(FromRow,ToRow:longint; list:TList); *)
procedure MoveItemColRow(FromRow,ToRow:longint; list:TList);
var
  i:longint;
  sublist:TList;
  p: pointer;
begin
  for i:=list.Count-1 downto 0 do begin
    sublist:=TList(list.Items[i]);
    if sublist=NIL then begin
      sublist:=TList.Create;
      list.Items[i]:=sublist;
      end;
    p:=SetItemCol(FromRow,sublist,NIL);
    sublist.Delete(FromRow);
    while ToRow>sublist.count do
      sublist.add(NIL);
    sublist.Insert(ToRow,p);
    end;
  end;
(*@\\\*)
(*@\\\0000000301*)

(*@/// Property read and write and reset for the Objects themselves *)
(*@/// function TStringAlignGrid.GetObjectCol(ACol: longint):TCellProperties; *)
function TStringAlignGrid.GetObjectCol(ACol: longint):TCellProperties;
begin
  result:=GetItemCol(ACol, FPropCol);
  if result=NIL then begin
    result:=CellPropertiesClass.Create(self);
    SetItemCol(ACol, FPropCol, result);
    end;
  end;
(*@\\\0000000601*)
(*@/// procedure TStringAlignGrid.SetObjectCol(ACol: longint; const Value: TCellProperties); *)
procedure TStringAlignGrid.SetObjectCol(ACol: longint; const Value: TCellProperties);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FPropCol);
  if v=NIL then begin
    v:=CellPropertiesClass.Create(self);
    v.assign(value);
    SetItemCol(ACol, FPropCol, v);
    end;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@/// function TStringAlignGrid.GetObjectRow(ARow: longint):TCellProperties; *)
function TStringAlignGrid.GetObjectRow(ARow: longint):TCellProperties;
begin
  result:=GetItemCol(ARow, FPropRow);
  if result=NIL then begin
    result:=CellPropertiesClass.Create(self);
    SetItemCol(ARow, FPropRow, result);
    end;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetObjectRow(ARow: longint; const Value: TCellProperties); *)
procedure TStringAlignGrid.SetObjectRow(ARow: longint; const Value: TCellProperties);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FPropRow);
  if v=NIL then begin
    v:=CellPropertiesClass.Create(self);
    v.assign(value);
    SetItemCol(ARow, FPropRow, v);
    end;
  Invalidate;
  end;
(*@\\\0000000501*)

(*@/// function TStringAlignGrid.GetObjectFixedCol(ACol: longint):TCellProperties; *)
function TStringAlignGrid.GetObjectFixedCol(ACol: longint):TCellProperties;
begin
  result:=GetItemCol(ACol, FFPropCol);
  if result=NIL then begin
    result:=CellPropertiesClass.Create(self);
    SetItemCol(ACol, FFPropCol, result);
    end;
  end;
(*@\\\0000000617*)
(*@/// procedure TStringAlignGrid.SetObjectFixedCol(ACol: longint; const Value: TCellProperties); *)
procedure TStringAlignGrid.SetObjectFixedCol(ACol: longint; const Value: TCellProperties);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FFPropCol);
  if v=NIL then begin
    v:=CellPropertiesClass.Create(self);
    v.assign(value);
    SetItemCol(ACol, FFPropCol, v);
    end;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@/// function TStringAlignGrid.GetObjectFixedRow(ARow: longint):TCellProperties; *)
function TStringAlignGrid.GetObjectFixedRow(ARow: longint):TCellProperties;
begin
  result:=GetItemCol(ARow, FFPropRow);
  if result=NIL then begin
    result:=CellPropertiesClass.Create(self);
    SetItemCol(ARow, FFPropRow, result);
    end;
  end;
(*@\\\0000000401*)
(*@/// procedure TStringAlignGrid.SetObjectFixedRow(ARow: longint; const Value: TCellProperties); *)
procedure TStringAlignGrid.SetObjectFixedRow(ARow: longint; const Value: TCellProperties);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FFPropRow);
  if v=NIL then begin
    v:=CellPropertiesClass.Create(self);
    v.assign(value);
    SetItemCol(ARow, FFPropRow, v);
    end;
  Invalidate;
  end;
(*@\\\0000000501*)

(*@/// function TStringAlignGrid.GetObjectCell(ACol,ARow: longint):TCellProperties; *)
function TStringAlignGrid.GetObjectCell(ACol,ARow: longint):TCellProperties;
begin
  result:=GetItemCell(ACol,ARow,FPropCell);
  if result=NIL then begin
    result:=CellPropertiesClass.Create(self);
    SetItemCell(ACol, ARow, FPropCell, result);
    end;
  end;
(*@\\\0000000601*)
(*@/// procedure TStringAlignGrid.SetObjectCell(ACol,ARow: longint; const Value: TCellProperties); *)
procedure TStringAlignGrid.SetObjectCell(ACol,ARow: longint; const Value: TCellProperties);
var
  v:TCellProperties;
begin
  v:=GetItemCell(ACol,ARow,FPropCell);
  if v=NIL then begin
    v:=CellPropertiesClass.Create(self);
    v.assign(value);
    SetItemCell(ACol,ARow, FPropCell, v);
    end;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@\\\*)

(*@/// Property read and write and reset for the Alignments *)
(*@/// Property read and write for Alignment *)
(*@/// procedure TStringAlignGrid.SetAlign(const Value: TMyAlign); *)
procedure TStringAlignGrid.SetAlign(const Value: TMyAlign);
begin
  if FAlign<>value then begin
    FAlign:=Value;
    Invalidate;
    end;
  end;
(*@\\\0000000501*)
(*@\\\*)
(*@/// Property read and write for AlignCell *)
(*@/// function TStringAlignGrid.GetAlignCell(ACol,ARow:longint):TMyAlign; *)
function TStringAlignGrid.GetAlignCell(ACol,ARow:longint):TMyAlign;
var
  v:TCellProperties;
  fixed: boolean;
begin
  v:=GetItemCell(ACol,ARow,FPropCell);
  fixed:=is_fixed(ACol,ARow);
  if (v=NIL) or (v.align=alDefault) then begin
    if fixed then begin
      if Col_before_Row then
        v:=GetItemCol(ACol,FFPropCol)
      else
        v:=GetItemCol(ACol,FFPropRow)
      end
    else begin
      if Col_before_Row then
        v:=GetItemCol(ACol,FPropCol)
      else
        v:=GetItemCol(ACol,FPropRow)
      end;
    if (v=NIL) or (v.align=alDefault) then begin
      if fixed then begin
        if Col_before_Row then
          v:=GetItemCol(ARow,FFPropRow)
        else
          v:=GetItemCol(ARow,FFPropCol)
        end
      else begin
        if Col_before_Row then
          v:=GetItemCol(ARow,FPropRow)
        else
          v:=GetItemCol(ARow,FPropCol)
        end;
      if (v=NIL) or (v.align=alDefault) then begin
        if Alignment=alDefault then
          result:=alLeft
        else
          result:=Alignment;
        end
      else
        result:=v.align;
      end
    else
      result:=v.align;
    end
  else
    result:=v.align;
  end;
(*@\\\0000001001*)
(*@/// procedure TStringAlignGrid.SetAlignCell(ACol,ARow:longint; const Value: TMyAlign); *)
procedure TStringAlignGrid.SetAlignCell(ACol,ARow:longint; const Value: TMyAlign);
begin
  ObjectCell[ACol,ARow].align:=value;
  Invalidate;
  end;
(*@\\\0000000301*)
(*@\\\0000000201*)
(*@/// Property read and write for AlignCol and FixedAlignCol *)
(*@/// function TStringAlignGrid.GetAlignCol(ACol:longint):TMyAlign; *)
function TStringAlignGrid.GetAlignCol(ACol:longint):TMyAlign;
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FPropCol);
  if v=NIL then
    result:=Alignment
  else
    result:=v.align;
  end;
(*@\\\0000000501*)
(*@/// function TStringAlignGrid.GetFixAlignCol(ACol:longint):TMyAlign; *)
function TStringAlignGrid.GetFixAlignCol(ACol:longint):TMyAlign;
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FFPropCol);
  if v=NIL then
    result:=Alignment
  else
    result:=v.align;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.SetAlignCol(ACol:longint; const Value: TMyAlign); *)
procedure TStringAlignGrid.SetAlignCol(ACol:longint; const Value: TMyAlign);
begin
  ObjectCol[ACol].align:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetFixAlignCol(ACol:longint; const Value: TMyAlign); *)
procedure TStringAlignGrid.SetFixAlignCol(ACol:longint; const Value: TMyAlign);
begin
  ObjectFixedCol[ACol].align:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@\\\0000000401*)
(*@/// Property read and write for AlignRow and FixedAlignRow *)
(*@/// function TStringAlignGrid.GetAlignRow(ARow:longint):TMyAlign; *)
function TStringAlignGrid.GetAlignRow(ARow:longint):TMyAlign;
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FPropRow);
  if v=NIL then
    result:=Alignment
  else
    result:=v.align;
  end;
(*@\\\0000000515*)
(*@/// function TStringAlignGrid.GetFixAlignRow(ARow:longint):TMyAlign; *)
function TStringAlignGrid.GetFixAlignRow(ARow:longint):TMyAlign;
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FFPropRow);
  if v=NIL then
    result:=Alignment
  else
    result:=v.align;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetAlignRow(ARow:longint; const Value: TMyAlign); *)
procedure TStringAlignGrid.SetAlignRow(ARow:longint; const Value: TMyAlign);
begin
  ObjectRow[ARow].align:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetFixAlignRow(ARow:longint; const Value: TMyAlign); *)
procedure TStringAlignGrid.SetFixAlignRow(ARow:longint; const Value: TMyAlign);
begin
  ObjectFixedRow[ARow].align:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@\\\0000000401*)

(*@/// Reset alignment and use the one defined a level above *)
(*@/// procedure TStringAlignGrid.ResetAlignCell(ACol,ARow:longint); *)
procedure TStringAlignGrid.ResetAlignCell(ACol,ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCell(ACol,ARow, FPropCell);
  if v<>NIL then
    v.align:=alDefault;
  Invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetAlignCol(ACol:longint); *)
procedure TStringAlignGrid.ResetAlignCol(ACol:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol,FPropCol);
  if v<>NIL then
    v.align:=alDefault;
  Invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetAlignFixedCol(ACol:longint); *)
procedure TStringAlignGrid.ResetAlignFixedCol(ACol:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol,FFPropCol);
  if v<>NIL then
    v.align:=alDefault;
  Invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetAlignRow(ARow:longint); *)
procedure TStringAlignGrid.ResetAlignRow(ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow,FPropRow);
  if v<>NIL then
    v.align:=alDefault;
  Invalidate;
  end;
(*@\\\0000000515*)
(*@/// procedure TStringAlignGrid.ResetAlignFixedRow(ARow:longint); *)
procedure TStringAlignGrid.ResetAlignFixedRow(ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow,FFPropRow);
  if v<>NIL then
    v.align:=alDefault;
  Invalidate;
  end;
(*@\\\0000000510*)
(*@/// procedure TStringAlignGrid.ResetAlignment; *)
procedure TStringAlignGrid.ResetAlignment;
begin
  FAlign:=alLeft;
  Invalidate;
  end;
(*@\\\*)

(*@/// procedure TStringAlignGrid.ResetAlignCellAll; *)
procedure TStringAlignGrid.ResetAlignCellAll;
var
  i,j: longint;
begin
  for i:=FPropCell.Count-1 downto 0 do begin
    if FPropCell.Items[i]<>NIL then
      for j:=TList(FPropCell.Items[i]).Count-1 downto 0 do
        ResetAlignCell(i,j);
    end;
  invalidate;
  end;
(*@\\\0000000A0D*)
(*@/// procedure TStringAlignGrid.ResetAlignColAll; *)
procedure TStringAlignGrid.ResetAlignColAll;
var
  i: longint;
begin
  for i:=FPropCol.Count-1 downto 0 do begin
    ResetAlignCol(i);
    end;
  invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetAlignRowAll; *)
procedure TStringAlignGrid.ResetAlignRowAll;
var
  i: longint;
begin
  for i:=FPropRow.Count-1 downto 0 do begin
    ResetAlignRow(i);
    end;
  invalidate;
  end;
(*@\\\*)
(*@\\\0000000801*)
(*@\\\0000000201*)
(*@/// Property read and write and reset for the Wordwraps *)
(*@/// Property read and write for Wordwrap *)
(*@/// procedure TStringAlignGrid.SetWordWrap(value: T_Wordwrap); *)
procedure TStringAlignGrid.SetWordWrap(value: T_Wordwrap);
begin
  if f_wordwrap<>value then begin
    f_wordwrap:=value;
    Invalidate;
    end;
  end;
(*@\\\*)
(*@\\\*)
(*@/// Property read and write for WordwrapCell *)
(*@/// function TStringAlignGrid.GetWordwrapCell(ACol,ARow:longint):T_Wordwrap; *)
function TStringAlignGrid.GetWordwrapCell(ACol,ARow:longint):T_Wordwrap;
var
  v:TCellProperties;
  fixed: boolean;
begin
  v:=GetItemCell(ACol,ARow,FPropCell);
  fixed:=is_fixed(ACol,ARow);
  if (v=NIL) or (v.wordwrap=ww_default) then begin
    if fixed then begin
      if Col_before_Row then
        v:=GetItemCol(ACol,FFPropCol)
      else
        v:=GetItemCol(ACol,FFPropRow)
      end
    else begin
      if Col_before_Row then
        v:=GetItemCol(ACol,FPropCol)
      else
        v:=GetItemCol(ACol,FPropRow)
      end;
    if (v=NIL) or (v.wordwrap=ww_default) then begin
      if fixed then begin
        if Col_before_Row then
          v:=GetItemCol(ARow,FFPropRow)
        else
          v:=GetItemCol(ARow,FFPropCol)
        end
      else begin
        if Col_before_Row then
          v:=GetItemCol(ARow,FPropRow)
        else
          v:=GetItemCol(ARow,FPropCol)
        end;
      if (v=NIL) or (v.wordwrap=ww_default) then begin
        if wordwrap=ww_default then
          result:=ww_none
        else
          result:=wordwrap;
        end
      else
        result:=v.wordwrap;
      end
    else
      result:=v.wordwrap;
    end
  else
    result:=v.wordwrap;
  end;
(*@\\\000000210D*)
(*@/// procedure TStringAlignGrid.SetWordwrapCell(ACol,ARow:longint; const Value: T_Wordwrap); *)
procedure TStringAlignGrid.SetWordwrapCell(ACol,ARow:longint; const Value: T_wordwrap);
begin
  ObjectCell[ACol,ARow].wordwrap:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@\\\0000000201*)
(*@/// Property read and write for WordwrapCol and FixedWordwrapCol *)
(*@/// function TStringAlignGrid.GetwordwrapCol(ACol:longint):t_wordwrap; *)
function TStringAlignGrid.GetwordwrapCol(ACol:longint):t_wordwrap;
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FPropCol);
  if v=NIL then
    result:=wordwrap
  else
    result:=v.wordwrap;
  end;
(*@\\\0000000401*)
(*@/// function TStringAlignGrid.GetFixwordwrapCol(ACol:longint):t_wordwrap; *)
function TStringAlignGrid.GetFixwordwrapCol(ACol:longint):t_wordwrap;
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FFPropCol);
  if v=NIL then
    result:=wordwrap
  else
    result:=v.wordwrap;
  end;
(*@\\\0000000401*)
(*@/// procedure TStringAlignGrid.SetwordwrapCol(ACol:longint; const Value: t_wordwrap); *)
procedure TStringAlignGrid.SetwordwrapCol(ACol:longint; const Value: t_wordwrap);
begin
  ObjectCol[ACol].wordwrap:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetFixwordwrapCol(ACol:longint; const Value: t_wordwrap); *)
procedure TStringAlignGrid.SetFixwordwrapCol(ACol:longint; const Value: t_wordwrap);
begin
  ObjectFixedCol[ACol].wordwrap:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@\\\0000000401*)
(*@/// Property read and write for WordwrapRow and FixedWordwrapRow *)
(*@/// function TStringAlignGrid.GetwordwrapRow(ARow:longint):t_wordwrap; *)
function TStringAlignGrid.GetwordwrapRow(ARow:longint):t_wordwrap;
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FPropRow);
  if v=NIL then
    result:=wordwrap
  else
    result:=v.wordwrap;
  end;
(*@\\\0000000515*)
(*@/// function TStringAlignGrid.GetFixwordwrapRow(ARow:longint):t_wordwrap; *)
function TStringAlignGrid.GetFixwordwrapRow(ARow:longint):t_wordwrap;
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FFPropRow);
  if v=NIL then
    result:=wordwrap
  else
    result:=v.wordwrap;
  end;
(*@\\\0000000515*)
(*@/// procedure TStringAlignGrid.SetwordwrapRow(ARow:longint; const Value: t_wordwrap); *)
procedure TStringAlignGrid.SetwordwrapRow(ARow:longint; const Value: t_wordwrap);
begin
  ObjectRow[ARow].wordwrap:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetFixwordwrapRow(ARow:longint; const Value: t_wordwrap); *)
procedure TStringAlignGrid.SetFixwordwrapRow(ARow:longint; const Value: t_wordwrap);
begin
  ObjectFixedRow[ARow].wordwrap:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@\\\0000000401*)

(*@/// Reset Wordwrap and use the one defined a level above *)
(*@/// procedure TStringAlignGrid.ResetwordwrapCell(ACol,ARow:longint); *)
procedure TStringAlignGrid.ResetwordwrapCell(ACol,ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCell(ACol,ARow, FPropCell);
  if v<>NIL then
    v.wordwrap:=ww_default;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetwordwrapCol(ACol:longint); *)
procedure TStringAlignGrid.ResetwordwrapCol(ACol:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol,FPropCol);
  if v<>NIL then
    v.wordwrap:=ww_default;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetwordwrapFixedCol(ACol:longint); *)
procedure TStringAlignGrid.ResetwordwrapFixedCol(ACol:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol,FFPropCol);
  if v<>NIL then
    v.wordwrap:=ww_default;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetwordwrapRow(ARow:longint); *)
procedure TStringAlignGrid.ResetwordwrapRow(ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow,FPropRow);
  if v<>NIL then
    v.wordwrap:=ww_default;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetwordwrapFixedRow(ARow:longint); *)
procedure TStringAlignGrid.ResetwordwrapFixedRow(ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow,FFPropRow);
  if v<>NIL then
    v.wordwrap:=ww_default;
  Invalidate;
  end;
(*@\\\*)

(*@/// procedure TStringAlignGrid.ResetwordwrapCellAll; *)
procedure TStringAlignGrid.ResetwordwrapCellAll;
var
  i,j: longint;
begin
  for i:=FPropCell.Count-1 downto 0 do begin
    if FPropCell.Items[i]<>NIL then
      for j:=TList(FPropCell.Items[i]).Count-1 downto 0 do
        ResetwordwrapCell(i,j);
    end;
  invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetwordwrapColAll; *)
procedure TStringAlignGrid.ResetwordwrapColAll;
var
  i: longint;
begin
  for i:=FPropCol.Count-1 downto 0 do begin
    ResetwordwrapCol(i);
    end;
  invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetwordwrapRowAll; *)
procedure TStringAlignGrid.ResetwordwrapRowAll;
var
  i: longint;
begin
  for i:=FPropRow.Count-1 downto 0 do begin
    ResetwordwrapRow(i);
    end;
  invalidate;
  end;
(*@\\\*)
(*@\\\*)
(*@\\\0000000401*)
(*@/// Property read and write and reset for the edit-enabled *)
(*@/// Property read and write for EditCell *)
(*@/// function TStringAlignGrid.GetEditCell(ACol,ARow:longint):boolean; *)
function TStringAlignGrid.GetEditCell(ACol,ARow:longint):boolean;
var
  v:TCellProperties;
  fixed: boolean;
begin
  v:=GetItemCell(ACol,ARow,FPropCell);
  fixed:=is_fixed(ACol,ARow);
  if (v=NIL) or (v.editable=0) then begin
    if fixed then begin
      if Col_before_Row then
        v:=GetItemCol(ACol,FFPropCol)
      else
        v:=GetItemCol(ACol,FFPropRow)
      end
    else begin
      if Col_before_Row then
        v:=GetItemCol(ACol,FPropCol)
      else
        v:=GetItemCol(ACol,FPropRow)
      end;
    if (v=NIL) or (v.editable=0) then begin
      if fixed then begin
        if Col_before_Row then
          v:=GetItemCol(ARow,FFPropRow)
        else
          v:=GetItemCol(ARow,FFPropCol)
        end
      else begin
        if Col_before_Row then
          v:=GetItemCol(ARow,FPropRow)
        else
          v:=GetItemCol(ARow,FPropCol)
        end;
      if (v=NIL) or (v.editable=0) then
        result:=editable
      else
        result:=v.editable=2;
      end
    else
      result:=v.editable=2;
    end
  else
    result:=v.editable=2;
  end;
(*@\\\0000001D01*)
(*@/// procedure TStringAlignGrid.SetEditCell(ACol,ARow:longint; const Value: boolean); *)
procedure TStringAlignGrid.SetEditCell(ACol,ARow:longint; const Value: boolean);
begin
  ObjectCell[ACol,ARow].editable:=ord(value)+1;
  end;
(*@\\\0000000303*)
(*@\\\0000000201*)
(*@/// Property read and write for EditCol *)
(*@/// function TStringAlignGrid.GetEditCol(ACol:longint):boolean; *)
function TStringAlignGrid.GetEditCol(ACol:longint):boolean;
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FPropCol);
  if v=NIL then
    result:=editable
  else
    result:=v.editable=2;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.SetEditCol(ACol:longint; const Value: boolean); *)
procedure TStringAlignGrid.SetEditCol(ACol:longint; const Value: boolean);
begin
  ObjectCol[ACol].editable:=ord(value)+1;
  end;
(*@\\\0000000301*)
(*@\\\0000000201*)
(*@/// Property read and write for EditRow *)
(*@/// function TStringAlignGrid.GetEditRow(ARow:longint):boolean; *)
function TStringAlignGrid.GetEditRow(ARow:longint):boolean;
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FPropRow);
  if v=NIL then
    result:=editable
  else
    result:=v.editable=2;
  end;
(*@\\\0000000515*)
(*@/// procedure TStringAlignGrid.SetEditRow(ARow:longint; const Value: boolean); *)
procedure TStringAlignGrid.SetEditRow(ARow:longint; const Value: boolean);
begin
  ObjectRow[ARow].editable:=ord(value)+1;
  end;
(*@\\\0000000401*)
(*@\\\0000000201*)

(*@/// Reset Edit and use the one defined a level above *)
(*@/// procedure TStringAlignGrid.ResetEditCell(ACol,ARow:longint); *)
procedure TStringAlignGrid.ResetEditCell(ACol,ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCell(ACol,ARow, FPropCell);
  if v<>NIL then
    v.editable:=0;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetEditCol(ACol:longint); *)
procedure TStringAlignGrid.ResetEditCol(ACol:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol,FPropCol);
  if v<>NIL then
    v.editable:=0;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetEditRow(ARow:longint); *)
procedure TStringAlignGrid.ResetEditRow(ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow,FPropRow);
  if v<>NIL then
    v.editable:=0;
  Invalidate;
  end;
(*@\\\*)

(*@/// procedure TStringAlignGrid.ResetEditCellAll; *)
procedure TStringAlignGrid.ResetEditCellAll;
var
  i,j: longint;
begin
  for i:=FPropCell.Count-1 downto 0 do begin
    if FPropCell.Items[i]<>NIL then
      for j:=TList(FPropCell.Items[i]).Count-1 downto 0 do
        ResetEditCell(i,j);
    end;
  invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetEditColAll; *)
procedure TStringAlignGrid.ResetEditColAll;
var
  i: longint;
begin
  for i:=FPropCol.Count-1 downto 0 do begin
    ResetEditCol(i);
    end;
  invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetEditRowAll; *)
procedure TStringAlignGrid.ResetEditRowAll;
var
  i: longint;
begin
  for i:=FPropRow.Count-1 downto 0 do begin
    ResetEditRow(i);
    end;
  invalidate;
  end;
(*@\\\*)
(*@\\\0000000401*)
(*@\\\*)
(*@/// Property read and write and reset for Fonts *)
(*@/// Property read and write for FontCell *)
(*@/// function TStringAlignGrid.GetFontCell(ACol,ARow: longint):TFont; *)
function TStringAlignGrid.GetFontCell(ACol,ARow: longint):TFont;
begin
  GetFontCell:=GetFontCellInternal(ACol,ARow,true);
  end;
(*@\\\0000000323*)
(*@/// procedure TStringAlignGrid.SetFontCell(ACol,ARow: longint; const Value: TFont); *)
procedure TStringAlignGrid.SetFontCell(ACol,ARow: longint; const Value: TFont);
begin
  ObjectCell[ACol,ARow].font:=value;
  Invalidate;
  end;
(*@\\\0000000301*)
(*@\\\0000000227*)
(*@/// Property read and write for FontCol/FixedFontCol *)
(*@/// function TStringAlignGrid.GetFontCol(ACol: longint):TFont; *)
function TStringAlignGrid.GetFontCol(ACol: longint):TFont;
begin
  GetFontCol:=GetFontColRowInternal(ACol,true,FPropCol);
  end;
(*@\\\0000000334*)
(*@/// function TStringAlignGrid.GetFontFixedCol(ACol: longint):TFont; *)
function TStringAlignGrid.GetFontFixedCol(ACol: longint):TFont;
begin
  GetFontFixedCol:=GetFontColRowInternal(ACol,true,FFPropCol);
  end;
(*@\\\000000033A*)
(*@/// procedure TStringAlignGrid.SetFontCol(ACol: longint; const Value: TFont); *)
procedure TStringAlignGrid.SetFontCol(ACol: longint; const Value: TFont);
begin
  ObjectCol[ACol].font:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetFontFixedCol(ACol: longint; const Value: TFont); *)
procedure TStringAlignGrid.SetFontFixedCol(ACol: longint; const Value: TFont);
begin
  ObjectFixedCol[ACol].font:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@\\\0000000401*)
(*@/// Property read and write for FontRow/FixedFontRow *)
(*@/// function TStringAlignGrid.GetFontRow(ARow: longint):TFont; *)
function TStringAlignGrid.GetFontRow(ARow: longint):TFont;
begin
  GetFontRow:=GetFontColRowInternal(ARow,true,FPropRow);
  end;
(*@\\\0000000334*)
(*@/// function TStringAlignGrid.GetFontFixedRow(ARow: longint):TFont; *)
function TStringAlignGrid.GetFontFixedRow(ARow: longint):TFont;
begin
  GetFontFixedRow:=GetFontColRowInternal(ARow,true,FFPropRow);
  end;
(*@\\\000000033A*)
(*@/// procedure TStringAlignGrid.SetFontRow(ARow: longint; const Value: TFont); *)
procedure TStringAlignGrid.SetFontRow(ARow: longint; const Value: TFont);
begin
  ObjectRow[ARow].font:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetFontFixedRow(ARow: longint; const Value: TFont); *)
procedure TStringAlignGrid.SetFontFixedRow(ARow: longint; const Value: TFont);
begin
  ObjectFixedRow[ARow].font:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@\\\000000040A*)

(*@/// Reset font and use the one defined a level above *)
(*@/// procedure TStringAlignGrid.ResetFontCol(ACol:longint); *)
procedure TStringAlignGrid.ResetFontCol(ACol:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FPropCol);
  if v<>NIL then
    v.font:=NIL;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.ResetFontFixedCol(ACol:longint); *)
procedure TStringAlignGrid.ResetFontFixedCol(ACol:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FFPropCol);
  if v<>NIL then
    v.font:=NIL;
  Invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetFontRow(ARow:longint); *)
procedure TStringAlignGrid.ResetFontRow(ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FPropRow);
  if v<>NIL then
    v.font:=NIL;
  Invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetFontFixedRow(ARow:longint); *)
procedure TStringAlignGrid.ResetFontFixedRow(ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FFPropRow);
  if v<>NIL then
    v.font:=NIL;
  Invalidate;
  end;
(*@\\\0000000518*)
(*@/// procedure TStringAlignGrid.ResetFontCell(ACol,ARow:longint); *)
procedure TStringAlignGrid.ResetFontCell(ACol,ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCell(ACol,ARow, FPropCell);
  if v<>NIL then
    v.font:=NIL;
  Invalidate;
  end;
(*@\\\*)

(*@/// procedure TStringAlignGrid.ResetFontCellAll; *)
procedure TStringAlignGrid.ResetFontCellAll;
var
  i,j: longint;
begin
  for i:=FPropCell.Count-1 downto 0 do begin
    if FPropCell.Items[i]<>NIL then
      for j:=TList(FPropCell.Items[i]).Count-1 downto 0 do
        ResetFontCell(i,j);
    end;
  invalidate;
  end;
(*@\\\0000000801*)
(*@/// procedure TStringAlignGrid.ResetFontColAll; *)
procedure TStringAlignGrid.ResetFontColAll;
var
  i: longint;
begin
  for i:=FPropCol.Count-1 downto 0 do begin
    ResetFontCol(i);
    end;
  invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetFontRowAll; *)
procedure TStringAlignGrid.ResetFontRowAll;
var
  i: longint;
begin
  for i:=FPropRow.Count-1 downto 0 do begin
    ResetFontRow(i);
    end;
  invalidate;
  end;
(*@\\\*)
(*@\\\0000000701*)

(*@/// procedure TStringAlignGrid.SetFixedFont(value: TFont); *)
procedure TStringAlignGrid.SetFixedFont(value: TFont);
begin
  if value=NIL then
    FFixedFont.Assign(self.font)
  else
    FFixedFont.assign(value);
  invalidate;
  end;
(*@\\\000000070E*)
(*@\\\0000000701*)
(*@/// Property read and write and reset for Brushs *)
(*@/// Property read and write for BrushCell *)
(*@/// function TStringAlignGrid.GetBrushCell(ACol,ARow: longint):TBrush; *)
function TStringAlignGrid.GetBrushCell(ACol,ARow: longint):TBrush;
begin
  GetBrushCell:=GetBrushCellInternal(ACol,ARow,true);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.SetBrushCell(ACol,ARow: longint; const Value: TBrush); *)
procedure TStringAlignGrid.SetBrushCell(ACol,ARow: longint; const Value: TBrush);
begin
  ObjectCell[ACol,ARow].brush:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@\\\0000000201*)
(*@/// Property read and write for BrushCol/FixedBrushCol *)
(*@/// function TStringAlignGrid.GetBrushCol(ACol: longint):TBrush; *)
function TStringAlignGrid.GetBrushCol(ACol: longint):TBrush;
begin
  GetBrushCol:=GetBrushColRowInternal(ACol,true,FPropCol);
  end;
(*@\\\0000000401*)
(*@/// function TStringAlignGrid.GetBrushFixedCol(ACol: longint):TBrush; *)
function TStringAlignGrid.GetBrushFixedCol(ACol: longint):TBrush;
begin
  GetBrushFixedCol:=GetBrushColRowInternal(ACol,true,FFPropCol);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.SetBrushCol(ACol: longint; const Value: TBrush); *)
procedure TStringAlignGrid.SetBrushCol(ACol: longint; const Value: TBrush);
begin
  ObjectCol[ACol].brush:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetBrushFixedCol(ACol: longint; const Value: TBrush); *)
procedure TStringAlignGrid.SetBrushFixedCol(ACol: longint; const Value: TBrush);
begin
  ObjectFixedCol[ACol].brush:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@\\\0000000401*)
(*@/// Property read and write for BrushRow/FixedBrushRow *)
(*@/// function TStringAlignGrid.GetBrushRow(ARow: longint):TBrush; *)
function TStringAlignGrid.GetBrushRow(ARow: longint):TBrush;
begin
  GetBrushRow:=GetBrushColRowInternal(ARow,true,FPropRow);
  end;
(*@\\\*)
(*@/// function TStringAlignGrid.GetBrushFixedRow(ARow: longint):TBrush; *)
function TStringAlignGrid.GetBrushFixedRow(ARow: longint):TBrush;
begin
  GetBrushFixedRow:=GetBrushColRowInternal(ARow,true,FFPropRow);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.SetBrushRow(ARow: longint; const Value: TBrush); *)
procedure TStringAlignGrid.SetBrushRow(ARow: longint; const Value: TBrush);
begin
  ObjectRow[ARow].brush:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetBrushFixedRow(ARow: longint; const Value: TBrush); *)
procedure TStringAlignGrid.SetBrushFixedRow(ARow: longint; const Value: TBrush);
begin
  ObjectFixedRow[ARow].brush:=value;
  Invalidate;
  end;
(*@\\\0000000501*)
(*@\\\0000000401*)

(*@/// Reset Brush and use the one defined a level above *)
(*@/// procedure TStringAlignGrid.ResetBrushCol(ACol:longint); *)
procedure TStringAlignGrid.ResetBrushCol(ACol:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FPropCol);
  if v<>NIL then
    v.Brush:=NIL;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetBrushFixedCol(ACol:longint); *)
procedure TStringAlignGrid.ResetBrushFixedCol(ACol:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FFPropCol);
  if v<>NIL then
    v.Brush:=NIL;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetBrushRow(ARow:longint); *)
procedure TStringAlignGrid.ResetBrushRow(ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FPropRow);
  if v<>NIL then
    v.Brush:=NIL;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetBrushFixedRow(ARow:longint); *)
procedure TStringAlignGrid.ResetBrushFixedRow(ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FFPropRow);
  if v<>NIL then
    v.Brush:=NIL;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetBrushCell(ACol,ARow:longint); *)
procedure TStringAlignGrid.ResetBrushCell(ACol,ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCell(ACol,ARow, FPropCell);
  if v<>NIL then
    v.Brush:=NIL;
  Invalidate;
  end;
(*@\\\*)

(*@/// procedure TStringAlignGrid.ResetBrushCellAll; *)
procedure TStringAlignGrid.ResetBrushCellAll;
var
  i,j: longint;
begin
  for i:=FPropCell.Count-1 downto 0 do begin
    if FPropCell.Items[i]<>NIL then
      for j:=TList(FPropCell.Items[i]).Count-1 downto 0 do
        ResetBrushCell(i,j);
    end;
  invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetBrushColAll; *)
procedure TStringAlignGrid.ResetBrushColAll;
var
  i: longint;
begin
  for i:=FPropCol.Count-1 downto 0 do begin
    ResetBrushCol(i);
    end;
  invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetBrushRowAll; *)
procedure TStringAlignGrid.ResetBrushRowAll;
var
  i: longint;
begin
  for i:=FPropRow.Count-1 downto 0 do begin
    ResetBrushRow(i);
    end;
  invalidate;
  end;
(*@\\\*)
(*@\\\*)
(*@\\\0000000501*)
(*@/// Property read and write and reset for Colors (done via Brushes!) *)
(*@/// Property read and write for ColorCell *)
{ Property read and write for ColorCell }
(*@/// function TStringAlignGrid.GetColorCell(ACol,ARow:longint):TColor; *)
function TStringAlignGrid.GetColorCell(ACol,ARow:longint):TColor;
begin
  result:=GetBrushCellComplete(ACol,ARow).color;
  end;
(*@\\\000000031F*)
(*@/// procedure TStringAlignGrid.SetColorCell(ACol,ARow:longint; const Value: TColor); *)
procedure TStringAlignGrid.SetColorCell(ACol,ARow:longint; const Value: TColor);
begin
  CellBrush[ACol,ARow].Color:=value;
  Invalidate;
  end;
(*@\\\0000000401*)
(*@\\\0000000301*)
(*@/// Property read and write for ColorCol and FixedColorCol *)
{ Property read and write for ColorCol and FixedColorCol }
(*@/// function TStringAlignGrid.GetColorCol(ACol:longint):TColor; *)
function TStringAlignGrid.GetColorCol(ACol:longint):TColor;
var
  h: TBrush;
begin
  h:=GetBrushColRowInternal(ACol,false,FPropCol);
  if h<>NIL then
    result:=h.color
  else
    result:=self.color;
  end;
(*@\\\0000000701*)
(*@/// procedure TStringAlignGrid.SetColorCol(ACol:longint; const Value: TColor); *)
procedure TStringAlignGrid.SetColorCol(ACol:longint; const Value: TColor);
begin
  ColBrush[Acol].color:=value;
  Invalidate;
  end;
(*@\\\0000000303*)
(*@/// function TStringAlignGrid.GetFixColorCol(ACol:longint):TColor; *)
function TStringAlignGrid.GetFixColorCol(ACol:longint):TColor;
var
  h: TBrush;
begin
  h:=GetBrushColRowInternal(ACol,false,FFPropCol);
  if h<>NIL then
    result:=h.color
  else
    result:=self.color;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetFixColorCol(ACol:longint; const Value: TColor); *)
procedure TStringAlignGrid.SetFixColorCol(ACol:longint; const Value: TColor);
begin
  FixedColBrush[Acol].color:=value;
  Invalidate;
  end;
(*@\\\0000000301*)
(*@\\\0000000301*)
(*@/// Property read and write for ColorRow and FixedColorRow *)
{ Property read and write for ColorRow and FixedColorRow }
(*@/// function TStringAlignGrid.GetColorRow(ARow:longint):TColor; *)
function TStringAlignGrid.GetColorRow(ARow:longint):TColor;
var
  h: TBrush;
begin
  h:=GetBrushColRowInternal(ARow,false,FPropRow);
  if h<>NIL then
    result:=h.color
  else
    result:=self.color;
  end;
(*@\\\000000052D*)
(*@/// procedure TStringAlignGrid.SetColorRow(ARow:longint; const Value: TColor); *)
procedure TStringAlignGrid.SetColorRow(ARow:longint; const Value: TColor);
begin
  RowBrush[ARow].color:=value;
  Invalidate;
  end;
(*@\\\*)
(*@/// function TStringAlignGrid.GetFixColorRow(ARow:longint):TColor; *)
function TStringAlignGrid.GetFixColorRow(ARow:longint):TColor;
var
  h: TBrush;
begin
  h:=GetBrushColRowInternal(ARow,false,FPropRow);
  if h<>NIL then
    result:=h.color
  else
    result:=self.color;
  end;
(*@\\\000000052D*)
(*@/// procedure TStringAlignGrid.SetFixColorRow(ARow:longint; const Value: TColor); *)
procedure TStringAlignGrid.SetFixColorRow(ARow:longint; const Value: TColor);
begin
  FixedRowBrush[ARow].color:=value;
  Invalidate;
  end;
(*@\\\*)
(*@\\\0000000301*)

(*@/// Reset color and use the one defined a level above *)
(*@/// procedure TStringAlignGrid.ResetColorCell(ACol,ARow:longint); *)
procedure TStringAlignGrid.ResetColorCell(ACol,ARow:longint);
begin
  ResetBrushCell(ACol,ARow);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetColorCol(ACol:longint); *)
procedure TStringAlignGrid.ResetColorCol(ACol:longint);
begin
  ResetBrushCol(ACol);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetColorFixedCol(ACol:longint); *)
procedure TStringAlignGrid.ResetColorFixedCol(ACol:longint);
begin
  ResetBrushFixedCol(ACol);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetColorRow(ARow:longint); *)
procedure TStringAlignGrid.ResetColorRow(ARow:longint);
begin
  ResetBrushRow(ARow);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetColorFixedRow(ARow:longint); *)
procedure TStringAlignGrid.ResetColorFixedRow(ARow:longint);
begin
  ResetBrushFixedRow(ARow);
  end;
(*@\\\*)

(*@/// procedure TStringAlignGrid.ResetColorCellAll; *)
procedure TStringAlignGrid.ResetColorCellAll;
begin
  ResetBrushCellAll;
  end;
(*@\\\0000000301*)
(*@/// procedure TStringAlignGrid.ResetColorColAll; *)
procedure TStringAlignGrid.ResetColorColAll;
begin
  ResetBrushColAll;
  end;
(*@\\\000000030F*)
(*@/// procedure TStringAlignGrid.ResetColorRowAll; *)
procedure TStringAlignGrid.ResetColorRowAll;
begin
  ResetBrushRowAll;
  end;
(*@\\\0000000301*)
(*@\\\0000000901*)

(*@/// procedure TStringAlignGrid.SetFixedColor(const Value: TColor); *)
procedure TStringAlignGrid.SetFixedColor(const Value: TColor);
begin
  inherited FixedColor:=value;
  FFixedBrush.color:=value;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.SetSelCellColor(Value: TColor); *)
procedure TStringAlignGrid.SetSelCellColor(Value: TColor);
begin
  f_SelCellColor:=value;
  invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.SetSelFontColor(Value: TColor); *)
procedure TStringAlignGrid.SetSelFontColor(Value: TColor);
begin
  f_SelFontColor:=value;
  invalidate;
  end;
(*@\\\*)

(*@/// procedure TStringAlignGrid.setaltrowcolor(value:TColor); *)
procedure TStringAlignGrid.setaltrowcolor(value:TColor);
begin
  if value<>f_altrowcolor then begin
    f_altrowcolor:=value;
    if f_doaltrowcolor then
      invalidate;
    end;
  end;
(*@\\\0000000405*)
(*@/// procedure TStringAlignGrid.setaltcolcolor(value:TColor); *)
procedure TStringAlignGrid.setaltcolcolor(value:TColor);
begin
  if value<>f_altcolcolor then begin
    f_altcolcolor:=value;
    if f_doaltcolcolor then
      invalidate;
    end;
  end;
(*@\\\0000000807*)
(*@/// procedure TStringAlignGrid.setdoaltrowcolor(value:boolean); *)
procedure TStringAlignGrid.setdoaltrowcolor(value:boolean);
begin
  if f_doaltrowcolor<>value then begin
    f_doaltrowcolor:=value;
    invalidate;
    end;
  end;
(*@\\\0000000405*)
(*@/// procedure TStringAlignGrid.setdoaltcolcolor(value:boolean); *)
procedure TStringAlignGrid.setdoaltcolcolor(value:boolean);
begin
  if f_doaltcolcolor<>value then begin
    f_doaltcolcolor:=value;
    invalidate;
    end;
  end;
(*@\\\*)
(*@\\\0000000D01*)
(*@/// Property read and write and reset for Selected Colors *)
(*@/// Property read and write for SelColorCell *)
(*@/// function TStringAlignGrid.GetSelColorCell(ACol,ARow:longint):TColor; *)
function TStringAlignGrid.GetSelColorCell(ACol,ARow:longint):TColor;
var
  v:TCellproperties;
begin
  v:=GetItemCell(ACol,ARow,FPropCell);
  if (v=NIL) or (v.SelBrush=NIL) then begin
    if Col_before_Row then
      v:=GetItemCol(ACol,FPropCol)
    else
      v:=GetItemCol(ACol,FPropRow);
    if (v=NIL) or (v.SelBrush=NIL) then begin
      if Col_before_Row then
        v:=GetItemCol(ARow,FPropRow)
      else
        v:=GetItemCol(ARow,FPropCol);
      if (v=NIL) or (v.SelBrush=NIL) then
        result:=f_SelCellColor
      else
        result:=v.selbrush.color;
      end
    else
      result:=v.selbrush.color;
    end
  else
    result:=v.selbrush.color;
  end;
(*@\\\0000000C01*)
(*@/// procedure TStringAlignGrid.SetSelColorCell(ACol,ARow:longint; const Value: TColor); *)
procedure TStringAlignGrid.SetSelColorCell(ACol,ARow:longint; const Value: TColor);
var
  f: TBrush;
begin
  f:=NIL;
  try
    f:=TBrush.Create;
    f.color:=value;
    ObjectCell[ACol,ARow].selbrush:=f;
    Invalidate;
  finally
    f.free;
    end;
  end;
(*@\\\0000000A01*)
(*@\\\0000000201*)
(*@/// Property read and write for SelColorCol *)
(*@/// function TStringAlignGrid.GetSelColorCol(ACol:longint):TColor; *)
function TStringAlignGrid.GetSelColorCol(ACol:longint):TColor;
var
  v:TCellproperties;
begin
  v:=GetItemCol(ACol,FPropCol);
  if (v=NIL) or (v.SelBrush=NIL) then
    result:=f_SelCellColor
  else
    result:=v.selbrush.color;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.SetSelColorCol(ACol:longint; const Value: TColor); *)
procedure TStringAlignGrid.SetSelColorCol(ACol:longint; const Value: TColor);
var
  f: TBrush;
begin
  f:=NIL;
  try
    f:=TBrush.Create;
    f.color:=value;
    ObjectCol[ACol].selbrush:=f;
    Invalidate;
  finally
    f.free;
    end;
  end;
(*@\\\0000000A01*)
(*@\\\0000000201*)
(*@/// Property read and write for SelColorRow *)
(*@/// function TStringAlignGrid.GetSelColorRow(ARow:longint):TColor; *)
function TStringAlignGrid.GetSelColorRow(ARow:longint):TColor;
var
  v:TCellproperties;
begin
  v:=GetItemCol(ARow,FPropRow);
  if (v=NIL) or (v.SelBrush=NIL) then
    result:=f_SelCellColor
  else
    result:=v.selbrush.color;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.SetSelColorRow(ARow:longint; const Value: TColor); *)
procedure TStringAlignGrid.SetSelColorRow(ARow:longint; const Value: TColor);
var
  f: TBrush;
begin
  f:=NIL;
  try
    f:=TBrush.Create;
    f.color:=value;
    ObjectRow[ARow].selbrush:=f;
    Invalidate;
  finally
    f.free;
    end;
  end;
(*@\\\0000000B01*)
(*@\\\0000000201*)

(*@/// procedure TStringAlignGrid.ResetSelectedColorCell(ACol,ARow:longint); *)
procedure TStringAlignGrid.ResetSelectedColorCell(ACol,ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCell(ACol,ARow, FPropCell);
  if v<>NIL then
    v.selBrush:=NIL;
  Invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetSelectedColorCol(ACol:longint); *)
procedure TStringAlignGrid.ResetSelectedColorCol(ACol:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FPropCol);
  if v<>NIL then
    v.selBrush:=NIL;
  Invalidate;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetSelectedColorRow(ARow:longint); *)
procedure TStringAlignGrid.ResetSelectedColorRow(ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FPropRow);
  if v<>NIL then
    v.selBrush:=NIL;
  Invalidate;
  end;
(*@\\\*)

(*@/// procedure TStringAlignGrid.ResetSelectedColorCellAll; *)
procedure TStringAlignGrid.ResetSelectedColorCellAll;
var
  i,j: longint;
begin
  for i:=FPropCell.Count-1 downto 0 do begin
    if FPropCell.Items[i]<>NIL then
      for j:=TList(FPropCell.Items[i]).Count-1 downto 0 do
        ResetBrushCell(i,j);
    end;
  invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetSelectedColorColAll; *)
procedure TStringAlignGrid.ResetSelectedColorColAll;
var
  i: longint;
begin
  for i:=FPropCol.Count-1 downto 0 do begin
    ResetBrushCol(i);
    end;
  invalidate;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ResetSelectedColorRowAll; *)
procedure TStringAlignGrid.ResetSelectedColorRowAll;
var
  i: longint;
begin
  for i:=FPropRow.Count-1 downto 0 do begin
    ResetBrushRow(i);
    end;
  invalidate;
  end;
(*@\\\0000000512*)
(*@\\\*)
(*@/// Property read and write and reset for Selected Font Colors *)
(*@/// Property read and write for SelFontColorCell *)
(*@/// function TStringAlignGrid.GetSelFontColorCell(ACol,ARow:longint):TColor; *)
function TStringAlignGrid.GetSelFontColorCell(ACol,ARow:longint):TColor;
var
  v:TCellproperties;
begin
  v:=GetItemCell(ACol,ARow,FPropCell);
  if (v=NIL) or (v.SelFont=NIL) then begin
    if Col_before_Row then
      v:=GetItemCol(ACol,FPropCol)
    else
      v:=GetItemCol(ACol,FPropRow);
    if (v=NIL) or (v.SelFont=NIL) then begin
      if Col_before_Row then
        v:=GetItemCol(ARow,FPropRow)
      else
        v:=GetItemCol(ARow,FPropCol);
      if (v=NIL) or (v.SelFont=NIL) then
        result:=f_SelFontColor
      else
        result:=v.selFont.color;
      end
    else
      result:=v.selFont.color;
    end
  else
    result:=v.selFont.color;
  end;
(*@\\\0000001012*)
(*@/// procedure TStringAlignGrid.SetSelFontColorCell(ACol,ARow:longint; const Value: TColor); *)
procedure TStringAlignGrid.SetSelFontColorCell(ACol,ARow:longint; const Value: TColor);
var
  f: TFont;
begin
  f:=NIL;
  try
    f:=TFont.Create;
    f.color:=value;
    ObjectCell[ACol,ARow].selfont:=f;
    Invalidate;
  finally
    f.free;
    end;
  end;
(*@\\\*)
(*@\\\0000000201*)
(*@/// Property read and write for SelFontColorCol *)
(*@/// function TStringAlignGrid.GetSelFontColorCol(ACol:longint):TColor; *)
function TStringAlignGrid.GetSelFontColorCol(ACol:longint):TColor;
var
  v:TCellproperties;
begin
  v:=GetItemCol(ACol,FPropCol);
  if (v=NIL) or (v.SelFont=NIL) then
    result:=f_SelCellColor
  else
    result:=v.selFont.color;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.SetSelFontColorCol(ACol:longint; const Value: TColor); *)
procedure TStringAlignGrid.SetSelFontColorCol(ACol:longint; const Value: TColor);
var
  f: TFont;
begin
  f:=NIL;
  try
    f:=TFont.Create;
    f.color:=value;
    ObjectCol[ACol].selfont:=f;
    Invalidate;
  finally
    f.free;
    end;
  end;
(*@\\\0000000B01*)
(*@\\\0000000201*)
(*@/// Property read and write for SelFontColorRow *)
(*@/// function TStringAlignGrid.GetSelFontColorRow(ARow:longint):TColor; *)
function TStringAlignGrid.GetSelFontColorRow(ARow:longint):TColor;
var
  v:TCellproperties;
begin
  v:=GetItemCol(ARow,FPropRow);
  if (v=NIL) or (v.SelFont=NIL) then
    result:=f_SelCellColor
  else
    result:=v.selFont.color;
  end;
(*@\\\0000000601*)
(*@/// procedure TStringAlignGrid.SetSelFontColorRow(ARow:longint; const Value: TColor); *)
procedure TStringAlignGrid.SetSelFontColorRow(ARow:longint; const Value: TColor);
var
  f: TFont;
begin
  f:=NIL;
  try
    f:=TFont.Create;
    f.color:=value;
    ObjectRow[ARow].selfont:=f;
    Invalidate;
  finally
    f.free;
    end;
  end;
(*@\\\0000000B01*)
(*@\\\0000000201*)

(*@/// procedure TStringAlignGrid.ResetSelectedFontColorCell(ACol,ARow:longint); *)
procedure TStringAlignGrid.ResetSelectedFontColorCell(ACol,ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCell(ACol,ARow, FPropCell);
  if v<>NIL then
    v.selFont:=NIL;
  Invalidate;
  end;
(*@\\\0000000907*)
(*@/// procedure TStringAlignGrid.ResetSelectedFontColorCol(ACol:longint); *)
procedure TStringAlignGrid.ResetSelectedFontColorCol(ACol:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ACol, FPropCol);
  if v<>NIL then
    v.selFont:=NIL;
  Invalidate;
  end;
(*@\\\0000000907*)
(*@/// procedure TStringAlignGrid.ResetSelectedFontColorRow(ARow:longint); *)
procedure TStringAlignGrid.ResetSelectedFontColorRow(ARow:longint);
var
  v:TCellProperties;
begin
  v:=GetItemCol(ARow, FPropRow);
  if v<>NIL then
    v.selFont:=NIL;
  Invalidate;
  end;
(*@\\\0000000907*)

(*@/// procedure TStringAlignGrid.ResetSelectedFontColorCellAll; *)
procedure TStringAlignGrid.ResetSelectedFontColorCellAll;
var
  i,j: longint;
begin
  for i:=FPropCell.Count-1 downto 0 do begin
    if FPropCell.Items[i]<>NIL then
      for j:=TList(FPropCell.Items[i]).Count-1 downto 0 do
        ResetFontCell(i,j);
    end;
  invalidate;
  end;
(*@\\\0000000B07*)
(*@/// procedure TStringAlignGrid.ResetSelectedFontColorColAll; *)
procedure TStringAlignGrid.ResetSelectedFontColorColAll;
var
  i: longint;
begin
  for i:=FPropCol.Count-1 downto 0 do begin
    ResetFontCol(i);
    end;
  invalidate;
  end;
(*@\\\000000080D*)
(*@/// procedure TStringAlignGrid.ResetSelectedFontColorRowAll; *)
procedure TStringAlignGrid.ResetSelectedFontColorRowAll;
var
  i: longint;
begin
  for i:=FPropRow.Count-1 downto 0 do begin
    ResetFontRow(i);
    end;
  invalidate;
  end;
(*@\\\000000012D*)
(*@\\\*)
(*@/// Property read and write for HintCell *)
{ Property read and write for HintCell }
(*@/// function TStringAlignGrid.GetHintCell(ACol,ARow: longint):string; *)
function TStringAlignGrid.GetHintCell(ACol,ARow: longint):string;
var
  v:pstring;
begin
  v:=GetItemCell(ACol,ARow,FHintCell);
  if v=NIL then
    GetHintCell:=''
  else
    GetHintCell:=v^;
  end;
(*@\\\0000000122*)
(*@/// procedure TStringAlignGrid.SetHintCell(ACol,ARow: longint; const Value: string); *)
procedure TStringAlignGrid.SetHintCell(ACol,ARow: longint; const Value: string);
var
  v:pstring;
begin
  FSaveHint:=true;
  v:=NewStr(value);
  v:=SetItemCell(ACol,ARow, FHintCell, v);
  if v<>NIL then
    DisposeStr(v);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ResetHintCellAll; *)
procedure TStringAlignGrid.ResetHintCellAll;
var
  i: longint;
begin
  for i:=FHintCell.Count-1 downto 0 do begin
    cleanlist_pstring(TList(FHintCell.Items[i]));
    TList(FHintCell.Items[i]).Free;
    end;
  FHintCell.clear;
  end;
(*@\\\0000000913*)
(*@\\\0000000401*)
(*@/// Resetting all the setting at once *)
(*@/// procedure TStringAligngrid.ResetAllCell(ACol,ARow:longint); *)
procedure TStringAligngrid.ResetAllCell(ACol,ARow:longint);
begin
  ResetAlignCell(ACol,ARow);
  ResetWordwrapCell(ACol,ARow);
  ResetEditCell(ACol,ARow);
  ResetFontCell(ACol,ARow);
  ResetBrushCell(ACol,ARow);
  ResetSelectedColorCell(ACol,ARow);
  ResetSelectedFontColorCell(ACol,ARow);
  end;
(*@\\\0000000410*)
(*@/// procedure TStringAligngrid.ResetAllCol(ACol:longint); *)
procedure TStringAligngrid.ResetAllCol(ACol:longint);
begin
  ResetAlignCol(ACol);
  ResetWordWrapCol(ACol);
  ResetEditCol(ACol);
  ResetFontCol(ACol);
  ResetBrushCol(ACol);
  ResetSelectedColorCol(ACol);
  ResetSelectedFontColorCol(ACol);
  end;
(*@\\\0000000410*)
(*@/// procedure TStringAligngrid.ResetAllFixedCol(ACol:longint); *)
procedure TStringAligngrid.ResetAllFixedCol(ACol:longint);
begin
  ResetAlignFixedCol(ACol);
  ResetWordwrapFixedCol(ACol);
  ResetFontFixedCol(ACol);
  ResetBrushFixedCol(ACol);
  end;
(*@\\\0000000410*)
(*@/// procedure TStringAligngrid.ResetAllRow(ARow:longint); *)
procedure TStringAligngrid.ResetAllRow(ARow:longint);
begin
  ResetAlignRow(ARow);
  ResetWordwrapRow(ARow);
  ResetEditRow(ARow);
  ResetFontRow(ARow);
  ResetBrushRow(ARow);
  ResetSelectedColorRow(ARow);
  ResetSelectedFontColorRow(ARow);
  end;
(*@\\\0000000410*)
(*@/// procedure TStringAligngrid.ResetAllFixedRow(ARow:longint); *)
procedure TStringAligngrid.ResetAllFixedRow(ARow:longint);
begin
  ResetAlignFixedRow(ARow);
  ResetWordwrapFixedRow(ARow);
  ResetFontFixedRow(ARow);
  ResetBrushFixedRow(ARow);
  end;
(*@\\\0000000410*)

(*@/// procedure TStringAligngrid.ResetAllCellAll; *)
procedure TStringAligngrid.ResetAllCellAll;
begin
  ResetAlignCellAll;
  ResetWordwrapCellAll;
  ResetEditCellAll;
  ResetFontCellAll;
  ResetBrushCellAll;
  ResetSelectedColorCellAll;
  ResetSelectedFontColorCellAll;
  end;
(*@\\\0000000410*)
(*@/// procedure TStringAligngrid.ResetAllColAll; *)
procedure TStringAligngrid.ResetAllColAll;
begin
  ResetAlignColAll;
  ResetWordwrapColAll;
  ResetEditColAll;
  ResetFontColAll;
  ResetBrushColAll;
  ResetSelectedColorColAll;
  ResetSelectedFontColorColAll;
  end;
(*@\\\0000000410*)
(*@/// procedure TStringAligngrid.ResetAllRowAll; *)
procedure TStringAligngrid.ResetAllRowAll;
begin
  ResetAlignRowAll;
  ResetWordwrapRowAll;
  ResetEditRowAll;
  ResetFontRowAll;
  ResetBrushRowAll;
  ResetSelectedColorRowAll;
  ResetSelectedFontColorRowAll;
  end;
(*@\\\0000000410*)
(*@\\\*)

(*@/// Insertion, removing, moving and exchanging of Rows and Columns *)
{ Cols.Delete[i] isn't implemented in any Delphi version I know of, it
  is abstract in D1/D2, in D3 at least an exception InvalidOp is raised.
  Same hold for Rows.Delete, Rows.Insert and Cols.Insert.
  Therefore all must be done by moving the Column/Row to be deleted or
  newly created from/to the place it should have }

(*@/// procedure TStringAlignGrid.RemoveCol(ACol:longint); *)
procedure TStringAlignGrid.RemoveCol(ACol:longint);
var
  v: TCellProperties;
  i:longint;
  reshow_edit: boolean;
begin
  if (ACol<FixedCols) or (ACol>=Colcount) or (ColCount=FixedCols+1) then EXIT;
     (* can't remove a fixed column *)
  (*@/// hide the inplace editor if necessary *)
  reshow_edit:=false;
  if (InplaceEditor <> nil) and InplaceEditor.visible then begin
    if (TNewInplaceEdit(InplaceEditor).col=ACol) then
      hideeditor
    else if (TNewInplaceEdit(InplaceEditor).col>ACol) then begin
      hideeditor;
      reshow_edit:=true;
      end;
    end;
  (*@\\\*)
  (*@/// PropertiesCol/Cell *)
  if FPropCol.Count>=ACol then begin
    v:=TCellProperties(SetItemCol(ACol,FPropCol,NIL));
    v.free;
    FPropCol.Delete(ACol);
    end;
  if FPropCell.Count>ACol then begin
    cleanlist_object(TList(FPropCell.Items[ACol]));
    TList(FPropCell.Items[ACol]).Free;
    FPropCell.Delete(ACol);
    end;
  (*@\\\0000000609*)
  (*@/// HintCell *)
  if FHintCell.Count>ACol then begin
    cleanlist_pstring(TList(FHintCell.Items[ACol]));
    TList(FHintCell.Items[ACol]).Free;
    FHintCell.Delete(ACol);
    end;
  (*@\\\0000000201*)
  (*@/// Cell *)
  for i:=ACol to ColCount-2 do
    inherited ColumnMoved(i,i+1);
  Cols[Colcount-1].clear;
  (*@\\\0000000201*)
  colcount:=colcount-1;
  if col>Acol then
    col:=col-1;
  if reshow_edit then
    ShowEditor;
  invalidate;
  end;
(*@\\\0000000105*)
(*@/// procedure TStringAlignGrid.RemoveRow(ARow:longint); *)
procedure TStringAlignGrid.RemoveRow(ARow:longint);
var
  v: TCellProperties;
  y:pstring;
  l: TList;
  i:longint;
  reshow_edit: boolean;
begin
  if (ARow<FixedRows) or (ARow>=Rowcount) or (RowCount=FixedRows+1) then EXIT;
     (* can't remove a fixed row *)
  reshow_edit:=false;
  (*@/// hide the inplace editor if necessary *)
  if (InplaceEditor <> nil) and InplaceEditor.visible then begin
    if (TNewInplaceEdit(InplaceEditor).row=ARow) then
      hideeditor
    else if (TNewInplaceEdit(InplaceEditor).row>ARow) then begin
      hideeditor;
      reshow_edit:=true;
      end;
    end;
  (*@\\\*)
  (*@/// PropertiesCol/Cell *)
  if FPropRow.Count>=ARow then begin
    v:=TCellProperties(SetItemCol(ARow,FPropRow,NIL));
    v.free;
    FPropRow.Delete(ARow);
    end;
  for i:=0 to FPropCell.Count-1 do begin
    l:=TList(FPropCell.Items[i]);
    if l<>NIL then begin
      if l.Count>=ARow then begin
        v:=TCellProperties(SetItemCol(ARow,l,NIL));
        v.free;
        l.Delete(ARow);
        end;
      end;
    end;
  (*@\\\0000000A01*)
  (*@/// HintCell *)
  for i:=0 to FHintCell.Count-1 do begin
    l:=TList(FHintCell.Items[i]);
    if l<>NIL then begin
      if l.Count>=ARow then begin
        y:=SetItemCol(ARow,l,NIL);
        if y<>NIL then
          DisposeStr(y);
        l.Delete(ARow);
        end;
      end;
    end;
  (*@\\\0000000701*)
  (*@/// Cell *)
  for i:=ARow to RowCount-2 do
    inherited RowMoved(i,i+1);
  Rows[Rowcount-1].clear;
  (*@\\\*)
  rowcount:=rowcount-1;
  if row>ARow then
    row:=row-1;
  if reshow_edit then
    ShowEditor;
  invalidate;
  end;
(*@\\\0000000501*)

(*@/// procedure TStringAlignGrid.InsertCol(ACol:longint); *)
procedure TStringAlignGrid.InsertCol(ACol:longint);
var
  i: longint;
  reshow_edit: boolean;
begin
  if (ACol<FixedCols) then ACol:=FixedCols;
  reshow_edit:=(InplaceEditor <> nil) and
               InplaceEditor.visible and
               (TNewInplaceEdit(InplaceEditor).col>=ACol);
  if reshow_edit then
    HideEditor;
  ColCount:=ColCount+1;
  (*@/// PropCol/Cell *)
  if FPropCol.Count>=ACol then
    FPropCol.Insert(ACol,NIL);
  if FPropCell.Count>=ACol then
    FPropCell.Insert(ACol,NIL);
  (*@\\\0000000401*)
  (*@/// HintCell *)
  if FHintCell.Count>=ACol then
    FHintCell.Insert(ACol,NIL);
  (*@\\\*)
  (*@/// Cell *)
  Cols[ColCount-1].clear;
  for i:=ColCount-1 downto ACol+1 do
    inherited ColumnMoved(i,i-1);      { maybe faster than doing it myself as
                                         this utilizes the internal sparselist }
  (*@\\\0000000201*)
  if col>=Acol then
    col:=col+1;
  if reshow_edit then
    ShowEditor;
  invalidate;
  end;
(*@\\\0000000701*)
(*@/// procedure TStringAlignGrid.InsertRow(ARow:longint); *)
procedure TStringAlignGrid.InsertRow(ARow:longint);
var
  i: longint;
  l: TList;
  reshow_edit: boolean;
begin
  if (ARow<FixedRows) then ARow:=FixedRows;
  reshow_edit:=(InplaceEditor <> nil) and
               InplaceEditor.visible and
               (TNewInplaceEdit(InplaceEditor).row>=ARow);
  if reshow_edit then
    HideEditor;
  rowcount:=rowcount+1;
  (*@/// FontRow/Cell *)
  if FPropRow.Count>=ARow then
    FPropRow.Insert(ARow,NIL);
  for i:=0 to FPropCell.Count-1 do begin
    l:=TList(FPropCell.Items[i]);
    if (l<>NIL) and (l.Count>=ARow) then
      l.Insert(ARow,NIL);
    end;
  (*@\\\*)
  (*@/// HintCell *)
  for i:=0 to FHintCell.Count-1 do begin
    l:=TList(FHintCell.Items[i]);
    if (l<>NIL) and (l.Count>=ARow) then begin
      l.Insert(ARow,NIL);
      end;
    end;
  (*@\\\*)
  (*@/// Cell *)
  Rows[RowCount-1].clear;
  for i:=RowCount-1 downto ARow+1 do
    inherited RowMoved(i,i-1);
  (*@\\\0000000315*)
  if row>=ARow then
    row:=row+1;
  if reshow_edit then
    ShowEditor;
  invalidate;
  end;
(*@\\\*)

(*@/// procedure TStringAlignGrid.RowMoved(FromIndex, ToIndex: Longint); *)
procedure TStringAlignGrid.RowMoved(FromIndex, ToIndex: Longint);
begin
  if FromIndex=ToIndex then EXIT;
  (*@/// adjust inplace edit *)
  if (InplaceEditor <> nil) then begin
    if false then
    else if TNewInplaceEdit(InplaceEditor).row=FromIndex then
      TNewInplaceEdit(InplaceEditor).row:=ToIndex
    else if TNewInplaceEdit(InplaceEditor).row=ToIndex then
      TNewInplaceEdit(InplaceEditor).row:=ToIndex+1;
    end;
  (*@\\\*)
  (*@/// PropRow/Cell *)
  MoveItemCol(FromIndex,ToIndex,FPropRow);
  MoveItemColRow(FromIndex,ToIndex,FPropCell);
  (*@\\\*)
  (*@/// HintCell *)
  MoveItemColRow(FromIndex,ToIndex,FHintCell);
  (*@\\\*)
  (*@/// Cells *)
  inherited RowMoved(FromIndex, ToIndex);
  (*@\\\*)
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.ColumnMoved(FromIndex, ToIndex: Longint); *)
procedure TStringAlignGrid.ColumnMoved(FromIndex, ToIndex: Longint);
begin
  if FromIndex=ToIndex then EXIT;
  (*@/// adjust inplace edit *)
  if (InplaceEditor <> nil) then begin
    if false then
    else if TNewInplaceEdit(InplaceEditor).col=FromIndex then
      TNewInplaceEdit(InplaceEditor).col:=ToIndex
    else if TNewInplaceEdit(InplaceEditor).col=ToIndex then
      TNewInplaceEdit(InplaceEditor).col:=ToIndex+1;
    end;
  (*@\\\0000000301*)
  (*@/// PropCol/Cell *)
  MoveItemCol(FromIndex,ToIndex,FPropCol);
  MoveItemCol(FromIndex,ToIndex,FPropCell);
  (*@\\\0000000201*)
  (*@/// HintCell *)
  MoveItemCol(FromIndex,ToIndex,FHintCell);
  (*@\\\*)
  (*@/// Cells *)
  inherited ColumnMoved(FromIndex, ToIndex);
  (*@\\\*)
  end;
(*@\\\0000000507*)

(*@/// procedure TStringAlignGrid.ExchangeRow(FromIndex, ToIndex: Longint); *)
procedure TStringAlignGrid.ExchangeRow(FromIndex, ToIndex: Longint);
var
  i: longint;
  s: string;
  o: TObject;
  reshow_edit: boolean;
begin
  if FromIndex=ToIndex then EXIT;
  reshow_edit:=(InplaceEditor <> nil) and
               InplaceEditor.visible and
               ((TNewInplaceEdit(InplaceEditor).row=FromIndex) or
                (TNewInplaceEdit(InplaceEditor).row=ToIndex));
  if reshow_edit then
    HideEditor;
  (*@/// PropRow/Cell *)
  ExchangeItemCol(FromIndex,ToIndex,FPropRow);
  ExchangeItemColRow(FromIndex,ToIndex,FPropCell);
  (*@\\\0000000201*)
  (*@/// HintCell *)
  ExchangeItemColRow(FromIndex,ToIndex,FHintCell);
  (*@\\\*)
  (*@/// Cells and Objects *)
  for i:=0 to ColCount-1 do begin
    s:=Cells[i,FromIndex];
    o:=Objects[i,FromIndex];
    Cells[i,FromIndex]:=Cells[i,ToIndex];
    Objects[i,FromIndex]:=Objects[i,ToIndex];
    Cells[i,ToIndex]:=s;
    Objects[i,ToIndex]:=o;
    end;
  (*@\\\*)
  if false then
  else if row=FromIndex then row:=toIndex
  else if row=toindex   then row:=fromindex;
  if reshow_edit then
    showeditor;
  end;
(*@\\\0000000F07*)
(*@/// procedure TStringAlignGrid.ExchangeCol(FromIndex, ToIndex: Longint); *)
procedure TStringAlignGrid.ExchangeCol(FromIndex, ToIndex: Longint);
var
  i: longint;
  s: string;
  o: TObject;
  reshow_edit: boolean;
begin
  if FromIndex=ToIndex then EXIT;
  reshow_edit:=(InplaceEditor <> nil) and
               InplaceEditor.visible and
               ((TNewInplaceEdit(InplaceEditor).col=FromIndex) or
                (TNewInplaceEdit(InplaceEditor).col=ToIndex));
  if reshow_edit then
    HideEditor;
  (*@/// PropCol/Cell *)
  ExchangeItemCol(FromIndex,ToIndex,FPropCol);
  ExchangeItemCol(FromIndex,ToIndex,FPropCell);
  (*@\\\0000000201*)
  (*@/// HintCell *)
  ExchangeItemCol(FromIndex,ToIndex,FHintCell);
  (*@\\\*)
  (*@/// Cells and Objects *)
  for i:=0 to RowCount-1 do begin
    s:=Cells[FromIndex,i];
    o:=Objects[FromIndex,i];
    Cells[FromIndex,i]:=Cells[ToIndex,i];
    Objects[FromIndex,i]:=Objects[ToIndex,i];
    Cells[ToIndex,i]:=s;
    Objects[ToIndex,i]:=o;
    end;
  (*@\\\*)
  if false then
  else if col=FromIndex then col:=toIndex
  else if col=toindex   then col:=fromindex;
  if reshow_edit then
    showeditor;
  end;
(*@\\\*)
(*@\\\0000000701*)
(*@/// Additional access methods for the cells property *)
(*@/// function TStringAlignGrid.GetCellAsDate(ACol,ARow:longint):TDateTime; *)
function TStringAlignGrid.GetCellAsDate(ACol,ARow:longint):TDateTime;
begin
  result:=StrToDateTime(Cells[Acol,ARow]);
  end;
(*@\\\000000030B*)
(*@/// procedure TStringAlignGrid.SetCellAsDate(ACol,ARow:longint; value:TDateTime); *)
procedure TStringAlignGrid.SetCellAsDate(ACol,ARow:longint; value:TDateTime);
begin
  Cells[Acol,ARow]:=DateTimeToStr(value);
  end;
(*@\\\000000032A*)
(*@/// function TStringAlignGrid.GetCellAsInt(ACol,ARow:longint):longint; *)
function TStringAlignGrid.GetCellAsInt(ACol,ARow:longint):longint;
var
  s: string;
begin
  s:=Cells[ACol,ARow];
  if s='' then
    result:=0
  else
    result:=strtoint(s);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.SetCellAsInt(ACol,ARow:longint; value:longint); *)
procedure TStringAlignGrid.SetCellAsInt(ACol,ARow:longint; value:longint);
begin
  Cells[ACol,ARow]:=inttostr(value);
  end;
(*@\\\*)
(*@\\\0000000428*)

(*@/// Utility methods for the fonts/brushs *)
(*@/// function TStringAlignGrid.GetFontColRowInternal(AColRow: longint; create:boolean; List:TList):TFont; *)
function TStringAlignGrid.GetFontColRowInternal(AColRow: longint; create:boolean; List:TList):TFont;
var
  v: TCellProperties;
begin
  v:=GetItemCol(AColRow,List);
  if create then begin
    if v=NIL then begin
      v:=CellPropertiesClass.Create(self);
      setitemcol(AColRow,list,v);
      end;
    if v.font=NIL then begin
      v.f_font:=TMyFont.Create;
      v.font.OnChange:=fontchanged;
      v.font.assign(self.font);
      TMyFont(v.font).haschanged:=false;
      end;
    end;
  if (v=NIL) or (v.font=NIL) then
    result:=self.Font
  else
    result:=v.font;
  end;
(*@\\\0000000F15*)
(*@/// function TStringAlignGrid.GetFontCellInternal(ACol,ARow: longint; create:boolean):TFont; *)
function TStringAlignGrid.GetFontCellInternal(ACol,ARow: longint; create:boolean):TFont;
var
  v: TCellProperties;
begin
  v:=GetItemCell(ACol,ARow,FPropCell);
  if create then begin
    if v=NIL then begin
      v:=CellPropertiesClass.Create(self);
      setitemcell(ACol,ARow,FPropCell,v);
      end;
    if v.font=NIL then begin
      v.f_font:=TMyFont.Create;
      v.font.OnChange:=fontchanged;
      v.font.assign(self.font);
      TMyFont(v.font).haschanged:=false;
      end;
    end;
  if (v=NIL) or (v.font=NIL) then begin
    if is_fixed(ACol,ARow) then
      result:=self.FFixedFont
    else
      result:=self.Font
    end
  else
    result:=v.font;
  end;
(*@\\\0000000F15*)
(*@/// function TStringAlignGrid.GetBrushColRowInternal(AColRow: longint; create:boolean; List:TList):TBrush; *)
function TStringAlignGrid.GetBrushColRowInternal(AColRow: longint; create:boolean; List:TList):TBrush;
var
  v: TCellProperties;
begin
  v:=GetItemCol(AColRow,List);
  if create then begin
    if v=NIL then begin
      v:=CellPropertiesClass.Create(self);
      setitemcol(AColRow,list,v);
      end;
    if v.brush=NIL then begin
      v.f_brush:=TMybrush.Create;
      v.brush.OnChange:=brushchanged;
      v.brush.assign(self.brush);
      TMyBrush(v.brush).haschanged:=false;
      end;
    end;
  if (v=NIL) or (v.Brush=NIL) then
    result:=self.Brush
  else
    result:=v.Brush;
  end;
(*@\\\0000000F17*)
(*@/// function TStringAlignGrid.GetBrushCellInternal(ACol,ARow: longint; create:boolean):TBrush; *)
function TStringAlignGrid.GetBrushCellInternal(ACol,ARow: longint; create:boolean):TBrush;
var
  v: TCellProperties;
begin
  v:=GetItemCell(ACol,ARow,FPropCell);
  if create then begin
    if v=NIL then begin
      v:=CellPropertiesClass.Create(self);
      setitemcell(ACol,ARow,FPropCell,v);
      end;
    if v.brush=NIL then begin
      v.f_brush:=TMybrush.Create;
      v.brush.OnChange:=brushchanged;
      v.brush.assign(self.brush);
      TMyBrush(v.brush).haschanged:=false;
      end;
    end;
  if (v=NIL) or (v.Brush=NIL) then begin
    if is_fixed(ACol,ARow) then
      result:=self.FFixedBrush
    else
      result:=self.Brush
    end
  else
    result:=v.Brush;
  end;
(*@\\\0000000F17*)

{ The Font/Brush for the Cell through all levels (Cell, Col, Row, Grid) }
(*@/// function TStringAlignGrid.GetFontCellComplete(ACol,ARow: longint):TFont; *)
function TStringAlignGrid.GetFontCellComplete(ACol,ARow: longint):TFont;
var
  v: TCellProperties;
  fixed: boolean;
begin
  v:=GetItemCell(ACol,ARow,FPropCell);
  fixed:=is_fixed(ACol,ARow);
  if (v=NIL) or (v.font=NIL) then begin
    if fixed then begin
      if Col_before_Row then
        v:=GetItemCol(ACol,FFPropCol)
      else
        v:=GetItemCol(ACol,FFPropRow)
      end
    else begin
      if Col_before_Row then
        v:=GetItemCol(ACol,FPropCol)
      else
        v:=GetItemCol(ACol,FPropRow)
      end;
    if (v=NIL) or (v.font=NIL) then begin
      if fixed then begin
        if Col_before_Row then
          v:=GetItemCol(ARow,FFPropRow)
        else
          v:=GetItemCol(ARow,FFPropCol)
        end
      else begin
        if Col_before_Row then
          v:=GetItemCol(ARow,FPropRow)
        else
          v:=GetItemCol(ARow,FPropCol)
        end;
      if (v=NIL) or (v.font=NIL) then begin
        if fixed then
          result:=self.FFixedFont
        else
          result:=self.Font
        end
      else
        result:=v.font
      end
    else
      result:=v.font
    end
  else
    result:=v.font;
  end;
(*@\\\0000003001*)
(*@/// function TStringAlignGrid.GetBrushCellComplete(ACol,ARow: longint):TBrush; *)
function TStringAlignGrid.GetBrushCellComplete(ACol,ARow: longint):TBrush;
var
  v: TCellProperties;
  fixed: boolean;
begin
  v:=GetItemCell(ACol,ARow,FPropCell);
  fixed:=is_fixed(ACol,ARow);
  if (v=NIL) or (v.Brush=NIL) then begin
    if fixed then begin
      if Col_before_Row then
        v:=GetItemCol(ACol,FFPropCol)
      else
        v:=GetItemCol(ACol,FFPropRow)
      end
    else begin
      if Col_before_Row then
        v:=GetItemCol(ACol,FPropCol)
      else
        v:=GetItemCol(ACol,FPropRow)
      end;
    if (v=NIL) or (v.Brush=NIL) then begin
      if fixed then begin
        if Col_before_Row then
          v:=GetItemCol(ARow,FFPropRow)
        else
          v:=GetItemCol(ARow,FFPropCol)
        end
      else begin
        if Col_before_Row then
          v:=GetItemCol(ARow,FPropRow)
        else
          v:=GetItemCol(ARow,FPropCol)
        end;
      if (v=NIL) or (v.Brush=NIL) then begin
        if fixed then
          result:=self.FFixedBrush
        else
          result:=self.Brush
        end
      else
        result:=v.Brush
      end
    else
      result:=v.Brush
    end
  else
    result:=v.Brush;
  end;
(*@\\\0000001A01*)

{ A callback to be sure the displayed font/brush is the same as the internal }
(*@/// procedure TStringAlignGrid.FontChanged(AFont: TObject); *)
procedure TStringAlignGrid.FontChanged(AFont: TObject);
begin
  invalidate;
  end;
(*@\\\0000000401*)
(*@/// procedure TStringAlignGrid.BrushChanged(ABrush: TObject); *)
procedure TStringAlignGrid.BrushChanged(ABrush: TObject);
begin
  invalidate;
  end;
(*@\\\*)

(*@/// function TStringAlignGrid.FixedFontChanged:boolean; *)
function TStringAlignGrid.FixedFontChanged:boolean;
begin
  result:=TMyFont(FFixedFont).HasChanged;
  end;
(*@\\\0000000301*)
(*@\\\*)
(*@/// Utility methods for the cell-specific hints *)
(*@/// procedure TStringAlignGrid.ShowHintCell(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo); *)
procedure TStringAlignGrid.ShowHintCell(var HintStr: (*$ifdef shortstring*)string;(*$else*)ansistring;(*$endif*)
  var CanShow: Boolean; var HintInfo: THintInfo);
var
  col,row:longint;
  HintPos:TRect;
begin
  if (hintinfo.hintcontrol=self) and FShowCellHints then begin
    self.mousetocell(hintinfo.cursorpos.x,hintinfo.cursorpos.y,col,row);
    FHintCellLast:=Point(col,row);
    hintpos:=self.Cellrect(col,row);
    hintinfo.hintpos.x:=hintpos.left;
    hintinfo.hintpos.y:=hintpos.bottom+6;
    hintinfo.hintpos:=self.clienttoscreen(hintinfo.hintpos);
    hintstr:=HintCell[col,row];
    if assigned(FOnShowHintCell) then
      FOnShowHintCell(self,col,row,HintStr,CanShow,HintInfo);
    end;
  end;
(*@\\\000000101C*)
(*@/// procedure TStringAlignGrid.MouseMove(Shift: TShiftState; X, Y: Integer); *)
procedure TStringAlignGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  col,row: longint;
begin
  if (FHintCellLast.x>=0) and (FHintCellLast.y>=0) then begin
    self.mousetocell(x,y,col,row);
    if (col<>FHintCellLast.x) or (row<>FHintCellLast.y) then begin
      Application.CancelHint;
      FHintCellLast:=Point(-1,-1);
      end;
    end;
  inherited MouseMove(Shift, X, Y);
  end;
(*@\\\*)
(*$ifdef delphi_ge_3 *)
(*@/// procedure TStringAlignGrid.CMHintShow(var Message: THintMessage); *)
procedure TStringAlignGrid.CMHintShow(var Message: THintMessage);
var
  canshow: boolean;
begin
  ShowHintCell(message.HintInfo^.HintStr, canshow, message.HintInfo^);
  if canshow then
    message.result:=0
  else
    message.result:=1;
  end;
(*@\\\0000000901*)
(*$endif *)
(*@\\\*)
(*@/// The Inplace-Editor which also gets the alignment, font and color *)
{ The Inplace-Editor which also gets the alignment, font and color -
  got the idea from James Sager's (jsager@ao.net) TIEAlignStringGrid -
  see UNDU #19 (http://www.informant.com/undu) }


(*@/// function TStringAlignGrid.CreateEditor: TInplaceEdit; *)
function TStringAlignGrid.CreateEditor: TInplaceEdit;
begin
  Result := TNewInplaceEdit.Create(Self);
  TNewInplaceEdit(Result).Col:=-1;
  TNewInplaceEdit(Result).Row:=-1;
  end;
(*@\\\0000000401*)
(*@/// function TStringAlignGrid.CanEditShow: Boolean; *)
function TStringAlignGrid.CanEditShow: Boolean;
var
 edit: TNewInplaceEdit;
begin
  if (goAlwaysShowEditor in Options) and not Editormode then
    Editormode:=true;
  Result := inherited CanEditShow;
  if (InplaceEditor<>nil) and (InplaceEditor is TNewInplaceEdit) then
    edit:=TNewInplaceEdit(InplaceEditor)
  else
    edit:=NIL;

  { Cell has changed -> send OnAfterEdit for last cell }
  if (edit<>NIL) and ((edit.Col<>Col) or (edit.Row<>Row)) then begin
    if (edit.Col>=0) and (edit.Row>=0) then
      postmessage(self.handle,cn_edit_exit,edit.Col,edit.Row);
    edit.event:=false;
    end;

  if not (csDesigning in ComponentState) then
    result:=result and (EditCell[Col,Row] or FAlwaysEdit);

  if Result then begin

(*$ifdef delphi_1 *)
    { Set the color, font, alignment to the edit - since D2 done by inherited }
    TNewInplaceEditor(InplaceEditor).UpdateContents;
(*$endif *)

    { If new edit is touched first time: save old text (for cancel)
      and send the OnBeforeEdit event }
    if (edit<>NIL) and (not edit.event) then begin
      edit.event:=true;
      self.perform(cn_edit_show,self.col,self.row);
      edit.oldtext:=cells[col,row];
      end;
    if (not f_selectall) and (edit<>NIL) then
      edit.Deselect;
    (* Hack: I may need to modify the position of inplaceedit,
       but within grids.pas the move comes as the last command and like
       always there's no virtual procedure to override to come after this
       move - only a message comes after it. Not needed for combobox. *)
    postmessage(self.handle,cn_edit_update,0,0);
    end
  else begin
    { No edit allowed }
    if edit<>NIL then begin
      edit.Col:=-1;
      edit.Row:=-1;
      end;
    EditorMode:=false; (* otherwise the grid thinks the editor is visible *)
    end;
  end;
(*@\\\0030001B01001C01*)

(*@/// procedure TStringAlignGrid.ShowEdit; *)
procedure TStringAlignGrid.ShowEdit;
begin
{   if CellHasCombobox(Col,Row) then }
{     ShowCombobox }
{   else }
    ShowEditor;
  edit_visible:=true;
  end;
(*@\\\0000000601*)
(*@/// procedure TStringAlignGrid.HideEdit(cancel:boolean); *)
procedure TStringAlignGrid.HideEdit(cancel:boolean);
var
  msg: TMessage;
begin
  edit_visible:=false;
  if (InplaceEditor<>NIL) and InplaceEditor.visible then begin
    if cancel then
      SendMessage(InplaceEditor.handle,wm_char,vk_escape,0)
    else begin
      self.HideEditor;
      msg.wparam:=col;
      msg.lparam:=row;
      self.mcn_edit_exit(msg);
      end;
    end;
  end;
(*@\\\0000000607*)
(*@/// procedure TStringAlignGrid.KeyPress(var Key: Char); *)
procedure TStringAlignGrid.KeyPress(var Key: Char);
begin
  if (key=#13) and f_edit_multi then
    {}
  else
    inherited KeyPress(Key);
  end;
(*@\\\0000000320*)

{ Stuff needed to reimplement because of private or static stuff }

(*@/// procedure TStringAlignGrid.WMLButtonDown(var Message: TMessage); *)
procedure TStringAlignGrid.WMLButtonDown(var Message: TMessage);
begin
  inherited;
  if InplaceEditor<>NIL then
    TNewInplaceEdit(InplaceEditor).ClickTime := GetMessageTime;
  end;
(*@\\\0000000505*)
(*@/// procedure TStringAlignGrid.CMFontChanged(var Message: TMessage); *)
procedure TStringAlignGrid.CMFontChanged(var Message: TMessage);
begin
  inherited;  (* will not honor the cellfont property *)
  if InplaceEditor<>NIL then begin
    TNewInplaceEdit(InplaceEditor).Font := GetFontCellComplete(Col,Row);
    TNewInplaceEdit(InplaceEditor).BoundsChanged;
    end;
  end;
(*@\\\0000000624*)
(*@/// procedure TStringAlignGrid.WMCommand(var Message: TWMCommand); *)
procedure TStringAlignGrid.WMCommand(var Message: TWMCommand);
begin
  with Message do begin
    if (InplaceEditor <> nil) and (Ctl = InplaceEditor.Handle) then
      case NotifyCode of
        EN_CHANGE: UpdateText_;
        end;
    end;
  end;
(*@\\\0000000614*)
(*@/// procedure TStringAlignGrid.UpdateText_; *)
procedure TStringAlignGrid.UpdateText_;
var
  edit: TNewInplaceEdit;
begin
  if (InplaceEditor<>NIL) and
     (InplaceEditor is TNewInplaceEdit) then begin
    edit:=TNewInplaceEdit(InplaceEditor);
    if (edit.Col<>-1) and (edit.Row<>-1) then
      edit.oldText:=Cells[edit.Col,edit.row]
    end;
  end;
(*@\\\0000000A09*)

(*@/// procedure TStringAlignGrid.Update_Edit; *)
procedure TStringAlignGrid.Update_Edit;
begin
  if InplaceEditor<>NIL then
    TNewInplaceEdit(InplaceEditor).UpdateContents;
  end;
(*@\\\0000000401*)


{ The stuff to get the editor's events right }

(*@/// procedure TStringAlignGrid.doExit; *)
procedure TStringAlignGrid.doExit;
begin
{   if (InplaceEditor<>NIL) and (InplaceEditor.visible) then begin }
  if (InplaceEditor<>NIL) and EditorMode then begin
    f_reshow_edit:=true;
    f_last_sel_pos:=InplaceEditor.SelStart;
    f_last_sel_len:=InplaceEditor.SelLength;
    hideedit(false);
    end;
(*   if the edit is still visible the contents of the cell   *)
(*   seems to be invalid, so just take back the focus        *)
  if self.edit_visible then
    self.setfocus
  else begin
    inherited doexit;
    EditorMode:=false; (* otherwise the grid thinks the editor is visible *)
    end;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.DoEnter; *)
procedure TStringAlignGrid.DoEnter;
begin
  inherited doenter;
  if f_reshow_edit and (goAlwaysShowEditor in options) then begin

    { Showing the editor here directly comes too early, there are
      other windows messages needed to be processed before, so I put
      this at the end of the message queue. Ugly, but the only way I
      could get this running. }

    postmessage(self.handle,cn_edit_toshow,0,0);
    end;
  end;
(*@\\\0000000B01*)
(*@/// procedure TStringAlignGrid.mcn_edit_return(var msg:TMessage); *)
procedure TStringAlignGrid.mcn_edit_return(var msg:TMessage);
var
  ACol,ARow: longint;
  ok: boolean;
begin
  edit_visible:=false;
  TNewInplaceEdit(InplaceEditor).event:=false;
  if (msg.wparam>=0) and (msg.lparam>=0) then begin
    ok:=true;
    if assigned(f_on_validate) then
      f_on_validate(self,msg.wparam,msg.lparam,ok);
    if ok then begin
      if assigned(f_on_after_edit) then
        f_on_after_edit(self,msg.wparam,msg.lparam);
      end
    else begin
      Col:=msg.wparam;
      Row:=msg.lparam;
      ShowEdit;
      end;
    end;
  if f_nextcell and not edit_visible and
    (msg.wparam>=0) and (msg.lparam>=0) then begin
    ACol:=self.col;
    ARow:=self.row;
    self.NextEditableCell(ACol,ARow);
    if (ACol>=0) and (ARow>=0) then begin
      if InplaceEditor<>NIL then begin
        TNewInplaceEdit(InplaceEditor).Col:=-1;
        TNewInplaceEdit(InplaceEditor).Row:=-1;
        end;
      self.col:=ACol;
      self.row:=ARow;
      ShowEdit;
      end;
    end;
  end;
(*@\\\0000000C01*)
(*@/// procedure TStringAlignGrid.mcn_edit_cancel(var msg:TMessage); *)
procedure TStringAlignGrid.mcn_edit_cancel(var msg:TMessage);
begin
  edit_visible:=false;
  TNewInplaceEdit(InplaceEditor).event:=false;
  if assigned(f_on_cancel_edit) and
    (msg.wparam>=0) and (msg.lparam>=0) then
    f_on_cancel_edit(self,msg.wparam,msg.lparam);
  end;
(*@\\\0000000401*)
(*@/// procedure TStringAlignGrid.mcn_edit_exit(var msg:TMessage); *)
procedure TStringAlignGrid.mcn_edit_exit(var msg:TMessage);
var
  ok: boolean;
begin
  edit_visible:=false;
  TNewInplaceEdit(InplaceEditor).event:=false;
  if (msg.wparam>=0) and (msg.lparam>=0) then begin
    ok:=true;
    if assigned(f_on_validate) then
      f_on_validate(self,msg.wparam,msg.lparam,ok);
    if ok then begin
      if assigned(f_on_after_edit) then
        f_on_after_edit(self,msg.wparam,msg.lparam);
      end
    else begin
      Col:=msg.wparam;
      Row:=msg.lparam;
      ShowEdit;
      end;
    end;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.mcn_edit_show(var msg:TMessage); *)
procedure TStringAlignGrid.mcn_edit_show(var msg:TMessage);
begin
  if assigned(f_on_before_edit) and
    (msg.wparam>=0) and (msg.lparam>=0) then
    f_on_before_edit(self,msg.wparam,msg.lparam);
  edit_visible:=true;
  end;
(*@\\\0000000601*)
(*@/// procedure TStringAlignGrid.mcn_edit_show_it(var msg:TMessage); *)
procedure TStringAlignGrid.mcn_edit_show_it(var msg:TMessage);
{ It's a hack, see DoEnter for more }
begin
  showeditor;
  if InplaceEditor<>NIL then begin
    InplaceEditor.SelStart:=f_last_sel_pos;
    InplaceEditor.SelLength:=f_last_sel_len;
    end;
  end;
(*@\\\0000000801*)
(*@/// procedure TStringAlignGrid.mcn_edit_update(var msg:TMessage); *)
procedure TStringAlignGrid.mcn_edit_update(var msg:TMessage);
begin
  end;
(*@\\\0000000301*)
(*@\\\0000000701*)
(*@/// The stuff for reading and writing the data from/to the DFM file *)
(*@/// procedure TStringAlignGrid.DefineProperties(Filer: TFiler); *)
procedure TStringAlignGrid.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('HintCell', ReadHint, WriteHint, FSaveHint);
  Filer.DefineProperty('Cells', ReadCells, WriteCells, FSaveCells);

  (* Always write these, only those non-empty entries will be written *)
  Filer.DefineProperty('PropCell', ReadPropCell, WritePropCell, true);
  Filer.DefineProperty('PropCol', ReadPropCol, WritePropCol, true);
  Filer.DefineProperty('PropRow', ReadPropRow, WritePropRow, true);
  Filer.DefineProperty('PropFixedCol', ReadPropFixedCol, WritePropFixedCol, true);
  Filer.DefineProperty('PropFixedRow', ReadPropFixedRow, WritePropFixedRow, true);

  (* the following are only for compatibility, therefore only read *)
  Filer.DefineBinaryProperty('AlignCell', ReadAlignCell, NIL, false);
  Filer.DefineBinaryProperty('AlignCol', ReadAlignCol, NIL, false);
  Filer.DefineBinaryProperty('FixedAlignCol', ReadFixedAlignCol, NIL, false);
  Filer.DefineBinaryProperty('AlignRow', ReadAlignRow, NIL, false);
  Filer.DefineBinaryProperty('FixedAlignRow', ReadFixedAlignRow, NIL, false);
  Filer.DefineBinaryProperty('EditCell', ReadEditCell, NIL, false);
  Filer.DefineBinaryProperty('EditCol', ReadEditCol, NIL, false);
  Filer.DefineBinaryProperty('EditRow', ReadEditRow, NIL, false);
  Filer.DefineProperty('FontCell', ReadFontCell, NIL, false);
  Filer.DefineProperty('FontCol', ReadFontCol, NIL, false);
  Filer.DefineProperty('FontFixedCol', ReadFixedFontCol, NIL, false);
  Filer.DefineProperty('FontRow', ReadFontRow, NIL, false);
  Filer.DefineProperty('FontFixedRow', ReadFixedFontRow, NIL, false);
  Filer.DefineProperty('BrushCell', ReadBrushCell, NIL, false);
  Filer.DefineProperty('BrushCol', ReadBrushCol, NIL, false);
  Filer.DefineProperty('BrushFixedCol', ReadFixedBrushCol, NIL, false);
  Filer.DefineProperty('BrushRow', ReadBrushRow, NIL, false);
  Filer.DefineProperty('BrushFixedRow', ReadFixedBrushRow, NIL, false);
  Filer.DefineProperty('ColorCell', ReadColorCell, NIL, false);
  Filer.DefineProperty('ColorCol', ReadColorCol, NIL, false);
  Filer.DefineProperty('ColorFixedCol', ReadFixedColorCol, NIL, false);
  Filer.DefineProperty('ColorRow', ReadColorRow, NIL, false);
  Filer.DefineProperty('ColorFixedRow', ReadFixedColorRow, NIL, false);
  Filer.DefineProperty('SelectedColorCell', ReadSelColorCell, NIL, false);
  Filer.DefineProperty('SelectedColorCol', ReadSelColorCol, NIL, false);
  Filer.DefineProperty('SelectedColorRow', ReadSelColorRow, NIL, false);
  end;
(*@\\\0000001601*)
(*@/// procedure TStringAlignGrid.Loaded; *)
procedure TStringAlignGrid.Loaded;
{ Fill the cell list into the original cells property after loading;
  if in designing mode hold the internal list for the later writing }
var
  i: longint;
begin
  inherited Loaded;
  if FCell<>NIL then begin
    ListToCells(FCell);
    if not (csDesigning in ComponentState) then begin
      (*@/// FCell.Free; *)
      for i:=FCell.Count-1 downto 0 do begin
        cleanlist_pstring(TList(FCell.Items[i]));
        TList(FCell.Items[i]).Free;
        end;
      FCell.Free;
      FCell:=NIL;
      (*@\\\0000000301*)
      end;
    end;
  f_reshow_edit:=(goAlwaysShowEditor in options);
  if f_reshow_edit and SelectEditText then
    f_last_sel_len:=-1;
  self.hideeditor;
  end;
(*@\\\0000000B22*)

(*@/// Read and write of the properties lists to the DFM *)
{ All the routines for the different property lists }
(*@/// procedure TStringAlignGrid.ReadpropCell(Reader: TReader); *)
procedure TStringAlignGrid.ReadpropCell(Reader: TReader);
begin
  ReadpropCellInt(Reader,FpropCell);
  end;
(*@\\\0000000303*)
(*@/// procedure TStringAlignGrid.ReadpropCol(Reader: TReader); *)
procedure TStringAlignGrid.ReadpropCol(Reader: TReader);
begin
  ReadpropColRow(Reader,FpropCol);
  end;
(*@\\\0000000303*)
(*@/// procedure TStringAlignGrid.ReadpropRow(Reader: TReader); *)
procedure TStringAlignGrid.ReadpropRow(Reader: TReader);
begin
  ReadpropColRow(Reader,FpropRow);
  end;
(*@\\\0000000303*)
(*@/// procedure TStringAlignGrid.ReadpropFixedCol(Reader: TReader); *)
procedure TStringAlignGrid.ReadpropFixedCol(Reader: TReader);
begin
  ReadpropColRow(Reader,FFpropCol);
  end;
(*@\\\0000000303*)
(*@/// procedure TStringAlignGrid.ReadpropFixedRow(Reader: TReader); *)
procedure TStringAlignGrid.ReadpropFixedRow(Reader: TReader);
begin
  ReadpropColRow(Reader,FFpropRow);
  end;
(*@\\\0000000303*)
(*@/// procedure TStringAlignGrid.WritepropCell(Writer: TWriter); *)
procedure TStringAlignGrid.WritepropCell(Writer: TWriter);
begin
  WritepropCellInt(Writer,ColCount-1,RowCount-1,FpropCell);
  end;
(*@\\\000000020A*)
(*@/// procedure TStringAlignGrid.WritepropCol(Writer: TWriter); *)
procedure TStringAlignGrid.WritepropCol(Writer: TWriter);
begin
  WritepropColRow(Writer, ColCount-1, FpropCol);
  end;
(*@\\\000000032F*)
(*@/// procedure TStringAlignGrid.WritepropRow(Writer: TWriter); *)
procedure TStringAlignGrid.WritepropRow(Writer: TWriter);
begin
  WritepropColRow(Writer, RowCount-1, FpropRow);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.WritepropFixedCol(Writer: TWriter); *)
procedure TStringAlignGrid.WritepropFixedCol(Writer: TWriter);
begin
  WritepropColRow(Writer, ColCount-1, FFpropCol);
  end;
(*@\\\0000000301*)
(*@/// procedure TStringAlignGrid.WritepropFixedRow(Writer: TWriter); *)
procedure TStringAlignGrid.WritepropFixedRow(Writer: TWriter);
begin
  WritepropColRow(Writer, RowCount-1, FFpropRow);
  end;
(*@\\\0000000301*)

{ All the ReadCol, ReadRow are so similar, so these to routines are there
  to avoid code-copy }
(*@/// function TStringAlignGrid.ReadpropCellInt(Reader: TReader; list:TList):boolean; *)
function TStringAlignGrid.ReadpropCellInt(Reader: TReader; list:TList):boolean;
var
  ACol,ARow: word;
  v:TCellProperties;
begin
  result:=false;
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    ACol:=Reader.ReadInteger;
    ARow:=Reader.ReadInteger;
    v:=CellPropertiesClass.Create(self);
    v.ReadFromReader(Reader,self);
    v:=TCellProperties(SetItemCell(ACol,ARow,list,v));
    result:=true;
    v.free;
    end;
  Reader.ReadListEnd;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.WritepropCellInt(Writer: TWriter; x,y:longint; list:TList); *)
procedure TStringAlignGrid.WritepropCellInt(Writer: TWriter; x,y:longint; list:TList);
var
  v:pointer;
  ACol,ARow: longint;
begin
  Writer.WriteListBegin;
  for ACol:=0 to x do begin
    for ARow:=0 to y do begin
      v:=GetItemCell(ACol,ARow,list);
      if (v<>NIL) and not TCellProperties(v).isempty then begin
        Writer.WriteInteger(ACol);
        Writer.WriteInteger(ARow);
        TCellProperties(v).WriteToWriter(Writer);
        end;
      end;
    end;
  Writer.WriteListEnd;
  end;
(*@\\\*)
(*@/// function TStringAlignGrid.ReadpropColRow(Reader:TReader; list:TList):boolean; *)
function TStringAlignGrid.ReadpropColRow(Reader:TReader; list:TList):boolean;
var
  AColRow: word;
  v: TCellProperties;
begin
  result:=false;
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    AColRow:=Reader.ReadInteger;
    v:=CellPropertiesClass.Create(self);
    v.ReadFromReader(Reader,self);
    v:=TCellProperties(SetItemCol(AColRow, list, v));
    result:=true;
    v.free;
    end;
  Reader.ReadListEnd;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.WritepropColRow(Writer:TWriter; count:longint; list:TList); *)
procedure TStringAlignGrid.WritepropColRow(Writer:TWriter; count:longint; list:TList);
var
  AColRow: word;
  v: pointer;
begin
  Writer.WriteListBegin;
  for AColRow:=0 to Count do begin
    v:=GetItemCol(AColRow,List);
    if (v<>NIL) and not TCellProperties(v).isempty then begin
      Writer.WriteInteger(AColRow);
      TCellProperties(v).WriteToWriter(Writer);
      end;
    end;
  Writer.WriteListEnd;
  end;
(*@\\\0000000933*)
(*@\\\*)

(*@/// Read and write the hint strings to the DFM *)
{ The hint and the cell strings }
(*@/// procedure TStringAlignGrid.ReadHint(Reader: TReader); *)
procedure TStringAlignGrid.ReadHint(Reader: TReader);
var
  ACol,ARow: longint;
  v:pstring;
begin
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    ACol:=Reader.ReadInteger;
    ARow:=Reader.ReadInteger;
    v:=NewStr(Reader.ReadString);
    v:=SetItemCell(ACol,ARow, FHintCell, v);
    FSaveHint:=true;
    if v<>NIL then
      DisposeStr(v);
    end;
  Reader.ReadListEnd;
  end;
(*@\\\0000000315*)
(*@/// procedure TStringAlignGrid.WriteHint(Writer: TWriter); *)
procedure TStringAlignGrid.WriteHint(Writer: TWriter);
var
  v:pstring;
  ACol,ARow: longint;
begin
  Writer.WriteListBegin;
  for ACol:=0 to ColCount-1 do begin
    for ARow:=0 to RowCount-1 do begin
      v:=GetItemCell(ACol,ARow,FHintCell);
      if v<>NIL then begin
        Writer.WriteInteger(ACol);
        Writer.WriteInteger(ARow);
        Writer.WriteString(v^);
        end;
      end;
    end;
  Writer.WriteListEnd;
  end;
(*@\\\0000000A01*)
(*@\\\000000010A*)
(*@/// Read and write the cell strings to the DFM *)
(*@/// procedure TStringAlignGrid.ReadCells(Reader: TReader); *)
procedure TStringAlignGrid.ReadCells(Reader: TReader);
var
  ACol,ARow: longint;
  v:pstring;
begin
  if FCell=NIL then  FCell:=TList.Create;
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    ACol:=Reader.ReadInteger;
    ARow:=Reader.ReadInteger;
    v:=NewStr(Reader.ReadString);
    v:=SetItemCell(ACol,ARow, FCell, v);
    FSaveCells:=true;
    if v<>NIL then
      DisposeStr(v);
    end;
  Reader.ReadListEnd;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.WriteCells(Writer: TWriter); *)
procedure TStringAlignGrid.WriteCells(Writer: TWriter);
var
  v:string;
  ACol,ARow: longint;
begin
  Writer.WriteListBegin;
  for ACol:=0 to ColCount-1 do begin
    for ARow:=0 to RowCount-1 do begin
      v:=Cells[ACol,ARow];
      if v<>'' then begin
        Writer.WriteInteger(ACol);
        Writer.WriteInteger(ARow);
        Writer.WriteString(v);
        end;
      end;
    end;
  Writer.WriteListEnd;
  end;
(*@\\\0000000415*)

{ To convert TStringGrid's own Cell property to my list and vice versa }
(*@/// procedure TStringAlignGrid.ListToCells(List:TList); *)
procedure TStringAlignGrid.ListToCells(List:TList);
var
  v:pstring;
  ACol, ARow: longint;
begin
  for ACol:=0 to ColCount-1 do
    for ARow:=0 to RowCount-1 do begin
      v:=GetItemCell(ACol,ARow,List);
      if v<>NIL then
        Cells[ACol,ARow]:=v^
      else
        Cells[ACol,ARow]:='';
      end;
  end;
(*@\\\0000000416*)
(*@/// procedure TStringAlignGrid.CellsToList(var List:TList); *)
procedure TStringAlignGrid.CellsToList(var List:TList);
var
  v:pstring;
  ACol, ARow: longint;
begin
  for ACol:=0 to ColCount-1 do
    for ARow:=0 to RowCount-1 do begin
      if cells[ACol,ARow]<>'' then begin
        v:=NewStr(cells[ACol,ARow]);
        end
      else
        v:=NIL;
      v:=SetItemCell(ACol,ARow, List, v);
      if v<>NIL then
        DisposeStr(v);
    end;
  end;
(*@\\\*)
(*@\\\*)

(*@/// Read several alignment lists to the DFM *)
{ All the routines for the several alignment lists }
(*@/// procedure TStringAlignGrid.ReadAlignCell(Stream: TStream); *)
procedure TStringAlignGrid.ReadAlignCell(Stream: TStream);
var
  ACol,ARow: word;
  p:tmyalign;
begin
  Stream.Seek(0,0);
  while Stream.Position<Stream.Size do begin
    Stream.Read(ACol,sizeof(word));
    Stream.Read(ARow,sizeof(word));
    Stream.Read(p,sizeof(TMyAlign));
    AlignCell[ACol,ARow]:=p;
    end;
  end;
(*@\\\0000000B01*)
(*@/// procedure TStringAlignGrid.ReadAlignCol(Stream: TStream); *)
procedure TStringAlignGrid.ReadAlignCol(Stream: TStream);
begin
  ReadAlignColRow(Stream,c_Column);
  end;
(*@\\\000000031A*)
(*@/// procedure TStringAlignGrid.ReadFixedAlignCol(Stream: TStream); *)
procedure TStringAlignGrid.ReadFixedAlignCol(Stream: TStream);
begin
  ReadAlignColRow(Stream,c_fixed_Column);
  end;
(*@\\\000000031A*)
(*@/// procedure TStringAlignGrid.ReadAlignRow(Stream: TStream); *)
procedure TStringAlignGrid.ReadAlignRow(Stream: TStream);
begin
  ReadAlignColRow(Stream,c_row);
  end;
(*@\\\000000031A*)
(*@/// procedure TStringAlignGrid.ReadFixedAlignRow(Stream: TStream); *)
procedure TStringAlignGrid.ReadFixedAlignRow(Stream: TStream);
begin
  ReadAlignColRow(Stream,c_fixed_row);
  end;
(*@\\\0000000322*)

{ All the ReadCol, ReadRow are so similar, so these to routines are there
  to avoid code-copy }
(*@/// function TStringAlignGrid.ReadAlignColRow(Stream: TStream; colrow:t_colrow):boolean; *)
function TStringAlignGrid.ReadAlignColRow(Stream: TStream; colrow:t_colrow):boolean;
var
  AColRow: word;
  p:tmyalign;
begin
  result:=false;
  Stream.Seek(0,0);
  while Stream.Position<Stream.Size do begin
    Stream.Read(AColRow,sizeof(word));
    Stream.Read(p,sizeof(TMyAlign));
    case colrow of
      c_column:       aligncol[AColRow]:=p;
      c_row:          alignrow[AColRow]:=p;
      c_fixed_column: fixaligncol[AColRow]:=p;
      c_fixed_row:    fixalignrow[AColRow]:=p;
      end;
    result:=true;
    end;
  end;
(*@\\\0000000B01*)
(*@\\\0000000A01*)
(*@/// Read several edit-enabled lists to the DFM *)
{ All the routines for the several edit-enabled lists }
(*@/// procedure TStringAlignGrid.ReadEditCell(Stream: TStream); *)
procedure TStringAlignGrid.ReadEditCell(Stream: TStream);
var
  ACol,ARow: word;
  p:boolean;
begin
  Stream.Seek(0,0);
  while Stream.Position<Stream.Size do begin
    Stream.Read(ACol,sizeof(word));
    Stream.Read(ARow,sizeof(word));
    Stream.Read(p,sizeof(boolean));
    EditCell[ACol,ARow]:=p;
    end;
  end;
(*@\\\0000000A01*)
(*@/// procedure TStringAlignGrid.ReadEditCol(Stream: TStream); *)
procedure TStringAlignGrid.ReadEditCol(Stream: TStream);
begin
  ReadEditColRow(Stream,c_column);
  end;
(*@\\\0000000319*)
(*@/// procedure TStringAlignGrid.ReadEditRow(Stream: TStream); *)
procedure TStringAlignGrid.ReadEditRow(Stream: TStream);
begin
  ReadEditColRow(Stream,c_row);
  end;
(*@\\\0000000303*)

{ All the ReadCol, ReadRow are so similar, so these to routines are there
  to avoid code-copy }
(*@/// function TStringAlignGrid.ReadEditColRow(Stream: TStream; colrow:t_colrow):boolean; *)
function TStringAlignGrid.ReadEditColRow(Stream: TStream; colrow:t_colrow):boolean;
var
  AColRow: word;
  p:boolean;
begin
  result:=false;
  Stream.Seek(0,0);
  while Stream.Position<Stream.Size do begin
    Stream.Read(AColRow,sizeof(word));
    Stream.Read(p,sizeof(boolean));
    case colrow of
      c_column:       editcol[AColRow]:=p;
      c_row:          editrow[AColRow]:=p;
      c_fixed_column: ;
      c_fixed_row:    ;
      end;
    result:=true;
    end;
  end;
(*@\\\0000000F15*)
(*@\\\0000000801*)
(*@/// Read several font lists to the DFM *)
{ All the routines for the different font lists }
(*@/// procedure TStringAlignGrid.ReadFontCell(Reader: TReader); *)
procedure TStringAlignGrid.ReadFontCell(Reader: TReader);
var
  ACol,ARow: word;
  v:TFont;
begin
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    ACol:=Reader.ReadInteger;
    ARow:=Reader.ReadInteger;
    v:=ReadFont(Reader);
    cellfont[ACol,ARow].assign(v);
    v.free;
{     v:=NIL; }
    end;
  Reader.ReadListEnd;
  end;
(*@\\\0000000E01*)
(*@/// procedure TStringAlignGrid.ReadFontCol(Reader: TReader); *)
procedure TStringAlignGrid.ReadFontCol(Reader: TReader);
begin
  ReadFontColRow(Reader,c_column);
  end;
(*@\\\0000000319*)
(*@/// procedure TStringAlignGrid.ReadFontRow(Reader: TReader); *)
procedure TStringAlignGrid.ReadFontRow(Reader: TReader);
begin
  ReadFontColRow(Reader,c_row);
  end;
(*@\\\0000000319*)
(*@/// procedure TStringAlignGrid.ReadFixedFontCol(Reader: TReader); *)
procedure TStringAlignGrid.ReadFixedFontCol(Reader: TReader);
begin
  ReadFontColRow(Reader,c_fixed_column);
  end;
(*@\\\0000000303*)
(*@/// procedure TStringAlignGrid.ReadFixedFontRow(Reader: TReader); *)
procedure TStringAlignGrid.ReadFixedFontRow(Reader: TReader);
begin
  ReadFontColRow(Reader,c_fixed_row);
  end;
(*@\\\0000000301*)

{ All the ReadCol, ReadRow are so similar, so these to routines are there
  to avoid code-copy }
(*@/// function TStringAlignGrid.ReadFontColRow(Reader:TReader; colrow:t_colrow):boolean; *)
function TStringAlignGrid.ReadFontColRow(Reader:TReader; colrow:t_colrow):boolean;
var
  AColRow: word;
  v: TFont;
begin
  result:=false;
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    AColRow:=Reader.ReadInteger;
    v:=ReadFont(Reader);
    case colrow of
      c_column:       colfont[AColRow].assign(v);
      c_row:          rowfont[AColRow].assign(v);
      c_fixed_column: fixedcolfont[AColRow].assign(v);
      c_fixed_row:    fixedrowfont[AColRow].assign(v);
      end;
    v.free;
{     v:=NIL; }
    result:=true;
    end;
  Reader.ReadListEnd;
  end;
(*@\\\0000000C01*)
(*@\\\0000000A01*)
(*@/// Read several brush lists to the DFM *)
{ All the routines for the different Brush lists }
(*@/// procedure TStringAlignGrid.ReadBrushCell(Reader: TReader); *)
procedure TStringAlignGrid.ReadBrushCell(Reader: TReader);
var
  ACol,ARow: word;
  v:TBrush;
begin
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    ACol:=Reader.ReadInteger;
    ARow:=Reader.ReadInteger;
    v:=ReadBrush(Reader);
    CellBrush[ACol,ARow].assign(v);
    v.free;
{     v:=NIL; }
    end;
  Reader.ReadListEnd;
  end;
(*@\\\0000000E01*)
(*@/// procedure TStringAlignGrid.ReadBrushCol(Reader: TReader); *)
procedure TStringAlignGrid.ReadBrushCol(Reader: TReader);
begin
  ReadBrushColRow(Reader,c_column);
  end;
(*@\\\000000031A*)
(*@/// procedure TStringAlignGrid.ReadBrushRow(Reader: TReader); *)
procedure TStringAlignGrid.ReadBrushRow(Reader: TReader);
begin
  ReadBrushColRow(Reader,c_row);
  end;
(*@\\\000000031A*)
(*@/// procedure TStringAlignGrid.ReadFixedBrushCol(Reader: TReader); *)
procedure TStringAlignGrid.ReadFixedBrushCol(Reader: TReader);
begin
  ReadBrushColRow(Reader,c_fixed_column);
  end;
(*@\\\000000031A*)
(*@/// procedure TStringAlignGrid.ReadFixedBrushRow(Reader: TReader); *)
procedure TStringAlignGrid.ReadFixedBrushRow(Reader: TReader);
begin
  ReadBrushColRow(Reader,c_fixed_row);
  end;
(*@\\\000000031A*)

{ All the ReadCol, ReadRow are so similar, so these to routines are there
  to avoid code-copy }
(*@/// function TStringAlignGrid.ReadBrushColRow(Reader:TReader; colrow:t_colrow):boolean; *)
function TStringAlignGrid.ReadBrushColRow(Reader:TReader; colrow:t_colrow):boolean;
var
  AColRow: word;
  v: TBrush;
begin
  result:=false;
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    AColRow:=Reader.ReadInteger;
    v:=ReadBrush(Reader);
    case colrow of
      c_column:       colbrush[AColRow].assign(v);
      c_row:          rowbrush[AColRow].assign(v);
      c_fixed_column: fixedcolbrush[AColRow].assign(v);
      c_fixed_row:    fixedrowbrush[AColRow].assign(v);
      end;
    v.free;
{     v:=NIL; }
    result:=true;
    end;
  Reader.ReadListEnd;
  end;
(*@\\\0000001301*)
(*@\\\0000000A01*)
(*@/// Read several color lists to the DFM *)
{ Only the read methods to read old DFM files correctly, all is now saved }
{ via the brushes }
(*@/// procedure TStringAlignGrid.ReadColorCell(Reader: TReader); *)
procedure TStringAlignGrid.ReadColorCell(Reader: TReader);
var
  ACol,ARow: longint;
begin
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    ACol:=Reader.ReadInteger;
    ARow:=Reader.ReadInteger;
    CellBrush[ACol,ARow].color:=Reader.ReadInteger;
    end;
  Reader.ReadListEnd;
  end;
(*@\\\0000000315*)
(*@/// procedure TStringAlignGrid.ReadColorCol(Reader: TReader); *)
procedure TStringAlignGrid.ReadColorCol(Reader: TReader);
begin
  ReadColorColRow(Reader,c_column);
  end;
(*@\\\000000031A*)
(*@/// procedure TStringAlignGrid.ReadColorRow(Reader: TReader); *)
procedure TStringAlignGrid.ReadColorRow(Reader: TReader);
begin
  ReadColorColRow(Reader,c_row);
  end;
(*@\\\000000031A*)
(*@/// procedure TStringAlignGrid.ReadFixedColorCol(Reader: TReader); *)
procedure TStringAlignGrid.ReadFixedColorCol(Reader: TReader);
begin
  ReadColorColRow(Reader,c_fixed_column);
  end;
(*@\\\000000031A*)
(*@/// procedure TStringAlignGrid.ReadFixedColorRow(Reader: TReader); *)
procedure TStringAlignGrid.ReadFixedColorRow(Reader: TReader);
begin
  ReadColorColRow(Reader,c_fixed_row);
  end;
(*@\\\000000031A*)

(*@/// procedure TStringAlignGrid.ReadColorColRow(Reader:TReader; colrow:t_colrow); *)
procedure TStringAlignGrid.ReadColorColRow(Reader:TReader; colrow:T_colrow);
var
  AColRow: longint;
begin
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    AColRow:=Reader.ReadInteger;
    case colrow of
      c_column:       ColBrush[AcolRow].color:=Reader.ReadInteger;
      c_row:          RowBrush[AcolRow].color:=Reader.ReadInteger;
      c_fixed_column: FixedColBrush[AcolRow].color:=Reader.ReadInteger;
      c_fixed_row:    FixedRowBrush[AcolRow].color:=Reader.ReadInteger;
      end;
    end;
  Reader.ReadListEnd;
  end;
(*@\\\0000000801*)
(*@\\\0000000901*)
(*@/// Read several selected color lists to the DFM *)
(*@/// procedure TStringAlignGrid.ReadSelColorCell(Reader: TReader); *)
procedure TStringAlignGrid.ReadSelColorCell(Reader: TReader);
var
  ACol,ARow: longint;
begin
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    ACol:=Reader.ReadInteger;
    ARow:=Reader.ReadInteger;
    SelectedColorCell[ACol,ARow]:=Reader.ReadInteger;
    end;
  Reader.ReadListEnd;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ReadSelColorCol(Reader: TReader); *)
procedure TStringAlignGrid.ReadSelColorCol(Reader: TReader);
begin
  ReadSelColorColRow(Reader,c_column);
  end;
(*@\\\0000000303*)
(*@/// procedure TStringAlignGrid.ReadSelColorRow(Reader: TReader); *)
procedure TStringAlignGrid.ReadSelColorRow(Reader: TReader);
begin
  ReadSelColorColRow(Reader,c_row);
  end;
(*@\\\0000000322*)

{ All the ReadCol, ReadRow are so similar, so these to routines are there
  to avoid code-copy }
(*@/// function TStringAlignGrid.ReadSelColorColRow(Reader:TReader; colrow:t_colrow):boolean; *)
function TStringAlignGrid.ReadSelColorColRow(Reader:TReader; colrow:t_colrow):boolean;
var
  AColRow: longint;
begin
  result:=false;
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    AColRow:=Reader.ReadInteger;
    case colrow of
      c_column:       SelectedColorCol[AcolRow]:=Reader.ReadInteger;
      c_row:          SelectedColorRow[AcolRow]:=Reader.ReadInteger;
      c_fixed_column: ;
      c_fixed_row:    ;
      end;
    result:=true;
    end;
  Reader.ReadListEnd;
  end;
(*@\\\0000000A17*)
(*@\\\*)
(*@/// Read several selected font color lists to the DFM *)
(*@/// procedure TStringAlignGrid.ReadSelFontColorCell(Reader: TReader); *)
procedure TStringAlignGrid.ReadSelFontColorCell(Reader: TReader);
var
  ACol,ARow: longint;
begin
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    ACol:=Reader.ReadInteger;
    ARow:=Reader.ReadInteger;
    SelectedFontColorCell[ACol,ARow]:=Reader.Readinteger;
    end;
  Reader.ReadListEnd;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.ReadSelFontColorCol(Reader: TReader); *)
procedure TStringAlignGrid.ReadSelFontColorCol(Reader: TReader);
begin
  ReadSelColorColRow(Reader,c_column);
  end;
(*@\\\0000000325*)
(*@/// procedure TStringAlignGrid.ReadSelFontColorRow(Reader: TReader); *)
procedure TStringAlignGrid.ReadSelFontColorRow(Reader: TReader);
begin
  ReadSelColorColRow(Reader,c_row);
  end;
(*@\\\0000000322*)

(*@/// function TStringAlignGrid.ReadSelFontColorColRow(Reader:TReader; colrow:t_colrow):boolean; *)
function TStringAlignGrid.ReadSelFontColorColRow(Reader:TReader; colrow:t_colrow):boolean;
var
  AColRow: longint;
begin
  result:=false;
  Reader.ReadListBegin;
  while not Reader.EndOfList do begin
    AColRow:=Reader.ReadInteger;
    case colrow of
      c_column:       SelectedFontColorCol[AcolRow]:=Reader.ReadInteger;
      c_row:          SelectedFontColorRow[AcolRow]:=Reader.ReadInteger;
      c_fixed_column: ;
      c_fixed_row:    ;
      end;
    result:=true;
    end;
  Reader.ReadListEnd;
  end;
(*@\\\0000000B2B*)
(*@\\\0000000301*)
(*@\\\*)
(*@/// Import and Export functions, Cut 'n' Paste *)
(*@/// function TStringAlignGrid.Contents2HTML(data:TMemorystream):TMemorystream; *)
function TStringAlignGrid.Contents2HTML(data:TMemorystream):TMemorystream;
var
  ACol,ARow: longint;
  font: TFont;
  c: TColor;
  addheader: string;
(*@/// function color2rgb(c:TColor):longint;        // bgr -> rgb *)
function color2rgb(c:TColor):longint;
var
  temp:longint;
begin
  temp:=colortorgb(c);
  result:=((temp and $ff) shl 16) or (temp and $ff00) or ((temp and $ff0000) shr 16);
  end;
(*@\\\*)
(*@/// function point2size(v:integer):integer; *)
function point2size(v:integer):integer;
begin
  case v of
    0..5: result:=1;
    6..9: result:=2;
    10  : result:=3;
    11..13: result:=4;
    14..17: result:=5;
    18..21: result:=6;
    else    result:=7;
    end;
  end;
(*@\\\*)
begin
  if data<>NIL then
    result:=data
  else
    result:=TMemorystream.Create;
  addheader:='';
  if htmlborder>0 then
    addheader:=addheader+' border='+inttostr(htmlborder);
  if htmlcaption<>'' then
    addheader:=addheader+' caption="'+text2html(htmlcaption)+'"';
  String2Stream(result,'<table bgcolor=#'+inttohex(color2rgb(color),6)+addheader+'>'#13#10);
  for ARow:=0 to RowCount do begin
    String2Stream(result,' <tr>'#13#10);
    for ACol:=0 to ColCount do begin
      if (ACol<FixedCols) or (ARow<FixedRows) then
        String2Stream(result,'  <th')
      else
        String2Stream(result,'  <td');
      case AlignCell[ACol,ARow] of
        alLeft  :  String2Stream(result,' align=left');
        alRight :  String2Stream(result,' align=right');
        alCenter:  String2Stream(result,' align=center');
        end;
      c:=ColorCell[ACol,ARow];
      if c<>color then
        String2Stream(result,' bgcolor=#'+inttohex(color2rgb(c),6));
      String2Stream(result,'>'#13#10);
      if cells[ACol,ARow]<>'' then begin
        font:=GetFontCellComplete(ACol,ARow);
        (*@/// if font.haschanged then write font data tags *)
        if TMyFont(font).haschanged then begin
          String2Stream(result,'   <font color=#'+inttohex(color2rgb(font.color),6)
                            +' size='+inttostr(point2size(font.size))+'>');
          if fsBold in font.style then
            String2Stream(result,'<b>');
          if fsItalic in font.style then
            String2Stream(result,'<i>');
          if fsStrikeOut in font.style then
            String2Stream(result,'<strike>');
          if fsUnderline in font.style then
            String2Stream(result,'<u>');
          end;
        (*@\\\*)
        String2Stream(result,text2html(cells[ACol,ARow]));
        (*@/// if font.haschanged then close font data tags *)
        if TMyFont(font).haschanged then begin
          if fsUnderline in font.style then
            String2Stream(result,'</u>');
          if fsStrikeOut in font.style then
            String2Stream(result,'</strike>');
          if fsItalic in font.style then
            String2Stream(result,'</i>');
          if fsBold in font.style then
            String2Stream(result,'</b>');
          String2Stream(result,'</font>');
          end;
        (*@\\\*)
        end;
      if (ACol<FixedCols) or (ARow<FixedRows) then
        String2Stream(result,'  </th>')
      else
        String2Stream(result,'  </td>');
      end;
    String2Stream(result,' </tr>'#13#10);
    end;
  String2Stream(result,'</table>'#13#10);
  end;
(*@\\\0000001001*)
(*@/// function TStringAlignGrid.Contents2CSV(data:TMemorystream; csv:char; range:TGridRect):TMemorystream; *)
function TStringAlignGrid.Contents2CSV(data:TMemorystream; csv:char; range:TGridRect):TMemorystream;
var
  ACol,ARow: longint;
  s: string;
begin
  if data<>NIL then
    result:=data
  else
    result:=TMemorystream.Create;
  if (range.right<range.left) or (range.right<0) then range.right:=self.colcount-1;
  if range.left<0 then range.left:=0;
  if (range.bottom<range.top) or (range.bottom<0) then range.bottom:=self.rowcount-1;
  if range.top<0 then range.top:=0;
  for ARow:=range.top to range.bottom do begin
    s:='';
    for ACol:=range.left to range.right do
      s:=s+cells[ACol,ARow]+csv;
    String2Stream(result,s+#13#10);
    end;
  end;
(*@\\\0000000A01*)
(*@/// procedure TStringAlignGrid.CSV2Contents(data:TStream; csv:char; range:TGridRect); *)
procedure TStringAlignGrid.CSV2Contents(data:TStream; csv:char; range:TGridRect);
var
  h: TStringlist;
  i,ACol,ARow: longint;
  s: string;
begin
  if data=NIL then EXIT;
  if Range.Top<0 then Range.top:=0;
  if Range.left<0 then Range.left:=0;
  if Range.Bottom<range.top then range.bottom:=maxint;
  if Range.right<range.left then range.right:=maxint;
  h:=NIL;
  try
    h:=TStringlist.Create;
    data.seek(0,0);
    h.loadfromstream(data);
    ARow:=range.top;
    i:=0;
    while (i<h.count) and (ARow<=Range.bottom) do begin
      if ARow>=RowCount then RowCount:=RowCount+1;
      ACol:=range.left;
      s:=h.strings[i]+csv;
      while (ACol<=range.right) and (length(s)>1) do begin
        if ACol>=ColCount then ColCount:=ColCount+1;
        if (not F_PasteEditableOnly) or EditCell[ACol,ARow] then
          cells[ACol,ARow]:=copy(s,1,pos(csv,s)-1);
        s:=copy(s,pos(csv,s)+1,length(s));
        inc(ACol);
        end;
      inc(ARow);
      inc(i);
      end;
  finally
    h.free;
    end;
  end;
(*@\\\0000001A01*)
(*@/// procedure TStringAlignGrid.SaveToFile(const filename:string); *)
procedure TStringAlignGrid.SaveToFile(const filename:string);
var
  data: TMemoryStream;
  rect: TGridRect;
begin
  data:=NIL;
  rect.left:=-1;
  rect.right:=-1;
  rect.top:=-1;
  rect.bottom:=-1;
  try
    data:=Contents2CSV(data,#9,rect);
    data.savetofile(filename);
  finally
    data.free;
    end;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.LoadFromFile(const filename:string); *)
procedure TStringAlignGrid.LoadFromFile(const filename:string);
var
  data: TFileStream;
  rect: TGridRect;
begin
  data:=NIL;
  rect.left:=-1;
  rect.right:=-1;
  rect.top:=-1;
  rect.bottom:=-1;
  try
    data:=TFileStream.Create(filename,fmOpenRead);
    CSV2Contents(data,#9,rect);
  finally
    data.free;
    end;
  end;
(*@\\\0000000D19*)

(*@/// procedure TStringAlignGrid.Contents2CSVClipboard(csv:char; range:TGridRect); *)
procedure TStringAlignGrid.Contents2CSVClipboard(csv:char; range:TGridRect);
var
  h: TMemorystream;
begin
  h:=NIL;
  try
    h:=TMemorystream.Create;
    Contents2CSV(h,csv,range);
    Stream2Clipboard(h,cf_text);
  finally
    h.free;
    end;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.ClipboardCSV2Contents(csv:char; range:TGridRect); *)
procedure TStringAlignGrid.ClipboardCSV2Contents(csv:char; range:TGridRect);
var
  h: TMemorystream;
begin
  h:=NIL;
  try
    h:=TMemorystream.Create;
    Clipboard2Stream(h,cf_text);
    CSV2Contents(h,csv,range);
  finally
    h.free;
    end;
  end;
(*@\\\0000000801*)
(*@/// procedure TStringAlignGrid.Contents2HTMLClipboard; *)
procedure TStringAlignGrid.Contents2HTMLClipboard;
var
  h: TMemorystream;
begin
  h:=NIL;
  try
    h:=Contents2HTML(NIL);
    Stream2Clipboard(h,cf_text);
  finally
    h.free;
    end;
  end;
(*@\\\0000000701*)

(*@/// procedure TStringAlignGrid.CopyToClipboard; *)
procedure TStringAlignGrid.CopyToClipboard;
var
  rect: TGridRect;
begin
  rect.left:=-1;
  rect.right:=-1;
  rect.top:=-1;
  rect.bottom:=-1;
  Contents2CSVClipboard(#9,rect);
  end;
(*@\\\0000000301*)
(*@/// procedure TStringAlignGrid.CopyFromClipboard; *)
procedure TStringAlignGrid.CopyFromClipboard;
var
  rect: TGridRect;
begin
  rect.left:=-1;
  rect.right:=-1;
  rect.top:=-1;
  rect.bottom:=-1;
  ClipboardCSV2Contents(#9,rect);
  end;
(*@\\\0000000901*)

(*@/// procedure TStringAlignGrid.WMCut(var Message: TMessage); *)
procedure TStringAlignGrid.WMCut(var Message: TMessage);
var
  range: TGridRect;
  ACol,ARow: longint;
begin
  if f_cutnpaste then begin
    range:=Selection;
    if (range.right<range.left) or (range.right<0) then range.right:=self.colcount-1;
    if range.left<0 then range.left:=0;
    if (range.bottom<range.top) or (range.bottom<0) then range.bottom:=self.rowcount-1;
    if range.top<0 then range.top:=0;
    Contents2CSVClipboard(#9,range);
    for ARow:=range.top to range.bottom do
      for ACol:=range.left to range.right do
        if (not F_PasteEditableOnly) or EditCell[ACol,ARow] then
          cells[ACol,ARow]:='';
    end;
  inherited;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.WMCopy(var Message: TMessage); *)
procedure TStringAlignGrid.WMCopy(var Message: TMessage);
begin
  if f_cutnpaste then
    Contents2CSVClipboard(#9,selection);
  inherited;
  end;
(*@\\\0000000301*)
(*@/// procedure TStringAlignGrid.WMPaste(var Message: TMessage); *)
procedure TStringAlignGrid.WMPaste(var Message: TMessage);
begin
  if f_cutnpaste then
    ClipboardCSV2Contents(#9,selection);
  inherited;
  end;
(*@\\\0000000401*)
(*@\\\*)
(*@/// Sorting stuff *)
{ The sorting itself }
(*@/// procedure TStringAlignGrid.DoSortBubble(ColRow,Min,Max: longint; ..) *)
procedure TStringAlignGrid.DoSortBubble(ColRow,Min,Max: longint; ByColumn,ascending: boolean);
var
  i,j,k: longint;
begin
  for i:=Min to Max-1 do begin
    k:=i;
    for j:=i+1 to Max do begin
      if ByColumn then
        case f_compare_col(self,ColRow,k,j) of
          rel_equal: ;
          rel_greater: if ascending then k:=j;
          rel_less:    if not ascending then k:=j;
          end
      else
        case f_compare_row(self,ColRow,k,j) of
          rel_equal: ;
          rel_greater: if ascending then k:=j;
          rel_less:    if not ascending then k:=j;
          end;
      end;
    if i<>k then begin
      if ByColumn then
        ExchangeRow(k,i)
      else
        ExchangeCol(k,i);
      end;
    end;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.DoSortQuick(ColRow,Min,Max: longint; ..) *)
procedure TStringAlignGrid.DoSortQuick(ColRow,Min,Max: longint; ByColumn,ascending: boolean);
(* Adopted from Delphi Magazine 37 - "Don Alfresco" Julian M Bucknall *)
var
  comp: t_relation;
  aLessThan: TCompareFunction;
(*@/// function Partition(L, R : longint): longint; *)
function Partition(L, R : longint): longint;
var
  i, j : longint;
begin
  i := L;
  j := pred(R);
  while true do begin
    while aLessThan(self,colrow,i,R)=comp do
      inc(i);
    while aLessThan(self,colrow,R,j)=comp do begin
      if (j = L) then
        BREAK;
      dec(j);
      end;
    if (i >= j) then
      BREAK;
    if ByColumn then
      ExchangeRow(i,j)
    else
      ExchangeCol(i,j);
    inc(i);
    dec(j);
    end;
  if ByColumn then
    ExchangeRow(i,R)
  else
    ExchangeCol(i,R);
  Result := i;
  end;
(*@\\\*)
(*@/// procedure QuickSortPrim(L, R : longint); *)
procedure QuickSortPrim(L, R : longint);
var
  DividingItem : longint;
begin
  if (R - L) <= 0 then
    EXIT;
  DividingItem := Partition(L, R);
  QuicksortPrim(L, pred(DividingItem));
  QuicksortPrim(succ(DividingItem), R);
  end;
(*@\\\0000000501*)
begin
  if ascending then
    comp:=rel_less
  else
    comp:=rel_greater;
  if ByColumn then
    aLessThan:=f_compare_col
  else
    aLessThan:=f_compare_row;
  QuicksortPrim(Min,Max);
  end;
(*@\\\0000000201*)

{ Some ready-made sorting functions }
(*@/// function TStringAlignGrid.CompareColString(Sender: TObject; Column, Row1,Row2: longint):t_relation; *)
function TStringAlignGrid.CompareColString(Sender: TObject; Column, Row1,Row2: longint):t_relation;
begin
  if false then
  else if Cells[Column,Row1]<Cells[Column,Row2] then
    result:=rel_less
  else if Cells[Column,Row1]>Cells[Column,Row2] then
    result:=rel_greater
  else
    result:=rel_equal;
  end;
(*@\\\0000000916*)
(*@/// function TStringAlignGrid.CompareRowString(Sender: TObject; RowNr, Col1,Col2: longint):t_relation; *)
function TStringAlignGrid.CompareRowString(Sender: TObject; RowNr, Col1,Col2: longint):t_relation;
begin
  if false then
  else if Cells[Col1,RowNr]<Cells[Col2,RowNr] then
    result:=rel_less
  else if Cells[Col1,RowNr]>Cells[Col2,RowNr] then
    result:=rel_greater
  else
    result:=rel_equal;
  end;
(*@\\\0000000916*)
(*@/// function TStringAlignGrid.CompareColInteger(Sender: TObject; Column, Row1,Row2: longint):t_relation; *)
function TStringAlignGrid.CompareColInteger(Sender: TObject; Column, Row1,Row2: longint):t_relation;
var
  v1,v2: longint;
begin
  try
    v1:=strtoint(Cells[Column,Row1]);
  except
    v1:=0;
    end;
  try
    v2:=strtoint(Cells[Column,Row2]);
  except
    v2:=0;
    end;
  if false then
  else if v1=v2 then
    result:=rel_equal
  else if v1>v2 then
    result:=rel_greater
  else
    result:=rel_less;
  end;
(*@\\\0000000801*)
(*@/// function TStringAlignGrid.CompareRowInteger(Sender: TObject; RowNr, Col1,Col2: longint):t_relation; *)
function TStringAlignGrid.CompareRowInteger(Sender: TObject; RowNr, Col1,Col2: longint):t_relation;
var
  v1,v2: longint;
begin
  try
    v1:=strtoint(Cells[Col1,RowNr]);
  except
    v1:=0;
    end;
  try
    v2:=strtoint(Cells[Col2,RowNr]);
  except
    v2:=0;
    end;
  if false then
  else if v1=v2 then
    result:=rel_equal
  else if v1>v2 then
    result:=rel_greater
  else
    result:=rel_less;
  end;
(*@\\\*)

{ The procedures for the user to call }
(*@/// procedure TStringAlignGrid.SortColumn(Column: longint; Ascending:boolean); *)
procedure TStringAlignGrid.SortColumn(Column: longint; Ascending:boolean);
begin
  if not assigned(f_compare_col) then EXIT;
  fSortMethod(Column,FixedRows,RowCount-1,true,Ascending);
  end;
(*@\\\000000040E*)
(*@/// procedure TStringAlignGrid.SortRow(RowNumber: longint; Ascending:boolean); *)
procedure TStringAlignGrid.SortRow(RowNumber: longint; Ascending:boolean);
begin
  if not assigned(f_compare_row) then EXIT;
  fSortMethod(RowNumber,FixedCols,ColCount-1,false,Ascending);
  end;
(*@\\\0000000401*)
(*@\\\0000000301*)
(*@/// Miscellaneous stuff *)
(*@/// procedure TStringAlignGrid.ClearSelection; *)
procedure TStringAlignGrid.ClearSelection;
var
  t: TGridRect;
begin
  t.left:=-1;
  t.right:=-1;
  t.top:=-1;
  t.bottom:=-1;
  self.selection:=t;
  end;
(*@\\\*)
(*@/// function TStringAlignGrid.is_fixed(ACol,ARow: longint):boolean; *)
function TStringAlignGrid.is_fixed(ACol,ARow: longint):boolean;
begin
  result:= (ACol<FixedCols) or (ARow<FixedRows) or
           (ACol<f_FixedCols) or (ARow<f_FixedRows);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.NextEditableCell(var ACol,ARow:longint); *)
procedure TStringAlignGrid.NextEditableCell(var ACol,ARow:longint);
var
  FCol,FRow: longint;
  ColNo, RowNo: longint;
  newline: boolean;
begin
  FCol:=ACol;
  FRow:=ARow;
  ColNo:=ColCount;
  RowNo:=RowCount;
  newline:=false;
  repeat
    if newline then
      BREAK;  (* a new line with no editable cells emerged, if not captured
                 here expect a lot of new lines *)
    nextCell(f_nextcell_edit,f_lastcell_edit,ACol,ARow);
    newline:=(ColNo<>ColCount) or (RowNo<>RowCount);
    if (ACol=FCol) and (ARow=FRow) then  BREAK;   (* to avoid dead loop *)
    if (ACol=-1) and (ARow=-1) then
      BREAK;   (* add a new line ? jump to start ? or stay in cell ? *)
    until EditCell[ACol,ARow]
  end;
(*@\\\0000001105*)
(*@/// procedure TStringAlignGrid.NextCell(direction:t_nextcell; ..); *)
procedure TStringAlignGrid.NextCell(direction:t_nextcell;
  LastCellBehaviour: t_lastcell; Var ACol,ARow:longint);
var
(*$ifdef delphi_ge_3 *)
  f: tcustomform;
(*$else *)
  f: tform;
(*$endif *)
begin
  case direction of
    (*@/// nc_rightdown: *)
    nc_rightdown: begin
      inc(ACol);
      if ACol>=ColCount then begin
        ACol:=FixedCols;
        inc(ARow);
        end;
      if ARow>=RowCount then begin
        ACol:=-1;
        ARow:=-1;
        end;
      end;
    (*@\\\*)
    (*@/// nc_rightup: *)
    nc_rightup: begin
      inc(ACol);
      if ACol>=ColCount then begin
        ACol:=FixedCols;
        dec(ARow);
        end;
      if ARow<FixedRows then begin
        ACol:=-1;
        ARow:=-1;
        end;
      end;
    (*@\\\*)
    (*@/// nc_leftdown: *)
    nc_leftdown: begin
      dec(ACol);
      if ACol<FixedCols then begin
        ACol:=ColCount-1;
        inc(ARow);
        end;
      if ARow>=RowCount then begin
        ACol:=-1;
        ARow:=-1;
        end;
      end;
    (*@\\\*)
    (*@/// nc_leftup: *)
    nc_leftup: begin
      dec(ACol);
      if ACol<FixedCols then begin
        ACol:=ColCount-1;
        dec(ARow); (* !!! *)
        end;
      if ARow<FixedRows then begin
        ACol:=-1;
        ARow:=-1;
        end;
      end;
    (*@\\\0000000501*)
    (*@/// nc_downright: *)
    nc_downright: begin
      inc(ARow);
      if ARow>=RowCount then begin
        ARow:=FixedRows;
        inc(ACol);
        end;
      if ACol>=ColCount then begin
        ACol:=-1;
        ARow:=-1;
        end;
      end;
    (*@\\\*)
    (*@/// nc_downleft: *)
    nc_downleft: begin
      inc(ARow);
      if ARow>=RowCount then begin
        ARow:=FixedRows;
        dec(ACol);
        end;
      if ACol<FixedCols then begin
        ACol:=-1;
        ARow:=-1;
        end;
      end;
    (*@\\\*)
    (*@/// nc_upleft: *)
    nc_upleft: begin
      dec(ARow);
      if ARow<FixedRows then begin
        ARow:=RowCount-1;
        dec(ACol);
        end;
      if ACol<FixedCols then begin
        ACol:=-1;
        ARow:=-1;
        end;
      end;
    (*@\\\*)
    (*@/// nc_upright: *)
    nc_upright: begin
      dec(ARow);
      if ARow<FixedRows then begin
        ARow:=RowCount-1;
        inc(ACol);
        end;
      if ACol>=ColCount then begin
        ACol:=-1;
        ARow:=-1;
        end;
      end;
    (*@\\\*)
    end;
  if (ACol=-1) and (ARow=-1) then
    case LastCellBehaviour of
      (*@/// lc_first: *)
      lc_first:
        case direction of
          nc_rightdown,
          nc_downright: begin  ACol:=FixedCols;  ARow:=FixedRows;  end;
          nc_rightup,
          nc_upright:   begin  ACol:=FixedCols;  ARow:=RowCount-1; end;
          nc_leftdown,
          nc_downleft:  begin  ACol:=ColCount-1; ARow:=FixedRows;  end;
          nc_leftup,
          nc_upleft:    begin  ACol:=ColCount-1; ARow:=RowCount-1; end;
          end;
      (*@\\\*)
      lc_stop:  ;
      (*@/// lc_newcolrow: *)
      lc_newcolrow:
        case direction of
          (*@/// nc_rightdown: *)
          nc_rightdown:   begin
            insertrow(RowCount);
            ARow:=Rowcount-1;
            ACol:=FixedCols;
            end;
          (*@\\\*)
          (*@/// nc_leftdown: *)
          nc_leftdown:   begin
            insertrow(RowCount);
            ARow:=Rowcount-1;
            ACol:=ColCount-1;
            end;
          (*@\\\*)
          (*@/// nc_rightup: *)
          nc_rightup:   begin
            insertrow(FixedRows);
            ARow:=FixedRows;
            ACol:=FixedCols;
            end;
          (*@\\\*)
          (*@/// nc_leftup: *)
          nc_leftup:   begin
            insertrow(FixedRows);
            ARow:=FixedRows;
            ACol:=ColCount-1;
            end;
          (*@\\\*)
          (*@/// nc_downright: *)
          nc_downright:   begin
            insertcol(ColCount);
            ARow:=FixedRows;
            ACol:=Colcount-1;
            end;
          (*@\\\*)
          (*@/// nc_downleft: *)
          nc_downleft:   begin
            insertcol(FixedCols);
            ARow:=FixedRows;
            ACol:=FixedCols;
            end;
          (*@\\\*)
          (*@/// nc_upright: *)
          nc_upright:   begin
            insertcol(ColCount);
            ARow:=RowCount-1;
            ACol:=ColCount-1;
            end;
          (*@\\\*)
          (*@/// nc_upleft: *)
          nc_upleft:   begin
            insertcol(FixedCols);
            ARow:=RowCount-1;
            ACol:=FixedCols;
            end;
          (*@\\\*)
          end;
      (*@\\\*)
      (*@/// lc_exit: *)
      lc_exit: begin
        f:=GetParentForm(self);
        if f<>NIL then
          f.Perform(wm_nextdlgctl,0,0);
        end;
      (*@\\\0000000108*)
      end;
  end;
(*@\\\0000001901*)
(*@/// procedure TStringAlignGrid.WMChar(var Msg: TWMChar); *)
procedure TStringAlignGrid.WMChar(var Msg: TWMChar);
begin
  if (goEditing in Options) and (Char(Msg.CharCode) in [^H, #32..#255]) then begin
    ShowEditorChar(Char(Msg.CharCode));
    if not Editormode then begin
      { This is what an inherited inherited would have done if Object Pascal
        would allow it }
      if not DoKeyPress(Msg) then
        { no further inherited } ;
      end
    end
  else
    inherited;
end;
(*@\\\0000000401*)
(*@/// procedure TStringAlignGrid.KeyDown(var Key: Word; Shift: TShiftState); *)
procedure TStringAlignGrid.KeyDown(var Key: Word; Shift: TShiftState);
var
  ACol,ARow: longint;
  FCol,FRow: longint;
  direction: T_nextcell;
{   ColNo, RowNo: longint; }
{   newline: boolean; }
(*@/// procedure CopyToClipboard; *)
procedure CopyToClipboard;
begin
  SendMessage(Handle, WM_COPY, 0, 0);
  end;
(*@\\\000000010B*)
(*@/// procedure CutToClipboard; *)
procedure CutToClipboard;
begin
  SendMessage(Handle, WM_CUT, 0, 0);
  end;
(*@\\\000000010B*)
(*@/// procedure PasteFromClipboard; *)
procedure PasteFromClipboard;
begin
  SendMessage(Handle, WM_PASTE, 0, 0);
  end;
(*@\\\000000010B*)
begin
  case Key of
    (*@/// VK_INSERT: *)
    VK_INSERT:
      if ssShift in Shift then
        PasteFromClipBoard
      else if ssCtrl in Shift then
        CopyToClipBoard;
    (*@\\\0000000301*)
    (*@/// VK_DELETE: *)
    VK_DELETE:
      if ssShift in Shift then
        CutToClipBoard;
    (*@\\\*)
{     ^X: CutToClipBoard; }
{     ^C: CopyToClipBoard; }
{     ^V: PasteFromClipBoard; }
    (*@/// VK_TAB: *)
    VK_TAB:
      if not (ssAlt in Shift) then begin
        ACol:=Col;        ARow:=Row;
        FCol:=Col;        FRow:=Row;
    {     ColNo:=ColCount;  RowNo:=RowCount; }
    {     newline:=false; }
        direction:=f_nextcell_tab;
        (*@/// if ssShift in Shift then  invert direction *)
        if ssShift in Shift then
          case direction of
            nc_rightdown:  direction:=nc_leftup;
            nc_rightup:    direction:=nc_leftdown;
            nc_leftdown:   direction:=nc_rightup;
            nc_leftup:     direction:=nc_rightdown;
            nc_downright:  direction:=nc_upleft;
            nc_downleft:   direction:=nc_upright;
            nc_upleft:     direction:=nc_downright;
            nc_upright:    direction:=nc_downleft;
            end;
        (*@\\\*)
        repeat
    {       if newline then }
    {         BREAK; }
          NextCell(direction,f_lastcell_tab,ACol,ARow);
    {       newline:=(ColNo<>ColCount) or (RowNo<>RowCount); }
          if (ACol=FCol) and (ARow=FRow) then  BREAK;   (* to avoid dead loop *)
          if (ACol=-1) and (ARow=-1) then begin
            ACol:=FCol;
            ARow:=FRow;
            BREAK;   (* add a new line ? jump to start ? or stay in cell ? *)
            end;
          until TabStops[ACol];
        Col:=ACol; Row:=ARow;      (* why is Focuscell private? *)
        key:=0;                    (* to avoid inherited making nonsense *)
        end;
    (*@\\\0000001705*)
    end;
  inherited KeyDown(Key, Shift);
  end;
(*@\\\0000001001*)
(*@/// procedure TStringAlignGrid.MouseDown(Button:TMouseButton; Shift:TShiftState; X,Y:Integer); *)
procedure TStringAlignGrid.MouseDown(Button:TMouseButton; Shift:TShiftState; X,Y:Integer);
var
  ACol,ARow: longint;
  r: TRect;
begin
  if ((x>=0) or (y>=0)) and (button=mbLeft) then begin
    mousetocell(x,y,ACol,ARow);
    if false then
    else if (ACol<FixedCols) and (ARow<FixedRows) then
    else if (ACol<FixedCols) and assigned(f_fixedrowclick) then
      f_fixedrowclick(Self,ARow)
    else if (ARow<FixedRows) and assigned(f_fixedcolclick) then
      f_fixedcolclick(Self,ACol);
    if CellHasCombobox(ACol,ARow) then begin
      r:=CellRect(ACol,ARow);
      if (x>=r.left) and (x<=r.right) and (y>=r.top) and (y<=r.bottom) then begin
        Col:=ACol;
        Row:=ARow;
        ShowEditor;
        end;
      end;
    end;
  inherited MouseDown(Button,Shift,X,Y);
  end;
(*@\\\000000140D*)

(*@/// procedure TStringAlignGrid.ColWidthsChanged; *)
procedure TStringAlignGrid.ColWidthsChanged;
begin
  inherited ColWidthsChanged;
  if assigned(fwidthschanged) then  fwidthschanged(self);
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.RowHeightsChanged; *)
procedure TStringAlignGrid.RowHeightsChanged;
begin
  inherited RowHeightsChanged;
  if assigned(fheightschanged) then  fheightschanged(self);
  end;
(*@\\\*)

(*@/// procedure TStringAlignGrid.AdjustRowHeight(ARow:longint); *)
procedure TStringAlignGrid.AdjustRowHeight(ARow:longint);
var
  h: longint;
  ACol: longint;
begin
  if ARow>=RowCount then EXIT;
  h:=0;
  for ACol:=ColCount-1 downto 0 do begin
    h:=max(h,textheight(ACol,ARow));
    end;
  RowHeights[ARow]:=h;
  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.AdjustColWidth(ACol:longint); *)
procedure TStringAlignGrid.AdjustColWidth(ACol:longint);
var
  h: longint;
  ARow: longint;
begin
  if ACol>=ColCount then EXIT;
  h:=0;
  for ARow:=RowCount-1 downto 0 do begin
    h:=max(h,textwidth(ACol,ARow));
    end;
  ColWidths[ACol]:=h;
  end;
(*@\\\0000000B03*)
(*@/// procedure TStringAlignGrid.AdjustRowHeights; *)
procedure TStringAlignGrid.AdjustRowHeights;
var
  ARow: longint;
begin
  for ARow:=RowCount-1 downto 0 do
    AdjustRowHeight(ARow);
  end;
(*@\\\000000012C*)
(*@/// procedure TStringAlignGrid.AdjustColWidths; *)
procedure TStringAlignGrid.AdjustColWidths;
var
  ACol: longint;
begin
  for ACol:=ColCount-1 downto 0 do
    AdjustColWidth(ACol);
  end;
(*@\\\*)

{ Suggested by Olav Lindkjolen <olav.lind@online.no> }
(*@/// procedure TStringAlignGrid.AdjustLastCol; *)
procedure TStringAlignGrid.AdjustLastCol;
var
  x,w,c: longint;
begin
  w:=0;
  for x:=0 to (ColCount-2) do
    w:= w+ColWidths[x];
  if (goVertLine in Options) or (goFixedVertLine in Options) then
    c:=ColCount*GridLineWidth
  else
    c:=0;
  if (w<ClientWidth) then
    ColWidths[ColCount-1]:=ClientWidth-w-c;
  end;
(*@\\\0000000901*)
(*@/// procedure TStringAlignGrid.SetAutoAdjustLastCol(Value: Boolean); *)
procedure TStringAlignGrid.SetAutoAdjustLastCol(Value: Boolean);
begin
  if (Value <> FAutoAdjustLastCol) then
    FAutoAdjustLastCol := Value;
  if FAutoAdjustLastCol then
    AdjustLastCol;
  end;
(*@\\\0000000501*)
(*@/// procedure TStringAlignGrid.SetGridLineWidthNew(Value: Integer); *)
procedure TStringAlignGrid.SetGridLineWidthNew(Value: Integer);
begin
  if GridLineWidth<>value then begin
    inherited GridLineWidth:=value;
    if FAutoAdjustLastCol then
      AdjustLastCol;
    end;
  end;
(*@\\\0000000201*)
(*@/// procedure TStringAlignGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); *)
procedure TStringAlignGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FAutoAdjustLastCol then
    AdjustLastCol;
  end;
(*@\\\0000000503*)
(*@/// procedure TStringAlignGrid.WMSize(var Msg: TWMSize); *)
procedure TStringAlignGrid.WMSize(var Msg: TWMSize);
begin
  inherited;
  if FAutoAdjustLastCol then
    AdjustLastCol;
  end;
(*@\\\0000000401*)

{ Suggested by Marian Meier <maier@home.ivm.de> }
(*@/// function TStringAlignGrid.GetTotalWidth:Longint; *)
function TStringAlignGrid.GetTotalWidth:Longint;
var
  i:Longint;
begin
  Result:=0;
  if BorderStyle=bsSingle then
    inc(Result);
  if Ctl3D then
    inc(Result);
  for i:=0 to ColCount-1 do
    Result:=Result+ColWidths[i];
  end;
(*@\\\*)
(*@/// function TStringAlignGrid.GetTotalHeight:Longint; *)
function TStringAlignGrid.GetTotalHeight:Longint;
var
  i:Longint;
begin
  Result:=0;
  if BorderStyle=bsSingle then
    inc(Result);
  if Ctl3D then
    inc(Result);
  for i:=0 to RowCount-1 do
    Result:=Result+RowHeights[i];
  end;
(*@\\\*)

(*@/// procedure TStringAlignGrid.TopLeftChanged; *)
procedure TStringAlignGrid.TopLeftChanged;
begin
  inherited TopLeftChanged;
  if EditorMode then
    postmessage(self.handle,cn_edit_update,0,0);
  if f_doaltcolcolor or f_doaltrowcolor then
    invalidate;
  end;
(*@\\\000000052B*)

(*@/// procedure TStringAlignGrid.SetDrawselect(value: boolean); *)
procedure TStringAlignGrid.SetDrawselect(value: boolean);
begin
  f_drawselect:=value;
  invalidate;
  end;
(*@\\\*)
(*@\\\0000001C2A*)
(*@/// Allow the scrollbar to act immidiatly *)
(* Idea taken from "The Delphi Magazine", Issue 40, December 1998, pg. 59 *)
(*@/// procedure TStringAlignGrid.WMHScroll(var Msg:TWMHScroll); *)
procedure TStringAlignGrid.WMHScroll(var Msg:TWMHScroll);
begin
  inherited;
  if f_dyn_scroll and (msg.scrollcode=sb_thumbtrack) then
    perform(wm_hscroll, makelong(sb_thumbposition, msg.pos), msg.scrollbar);
  end;
(*@\\\0000000301*)
(*@/// procedure TStringAlignGrid.WMVScroll(var Msg:TWMVScroll); *)
procedure TStringAlignGrid.WMVScroll(var Msg:TWMVScroll);
begin
  inherited;
  if f_dyn_scroll and (msg.scrollcode=sb_thumbtrack) then
    perform(wm_vscroll, makelong(sb_thumbposition, msg.pos), msg.scrollbar);
  end;
(*@\\\0000000501*)

(*@/// function TStringAlignGrid.VerticalScrollBarVisible: boolean; *)
function TStringAlignGrid.VerticalScrollBarVisible: boolean;
begin
  result:=ScrollBarVisible(self,true);
  end;
(*@\\\0000000301*)
(*@/// function TStringAlignGrid.HorizontalScrollBarVisible: boolean; *)
function TStringAlignGrid.HorizontalScrollBarVisible: boolean;
begin
  result:=ScrollBarVisible(self,false);
  end;
(*@\\\*)
(*@\\\*)

(*@/// Comboboxes *)
(*@/// ! function TStringAlignGrid.CellHasCombobox(ACol,ARow:longint):boolean; *)
function TStringAlignGrid.CellHasCombobox(ACol,ARow:longint):boolean;
begin
{   result:=(ACol+ARow) mod 3 =0; }
  result:=false;
  end;
(*@\\\0002000411000411*)
(*@\\\4000000148000148*)

(*@/// The real action - the draw of a cell *)
{ the draw of a cell, is called from the Paint Method of TCustomGrid }

(*@/// procedure TStringAlignGrid.DrawCellBack(ACol, ARow: Longint; var ARect: TRect; *)
procedure TStringAlignGrid.DrawCellBack(ACol, ARow: Longint; var ARect: TRect;
  AState: TGridDrawState);
var
  TopColor, BottomColor: TColor;
(*@/// procedure AdjustColors(Bevel: TPanelBevel); *)
procedure AdjustColors(Bevel: TPanelBevel);
begin
  TopColor := clBtnHighlight;
  if Bevel = bvLowered then TopColor := clBtnShadow;
  BottomColor := clBtnShadow;
  if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;
(*@\\\0000000401*)
begin
  self.canvas.font:=GetFontCellComplete(ACol,ARow);
  self.canvas.brush:=GetBrushCellComplete(ACol,ARow);
  Arect:=Arect;

  if f_drawselect and ((gdSelected in AState) and (not (gdFocused in AState) or
       ([goDrawFocusSelected, goRowSelect] * Options <> []))) then begin
    self.canvas.brush.color:=SelectedColorCell[Acol,ARow];
    self.canvas.font.color:=SelectedFontColorCell[Acol,ARow];
    end;

  if DefaultDrawing then begin
    self.canvas.fillrect(Arect);
    if gdFixed in Astate then begin
      if not (goFixedVertLine in Options) then
        inc(Arect.Bottom,GridLineWidth);
      if not (goFixedHorzLine in Options) then
        inc(Arect.Right,GridLineWidth);
      end
    else begin
      if not (goVertLine in Options) then
        inc(Arect.Bottom,GridLineWidth);
      if not (goHorzLine in Options) then
        inc(Arect.Right,GridLineWidth);
      end;

    SetBkMode(Canvas.Handle,transparent);
    end;
  end;
(*@\\\0000000715*)
(*@/// procedure TStringAlignGrid.DrawCellCombo(ACol, ARow: Longint; var ARect: TRect; *)
procedure TStringAlignGrid.DrawCellCombo(ACol, ARow: Longint; var ARect: TRect;
  AState: TGridDrawState);
var
  h,w,l: integer;
  r: TRect;
  active: boolean;
begin
  r:=rect(ARect.Right-ComboDropDownWidth,ARect.Top,ARect.right,ARect.bottom);
  Canvas.Brush.Color:=clBtnFace;
  Canvas.FillRect(r);
  Frame3D(self.Canvas,R,cl3dLight,cl3dDkShadow,1);
  Frame3D(self.Canvas,R,clBtnHighlight,clBtnShadow,1);
  h:=(ARect.bottom-ARect.top) div 2;
  w:=(ComboDropDownWidth div 2);
  l:=ARect.Right-ComboDropDownWidth;
  active:=self.enabled and EditCell[ACol,ARow];
  if active then begin
    Canvas.Brush.Color:=clBtnText;
    Canvas.Pen.Color:=clBtnText;
    end
  else begin
    Canvas.Brush.Color:=clBtnHighlight;
    Canvas.Pen.Color:=clBtnHighlight;
    Canvas.PolyGon([Point(l+w-4+2,ARect.Top+h-2+1),
                    Point(l+w+2+2,ARect.Top+h-2+1),
                    Point(l+w-1+2,ARect.Top+h+1+1)]);
    Canvas.Brush.Color:=clBtnShadow;
    Canvas.Pen.Color:=clBtnShadow;
    end;
  Canvas.PolyGon([Point(l+w-4,ARect.Top+h-2),
                  Point(l+w+2,ARect.Top+h-2),
                  Point(l+w-1,ARect.Top+h+1)]);
  Dec(ARect.right,ComboDropDownWidth);

  end;
(*@\\\*)
(*@/// procedure TStringAlignGrid.DrawCellText(ACol, ARow: Longint; var ARect: TRect; *)
procedure TStringAlignGrid.DrawCellText(ACol, ARow: Longint; var ARect: TRect;
  AState: TGridDrawState);
var
  s: string;
  flags: integer;
  _align: TMyAlign;
  _wordwrap: T_Wordwrap;
begin
  if DefaultDrawing then begin
    _align:=AlignCell[ACol,ARow];
    _wordwrap:=WordWrapCell[ACol,ARow];
    if assigned(f_ondrawcellpar) then
      f_ondrawcellpar(self,ACol,ARow,_align,_wordwrap);

    s:=Cells[ACol, ARow]+#0;
    InflateRect(Arect,-2,-2);
    flags:=0;
    case _align of
      alLeft,
      alDefault:flags:=dt_left;
      alCenter: flags:=dt_center;
      alRight:  flags:=dt_Right;
      end;
    case _wordwrap of
      ww_Wordwrap: flags:=flags or dt_wordbreak;
      ww_Ellipsis: flags:=flags or dt_end_ellipsis;
      ww_default :  ;
      end;
    flags:=flags or dt_noprefix;

    DrawText(canvas.handle,PChar(@s[1]),length(s)-1,Arect,flags);
    end;
  end;
(*@\\\0000002107*)
(*@/// procedure TStringAlignGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; *)
procedure TStringAlignGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  temp: TDrawCellEvent;
begin
  if (not (gdFixed in AState)) and CellHasCombobox(ACol,ARow) then
    DrawCellCombo(ACol,ARow,ARect,AState);
  { The Defaultdrawing is parsed in there }
  DrawCellBack(ACol,ARow,ARect,AState);
  DrawCellText(ACol,ARow,ARect,AState);
  { Delphi 1 doesn't understand a Assigned(OnDrawCell), but this way it
    works with all versions }
  temp:=OnDrawCell;
  if Assigned(temp) then OnDrawCell(Self, ACol, ARow, ARect, AState);
  end;
(*@\\\0000000623*)

(*@/// procedure TStringAlignGrid.CalcTextSize(ACol,ARow:longint; var Width,height: integer); *)
procedure TStringAlignGrid.CalcTextSize(ACol,ARow:longint; var Width,height: integer);
const
  min_width = 4;
  min_height = 4;
var
  s: string;
  flags: integer;
  ARect: TRect;
begin
  self.canvas.font:=GetFontCellComplete(ACol,ARow);
  s:=Cells[ACol, ARow]+#0;
  Arect:=rect(0,0,0,0);
  flags:=dt_noprefix or dt_calcrect or dt_right;
  DrawText(canvas.handle,PChar(@s[1]),length(s)-1,ARect,flags);
  height:=ARect.bottom-Arect.top+min_height;
  if height<=min_height then
    height:=0;
  width:=Arect.right-Arect.left+min_width;
  if width<=min_width then
    width:=0;
  end;
(*@\\\0000000501*)
(*@/// function TStringAlignGrid.textheight(ACol,ARow:longint):integer; *)
function TStringAlignGrid.textheight(ACol,ARow:longint):integer;
var
  w: integer;
begin
  CalcTextSize(ACol,ARow,w,result);
  end;
(*@\\\000000030D*)
(*@/// function TStringAlignGrid.textwidth(ACol,ARow:longint):integer; *)
function TStringAlignGrid.textwidth(ACol,ARow:longint):integer;
var
  h: integer;
begin
  CalcTextSize(ACol,ARow,result,h);
  end;
(*@\\\000000050D*)

(*@/// procedure TStringAlignGrid.Paint; *)
procedure TStringAlignGrid.Paint;
var
  R: TRect;
begin
  inherited Paint;
  if DefaultDrawing and not (csDesigning in ComponentState) and
    (ValidParentForm(Self).ActiveControl = Self) and
    ([goEditing, goAlwaysShowEditor] * Options <>
    [goEditing, goAlwaysShowEditor])
    and (not (goRowSelect in Options))
    and CellHasCombobox(Col,Row) then begin
    r:=CellRect(Col,Row);
    DrawFocusRect(Canvas.Handle,r);
    dec(r.right,ComboDropDownWidth);
    DrawFocusRect(Canvas.Handle,r);
    end;
  end;
(*@\\\0000000F01*)
(*@\\\0000000301*)
(*@\\\0000002001*)
(*@\\\0000001401*)
(*$ifdef delphi_ge_2 *) (*$warnings off *) (*$endif *)
end.

(*@/// Benutzte Routinen/properties von InplaceEdit *)
Benutzte Routinen/properties von InplaceEdit

ok  Create, Free
ok  FClickTime   -> WMLButtonDown berschreiben und nochmal implementieren
ok  UpdateContents   -> Callback ans Grid?
ok  SetGrid          -> unn”tig, parent macht dasselbe
ok  UpdateLoc,Move,Hide  -> WMPosChanged!
ok  Font     -> CMFontChanged
ok  Text     -> UpdateText_
ok  SelectAll, Deselect  -> EMSetSel
  PostMessage(wm_char) -> einfach weiterreichen

grid.wmkillfocus: focused(inplacedit.handle)
grid.setfocus: focused(inplacedit.handle)
grid.CMCancelMode      -> einfach weiterreichen
(*@\\\0000000A25*)
(*@\\\0001000011000E01*)
