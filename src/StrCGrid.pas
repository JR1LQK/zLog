{
===============================================================================
�F�E�����w��t��TStringGrid  TStrColGrid
                                      1996-1997 (C) �l�n�|(NiftyServe:QZE03067)
                                      1997.08.02 �쐬
                                      Version2.0

-------------------------------------------------------------------------------
1.0 -> 2.0 �̉��ϓ_
�@�ȉ��̃v���p�e�B�^���\�b�h��ǉ��B
    FocusDraw: boolean
    FontCount: integer
    FocusDraw: boolean
    CellFonts[ACol, ARow: integer]: integer
    proceudre AddFont(AFont: TFont);
    proceudre DeleteFont(AIndex: integer);
-------------------------------------------------------------------------------

�ǉ��v���p�e�B

  Alignment: TAlignment;
    �O���b�h�S�̂̕����\���ʒu�B
  FixedAlignment: TAlignment;
    �Œ�Z���̕����\���ʒu�B
  FocusDraw: boolean
    �t�H�[�J�X�������Ă��A�I���̕\����Ԃ�ۂB
  FontCount: integer
    �o�^����Ă���t�H���g���B
  FocusDraw: boolean
    �t�H�[�J�X���������ꍇ�ł��I��͈͕\�����s�����ۂ��B

  CellAlignments[ACol, ARow: integer]: TAlignment
    �Z���ŗL�̕����\���ʒu�B
  CellFontColors[ACol, ARow: integer]: TColor
    �Z���ŗL�̕����F�B
  CellFontWidths[ACol, ARow: integer]: integer
    �Z���ŗL�̕��������B
  CellColors[ACol, ARow: integer]: TColor
    �Z���ŗL�̔w�i�F�B
  CellBrushEnabled[ACol, ARow: integer]: boolean;
    �Z���ŗL�̃u���V�g�p�^���g�p�t���O�B
  CellBrushStyles[ACol, ARow: integer]: TBrushStyle
    �Z���ŗL�̃u���V�X�^�C���B
  CellBrushColors[ACol, ARow: integer]: TColor
    �Z���ŗL�̃u���V�J���[�B
  CellFonts[ACol, ARow: integer]: integer
    �Z���Ŏg�p����t�H���g�̃C���f�b�N�X�ԍ�


�ǉ����\�b�h

  procedure ClearAllCellParams;
    �S�p�����[�^�����B
  function GetDefaultCellParams(ACol, ARow: integer): TCellDrawParams;
    �f�t�H���g�̃Z���p�����[�^���擾�B
  function GetCellParams(ACol, ARow: integer): TCellDrawParams;
    �Z���p�����[�^���ꊇ�擾�B
  procedure SetCellParams(ACol, ARow: integer; AValue: TCellDrawParams);
    �Z���p�����[�^���ꊇ�ݒ�B
  proceudre AddFont(AFont: TFont);
    �t�H���g��ǉ��B
  proceudre DeleteFont(AIndex: integer);
    �t�H���g���폜�B
===============================================================================
}
unit StrCGrid;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids;

type
  // �`��p�����[�^ ���R�[�h
  TCellDrawParams = record
    Col, Row: integer;
    Alignment: TAlignment;
    FontColor: TColor;
    FontWidth: integer;
    BackColor: TColor;
    BrushEnabled: boolean;
    BrushStyle: TBrushStyle;
    BrushColor: TColor;
    FontIndex: integer;
  end;
  // �`��p�����[�^ ���R�[�h�̃|�C���^
  PCellDrawParams = ^TCellDrawParams;

  // �R���|�[�l���g��`
  TStrColGrid = class(TStringGrid)
  private
    FParamsList: TList;
    FFontList: TStringList;

    FAlignment: TAlignment;
    FFixedAlignment: TAlignment;
    FFocusDraw: boolean;
    FCacheCol, FCacheRow, FCacheIndex: integer; // �O��Q�ƃp�����[�^�ʒu
    FsvPen: TPen;
    FsvBrush: TBrush;
    FsvFont: TFont;
    procedure CheckColRowRange(ACol, ARow: integer);
    function GetFontCount: integer;
    function GetParamPointer(ACol, ARow: integer; AAlloc: boolean): PCellDrawParams;
    function GetCellAlignments(ACol, ARow: integer): TAlignment;
    procedure SetCellAlignments(ACol, ARow: integer; AValue: TAlignment);
    function GetCellFontColors(ACol, ARow: integer): TColor;
    procedure SetCellFontColors(ACol, ARow: integer; AValue: TColor);
    function GetCellFontWidths(ACol, ARow: integer): integer;
    procedure SetCellFontWidths(ACol, ARow: integer; AValue: integer);
    function GetCellColors(ACol, ARow: integer): TColor;
    procedure SetCellColors(ACol, ARow: integer; AValue: TColor);
    function GetCellBrushEnabled(ACol, ARow: integer): boolean;
    procedure SetCellBrushEnabled(ACol, ARow: integer; AValue: boolean);
    function GetCellBrushStyles(ACol, ARow: integer): TBrushStyle;
    procedure SetCellBrushStyles(ACol, ARow: integer; AValue: TBrushStyle);
    function GetCellBrushColors(ACol, ARow: integer): TColor;
    procedure SetCellBrushColors(ACol, ARow: integer; AValue: TColor);
    function GetCellFonts(ACol, ARow: integer): integer;
    procedure SetCellFonts(ACol, ARow: integer; AIndex: integer);
  protected
    procedure Loaded; override;
    procedure DrawCell(ACol, ARow: longint; ARect: TRect;
      AState: TGridDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // ���\�b�h
    procedure ClearAllCellParams;
    function GetDefaultCellParams(ACol, ARow: integer): TCellDrawParams;
    function GetCellParams(ACol, ARow: integer): TCellDrawParams;
    procedure SetCellParams(AValue: TCellDrawParams);
    procedure AddFont(AFont: TFont);
    procedure DeleteFont(AIndex: integer);

    // ���s���v���p�e�B
    property FontCount: integer
      read GetFontCount;
    property CellAlignments[ACol, ARow: integer]: TAlignment
      read GetCellAlignments write SetCellAlignments;
    property CellFontColors[ACol, ARow: integer]: TColor
      read GetCellFontColors write SetCellFontColors;
    property CellFontWidths[ACol, ARow: integer]: integer
      read GetCellFontWidths write SetCellFontWidths;
    property CellColors[ACol, ARow: integer]: TColor
      read GetCellColors write SetCellColors;
    property CellBrushEnabled[ACol, ARow: integer]: boolean
      read GetCellBrushEnabled write SetCellBrushEnabled;
    property CellBrushStyles[ACol, ARow: integer]: TBrushStyle
      read GetCellBrushStyles write SetCellBrushStyles;
    property CellBrushColors[ACol, ARow: integer]: TColor
      read GetCellBrushColors write SetCellBrushColors;
    property CellFonts[ACol, ARow: integer]: integer
      read GetCellFonts write SetCellFonts;

  published
    // �݌v���v���p�e�B
    property Alignment: TAlignment
      read FAlignment write FAlignment default taLeftJustify;
    property FixedAlignment: TAlignment
      read FFixedAlignment write FFixedAlignment default taLeftJustify;
    property FocusDraw: boolean
      read FFocusDraw write FFocusDraw default True;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TStrColGrid]);
end;


//-----------------------------------------------------------------------------
// �R���X�g���N�^
//-----------------------------------------------------------------------------
constructor TStrColGrid.Create(AOwner: TComponent);
begin
  inherited;
  DefaultDrawing := False;
  FAlignment := taLeftJustify;
  FFixedAlignment := taLeftJustify;
  FFocusDraw := True;
  if not (csDesigning in ComponentState) then
  begin
    FParamsList := TList.Create;
    FFontList := TStringList.Create;
    FsvPen := TPen.Create;
    FsvBrush := TBrush.Create;
    FsvFont := TFont.Create;
    FCacheCol := -1;
    FCacheRow := -1;
    FCacheIndex := -1;
  end
end;


//-----------------------------------------------------------------------------
// �f�X�g���N�^
//-----------------------------------------------------------------------------
destructor TStrColGrid.Destroy;
var
  i: integer;
begin
  if not (csDesigning in ComponentState) then
  begin
    FsvPen.Free;
    FsvBrush.Free;
    FsvFont.Free;

    ClearAllCellParams;
    FParamsList.Free;

    for i := 0 to FFontList.Count - 1 do
      TFont(FFontList.Objects[i]).Free;
    FFontList.Free;
  end;
  inherited;
end;


//-----------------------------------------------------------------------------
// ������
//-----------------------------------------------------------------------------
procedure TStrColGrid.Loaded;
var
  i: integer;
  ColParams: TList;
begin
  inherited;
  // �p�����[�^���X�g �����񐔕� ������
  if not (csDesigning in ComponentState) then
  begin
    Canvas.Font.Assign(Font);
    for i := 1 to ColCount do
    begin
      ColParams := TList.Create;
      FParamsList.Add(pointer(ColParams));
    end;
  end;
end;


//-----------------------------------------------------------------------------
// �S�p�����[�^�폜
//-----------------------------------------------------------------------------
procedure TStrColGrid.ClearAllCellParams;
var
  i, j, c1, c2: integer;
  ColParam: TList;
  pPrm: PCellDrawParams;
begin
  c1 := FParamsList.Count;
  for i := 1 to c1 do
  begin
    ColParam := TList(FParamsList.Items[i - 1]);
    c2 := ColParam.Count;
    for j := 1 to c2 do
    begin
      pPrm := ColParam.Items[j - 1];
      FreeMem(pPrm, sizeof(TCellDrawParams));
    end;
    ColParam.Free;
  end;
  FCacheCol := -1;
  FCacheRow := -1;
end;


//-----------------------------------------------------------------------------
// �f�t�H���g�p�����[�^�擾
//-----------------------------------------------------------------------------
function TStrColGrid.GetDefaultCellParams(ACol, ARow: integer): TCellDrawParams;
begin

  with Result do
  begin
    Col := ACol;
    Row := ARow;
    Alignment := FAlignment;
    FontColor := Font.Color;
    FontWidth := 1;
    if (ACol < FixedCols) or (ARow < FixedRows) then
      BackColor := FixedColor
    else
      BackColor := Self.Color;
    BrushEnabled := False;
    BrushStyle := bsClear;
    BrushColor := Self.Color;
    FontIndex := -1;
  end;

end;


//-----------------------------------------------------------------------------
// �p�����[�^�ʒu�擾�A�m��
//-----------------------------------------------------------------------------
function TStrColGrid.GetParamPointer(ACol, ARow: integer; AAlloc: boolean): PCellDrawParams;
var
  i, n: integer;
  pPrm: PCellDrawParams;
  ColParam: TList;
begin

  // �p�����[�^���X�g�ǉ�
  if ColCount > FParamsList.Count then
  begin
    n := FParamsList.Count;
    for i := n to ColCount - 1 do
    begin
      ColParam := TList.Create;
      FParamsList.Add(pointer(ColParam));
    end;
  end
  // �p�����[�^���X�g�폜
  else if ColCount > FParamsList.Count then
  begin
    ColParam := TList(FParamsList.Items[FParamsList.Count - 1]);
    n := ColParam.Count;
    for i := 1 to n do
    begin
      pPrm := ColParam.Items[i - 1];
      FreeMem(pPrm, sizeof(TCellDrawParams));
    end;
    ColParam.Free;
  end;

  // �����ʒu������
  ColParam := TList(FParamsList[ACol]);
  // �L���b�V���Ɠ����Ȃ�ꔭ�ŌĂяo��
  if (FCacheCol = ACol) and (FCacheRow = ARow) then
  begin
    Result := ColParam.Items[FCacheIndex];
    exit;
  end
  // �L���b�V���ƈ�����猟��
  else begin
    for i := 0 to (ColParam.Count - 1) do
    begin
      pPrm := ColParam.Items[i];
      if pPrm^.Row = ARow then
      begin
        Result := pPrm;
        FCacheCol := ACol;
        FCacheRow := ARow;
        FCacheIndex := i;
        exit;
      end;
    end;
  end;
  // ������Ȃ���
  // �������m��
  if AAlloc then
  begin
    GetMem(pPrm, sizeof(TCellDrawParams));
    pPrm^ := GetDefaultCellParams(ACol, ARow);
    ColParam.Add(pPrm);
    FCacheCol := ACol;
    FCacheRow := ARow;
    FCacheIndex := ColParam.Count - 1;
    if FCacheIndex < 0 then FCacheIndex := 0;
  end
  // �������s�p
  else begin
    pPrm := nil;
  end;
  Result := pPrm;
end;


//-----------------------------------------------------------------------------
// �p�����[�^�ꊇ�擾�p
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellParams(ACol, ARow: integer): TCellDrawParams;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := GetDefaultCellParams(ACol, ARow)
  else
    Result := pPrm^;
end;


//-----------------------------------------------------------------------------
// �p�����[�^�ꊇ�ݒ�p
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellParams(AValue: TCellDrawParams);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(AValue.Col, AValue.Row);
  // �p�����[�^�������݈ʒu�擾�A��������
  pPrm := GetParamPointer(AValue.Col, AValue.Row, True);
  pPrm^ := AValue;
end;


//-----------------------------------------------------------------------------
// �t�H���g�ǉ�
//-----------------------------------------------------------------------------
procedure TStrColGrid.AddFont(AFont: TFont);
var
  f: TFont;
begin
  f := TFont.Create;
  f.Assign(AFont);
  FFontList.AddObject('0', f);
end;


//-----------------------------------------------------------------------------
// �t�H���g�폜
//-----------------------------------------------------------------------------
procedure TStrColGrid.DeleteFont(AIndex: integer);
begin
  if (AIndex < 0) or (AIndex >= FFontList.Count) then
    raise ERangeError.Create('���ޯ�����͈͂𒴂��܂����B');
  if FFontList[AIndex] <> '0' then
    raise Exception.Create('�g�p����̫�Ă��폜���悤�Ƃ��܂����B');
  TFont(FFontList.Objects[AIndex]).Free;
  FFontList.Delete(AIndex);
end;


//-----------------------------------------------------------------------------
// ��s�ʒu����
//-----------------------------------------------------------------------------
procedure TStrColGrid.CheckColRowRange(ACol, ARow: integer);
begin
  if (ACol < 0) or (ARow < 0) or (ColCount < ACol) or (RowCount < ARow) then
  begin
    raise ERangeError.Create('�وʒu����د�ނ͈̔͂𒴂��܂����B');
  end;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�t�H���g���ǂݏo��
//-----------------------------------------------------------------------------
function TStrColGrid.GetFontCount: integer;
begin
  Result := FFontList.Count;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F������\���ʒu�ǂݏo��
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellAlignments(ACol, ARow: integer): TAlignment;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := FAlignment
  else
    Result := pPrm^.Alignment;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F������\���ʒu�ݒ�
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellAlignments(ACol, ARow: integer; AValue: TAlignment);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�������݈ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.Alignment := AValue;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�t�H���g�F�ǂݏo��
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellFontColors(ACol, ARow: integer): TColor;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := Font.Color
  else
    Result := pPrm^.FontColor;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�t�H���g�F�ݒ�
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellFontColors(ACol, ARow: integer; AValue: TColor);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�������݈ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.FontColor := AValue;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�t�H���g���ǂݏo��
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellFontWidths(ACol, ARow: integer): integer;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := 1
  else
    Result := pPrm^.FontWidth;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�t�H���g���ݒ�
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellFontWidths(ACol, ARow: integer; AValue: integer);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�������݈ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.FontWidth := AValue;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�Z���F�ǂݏo��
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellColors(ACol, ARow: integer): TColor;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := Color
  else
    Result := pPrm^.BackColor;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�Z���F�ݒ�
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellColors(ACol, ARow: integer; AValue: TColor);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�������݈ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.BackColor := AValue;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�Z���u���V�g�p�^�s�ǂݏo��
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellBrushEnabled(ACol, ARow: integer): boolean;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := False
  else
    Result := pPrm^.BrushEnabled;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�Z���u���V�g�p�^�s�ݒ�
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellBrushEnabled(ACol, ARow: integer; AValue: boolean);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�������݈ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.BrushEnabled := AValue;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�Z���u���V�X�^�C���ǂݏo��
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellBrushStyles(ACol, ARow: integer): TBrushStyle;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := Canvas.Brush.Style
  else
    Result := pPrm^.BrushStyle;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�Z���u���V�X�^�C���ݒ�
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellBrushStyles(ACol, ARow: integer; AValue: TBrushStyle);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�������݈ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.BrushStyle := AValue;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�Z���u���V�F�ǂݏo��
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellBrushColors(ACol, ARow: integer): TColor;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := Color
  else
    Result := pPrm^.BrushColor;
end;


//-----------------------------------------------------------------------------
// �v���p�e�B�F�Z���u���V�F�ݒ�
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellBrushColors(ACol, ARow: integer; AValue: TColor);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�������݈ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.BrushColor := AValue;
end;

//-----------------------------------------------------------------------------
// �v���p�e�B�F�Z���t�H���g�ԍ��ǂݏo��
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellFonts(ACol, ARow: integer): integer;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // �p�����[�^�ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := 0
  else
    Result := pPrm^.FontIndex;
end;

//-----------------------------------------------------------------------------
// �v���p�e�B�F�Z���t�H���g�ԍ��ݒ�
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellFonts(ACol, ARow: integer; AIndex: integer);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);

  if (AIndex < -1) or (AIndex >= FFontList.Count) then
    raise ERangeError.Create('���ޯ�����͈͂𒴂��܂����B');

  // �p�����[�^�������݈ʒu�擾
  pPrm := GetParamPointer(ACol, ARow, True);
  // ���ݎg�p���Ă���t�H���g�̎g�p�񐔂��|�P
  if pPrm^.FontIndex >= 0 then
    FFontList[pPrm^.FontIndex] := IntToStr(
        StrToInt(FFontList[pPrm^.FontIndex]) - 1
    );
  // �V�K�Ɏg�p����t�H���g�̎g�p�񐔂��{�P
  if AIndex >= 0 then
    FFontList[AIndex] := IntToStr(
        StrToInt(FFontList[AIndex]) + 1
    );

  pPrm^.FontIndex := AIndex;
  if AIndex = -1 then
    pPrm^.FontColor := Font.Color
  else
    pPrm^.FontColor := TFont(FFontList.Objects[AIndex]).Color;
end;


//-----------------------------------------------------------------------------
// �Z���`�揈��
//-----------------------------------------------------------------------------
procedure TStrColGrid.DrawCell(ACol, ARow: longint; ARect: TRect;
      AState: TGridDrawState);

    // �Œ�Z���n�C���C�g�`��
    procedure DrawFixed;
    begin
      if (AState = [gdFixed]) then
      begin
        Canvas.Pen.Style := psSolid;
        Canvas.Pen.Mode := pmCopy;
        with ARect do begin
          Canvas.Pen.Color := clBtnHighlight;
          Canvas.MoveTo(Right - 1, Top);
          Canvas.LineTo(Left, Top);
          Canvas.LineTo(Left, Bottom - 1);
          Canvas.Pen.Color := clGray;
          Canvas.LineTo(Right - 1, Bottom - 1);
          Canvas.LineTo(Right - 1, Top);
        end;
      end;
    end;

var
  i, x, y: integer;
  FontWidth: integer;
  Arg: TAlignment;
  pPrm: PCellDrawParams;
begin

  // �݌v���ƃf�t�H���g�`��w�莞�́A�f�t�H���g�`��
  if (csDesigning in ComponentState) or (DefaultDrawing) then
  begin
    inherited;
    if csDesigning in ComponentState then DrawFixed;
    exit;
  end;

  // ������
  x := 0;
  FontWidth := 1;
  // �`��p�����[�^�擾
  pPrm := GetParamPointer(ACol, ARow, False);
  // �L�����o�X�̏�Ԃ�ۑ�
  FsvPen.Assign(Canvas.Pen);
  FsvBrush.Assign(Canvas.Brush);
  FsvFont.Assign(Canvas.Font);
  // �`�惂�[�h�ݒ�
  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Mode := pmCopy;
  Canvas.Font.Assign(Font);

  // �t�H���g���蓖�āi-1�Ȃ�f�t�H���g�t�H���g�A0�ȏ�͎w��t�H���g�j
  if pPrm <> nil then
  begin
    FontWidth := pPrm^.FontWidth;
    if pPrm^.FontIndex >= 0 then
      Canvas.Font.Assign(TFont(FFontList.Objects[pPrm^.FontIndex]));
  end;

  // ������`��ʒu����i�Œ�Z���^�ʏ�Z���j
  if AState = [gdFixed] then
    Arg := FFixedAlignment
  else
    Arg := FAlignment;

  // �Œ�Z���`��
  if (pPrm = nil) and (AState = [gdFixed]) then
  begin
    Canvas.Brush.Color := FixedColor;
    Canvas.FillRect(ARect);
  end
  // �ʏ�Z���`��
  else begin
    // �I�𒆂̃Z���͔��]�\��
        // �t�H�[�J�X�����邩�A�Ȃ��Ƃ���FocuseDraw��True���A
    if  ((Focused) or ((not Focused) and (FFocusDraw))) and
        // �I������Ă��邩
        (gdSelected in AState) and
        (
            // �\������ݒ�ɂȂ��Ă��邩
            //((goDrawFocusSelected in Options) and (not (gdFocused in AState))) or
            (goDrawFocusSelected in Options) or
            ((not (goDrawFocusSelected in Options)) and (not (gdFocused in AState))) or
            // �܂��͍s�I����Ԃ�
            (goRowSelect in Options)
        ) then
    begin
      Canvas.Brush.Color := clHighlight;
      Canvas.FillRect(ARect);
      Canvas.Font.Color := clHighlightText;
    end
    // �p�����[�^���ݒ肳��Ă���ꍇ
    else if pPrm <> nil then
    begin
      // �����\���ʒu
      Arg := pPrm^.Alignment;
      // �w�i
      Canvas.Brush.Style := bsSolid;
      Canvas.Brush.Color := pPrm^.BackColor;
      Canvas.FillRect(ARect);
      // �u���V
      if pPrm^.BrushEnabled then
      begin
        Canvas.Brush.Color := pPrm^.BrushColor;
        Canvas.Pen.Color := pPrm^.BrushColor;
        Canvas.Brush.Style := pPrm^.BrushStyle;
        Canvas.Pen.Width := 0;
        Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
      end;
      // �t�H���g
      Canvas.Font.Color := pPrm^.FontColor;
    end
    // �p�����[�^�����ݒ�̏ꍇ
    else begin
      Canvas.FillRect(ARect);
    end;
  end;

  // ������`��
  if Cells[ACol, ARow] <> '' then
  begin
    case Arg of
      taLeftJustify:  x := ARect.Left + 2;
      taRightJustify: x := ARect.Left + (ARect.Right - ARect.Left) -
                        Canvas.TextWidth(Cells[ACol, ARow]) - 2;
      taCenter:       x := ARect.Left + ((ARect.Right - ARect.Left) -
                        Canvas.TextWidth(Cells[ACol, ARow])) div 2;
    end;
    y := ARect.Top + 2;
    Canvas.Brush.Style := bsClear;
    for i := 0 to FontWidth - 1 do
    begin
      Canvas.TextRect(ARect, x + i, y, Cells[ACol, ARow]);
    end;
  end;

  // �L�����o�X�̏�Ԃ����ɖ߂�
  Canvas.Pen.Assign(FsvPen);
  Canvas.Brush.Assign(FsvBrush);
  Canvas.Font.Assign(FsvFont);

  // �t�H�[�J�X�g�`��
  if (Focused) and (gdFocused in AState) then
    Canvas.DrawFocusRect(ARect);

  // �Œ�Z���n�C���C�g�`��
  DrawFixed;

end;


end.
