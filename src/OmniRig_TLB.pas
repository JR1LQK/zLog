unit OmniRig_TLB;

// ************************************************************************ //
//  警告                                                                      
// ------                                                                     
// このファイルで定義されている型宣言はタイプライブラリから読み出した       //
// 値を元に作成されています。タイプライブラリエディタで作業中に [ソー       //
// スコードの更新] ボタンを押したときや，ほかのタイプライブラリが直接       //
// または間接にこのタイプライブラリを参照している場合に，このファイル       //
// はタイプライブラリの値を元に再生成されます。                             //
// この場合，このファイル自身に対する変更は失われてしまいます。             //
// ************************************************************************ //

// PASTLWTR : $Revision:   1.130  $
// このファイルは以下のタイプライブラリから 2004/11/25 17:59:28 に生成されました。

// ************************************************************************ //
// Type Lib: F:\PROGRA~1\Afreet\Omni-Rig\OmniRig.exe (1)
// LIBID: {4FE359C5-A58F-459D-BE95-CA559FB4F270}
// LCID: 0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (F:\WINDOWS\System32\stdole2.tlb)
//   (2) v4.0 StdVCL, (F:\WINDOWS\System32\stdvcl40.dll)
// ************************************************************************ //
// *************************************************************************//
// 注意：                                                                     
// コンパイラ指令 {$IFDEF LIVE_SERVER_AT_DESIGN_TIME} で分離されている部分で  
// はオブジェクトを返すプロパティを定義しています。オブジェクトインスペクター 
// 内での操作間違いを回避するために、デフォルトではこれらの機能は無効にされて 
// います。必要な場合には LIVE_SERVER_AT_DESIGN_TIME を定義することでこれらの 
// 機能を有効にすることができます。また $IFDEF ブロックを書き換えることで部分 
// 的に有効にすることもできます。なお、適切な CoClass メソッドによりオブジェ  
// クトが作成できるようになっている必要があります。                           
{$TYPEDADDRESS OFF} // 型付き @ 演算子の指定を外す必要があります。
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}

interface

uses ActiveX, Classes, Graphics, OleServer, StdVCL, Variants, Windows;
  


// *********************************************************************//
// タイプライブラリ中の GUID の定義。以下の規則が使われます。             
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // タイプライブラリのメジャー/マイナーバージョン番号
  OmniRigMajorVersion = 1;
  OmniRigMinorVersion = 0;

  LIBID_OmniRig: TGUID = '{4FE359C5-A58F-459D-BE95-CA559FB4F270}';

  IID_IOmniRigX: TGUID = '{501A2858-3331-467A-837A-989FDEDACC7D}';
  DIID_IOmniRigXEvents: TGUID = '{2219175F-E561-47E7-AD17-73C4D8891AA1}';
  CLASS_OmniRigX: TGUID = '{0839E8C6-ED30-4950-8087-966F970F0CAE}';
  IID_IRigX: TGUID = '{D30A7E51-5862-45B7-BFFA-6415917DA0CF}';
  CLASS_RigX: TGUID = '{78AECFA2-3F52-4E39-98D3-1646C00A6234}';
  IID_IPortBits: TGUID = '{3DEE2CC8-1EA3-46E7-B8B4-3E7321F2446A}';
  CLASS_PortBits: TGUID = '{B786DE29-3B3D-4C66-B7C4-547F9A77A21D}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// enum RigParamX のための定数
type
  RigParamX = TOleEnum;
const
  PM_UNKNOWN = $00000001;
  PM_FREQ = $00000002;
  PM_FREQA = $00000004;
  PM_FREQB = $00000008;
  PM_PITCH = $00000010;
  PM_RITOFFSET = $00000020;
  PM_RIT0 = $00000040;
  PM_VFOAA = $00000080;
  PM_VFOAB = $00000100;
  PM_VFOBA = $00000200;
  PM_VFOBB = $00000400;
  PM_VFOA = $00000800;
  PM_VFOB = $00001000;
  PM_VFOEQUAL = $00002000;
  PM_VFOSWAP = $00004000;
  PM_SPLITON = $00008000;
  PM_SPLITOFF = $00010000;
  PM_RITON = $00020000;
  PM_RITOFF = $00040000;
  PM_XITON = $00080000;
  PM_XITOFF = $00100000;
  PM_RX = $00200000;
  PM_TX = $00400000;
  PM_CW_U = $00800000;
  PM_CW_L = $01000000;
  PM_SSB_U = $02000000;
  PM_SSB_L = $04000000;
  PM_DIG_U = $08000000;
  PM_DIG_L = $10000000;
  PM_AM = $20000000;
  PM_FM = $40000000;

// enum RigStatusX のための定数
type
  RigStatusX = TOleEnum;
const
  ST_NOTCONFIGURED = $00000000;
  ST_DISABLED = $00000001;
  ST_PORTBUSY = $00000002;
  ST_NOTRESPONDING = $00000003;
  ST_ONLINE = $00000004;

type

// *********************************************************************//
// タイプライブラリの型宣言のための forward 宣言                          
// *********************************************************************//
  IOmniRigX = interface;
  IOmniRigXDisp = dispinterface;
  IOmniRigXEvents = dispinterface;
  IRigX = interface;
  IRigXDisp = dispinterface;
  IPortBits = interface;
  IPortBitsDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  OmniRigX = IOmniRigX;
  RigX = IRigX;
  PortBits = IPortBits;


// *********************************************************************//
// Interface: IOmniRigX
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {501A2858-3331-467A-837A-989FDEDACC7D}
// *********************************************************************//
  IOmniRigX = interface(IDispatch)
    ['{501A2858-3331-467A-837A-989FDEDACC7D}']
    function  Get_InterfaceVersion: Integer; safecall;
    function  Get_SoftwareVersion: Integer; safecall;
    function  Get_Rig1: IRigX; safecall;
    function  Get_Rig2: IRigX; safecall;
    function  Get_DialogVisible: WordBool; safecall;
    procedure Set_DialogVisible(Value: WordBool); safecall;
    property InterfaceVersion: Integer read Get_InterfaceVersion;
    property SoftwareVersion: Integer read Get_SoftwareVersion;
    property Rig1: IRigX read Get_Rig1;
    property Rig2: IRigX read Get_Rig2;
    property DialogVisible: WordBool read Get_DialogVisible write Set_DialogVisible;
  end;

// *********************************************************************//
// DispIntf:  IOmniRigXDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {501A2858-3331-467A-837A-989FDEDACC7D}
// *********************************************************************//
  IOmniRigXDisp = dispinterface
    ['{501A2858-3331-467A-837A-989FDEDACC7D}']
    property InterfaceVersion: Integer readonly dispid 1;
    property SoftwareVersion: Integer readonly dispid 2;
    property Rig1: IRigX readonly dispid 3;
    property Rig2: IRigX readonly dispid 4;
    property DialogVisible: WordBool dispid 5;
  end;

// *********************************************************************//
// DispIntf:  IOmniRigXEvents
// Flags:     (4096) Dispatchable
// GUID:      {2219175F-E561-47E7-AD17-73C4D8891AA1}
// *********************************************************************//
  IOmniRigXEvents = dispinterface
    ['{2219175F-E561-47E7-AD17-73C4D8891AA1}']
    procedure VisibleChange; dispid 1;
    procedure RigTypeChange(RigNumber: Integer); dispid 2;
    procedure StatusChange(RigNumber: Integer); dispid 3;
    procedure ParamsChange(RigNumber: Integer; Params: Integer); dispid 4;
    procedure CustomReply(RigNumber: Integer; Command: OleVariant; Reply: OleVariant); dispid 5;
  end;

// *********************************************************************//
// Interface: IRigX
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D30A7E51-5862-45B7-BFFA-6415917DA0CF}
// *********************************************************************//
  IRigX = interface(IDispatch)
    ['{D30A7E51-5862-45B7-BFFA-6415917DA0CF}']
    function  Get_RigType: WideString; safecall;
    function  Get_ReadableParams: Integer; safecall;
    function  Get_WriteableParams: Integer; safecall;
    function  IsParamReadable(Param: RigParamX): WordBool; safecall;
    function  IsParamWriteable(Param: RigParamX): WordBool; safecall;
    function  Get_Status: RigStatusX; safecall;
    function  Get_StatusStr: WideString; safecall;
    function  Get_Freq: Integer; safecall;
    procedure Set_Freq(Value: Integer); safecall;
    function  Get_FreqA: Integer; safecall;
    procedure Set_FreqA(Value: Integer); safecall;
    function  Get_FreqB: Integer; safecall;
    procedure Set_FreqB(Value: Integer); safecall;
    function  Get_RitOffset: Integer; safecall;
    procedure Set_RitOffset(Value: Integer); safecall;
    function  Get_Pitch: Integer; safecall;
    procedure Set_Pitch(Value: Integer); safecall;
    function  Get_Vfo: RigParamX; safecall;
    procedure Set_Vfo(Value: RigParamX); safecall;
    function  Get_Split: RigParamX; safecall;
    procedure Set_Split(Value: RigParamX); safecall;
    function  Get_Rit: RigParamX; safecall;
    procedure Set_Rit(Value: RigParamX); safecall;
    function  Get_Xit: RigParamX; safecall;
    procedure Set_Xit(Value: RigParamX); safecall;
    function  Get_Tx: RigParamX; safecall;
    procedure Set_Tx(Value: RigParamX); safecall;
    function  Get_Mode: RigParamX; safecall;
    procedure Set_Mode(Value: RigParamX); safecall;
    procedure ClearRit; safecall;
    procedure SetSimplexMode(Freq: Integer); safecall;
    procedure SetSplitMode(RxFreq: Integer; TxFreq: Integer); safecall;
    function  FrequencyOfTone(Tone: Integer): Integer; safecall;
    procedure SendCustomCommand(Command: OleVariant; ReplyLength: Integer; ReplyEnd: OleVariant); safecall;
    function  GetRxFrequency: Integer; safecall;
    function  GetTxFrequency: Integer; safecall;
    function  Get_PortBits: IPortBits; safecall;
    property RigType: WideString read Get_RigType;
    property ReadableParams: Integer read Get_ReadableParams;
    property WriteableParams: Integer read Get_WriteableParams;
    property Status: RigStatusX read Get_Status;
    property StatusStr: WideString read Get_StatusStr;
    property Freq: Integer read Get_Freq write Set_Freq;
    property FreqA: Integer read Get_FreqA write Set_FreqA;
    property FreqB: Integer read Get_FreqB write Set_FreqB;
    property RitOffset: Integer read Get_RitOffset write Set_RitOffset;
    property Pitch: Integer read Get_Pitch write Set_Pitch;
    property Vfo: RigParamX read Get_Vfo write Set_Vfo;
    property Split: RigParamX read Get_Split write Set_Split;
    property Rit: RigParamX read Get_Rit write Set_Rit;
    property Xit: RigParamX read Get_Xit write Set_Xit;
    property Tx: RigParamX read Get_Tx write Set_Tx;
    property Mode: RigParamX read Get_Mode write Set_Mode;
    property PortBits: IPortBits read Get_PortBits;
  end;

// *********************************************************************//
// DispIntf:  IRigXDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D30A7E51-5862-45B7-BFFA-6415917DA0CF}
// *********************************************************************//
  IRigXDisp = dispinterface
    ['{D30A7E51-5862-45B7-BFFA-6415917DA0CF}']
    property RigType: WideString readonly dispid 1;
    property ReadableParams: Integer readonly dispid 2;
    property WriteableParams: Integer readonly dispid 3;
    function  IsParamReadable(Param: RigParamX): WordBool; dispid 4;
    function  IsParamWriteable(Param: RigParamX): WordBool; dispid 5;
    property Status: RigStatusX readonly dispid 6;
    property StatusStr: WideString readonly dispid 7;
    property Freq: Integer dispid 8;
    property FreqA: Integer dispid 9;
    property FreqB: Integer dispid 10;
    property RitOffset: Integer dispid 11;
    property Pitch: Integer dispid 12;
    property Vfo: RigParamX dispid 13;
    property Split: RigParamX dispid 14;
    property Rit: RigParamX dispid 15;
    property Xit: RigParamX dispid 16;
    property Tx: RigParamX dispid 17;
    property Mode: RigParamX dispid 18;
    procedure ClearRit; dispid 19;
    procedure SetSimplexMode(Freq: Integer); dispid 20;
    procedure SetSplitMode(RxFreq: Integer; TxFreq: Integer); dispid 21;
    function  FrequencyOfTone(Tone: Integer): Integer; dispid 22;
    procedure SendCustomCommand(Command: OleVariant; ReplyLength: Integer; ReplyEnd: OleVariant); dispid 23;
    function  GetRxFrequency: Integer; dispid 24;
    function  GetTxFrequency: Integer; dispid 25;
    property PortBits: IPortBits readonly dispid 26;
  end;

// *********************************************************************//
// Interface: IPortBits
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3DEE2CC8-1EA3-46E7-B8B4-3E7321F2446A}
// *********************************************************************//
  IPortBits = interface(IDispatch)
    ['{3DEE2CC8-1EA3-46E7-B8B4-3E7321F2446A}']
    function  Lock: WordBool; safecall;
    function  Get_Rts: WordBool; safecall;
    procedure Set_Rts(Value: WordBool); safecall;
    function  Get_Dtr: WordBool; safecall;
    procedure Set_Dtr(Value: WordBool); safecall;
    function  Get_Cts: WordBool; safecall;
    function  Get_Dsr: WordBool; safecall;
    procedure Unlock; safecall;
    property Rts: WordBool read Get_Rts write Set_Rts;
    property Dtr: WordBool read Get_Dtr write Set_Dtr;
    property Cts: WordBool read Get_Cts;
    property Dsr: WordBool read Get_Dsr;
  end;

// *********************************************************************//
// DispIntf:  IPortBitsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3DEE2CC8-1EA3-46E7-B8B4-3E7321F2446A}
// *********************************************************************//
  IPortBitsDisp = dispinterface
    ['{3DEE2CC8-1EA3-46E7-B8B4-3E7321F2446A}']
    function  Lock: WordBool; dispid 1;
    property Rts: WordBool dispid 2;
    property Dtr: WordBool dispid 3;
    property Cts: WordBool readonly dispid 4;
    property Dsr: WordBool readonly dispid 5;
    procedure Unlock; dispid 6;
  end;

// *********************************************************************//
// The Class CoOmniRigX provides a Create and CreateRemote method to          
// create instances of the default interface IOmniRigX exposed by              
// the CoClass OmniRigX. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOmniRigX = class
    class function Create: IOmniRigX;
    class function CreateRemote(const MachineName: string): IOmniRigX;
  end;

  TOmniRigXRigTypeChange = procedure(Sender: TObject; RigNumber: Integer) of object;
  TOmniRigXStatusChange = procedure(Sender: TObject; RigNumber: Integer) of object;
  TOmniRigXParamsChange = procedure(Sender: TObject; RigNumber: Integer; Params: Integer) of object;
  TOmniRigXCustomReply = procedure(Sender: TObject; RigNumber: Integer; Command: OleVariant; 
                                                    Reply: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TOmniRigX
// Help String      : OmniRigX Object
// Default Interface: IOmniRigX
// Def. Intf. DISP? : No
// Event   Interface: IOmniRigXEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TOmniRigXProperties= class;
{$ENDIF}
  TOmniRigX = class(TOleServer)
  private
    FOnVisibleChange: TNotifyEvent;
    FOnRigTypeChange: TOmniRigXRigTypeChange;
    FOnStatusChange: TOmniRigXStatusChange;
    FOnParamsChange: TOmniRigXParamsChange;
    FOnCustomReply: TOmniRigXCustomReply;
    FIntf:        IOmniRigX;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TOmniRigXProperties;
    function      GetServerProperties: TOmniRigXProperties;
{$ENDIF}
    function      GetDefaultInterface: IOmniRigX;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_InterfaceVersion: Integer;
    function  Get_SoftwareVersion: Integer;
    function  Get_Rig1: IRigX;
    function  Get_Rig2: IRigX;
    function  Get_DialogVisible: WordBool;
    procedure Set_DialogVisible(Value: WordBool);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IOmniRigX);
    procedure Disconnect; override;
    property  DefaultInterface: IOmniRigX read GetDefaultInterface;
    property InterfaceVersion: Integer read Get_InterfaceVersion;
    property SoftwareVersion: Integer read Get_SoftwareVersion;
    property Rig1: IRigX read Get_Rig1;
    property Rig2: IRigX read Get_Rig2;
    property DialogVisible: WordBool read Get_DialogVisible write Set_DialogVisible;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TOmniRigXProperties read GetServerProperties;
{$ENDIF}
    property OnVisibleChange: TNotifyEvent read FOnVisibleChange write FOnVisibleChange;
    property OnRigTypeChange: TOmniRigXRigTypeChange read FOnRigTypeChange write FOnRigTypeChange;
    property OnStatusChange: TOmniRigXStatusChange read FOnStatusChange write FOnStatusChange;
    property OnParamsChange: TOmniRigXParamsChange read FOnParamsChange write FOnParamsChange;
    property OnCustomReply: TOmniRigXCustomReply read FOnCustomReply write FOnCustomReply;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TOmniRigX
// (このオブジェクトは IDE のプロパティ インスペクターからサーバーの     
// プロパティを変更する場合に使われます)
// *********************************************************************//
 TOmniRigXProperties = class(TPersistent)
  private
    FServer:    TOmniRigX;
    function    GetDefaultInterface: IOmniRigX;
    constructor Create(AServer: TOmniRigX);
  protected
    function  Get_InterfaceVersion: Integer;
    function  Get_SoftwareVersion: Integer;
    function  Get_Rig1: IRigX;
    function  Get_Rig2: IRigX;
    function  Get_DialogVisible: WordBool;
    procedure Set_DialogVisible(Value: WordBool);
  public
    property DefaultInterface: IOmniRigX read GetDefaultInterface;
  published
    property DialogVisible: WordBool read Get_DialogVisible write Set_DialogVisible;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoRigX provides a Create and CreateRemote method to          
// create instances of the default interface IRigX exposed by              
// the CoClass RigX. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRigX = class
    class function Create: IRigX;
    class function CreateRemote(const MachineName: string): IRigX;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TRigX
// Help String      : Rig Object
// Default Interface: IRigX
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TRigXProperties= class;
{$ENDIF}
  TRigX = class(TOleServer)
  private
    FIntf:        IRigX;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TRigXProperties;
    function      GetServerProperties: TRigXProperties;
{$ENDIF}
    function      GetDefaultInterface: IRigX;
  protected
    procedure InitServerData; override;
    function  Get_RigType: WideString;
    function  Get_ReadableParams: Integer;
    function  Get_WriteableParams: Integer;
    function  Get_Status: RigStatusX;
    function  Get_StatusStr: WideString;
    function  Get_Freq: Integer;
    procedure Set_Freq(Value: Integer);
    function  Get_FreqA: Integer;
    procedure Set_FreqA(Value: Integer);
    function  Get_FreqB: Integer;
    procedure Set_FreqB(Value: Integer);
    function  Get_RitOffset: Integer;
    procedure Set_RitOffset(Value: Integer);
    function  Get_Pitch: Integer;
    procedure Set_Pitch(Value: Integer);
    function  Get_Vfo: RigParamX;
    procedure Set_Vfo(Value: RigParamX);
    function  Get_Split: RigParamX;
    procedure Set_Split(Value: RigParamX);
    function  Get_Rit: RigParamX;
    procedure Set_Rit(Value: RigParamX);
    function  Get_Xit: RigParamX;
    procedure Set_Xit(Value: RigParamX);
    function  Get_Tx: RigParamX;
    procedure Set_Tx(Value: RigParamX);
    function  Get_Mode: RigParamX;
    procedure Set_Mode(Value: RigParamX);
    function  Get_PortBits: IPortBits;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IRigX);
    procedure Disconnect; override;
    function  IsParamReadable(Param: RigParamX): WordBool;
    function  IsParamWriteable(Param: RigParamX): WordBool;
    procedure ClearRit;
    procedure SetSimplexMode(Freq: Integer);
    procedure SetSplitMode(RxFreq: Integer; TxFreq: Integer);
    function  FrequencyOfTone(Tone: Integer): Integer;
    procedure SendCustomCommand(Command: OleVariant; ReplyLength: Integer; ReplyEnd: OleVariant);
    function  GetRxFrequency: Integer;
    function  GetTxFrequency: Integer;
    property  DefaultInterface: IRigX read GetDefaultInterface;
    property RigType: WideString read Get_RigType;
    property ReadableParams: Integer read Get_ReadableParams;
    property WriteableParams: Integer read Get_WriteableParams;
    property Status: RigStatusX read Get_Status;
    property StatusStr: WideString read Get_StatusStr;
    property PortBits: IPortBits read Get_PortBits;
    property Freq: Integer read Get_Freq write Set_Freq;
    property FreqA: Integer read Get_FreqA write Set_FreqA;
    property FreqB: Integer read Get_FreqB write Set_FreqB;
    property RitOffset: Integer read Get_RitOffset write Set_RitOffset;
    property Pitch: Integer read Get_Pitch write Set_Pitch;
    property Vfo: RigParamX read Get_Vfo write Set_Vfo;
    property Split: RigParamX read Get_Split write Set_Split;
    property Rit: RigParamX read Get_Rit write Set_Rit;
    property Xit: RigParamX read Get_Xit write Set_Xit;
    property Tx: RigParamX read Get_Tx write Set_Tx;
    property Mode: RigParamX read Get_Mode write Set_Mode;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TRigXProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TRigX
// (このオブジェクトは IDE のプロパティ インスペクターからサーバーの     
// プロパティを変更する場合に使われます)
// *********************************************************************//
 TRigXProperties = class(TPersistent)
  private
    FServer:    TRigX;
    function    GetDefaultInterface: IRigX;
    constructor Create(AServer: TRigX);
  protected
    function  Get_RigType: WideString;
    function  Get_ReadableParams: Integer;
    function  Get_WriteableParams: Integer;
    function  Get_Status: RigStatusX;
    function  Get_StatusStr: WideString;
    function  Get_Freq: Integer;
    procedure Set_Freq(Value: Integer);
    function  Get_FreqA: Integer;
    procedure Set_FreqA(Value: Integer);
    function  Get_FreqB: Integer;
    procedure Set_FreqB(Value: Integer);
    function  Get_RitOffset: Integer;
    procedure Set_RitOffset(Value: Integer);
    function  Get_Pitch: Integer;
    procedure Set_Pitch(Value: Integer);
    function  Get_Vfo: RigParamX;
    procedure Set_Vfo(Value: RigParamX);
    function  Get_Split: RigParamX;
    procedure Set_Split(Value: RigParamX);
    function  Get_Rit: RigParamX;
    procedure Set_Rit(Value: RigParamX);
    function  Get_Xit: RigParamX;
    procedure Set_Xit(Value: RigParamX);
    function  Get_Tx: RigParamX;
    procedure Set_Tx(Value: RigParamX);
    function  Get_Mode: RigParamX;
    procedure Set_Mode(Value: RigParamX);
    function  Get_PortBits: IPortBits;
  public
    property DefaultInterface: IRigX read GetDefaultInterface;
  published
    property Freq: Integer read Get_Freq write Set_Freq;
    property FreqA: Integer read Get_FreqA write Set_FreqA;
    property FreqB: Integer read Get_FreqB write Set_FreqB;
    property RitOffset: Integer read Get_RitOffset write Set_RitOffset;
    property Pitch: Integer read Get_Pitch write Set_Pitch;
    property Vfo: RigParamX read Get_Vfo write Set_Vfo;
    property Split: RigParamX read Get_Split write Set_Split;
    property Rit: RigParamX read Get_Rit write Set_Rit;
    property Xit: RigParamX read Get_Xit write Set_Xit;
    property Tx: RigParamX read Get_Tx write Set_Tx;
    property Mode: RigParamX read Get_Mode write Set_Mode;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoPortBits provides a Create and CreateRemote method to          
// create instances of the default interface IPortBits exposed by              
// the CoClass PortBits. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPortBits = class
    class function Create: IPortBits;
    class function CreateRemote(const MachineName: string): IPortBits;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TPortBits
// Help String      : PortBits Object
// Default Interface: IPortBits
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TPortBitsProperties= class;
{$ENDIF}
  TPortBits = class(TOleServer)
  private
    FIntf:        IPortBits;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TPortBitsProperties;
    function      GetServerProperties: TPortBitsProperties;
{$ENDIF}
    function      GetDefaultInterface: IPortBits;
  protected
    procedure InitServerData; override;
    function  Get_Rts: WordBool;
    procedure Set_Rts(Value: WordBool);
    function  Get_Dtr: WordBool;
    procedure Set_Dtr(Value: WordBool);
    function  Get_Cts: WordBool;
    function  Get_Dsr: WordBool;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IPortBits);
    procedure Disconnect; override;
    function  Lock: WordBool;
    procedure Unlock;
    property  DefaultInterface: IPortBits read GetDefaultInterface;
    property Cts: WordBool read Get_Cts;
    property Dsr: WordBool read Get_Dsr;
    property Rts: WordBool read Get_Rts write Set_Rts;
    property Dtr: WordBool read Get_Dtr write Set_Dtr;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TPortBitsProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TPortBits
// (このオブジェクトは IDE のプロパティ インスペクターからサーバーの     
// プロパティを変更する場合に使われます)
// *********************************************************************//
 TPortBitsProperties = class(TPersistent)
  private
    FServer:    TPortBits;
    function    GetDefaultInterface: IPortBits;
    constructor Create(AServer: TPortBits);
  protected
    function  Get_Rts: WordBool;
    procedure Set_Rts(Value: WordBool);
    function  Get_Dtr: WordBool;
    procedure Set_Dtr(Value: WordBool);
    function  Get_Cts: WordBool;
    function  Get_Dsr: WordBool;
  public
    property DefaultInterface: IPortBits read GetDefaultInterface;
  published
    property Rts: WordBool read Get_Rts write Set_Rts;
    property Dtr: WordBool read Get_Dtr write Set_Dtr;
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

implementation

uses ComObj;

class function CoOmniRigX.Create: IOmniRigX;
begin
  Result := CreateComObject(CLASS_OmniRigX) as IOmniRigX;
end;

class function CoOmniRigX.CreateRemote(const MachineName: string): IOmniRigX;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OmniRigX) as IOmniRigX;
end;

procedure TOmniRigX.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{0839E8C6-ED30-4950-8087-966F970F0CAE}';
    IntfIID:   '{501A2858-3331-467A-837A-989FDEDACC7D}';
    EventIID:  '{2219175F-E561-47E7-AD17-73C4D8891AA1}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TOmniRigX.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IOmniRigX;
  end;
end;

procedure TOmniRigX.ConnectTo(svrIntf: IOmniRigX);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TOmniRigX.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TOmniRigX.GetDefaultInterface: IOmniRigX;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface が NULL です。コンポーネントはサーバーに接続できませんでした。操作を始める前に ''Connect'' または ''ConnectTo'' を呼ぶ必要があります。');
  Result := FIntf;
end;

constructor TOmniRigX.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TOmniRigXProperties.Create(Self);
{$ENDIF}
end;

destructor TOmniRigX.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TOmniRigX.GetServerProperties: TOmniRigXProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TOmniRigX.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnVisibleChange) then
            FOnVisibleChange(Self);
   2: if Assigned(FOnRigTypeChange) then
            FOnRigTypeChange(Self, Params[0] {Integer});
   3: if Assigned(FOnStatusChange) then
            FOnStatusChange(Self, Params[0] {Integer});
   4: if Assigned(FOnParamsChange) then
            FOnParamsChange(Self, Params[1] {Integer}, Params[0] {Integer});
   5: if Assigned(FOnCustomReply) then
            FOnCustomReply(Self, Params[2] {OleVariant}, Params[1] {OleVariant}, Params[0] {Integer});
  end; {case DispID}
end;

function  TOmniRigX.Get_InterfaceVersion: Integer;
begin
  Result := DefaultInterface.InterfaceVersion;
end;

function  TOmniRigX.Get_SoftwareVersion: Integer;
begin
  Result := DefaultInterface.SoftwareVersion;
end;

function  TOmniRigX.Get_Rig1: IRigX;
begin
  Result := DefaultInterface.Rig1;
end;

function  TOmniRigX.Get_Rig2: IRigX;
begin
  Result := DefaultInterface.Rig2;
end;

function  TOmniRigX.Get_DialogVisible: WordBool;
begin
  Result := DefaultInterface.DialogVisible;
end;

procedure TOmniRigX.Set_DialogVisible(Value: WordBool);
begin
  DefaultInterface.DialogVisible := Value;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TOmniRigXProperties.Create(AServer: TOmniRigX);
begin
  inherited Create;
  FServer := AServer;
end;

function TOmniRigXProperties.GetDefaultInterface: IOmniRigX;
begin
  Result := FServer.DefaultInterface;
end;

function  TOmniRigXProperties.Get_InterfaceVersion: Integer;
begin
  Result := DefaultInterface.InterfaceVersion;
end;

function  TOmniRigXProperties.Get_SoftwareVersion: Integer;
begin
  Result := DefaultInterface.SoftwareVersion;
end;

function  TOmniRigXProperties.Get_Rig1: IRigX;
begin
  Result := DefaultInterface.Rig1;
end;

function  TOmniRigXProperties.Get_Rig2: IRigX;
begin
  Result := DefaultInterface.Rig2;
end;

function  TOmniRigXProperties.Get_DialogVisible: WordBool;
begin
  Result := DefaultInterface.DialogVisible;
end;

procedure TOmniRigXProperties.Set_DialogVisible(Value: WordBool);
begin
  DefaultInterface.DialogVisible := Value;
end;

{$ENDIF}

class function CoRigX.Create: IRigX;
begin
  Result := CreateComObject(CLASS_RigX) as IRigX;
end;

class function CoRigX.CreateRemote(const MachineName: string): IRigX;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RigX) as IRigX;
end;

procedure TRigX.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{78AECFA2-3F52-4E39-98D3-1646C00A6234}';
    IntfIID:   '{D30A7E51-5862-45B7-BFFA-6415917DA0CF}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TRigX.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IRigX;
  end;
end;

procedure TRigX.ConnectTo(svrIntf: IRigX);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TRigX.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TRigX.GetDefaultInterface: IRigX;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface が NULL です。コンポーネントはサーバーに接続できませんでした。操作を始める前に ''Connect'' または ''ConnectTo'' を呼ぶ必要があります。');
  Result := FIntf;
end;

constructor TRigX.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TRigXProperties.Create(Self);
{$ENDIF}
end;

destructor TRigX.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TRigX.GetServerProperties: TRigXProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function  TRigX.Get_RigType: WideString;
begin
  Result := DefaultInterface.RigType;
end;

function  TRigX.Get_ReadableParams: Integer;
begin
  Result := DefaultInterface.ReadableParams;
end;

function  TRigX.Get_WriteableParams: Integer;
begin
  Result := DefaultInterface.WriteableParams;
end;

function  TRigX.Get_Status: RigStatusX;
begin
  Result := DefaultInterface.Status;
end;

function  TRigX.Get_StatusStr: WideString;
begin
  Result := DefaultInterface.StatusStr;
end;

function  TRigX.Get_Freq: Integer;
begin
  Result := DefaultInterface.Freq;
end;

procedure TRigX.Set_Freq(Value: Integer);
begin
  DefaultInterface.Freq := Value;
end;

function  TRigX.Get_FreqA: Integer;
begin
  Result := DefaultInterface.FreqA;
end;

procedure TRigX.Set_FreqA(Value: Integer);
begin
  DefaultInterface.FreqA := Value;
end;

function  TRigX.Get_FreqB: Integer;
begin
  Result := DefaultInterface.FreqB;
end;

procedure TRigX.Set_FreqB(Value: Integer);
begin
  DefaultInterface.FreqB := Value;
end;

function  TRigX.Get_RitOffset: Integer;
begin
  Result := DefaultInterface.RitOffset;
end;

procedure TRigX.Set_RitOffset(Value: Integer);
begin
  DefaultInterface.RitOffset := Value;
end;

function  TRigX.Get_Pitch: Integer;
begin
  Result := DefaultInterface.Pitch;
end;

procedure TRigX.Set_Pitch(Value: Integer);
begin
  DefaultInterface.Pitch := Value;
end;

function  TRigX.Get_Vfo: RigParamX;
begin
  Result := DefaultInterface.Vfo;
end;

procedure TRigX.Set_Vfo(Value: RigParamX);
begin
  DefaultInterface.Vfo := Value;
end;

function  TRigX.Get_Split: RigParamX;
begin
  Result := DefaultInterface.Split;
end;

procedure TRigX.Set_Split(Value: RigParamX);
begin
  DefaultInterface.Split := Value;
end;

function  TRigX.Get_Rit: RigParamX;
begin
  Result := DefaultInterface.Rit;
end;

procedure TRigX.Set_Rit(Value: RigParamX);
begin
  DefaultInterface.Rit := Value;
end;

function  TRigX.Get_Xit: RigParamX;
begin
  Result := DefaultInterface.Xit;
end;

procedure TRigX.Set_Xit(Value: RigParamX);
begin
  DefaultInterface.Xit := Value;
end;

function  TRigX.Get_Tx: RigParamX;
begin
  Result := DefaultInterface.Tx;
end;

procedure TRigX.Set_Tx(Value: RigParamX);
begin
  DefaultInterface.Tx := Value;
end;

function  TRigX.Get_Mode: RigParamX;
begin
  Result := DefaultInterface.Mode;
end;

procedure TRigX.Set_Mode(Value: RigParamX);
begin
  DefaultInterface.Mode := Value;
end;

function  TRigX.Get_PortBits: IPortBits;
begin
  Result := DefaultInterface.PortBits;
end;

function  TRigX.IsParamReadable(Param: RigParamX): WordBool;
begin
  Result := DefaultInterface.IsParamReadable(Param);
end;

function  TRigX.IsParamWriteable(Param: RigParamX): WordBool;
begin
  Result := DefaultInterface.IsParamWriteable(Param);
end;

procedure TRigX.ClearRit;
begin
  DefaultInterface.ClearRit;
end;

procedure TRigX.SetSimplexMode(Freq: Integer);
begin
  DefaultInterface.SetSimplexMode(Freq);
end;

procedure TRigX.SetSplitMode(RxFreq: Integer; TxFreq: Integer);
begin
  DefaultInterface.SetSplitMode(RxFreq, TxFreq);
end;

function  TRigX.FrequencyOfTone(Tone: Integer): Integer;
begin
  Result := DefaultInterface.FrequencyOfTone(Tone);
end;

procedure TRigX.SendCustomCommand(Command: OleVariant; ReplyLength: Integer; ReplyEnd: OleVariant);
begin
  DefaultInterface.SendCustomCommand(Command, ReplyLength, ReplyEnd);
end;

function  TRigX.GetRxFrequency: Integer;
begin
  Result := DefaultInterface.GetRxFrequency;
end;

function  TRigX.GetTxFrequency: Integer;
begin
  Result := DefaultInterface.GetTxFrequency;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TRigXProperties.Create(AServer: TRigX);
begin
  inherited Create;
  FServer := AServer;
end;

function TRigXProperties.GetDefaultInterface: IRigX;
begin
  Result := FServer.DefaultInterface;
end;

function  TRigXProperties.Get_RigType: WideString;
begin
  Result := DefaultInterface.RigType;
end;

function  TRigXProperties.Get_ReadableParams: Integer;
begin
  Result := DefaultInterface.ReadableParams;
end;

function  TRigXProperties.Get_WriteableParams: Integer;
begin
  Result := DefaultInterface.WriteableParams;
end;

function  TRigXProperties.Get_Status: RigStatusX;
begin
  Result := DefaultInterface.Status;
end;

function  TRigXProperties.Get_StatusStr: WideString;
begin
  Result := DefaultInterface.StatusStr;
end;

function  TRigXProperties.Get_Freq: Integer;
begin
  Result := DefaultInterface.Freq;
end;

procedure TRigXProperties.Set_Freq(Value: Integer);
begin
  DefaultInterface.Freq := Value;
end;

function  TRigXProperties.Get_FreqA: Integer;
begin
  Result := DefaultInterface.FreqA;
end;

procedure TRigXProperties.Set_FreqA(Value: Integer);
begin
  DefaultInterface.FreqA := Value;
end;

function  TRigXProperties.Get_FreqB: Integer;
begin
  Result := DefaultInterface.FreqB;
end;

procedure TRigXProperties.Set_FreqB(Value: Integer);
begin
  DefaultInterface.FreqB := Value;
end;

function  TRigXProperties.Get_RitOffset: Integer;
begin
  Result := DefaultInterface.RitOffset;
end;

procedure TRigXProperties.Set_RitOffset(Value: Integer);
begin
  DefaultInterface.RitOffset := Value;
end;

function  TRigXProperties.Get_Pitch: Integer;
begin
  Result := DefaultInterface.Pitch;
end;

procedure TRigXProperties.Set_Pitch(Value: Integer);
begin
  DefaultInterface.Pitch := Value;
end;

function  TRigXProperties.Get_Vfo: RigParamX;
begin
  Result := DefaultInterface.Vfo;
end;

procedure TRigXProperties.Set_Vfo(Value: RigParamX);
begin
  DefaultInterface.Vfo := Value;
end;

function  TRigXProperties.Get_Split: RigParamX;
begin
  Result := DefaultInterface.Split;
end;

procedure TRigXProperties.Set_Split(Value: RigParamX);
begin
  DefaultInterface.Split := Value;
end;

function  TRigXProperties.Get_Rit: RigParamX;
begin
  Result := DefaultInterface.Rit;
end;

procedure TRigXProperties.Set_Rit(Value: RigParamX);
begin
  DefaultInterface.Rit := Value;
end;

function  TRigXProperties.Get_Xit: RigParamX;
begin
  Result := DefaultInterface.Xit;
end;

procedure TRigXProperties.Set_Xit(Value: RigParamX);
begin
  DefaultInterface.Xit := Value;
end;

function  TRigXProperties.Get_Tx: RigParamX;
begin
  Result := DefaultInterface.Tx;
end;

procedure TRigXProperties.Set_Tx(Value: RigParamX);
begin
  DefaultInterface.Tx := Value;
end;

function  TRigXProperties.Get_Mode: RigParamX;
begin
  Result := DefaultInterface.Mode;
end;

procedure TRigXProperties.Set_Mode(Value: RigParamX);
begin
  DefaultInterface.Mode := Value;
end;

function  TRigXProperties.Get_PortBits: IPortBits;
begin
  Result := DefaultInterface.PortBits;
end;

{$ENDIF}

class function CoPortBits.Create: IPortBits;
begin
  Result := CreateComObject(CLASS_PortBits) as IPortBits;
end;

class function CoPortBits.CreateRemote(const MachineName: string): IPortBits;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PortBits) as IPortBits;
end;

procedure TPortBits.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{B786DE29-3B3D-4C66-B7C4-547F9A77A21D}';
    IntfIID:   '{3DEE2CC8-1EA3-46E7-B8B4-3E7321F2446A}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TPortBits.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IPortBits;
  end;
end;

procedure TPortBits.ConnectTo(svrIntf: IPortBits);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TPortBits.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TPortBits.GetDefaultInterface: IPortBits;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface が NULL です。コンポーネントはサーバーに接続できませんでした。操作を始める前に ''Connect'' または ''ConnectTo'' を呼ぶ必要があります。');
  Result := FIntf;
end;

constructor TPortBits.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TPortBitsProperties.Create(Self);
{$ENDIF}
end;

destructor TPortBits.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TPortBits.GetServerProperties: TPortBitsProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function  TPortBits.Get_Rts: WordBool;
begin
  Result := DefaultInterface.Rts;
end;

procedure TPortBits.Set_Rts(Value: WordBool);
begin
  DefaultInterface.Rts := Value;
end;

function  TPortBits.Get_Dtr: WordBool;
begin
  Result := DefaultInterface.Dtr;
end;

procedure TPortBits.Set_Dtr(Value: WordBool);
begin
  DefaultInterface.Dtr := Value;
end;

function  TPortBits.Get_Cts: WordBool;
begin
  Result := DefaultInterface.Cts;
end;

function  TPortBits.Get_Dsr: WordBool;
begin
  Result := DefaultInterface.Dsr;
end;

function  TPortBits.Lock: WordBool;
begin
  Result := DefaultInterface.Lock;
end;

procedure TPortBits.Unlock;
begin
  DefaultInterface.Unlock;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TPortBitsProperties.Create(AServer: TPortBits);
begin
  inherited Create;
  FServer := AServer;
end;

function TPortBitsProperties.GetDefaultInterface: IPortBits;
begin
  Result := FServer.DefaultInterface;
end;

function  TPortBitsProperties.Get_Rts: WordBool;
begin
  Result := DefaultInterface.Rts;
end;

procedure TPortBitsProperties.Set_Rts(Value: WordBool);
begin
  DefaultInterface.Rts := Value;
end;

function  TPortBitsProperties.Get_Dtr: WordBool;
begin
  Result := DefaultInterface.Dtr;
end;

procedure TPortBitsProperties.Set_Dtr(Value: WordBool);
begin
  DefaultInterface.Dtr := Value;
end;

function  TPortBitsProperties.Get_Cts: WordBool;
begin
  Result := DefaultInterface.Cts;
end;

function  TPortBitsProperties.Get_Dsr: WordBool;
begin
  Result := DefaultInterface.Dsr;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TOmniRigX, TRigX, TPortBits]);
end;

end.
