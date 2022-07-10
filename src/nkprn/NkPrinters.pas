/////////////////////////////////////////////////
//
// NkPrinters.pas
//
// Coded By T.Nakamura
//
// Ver. 0.1   1998.3.30 初版
// Ver. 0.11  1998.3.31
//   (1) BinNames で2番目以降のビン名がおかしくなるバグを修正
//   (2) メモリリークを1件修正
//   (3) PaperExtent Property の書き込み(ユーザ定義サイズ)が 0.1mm 単位に
//       なってしまっているバグを修正。Pixel 単位とする。
// Ver. 0.12  1998.3.31
//   (1) DevMode 構造体の変更を DocumentProperties を介して行うように変更
// Ver. 0.2  1998.4.2
//   (1) プリンタのパラメータを一つ変えると他のパラメータがリセットされて
//       しまうというおおぼけバグを修正。
//   (2) Copies, MaxCopies, Collate property を追加
//   (3) MaxPaperExtebt, MinPaperExtent Property を追加
//   (4) プリンタの追加削除に対応。OnSystemChanged イベントを追加
//
// Ver. 0.21 1998.4.4
//   (1) Port が変更されても Indexがずれないようにした。
//       このためソースを大幅修正！！ これで Port 変更機能の準備完了。
//   (2) Demo の修正。Copies/Collate が機能していなかった。
//   (3) 例外の定義がすべて Exception と同等になっていたので、継承に
//       なるように修正(^^。
//
// Ver. 0.3  1998.4.5
//   (1) Color, Duplex, Scale, ColorBitCount を追加。
//   (2) Portnames. Port を追加
// Ver. 0.31 1998.4.7
//   (1) MaxPaperExtent/MinPaperExtent property の削除
//   (2) delphi-cw 99 で東大 武内氏からご報告の有った Collate の
//       バグを修正(Orientation を取得／設定していた(^^;)
//   (3) delphi-cw 99 で東大 武内氏からご報告の有った MD-1300 での不具合
//       に対応。紙情報／ビン情報の更新をビンと紙関係の Propety を
//       アクセスするたびに行うように修正。
//
// Ver. 0.32 1998.4.9
//   (1) Ver 0.31 の (3) の対処でデモプログラムが異様に遅くなること判明。
//       紙名、ビン名一覧の取得で DocumentProperties が遅いことが判明。
//       TNkPrintDialog, TNkPrinterSetupDialog を導入することに決めた。
//
// Ver. 0.4  1998.4.18
//   (1) 印刷品質用の Property を追加
//       Quality, Qualities NumQuality Property
//   (2) HasPaperSizeNumber, HasBinNumber メソッドを追加
//   (3) BinNumber Property の追加
//   (4) PaperSize Property を PaperSizeNumber Property に改名
//   (5) NumPaperSizes, NumBins Property を追加
//   (6) PaperNumbers, BinNumbers Property を追加
// Ver 0.41 1998.4.19
//   (1) PaperExtent Property でユーザ定義紙サイズを設定するとき Scale
//       を考慮していなかった点を修正。
//   (2) MMPageExtent(0.1mm 単位の印刷可能領域の大きさ) Property を追加
//   (3) 印刷倍率 がサポートされていない場合 Scale の読み出しでは 100% が
//       返るように変更。
//
// Ver 0.42 1998.4.27
//   (1) MMPaperExtent Property を新設。ユーザ定義紙サイズを 0.1 mm 単位で
//       設定できるようにした。
//   (2) NkPrinter の IC or DC を表わす Handle Property を追加
//   (3) 印刷中を表わす、Printing Property を追加
// Ver 0.43 1998.4.29
//   (1) Port 追加／削除に対応
//   (2) ポート一覧に同じポート名が複数出てくるのに対処(対症療法)
// Ver 0.44 1998.6.1  リリース版
//   (1) ヘルプを作成。
//   (2) Property の型を若干修正
// Ver 0.45 1998.6.6
//   (1)プリンタが紙サイズ情報、ビン情報、印刷品質情報、最大部数を
//      DeviceCapabilitites で提供しない場合が有ることに対応した。
// Ver 0.46 1998.6.8
//   (1) ヘルプを修正。
// Ver 0.5  1998.9.13
//   (1) ApplySettings/DiscardModification メソッド Modified プロパティを追加。
//       プリンタ設定の変更をダイレクトにプリンタに設定せず、ApplySettings
//       メソッドで一括設定することにした。
//   (2) MMPaperExtent/PaperExtent を読み取り専用に変更。ユーザ定義紙サイズの
//       取得／変更用に UserPaperExtent を新設。


unit NkPrinters;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, WinSpool;

type
  ENkPrinter = class(Exception);
  ENKPrinterRangeError = class(ENkPrinter);       // プリンター設定パラメータの
                                                  //  範囲エラー例外
  ENKPrinterPaperSizeError = class(ENkPrinter);   // サポートしていない紙サイズ
  ENkPrinterBinError = class(ENkPrinter);         // サポートしていないビン
  ENkPrinterNoPrinter = class(ENkPrinter);        // プリンターが無い
  ENkPrinterNotSupported = class(ENkPrinter);     // サポートしていない機能を
                                                  //  使おうとした
  ENkPrinterNoInfo = class(ENkPrinter);           // 情報が提供されていない
  ENkPrinterIllegalIndex = class(ENkPrinter);     // PrinterIndex が隠された
  ENkPrinterNoUserPaperExtent = class(ENkPrinter);// ユーザ定義サイズを取得不可                                               // プリンタを指している。

  // プリンタのサポートしている機能
  TNkPrintCap = (nkPcOrientation,         // 紙の方向
                 nkPcPaperSize,           // 紙のサイズ
                 nkPcPaperlength,         // 紙の長さ（ユーザ定義サイズ）
                 nkPcPaperWidth,          // 紙の幅（ユーザ定義サイズ）
                 nkPcScale,               // スケーリング
                 nkPcCopies,              // 部数
                 nkPcDefaultSource,       // ビン
                 nkPcPrintQuality,        // 印刷品質
                 nkPcColor,               // カラー印刷
                 nkPcDuplex,              // 両面印刷
                 nkPcYResolution,         // Y 方向 解像度
                 nkPcTTOption,            // True Type Option
                 nkPcCollate,             // 丁合
                 nkPcFormName,            // フォーム名
                 nkPcLogPixels,           // 論理インチ
                 nkPcMediaType,           // メディアタイプ
                 nkPcDitherType           // ディザタイプ
                );

  TNkPrintCaps = set of TNkPrintCap;      // サポート機能の集合

  TNkPaperOrientation = (nkOrPortrait,    // 紙の方向： 縦
                         nkOrLandScape    // 紙の方向： 横
                        );
  TNkDuplex = (nkDupSimplex,              // 片面
               nkDupHorizontal,           // 水平方向両面
               nkDupVertical              // 垂直方向両面
              );

  TNkAvailInfo = (nkAvPaperSize,          // 紙サイズ情報有
                  nkAvBin,                // ビン情報有
                  nkAvQuality,            // 印刷品質情報有
                  nkAvMaxCopies);         // 最大部数情報有

  TNkAvailInfos = set of TNkAvailInfo;    // 有効情報の集合


  // EnumPrinters で取り出した情報を格納するクラス。
  TNkAllPrintersInfo = class
  private
    pPrintersInfo: Pointer;   // Printer_Info_2 の配列へのポインタ。
    nPrinters: DWORD;       // プリンタの数（隠されたプリンタを含む）

    function GetName(Index: Integer): string;      // プリンタ名の取り出し
    function GetAttributes(Index: Integer): DWORD; // 属性の取り出し
  public
    constructor Create;              // 全プリンタの情報を取得
    destructor Destroy; override;

    // 全プリンタ情報の比較
    function Compare(Another: TNkAllPrintersInfo): Boolean;
    // プリンタ数（隠されたプリンタを含む）
    property Count: DWORD read nPrinters;
    //プリンタ名
    property Name[Index: Integer]: string read GetName;
    //プリンタの属性
    property Attributes[Index: Integer]: DWORD read GetAttributes;
  end;

  // GetInfo, SetInfo, Release Info のパラメータの型
  TNkPrinterInfo = record
    Device, Driver, Port: array[0..511] of Char;
    hDevMode: THandle;
    pDevMode: PDEVICEMODE;
  end;

  TNkPrinter = class
  private
    AllInfo: TNkAllPrintersInfo;    // 全プリンタ情報
    pPaperNumbers: Pointer;         // サポートする紙サイズ番号の配列を保持
    FPaperNames: TStrings;          // サポートする紙サイズ名の配列

    pBinNumbers: Pointer;           // サポートするビン番号の配列
    FBinNames: TStringList;         // サポートするビン名の配列。

    pResolutions: Pointer;          // サポートする解像度の配列
    FNumResolutions: Integer;       // サポートする解像度の数

    FPrinterNames: TStringList;     // プリンター名の配列
    FPortNames: TStringList;        // ポート名の配列
    FMaxCopies: Integer;            // 最大部数

    FIndex: Integer;                // Printer.PrinterIndex の値をセーブしたもの
                                    // Printer.PrinterIndex が変更されたか
                                    // 検出するために用いる。

    FOnSystemChanged: TNotifyEvent; // システム変更時のイベント。
                                    // プリンタの削除追加時を捕捉するのに使う。

    FAvailInfos: TNkAvailInfos;     // 利用可能な情報を示す集合


    FModified: Boolean;             // プリンタ設定が変更されたかを示すフラグ。
    pSettings: PDEVICEMODE;         // プリンタ設定(DevMode)のコピー。ここに設定を
                                    // 保存する。
    PortName: string;               // プリンタ設定のポート名。



    // WM_WININICHANGE 受信用フック
    function AppHook(var Msg: TMessage): Boolean;

    procedure CheckNoPrinter;       // プリンタが有るかチェック。無ければ例外が
                                    // あがる。

    // 指定されたプリンタの機能がサポートされているかチェックする。
    procedure CheckSupport(Value: TNkPrintCap; str: string);


    function GetInfo: TNkPrinterInfo;           // プリンタ情報の取得
    procedure SetInfo(PrnInfo: TNkPrinterInfo); // プリンタ情報の更新
    // プリンター情報の解放
    procedure ReleaseInfo(PrnInfo: TNkPrinterInfo);

    procedure GetSettings;                      // プリンタ設定の取得


    //////////////
    // TNkPrinter 内の情報更新
    procedure GetPaperSizes;       // 紙サイズ情報の取得
    procedure GetBins;             // ビン情報の取得
    procedure GetResolutions;      // 解像度情報の取得
    procedure GetMaxCopiesInfo;    // 最大部数の取得
    procedure Update;              // プリンタの各種情報の更新




    ////////////////////
    // 紙関係の property アクセスメソッド
    //

    // PaperSizeNumber Property のアクセスメソッド
    function GetPaperSizeNumber: Integer;
    procedure SetPaperSizeNumber(Value: Integer);

    // PaperSizeNames Property のアクセスメソッド
    function GetPaperSizeNames: TStrings;

    // PaperSizeIndex Property のアクセスメソッド
    function GetPaperSizeIndex: Integer;
    procedure SetPaperSizeIndex(Value: Integer);

    // NumPaperSizes propety のアクセスメソッド
    function GetNumPaperSizes: Integer;

    // paperSizeNumbers Property のアクセスメソッド
    function GetPaperSizeNumbers(Index: Integer): Integer;

    // PageExtent property のアクセスメソッド
    function GetPageExtent: TSize;

    // MMPageExtent property のアクセスメソッド
    function GetMMPageExtent: TSize;

    // DPI Proeprty のアクセスメソッド
    function GetDPI: TSize;

    // PaperExtent Property のアクセスメソッド
    function GetPaperExtent: TSize;

    // MMPaperExtent Property のアクセスメソッド
    function GetMMPaperExtent: TSize;

    // UserPaperExtent Property のアクセスメソッド
    function GetUserPaperExtent: TSize;
    procedure SetUserPaperExtent(Value: TSize);


    // Offset Property のアクセスメソッド
    function GetOffset: TSize;



    ////////////////////
    // Bin 関係 の property アクセスメソッド
    //

    // Bin Property のアクセスメソッド
    function GetBinNumber: Integer;
    procedure SetBinNumber(Value: Integer);

    // BinNames Property のアクセスメソッド
    function GetBinNames: TStrings;

    // BinIndex Property のアクセスメソッド
    function GetBinIndex: Integer;
    procedure SetBinIndex(Value: Integer);

    // NumBins property のアクセスメソッド
    function GetNumBins: Integer;

    // BinNumbers property のアクセスメソッド
    function GetBinNumbers(Index: Integer): Integer;


    ////////////////////
    // 印刷品質関係 property のアクセスメソッド
    //

    // Quality Propertyアクセスメソッド；
    function GetQuality: TSize;
    procedure SetQuality(Value: TSize);

    // Qualities Property のアクセスメソッド
    function GetQualities(Index: Integer): TSize;

    // NumQualities Property のアクセスメソッド
    function GetNumQualities: Integer;




    ////////////////////
    // ポート関係 property のアクセスメソッド
    //

    // PortNames Property アクセスメソッド
    function GetPortNames: TStrings;

    // Port Property アクセスメソッド
    function GetPort: string;
    procedure SetPort(Value: string);




    ////////////////////
    // その他の Property のアクセスメソッド
    //
    // PrintCaps Property のアクセスメソッド
    function GetPrintCaps: TNkPrintCaps;

    // Orientation Property のアクセスメソッド
    function GetOrientation: TNkPaperOrientation;
    procedure SetOrientation(Value: TNkPaperOrientation);

    // PrinterNames Property のアクセスメソッド
    function GetPrinterNames: TStrings;

    // MaxCopies Property のアクセスメソッド
    function GetMaxCopies: WORD;

    // Copies property のアクセスメソッド
    function GetCopies: WORD;
    procedure SetCopies(Value: WORD);

    // Collate property のアクセスメソッド
    function GetCollate: Boolean;
    procedure SetCollate(Value: Boolean);

    // Color property のアクセスメソッド
    function GetColor: Boolean;
    procedure SetColor(Value: Boolean);

    // Duplex property のアクセスメソッド
    function GetDuplex: TNkDuplex;
    procedure SetDuplex(Value: TNkDuplex);

    // Scale property のアクセスメソッド
    function GetScale: WORD;
    procedure SetScale(Value: WORD);

    // ColorBitCount Property アクセスメソッド
    function GetColorBitCount: Integer;

    // Index Property のアクセスメソッド
    function GetIndex: Integer;
    procedure SetIndex(Value: Integer);

    // Canvas Property のアクセスメソッド
    function GetCanvas: TCanvas;

    // Handle Property のアクセスメソッド
    function GetHandle: HDC;

    // Printing Property のアクセスメソッド
    function GetPrinting: Boolean;

    function GetAvailInfos: TNkAvailInfos;

  public
    // コンストラクタ デストラクタ
    constructor Create;
    destructor Destroy; override;




    ////////////////////
    // 公開 メソッド
    //

    // 印刷関係のメソッド
    procedure BeginDoc(Title: string); // 印刷開始
    procedure Abort;                   // 印刷中止
    procedure Newpage;                 // 新ページ
    procedure EndDoc;                  // 印刷終了


    // 紙サイズ番号がサポートされているかチェックするメソッド
    function HasPaperSizeNumber(SizeNumber: Integer): Boolean;

    // ビン番号がサポートされているかチェックするメソッド
    function HasBinNumber(BinNumber: Integer): Boolean;

    // 強制的なプリンタ情報の更新
    procedure ForceUpdate;

    // プリンタ設定をプリンタに反映する
    procedure ApplySettings;

    // プリンタ設定の変更を捨てる
    procedure DiscardModification;


    ////////////////////
    // 公開 プロパティ
    //

    // Canvas Property:       NkPrinter の Canvas
    property Canvas: TCanvas read GetCanvas;

    // プリンタのIC or DC;
    property Handle: HDC read GetHandle;

    // 印刷中フラグ
    property Printing: Boolean read GetPrinting;

    // 修正された設定が有ることを示す。プリンタの設定を修正すると True になり
    // ApplySettings を呼んで設定をプリンタに送ると False になる。

    property Modified: Boolean read FModified;

    ////////////
    // 紙関係の Porperty
    //

    // PaperSizeNumber Property: 紙サイズの番号。現在の紙サイズの参照／設定に
    //                           用いる。例えば A4 をセットするには DMPAPER_A4
    //                           をセットする。
    property PaperSizeNumber: Integer read GetPaperSizeNumber
                                   write SetPaperSizeNumber;

    // PaperSizeNames Property:紙サイズ名の配列。読み込み専用
    property PaperSizeNames: TStrings read GetPaperSizeNames;

    // PaperSizeIndex Property:紙サイズのインデックス。紙サイズの
    //                         参照／設定に用いる。PaperSize Property とは
    //                         異なり、紙サイズを PaperSizeNames 配列の
    //                         インデックスで指定する
    property PaperSizeIndex: Integer read GetPaperSizeIndex
                                     write SetPaperSizeIndex;

    // NumPaperSizes Property: 紙サイズの数
    property NumPaperSizes: Integer read GetNumPaperSizes;

    // PaperSizeNumbers Property: 紙サイズ番号の配列。読み込み専用
    property PaperSizeNumbers[Index: Integer]: Integer read GetpaperSizeNumbers;

    // 紙情報関連の Property
    // PageExtent:    印刷可能領域の大きさ（Pixel)
    // MMPageExtent:  印刷可能領域の大きさ（0.1mm 単位)
    // DPI:           解像度(Dot Per Inch)
    // PaperExtent:   紙の大きさ(Pixel)
    // MMPaperExtent: 紙の大きさ(0.1mm 単位)
    // Offset:     紙の左上端から印刷可能領域の左上端までの距離(Pixel)
    property PageExtent: TSize read GetPageExtent;
    property MMPageExtent: TSize read GetMMPageExtent;
    property DPI: TSize read GetDPI;
    property PaperExtent: TSize read GetPaperExtent;
    property MMPaperExtent: TSize read GetMMPaperExtent;
    property UserPaperExtent: TSize read getUserPaperExtent
                                    write SetUserPaperExtent;
    property Offset: TSize read GetOffset;




    ////////////
    // ビン関係の Porperty
    //

    // BinNumber Property: ビン番号の取得／設定
    property BinNumber: Integer read GetBinNumber write SetBinNumber;

    // BinNames Property:ビン名の配列。読み込み専用
    property BinNames: TStrings read GetBinNames;

    // BinIndex Property:      ビンのインデックス。ビンの
    //                         参照／設定に用いる。ビンを BinNames 配列の
    //                         インデックスで指定する
    property BinIndex: Integer read GetBinIndex
                               write SetBinIndex;

    // NumBins Property: ビンの数
    property NumBins: Integer read GetNumBins;

    // BinNumbers Property: ビン番号の配列。読み込み専用
    property BinNumbers[Index: Integer]: Integer read GetBinNumbers;



    ////////////
    // 印刷品質関係の Porperty
    //

    // Quality Property 印刷品質
    property Quality: TSize read  GetQuality
                            write SetQuality;

    // NumQualites Property 印刷品質（解像度）の数
    property NumQualities: Integer read GetNumQualities;

    // Qualities 配列 Property 印刷品質（解像度）の配列
    property Qualities[Index: Integer]: TSize read GetQualities;




    ////////////
    // プリンタ関係の Porperty
    //

    // Index Property:        現在選択しているプリンタのインデックス。
    //                        インデックス値は PrinterNames 配列のインデックス
    //                        と同じ。-1 を代入するとデフォルトプリンタを選択
    //                        できる。PrinterNames 配列は「隠された」プリンタ
    //                        を含まないため、Printer.PrinterIndex とは値が
    //                        異なるので注意！
    property Index: Integer read GetIndex
                            write SetIndex;

    // PrintCaps Property:     現在選択されているプリンタの機能
    property PrintCaps: TNkPrintCaps read GetPrintCaps;

    // PrinterNames Property:  インストールされているすべてのプリンタ名の
    //                          配列。「隠された」プリンタは含まない。
    //                          読み出し専用
    property PrinterNames: TStrings read GetPrinterNames;

    // PortNames Property:  ポート一覧
    property PortNames: TStrings read GetPortNames;

    // Port Property  ポート名
    property Port: string read GetPort write SetPort;






    ////////////
    // その他の Porperty
    //

    // Orientation Property:   紙の方向を参照／指定する。
    property Orientation: TNkPaperOrientation read GetOrientation
                                              write SetOrientation;

    // MaxCopies Property 最大部数
    property MaxCopies: WORD read GetMaxCopies;

    // Copies Property 部数
    property Copies: WORD read GetCopies write SetCopies;

    // Collate Property 丁合い
    property Collate: Boolean read GetCollate write SetCollate;

    // Color Property カラー／白黒の指定
    property Color: Boolean read GetColor write SetColor;

    // Duplex Property 両面印刷
    property Duplex: TNkDuplex read GetDuplex write SetDuplex;

    // Scale Property 印刷倍率
    property Scale: WORD read GetScale write SetScale;

    // ColorBitCount Property 色ビット数
    property ColorBitCount: Integer read GetColorBitCount;

    // プリンタ関連情報の有効フラグ
    property AvailInfos: TNkAvailInfos read GetAvailInfos;


    //////////////////////
    // 公開イベント
    //


    // システム変更イベント。プリンタの追加削除時に起きる。
    property OnSystemChanged: TNotifyEvent read  FOnSystemChanged
                                           write FOnSystemChanged;
  end;

  // NkPrinter 用印刷ダイアログ
  TNkPrintDialog = class(TPrintDialog)
  public
    function Execute: Boolean; override;
  end;

  // NkPrinter 用印刷設定ダイアログ
  TNkPrinterSetupDialog = class(TPrinterSetupDialog)
  public
    function Execute: Boolean; override;
  end;

procedure Register;


var
  NkPrinter: TNkPrinter;

implementation

uses Printers;

const PrintCapValues: array[0..16] of LongInt =
  (DM_ORIENTATION, DM_PAPERSIZE, DM_PAPERLENGTH, DM_PAPERWIDTH,
   DM_SCALE, DM_COPIES, DM_DEFAULTSOURCE, DM_PRINTQUALITY,
   DM_COLOR, DM_DUPLEX, DM_YRESOLUTION, DM_TTOPTION, DM_COLLATE,
   DM_FORMNAME, DM_LOGPIXELS, DM_MEDIATYPE, DM_DITHERTYPE);

const OrientationValues: array[0..1] of LongInt =
  (DMORIENT_PORTRAIT, DMORIENT_LANDSCAPE);

const DuplexValues: array[0..2] of LongInt =
  (DMDUP_SIMPLEX, DMDUP_HORIZONTAL, DMDUP_VERTICAL);

type
  TWORDArray = array[0..10000] of WORD;
  PWORDArray = ^TWORDArray;
  TNameArray = array[0..10000] of array[0..63] of Char;
  PNameArray = ^TNameArray;
  TBinNameArray = array[0..10000] of array[0..23] of Char;
  PBinNameArray = ^TBinNameArray;
  TPrinterInfo2Array = array[0..10000] of TPrinterInfo2;
  PPrinterInfo2Array = ^TPrinterInfo2Array;
  TPortInfo1Array = array[0..10000] of TPortInfo1;
  PPortInfo1Array = ^TPortInfo1Array;
  TSizeArray = array[0..10000] of TSize;
  PSizeArray = ^TSizeArray;


// 全プリンタ情報の作成
constructor TNkAllPrintersInfo.Create;
var Flags: Integer;
    InfoBytes: DWORD;
begin
  nPrinters := 0;

  if Win32Platform = VER_PLATFORM_WIN32_NT
  then Flags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL
  else Flags := PRINTER_ENUM_LOCAL;

  InfoBytes := 0;
  // バッファ長を得る
  EnumPrinters(Flags, nil, 2, nil, 0, InfoBytes, nPrinters);
  if InfoBytes = 0 then Exit;
  GetMem(pPrintersInfo, InfoBytes);

  // プリンタ情報(Level = 2)を取得
  Win32Check(EnumPrinters(Flags, nil, 2, pPrintersInfo,
                        InfoBytes, InfoBytes, nPrinters));
end;

// 全プリンタ情報の破棄
destructor TNkAllPrintersInfo.Destroy;
begin
  if pPrintersInfo <> Nil then FreeMem(pPrintersInfo);
end;

// 全プリンタ情報からプリンタ名を取り出す。
function TNkAllPrintersInfo.GetName(Index: Integer): string;
begin
  Result := PPrinterInfo2Array(pPrintersInfo)^[Index].pPrinterName;
end;

// 全プリンタ情報からプリンタの属性を取り出す。
function TNkAllPrintersInfo.GetAttributes(Index: Integer): DWORD;
begin
  Result := PPrinterInfo2Array(pPrintersInfo)^[Index].Attributes;
end;

// 全プリンタ情報の比較。
function TNkAllPrintersInfo.Compare(Another: TNkAllPrintersInfo): Boolean;
var i: Integer;
    pInfo1, pInfo2: PPrinterInfo2;
begin
  Result := False;

  // 数が違ったら駄目！
  if nPrinters <> Another.nPrinters then Exit;

  // 情報無しなら一致
  if nPrinters = 0 then begin Result := True; Exit; end;

  pInfo1 := pPrintersInfo; pInfo2 := Another.pPrintersInfo;

  // プリンタ名、ポート名、ドライバ名、属性のみを比較 (^^
  for i := 0 to nPrinters-1 do begin
    if AnsiStrComp(pInfo1^.pPrinterName, pInfo2^.pPrinterName) <> 0 then Exit;
    if AnsiStrComp(pInfo1^.pPortName, pInfo2^.pPortName) <> 0 then Exit;
    if AnsiStrComp(pInfo1^.pDriverName, pInfo2^.pDriverName) <> 0 then Exit;
    if pInfo1^.Attributes <> pInfo2^.Attributes then Exit;
    Inc(pInfo1); Inc(pInfo2);
  end;
  Result := True;
end;


////////////////////
// Note:
//
// コンストラクタでは Printer にアクセスしないことに注意！！
// コンストラクタで Printer にアクセスするとプリンターが無い場合
// アプリケーションが立ち上がらなくなる。

constructor TNkPrinter.Create;
begin
  FIndex := -1;                   // Update の呼び出しに備えて -1 にセット
  // 全プリンタ情報を初期化
  AllInfo := TNkAllPrintersInfo.Create;
  pPaperNumbers := Nil;           // 紙サイズ情報用バッファポインタをクリア
  pBinNumbers := Nil;             // ビン情報用バッファポインタをクリア
  pResolutions := Nil;            // 解像度情報用バッファポインタをクリア

  FModified := False;             // プリンタ設定変更フラグをオフ。
  pSettings := Nil;                // プリンタ設定保持用ポインタをクリア

  // 紙サイズ名配列、プリンタ名配列をクリア
  FPaperNames := TStringList.Create;
  FBinNames := TStringList.Create;
  FPrinterNames := TStringList.Create;
  FPortNames := TStringList.Create;

  // アプリケーションウィンドウに来る WM_WININICHANGE 受信用フックを設置
  Application.HookMainWindow(AppHook);
end;

destructor TNkPrinter.Destroy;
begin
  // アプリケーションウィンドウに来る WM_WININICHANGE 受信用フックをはずす
  Application.UnHookMainWindow(AppHook);
  // 各種リソースを解放
  if pPaperNumbers <> Nil then FreeMem(pPaperNumbers);
  if pBinNumbers <> Nil then FreeMem(pBinNumbers);
  if pResolutions <> Nil then FreeMem(pResolutions);
  if AllInfo <> Nil then AllInfo.Free;
  if FPaperNames <> Nil then FPaperNames.Free;
  if FBinNames <> Nil then FBinNames.Free;
  if FPrinterNames <> Nil then FPrinterNames.Free;
  if FPortNames <> Nil then FPortNames.Free;
  DiscardModification;
  inherited Destroy;
end;


// プリンタの追加削除が「あったかもしれない」時の処理
function TNkPrinter.AppHook(var Msg: TMessage): Boolean;
var OldPrinter: TPrinter;
    NewInfo: TNkAllPrintersInfo;
    SavedPortNames: TStringList;
    DummyList: TStrings;
    i: Integer;
begin
  Result := False;
  if Msg.Msg = WM_WININICHANGE then begin

    ////////////////////
    //
    // Note:
    //
    // TPrinter はプリンタの追加削除に対応していないので
    // 内部のプリンタリストを破棄するためには
    // TPrinter そのものを破棄するのが最も簡単。
    // TPrinter 内の FreePrinters はPrivate なので
    // 呼び出せない。
    //

    NewInfo := TNkAllPrintersInfo.Create;
    if not AllInfo.Compare(NewInfo) then begin
      // 全プリンタ情報に変化が有るなら TPrinter を破棄！！
      OldPrinter := Printers.SetPrinter(Nil);
      OldPrinter.Free;
      AllInfo.Free;
      // 全プリンタ情報を更新
      AllInfo := NewInfo;
      FIndex := -1; // インデックスを無効化

      // プリンタ設定情報を破棄
      DiscardModification;
      
      if Assigned(FOnSystemChanged) then FOnSystemChanged(Self);
      Exit;
    end
      else NewInfo.Free;  // 更新不要

    ////////////
    //
    // Port の追加削除が有ったら SystemChanged Event を起こす
    //
    SavedPortNames := TStringList.Create;
    try
      SavedPortNames.Assign(FPortNames);
      DummyList := PortNames;
      if DummyList.Count <> SavedPortNames.Count then begin
        if Assigned(FOnSystemChanged) then FOnSystemChanged(Self);
      end
      else if DummyList.Count > 0 then begin
        for i := 0 to DummyList.Count-1 do
          if DummyList[i] <> SavedPortnames[i] then begin
            if Assigned(FOnSystemChanged) then FOnSystemChanged(Self);
            Break;
          end;
      end;
    finally
      SavedPortNames.Free;
    end;
  end;
end;

// TNkPrinter の Canvas を取得。Printer.Canvas を使う
function TNkPrinter.GetCanvas: TCanvas;
begin Result := Printer.Canvas; end;

// プリンタの IC or DC の取得
function TNkPrinter.GetHandle: HDC;
begin Result := Printer.Handle; end;

// 印刷中フラグ
function TNkPrinter.GetPrinting: Boolean;
begin result := Printer.Printing; end;

// 印刷開始
procedure TNkPrinter.BeginDoc(Title: string);
begin
  Printer.Title := Title;
  Printer.BeginDoc;
end;

// 印刷中止
procedure TNkPrinter.Abort;
begin
  Printer.Abort;
end;

// 新しいページ
procedure TNkPrinter.NewPage;
begin
  Printer.NewPage;
end;

// 印刷終了
procedure TNkPrinter.EndDoc;
begin
  Printer.EndDoc;
end;


// プリンターが有るかチェック
// 「隠された」プリンタしかない場合も例外をあげる
procedure TNkPrinter.CheckNoPrinter;
var i: Integer;
begin
  if AllInfo.Count > 0 then
    for i := 0 to AllInfo.Count-1 do
      if (AllInfo.Attributes[i] and PRINTER_ATTRIBUTE_HIDDEN) = 0 then
        Exit;

  FIndex := -1; // プリンタの非選択状態に戻す
  raise ENkPrinterNoPrinter.Create(
    'TNkPrinter.CheckNoPrinter: No Printer');
end;

// プリンタが指定された機能をサポートしているかチェック
procedure TNkPrinter.CheckSupport(Value: TNkPrintCap; str: string);
begin
  if not (Value in PrintCaps) then
    raise ENkPrinterNotSupported.Create(str);
END;


// Printer.GetPrinter でプリンターの情報を取得
// DevMode 構造体を GlobalLock でアクセス可能にします。
function TNkPrinter.GetInfo: TNkPrinterInfo;
begin
  with Result do begin
    Printer.GetPrinter(Device, Driver, Port, hDevMode);
    if hDevMode = 0 then begin
      Printer.PrinterIndex := Printer.PrinterIndex;
      Printer.GetPrinter(Device, Driver, Port, hDevMode);
    end;
    pDevMode := GlobalLock(hDevMode);
  end;
end;

// Printer.SetPrinter でプリンターの情報を更新
// 一応 DocumentProperties  を間に入れて、プリンタドライバに
// お伺いを立ててから変更する
procedure TNkPrinter.SetInfo(PrnInfo: TNkPrinterInfo);
var hPrinterHandle: Thandle;
begin
  with PrnInfo do begin
    try
      Assert(OpenPrinter(Device, hPrinterHandle, nil));
      try
        Assert(DocumentProperties(0, hPrinterHandle, Device, pDevMode^,
                                pDevMode^, DM_COPY or DM_MODIFY) >= 0);
      finally
        ClosePrinter(hPrinterHandle);
      end;
    finally
      GlobalUnlock(hDevMode);
      Printer.SetPrinter(Device, Driver, Port, hDevMode);
    end;
  end;
end;

// DevMode 構造体を GlobalUnlock するだけ
// Devnode 構造体を変更しない場合に利用する。
procedure TNkPrinter.ReleaseInfo(PrnInfo: TNkPrinterInfo);
begin
  GlobalUnlock(PrnInfo.hDevMode);
end;

// 現在のプリンタ設定を取得し pSettings にセットする
procedure TNkPrinter.GetSettings;
var PrnInfo: TNkPrinterInfo;
    Size: Integer;
begin
  if pSettings <> Nil then FreeMem(pSettings);
  PrnInfo := GetInfo;
  try
    Size := GlobalSize(PrnInfo.hDevMode);
    Assert(Size > 0);
    GetMem(pSettings, Size);
    System.Move(PrnInfo.pDevMode^, pSettings^, Size);
    PortName := PrnInfo.Port;
  finally
    ReleaseInfo(PrnInfo);
  end;
end;


// 紙サイズの情報を更新する。
// CheckNoPrinter, CheckSupport は呼ぶ側で行うこと
procedure TNkPrinter.GetPaperSizes;
var PrnInfo: TNkPrinterInfo;
    pPaperNames: PNameArray;
    nPaperSizes: Integer;
    i: Integer;
begin
  // 古い情報を捨てる
  if pPaperNumbers <> Nil then begin
    FreeMem(pPaperNumbers);
    pPaperNumbers := Nil;
  end;
  FPaperNames.Clear;     // 紙サイズ名を破棄

  PrnInfo := GetInfo;
  try
    with PrnInfo do begin
      // 紙サイズ数を得てバッファを確保
      nPaperSizes := DeviceCapabilities(Device, Port, DC_PAPERS,
                                        Nil, pDevMode);

      // 紙サイズ情報がないなら、情報無しにする。
      if (nPaperSizes = -1) or (nPaperSizes = 0) then Exit;

      // AvailInfos Property に紙サイズ情報が有ることをセット
      FAvailInfos := FAvailInfos + [nkAvPaperSize];

      GetMem(pPaperNumbers, SizeOf(WORD) * nPaperSizes);
      Getmem(pPaperNames, 64 * nPaperSizes);
      try
        // 紙サイズの番号配列と紙名配列を得る。
        DeviceCapabilities(Device, Port, DC_PAPERS,
                             PCHAR(pPaperNumbers), pDevmode);
        DeviceCapabilities(Device, Port, DC_PAPERNAMES,
                             PCHAR(pPaperNames), pDevmode);
        if nPaperSizes > 0 then
          for i := 0 to nPaperSizes-1 do
            FPaperNames.Add(pPaperNames^[i]);
      finally
        FreeMem(pPaperNames); // 紙名配列を捨てる。
      end;
    end;
  finally
    ReleaseInfo(PrnInfo);
  end;
end;

// ビン情報を更新する。
// CheckNoPrinter, CheckSupport は呼ぶ側で行うこと
procedure TNkPrinter.GetBins;
var PrnInfo: TNkPrinterInfo;
    pBinNames: PBinNameArray;
    nBins: Integer;
    i: Integer;
begin
  // 古い情報を捨てる
  if pBinNumbers <> Nil then begin
    FreeMem(pBinNumbers);
    pBinNumbers := Nil;
  end;
  FBinNames.Clear;

  PrnInfo := GetInfo;
  try
    with PrnInfo do begin
      // ビン数を得てバッファを確保
      nBins := DeviceCapabilities(Device, Port, DC_BINS,
                                          Nil, pDevMode);

      // ビン情報が無いなら、情報無しとする。
      if (nBins = -1) or (nBins = 0) then Exit;

      // AvailInfos Property にビン情報が有ることをセット
      FAvailInfos := FAvailInfos + [nkAvBin];

      GetMem(pBinNumbers, SizeOf(WORD) * nBins);
      Getmem(pBinNames, 64 * nBins);
      try
        // ビンの番号配列と紙名配列を得る。
        DeviceCapabilities(Device, Port, DC_BINS,
                             PCHAR(pBinNumbers), pDevmode);
        DeviceCapabilities(Device, Port, DC_BINNAMES,
                             PCHAR(pBinNames), pDevmode);
        if nBins > 0 then
          for i := 0 to nBins-1 do
            FBinNames.Add(pBinNames^[i]);

      finally
        FreeMem(pBinNames); // ビン名配列を捨てる。
      end;
    end;
  finally
    ReleaseInfo(PrnInfo);
  end;
end;

// 解像度情報を更新する。
// CheckNoPrinter, CheckSupport は呼ぶ側で行うこと
procedure TNkPrinter.GetResolutions;
var PrnInfo: TNkPrinterInfo;
begin
  // 古い情報を捨てる
  if pResolutions <> Nil then begin
    FreeMem(pResolutions);
    pResolutions := Nil;
  end;

  PrnInfo := GetInfo;
  try
    with PrnInfo do begin
      // 解像度数を得てバッファを確保
      FNumResolutions := DeviceCapabilities(Device, Port, DC_ENUMRESOLUTIONS,
                                            Nil, pDevMode);

      // 印刷品質情報無しなら、無しとする。

      if FNumResolutions <= 0 then begin
        FNumResolutions := 0; Exit;
      end;

      // AvailInfos Property に印刷品質情報が有ることをセット
      FAvailInfos := FAvailInfos + [nkAvQuality];

      GetMem(pResolutions, SizeOf(TSize) * FNumResolutions);

      // 解像度配列を得る。
      Assert(DeviceCapabilities(Device, Port, DC_ENUMRESOLUTIONS,
                                PCHAR(pResolutions), pDevMode) <> -1);
    end;
  finally
    ReleaseInfo(PrnInfo);
  end;
end;

// 最大部数を更新する。
// CheckNoPrinter, CheckSupport は呼ぶ側で行うこと
procedure TNkPrinter.GetMaxCopiesInfo;
var PrnInfo: TNkPrinterInfo;
    ret: Integer;
begin
  PrnInfo := GetInfo;
  try
    Ret := DeviceCapabilities(PrnInfo.Device, PrnInfo.Port, DC_COPIES,
                       Nil, PrnInfo.pDevMode);
    if ret <= 0 then Exit;

    // AvailInfos Property に最大部数情報が有ることをセット
    FAvailInfos := FAvailInfos + [nkAvMaxCopies];
    FMaxCopies := ret;
  finally
    ReleaseInfo(PrnInfo);
  end;
end;



// 各種情報の更新
procedure TNkPrinter.Update;
var Caps: TNkPrintCaps;
begin
  // Printer.PrinterIndex が変わってないなら何もしない。
  if FIndex = Printer.PrinterIndex then Exit;

  FIndex := Printer.PrinterIndex;

  Caps := PrintCaps;

  FAvailInfos := [];  // AvailInfos プロパティをクリア。設定は
                      // GetPaperSizes, GetBins, GetResolutions,
                      // GetMaxCopiesInfo が行う。

  // 紙サイズ情報の取得
  //if nkPcPaperSize in Caps then
    GetPaperSizes;

  // ビン情報を取得
  //if nkPcDefaultSource in Caps then
    GetBins;

  // 印刷品質情報を取得
  //if nkPcPrintQuality in caps then
    GetResolutions;

  // 最大部数を取得
  //if nkPcCopies in caps then
    GetMaxCopiesInfo;
end;

// 強制的に各種プリンタ情報を更新
procedure TNkPrinter.ForceUpdate;
begin
  DiscardModification;
  FIndex := -1;
  Update;
end;


// Index Property の取得
// Printer.PrinterIndex を Index に変換する。
function TNkPrinter.GetIndex: Integer;
var i, PIndex: Integer;
    PrnInfo: TNkPrinterInfo;
    PrinterFound: Boolean;
begin
  CheckNoPrinter;
  Result := Printer.PrinterIndex;

  if Result = -1 then Exit;

  // 現在選択されているプリンターが「隠された」プリンターなら変換不能

  //////////////////////
  //
  // Note:
  //
  // TPrinter はポートが変更されると新たなエントリを TPrinter 内に作るので
  // PrinterIndex が プリンター数以上になることがある。
  // 以下のコードはこの点を考慮している。

  // PrinterIndex が隠されたプリンタならエラー
  if Result < AllInfo.Count then
    if (AllInfo.Attributes[Result] and PRINTER_ATTRIBUTE_HIDDEN) <> 0 then
      raise ENkPrinterIllegalIndex.Create(
        'TNkPrinter.GetIndex: Printers.PrinterIndex is Illegal');

  // 「隠された」プリンターを除いたインデックスに変換


  // PrinterIndex を直接見るのではなく、プリンター名でインデックス求める。
  PrnInfo := GetInfo;
  try
    PrinterFound := False;
    for i := 0 to AllInfo.Count-1 do
      if AllInfo.Name[i] = StrPas(PrnInfo.Device) then begin
        PrinterFound := True;
        Result := i;
        Break;
      end;

    Assert(PrinterFound);
  finally
    ReleaseInfo(PrnInfo);
  end;

  PIndex := Result;

  // 「隠された」プリンタの数だけ値を減らす。
  if PIndex > 0 then
    for i := 0 to PIndex-1 do
      if (AllInfo.Attributes[i] and PRINTER_ATTRIBUTE_HIDDEN) <> 0 then
        Dec(Result);
end;

// Index Property の設定
// Printer.PrinterIndex に Index を変換して設定
procedure TNkPrinter.SetIndex(Value: Integer);
var Device, Driver, Port: array[0..511] of Char;
    hDevMode: THandle;
    i, IndexForPrinter, IndexForNkPrinter: Integer;
begin
  CheckNoPrinter;

  // Value < -1 は有り得ない
  if Value < -1 then
    raise ENkPrinterRangeError.Create(
      'TNkPrinter.SetIndex: Index is out of Range');

  if Value = Index then Exit;  // インデックス値が同じなら何もしない。

  if Value > -1 then begin
    IndexForPrinter := -1;
    IndexForNkPrinter := 0;
    for i := 0 to AllInfo.Count-1 do begin
      if (AllInfo.Attributes[i] and PRINTER_ATTRIBUTE_HIDDEN) <> 0 then
        Continue
      else
        if IndexForNkPrinter = Value then begin
          IndexForPrinter := i;
          Break;
        end
        else
          Inc(IndexForNkPrinter);
    end;
    if IndexForPrinter = -1 then
      raise ENkPrinterRangeError.Create(
        'TNkPrinter.SetIndex: Index is out of Range');
  end
  else // Value = -1 -> デフォルトプリンターに設定
    IndexForPrinter := -1;

  with Printer do begin
    PrinterIndex := IndexForPrinter;
    // PrinterIndex のバグ対策
    GetPrinter(Driver, Device, Port, hDevMode);
    SetPrinter(Driver, Device, Port, 0);
    // 最新情報を取得
    FIndex := -1;
    Update;
  end;

  // プリンタ設定情報の破棄
  DiscardModification;
end;


// 現在設定されている紙サイズ番号を取得
function TNkPrinter.GetPaperSizeNumber: Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcPaperSize,
               'TNkPrinter.GetPaperSizeNumber: PaperSize is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  Result := pSettings^.dmPaperSize;
end;


// 紙サイズ番号を設定
procedure TNkPrinter.SetPaperSizeNumber(Value:Integer);
begin
  CheckNoPrinter;
  CheckSupport(nkPcPaperSize,
               'TNkPrinter.SetPaperSizeNumber: PaperSize is not Supported');
  Update;

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if pSettings^.dmPaperSize <> Value then begin
    pSettings^.dmPaperSize := Value;
    FModified := True;
  end;
end;

// 紙番号がプリンタにサポートされているかどうかチェック
function TNkPrinter.HasPaperSizeNumber(SizeNumber: Integer): Boolean;
var i: Integer;
    FindSize: Boolean;
begin
  CheckNoPrinter;
  CheckSupport(nkPcPaperSize,
               'TNkPrinter.HasPaperNumber: PaperSize is not Supported');
  Update;

  if not (nkAvPaperSize in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.HasPapserSizeNumber: No PaperSize Info Available');

  FindSize := False;
  if PaperSizeNames.Count > 0 then
    for i := 0 to PaperSizeNames.Count-1 do
      if SizeNumber = PWORDArray(pPaperNumbers)^[i] then begin
        FindSize := True;
        Break;
      end;
  Result := FindSize;
end;

// 紙サイズの数の取得
function TNkPrinter.GetNumPaperSizes: Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcPaperSize,
    'TNkPrinter.GetNumPaperSize: PaperSize is not Supported');

  Update;

  if not (nkAvPaperSize in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetNumPaperSizes: No Papersize Info Available');


  Result := FPaperNames.Count;
end;

//紙サイズインデックスから紙サイズ番号を取得
function TNkPrinter.GetPaperSizeNumbers(Index: Integer): Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcPaperSize,
    'TNkPrinter.GetPaperSizeNumber: PaperSize is not Supported');
  Update;

  if not (nkAvPaperSize in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetNumPaperSizeNumbers: No Papersize Info Available');


  if (Index < 0) or (Index >= NumPaperSizes) then
    raise ENkPrinterRangeError.Create(
      'TNkPrinter.GetPaperNumbers: Index is our of range');

  Result := PWordArray(pPaperNumbers)^[Index];
end;

// 紙サイズ名配列を取得
function TNkPrinter.GetPaperSizeNames: TStrings;
begin
  CheckNoPrinter;
  CheckSupport(nkPcPaperSize,
    'TNkPrinter.GetPaperSizeNames: PaperSize is not Supported');

  Update;

  if not (nkAvPaperSize in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetPaperSizeNames: No Papersize Info Available');


  Result := FPaperNames;
end;

// 現在選択されている紙サイズのインデックスを取得
function TNkPrinter.GetPaperSizeIndex: Integer;
var i: Integer;
    PaperNumber: Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcpaperSize,
    'TNkPrinter.GetPaperSizeIndex: PaperSize is not Supported');

  PaperNumber := GetPaperSizeNumber; // 紙サイズ番号を取得
  Update;

  if not (nkAvPaperSize in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetPaperSizeIndex: No Papersize Info Available');


  // 紙サイズ番号配列から紙サイズインデックスをみつける
  Result := -1;
  if FPaperNames.Count > 0 then
    for i := 0 to FPaperNames.Count-1 do
      if PWordArray(pPaperNumbers)^[i] = PaperNumber then begin
        Result := i;
        Break;
      end;

  if Result = -1 then
    raise ENKPrinterPaperSizeError.Create(
      'TNkPrinter.GetPaperSizeIndex: Cannot Get Paper Index');
end;

// 紙サイズインデックスを設定
procedure TNkPrinter.SetPaperSizeIndex(Value: Integer);
begin
  CheckNoPrinter;
  CheckSupport(nkPcpaperSize,
    'TNkPrinter.SetPaperSizeIndex: PaperSize is not Supported');

  Update;

  if not (nkAvPaperSize in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.SetPaperSizeIndex: No Papersize Info Available');


  if (Value < 0) or (Value >= FPaperNames.Count) then
    raise ENkPrinterPaperSizeError.Create(
      'TNkPrinter:SetPaperSizeIndex: No such PaperSize Index');
  SetPaperSizeNumber(PWordArray(pPaperNumbers)^[Value]);
end;


// 現在設定されているビン番号を取得
function TNkPrinter.GetBinNumber: Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcDefaultSource,
               'TNkPrinter.GetBinNumber: Bin is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;
  Result := pSettings^.dmDefaultSource;
end;


// ビン番号を設定
procedure TNkPrinter.SetBinNumber(Value: Integer);
begin
  CheckNoPrinter;
  CheckSupport(nkPcDefaultSource,
               'TNkPrinter.SetBinNumber: Bin is not Supported');
  Update;

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if pSettings^.dmDefaultSource <> Value then begin
    pSettings^.dmDefaultSource := Value;
    FModified := True;
  end;
end;

// ビン番号がサポートされているかチェック
function TNkPrinter.HasBinNumber(BinNumber: Integer): Boolean;
var i: Integer;
    FindBin: Boolean;
begin
  CheckNoPrinter;
  CheckSupport(nkPcDefaultSource,
               'TNkPrinter.SetBin: Bin is not Supported');
  Update;

  if not (nkAvBin in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.HasBinNumber: No Bin Info Available');

  FindBin := False;
  if BinNames.Count > 0 then
    for i := 0 to BinNames.Count-1 do
      if BinNumber = PWORDArray(pBinNumbers)^[i] then begin
        FindBin := True;
        Break;
      end;
  Result := FindBin;
end;



// ビンの数の取得
function TNkPrinter.GetNumBins: Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcDefaultSource,
    'TNkPrinter.GetNumBins: Bin is not Supported');

  Update;

  if not (nkAvBin in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetNumBins: No Bin Info Available');

  Result := FBinNames.Count;
end;

// ビン名配列を取得
function TNkPrinter.GetBinNames: TStrings;
begin
  CheckNoPrinter;
  CheckSupport(nkPcDefaultSource,
    'TNkPrinter.GetBinNames: Bin is not Supported');

  Update;

  if not (nkAvBin in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetBinNames: No Bin Info Available');


  Result := FBinNames;
end;

// 現在選択されているビンのインデックスを取得
function TNkPrinter.GetBinIndex: Integer;
var i: Integer;
    BinNumber: Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcDefaultSource,
    'TNkPrinter.GetBinIndex: Bin is not Supported');

  BinNumber := GetBinNumber; // ビン番号を取得
  Update;

  if not (nkAvBin in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetBinIndex: No Bin Info Available');


  Result := -1;
  // ビン番号配列からビンのインデックスをみつける
  if FBinNames.Count > 0 then
    for i := 0 to FBinNames.Count-1 do
      if PWordArray(pBinNumbers)^[i] = BinNumber then
        Result := i;

  if Result = -1 then
    raise ENkPrinterBinError.Create(
      'TNkPrinter.GetBinIndex: Cannot Get Bin Index');
end;

// ビンインデックスを設定
procedure TNkPrinter.SetBinIndex(Value: Integer);
begin
  CheckNoPrinter;
  CheckSupport(nkPcDefaultSource,
    'TNkPrinter.SetBinIndex: Bin is not Supported');

  Update;

  if not (nkAvBin in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.SetBinIndex: No Bin Info Available');


  if (Value < 0) or (Value >= FBinNames.Count) then
    raise ENkPrinterBinError.Create(
      'TNkPrinter:SetBinIndex: No such Bin Index');
  SetBinNumber(PWordArray(pBinNumbers)^[Value]);
end;

//ビンインデックスからビン番号を取得
function TNkPrinter.GetBinNumbers(Index: Integer): Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcDefaultSource,
    'TNkPrinter.GetBunNumbers: Bin is not Supported');
  Update;

  if not (nkAvBin in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetBinNumbers: No Bin Info Available');

  if (Index < 0) or (Index >= NumBins) then
    raise ENkPrinterRangeError.Create(
      'TNkPrinter.GetBunNumbers: Index is our of range');

  Result := PWordArray(pBinNumbers)^[Index];
end;



// プリンターのサポート機能の取得
function TNkPrinter.GetPrintCaps;
var Cap: TNkPrintcap;
begin
  CheckNoPrinter;

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  Result := [];
  for Cap := Low(TNkPrintCap) to High(TNkPrintCap) do
    if (pSettings^.dmFields and PrintCapValues[ord(Cap)]) <> 0 then
      Include(Result, Cap);
end;

// 紙の方向の取得
function TNkPrinter.GetOrientation: TNkPaperOrientation;
begin
  CheckNoPrinter;
  CheckSupport(nkPcOrientation,
    'TNkPrinter.GetOrientation: Orientation is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if pSettings^.dmOrientation = DMORIENT_PORTRAIT then Result := nkOrPortrait
                                                  else result := nkOrLandScape;
end;

// 紙の方向の設定
procedure TNkPrinter.SetOrientation(Value: TNkPaperOrientation);
begin
  CheckNoPrinter;
  CheckSupport(nkPcOrientation,
    'TNkPrinter.SetOrientation: Orientation is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if pSettings^.dmOrientation <> OrientationValues[Ord(Value)] then begin
    pSettings^.dmOrientation := OrientationValues[Ord(Value)];
    FModified := True;
  end;
end;

// プリンター名配列の取得
function TNkPrinter.GetPrinterNames: TStrings;
var i: Integer;
begin
  CheckNoPrinter;
  FPrinterNames.Clear; Result := FPrinterNames;

  // 「隠された」プリンターを除くプリンター名を取り出す
  if AllInfo.Count > 0 then
    for i := 0 to AllInfo.Count-1 do
      if (AllInfo.Attributes[i] and PRINTER_ATTRIBUTE_HIDDEN) = 0 then
        FPrinterNames.Add(AllInfo.Name[i]);
end;

// 印刷可能領域の取得
function TNkPrinter.GetPageExtent: TSize;
begin
  CheckNoPrinter;
  Result.cx := GetDeviceCaps(Printer.Handle, HORZRES);
  Result.cy := GetDeviceCaps(Printer.Handle, VERTRES);
end;

// 印刷可能領域の取得(mm 単位)
function TNkPrinter.GetMMPageExtent: TSize;
begin
  CheckNoPrinter;
  Result.cx := GetDeviceCaps(Printer.Handle, HORZSIZE) * 10;
  Result.cy := GetDeviceCaps(Printer.Handle, VERTSIZE) * 10;
end;

// DPIの取得
function TNkPrinter.GetDPI: TSize;
begin
  CheckNoPrinter;
  Result.cx := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
  Result.cy := GetDeviceCaps(Printer.Handle, LOGPIXELSY);
end;

// 紙サイズの取得
function TNkPrinter.GetPaperExtent: TSize;
begin
  CheckNoPrinter;
  Result.cx := GetDeviceCaps(Printer.Handle, PHYSICALWIDTH);
  Result.cy := GetDeviceCaps(Printer.Handle, PHYSICALHEIGHT);
end;



// 紙サイズの取得(0.1mm 単位)
function TNkPrinter.GetMMPaperExtent: TSize;
var Res: TSize;
    sc: Integer;
begin
  CheckNoPrinter;
  Res := DPI;
  sc := Scale;
  Result.cx := GetDeviceCaps(Printer.Handle, PHYSICALWIDTH) * 254 * sc div
               Res.cx div 100;
  Result.cy := GetDeviceCaps(Printer.Handle, PHYSICALHEIGHT) * 254 * sc div
               Res.cy div 100;
end;

function TNkPrinter.GetUserPaperExtent: TSize;
begin
  CheckNoPrinter;
  // プリンタ設定未作成なら 作成する。

  if (nkPcPaperSize in PrintCaps) and
     (nkPcPaperLength in PrintCaps) and
     (nkPcPaperWidth in PrintCaps) and
     (PaperSizeNumber = DMPAPER_USER) then begin

    if pSettings = Nil then GetSettings;

    Result.cx := pSettings^.dmPaperWidth;
    Result.cy := pSettings^.dmPaperLength;
  end
  else
    Raise ENkPrinterNoUserPaperExtent.Create(
      'TNkPrinter.GetUserpaperExtent: Cannot Get User paper Extent');
end;

procedure TNkPrinter.SetUserPaperExtent(Value: TSize);
begin
  CheckNoPrinter;

  // ユーザ定義サイズをサポートしているかチェック
  CheckSupport(nkPcPaperSize,
               'TNkPrinter.SetpaperExtent: PaperSize is not Supported');

  ////////////
  //
  //  Note: nkPcPaperLength, nkPcPaperWidth をチェックするのは
  //        止めにした。紙番号が DMPAPER_USER の時初めて
  //        ON になるプリンタが有るから。統一性が無い！


  Update;

  // ユーザ定義サイズをセット

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  FModified := True;
  with pSettings^ do begin
    dmPaperSize := DMPAPER_USER;
    dmPaperWidth := Value.cx;
    dmpaperLength := Value.cy;
    dmFields := dmFields or DM_PAPERLENGTH or DM_PAPERWIDTH;
  end;
end;


// 紙の左上端から印刷可能領域の左上端までの距離(Pixel)
function TNkPrinter.GetOffset: TSize;
begin
  CheckNoPrinter;
  Result.cx := GetDeviceCaps(Printer.Handle, PHYSICALOFFSETX);
  Result.cy := GetDeviceCaps(Printer.Handle, PHYSICALOFFSETY);
end;


// 最大部数
function TNkPrinter.GetMaxCopies: WORD;
begin
  CheckNoPrinter;
  CheckSupport(nkPcCopies,
               'TNkPrinter.GetMaxCopies: Copies is not Supported');
  Update;
  if not (nkAvMaxCopies in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetMaxCopies: No MaxCopies Info Available');
  Result := FMaxCopies;
end;

// 部数の取得
function TNkPrinter.GetCopies: WORD;
begin
  CheckNoPrinter;
  CheckSupport(nkPcCopies, 'TNkPrinter.GetCopies: Copies not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  Result := pSettings^.dmCopies;
end;

// 部数のセット
procedure TNkPrinter.SetCopies(Value: WORD);
begin
  CheckNoPrinter;
  CheckSupport(nkPcCopies, 'TNkPrinter.SetCopies: Copies not Supported');
  if (Value < 1) then
    raise ENkPrinterRangeError.Create(
      'TNkPrinter.SetCopies: Too Small Copies');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if pSettings^.dmCopies <> Value then begin
    pSettings^.dmCopies := Value;
    FModified := True;
  end;
end;

// 丁合いの取得
function TNkPrinter.GetCollate: Boolean;
begin
  CheckNoPrinter;
  CheckSupport(nkPcCollate,
    'TNkPrinter.GetCollate: Collate is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if pSettings^.dmCollate = DMCOLLATE_TRUE then Result := True
                                           else result := False;
end;

// 丁合いの設定
procedure TNkPrinter.SetCollate(Value: Boolean);
begin
  CheckNoPrinter;
  CheckSupport(nkPcCollate,
    'TNkPrinter.SetCollate: Collate is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if (Value = True) and (pSettings^.dmCollate = DMCOLLATE_FALSE) or
     (Value = False) and (pSettings^.dmCollate = DMCOLLATE_TRUE) then begin
    if Value then pSettings^.dmCollate := DMCOLLATE_TRUE
             else pSettings^.dmCollate := DMCOLLATE_FALSE;
    FModified := True;
  end;
end;

// カラーの取得
function TNkPrinter.GetColor: Boolean;
begin
  CheckNoPrinter;
  CheckSupport(nkPcColor,
    'TNkPrinter.GetColor: Color is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if pSettings^.dmColor = DMCOLOR_COLOR then Result := True
                                        else result := False;
end;

// カラーの設定
procedure TNkPrinter.SetColor(Value: Boolean);
begin
  CheckNoPrinter;
  CheckSupport(nkPcColor,
    'TNkPrinter.SetColor: Color is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if (Value = True) and (pSettings^.dmColor = DMCOLOR_MONOCHROME) or
     (Value = False) and (pSettings^.dmColor = DMCOLOR_Color) then begin
    if Value then pSettings^.dmColor := DMCOLOR_COLOR
             else pSettings^.dmColor := DMCOLOR_MONOCHROME;
    FModified := True;
  end;
end;

// 両面の取得
function TNkPrinter.GetDuplex: TNkDuplex;
begin
  CheckNoPrinter;
  CheckSupport(nkPcDuplex,
    'TNkPrinter.GetDuplex: Duplex is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if pSettings^.dmDuplex = DMDUP_SIMPLEX then
    Result := nkDupSimplex
  else if pSettings^.dmDuplex = DMDUP_HORIZONTAL then
    Result := nkDupHorizontal
  else Result := nkDupVertical;
end;

// 両面の設定
procedure TNkPrinter.SetDuplex(Value: TNkDuplex);
begin
  CheckNoPrinter;
  CheckSupport(nkPcDuplex,
    'TNkPrinter.SetDuplex: Duplex is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if pSettings^.dmDuplex <> DuplexValues[Ord(Value)] then begin
    pSettings^.dmDuplex := DuplexValues[Ord(Value)];
    FModified := True;
  end;
end;

// 倍率の取得
function TNkPrinter.GetScale: WORD;
begin
  CheckNoPrinter;
  if nkPcScale in PrintCaps then begin
    // プリンタ設定未作成なら 作成する。
    if pSettings = Nil then GetSettings;

    Result := pSettings^.dmScale;
  end
  else Result := 100;
end;

// 倍率の設定
procedure TNkPrinter.SetScale(Value: WORD);
begin
  CheckNoPrinter;
  CheckSupport(nkPcScale,
    'TNkPrinter.SetScale: Scale is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  if pSettings^.dmScale <> Value then begin
    pSettings^.dmScale := Value;
    FModified := True;
  end;
end;

// カラービット数の取得
function TNkPrinter.GetColorBitCount: Integer;
begin
  CheckNoPrinter;
  Result := GetDeviceCaps(Printer.Handle, BITSPIXEL) *
            GetDeviceCaps(Printer.Handle, PLANES);
end;

// ポート名配列の取得
function TNkPrinter.GetPortNames: TStrings;
var InfoBytes, nPorts: DWORD;
    pPortsInfo: PPortInfo1Array;
    i: Integer;
begin
  // CheckNoPrinter;

  FPortNames.Clear;
  Result := FPortNames;
  InfoBytes := 0;
  // バッファ長を得る
  EnumPorts(Nil, 1, nil, 0, InfoBytes, nPorts);
  if InfoBytes = 0 then Exit;
  GetMem(pPortsInfo, InfoBytes);
  try

    // ポート情報(Level = 1)を取得
    Win32Check(EnumPorts(Nil, 1, pPortsInfo,
                         InfoBytes, InfoBytes, nPorts));
    if nPorts > 0 then
      for i := 0 to nPorts-1 do
        if FPortnames.IndexOf(pPortsInfo^[i].pName) = -1 then
          FPortNames.Add(pPortsInfo^[i].pName);
  finally
    FreeMem(pPortsInfo);
  end;
  // Result := FPortNames;
end;

// ポート名の取得
function TNkPrinter.GetPort: string;
begin
  CheckNoPrinter;
  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;
  Result := PortName;
end;

// ポート名のセット
procedure TNkPrinter.SetPort(Value: string);
begin
  CheckNoPrinter;
  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;
  if PortName <> Value then begin
    PortName := Value;
    FModified := True;
  end;
end;

// 印刷品質の取得
function TNkPrinter.GetQuality: TSize;
begin
  CheckNoPrinter;
  CheckSupport(nkPcPrintQuality,
    'TNkPrinter.GetQuality: PrintQuality is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;
  Result.cx := pSettings^.dmPrintQuality;

  if (Result.cx > 0) and
     ((pSettings^.dmFields and DM_YRESOLUTION) <> 0) then
    Result.cy := pSettings^.dmYResolution
  else
    Result.cy := 0;
end;

// 印刷品質のセット
procedure TNkPrinter.SetQuality(Value: TSize);
begin
  CheckNoPrinter;
  CheckSupport(nkPcPrintQuality,
    'TNkPrinter.SetQuality: PrintQuality is not Supported');

  // プリンタ設定未作成なら 作成する。
  if pSettings = Nil then GetSettings;

  FModified := True;
  pSettings^.dmPrintQuality := Value.cx;
  if Value.cx > 0 then begin
    pSettings^.dmYResolution  := Value.cy;
    pSettings^.dmFields := pSettings^.dmFields or DM_YRESOLUTION;
  end
  else begin
    pSettings^.dmYResolution  := 0;
    pSettings^.dmFields := pSettings^.dmFields and not DM_YRESOLUTION;
  end;
end;

// 印刷品質（解像度）の数の取得
function TNkPrinter.GetNumQualities: Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcPrintQuality,
    'TNkPrinter.GetNumQualities: PrintQuality is not Supported');
  Update;

  if not (nkAvQuality in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetNumQualities: No Quality Info Available');

  Result := FNumResolutions;
end;

// 印刷品質配列の取得
function TNkPrinter.GetQualities(Index: Integer): TSize;
begin
  CheckNoPrinter;
  CheckSupport(nkPcPrintQuality,
    'TNkPrinter.GetQualities: PrintQuality is not Supported');
  Update;

  if not (nkAvQuality in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetQualities: No Quality Info Available');


  if (Index < 0) or (Index >= NumQualities) then
    raise ENkPrinterRangeError.Create(
      'TNkPrinter.GetQualities: Index is our of range');

  Result := PSizeArray(pResolutions)^[Index];
end;

function TNkPrinter.GetAvailInfos: TNkAvailInfos;
begin
  Update;
  Result := FAvailInfos;
end;

procedure TNkPrinter.ApplySettings;
var PrnInfo: TNkPrinterInfo;
    Size: Integer;
begin
  if not Modified then Exit;

  Assert(pSettings <> Nil,
         'TNkPrinter.ApplySettings; No Setteing Info');

  PrnInfo := GetInfo;
  try
    // プリンタ設定を  TPrinter へ DocumentProperties を介してコピーする。
    Size := GlobalSize(PrnInfo.hDevMode);
    Assert(Size > 0,
           'TNkPrinter.ApplySettings; Devmode Size Should be greater than 0');
    System.Move(pSettings^, PrnInfo.pDevMode^, Size);
    StrCopy(PrnInfo.Port, PCHAR(PortName));
    // コピーして設定がいらなくなったので、次の変更に備えて捨てる。
    DiscardModification;
    // 各種情報を取り直すように FIndex を無効にする。
    FIndex := -1;
  finally
    SetInfo(PrnInfo);
  end;
end;


procedure TNkPrinter.DiscardModification;
begin
  if pSettings <> Nil then FreeMem(pSettings);
  pSettings := Nil;
  FModified := False;
end;


function TNkPrintDialog.Execute: Boolean;
begin
  Result := inherited Execute;
  if Result then NkPrinter.ForceUpdate;
end;

function TNkPrinterSetupDialog.Execute: Boolean;
begin
  Result := inherited Execute;
  if Result then  NkPrinter.ForceUpdate;
end;


procedure Register;
begin
  RegisterComponents('NkPrinter', [TNkPrintDialog, TNkPrinterSetupDialog]);
end;

initialization
  NkPrinter := TNkPrinter.Create;

finalization
  NkPrinter.Free;
end.

