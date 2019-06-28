{
===============================================================================
色・書式指定付きTStringGrid  TStrColGrid
                                      1996-1997 (C) ＭＯ－(NiftyServe:QZE03067)
                                      1997.08.02 作成
                                      Version2.0

-------------------------------------------------------------------------------
1.0 -> 2.0 の改変点
　以下のプロパティ／メソッドを追加。
    FocusDraw: boolean
    FontCount: integer
    FocusDraw: boolean
    CellFonts[ACol, ARow: integer]: integer
    proceudre AddFont(AFont: TFont);
    proceudre DeleteFont(AIndex: integer);
-------------------------------------------------------------------------------

追加プロパティ

  Alignment: TAlignment;
    グリッド全体の文字表示位置。
  FixedAlignment: TAlignment;
    固定セルの文字表示位置。
  FocusDraw: boolean
    フォーカスを失っても、選択の表示常態を保つ。
  FontCount: integer
    登録されているフォント数。
  FocusDraw: boolean
    フォーカスを失った場合でも選択範囲表示を行うか否か。

  CellAlignments[ACol, ARow: integer]: TAlignment
    セル固有の文字表示位置。
  CellFontColors[ACol, ARow: integer]: TColor
    セル固有の文字色。
  CellFontWidths[ACol, ARow: integer]: integer
    セル固有の文字太さ。
  CellColors[ACol, ARow: integer]: TColor
    セル固有の背景色。
  CellBrushEnabled[ACol, ARow: integer]: boolean;
    セル固有のブラシ使用／未使用フラグ。
  CellBrushStyles[ACol, ARow: integer]: TBrushStyle
    セル固有のブラシスタイル。
  CellBrushColors[ACol, ARow: integer]: TColor
    セル固有のブラシカラー。
  CellFonts[ACol, ARow: integer]: integer
    セルで使用するフォントのインデックス番号


追加メソッド

  procedure ClearAllCellParams;
    全パラメータ消去。
  function GetDefaultCellParams(ACol, ARow: integer): TCellDrawParams;
    デフォルトのセルパラメータを取得。
  function GetCellParams(ACol, ARow: integer): TCellDrawParams;
    セルパラメータを一括取得。
  procedure SetCellParams(ACol, ARow: integer; AValue: TCellDrawParams);
    セルパラメータを一括設定。
  proceudre AddFont(AFont: TFont);
    フォントを追加。
  proceudre DeleteFont(AIndex: integer);
    フォントを削除。
===============================================================================
}
unit StrCGrid;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids;

type
  // 描画パラメータ レコード
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
  // 描画パラメータ レコードのポインタ
  PCellDrawParams = ^TCellDrawParams;

  // コンポーネント定義
  TStrColGrid = class(TStringGrid)
  private
    FParamsList: TList;
    FFontList: TStringList;

    FAlignment: TAlignment;
    FFixedAlignment: TAlignment;
    FFocusDraw: boolean;
    FCacheCol, FCacheRow, FCacheIndex: integer; // 前回参照パラメータ位置
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

    // メソッド
    procedure ClearAllCellParams;
    function GetDefaultCellParams(ACol, ARow: integer): TCellDrawParams;
    function GetCellParams(ACol, ARow: integer): TCellDrawParams;
    procedure SetCellParams(AValue: TCellDrawParams);
    procedure AddFont(AFont: TFont);
    procedure DeleteFont(AIndex: integer);

    // 実行時プロパティ
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
    // 設計時プロパティ
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
// コンストラクタ
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
// デストラクタ
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
// 初期化
//-----------------------------------------------------------------------------
procedure TStrColGrid.Loaded;
var
  i: integer;
  ColParams: TList;
begin
  inherited;
  // パラメータリスト 初期列数分 初期化
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
// 全パラメータ削除
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
// デフォルトパラメータ取得
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
// パラメータ位置取得、確保
//-----------------------------------------------------------------------------
function TStrColGrid.GetParamPointer(ACol, ARow: integer; AAlloc: boolean): PCellDrawParams;
var
  i, n: integer;
  pPrm: PCellDrawParams;
  ColParam: TList;
begin

  // パラメータリスト追加
  if ColCount > FParamsList.Count then
  begin
    n := FParamsList.Count;
    for i := n to ColCount - 1 do
    begin
      ColParam := TList.Create;
      FParamsList.Add(pointer(ColParam));
    end;
  end
  // パラメータリスト削除
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

  // 書式位置を検索
  ColParam := TList(FParamsList[ACol]);
  // キャッシュと同じなら一発で呼び出し
  if (FCacheCol = ACol) and (FCacheRow = ARow) then
  begin
    Result := ColParam.Items[FCacheIndex];
    exit;
  end
  // キャッシュと違ったら検索
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
  // 見つからない時
  // メモリ確保
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
  // メモリ不用
  else begin
    pPrm := nil;
  end;
  Result := pPrm;
end;


//-----------------------------------------------------------------------------
// パラメータ一括取得用
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellParams(ACol, ARow: integer): TCellDrawParams;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ位置取得
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := GetDefaultCellParams(ACol, ARow)
  else
    Result := pPrm^;
end;


//-----------------------------------------------------------------------------
// パラメータ一括設定用
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellParams(AValue: TCellDrawParams);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(AValue.Col, AValue.Row);
  // パラメータ書き込み位置取得、書き込み
  pPrm := GetParamPointer(AValue.Col, AValue.Row, True);
  pPrm^ := AValue;
end;


//-----------------------------------------------------------------------------
// フォント追加
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
// フォント削除
//-----------------------------------------------------------------------------
procedure TStrColGrid.DeleteFont(AIndex: integer);
begin
  if (AIndex < 0) or (AIndex >= FFontList.Count) then
    raise ERangeError.Create('ｲﾝﾃﾞｯｸｽが範囲を超えました。');
  if FFontList[AIndex] <> '0' then
    raise Exception.Create('使用中のﾌｫﾝﾄを削除しようとしました。');
  TFont(FFontList.Objects[AIndex]).Free;
  FFontList.Delete(AIndex);
end;


//-----------------------------------------------------------------------------
// 列行位置判定
//-----------------------------------------------------------------------------
procedure TStrColGrid.CheckColRowRange(ACol, ARow: integer);
begin
  if (ACol < 0) or (ARow < 0) or (ColCount < ACol) or (RowCount < ARow) then
  begin
    raise ERangeError.Create('ｾﾙ位置がｸﾞﾘｯﾄﾞの範囲を超えました。');
  end;
end;


//-----------------------------------------------------------------------------
// プロパティ：フォント数読み出し
//-----------------------------------------------------------------------------
function TStrColGrid.GetFontCount: integer;
begin
  Result := FFontList.Count;
end;


//-----------------------------------------------------------------------------
// プロパティ：文字列表示位置読み出し
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellAlignments(ACol, ARow: integer): TAlignment;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ位置取得
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := FAlignment
  else
    Result := pPrm^.Alignment;
end;


//-----------------------------------------------------------------------------
// プロパティ：文字列表示位置設定
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellAlignments(ACol, ARow: integer; AValue: TAlignment);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ書き込み位置取得
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.Alignment := AValue;
end;


//-----------------------------------------------------------------------------
// プロパティ：フォント色読み出し
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellFontColors(ACol, ARow: integer): TColor;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ位置取得
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := Font.Color
  else
    Result := pPrm^.FontColor;
end;


//-----------------------------------------------------------------------------
// プロパティ：フォント色設定
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellFontColors(ACol, ARow: integer; AValue: TColor);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ書き込み位置取得
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.FontColor := AValue;
end;


//-----------------------------------------------------------------------------
// プロパティ：フォント幅読み出し
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellFontWidths(ACol, ARow: integer): integer;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ位置取得
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := 1
  else
    Result := pPrm^.FontWidth;
end;


//-----------------------------------------------------------------------------
// プロパティ：フォント幅設定
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellFontWidths(ACol, ARow: integer; AValue: integer);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ書き込み位置取得
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.FontWidth := AValue;
end;


//-----------------------------------------------------------------------------
// プロパティ：セル色読み出し
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellColors(ACol, ARow: integer): TColor;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ位置取得
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := Color
  else
    Result := pPrm^.BackColor;
end;


//-----------------------------------------------------------------------------
// プロパティ：セル色設定
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellColors(ACol, ARow: integer; AValue: TColor);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ書き込み位置取得
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.BackColor := AValue;
end;


//-----------------------------------------------------------------------------
// プロパティ：セルブラシ使用可／不可読み出し
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellBrushEnabled(ACol, ARow: integer): boolean;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ位置取得
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := False
  else
    Result := pPrm^.BrushEnabled;
end;


//-----------------------------------------------------------------------------
// プロパティ：セルブラシ使用可／不可設定
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellBrushEnabled(ACol, ARow: integer; AValue: boolean);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ書き込み位置取得
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.BrushEnabled := AValue;
end;


//-----------------------------------------------------------------------------
// プロパティ：セルブラシスタイル読み出し
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellBrushStyles(ACol, ARow: integer): TBrushStyle;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ位置取得
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := Canvas.Brush.Style
  else
    Result := pPrm^.BrushStyle;
end;


//-----------------------------------------------------------------------------
// プロパティ：セルブラシスタイル設定
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellBrushStyles(ACol, ARow: integer; AValue: TBrushStyle);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ書き込み位置取得
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.BrushStyle := AValue;
end;


//-----------------------------------------------------------------------------
// プロパティ：セルブラシ色読み出し
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellBrushColors(ACol, ARow: integer): TColor;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ位置取得
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := Color
  else
    Result := pPrm^.BrushColor;
end;


//-----------------------------------------------------------------------------
// プロパティ：セルブラシ色設定
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellBrushColors(ACol, ARow: integer; AValue: TColor);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ書き込み位置取得
  pPrm := GetParamPointer(ACol, ARow, True);
  pPrm^.BrushColor := AValue;
end;

//-----------------------------------------------------------------------------
// プロパティ：セルフォント番号読み出し
//-----------------------------------------------------------------------------
function TStrColGrid.GetCellFonts(ACol, ARow: integer): integer;
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);
  // パラメータ位置取得
  pPrm := GetParamPointer(ACol, ARow, False);
  if pPrm = nil then
    Result := 0
  else
    Result := pPrm^.FontIndex;
end;

//-----------------------------------------------------------------------------
// プロパティ：セルフォント番号設定
//-----------------------------------------------------------------------------
procedure TStrColGrid.SetCellFonts(ACol, ARow: integer; AIndex: integer);
var
  pPrm: PCellDrawParams;
begin
  CheckColRowRange(ACol, ARow);

  if (AIndex < -1) or (AIndex >= FFontList.Count) then
    raise ERangeError.Create('ｲﾝﾃﾞｯｸｽが範囲を超えました。');

  // パラメータ書き込み位置取得
  pPrm := GetParamPointer(ACol, ARow, True);
  // 現在使用しているフォントの使用回数を－１
  if pPrm^.FontIndex >= 0 then
    FFontList[pPrm^.FontIndex] := IntToStr(
        StrToInt(FFontList[pPrm^.FontIndex]) - 1
    );
  // 新規に使用するフォントの使用回数を＋１
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
// セル描画処理
//-----------------------------------------------------------------------------
procedure TStrColGrid.DrawCell(ACol, ARow: longint; ARect: TRect;
      AState: TGridDrawState);

    // 固定セルハイライト描画
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

  // 設計時とデフォルト描画指定時は、デフォルト描画
  if (csDesigning in ComponentState) or (DefaultDrawing) then
  begin
    inherited;
    if csDesigning in ComponentState then DrawFixed;
    exit;
  end;

  // 初期化
  x := 0;
  FontWidth := 1;
  // 描画パラメータ取得
  pPrm := GetParamPointer(ACol, ARow, False);
  // キャンバスの状態を保存
  FsvPen.Assign(Canvas.Pen);
  FsvBrush.Assign(Canvas.Brush);
  FsvFont.Assign(Canvas.Font);
  // 描画モード設定
  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Mode := pmCopy;
  Canvas.Font.Assign(Font);

  // フォント割り当て（-1ならデフォルトフォント、0以上は指定フォント）
  if pPrm <> nil then
  begin
    FontWidth := pPrm^.FontWidth;
    if pPrm^.FontIndex >= 0 then
      Canvas.Font.Assign(TFont(FFontList.Objects[pPrm^.FontIndex]));
  end;

  // 文字列描画位置判定（固定セル／通常セル）
  if AState = [gdFixed] then
    Arg := FFixedAlignment
  else
    Arg := FAlignment;

  // 固定セル描画
  if (pPrm = nil) and (AState = [gdFixed]) then
  begin
    Canvas.Brush.Color := FixedColor;
    Canvas.FillRect(ARect);
  end
  // 通常セル描画
  else begin
    // 選択中のセルは反転表示
        // フォーカスがあるか、ないときはFocuseDrawがTrueか、
    if  ((Focused) or ((not Focused) and (FFocusDraw))) and
        // 選択されているか
        (gdSelected in AState) and
        (
            // 表示する設定になっているか
            //((goDrawFocusSelected in Options) and (not (gdFocused in AState))) or
            (goDrawFocusSelected in Options) or
            ((not (goDrawFocusSelected in Options)) and (not (gdFocused in AState))) or
            // または行選択状態か
            (goRowSelect in Options)
        ) then
    begin
      Canvas.Brush.Color := clHighlight;
      Canvas.FillRect(ARect);
      Canvas.Font.Color := clHighlightText;
    end
    // パラメータが設定されている場合
    else if pPrm <> nil then
    begin
      // 文字表示位置
      Arg := pPrm^.Alignment;
      // 背景
      Canvas.Brush.Style := bsSolid;
      Canvas.Brush.Color := pPrm^.BackColor;
      Canvas.FillRect(ARect);
      // ブラシ
      if pPrm^.BrushEnabled then
      begin
        Canvas.Brush.Color := pPrm^.BrushColor;
        Canvas.Pen.Color := pPrm^.BrushColor;
        Canvas.Brush.Style := pPrm^.BrushStyle;
        Canvas.Pen.Width := 0;
        Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
      end;
      // フォント
      Canvas.Font.Color := pPrm^.FontColor;
    end
    // パラメータが未設定の場合
    else begin
      Canvas.FillRect(ARect);
    end;
  end;

  // 文字列描画
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

  // キャンバスの状態を元に戻す
  Canvas.Pen.Assign(FsvPen);
  Canvas.Brush.Assign(FsvBrush);
  Canvas.Font.Assign(FsvFont);

  // フォーカス枠描画
  if (Focused) and (gdFocused in AState) then
    Canvas.DrawFocusRect(ARect);

  // 固定セルハイライト描画
  DrawFixed;

end;


end.
