unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus, zLogGlobal, ComCtrls,
  Grids, UBasicMulti, UBasicScore, UALLJAMulti, UALLJAScore1, UOptions, UEditDialog,
  Trapedit, BGK32Lib, UzLogCW, Aligrid, UzLogVoice, Hemibtn, ShellAPI,
  OEdit, URigControl, UConsolePad, URenewThread, FngSingleInst, USpotClass,
  UMMTTY, UTTYConsole, UPaddleThread, MPlayer, UELogJapanese;


const MaxGridQSO = 20000;

const GLOBALSERIAL : integer = 0;
      ZLOCOUNT : integer = 0;


type

  TBasicEdit = class
  private
    colSerial : integer;
    colTime : integer;
    colCall : integer;
    colrcvdRST : integer;
    colrcvdNumber : integer;
    colMode : integer;
    colPower : integer;
    colNewPower : integer;
    colBand : integer;
    colPoint : integer;
    colMemo : integer;
    colOp : integer;
    colNewMulti1 : integer;
    colNewMulti2 : integer;
    colsentRST : integer;
    colsentNumber : integer;
    colCQ : integer;
    DispQSO : integer;
    function GetLeft(col : integer) : integer;
    Procedure WriteQSO(R: integer; aQSO : TQSO);
  public
    IndexArray : array[1..MaxGridQSO] of word; {contains the index to Log}
    SerialWid : integer;
    TimeWid : integer;
    CallSignWid : integer;
    rcvdRSTWid : integer;
    NumberWid : integer;
    BandWid : integer;
    ModeWid : integer;
    PowerWid : integer;
    NewPowerWid : integer;
    PointWid : integer;
    OpWid : integer;
    MemoWid : integer;
    NewMulti1Wid : integer;
    NewMulti2Wid : integer;

    DirectEdit : boolean;
    BeforeEdit : string; // temp var for directedit mode

    constructor Create; virtual;
    procedure SetDirectEdit(Direct : boolean);
    procedure Add(aQSO : TQSO); virtual;
    procedure ResetTopRow;
    procedure Renew; virtual;
    procedure SetGridWidth;
    procedure SetEditFields;
    function GetNewMulti1(aQSO : TQSO) : string; virtual;
    procedure RefreshScreen;
  end;

  TGeneralEdit = class(TBasicEdit)
  private
  public
    constructor Create; override;
    function GetNewMulti1(aQSO : TQSO) : string; override;
  end;

  TALLJAEdit = class(TBasicEdit)
  private
  public
    constructor Create; override;
    function GetNewMulti1(aQSO : TQSO) : string; override;
  end;

  TIARUEdit = class(TBasicEdit)
  private
  public
    constructor Create; override;
    function GetNewMulti1(aQSO : TQSO) : string; override;
  end;

  TARRLDXEdit = class(TBasicEdit)
  private
  public
    constructor Create; override;
    function GetNewMulti1(aQSO : TQSO) : string; override;
  end;

  TACAGEdit = class(TALLJAEdit)
  private
  public
    // constructor Create; override;
    function GetNewMulti1(aQSO : TQSO) : string; override;
  end;

  TWWEdit = class(TBasicEdit)
  private
  public
    constructor Create; override;
    function GetNewMulti1(aQSO : TQSO) : string; override;
  end;

  TKCJEdit = class(TWWEdit)
  private
  public
    //constructor Create; override;
    function GetNewMulti1(aQSO : TQSO) : string; override;
  end;

  TDXCCEdit = class(TBasicEdit)
  private
  public
    constructor Create; override;
    function GetNewMulti1(aQSO : TQSO) : string; override;
  end;

  TWPXEdit = class(TBasicEdit)
  private
  public
    constructor Create; override;
    function GetNewMulti1(aQSO : TQSO) : string; override;
  end;

  TJA0Edit = class(TWPXEdit)
  private
  public
    constructor Create; override;
  end;

  TSerialGeneralEdit = class(TWPXEdit)
  private
  public
    constructor Create; override;
    function GetNewMulti1(aQSO : TQSO) : string; override;
  end;

  TIOTAEdit = class(TBasicEdit)
  private
  public
    constructor Create; override;
    function GetNewMulti1(aQSO : TQSO) : string; override;
  end;

  TWanted = class
    Multi : string;
    Bands : set of TBand;
    constructor Create;
  end;

  TContest = class
    WantedList : TList;
    MultiForm : TBasicMulti;
    ScoreForm : TBasicScore;
    PastEditForm : TEditDialog;
    Name : string;
    SameExchange : boolean; // true by default. false when serial number etc
    MultiFound : boolean; // used in spacebarproc

    constructor Create(N : string); virtual;
    destructor Destroy; virtual;
    procedure PostWanted(S : string);
    procedure DelWanted(S : string);
    procedure ClearWanted;
    function QTHString : string; virtual;
    function ValidBand(B : TBand) : boolean; virtual;
    procedure LogQSO(var aQSO : TQSO; Local : boolean); virtual;
    procedure ShowScore; virtual;
    procedure ShowMulti; virtual;
    procedure Renew; virtual;
    {procedure LoadFromFile(FileName : string); virtual; }
    procedure EditCurrentRow; virtual;
    procedure ChangeBand(Up : boolean); virtual;
    procedure ChangeMode; virtual;
    procedure ChangePower; virtual;
    procedure DispExchangeOnOtherBands; virtual;
    procedure SpaceBarProc; virtual; {called when space is pressed when Callsign Edit
                                      is in focus AND the callsign is not DUPE}
    procedure SetNrSent(var aQSO : TQSO); virtual;
    procedure SetPoints(var aQSO : TQSO); virtual; {Sets QSO.points according to band/mode}
                                                {called from ChangeBand/ChangeMode}
    procedure SetBand(B : TBand); virtual; {JA0}
    procedure WriteSummary(filename : string); // creates summary file
    function CheckWinSummary(aQSO : TQSO) : string; virtual; // returns summary for checkcall etc.
    function ADIF_ExchangeRX_FieldName : string; virtual;
    function ADIF_ExchangeRX(aQSO : TQSO) : string; virtual;
    function ADIF_ExtraFieldName : string; virtual;
    function ADIF_ExtraField(aQSO : TQSO) : string; virtual;
    procedure ADIF_Export(FileName : string);
  end;

  TPedi = class(TContest)
    constructor Create(N : string); override;
  end;

  TALLJAContest = class(TContest)
    constructor Create(N : string); override;
    function QTHString : string; override;
    procedure DispExchangeOnOtherBands; override;
    function CheckWinSummary(aQSO : TQSO) : string; override;
  end;

  TKCJContest = class(TContest)
    constructor Create(N : string); override;
    function QTHString : string; override;
    //procedure DispExchangeOnOtherBands; override;
    function CheckWinSummary(aQSO : TQSO) : string; override;
  end;

  TACAGContest = class(TContest)
    constructor Create(N : string); override;
    procedure DispExchangeOnOtherBands; override;
  end;

  TFDContest = class(TContest)
    constructor Create(N : string); override;
    function QTHString : string; override;
    procedure DispExchangeOnOtherBands; override;
  end;

  TSixDownContest = class(TContest)
    constructor Create(N : string); override;
    function QTHString : string; override;
    procedure DispExchangeOnOtherBands; override;
  end;

  TGeneralContest = class(TContest)
    constructor Create(N : string); override;
    procedure SetPoints(var aQSO : TQSO); override;
  end;

  TCQWPXContest = class(TContest)
    constructor Create(N : string); override;
    function ADIF_ExtraFieldName : string; override;
    function ADIF_ExtraField(aQSO : TQSO) : string; override;
  end;

  TWAEContest = class(TContest)
    constructor Create(N : string); override;
    procedure SpaceBarProc; override;
  end;

  TIOTAContest = class(TContest)
    constructor Create(N : string); override;
    function QTHString : string; override;
    procedure SpaceBarProc; override;
  end;

  TARRL10Contest = class(TContest)
    constructor Create(N : string); override;
    function CheckWinSummary(aQSO : TQSO) : string; override;
  end;

  TJA0Contest = class(TContest)
    constructor Create(N : string); override;
    procedure SetBand(B : TBand); override;
    procedure Renew; override;
  end;

  TJA0ContestZero = class(TJA0Contest)
    constructor Create(N : string); override;
  end;

  TAPSprint = class(TContest)
    constructor Create(N : string); override;
  end;

  TCQWWContest = class(TContest)
    constructor Create(N : string); override;
    procedure SpaceBarProc; override;
    procedure ShowMulti; override;
    function CheckWinSummary(aQSO : TQSO) : string; override;
    function ADIF_ExchangeRX_FieldName : string; override;
  end;

  TIARUContest = class(TContest)
    constructor Create(N : string); override;
    //function CheckWinSummary(aQSO : TQSO) : string; override;
    procedure SpaceBarProc; override;
    function ADIF_ExchangeRX_FieldName : string; override;
  end;

  TJIDXContest = class(TCQWWContest)
    constructor Create(N : string); override;
    procedure SetPoints(var aQSO : TQSO); override;
  end;

  TJIDXContestDX = class(TContest)
    constructor Create(N : string); override;
    procedure SetPoints(var aQSO : TQSO); override;
  end;

  TARRLDXContestDX = class(TContest)
    constructor Create(N : string); override;
    function ADIF_ExchangeRX_FieldName : string; override;
  end;

  TARRLDXContestW = class(TContest)
    constructor Create(N : string); override;
    procedure SpaceBarProc; override;
    function ADIF_ExchangeRX_FieldName : string; override;
  end;

  TAllAsianContest = class(TContest)
    constructor Create(N : string); override;
    procedure SetPoints(var aQSO : TQSO); override;
    procedure SpaceBarProc; override;
    function ADIF_ExchangeRX_FieldName : string; override;
  end;



type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    FilePrintItem: TMenuItem;
    FilePrintSetupItem: TMenuItem;
    FileExitItem: TMenuItem;
    EditUndoItem: TMenuItem;
    EditCutItem: TMenuItem;
    EditCopyItem: TMenuItem;
    EditPasteItem: TMenuItem;
    StatusLine: TStatusBar;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    Grid: TStringGrid;
    PowerMenu: TPopupMenu;
    N1W1: TMenuItem;
    N2W1: TMenuItem;
    N5W1: TMenuItem;
    N10W1: TMenuItem;
    N20W1: TMenuItem;
    N25W1: TMenuItem;
    N50W1: TMenuItem;
    N100W1: TMenuItem;
    N200W1: TMenuItem;
    N500W1: TMenuItem;
    N1kW1: TMenuItem;
    BandMenu: TPopupMenu;
    N19MHz: TMenuItem;
    N35MHz: TMenuItem;
    N7MHz: TMenuItem;
    N14MHz: TMenuItem;
    N21MHz: TMenuItem;
    N28MHz: TMenuItem;
    N50MHz: TMenuItem;
    N144MHz: TMenuItem;
    N430MHz: TMenuItem;
    N1200MHz: TMenuItem;
    N2400MHz: TMenuItem;
    N5600MHz: TMenuItem;
    ModeMenu: TPopupMenu;
    CW1: TMenuItem;
    SSB1: TMenuItem;
    FM1: TMenuItem;
    AM1: TMenuItem;
    RTTY1: TMenuItem;
    Other1: TMenuItem;
    GridMenu: TPopupMenu;
    EditQSO: TMenuItem;
    DeleteQSO1: TMenuItem;
    MainToolBar: TPanel;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    MultiButton: TSpeedButton;
    SpeedButton8: TSpeedButton;
    CWToolBar: TPanel;
    LogButton: TSpeedButton;
    EditPanel: TPanel;
    RcvdRSTEdit: TEdit;
    BandEdit: TEdit;
    ModeEdit: TEdit;
    PointEdit: TEdit;
    PowerEdit: TEdit;
    OpEdit: TEdit;
    OptionsButton: TSpeedButton;
    OpMenu: TPopupMenu;
    SuperCheckButtpn: TSpeedButton;
    CWStopButton: TSpeedButton;
    CWPauseButton: TSpeedButton;
    SideToneButton: TSpeedButton;
    SpeedButton12: TSpeedButton;
    SpeedBar: TTrackBar;
    SpeedLabel: TLabel;
    Button1: TButton;
    CWPlayButton: TSpeedButton;
    Timer1: TTimer;
    InsertQSO1: TMenuItem;
    N10GHzup1: TMenuItem;
    Export1: TMenuItem;
    TXTSaveDialog: TSaveDialog;
    SerialEdit: TEdit;
    SpeedButton2: TSpeedButton;
    CWF1: THemisphereButton;
    CWF2: THemisphereButton;
    CWF3: THemisphereButton;
    CWF4: THemisphereButton;
    CWF5: THemisphereButton;
    CWF6: THemisphereButton;
    CWF7: THemisphereButton;
    CWF8: THemisphereButton;
    HemisphereButton8: THemisphereButton;
    HemisphereButton9: THemisphereButton;
    HemisphereButton10: THemisphereButton;
    Windows1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    N3: TMenuItem;
    HowtoUseHelp1: TMenuItem;
    SearchforHelpOn1: TMenuItem;
    Contents1: TMenuItem;
    Score1: TMenuItem;
    Multipliers1: TMenuItem;
    QSOrate1: TMenuItem;
    PacketCluster1: TMenuItem;
    SuperCheck1: TMenuItem;
    PartialCheck1: TMenuItem;
    GBand: TMenuItem;
    Changemode: TMenuItem;
    GOperator: TMenuItem;
    G1R9MHz: TMenuItem;
    G3R5MHz: TMenuItem;
    G7MHz: TMenuItem;
    G14MHz: TMenuItem;
    G21MHz: TMenuItem;
    G28MHz: TMenuItem;
    G50MHz: TMenuItem;
    G144MHz: TMenuItem;
    G430MHz: TMenuItem;
    G1200MHz: TMenuItem;
    G2400MHz: TMenuItem;
    G5600MHz: TMenuItem;
    G10GHz: TMenuItem;
    N5: TMenuItem;
    ZLinkmonitor1: TMenuItem;
    Options1: TMenuItem;
    CWFMenu: TPopupMenu;
    Edit1: TMenuItem;
    VoiceMenu: TPopupMenu;
    Edit2: TMenuItem;
    N10MHz1: TMenuItem;
    N18MHz1: TMenuItem;
    N24MHz1: TMenuItem;
    Backup1: TMenuItem;
    CWKeyboard1: TMenuItem;
    ZServer1: TMenuItem;
    SpeedButton7: TSpeedButton;
    Network1: TMenuItem;
    mnDownload: TMenuItem;
    mnMerge: TMenuItem;
    ConnecttoZServer1: TMenuItem;
    N6: TMenuItem;
    G10MHz: TMenuItem;
    G18MHz: TMenuItem;
    G24MHz: TMenuItem;
    CW2: TMenuItem;
    SSB2: TMenuItem;
    FM2: TMenuItem;
    AM2: TMenuItem;
    RTTY2: TMenuItem;
    Other2: TMenuItem;
    Clear1: TMenuItem;
    SendSpot1: TMenuItem;
    NewPowerEdit: TEdit;
    NewPowerMenu: TPopupMenu;
    P1: TMenuItem;
    L1: TMenuItem;
    M1: TMenuItem;
    H1: TMenuItem;
    CheckCall1: TMenuItem;
    CreateDupeCheckSheetZPRINT1: TMenuItem;
    memo1: TMenuItem;
    rst1: TMenuItem;
    callsign1: TMenuItem;
    View1: TMenuItem;
    ShowCurrentBandOnly: TMenuItem;
    SortbyTime1: TMenuItem;
    pushqso1: TMenuItem;
    pullqso1: TMenuItem;
    CallsignEdit: TOvrEdit;
    NumberEdit: TOvrEdit;
    MemoEdit: TOvrEdit;
    TimeEdit: TOvrEdit;
    DateEdit: TOvrEdit;
    ZServerIcon: TImage;
    memo21: TMenuItem;
    PrintLogSummaryzLog1: TMenuItem;
    GeneralSaveDialog: TSaveDialog;
    mPXListWPX: TMenuItem;
    mSummaryFile: TMenuItem;
    op1: TMenuItem;
    mChangePower: TMenuItem;
    H2: TMenuItem;
    M2: TMenuItem;
    L2: TMenuItem;
    P2: TMenuItem;
    RigControl1: TMenuItem;
    Console1: TMenuItem;
    MergeFile1: TMenuItem;
    RunningFrequencies1: TMenuItem;
    mnCheckCountry: TMenuItem;
    mnCheckMulti: TMenuItem;
    SSBToolBar: TPanel;
    VoiceStopButton: TSpeedButton;
    VoicePauseButton: TSpeedButton;
    SpeedButton15: TSpeedButton;
    VoicePlayButton: TSpeedButton;
    VoiceF1: THemisphereButton;
    VoiceF3: THemisphereButton;
    VoiceF2: THemisphereButton;
    VoiceF4: THemisphereButton;
    VoiceF5: THemisphereButton;
    VoiceF6: THemisphereButton;
    VoiceF7: THemisphereButton;
    VoiceF8: THemisphereButton;
    HemisphereButton1: THemisphereButton;
    CQRepeatVoice1: THemisphereButton;
    CQRepeatVoice2: THemisphereButton;
    Bandscope1: TMenuItem;
    mnChangeTXNr: TMenuItem;
    mnGridAddNewPX: TMenuItem;
    Togglerig1: TMenuItem;
    mnHideCWPhToolBar: TMenuItem;
    mnHideMenuToolbar: TMenuItem;
    Scratchsheet1: TMenuItem;
    OpenDialog1: TOpenDialog;
    IncreaseFontSize1: TMenuItem;
    mnMMTTY: TMenuItem;
    mnTTYConsole: TMenuItem;
    QTC1: TMenuItem;
    mnNewBandScope: TMenuItem;
    QuickReference1: TMenuItem;
    CreateELogJARL1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure ShowHint(Sender: TObject);
    procedure FileNew(Sender: TObject);
    procedure FileOpen(Sender: TObject);
    procedure FileSave(Sender: TObject);
    procedure FileSaveAs(Sender: TObject);
    procedure FilePrint(Sender: TObject);
    procedure FilePrintSetup(Sender: TObject);
    procedure FileExit(Sender: TObject);
    procedure EditUndo(Sender: TObject);
    procedure EditCut(Sender: TObject);
    procedure EditCopy(Sender: TObject);
    procedure EditPaste(Sender: TObject);
    procedure HelpContents(Sender: TObject);
    procedure HelpSearch(Sender: TObject);
    procedure HelpHowToUse(Sender: TObject);
    procedure HelpAbout(Sender: TObject);
    procedure CommonEditKeyProcess(Sender: TObject; var Key: Char);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure CallsignEditChange(Sender: TObject);
    procedure NumberEditChange(Sender: TObject);
    procedure PowerEditClick(Sender: TObject);
    procedure PowerMenuClick(Sender: TObject);
    procedure BandMenuClick(Sender: TObject);
    procedure BandEditClick(Sender: TObject);
    procedure ModeMenuClick(Sender: TObject);
    procedure MemoEditChange(Sender: TObject);
    procedure ModeEditClick(Sender: TObject);
    procedure GridMenuPopup(Sender: TObject);
    procedure DeleteQSO1Click(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditQSOClick(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GridDblClick(Sender: TObject);
    procedure PartialClick(Sender: TObject);
    procedure CallsignEditKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ScoreClick(Sender: TObject);
    procedure MultiClick(Sender: TObject);
    procedure RateClick(Sender: TObject);
    procedure LogButtonClick(Sender: TObject);
    procedure OptionsButtonClick(Sender: TObject);
    procedure SuperCheckButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CWFButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedBarChange(Sender: TObject);
    procedure SideToneButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CWStopButtonClick(Sender: TObject);
    procedure VoiceStopButtonClick(Sender: TObject);
    procedure SetCQ(CQ : boolean);
    procedure CQRepeatClick1(Sender: TObject);
    procedure CQRepeatClick2(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton15Click(Sender: TObject);
    procedure OpMenuClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CWPauseButtonClick(Sender: TObject);
    procedure CWPlayButtonClick(Sender: TObject);
    procedure RcvdRSTEditChange(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure InsertQSO1Click(Sender: TObject);
    procedure MemoEditKeyPress(Sender: TObject; var Key: Char);
    procedure VoiceFButtonClick(Sender: TObject);
    procedure TimeEditChange(Sender: TObject);
    procedure Export1Click(Sender: TObject);
    procedure ClusterClick(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure SpeedButton9Click(Sender: TObject);
    procedure SerialEditChange(Sender: TObject);
    procedure GridBandChangeClick(Sender: TObject);
    procedure ZLinkmonitor1Click(Sender: TObject);
    procedure Load1Click(Sender: TObject);
    procedure SortbyTime1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure DateEditChange(Sender: TObject);
    procedure TimeEditDblClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure CWF1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HemisphereButton8MouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Edit2Click(Sender: TObject);
    procedure VoiceF1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HemisphereButton1MouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Backup1Click(Sender: TObject);
    procedure CWKeyboard1Click(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure mnMergeClick(Sender: TObject);
    procedure ZServer1Click(Sender: TObject);
    procedure ConnecttoZServer1Click(Sender: TObject);
    procedure GridModeChangeClick(Sender: TObject);
    procedure GridOperatorClick(Sender: TObject);
    procedure SendSpot1Click(Sender: TObject);
    procedure NumberEditKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure NewPowerMenuClick(Sender: TObject);
    procedure NewPowerEditClick(Sender: TObject);
    procedure OpEditClick(Sender: TObject);
    procedure PowerEditKeyPress(Sender: TObject; var Key: Char);
    procedure PowerEditChange(Sender: TObject);
    procedure CheckCall1Click(Sender: TObject);
    procedure GridClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CreateDupeCheckSheetZPRINT1Click(Sender: TObject);
    procedure MemoHotKeyEnter(Sender: TObject);
    procedure memo1Click(Sender: TObject);
    procedure rst1Click(Sender: TObject);
    procedure callsign1Click(Sender: TObject);
    procedure ShowCurrentBandOnlyClick(Sender: TObject);
    procedure pushqso1Click(Sender: TObject);
    procedure pullqso1Click(Sender: TObject);
    procedure GridTopLeftChanged(Sender: TObject);
    procedure TXTSaveDialogTypeChange(Sender: TObject);
    procedure GridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure memo21Click(Sender: TObject);
    procedure StatusLineResize(Sender: TObject);
    procedure PrintLogSummaryzLog1Click(Sender: TObject);
    procedure CQRepeatVoice2Click(Sender: TObject);
    procedure CQRepeatVoice1Click(Sender: TObject);
    procedure mPXListWPXClick(Sender: TObject);
    procedure mSummaryFileClick(Sender: TObject);
    procedure op1Click(Sender: TObject);
    procedure GridPowerChangeClick(Sender: TObject);
    procedure RigControl1Click(Sender: TObject);
    procedure Console1Click(Sender: TObject);
    procedure MergeFile1Click(Sender: TObject);
    procedure RunningFrequencies1Click(Sender: TObject);
    procedure mnCheckCountryClick(Sender: TObject);
    procedure mnCheckMultiClick(Sender: TObject);
    procedure StatusLineDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure Bandscope1Click(Sender: TObject);
    procedure mnChangeTXNrClick(Sender: TObject);
    procedure GridKeyPress(Sender: TObject; var Key: Char);
    procedure mnGridAddNewPXClick(Sender: TObject);
    procedure GridSelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure GridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure GridGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: String);
    procedure Togglerig1Click(Sender: TObject);
    procedure mnHideCWPhToolBarClick(Sender: TObject);
    procedure mnHideMenuToolbarClick(Sender: TObject);
    procedure Scratchsheet1Click(Sender: TObject);
    procedure IncreaseFontSize1Click(Sender: TObject);
    procedure mnMMTTYClick(Sender: TObject);
    procedure mnTTYConsoleClick(Sender: TObject);
    procedure SwitchCWBank(Action : integer);
    procedure QTC1Click(Sender: TObject);
    procedure mnNewBandScopeClick(Sender: TObject);
    procedure QuickReference1Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure CreateELogJARL1Click(Sender: TObject);
  private
    TempQSOList : TList;
    clStatusLine : TColor;
    OldCallsign, OldNumber : string;
    defaultTextColor : TColor;
    procedure DeleteCurrentRow;
    Procedure MultipleDelete(A, B : LongInt);
  public
    EditScreen : TBasicEdit;
    LastFocus : TEdit;
    procedure LoadNewContestFromFile(FileName : string);
    procedure RenewCWToolBar;
    procedure RenewVoiceToolBar;
    procedure OnTabPress;
    procedure DownKeyPress;
    procedure MonitorPort;
    procedure PushQSO(aQSO : TQSO);
    procedure PullQSO;
    procedure SetR(var aQSO : TQSO); // RST
    procedure SetS(var aQSO : TQSO);

    //procedure SetQSOBand(var aQSO : TQSO; Up : boolean);
    function GetNextBand(BB : TBand; Up : boolean) : TBand;

    procedure SetQSOMode(var aQSO : TQSO);
    procedure WriteStatusLine(S : string; WriteConsole : boolean);
    procedure WriteStatusLineRed(S : string; WriteConsole : boolean);
    procedure CallsignSentProc; // called when callsign is sent;
    procedure Update10MinTimer; //10 min countdown
    procedure SetDispHeight(H : integer); // sets grid's row height 18..40 pts
    procedure ProcessConsoleCommand(S : string);
    procedure UpdateBand(B : TBand); // takes care of window disp
    procedure UpdateMode(M : TMode);
    {procedure LogQSO(aQSO : TQSO);  }
    function MergeFile(Filename : string) : integer; // merges filename to current data. returns #QSOs added
    function NewQSOID : integer;
    procedure DisableNetworkMenus;
    procedure EnableNetworkMenus;
    procedure SaveFileAndBackUp;
    procedure ReEvaluateCountDownTimer;
    procedure ReEvaluateQSYCount;
    procedure RestoreWindowStates;
    procedure RecordWindowStates;
    procedure SwitchLastQSOBandMode;
    procedure IncFontSize;
    procedure AutoInput(D : TBSData);
  end;

var
  MainForm: TMainForm;
  CurrentQSO: TQSO;

const
  MyContest : TContest = nil;

const DisplayedQSOs : integer = 15;


procedure StartDebugTimer;
procedure EndDebugTimer;

implementation

uses UPartials, UALLJAEditDialog, UAbout, URateDialog, UMenu, UACAGMulti,
  USuperCheck, UACAGScore, UALLJAScore, UWWMulti, UWWScore, UWWZone, UComm,
  UJIDXMulti, UJIDXScore, UJIDXScore2, UZLinkForm, UWPXMulti, UWPXScore,
  UPediScore, UCWKeyBoard, UJIDX_DX_Multi, UJIDX_DX_Score, UChat,
  UGeneralMulti2, UGeneralScore, USpotForm, UFDMulti, UARRLDXMulti,
  UARRLDXScore, UARRLWMulti, UAPSprintScore, UJA0Multi, UJA0Score,
  {UCheckCall,} UKCJMulti, USixDownMulti, USixDownScore, UIARUMulti,
  UIARUScore, UAllAsianScore, UIOTAMulti, {UIOTACategory,} UARRL10Multi,
  UARRL10Score, UFreqList, UCheckCall2, UCheckCountry, UCheckMulti,
  {ubandscope,} uBandScope2, UIntegerDialog, UNewPrefix, UKCJScore, UScratchSheet,
  UQTCForm, UWAEScore, UWAEMulti, UQuickRef;

{$R *.DFM}

const FirstTime : boolean = True;

var    Device_Selector : Word;

DebugTimer : TDateTime;

procedure StartDebugTimer;
begin
  DebugTimer := Now;
end;

procedure EndDebugTimer;
var T : TDateTime;
    ms : integer;
begin
  T := Now - DebugTimer;
  ms := Trunc(T*24*60*60*1000);
  MainForm.WriteStatusLine(IntToStr(ms), false);
end;

function TMainForm.NewQSOID : integer;
var tt, ss, rr : integer;
begin
  tt := Options.Settings._txnr;
  if tt > 21 then
    tt := 21;
  ss := GLOBALSERIAL;
  inc(GLOBALSERIAL);
  if GLOBALSERIAL > 9999 then
    GLOBALSERIAL := 0;
  rr := random(100);
  Result := tt*100000000+ss*10000+rr*100;
end;

function TMainForm.MergeFile(Filename : string) : integer;
var Q : TQSO;
    f : file of TQSOdata;
    i, j, merged : integer;
    boo : boolean;
begin
  merged := 0;
  Q := TQSO.Create;
  System.assign(f, FileName);
  reset(f);
  read(f,Q.QSO); // first qso comment
  for i := 1 to FileSize(f)-1 do
    begin
      read(f,Q.QSO);
      boo := False;
      for j := 1 to Log.TotalQSO do
        if SameQSO(Q, TQSO(Log.List[j])) then
          begin
            boo := True;
            break;
          end;
      if boo = False then
          begin
            Log.Add(Q);
            inc(merged);
          end;
    end;
  System.close(f);
  Q.Free;
  Result := merged;
end;

procedure TMainForm.ReEvaluateCountDownTimer;
var mytx, i : integer;
    TL : TList;
    Q, QQ : TQSO;
begin

  TL := TList.Create;
  mytx := Options.GetTXNr;
  for i := 1 to Log.TotalQSO do
    if TQSO(Log.List[i]).QSO.TX = mytx then
      TL.Add(TQSO(Log.List[i]));
  Q := nil;
  if TL.Count = 0 then
    begin
      CountDownStartTime := 0;
      exit;
    end;
  Q := TQSO(TL[TL.Count-1]);
  for i := TL.Count - 2 downto 0 do // if there's only 1 qso then it won't loop
    begin
      QQ := TQSO(TL[i]);
      if QQ.QSO.Band <> Q.QSO.Band then
        begin
          CountDownStartTime := Q.QSO.Time;
          break;
        end
      else
        Q := QQ;
    end;
  CountDownStartTime := Q.QSO.Time;
  TL.Free;
end;

procedure TMainForm.ReEvaluateQSYCount;
var mytx, i : integer;
    TL : TList;
    Q, QQ : TQSO;
    aTime : TDateTime;
    Hr, Min, Sec, mSec : word;
begin
  if Options.Settings._qsycount = false then
    exit;

  TL := TList.Create;
  mytx := Options.GetTXNr;
  for i := 1 to Log.TotalQSO do
    if TQSO(Log.List[i]).QSO.TX = mytx then
      TL.Add(TQSO(Log.List[i]));
  Q := nil;
  QSYCount := 0;
  if TL.Count = 0 then
    exit;

  Q := TQSO(TL[TL.Count-1]);

  aTime := CurrentTime;
  DecodeTime(aTime, Hr, Min, Sec, MSec);
  aTime := EncodeTime(Hr, 0, 0, 0);
  aTime := Int(CurrentTime) + aTime;

  for i := TL.Count - 2 downto 0 do // if there's only 1 qso then it won't loop
    begin
      QQ := TQSO(TL[i]);
      if QQ.QSO.Time < aTime then
        break;
      if QQ.QSO.Band <> Q.QSO.Band then
        Inc(QSYCount);
      Q := QQ;
    end;

  TL.Free;
end;

{procedure TMainForm.ReEvaluateCountDownTimer;
var t, mytx, i, j : integer;
    MostRecentQSO, Q1, Q2 : TQSO;
begin
  if Log.TotalQSO > 0 then
    begin
      t := Log.TotalQSO;
      mytx := Options.GetTXnr;

      MostRecentQSO := nil;
      for i := t downto 1 do
        begin
          if TQSO(Log.List[i]).QSO.TX = mytx then
            begin
              MostRecentQSO := TQSO(Log.List[i]);
              break;
            end;
        end;
      if MostRecentQSO = nil then
        begin
          CountDownStartTime := 0;
          exit;
        end
      else
        begin
          if Now - MostRecentQSO.QSO.Time > 10.0/(60*24) then
            CountDownStartTime := 0
          else
            begin
              Q2 := MostRecentQSO;
              for j := i - 1 downto 1 do
                begin
                  Q1 := TQSO(Log.List[j]);
                  if Q1.QSO.TX = mytx then
                    begin
                      if Q2.QSO.Band <> Q1.QSO.Band then
                        begin
                          CountDownStartTime := Q2.QSO.Time;
                          exit;
                        end
                      else
                        begin
                          Q2 := Q1;
                        end;
                    end;
                  if Q1.QSO.Tx = mytx then
                    CountDownStartTime := Q1.QSO.Time
                  else
                    CountDownStartTime := Q2.QSO.Time;
                end;
            end;
        end;
    end;
end;}

procedure TMainForm.WriteStatusLine(S : string; WriteConsole : boolean);
begin
  if ContainsDoubleByteChar(S) then
    begin
      StatusLine.Font.Name := '‚l‚r ‚oƒSƒVƒbƒN';
      StatusLine.Font.Charset := 128;  // shift jis
    end
  else
    begin
      StatusLine.Font.Name := 'MS Sans Serif';
      StatusLine.Font.Charset := 0;  // shift jis
    end;
  clStatusLine := clWindowText;
  StatusLine.Panels[0].Text := S;
  if WriteConsole then
    ConsolePad.AddLine(S);
end;

procedure TMainForm.WriteStatusLineRed(S : string; WriteConsole : boolean);
begin
  clStatusLine := clRed;
  if ContainsDoubleByteChar(S) then
    begin
      StatusLine.Font.Name := '‚l‚r ‚oƒSƒVƒbƒN';
      StatusLine.Font.Charset := 128;  // shift jis
    end
  else
    begin
      StatusLine.Font.Name := 'MS Sans Serif';
      StatusLine.Font.Charset := 0;  // shift jis
    end;
  StatusLine.Panels[0].Text := S;
  if WriteConsole then
    ConsolePad.AddLine(S);
end;

procedure TMainForm.PushQSO(aQSO : TQSO);
const TEMPQSOMAX = 5;
var i : integer;
    Q : TQSO;
begin
  i := TempQSOList.Count;
  Q := TQSO.Create;
  Q.QSO := aQSO.QSO;
  TempQSOList.Insert(0, Q);
  if TempQSOList.Count > TEMPQSOMAX then
    begin
      i := TempQSOList.Count;
      Q := TQSO(TempQSOList[i-1]);
      TempQSOList.Delete(i-1);
      Q.Free;
    end;
end;

procedure TMainForm.PullQSO;
var i : integer;
begin
  i := TempQSOList.Count;
  if i > 0 then
    begin
      CurrentQSO.QSO := TQSO(TempQSOList[0]).QSO;

      CallsignEdit.Text := CurrentQSO.QSO.Callsign;
      NumberEdit.Text := CurrentQSO.QSO.NrRcvd;
      BandEdit.Text := MHzString[CurrentQSO.QSO.Band];
      PowerEdit.Text := CurrentQSO.PowerStr;
      NewPowerEdit.Text := NewPowerString[CurrentQSO.QSO.Power];
      PointEdit.Text := CurrentQSO.PointStr;
      RcvdRSTEdit.Text := CurrentQSO.RSTStr;
      CurrentQSO.UpdateTime;
      TimeEdit.Text := CurrentQSO.TimeStr;
      DateEdit.Text := CurrentQSO.DateStr;
      //ModeEdit.Text := CurrentQSO.ModeStr;

      ModeEdit.Text :=  ModeString[CurrentQSO.QSO.mode];

      If CurrentQSO.QSO.mode in [mSSB..mAM] then
        begin
          Grid.Align := alNone;
          SSBToolBar.Visible := True;
          CWToolBar.Visible := False;
          Grid.Align := alClient;
        end
      else
        begin
          Grid.Align := alNone;
          CWToolBar.Visible := True;
          SSBToolBar.Visible := False;
          Grid.Align := alClient;
        end;
      TempQSOList.Move(0,i-1);
    end;
end;

function GetPointerToMemory(BaseMem:dWord; Size:Word):Pointer;
begin
  { Device_Selector:=AllocSelector(DSeg);
   SetSelectorBase(Device_Selector,BaseMem shl 4);
   SetSelectorLimit(Device_Selector,Size);
   Result:=Ptr(Device_Selector,0); }
end;

procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
 { Params.Caption := PChar('zLog main window'); }
end;

function GetPort(address: Word): byte;
var
   bValue: Byte;
begin
   asm
      mov DX, address
      in  AL, DX
      mov bValue, AL
   end;
   result := bValue;
end;

procedure TMainForm.MonitorPort;
{
var p : byte;
    i : integer;
    str : string[10];
    }
begin
{
  p := GetPort(Options.Settings._cwport);
  str := '';
  for i := 1 to 8 do
    begin
      str := chr(($01 and p) + ord('0')) + str;
      p := p shr 1;
    end;
    }
end;

procedure TMainForm.RenewCWToolBar;
var i : integer;
begin
  if Options.SideTone then
    SideToneButton.Down := True
  else
    SideToneButton.Down := False;
  SpeedBar.Position := Options.Speed;
  SpeedLabel.Caption := IntToStr(Options.Speed)+' wpm';
  i := Options.Settings.CW.CurrentBank;
  CWF1.Hint := Options.CWMessage(i, 1);
  CWF2.Hint := Options.CWMessage(i, 2);
  CWF3.Hint := Options.CWMessage(i, 3);
  CWF4.Hint := Options.CWMessage(i, 4);
  CWF5.Hint := Options.CWMessage(i, 5);
  CWF6.Hint := Options.CWMessage(i, 6);
  CWF7.Hint := Options.CWMessage(i, 7);
  CWF8.Hint := Options.CWMessage(i, 8);
end;

procedure TMainForm.RenewVoiceToolBar;
begin
  {if Options.SideTone then
    SideToneButton.Down := True
  else
    SideToneButton.Down := False;
  SpeedBar.Position := Options.Speed;
  SpeedLabel.Caption := IntToStr(Options.Speed)+' wpm';
  CWF1.Hint := Options.CWMessage(1, 1);
  CWF2.Hint := Options.CWMessage(1, 2);
  CWF3.Hint := Options.CWMessage(1, 3);
  CWF4.Hint := Options.CWMessage(1, 4);
  CWF5.Hint := Options.CWMessage(1, 5);
  CWF6.Hint := Options.CWMessage(1, 6);
  CWF7.Hint := Options.CWMessage(1, 7);
  CWF8.Hint := Options.CWMessage(1, 8);}
end;

procedure TContest.SetBand(B : TBand);
begin
end;

procedure TContest.WriteSummary(filename : string); // creates summary file
var f : textfile;
    S : string;
begin
  if Log.Year = 0 then
    exit;
  assign(f, filename);
  rewrite(f);
  S := FillRight('Year:',12) + IntToStr(Log.Year);
  writeln(f, S);
  writeln(f);
  writeln(f, Name);
  writeln(f);
  S := FillRight('Callsign:',12) + Options.MyCall;
  writeln(f, S);
  writeln(f);
  writeln(f, 'Country: ');
  writeln(f);
  S := FillRight('Category:',12);
  if Options.MultiOp > 0 then
    S := S + 'Multi Operator  '
  else
    S := S + 'Single Operator  ';
  if Options.Band = 0 then
    S := S + 'All band'
  else
    S := S + MHzString[TBand(Ord(Options.Band)-1)];
  S := S + '  ';
  case Options.Mode of
    0 : S := S + 'Phone/CW';
    1 : S := S + 'CW';
    2 : S := S + 'Phone';
  end;
  writeln(f, S);
  writeln(f);
  writeln(f, 'Band(MHz)      QSOs         Points       Multi.');

  writeln(f, 'Total');
  writeln(f, 'Score');


  writeln(f);

  close(f);
end;

function TARRL10Contest.CheckWinSummary(aQSO : TQSO) : string; // returns summary for checkcall etc.
var str : string;
begin
  str := aQSO.CheckCallSummary;
  if aQSO.QSO.Mode = mCW then
    Insert('CW ', str, 5)
  else
    Insert('Ph ', str, 5);
  Result := str;
end;

{
function TIARUContest.CheckWinSummary(aQSO : TQSO) : string; // returns summary for checkcall etc.
var str : string;
begin
  str := aQSO.CheckCallSummary;
  if aQSO.QSO.Mode = mCW then
    Insert('CW ', str, 5)
  else
    Insert('Ph ', str, 5);
  Result := str;
end;
}

function TContest.CheckWinSummary(aQSO : TQSO) : string; // returns summary for checkcall etc.
begin
  Result := aQSO.CheckCallSummary;
end;

function TContest.QTHString : string;
begin
  Result := Options.Settings._city;
end;

procedure TContest.SetPoints(var aQSO : TQSO);
begin
end;

Procedure TContest.DispExchangeOnOtherBands;
var boo : boolean;
    j : integer;
    B : TBand;
begin
  boo := false;
  for j := 1 to Log.TotalQSO do
    begin
      if CurrentQSO.QSO.callsign = TQSO(Log.List[j]).QSO.callsign then
        begin
          boo := true;
          break;
        end;
    end;
  if boo then
    begin
      MainForm.NumberEdit.Text := TQSO(Log.List[j]).QSO.NrRcvd;
      CurrentQSO.QSO.NrRcvd := TQSO(Log.List[j]).QSO.NrRcvd;
    end
  else  {check SubLog 0.23}
    begin
      {for B := b19 to HiBand do
        begin
          for j := 1 to SubLog[B].TotalQSO do
            begin
              if CurrentQSO.QSO.callsign = TQSO(SubLog[B].List[j]).QSO.callsign then
                begin
                  MainForm.NumberEdit.Text := TQSO(SubLog[B].List[j]).QSO.NrRcvd;
                  CurrentQSO.QSO.NrRcvd := TQSO(SubLog[B].List[j]).QSO.NrRcvd;
                  exit;
                end;
            end;
        end;}
    end;
end;

Procedure TACAGContest.DispExchangeOnOtherBands;
var boo : boolean;
    j : integer;
    B : TBand;
    str : string;
begin
  boo := false;
  for j := 1 to Log.TotalQSO do
    begin
      if CurrentQSO.QSO.callsign = TQSO(Log.List[j]).QSO.callsign then
        begin
          boo := true;
          break;
        end;
    end;
  if boo then
    begin
      MainForm.NumberEdit.Text := TQSO(Log.List[j]).QSO.NrRcvd;
      CurrentQSO.QSO.NrRcvd := TQSO(Log.List[j]).QSO.NrRcvd;
    end
  else  {check SubLog 0.23}
    begin
      {for B := b19 to HiBand do
        begin
          for j := 1 to SubLog[B].TotalQSO do
            begin
              if CurrentQSO.QSO.callsign = TQSO(SubLog[B].List[j]).QSO.callsign then
                begin
                  MainForm.NumberEdit.Text := TQSO(SubLog[B].List[j]).QSO.NrRcvd;
                  CurrentQSO.QSO.NrRcvd := TQSO(SubLog[B].List[j]).QSO.NrRcvd;
                  exit;
                end;
            end;
        end;}
    end;

  // added for acag
  str := MainForm.NumberEdit.Text;
  if str <> '' then
    if str[length(str)] in ['H', 'M', 'L', 'P'] then
      begin
        MainForm.NumberEdit.SelStart := length(str) - 1;
        MainForm.NumberEdit.SelLength := 1;
      end;
end;

Procedure TALLJAContest.DispExchangeOnOtherBands;
var boo : boolean;
    j : integer;
    B : TBand;
    str : string;
begin
  boo := false;
  for j := 1 to Log.TotalQSO do
    begin
      if CurrentQSO.QSO.callsign = TQSO(Log.List[j]).QSO.callsign then
        begin
          boo := true;
          break;
        end;
    end;
  if boo then
    begin
      MainForm.NumberEdit.Text := TQSO(Log.List[j]).QSO.NrRcvd;
      CurrentQSO.QSO.NrRcvd := TQSO(Log.List[j]).QSO.NrRcvd;
    end
  else  {check SubLog 0.23}
    begin
      {for B := b19 to HiBand do
        begin
          for j := 1 to SubLog[B].TotalQSO do
            begin
              if CurrentQSO.QSO.callsign = TQSO(SubLog[B].List[j]).QSO.callsign then
                begin
                  MainForm.NumberEdit.Text := TQSO(SubLog[B].List[j]).QSO.NrRcvd;
                  CurrentQSO.QSO.NrRcvd := TQSO(SubLog[B].List[j]).QSO.NrRcvd;
                  exit;
                end;
            end;
        end; }
    end;

  // added for allja (same as acag)
  str := MainForm.NumberEdit.Text;
  if str <> '' then
    if str[length(str)] in ['H', 'M', 'L', 'P'] then
      begin
        MainForm.NumberEdit.SelStart := length(str) - 1;
        MainForm.NumberEdit.SelLength := 1;
      end;
end;

Procedure TFDContest.DispExchangeOnOtherBands;
var j : integer;
    B : TBand;
    str : string;
    currshf : boolean;
    pastQSO, tempQSO : TQSO;

label med;

begin

  currshf := IsSHF(CurrentQSO.QSO.Band);
  pastQSO := nil;
  tempQSO := nil;

  for j := 1 to Log.TotalQSO do
    begin
      if CurrentQSO.QSO.callsign = TQSO(Log.List[j]).QSO.callsign then
        begin
          if currshf = IsSHF(TQSO(Log.List[j]).QSO.Band) then
            begin
              pastQSO := TQSO(Log.List[j]);
              break;
            end
          else
            begin
              TempQSO := TQSO(Log.List[j]);
            end;
        end;
    end;

  if pastQSO = nil then  {check SubLog 0.23}
    begin
      {
      for B := b19 to HiBand do
        begin
          for j := 1 to SubLog[B].TotalQSO do
            begin
              if CurrentQSO.QSO.callsign = TQSO(SubLog[B].List[j]).QSO.callsign then
                begin
                  if currshf = IsSHF(TQSO(SubLog[B].List[j]).QSO.Band) then
                    begin
                      pastQSO := TQSO(SubLog[B].List[j]);
                      goto med;
                    end
                  else
                    begin
                      tempQSO := TQSO(SubLog[B].List[j]);
                    end;
                end;
            end;
        end; }
    end;

med:
  if pastQSO <> nil then
    begin
      MainForm.NumberEdit.Text := pastQSO.QSO.NrRcvd;
      CurrentQSO.QSO.NrRcvd := pastQSO.QSO.NrRcvd;
    end
  else
    begin
      if tempQSO <> nil then
        begin
          if currshf = True then
            begin
              if length(tempQSO.QSO.NrRcvd) > 3 then
                str := '01' + ExtractPower(tempQSO.QSO.NrRcvd)
              else
                str := tempQSO.QSO.NrRcvd;
              MainForm.NumberEdit.Text := str;
              CurrentQSO.QSO.NrRcvd := str;
            end
          else
            begin
              str := ExtractKenNr(tempQSO.QSO.NrRcvd) + ExtractPower(tempQSO.QSO.NrRcvd);
              MainForm.NumberEdit.Text := str;
              CurrentQSO.QSO.NrRcvd := str;
            end;
        end
      else  // if tempQSO = nil
        begin
          exit;
        end;
    end;

  // added for acag
  str := MainForm.NumberEdit.Text;
  if str <> '' then
    if str[length(str)] in ['H', 'M', 'L', 'P'] then
      begin
        MainForm.NumberEdit.SelStart := length(str) - 1;
        MainForm.NumberEdit.SelLength := 1;
      end;
end;

Procedure TSixDownContest.DispExchangeOnOtherBands;
var j : integer;
    B : TBand;
    str : string;
    currshf : boolean;
    pastQSO, tempQSO : TQSO;

label med;

begin

  currshf := IsSHF(CurrentQSO.QSO.Band);
  pastQSO := nil;
  tempQSO := nil;

  for j := 1 to Log.TotalQSO do
    begin
      if CurrentQSO.QSO.callsign = TQSO(Log.List[j]).QSO.callsign then
        begin
          if currshf = IsSHF(TQSO(Log.List[j]).QSO.Band) then
            begin
              pastQSO := TQSO(Log.List[j]);
              break;
            end
          else
            begin
              TempQSO := TQSO(Log.List[j]);
            end;
        end;
    end;

  if pastQSO = nil then  {check SubLog 0.23}
    begin
      {for B := b19 to HiBand do
        begin
          for j := 1 to SubLog[B].TotalQSO do
            begin
              if CurrentQSO.QSO.callsign = TQSO(SubLog[B].List[j]).QSO.callsign then
                begin
                  if currshf = IsSHF(TQSO(SubLog[B].List[j]).QSO.Band) then
                    begin
                      pastQSO := TQSO(SubLog[B].List[j]);
                      goto med;
                    end
                  else
                    begin
                      tempQSO := TQSO(SubLog[B].List[j]);
                    end;
                end;
            end;
        end;}
    end;

med:
  if pastQSO <> nil then
    begin
      MainForm.NumberEdit.Text := pastQSO.QSO.NrRcvd;
      CurrentQSO.QSO.NrRcvd := pastQSO.QSO.NrRcvd;
    end
  else
    begin
      if tempQSO <> nil then
        begin
          if currshf = True then
            begin
              if length(tempQSO.QSO.NrRcvd) > 3 then
                str := '01' + ExtractPower(tempQSO.QSO.NrRcvd)
              else
                str := tempQSO.QSO.NrRcvd;
              MainForm.NumberEdit.Text := str;
              CurrentQSO.QSO.NrRcvd := str;
            end
          else
            begin
              str := ExtractKenNr(tempQSO.QSO.NrRcvd) + ExtractPower(tempQSO.QSO.NrRcvd);
              MainForm.NumberEdit.Text := str;
              CurrentQSO.QSO.NrRcvd := str;
            end;
        end
      else  // if tempQSO = nil
        begin
          exit;
        end;
    end;

  // added for acag
  str := MainForm.NumberEdit.Text;
  if str <> '' then
    if str[length(str)] in ['H', 'M', 'L', 'P'] then
      begin
        MainForm.NumberEdit.SelStart := length(str) - 1;
        MainForm.NumberEdit.SelLength := 1;
      end;
end;


Procedure TContest.SpaceBarProc;
begin
  MultiFound := False;
  if (MainForm.NumberEdit.Text = '') and (SameExchange = True)then
    begin
      DispExchangeOnOtherBands;
      if MainForm.NumberEdit.Text <> '' then
        MultiFound := True;
    end;
  if Options.Settings._entersuperexchange and (SuperCheck.Rcvd_Estimate <> '') then
    if MainForm.NumberEdit.Text = '' then
      if CoreCall(SuperCheck.FirstDataCall) = CoreCall(MainForm.CallsignEdit.Text) then
        begin
          MainForm.NumberEdit.Text := TrimRight(SuperCheck.Rcvd_Estimate);
          MultiFound := True;
        end;
  if CheckMulti.Visible then
    CheckMulti.Renew(CurrentQSO);
end;

Procedure TIOTAContest.SpaceBarProc;
begin
  inherited;
  if MultiFound and (IOTAMulti.ExtractMulti(CurrentQSO) = '') then // serial number
    MainForm.NumberEdit.Text := '';
end;

procedure TMainForm.SetR(var aQSO : TQSO); // r of RST
var i: integer;
begin
  i := aQSO.QSO.RSTRcvd;
  if i < 100 then
    begin
      if i > 50 then
        i := 10 + (i mod 10)
      else
        i := i + 10;
    end
  else
    begin
      if i > 500 then
        i := 100 + (i mod 100)
      else
        i := i + 100;
    end;
  aQSO.QSO.RSTRcvd := i;
  //RcvdRSTEdit.Text := CurrentQSO.RSTStr;
end;

procedure TMainForm.SetS(var aQSO : TQSO);
var i: integer;
begin
  i := aQSO.QSO.RSTRcvd;
  if i < 100 then
    begin
      if (i mod 10) = 9 then
        i := 10*(i div 10) + 1
      else
        i := i + 1;
    end
  else
    begin
      if ((i div 10) mod 10) = 9 then
        i := 100*(i div 100) + 10 + (i mod 10)
      else
        i := i + 10;
    end;
  aQSO.QSO.RSTRcvd := i;
  //RcvdRSTEdit.Text := CurrentQSO.RSTStr;
end;

(*
procedure TMainForm.SetQSOBand(var aQSO : TQSO; Up : boolean);
var B0, B : TBand;
    boo : boolean;
label xxx;
begin
  boo := false;
  for B := b19 to HiBand do
    begin
      if MainForm.BandMenu.Items[ord(B)].Visible and
         MainForm.BandMenu.Items[ord(B)].Enabled then
        boo := true;
    end;
  if boo = false then exit; {No QRVable and Contest allowed band}

  B0 := aQSO.QSO.band;
  if Up then
    begin
      if B0 = HiBand then
        B0 := b19
      else
        inc(B0);
      for B := B0 to HiBand do
        if MainForm.BandMenu.Items[ord(B)].Visible and
           MainForm.BandMenu.Items[ord(B)].Enabled then
             goto xxx;
      for B := b19 to B0 do
        if MainForm.BandMenu.Items[ord(B)].Visible and
           MainForm.BandMenu.Items[ord(B)].Enabled then
             goto xxx;
    end
  else
    begin
      if B0 = b19 then
        B0 := HiBand
      else
        dec(B0);
      for B := B0 downto b19 do
        if MainForm.BandMenu.Items[ord(B)].Visible and
           MainForm.BandMenu.Items[ord(B)].Enabled then
             goto xxx;
      for B := HiBand downto B0 do
        if MainForm.BandMenu.Items[ord(B)].Visible and
           MainForm.BandMenu.Items[ord(B)].Enabled then
             goto xxx;
    end;

xxx:
  aQSO.QSO.band := B;
end;
*)

function TMainForm.GetNextBand(BB : TBand; Up : boolean) : TBand;
var B0, B : TBand;
    boo : boolean;
label xxx;
label top;
begin
  Result := BB;


  boo := false;
  for B := b19 to HiBand do
    begin
      if MainForm.BandMenu.Items[ord(B)].Visible and
         MainForm.BandMenu.Items[ord(B)].Enabled then
        boo := true;
    end;
  if boo = false then exit; {No QRVable and Contest allowed band}

  B0 := BB;

top:
  if Up then
    begin
      if B0 = HiBand then
        B0 := b19
      else
        inc(B0);
      for B := B0 to HiBand do
        if MainForm.BandMenu.Items[ord(B)].Visible and
           MainForm.BandMenu.Items[ord(B)].Enabled then
             begin
               if Options.Settings._dontallowsameband and RigControl.CheckSameBand(B) then
                 begin
                 end
               else
                 goto xxx;
             end;
      for B := b19 to B0 do
        if MainForm.BandMenu.Items[ord(B)].Visible and
           MainForm.BandMenu.Items[ord(B)].Enabled then
             begin
               if Options.Settings._dontallowsameband and RigControl.CheckSameBand(B) then
                 begin
                 end
               else
                 goto xxx;
             end;
    end
  else
    begin
      if B0 = b19 then
        B0 := HiBand
      else
        dec(B0);
      for B := B0 downto b19 do
        if MainForm.BandMenu.Items[ord(B)].Visible and
           MainForm.BandMenu.Items[ord(B)].Enabled then
             begin
               if Options.Settings._dontallowsameband and RigControl.CheckSameBand(B) then
                 begin
                 end
               else
                 goto xxx;
             end;
      for B := HiBand downto B0 do
        if MainForm.BandMenu.Items[ord(B)].Visible and
           MainForm.BandMenu.Items[ord(B)].Enabled then
             begin
               if Options.Settings._dontallowsameband and RigControl.CheckSameBand(B) then
                 begin
                 end
               else
                 goto xxx;
             end;
    end;

xxx:

  if RigControl.Rig <> nil then // keep band within Rig
    begin
      if (B > RigControl.Rig._maxband) or (B < RigControl.Rig._minband) then
        begin
          B0 := B;
          goto top;
        end;
    end;

  Result := B;
end;

procedure TMainForm.BandMenuClick(Sender: TObject);
begin
(*
  Options.CurrentPower[CurrentQSO.QSO.Band] := CurrentQSO.QSO.Power;
  Options.CurrentPower2[CurrentQSO.QSO.Band] := CurrentQSO.QSO.Power2;

  BandEdit.Text := MHzString[Tband(TMenuItem(Sender).Tag)];
  CurrentQSO.QSO.band := Tband(TMenuItem(Sender).Tag);

  MyContest.SetPoints(CurrentQSO);
  MainForm.PointEdit.Text := CurrentQSO.PointStr; // ver 0.23

  ZLinkForm.SendBand; // ver 0.41

  if NewPowerEdit.Visible then
    begin
      CurrentQSO.QSO.Power := Options.CurrentPower[CurrentQSO.QSO.Band];
      Options.SetOpPower(CurrentQSO);
      NewPowerEdit.Text := CurrentQSO.NewPowerStr;
    end;

  if PowerEdit.Visible then
    begin
      CurrentQSO.QSO.Power2 := Options.CurrentPower2[CurrentQSO.QSO.Band];
      PowerEdit.Text := CurrentQSO.PowerStr;
    end;

  if MyContest.MultiForm.Visible then
    MyContest.MultiForm.Update;

  if PartialCheck.Visible then
    PartialCheck.Update(CurrentQSO);


  if ShowCurrentBandOnly.Checked then
    begin
      EditScreen.Renew;
      EditScreen.RefreshScreen;
    end;
*)

  UpdateBand(Tband(TMenuItem(Sender).Tag));

  if RigControl.Rig <> nil then
    begin
      RigControl.Rig.SetBand(CurrentQSO);
      if CurrentQSO.QSO.Mode = mSSB then
        RigControl.Rig.SetMode(CurrentQSO);
    end;

  LastFocus.SetFocus;
end;

procedure TMainForm.UpdateBand(B : TBand); // called from rigcontrol too
begin

  Options.CurrentPower[CurrentQSO.QSO.Band] := CurrentQSO.QSO.Power;
  Options.CurrentPower2[CurrentQSO.QSO.Band] := CurrentQSO.QSO.Power2;

  BandEdit.Text := MHzString[B];

  if MainForm.SerialEdit.Visible then
    if SerialContestType = SER_BAND then
      begin
        SerialArray[CurrentQSO.QSO.Band] := CurrentQSO.QSO.Serial;
        CurrentQSO.QSO.Serial := SerialArray[B];
        MainForm.SerialEdit.Text := CurrentQSO.SerialStr;
      end;

  CurrentQSO.QSO.band := B;

  {BGK32LIB._bandmask := (Options.Settings._BandData[B] * 16);
  BGK32LIB.UpdateDataPort; }
  RigControl.SetBandMask;

  if MyContest <> nil then
    MyContest.SetPoints(CurrentQSO);
  MainForm.PointEdit.Text := CurrentQSO.PointStr; // ver 0.23

  ZLinkForm.SendBand; // ver 0.41

  if NewPowerEdit.Visible then
    begin
      CurrentQSO.QSO.Power := Options.CurrentPower[B];
      Options.SetOpPower(CurrentQSO);
      NewPowerEdit.Text := CurrentQSO.NewPowerStr;
    end;

  if PowerEdit.Visible then
    begin
      CurrentQSO.QSO.Power2 := Options.CurrentPower2[B];
      // Options.SetOpPower(CurrentQSO);
      PowerEdit.Text := CurrentQSO.PowerStr;
    end;

  if MyContest <> nil then
    if MyContest.MultiForm.Visible then
      MyContest.MultiForm.Update;

  if PartialCheck.Visible then
    PartialCheck.Update(CurrentQSO);

  if ShowCurrentBandOnly.Checked then
    begin
      EditScreen.Renew;
      EditScreen.RefreshScreen;
    end;
  //LastFocus.SetFocus;
  //BandScope.SetBandMode(CurrentQSO.QSO.Band, CurrentQSO.QSO.Mode);
  BandScope2.SetBandMode(CurrentQSO.QSO.Band, CurrentQSO.QSO.Mode);

  if Options.Settings._countdown and (CountDownStartTime > 0) then
    WriteStatusLineRed('Less than 10 min since last QSY!', false);

  if RigControl.Rig = nil then
    ZLinkForm.SendFreqInfo(round(RigControl.TempFreq[B]*1000));
end;

procedure TMainForm.UpdateMode(M : TMode);
begin
  ModeEdit.Text := ModeString[M];
  CurrentQSO.QSO.mode := M;
  If M in [mSSB, mFM, mAM] then
    begin
      CurrentQSO.QSO.RSTrcvd := 59;
      CurrentQSO.QSO.RSTsent := 59;
      RcvdRSTEdit.Text := '59';
      Grid.Align := alNone;
      SSBToolBar.Visible := True;
      CWToolBar.Visible := False;
      Grid.Align := alClient;
    end
  else
    begin
      CurrentQSO.QSO.RSTrcvd := 599;
      CurrentQSO.QSO.RSTsent := 599;
      RcvdRSTEdit.Text := '599';
      Grid.Align := alNone;
      CWToolBar.Visible := True;
      SSBToolBar.Visible := False;
      Grid.Align := alClient;
    end;
  if MyContest <> nil then
    if MyContest.MultiForm.Visible then
      MyContest.MultiForm.Update;

  if MyContest <> nil then
    MyContest.SetPoints(CurrentQSO);
  MainForm.PointEdit.Text := CurrentQSO.PointStr;

  //BandScope.SetBandMode(CurrentQSO.QSO.Band, CurrentQSO.QSO.Mode);
  BandScope2.SetBandMode(CurrentQSO.QSO.Band, CurrentQSO.QSO.Mode);


end;

procedure TContest.ChangeBand(Up : boolean);
begin
  MainForm.UpdateBand(MainForm.GetNextBand(CurrentQSO.QSO.Band, Up));
  if RigControl.Rig <> nil then
    begin
      RigControl.Rig.SetBand(CurrentQSO);
      if CurrentQSO.QSO.Mode = mSSB then
        RigControl.Rig.SetMode(CurrentQSO);
      RigControl.SetBandMask;
    end;
end;

procedure TMainForm.SetQSOMode(var aQSO : TQSO);
var maxmode : TMode;
begin
  maxmode := mOther;
  case aQSO.QSO.band of
    b19..b28 : maxmode := mSSB;
    b50 : maxmode := mAM;
    b144..HiBand : maxmode := mFM;
  end;
  if Pos('Pedition',MyContest.Name) > 0 then
    maxmode := mOther;
  if aQSO.QSO.mode < maxmode then
    inc(aQSO.QSO.mode)
  else
    aQSO.QSO.mode := mCW;
end;

procedure TContest.ChangeMode;
begin
  MainForm.SetQSOMode(CurrentQSO);
  MainForm.UpdateMode(CurrentQSO.QSO.Mode);
{
  MainForm.ModeEdit.Text :=  ModeString[CurrentQSO.QSO.mode];

  If CurrentQSO.QSO.mode in [mSSB..mAM] then
    begin
      CurrentQSO.QSO.RSTrcvd := 59;
      CurrentQSO.QSO.RSTsent := 59;
      MainForm.RcvdRSTEdit.Text := '59';
      MainForm.Grid.Align := alNone;
      MainForm.SSBToolBar.Visible := True;
      MainForm.CWToolBar.Visible := False;
      MainForm.Grid.Align := alClient;
    end
  else
    begin
      CurrentQSO.QSO.RSTrcvd := 599;
      CurrentQSO.QSO.RSTsent := 599;
      MainForm.RcvdRSTEdit.Text := '599';
      MainForm.Grid.Align := alNone;
      MainForm.CWToolBar.Visible := True;
      MainForm.SSBToolBar.Visible := False;
      MainForm.Grid.Align := alClient;
    end;

  if MyContest.MultiForm.Visible then
    MyContest.MultiForm.Update;

  MyContest.SetPoints(CurrentQSO);
  MainForm.PointEdit.Text := CurrentQSO.PointStr; }
  if RigControl.Rig <> nil then
    RigControl.Rig.SetMode(CurrentQSO);
end;

procedure TContest.ChangePower;
begin
  if CurrentQSO.QSO.Power = pwrH then
    CurrentQSO.QSO.Power := pwrP
  else
    inc(CurrentQSO.QSO.Power);
  MainForm.NewPowerEdit.Text := CurrentQSO.NewPowerStr;
end;

constructor TWanted.Create;
begin
  Multi := '';
  Bands := [];
end;

constructor TContest.Create(N : string);
var i : integer;
    B : TBand;
begin
  WantedList := TList.Create;

  SameExchange := True;
  Options.Settings._sameexchange := SameExchange;
  MainForm.MultiButton.Enabled := True; // toolbar
  MainForm.Multipliers1.Enabled := True; // menu
  MainForm.mnCheckCountry.Visible := False; // checkcountry window
  MainForm.mnCheckMulti.Caption := 'Check Multi';
  Name := N;
  CONTESTNAME := N; // zlogglobal

  Log.AcceptDifferentMode := False;
  Log.CountHigherPoints := False;

  TQSO(Log.List[0]).QSO.Callsign := Options.Settings._mycall; //Callsign
  TQSO(Log.List[0]).QSO.Memo := N; //Contest name
  TQSO(Log.List[0]).QSO.RSTSent := UTCOffset; //UTC = $FFFF else UTC + x hrs;
  TQSO(Log.List[0]).QSO.RSTRcvd := 0; // or Field Day coefficient

  for i := 0 to ord(High(TBand)) do
    begin
      MainForm.BandMenu.Items[i].Visible := True;
    end;
  MainForm.BandMenu.Items[ord(b10)].Visible := False;
  MainForm.BandMenu.Items[ord(b18)].Visible := False;
  MainForm.BandMenu.Items[ord(b24)].Visible := False;

  SerialContestType := 0;
  for B := b19 to HiBand do
    SerialArray[B] := 1;
  for i := 0 to 64 do
    SerialArrayTX[i] := 1;
  //MainForm.EditScreen.Renew;
end;

procedure TContest.PostWanted(S : string);
var ss, mm : string;
    i, bb : integer;
    W : TWanted;

begin
  ss := copy(S, 1, 2);
  ss := TrimRight(ss);

  bb := StrToInt(ss);
  if bb <= ord(HiBand) then
    begin
      mm := copy(S, 3, 255);
      mm := TrimLeft(mm);
      mm := TrimRight(mm);
      for i := 0 to WantedList.Count - 1 do
        begin
          W := TWanted(WantedList[i]);
          if W.Multi = mm then
            begin
              W.Bands := W.Bands + [TBand(bb)];
              exit;
            end;
        end;
      W := TWanted.Create;
      W.Multi := mm;
      W.Bands := [TBand(bb)];
      WantedList.Add(W);
    end;
end;

procedure TContest.DelWanted(S : string);
var ss, mm : string;
    i, bb : integer;
    W : TWanted;
begin
  ss := copy(S, 1, 2);
  ss := TrimRight(ss);

  bb := StrToInt(ss);
  if bb <= ord(HiBand) then
    begin
      mm := copy(S, 3, 255);
      mm := TrimLeft(mm);
      mm := TrimRight(mm);
      for i := 0 to WantedList.Count - 1 do
        begin
          W := TWanted(WantedList[i]);
          if W.Multi = mm then
            begin
              W.Bands := W.Bands - [TBand(bb)];
              if W.Bands = [] then
                begin
                  W.Free;
                  WantedList.Delete(i);
                  WantedList.Pack;
                end;
              exit;
            end;
        end;
    end;
end;


procedure TContest.ClearWanted;
var  W : TWanted;
     i : integer;
begin
  for i := 0 to WantedList.Count - 1 do
    begin
      W := TWanted(WantedList[i]);
      W.Free;
    end;
  WantedList.Clear;
end;


function TContest.ValidBand(B : TBand) : boolean;
begin
  Result := MainForm.BandMenu.Items[ord(B)].Visible;
end;

destructor TContest.Destroy;
begin
  inherited;

end;

procedure TContest.SetNrSent(var aQSO : TQSO);
var s : string;
begin
  s := SetStrNoAbbrev(Options.Settings._sentstr, aQSO);
  aQSO.QSO.NrSent := s;
end;

function TContest.ADIF_ExchangeRX_FieldName : string;
begin
  if SerialContestType <> 0 then
    Result := 'srx'
  else
    Result := 'qth';
end;

function TCQWWContest.ADIF_ExchangeRX_FieldName : string;
begin
  Result := 'cqz';
end;

function TIARUContest.ADIF_ExchangeRX_FieldName : string;
begin
  Result := 'ituz';
end;

function TARRLDXContestDX.ADIF_ExchangeRX_FieldName : string;
begin
  Result := 'state';
end;

function TARRLDXContestW.ADIF_ExchangeRX_FieldName : string;
begin
  Result := 'rx_pwr';
end;

function TAllAsianContest.ADIF_ExchangeRX_FieldName : string;
begin
  Result := 'age';
end;

function TContest.ADIF_ExchangeRX(aQSO : TQSO) : string;
begin
  Result := aQSO.QSO.NrRcvd;
end;

function TContest.ADIF_ExtraFieldName : string;
begin
  Result := '';
end;

function TContest.ADIF_ExtraField(aQSO : TQSO) : string;
begin
  Result := '';
end;

function TCQWPXContest.ADIF_ExtraFieldName : string;
begin
  Result := 'pfx';
end;

function TCQWPXContest.ADIF_ExtraField(aQSO : TQSO) : string;
begin
  Result := aQSO.QSO.Multi1;
end;

procedure TContest.ADIF_Export(FileName : string);
var f : textfile;
    Header, S, temp : string;
    i : integer;
    aQSO : TQSO;
    offsetmin : integer;
    dbl : double;
begin
  Header := 'ADIF export from zLog for Windows'; //+Options.Settings._mycall;
  assignfile(f, Filename);
  rewrite(f);
  {str := 'zLog for Windows Text File';}
  writeln(f, Header);
  writeln(f, 'All times in UTC');
  writeln(f, 'Yohei Yokobayashi AD6AJ/JJ1MED');
  writeln(f, '<eoh>');
  offsetmin := TQSO(Log.List[0]).QSO.RSTSent;
  {if offsetmin = 0 then // default JST for older versions
    offsetmin := -1*9*60; }
  if offsetmin = _USEUTC then //already recorded in utc
    offsetmin := 0;
  dbl := offsetmin / (24*60);
  for i := 1 to Log.TotalQSO do
    begin
      aQSO := TQSO(Log.List[i]);
      S := '<qso_date:8>';
      S := S + FormatDateTime('yyyymmdd', aQSO.QSO.Time + dbl);
      S := S + '<time_on:4>' + FormatDateTime('hhnn',aQSO.QSO.Time + dbl);
      S := S + '<time_off:4>' + FormatDateTime('hhnn',aQSO.QSO.Time + dbl);

      temp := aQSO.QSO.Callsign;
      S := S + '<call:'+IntToStr(length(temp))+'>'+ temp;

      temp := IntToStr(aQSO.QSO.RSTsent);
      S := S + '<rst_sent:'+IntToStr(length(temp))+'>' + temp;

      if SerialContestType <> 0 then
        begin
          temp := IntToStr(aQSO.QSO.Serial);
          S := S + '<stx:'+IntToStr(length(temp))+'>' + temp;
        end;

      temp := IntToStr(aQSO.QSO.RSTrcvd);
      S := S + '<rst_rcvd:'+IntToStr(length(temp))+'>' + temp;

      temp := ADIF_ExchangeRX(aQSO);
      S := S + '<'+ADIF_ExchangeRX_FieldName+':'
         + IntToStr(length(temp))+'>' + temp;

      temp := ADIF_ExtraField(aQSO);
      if temp <> '' then
        begin
          S := S + '<'+ADIF_ExtraFieldName+':'
             + IntToStr(length(temp))+'>' + temp;
        end;

      temp := ADIFBandString[aQSO.QSO.Band];
      S := S + '<band:'+IntToStr(length(temp))+'>' + temp;

      temp := ModeString[aQSO.QSO.Mode];
      S := S + '<mode:'+IntToStr(length(temp))+'>' + temp;

      if aQSO.QSO.Operator <> '' then
        begin
          temp := aQSO.QSO.Operator;
          S := S + '<operator:'+IntToStr(length(temp))+'>' + temp;
        end;

      if aQSO.QSO.Memo <> '' then
        begin
          temp := aQSO.QSO.Memo;
          S := S + '<comment:'+IntToStr(length(temp))+'>' + temp;
        end;

      S := S + '<eor>';

      writeln(f, S);
    end;
  close(f);
end;


procedure TContest.LogQSO(var aQSO : TQSO; Local : boolean);
var i, t, mytx : integer;
    R : word;
    boo : boolean;
begin
  if Log.TotalQSO > 0 then
    begin
      t := Log.TotalQSO;
      mytx := Options.GetTXnr;
      if {Local = True} mytx = aQSO.QSO.TX then // same tx # could be through network
        begin
          boo := false;
          for i := t downto 1 do
            begin
              if TQSO(Log.List[i]).QSO.TX = mytx then
                begin
                  boo := true;
                  break;
                end;
            end;
          if (boo = false) or
             (boo and (TQSO(Log.List[i]).QSO.Band <> aQSO.QSO.Band)) then
            begin
              CountDownStartTime := CurrentTime;//Now;
            end;
        end;
    end
  else // log.total = 0
    begin
      CountDownStartTime := CurrentTime;
    end;
  {if Local then
    if Options.Settings._multistation = True then
      aQSO.QSO.Memo := 'MULT '+aQSO.QSO.Memo;}

  if Local=False then
    aQSO.QSO.Reserve2 := $AA; // some multi form and editscreen uses this flag
  MultiForm.Add(aQSO);
  aQSO.QSO.Reserve2 := $00;

  ScoreForm.Add(aQSO);
  aQSO.QSO.Reserve := actAdd;
  Log.AddQue(aQSO);
  Log.ProcessQue;

  if Local=False then
    aQSO.QSO.Reserve2 := $AA; // some multi form and editscreen uses this flag
  MainForm.EditScreen.Add(aQSO);

  //synchronization of serial # over network
  if Options.Settings._syncserial and (SerialContestType <> 0) and (Local = False) then
    begin
      if SerialContestType = SER_MS then // WPX M/S type. Separate serial for mult/run
        begin
          SerialArrayTX[aQSO.QSO.TX] := aQSO.QSO.Serial + 1;
          if aQSO.QSO.TX = Options.Settings._txnr then
            begin
              CurrentQSO.QSO.Serial := aQSO.QSO.Serial + 1;
              MainForm.SerialEdit.Text := CurrentQSO.SerialStr;
            end;
        end
      else
        begin
          SerialArray[aQSO.QSO.Band] := aQSO.QSO.Serial + 1;
          if (SerialContestType = SER_ALL) or
             ((SerialContestType = SER_Band) and (CurrentQSO.QSO.Band = aQSO.QSO.Band)) then
            begin
              CurrentQSO.QSO.Serial := aQSO.QSO.Serial + 1;
              MainForm.SerialEdit.Text := CurrentQSO.SerialStr;
            end;
        end;
    end;

  aQSO.QSO.Reserve2 := $00;

  MainForm.ReEvaluateQSYCount;

  if RateDialog.Visible then
    RateDialog.UpdateGraph;

  if Options.Settings._multistation then
    if Local{(mytx = aQSO.QSO.TX)} and (aQSO.QSO.NewMulti1 = False) and (aQSO.QSO.NewMulti2 = False) and (Options.Settings._multistationwarning) then
      begin
        R := MessageDlg('This station is not a new multiplier, but will be logged anyway.', mtError,
                    [mbOK], 0); {HELP context 0}
      end;
end;

procedure TContest.ShowScore;
begin
  ScoreForm.Show;
end;

procedure TContest.ShowMulti;
begin
  MultiForm.Show;
end;

procedure TContest.Renew;
var i, j : integer;
    aQSO : TQSO;
    temp : string;
    B : TBand;
begin

  if Options.Settings._renewbythread then
    begin
      RequestRenewThread;
      exit;
    end;

  MultiForm.Reset;
  ScoreForm.Reset;

  Log.SetDupeFlags;

  for i := 1 to Log.TotalQSO do
    begin
      aQSO := TQSO(Log.List[i]);
      if Log.CountHigherPoints = True then
        j := Log.IsDupe(aQSO); // called to set log.differentmodepointer
      MultiForm.AddNoUpdate(aQSO);
      ScoreForm.AddNoUpdate(aQSO);
    end;

  MultiForm.Update;
  ScoreForm.Update;
  MainForm.EditScreen.Renew;
  MultiForm.RenewBandScope;

  MainForm.ReevaluateCountDownTimer;
  MainForm.ReevaluateQSYCount;
end;

(*
procedure TContest.Renew;
var i, dupeindex : integer;
    aQSO : TQSO;
    temp : string;
    B : TBand;
begin
  MultiForm.Reset;
  ScoreForm.Reset;
f
  for i := 1 to Log.TotalQSO do
    begin
      aQSO := TQSO(Log.List[i]);
      MultiForm.AddNoUpdate(aQSO); //??
      if Log.IsDupe2(aQSO, i, dupeindex) and (i > dupeindex) then
        begin
          aQSO.QSO.Points := 0;
          aQSO.QSO.Dupe := True;
          temp := aQSO.QSO.memo;
          if Pos('-DUPE-',temp) = 0 then
            aQSO.QSO.memo := '-DUPE- '+temp;
        end
      else
        begin
          aQSO.QSO.Dupe := False;
          ScoreForm.AddNoUpdate(aQSO);
          temp := aQSO.QSO.memo;
          if Pos('-DUPE-',temp) = 1 then
            aQSO.QSO.memo := Copy(temp, 8, 255);
        end;
      TQSO(Log.List[i]).QSO := aQSO.QSO;
    end;

  for B := b19 to HiBand do
    begin
      for i := 1 to SubLog[B].TotalQSO do
        begin
          aQSO := TQSO(SubLog[B].List[i]);
          MultiForm.AddNoUpdate(aQSO);
          if SubLog[B].IsDupe2(aQSO, i, dupeindex) and (i > dupeindex) then
            begin
              aQSO.QSO.Points := 0;
              aQSO.QSO.Dupe := True;
              temp := aQSO.QSO.memo;
              if Pos('-DUPE-',temp) = 0 then
                aQSO.QSO.memo := '-DUPE- '+temp;
            end
          else
            begin
              aQSO.QSO.Dupe := False;
              ScoreForm.AddNoUpdate(aQSO);
              temp := aQSO.QSO.memo;
              if Pos('-DUPE-',temp) = 1 then
                aQSO.QSO.memo := Copy(temp, 8, 255);
            end;
          TQSO(SubLog[B].List[i]).QSO := aQSO.QSO;
        end;
    end;
  MultiForm.Update;
  ScoreForm.Update;
  MainForm.EditScreen.Renew;
end;
*)

procedure TContest.EditCurrentRow;
var R : integer;
    _top, _row : integer;
begin
  // R := MainForm.Grid.Row;
  _row := MainForm.Grid.Row;
  R := MainForm.EditScreen.IndexArray[_row];
  _top := MainForm.Grid.TopRow;
  if (R <= Log.TotalQSO) and (R > 0) then
    begin
      if TQSO(Log.List[R]).QSO.Reserve = actLock then
        begin
          MainForm.WriteStatusLine('This QSO is currently locked', false);
          exit;
        end;
      PastEditForm.Init(TQSO(Log.List[R]), R, _ActChange);
      if PastEditForm.ShowModal = mrOK then
        begin
          if PartialCheck.Visible and PartialCheck._CheckCall then
            PartialCheck.CheckPartial(CurrentQSO);
          {if SuperCheck.Visible then
            SuperCheck.CheckSuper(CurrentQSO);}
          if CheckCall2.Visible then
            CheckCall2.Renew(CurrentQSO);
        end;
      MainForm.Grid.TopRow :=  _top;
      MainForm.Grid.Row := _row;
      //MainForm.EditScreen.RefreshScreen;
    end;
end;

constructor TJIDXContest.Create(N : string);
begin
  inherited;
  MultiForm := JIDXMulti;
  ScoreForm := JIDXScore2;
  CheckCountry.ParentMulti := JIDXMulti;
  UseUTC := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
end;

procedure TJIDXContest.SetPoints(var aQSO : TQSO);
begin
  JIDXScore2.CalcPoints(aQSO);
end;

constructor TARRLDXContestDX.Create(N : string);
begin
  inherited;
  MultiForm := ARRLDXMulti;
  ScoreForm := ARRLDXScore;
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TARRLDXEdit.Create;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;
  UseUTC := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
end;

constructor TARRLDXContestW.Create(N : string);
begin
  inherited;
  MultiForm := ARRLWMulti;
  ARRLWMulti.ALLASIANFLAG := False;
  ScoreForm := ARRLDXScore;
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TDXCCEdit.Create;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;
  UseUTC := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
end;

constructor TAllAsianContest.Create(N : string);
begin
  inherited;
  MultiForm := ARRLWMulti;
  ARRLWMulti.ALLASIANFLAG := True;
  ScoreForm := AllAsianScore;
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TDXCCEdit.Create;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;
  UseUTC := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
end;

procedure TAllAsianContest.SetPoints(var aQSO : TQSO);
begin
  AllAsianScore.CalcPoints(aQSO);
end;

procedure TAllAsianContest.SpaceBarProc;
begin
  inherited;
  MainForm.WriteStatusLine(MultiForm.GetInfo(CurrentQSO), false);
end;

constructor TJIDXContestDX.Create(N : string);
begin
  inherited;
  MultiForm := JIDX_DX_Multi;
  ScoreForm := JIDX_DX_Score;
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TGeneralEdit.Create;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;
  UseUTC := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
end;

procedure TJIDXContestDX.SetPoints(var aQSO : TQSO);
begin
  JIDX_DX_Score.CalcPoints(aQSO);
end;

constructor TCQWPXContest.Create(N : string);
begin
  inherited;
  MultiForm := WPXMulti;
  ScoreForm := WPXScore;
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TWPXEdit.Create;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;
  UseUTC := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
  TQSO(Log.List[0]).QSO.Serial := $01; // uses serial number
  SerialContestType := SER_ALL;
  SameExchange := False;
  Options.Settings._sameexchange := SameExchange;
end;

constructor TWAEContest.Create(N : string);
begin
  inherited;
  MultiForm := WAEMulti;
  ScoreForm := WAEScore;
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TWPXEdit.Create;
  MainForm.BandMenu.Items[ord(b19)].Visible := False;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;
  UseUTC := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
  TQSO(Log.List[0]).QSO.Serial := $01; // uses serial number
  SerialContestType := SER_ALL;
  SameExchange := False;
  Options.Settings._sameexchange := SameExchange;
end;

function TIOTAContest.QTHString : string;
begin
  Result := IOTAMulti.MyIOTA;
end;

constructor TIOTAContest.Create(N : string);
begin
  inherited;
  MultiForm := IOTAMulti;
  ScoreForm := IARUScore;
  IARUScore.InitGrid(b35, b28);
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TIOTAEdit.Create;
  MainForm.BandMenu.Items[ord(b19)].Visible := False;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;
  UseUTC := True;
  Log.AcceptDifferentMode := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
  TQSO(Log.List[0]).QSO.Serial := $01; // uses serial number
  SerialContestType := SER_ALL;
end;

constructor TARRL10Contest.Create(N : string);
begin
  inherited;
  MultiForm := ARRL10Multi;
  ScoreForm := ARRL10Score;
  //IARUScore.InitGrid(b35, b28);

  CheckMulti.ListCWandPh := True;

  PastEditForm := ALLJAEditDialog;
  if ARRL10Multi.IsUSA then
    begin
      MainForm.EditScreen := TDXCCEdit.Create;
      Options.Settings._sentstr := '$V';
    end
  else
    begin
      MainForm.EditScreen := TIOTAEdit.Create;
      Options.Settings._sentstr := '$S';
    end;
  MainForm.BandMenu.Items[ord(b19)].Visible := False;
  MainForm.BandMenu.Items[ord(b35)].Visible := False;
  MainForm.BandMenu.Items[ord(b7)].Visible := False;
  MainForm.BandMenu.Items[ord(b14)].Visible := False;
  MainForm.BandMenu.Items[ord(b21)].Visible := False;

  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;
  UseUTC := True;
  Log.AcceptDifferentMode := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
  TQSO(Log.List[0]).QSO.Serial := $01; // uses serial number
  SerialContestType := SER_ALL;
  SameExchange := False;
  Options.Settings._sameexchange := SameExchange;
end;

constructor TJA0Contest.Create(N : string);
begin
  inherited;
  MultiForm := JA0Multi;
  ScoreForm := JA0Score;

  MainForm.BandMenu.Items[ord(b35)].Visible := False;
  MainForm.BandMenu.Items[ord(b7)].Visible := False;


  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TJA0Edit.Create;
  MainForm.BandMenu.Items[ord(b19)].Visible := False;
  MainForm.BandMenu.Items[ord(b14)].Visible := False;
  MainForm.BandMenu.Items[ord(b21)].Visible := False;
  MainForm.BandMenu.Items[ord(b28)].Visible := False;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;

  TQSO(Log.List[0]).QSO.Serial := $01; // uses serial number
  SerialContestType := SER_ALL;
  SameExchange := False;
  Options.Settings._sameexchange := SameExchange;
end;

constructor TJA0ContestZero.Create(N : string);
begin
  inherited;
  JA0Multi.JA0 := True;

  TQSO(Log.List[0]).QSO.Serial := $01; // uses serial number
  SerialContestType := SER_ALL;
  SameExchange := False;
  Options.Settings._sameexchange := SameExchange;

end;

procedure TJA0Contest.SetBand(B : TBand);
begin
  JA0Score.SetBand(B);
  if (B = b21) or (B = b28) then
    begin
      MainForm.BandMenu.Items[ord(b21)].Enabled := True;
      MainForm.BandMenu.Items[ord(b28)].Enabled := True;
      MainForm.BandMenu.Items[ord(b21)].Visible := True;
      MainForm.BandMenu.Items[ord(b28)].Visible := True;
    end
  else
    begin
      MainForm.BandMenu.Items[ord(B)].Visible := True;
    end;
end;

procedure TJA0Contest.Renew;
var B : TBand;
begin
  inherited;
  B := JA0Score.JA0Band;
  if (B = b21) or (B = b28) then
    begin
      MainForm.BandMenu.Items[ord(b21)].Enabled := True;
      MainForm.BandMenu.Items[ord(b28)].Enabled := True;
      MainForm.BandMenu.Items[ord(b21)].Visible := True;
      MainForm.BandMenu.Items[ord(b28)].Visible := True;
    end
  else
    begin
      MainForm.BandMenu.Items[ord(B)].Visible := True;
    end;
end;

constructor TAPSprint.Create(N : string);
begin
  inherited;
  MultiForm := WPXMulti;
  ScoreForm := APSprintScore;
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TWPXEdit.Create;
  MainForm.BandMenu.Items[ord(b19)].Visible := False;
  MainForm.BandMenu.Items[ord(b35)].Visible := False;
  //MainForm.BandMenu.Items[ord(b21)].Visible := False;  rule change
  MainForm.BandMenu.Items[ord(b28)].Visible := False;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;
  UseUTC := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
  TQSO(Log.List[0]).QSO.Serial := $01; // uses serial number
  SerialContestType := SER_ALL;

  SameExchange := False;
  Options.Settings._sameexchange := SameExchange;

end;

constructor TCQWWContest.Create(N : string);
begin
  inherited;
  MultiForm := WWMulti;
  ScoreForm := WWScore;

  MainForm.mnCheckCountry.Visible := True;
  MainForm.mnCheckMulti.Caption := 'Check Zone';

  CheckCountry.ParentMulti := WWMulti;

  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TWWEdit.Create;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;
  UseUTC := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
end;

procedure TCQWWContest.SpaceBarProc;
var temp : string;
begin
  //inherited;
  {if MainForm.NumberEdit.Text = '' then
    begin}
      temp := MultiForm.GuessZone(CurrentQSO);
      MainForm.NumberEdit.Text := temp;
      CurrentQSO.QSO.NrRcvd := temp;
    //end;

{This section moved from tcontest.spacebarproc}
  //if (MainForm.NumberEdit.Text = '') and (SameExchange = True)then
    DispExchangeOnOtherBands;
  if CheckMulti.Visible then
    CheckMulti.Renew(CurrentQSO);
{This section moved from tcontest.spacebarproc}


  if CheckCountry.Visible then
    CheckCountry.Renew(CurrentQSO);

  if Options.Settings._multistation then
    begin
      if CheckCountry.Visible = False then
        CheckCountry.Renew(CurrentQSO);
      if CheckCountry.NotNewMulti(CurrentQSO.QSO.Band) then
        begin
          MainForm.WriteStatusLineRed('NOT a new multiplier. (This is a multi stn)', false);
          exit;
        end;
    end;

  MainForm.WriteStatusLine(MultiForm.GetInfo(CurrentQSO), false);
end;

procedure TWAEContest.SpaceBarProc;
var temp : string;
begin
  inherited;
  if CheckCountry.Visible then
    CheckCountry.Renew(CurrentQSO);

  if Options.Settings._multistation then
    begin
      if CheckCountry.Visible = False then
        CheckCountry.Renew(CurrentQSO);
      if CheckCountry.NotNewMulti(CurrentQSO.QSO.Band) then
        begin
          MainForm.WriteStatusLineRed('NOT a new multiplier. (This is a multi stn)', false);
          exit;
        end;
    end;

  MainForm.WriteStatusLine(MultiForm.GetInfo(CurrentQSO), false);
end;

procedure TCQWWContest.ShowMulti;
begin
  MultiForm.Show;
  WWZone.Show;
end;

function TCQWWContest.CheckWinSummary(aQSO : TQSO) : string;
var S : string;
begin
  S := '';
  S := S + FillRight(aQSO.BandStr, 5);
  S := S + aQSO.TimeStr + ' ';
  S := S + FillRight(aQSO.QSO.Callsign, 12);
  S := S + FillRight(aQSO.QSO.NrRcvd, 4);
  Result := S;
end;

constructor TIARUContest.Create(N : string);
begin
  inherited;
  MultiForm := IARUMulti;
  ScoreForm := IARUScore;
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TIARUEdit.Create;
  //CheckMulti.ListCWandPh := True;
  MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10G)].Visible := False;
  UseUTC := True;
  Log.AcceptDifferentMode := True;
  TQSO(Log.List[0]).QSO.RSTSent := _USEUTC; //JST = 0; UTC = $FFFF
end;

procedure TIARUContest.SpaceBarProc;
var temp : string;
begin
  inherited;
  MainForm.WriteStatusLine(MultiForm.GetInfo(CurrentQSO), false);
  if (MultiFound = False) and (MainForm.NumberEdit.Text = '') then
    begin
      temp := MultiForm.GuessZone(CurrentQSO);
      MainForm.NumberEdit.Text := temp;
      CurrentQSO.QSO.NrRcvd := temp;
    end;
end;

procedure TARRLDXContestW.SpaceBarProc;
begin
  inherited;
  MainForm.WriteStatusLine(MultiForm.GetInfo(CurrentQSO), false);
end;

constructor TPedi.Create(N : string);
begin
  inherited;
  MainForm.MultiButton.Enabled := False; // toolbar
  MainForm.Multipliers1.Enabled := False; // menu
  MultiForm := BasicMulti;
  ScoreForm := PediScore;
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TGeneralEdit.Create;
  MainForm.BandMenu.Items[ord(b10)].Visible := True;
  MainForm.BandMenu.Items[ord(b18)].Visible := True;
  MainForm.BandMenu.Items[ord(b24)].Visible := True;

  Log.AcceptDifferentMode := True;
  if UseUTC then
    TQSO(Log.List[0]).QSO.RSTSent := _USEUTC
  else
    TQSO(Log.List[0]).QSO.RSTSent := UTCOffset;
     //UTC = $FFFF else UTC + x hrs;
  {
  UseUTC := True;
  TQSO(Log.List[0]).QSO.RSTSent := $FFFF; //JST = 0; UTC = $FFFF
  }
end;

constructor TALLJAContest.Create(N : string);
begin
  inherited;
  MultiForm := ALLJAMulti;
  ScoreForm := ALLJAScore;
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TALLJAEdit.Create;
  MainForm.BandMenu.Items[ord(b19)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10g)].Visible := False;
end;

constructor TKCJContest.Create(N : string);
begin
  inherited;
  MultiForm := KCJMulti;
  ScoreForm := KCJScore;
  PastEditForm := ALLJAEditDialog;
  MainForm.EditScreen := TKCJEdit.Create;
  MainForm.BandMenu.Items[ord(b19)].Visible := True;
  //MainForm.BandMenu.Items[ord(b50)].Visible := False;
  MainForm.BandMenu.Items[ord(b144)].Visible := False;
  MainForm.BandMenu.Items[ord(b430)].Visible := False;
  MainForm.BandMenu.Items[ord(b1200)].Visible := False;
  MainForm.BandMenu.Items[ord(b2400)].Visible := False;
  MainForm.BandMenu.Items[ord(b5600)].Visible := False;
  MainForm.BandMenu.Items[ord(b10g)].Visible := False;
end;

function TALLJAContest.QTHString : string;
begin
  Result := Options.Settings._prov;
end;

function TKCJContest.QTHString : string;
begin
  Result := Options.Settings._prov;
  // get the kcj code;
end;

function TALLJAContest.CheckWinSummary(aQSO : TQSO) : string;
var S : string;
begin
  S := '';
  S := S + FillRight(aQSO.BandStr, 5);
  S := S + aQSO.TimeStr + ' ';
  S := S + FillRight(aQSO.QSO.Callsign, 12);
  S := S + FillRight(aQSO.QSO.NrRcvd, 5);
  S := S + FillRight(aQSO.ModeStr, 4);
  Result := S;
end;

function TKCJContest.CheckWinSummary(aQSO : TQSO) : string;
var S : string;
begin
  S := '';
  S := S + FillRight(aQSO.BandStr, 5);
  S := S + aQSO.TimeStr + ' ';
  S := S + FillRight(aQSO.QSO.Callsign, 12);
  S := S + FillRight(aQSO.QSO.NrRcvd, 3);
  //S := S + FillRight(aQSO.ModeStr, 4);
  Result := S;
end;

function TFDContest.QTHString : string;
begin
  if CurrentQSO.QSO.band <= b1200 then
    Result := Options.Settings._prov
  else
    Result := Options.Settings._city;
end;

function TSixDownContest.QTHString : string;
begin
  if CurrentQSO.QSO.band <= b1200 then
    Result := Options.Settings._prov
  else
    Result := Options.Settings._city;
end;

constructor TACAGContest.Create(N : string);
begin
  inherited;
  MainForm.BandMenu.Items[ord(b19)].Visible := False;
  MultiForm := ACAGMulti;
  ScoreForm := ACAGScore;
  PastEditForm := ALLJAEditDialog;
  // MainForm.EditScreen := TALLJAEdit.Create;
  MainForm.EditScreen := TACAGEdit.Create;
end;

constructor TFDContest.Create(N : string);
begin
  inherited;
  MainForm.BandMenu.Items[ord(b19)].Visible := False;
  MultiForm := FDMulti;
  ScoreForm := ACAGScore;
  PastEditForm := ALLJAEditDialog;
  // MainForm.EditScreen := TALLJAEdit.Create;
  MainForm.EditScreen := TACAGEdit.Create;
end;

constructor TSixDownContest.Create(N : string);
begin
  inherited;
  MainForm.BandMenu.Items[ord(b19)].Visible := False;
  MainForm.BandMenu.Items[ord(b35)].Visible := False;
  MainForm.BandMenu.Items[ord(b7)].Visible := False;
  MainForm.BandMenu.Items[ord(b14)].Visible := False;
  MainForm.BandMenu.Items[ord(b21)].Visible := False;
  MainForm.BandMenu.Items[ord(b28)].Visible := False;
  MultiForm := SixDownMulti;
  ScoreForm := SixDownScore;
  PastEditForm := ALLJAEditDialog;
  // MainForm.EditScreen := TALLJAEdit.Create;
  MainForm.EditScreen := TACAGEdit.Create;
end;

constructor TGeneralContest.Create(N : string);
begin
  inherited;
  MultiForm := GeneralMulti2;
  ScoreForm := GeneralScore;
  GeneralScore.LoadCFG(MenuForm.CFGFileName);
  PastEditForm := ALLJAEditDialog;
  if SerialContestType = 0 then
    MainForm.EditScreen := TGeneralEdit.Create
  else
    begin
      MainForm.EditScreen := TSerialGeneralEdit.Create;
      TQSO(Log.List[0]).QSO.Serial := $01; // uses serial number
      SameExchange := False;
      Options.Settings._sameexchange := SameExchange;
    end;
  //MultiForm.Update;
end;

procedure TGeneralContest.SetPoints(var aQSO : TQSO);
begin
  GeneralScore.CalcPoints(aQSO);
end;

constructor TBasicEdit.Create;
var i, j : integer;
begin
  for i := 1 to MaxGridQSO do
    IndexArray[i] := 0;
  DispQSO := 0;
  DirectEdit := False;
  with MainForm.Grid do
    begin
      ColCount := 10;
      colSerial := -1;
      colTime := 1;
      colCall := -1;
      colrcvdRST := -1;
      colrcvdNumber := -1;
      colMode := -1;
      colPower := -1;
      colNewPower := -1;
      colBand := -1;
      colPoint := -1;
      colMemo := -1;
      colSerial := -1;
      colOp := -1;
      colNewMulti1 := -1;
      colNewMulti2 := -1;
      colsentRST := -1;
      colsentNumber := -1;
      colCQ := -1;
      //Align := alTop;
      FixedCols := 0;
      FixedRows := 1;
      ColCount := 10;
      Height := 291;
      DefaultRowHeight := 17;
      //Height := 256;
      //DefaultRowHeight := 16;

      SerialWid := 4;
      TimeWid := 4;
      //CallSignWid := 10;
      CallSignWid := 9;
      rcvdRSTWid := 3;
      //NumberWid := 5;
      NumberWid := 6;
      BandWid := 4;
      ModeWid := 3;
      PowerWid := 0;
      NewPowerWid := 2;
      PointWid := 3;
      OpWid := 6;
      MemoWid := 7;
      NewMulti1Wid := 3;
      NewMulti2Wid := 0;
    end;

  MainForm.SerialEdit.Visible := False;
  MainForm.PowerEdit.Visible := False;
  MainForm.NewPowerEdit.Visible := False;
  MainForm.ModeEdit.Visible := True;

  for i := 1 to MainForm.Grid.RowCount-1 do
    for j := 0 to MainForm.Grid.ColCount-1 do
      MainForm.Grid.Cells[j,i] := '';
end;

procedure TBasicEdit.SetDirectEdit(Direct : boolean);
begin
  if Direct then
    begin
      MainForm.Grid.Options := MainForm.Grid.Options + [goEditing{, goAlwaysShowEditor}];
      MainForm.Grid.Options := MainForm.Grid.Options - [goRowSelect];
      DirectEdit := True;
    end
  else
    begin
      MainForm.Grid.Options := MainForm.Grid.Options - [goEditing, goAlwaysShowEditor];
      MainForm.Grid.Options := MainForm.Grid.Options + [goRowSelect];
      DirectEdit := False;
    end;
end;

procedure TBasicEdit.Add(aQSO : TQSO);
var R : word;
    i : integer;
begin
  if MainForm.ShowCurrentBandOnly.Checked and (aQSO.QSO.Band <> CurrentQSO.QSO.Band) then
    exit;
  R := Log.TotalQSO;
  with MainForm.Grid do
    begin
      {if R+1 > DisplayedQSOs then
        RowCount := R+1;}
      //_top := TopRow;

      inc(DispQSO);

      if DispQSO+1 > DisplayedQSOs then
        RowCount := DispQSO + 1;

      WriteQSO(DispQSO, aQSO);
      //WriteQSO(R, aQSO);
      IndexArray[DispQSO] := Log.TotalQSO;
      (*
      if colSerial >= 0 then Cells[colSerial,R] := aQSO.SerialStr;
      if colTime >= 0 then Cells[colTime,R]:= aQSO.TimeStr;
      if colCall >= 0 then Cells[colCall,R]:= aQSO.QSO.Callsign;
      if colrcvdRST >=0 then Cells[colrcvdRST,R]:= aQSO.RSTStr;
      if colrcvdNumber >= 0 then Cells[colrcvdNumber,R]:= aQSO.QSO.NrRcvd;
      if colBand >= 0 then Cells[colBand,R]:= aQSO.BandStr;
      if colMode >= 0 then Cells[colMode,R]:= aQSO.ModeStr;
      if colPower >= 0 then Cells[colPower,R]:= aQSO.PowerStr;
      if colNewPower >= 0 then Cells[colNewPower,R] := aQSO.NewPowerStr;
      if colPoint >= 0 then Cells[colPoint,R]:= aQSO.PointStr;
      if colNewMulti1 >= 0 then Cells[colNewMulti1,R]:= GetNewMulti1(aQSO);
      if colOp >= 0 then Cells[colOp,R]:= aQSO.QSO.Operator;
      if colMemo >= 0 then Cells[colMemo,R]:= aQSO.QSO.memo;
      *)

      // i := Log.TotalQSO - DisplayedQSOs;
      i := DispQSO - DisplayedQSOs;

      if (MainForm.Grid.Focused = False) and (aQSO.QSO.Reserve2 <> $AA) {local} then
        begin
          if i > 0 then
            TopRow := i+1
          else
            TopRow := 1;
        end
      else  // ver 2.0x
        if (aQSO.QSO.Reserve2 = $AA) {not local} and (MainForm.Grid.Focused = False) then
          if i > 0 then
            TopRow := i + 1; // ver 2.0x

      DefaultDrawing := True;
      RefreshScreen;
    end;
end;

Procedure TBasicEdit.WriteQSO(R: integer; aQSO : TQSO);
var temp : string;
begin
  with MainForm.Grid do
    begin
      if colSerial >= 0 then Cells[colSerial,R]:= aQSO.SerialStr;
      if colTime >= 0 then Cells[colTime,R]:= aQSO.TimeStr;
      if colCall >= 0 then Cells[colCall,R]:= aQSO.QSO.Callsign;
      if colrcvdRST >= 0 then Cells[colrcvdRST,R]:= aQSO.RSTStr;
      if colrcvdNumber >= 0 then Cells[colrcvdNumber,R]:= aQSO.QSO.NrRcvd;
      if colBand >= 0 then Cells[colBand,R]:= aQSO.BandStr;
      if colMode >= 0 then Cells[colMode,R]:= aQSO.ModeStr;
      if colPower >= 0 then Cells[colPower,R]:= aQSO.PowerStr;
      if colNewPower >= 0 then Cells[colNewPower,R]:= aQSO.NewPowerStr;
      if colPoint >= 0 then Cells[colPoint,R]:= aQSO.PointStr;
      if colOp >= 0 then
        begin
          temp := IntToStr(aQSO.QSO.TX);
          if UOptions.Options.Settings._multiop = 2 then
            begin
              case aQSO.QSO.TX of
                1 : temp := 'R';
                2 : temp := 'M';
              end;
            end;
          Cells[colOp,R]:= temp + ' ' + aQSO.QSO.Operator;
        end;                                                              IntToStr(aQSO.QSO.Reserve3);

      if colNewMulti1 >= 0 then Cells[colNewMulti1, R] := GetNewMulti1(aQSO);


      if colMemo >= 0 then Cells[colMemo,R]:= aQSO.QSO.memo; // + IntToStr(aQSO.QSO.Reserve3);
      if aQSO.QSO.Reserve = actLock then Cells[colmemo,R] := 'locked';
    end;
end;

procedure TBasicEdit.RefreshScreen;
var i, j : integer;
begin
  with MainForm.Grid do
    begin
      for i := TopRow to TopRow + VisibleRowCount - 1 do
        begin
          if (i > RowCount - 1) or (i = 0) then
            exit;
          if IndexArray[i] > 0 then
            WriteQSO(i, TQSO(Log.List[IndexArray[i]]))
          else
            for j := 0 to ColCount-1 do
              Cells[j,i] := '';
        end;
    end;
end;

procedure TBasicEdit.ResetTopRow;
var i : integer;
begin
  i := DispQSO - DisplayedQSOs;
  if i > 0 then
    MainForm.Grid.TopRow := i+1
  else
    mainForm.Grid.TopRow := 1;
end;

procedure TBasicEdit.Renew;
var R : word;
    i, j, _row, _toprow : integer;
    temp : string[2];
begin
  for i := 1 to MaxGridQSO do
    IndexArray[i] := 0;
  DispQSO := 0;
  R := Log.TotalQSO;

  with MainForm.Grid do
    begin
      _row := Row;
      _toprow := TopRow;
      Enabled := False;
      //defaultdrawing := false;
      //RowCount := R+1;
      //RowCount := 2;
      for i := 1 to R do
        begin
          if MainForm.ShowCurrentBandOnly.Checked then
            begin
              if CurrentQSO.QSO.Band = TQSO(Log.List[i]).QSO.Band then
                begin
                  inc(DispQSO);
                  //WriteQSO(DispQSO, TQSO(Log.List[i]));
                  IndexArray[DispQSO] := i;
                end;
            end
          else
            begin
              inc(DispQSO);
              //WriteQSO(i, TQSO(Log.List[i]));
              IndexArray[i] := i;
            end;
        end;
      // i := Log.TotalQSO - DisplayedQSOs;

      if DispQSO > DisplayedQSOs then
        RowCount := DispQSO+1
      else
        RowCount := DisplayedQSOs + 1;

{
      i := DispQSO - DisplayedQSOs;

      if i > 0 then
        TopRow := i+1
      else
        TopRow := 1; }

      Enabled := True;
      //DefaultDrawing := True;
      RefreshScreen;  // this is not enough!!!!

      if _row > RowCount - 1 then
        Row := RowCount - 1
      else
        Row := _row;
      //Refresh;
    end;
end;

procedure TBasicEdit.SetGridWidth;
begin
  with MainForm.Grid do
    begin
      if colSerial >= 0 then
        begin
          Cells[colSerial, 0]:='serial';
          ColWidths[colSerial] := SerialWid*CWid;
        end;
      MainForm.SerialEdit.Tag := colSerial;

      if colTime >= 0 then
        begin
          Cells[colTime,0]:='time';
          ColWidths[colTime] := TimeWid*CWid;
        end;
      MainForm.TimeEdit.tag := colTime;

      if colCall >= 0 then
        begin
          Cells[colCall,0]:='call';
          ColWidths[colCall] := CallSignWid*CWid;
        end;
      MainForm.CallsignEdit.Tag := colCall;

      if colRcvdRST >= 0 then
        begin
          Cells[colrcvdRST,0]:='RST';
          ColWidths[colrcvdRST] := rcvdRSTWid*Cwid;
        end;
      MainForm.RcvdRSTEdit.Tag := colrcvdRST;

      if colrcvdNumber >= 0 then
        begin
          Cells[colrcvdNumber,0]:='rcvd';
          ColWidths[colrcvdNumber] := NumberWid*Cwid;
        end;
      MainForm.NumberEdit.Tag := colrcvdNumber;

      if colBand >= 0 then
        begin
          Cells[colBand,0]:='band';
          ColWidths[colBand] := BandWid*Cwid;
        end;
      MainForm.BandEdit.Tag := colBand;

      if colMode >= 0 then
        begin
          Cells[colMode,0]:='mod';
          ColWidths[colMode] := ModeWid*CWid;
        end;
      MainForm.ModeEdit.Tag := colMode;

      if colPower >= 0 then
        begin
          Cells[colPower,0]:='pwr';
          ColWidths[colPower] := 3*Cwid;
        end;
      MainForm.PowerEdit.Tag := colPower;

      if colNewPower >= 0 then
        begin
          Cells[colNewPower,0]:='pwr';
          ColWidths[colNewPower] := NewPowerWid*Cwid;
        end;
      MainForm.NewPowerEdit.Tag := colNewPower;

      if colPoint >= 0 then
        begin
          Cells[colPoint,0]:='pts';
          ColWidths[colPoint] := PointWid*Cwid;
        end;
      MainForm.PointEdit.Tag := colPoint;

      if colNewMulti1 >= 0 then
        begin
          Cells[colNewMulti1,0]:='new';
          ColWidths[colNewMulti1] := NewMulti1Wid*Cwid;
        end;

      if colNewMulti2 >= 0 then
        begin
          Cells[colNewMulti2,0]:='new';
          ColWidths[colNewMulti2] := NewMulti2Wid*Cwid;
        end;

      if colOp >= 0 then
        begin
          Cells[colOp,0] := 'op';
          ColWidths[colOp] := OpWid*Cwid;
        end;
      MainForm.OpEdit.Tag := colOp;

      if colMemo >= 0 then
        begin
          Cells[colMemo,0]:='memo';
          ColWidths[colMemo] := MemoWid*Cwid;
        end;
      MainForm.MemoEdit.Tag := colMemo;

    end;
  MainForm.Width := 46*CWid + 36;
end;

function TBasicEdit.GetLeft(col : integer) : integer;
var i, j : integer;
begin
  if col = 0 then
    begin
      Result := 0;
      exit;
    end;
  j := 0;
  for i := 0 to col-1 do
    j := j + MainForm.Grid.ColWidths[i] + 1;
  Result := j ;
end;

Procedure TBasicEdit.SetEditFields;
begin
  with MainForm do
    begin
      if colSerial >= 0 then
        begin
          SerialEdit.Width := MainForm.Grid.ColWidths[colSerial];
          SerialEdit.Left := GetLeft(colSerial);
        end;
      if colTime >= 0 then
        begin
          TimeEdit.Width := MainForm.Grid.ColWidths[colTime];
          TimeEdit.Left := GetLeft(colTime);
          DateEdit.Width := TimeEdit.Width;
          DateEdit.Left := TimeEdit.Left;
        end;
      if colCall >= 0 then
        begin
          CallsignEdit.Width := MainForm.Grid.ColWidths[colCall];
          CallsignEdit.Left := GetLeft(colCall);
        end;
      if colRcvdRST >= 0 then
        begin
          RcvdRSTEdit.Width := MainForm.Grid.ColWidths[colrcvdRST];
          RcvdRSTEdit.Left := GetLeft(colrcvdRST);
        end;
      if colrcvdNumber >= 0 then
        begin
          NumberEdit.Width := MainForm.Grid.ColWidths[colrcvdNumber];
          NumberEdit.Left := GetLeft(colrcvdNumber);
        end;
      if colBand >= 0 then
        begin
          BandEdit.Width := MainForm.Grid.ColWidths[colBand];
          BandEdit.Left := GetLeft(colBand);
        end;
      if colMode >= 0 then
        begin
          ModeEdit.Width := MainForm.Grid.ColWidths[colMode];
          ModeEdit.Left := GetLeft(colMode);
        end;
      if colPower >= 0 then
        begin
          PowerEdit.Width := MainForm.Grid.ColWidths[colPower];
          PowerEdit.Left := GetLeft(colPower);
        end;
      if colNewPower >= 0 then
        begin
          NewPowerEdit.Width := MainForm.Grid.ColWidths[colNewPower];
          NewPowerEdit.Left := GetLeft(colNewPower);
        end;
      if colPoint >= 0 then
        begin
          PointEdit.Width := MainForm.Grid.ColWidths[colPoint];
          PointEdit.Left := GetLeft(colPoint);
        end;
      if colOp >= 0 then
        begin
          OpEdit.Width := MainForm.Grid.ColWidths[colOp];
          OpEdit.Left := GetLeft(colOp);
        end;
      if colMemo >= 0 then
        begin
          MemoEdit.Left := GetLeft(colMemo);
          MemoEdit.Width := EditPanel.Width - MemoEdit.Left - 3;
        end;
    end;
end;


function TBasicEdit.GetNewMulti1(aQSO : TQSO) : string;
begin
  if aQSO.QSO.NewMulti1 then
    Result := '*'
  else
    Result := '';
end;

constructor TGeneralEdit.Create;
var i : integer;
begin

  inherited;

  colTime := 0;
  colCall := 1;
  colrcvdRST := 2;
  colrcvdNumber := 3;
  colBand := 4;
  colMode := 5;
  colPoint := 6;
  colNewMulti1 := 7;

  if pos('$P', Options.Settings._sentstr) > 0 then
    begin
      colNewPower := 8;
      colOp := 9;
      colMemo := 10;
      MainForm.Grid.ColCount := 11;
      MainForm.NewPowerEdit.Visible := True;
    end
  else
    begin
      colOp := 8;
      colMemo := 9;
      MainForm.Grid.ColCount := 10;
    end;

  if UOptions.Options.MultiOp > 0 then
    begin
      OpWid := 6;
      MemoWid := 7;
    end
  else
    begin
      OpWid := 0;
      MemoWid := 13;
      MainForm.OpEdit.Visible := False;
    end;

  SetGridWidth;
  SetEditFields;

 (* with MainForm do
    begin
      TimeEdit.Left := 0;
      TimeEdit.Width := TimeWid*CWid+1;

      CallsignEdit.Left := TimeEdit.Width + 1;
      CallsignEdit.Width := CallSignWid*CWid+1;

      rcvdRSTEdit.Left := CallsignEdit.Left + CallsignEdit.Width;
      rcvdRSTEdit.Width := rcvdRSTWid*CWid+1;

      NumberEdit.Left := rcvdRSTEdit.Left + rcvdRSTEdit.Width;
      NumberEdit.Width := NumberWid*CWid+1;

      BandEdit.Left := NumberEdit.Left + NumberEdit.Width;
      BandEdit.Width := BandWid*CWid+1;

      ModeEdit.Left := BandEdit.Left + BandEdit.Width;
      ModeEdit.Width := ModeWid*CWid+1;

      {PowerEdit.Left := 29*CWid + 7;
      PowerEdit.Width := 3*CWid+1; }

      PointEdit.Left := ModeEdit.Left + ModeEdit.Width;
      PointEdit.Width := PointWid*CWid + 1;

      OpEdit.Left := NewMulti1Wid*CWid + 1 + PointEdit.Left + PointEdit.Width;
      OpEdit.Width := OpWid*Cwid + 1;

      MemoEdit.Left := OpEdit.Left + OpEdit.Width;
      MemoEdit.Width := MemoWid*CWid + 1;

      {if UOptions.Options.MultiOp = false then
        begin
          OpEdit.Visible := false;
          MemoEdit.Left := 3*CWid + 1 + PointEdit.Left + PointEdit.Width;
          MemoEdit.Width := (13)*CWid + 1;
        end; }

    end;
   *)
 end;


constructor TARRLDXEdit.Create;
begin
  inherited;

  colTime := 0;
  colCall := 1;
  colrcvdRST := 2;
  colrcvdNumber := 3;
  colBand := 4;
  colMode := 5;
  colPoint := 6;
  colNewMulti1 := 7;
  colPower := 8;
  colOp := 9;
  colMemo := 10;
  MainForm.Grid.ColCount := 11;
  MainForm.PowerEdit.Visible := True;
  if UOptions.Options.MultiOp > 0 then
    begin
      OpWid := 6;
      MemoWid := 7;
    end
  else
    begin
      OpWid := 0;
      MemoWid := 13;
      MainForm.OpEdit.Visible := False;
    end;

  NumberWid := 3;

  SetGridWidth;
  SetEditFields;
 end;



constructor TWWEdit.Create;
begin
  inherited;
  colTime := 0;
  colCall := 1;
  colrcvdRST := 2;
  colrcvdNumber := 3;
  colBand := 4;
  {colMode := 5;}
  {colPower := 6;}
  colPoint := 5;
  colNewMulti1 := 6;
  // colNewMulti2 := 7;
  colOp := 7;
  colMemo := 8;
  MainForm.Grid.ColCount := 9;
  MainForm.ModeEdit.Visible := False;
  NumberWid := 3;
  NewMulti1Wid := 6;

  if UOptions.Options.MultiOp > 0 then
    begin
      OpWid := 6;
      MemoWid := 10;
    end
  else
    begin
      OpWid := 0;
      MemoWid := 16;
      MainForm.OpEdit.Visible := False;
    end;

  SetGridWidth;
  SetEditFields;
end;

function TWWEdit.GetNewMulti1(aQSO : TQSO) : string;
var str : string;
begin
  if aQSO.QSO.NewMulti1 then
    str := FillRight(aQSO.QSO.Multi1, 3)
  else
    str := '   ';
  if aQSO.QSO.NewMulti2 then
    str := str + aQSO.QSO.Multi2;
  Result := str;
end;

function TKCJEdit.GetNewMulti1(aQSO : TQSO) : string;
var str : string;
begin
  if aQSO.QSO.NewMulti1 then
    str := aQSO.QSO.Multi1
  else
    str := '';
  Result := str;
end;

constructor TDXCCEdit.Create;
begin
  inherited;
  colTime := 0;
  colCall := 1;
  colrcvdRST := 2;
  colrcvdNumber := 3;
  colBand := 4;
  {colMode := 5;}
  {colPower := 6;}
  colPoint := 5;
  colNewMulti1 := 6;
  colOp := 7;
  colMemo := 8;
  MainForm.Grid.ColCount := 9;
  MainForm.ModeEdit.Visible := False;

  NumberWid := 4;
  NewMulti1Wid := 5;

  if UOptions.Options.MultiOp > 0 then
    begin
      OpWid := 6;
      MemoWid := 10;
    end
  else
    begin
      OpWid := 0;
      MemoWid := 16;
      MainForm.OpEdit.Visible := False;
    end;

  SetGridWidth;
  SetEditFields;
end;

function TDXCCEdit.GetNewMulti1(aQSO : TQSO) : string;
begin
  if aQSO.QSO.NewMulti1 then
    Result := aQSO.QSO.Multi1
  else
    Result := '';
end;

constructor TWPXEdit.Create;
begin
  inherited;
  colSerial := 0;
  colTime := 1;
  colCall := 2;
  colrcvdRST := 3;
  colrcvdNumber := 4;
  colBand := 5;
  {colMode := 5;}
  {colPower := 6;}
  colPoint := 6;
  colNewMulti1 := 7;
  colOp := 8;
  colMemo := 9;

  SerialWid := 4;
  TimeWid := 4;
  CallSignWid := 8;
  rcvdRSTWid := 3;
  NumberWid := 4;
  BandWid := 3;
  PointWid := 2;
  OpWid := 6;
  MemoWid := 7;
  NewMulti1Wid := 5;

  MainForm.Grid.Cells[colNewMulti1,0] := 'prefix';

  MainForm.Grid.ColCount := 10;
  MainForm.ModeEdit.Visible := False;
  MainForm.SerialEdit.Visible := True;
  if UOptions.Options.MultiOp > 0 then
    begin
      OpWid := 6;
      MemoWid := 10;
    end
  else
    begin
      OpWid := 0;
      MemoWid := 16;
      MainForm.OpEdit.Visible := False;
    end;

  SetGridWidth;
  SetEditFields;
end;

constructor TJA0Edit.Create;
begin
  inherited;
  MainForm.Grid.ColCount := 11;

  colSerial := 0;
  colTime := 1;
  colCall := 2;
  colrcvdRST := 3;
  colrcvdNumber := 4;
  colBand := 5;
  colMode := 6;
  colPoint := 7;
  colNewMulti1 := 8;
  colOp := 9;
  colMemo := 10;

  MainForm.ModeEdit.Visible := True;
  MainForm.SerialEdit.Visible := True;
  if UOptions.Options.MultiOp > 0 then
    begin
      OpWid := 6;
      MemoWid := 10;
    end
  else
    begin
      OpWid := 0;
      MemoWid := 16;
      MainForm.OpEdit.Visible := False;
    end;

  SetGridWidth;
  SetEditFields;
end;



function TWPXEdit.GetNewMulti1(aQSO : TQSO) : string;
var temp : string;
begin
  temp := '  '+aQSO.QSO.Multi1;
  if aQSO.QSO.NewMulti1 then temp[1] := '*';
  Result := temp;
end;

constructor TSerialGeneralEdit.Create;
begin
  inherited;
  colSerial := 0;
  colTime := 1;
  colCall := 2;
  colrcvdRST := 3;
  colrcvdNumber := 4;
  colBand := 5;
  colMode := 6;
  {colPower := 6;}
  colPoint := 7;
  colNewMulti1 := 8;
  colOp := 9;
  colMemo := 10;

  SerialWid := 4;
  TimeWid := 4;
  CallSignWid := 8;
  rcvdRSTWid := 3;
  NumberWid := 4;
  BandWid := 3;
  ModeWid := 3;
  PointWid := 2;
  OpWid := 6;
  MemoWid := 7;
  NewMulti1Wid := 5;

  MainForm.Grid.Cells[colNewMulti1,0] := 'prefix';

  MainForm.Grid.ColCount := 11;
  MainForm.ModeEdit.Visible := True;
  MainForm.SerialEdit.Visible := True;
  if UOptions.Options.MultiOp > 0 then
    begin
      OpWid := 6;
      MemoWid := 7;
    end
  else
    begin
      OpWid := 0;
      MemoWid := 13;
      MainForm.OpEdit.Visible := False;
    end;

  SetGridWidth;
  SetEditFields;
end;

function TSerialGeneralEdit.GetNewMulti1(aQSO : TQSO) : string;
var temp : string;
begin
  Result := '';
  if GeneralMulti2.PXMulti = 0 then
    begin
      if aQSO.QSO.NewMulti1 then
        Result := aQSO.QSO.Multi1;
    end
  else
    begin
      temp := '  '+aQSO.QSO.Multi1;
      if aQSO.QSO.NewMulti1 then temp[1] := '*';
      Result := temp;
    end;
end;

constructor TIOTAEdit.Create;
begin
  inherited;
  colSerial := 0;
  colTime := 1;
  colCall := 2;
  colrcvdRST := 3;
  colrcvdNumber := 4;
  colBand := 5;
  colMode := 6;
  {colPower := 6;}
  colPoint := 7;
  colNewMulti1 := 8;
  colOp := 9;
  colMemo := 10;

  SerialWid := 4;
  TimeWid := 4;
  CallSignWid := 8;
  rcvdRSTWid := 3;
  NumberWid := 6;
  BandWid := 3;
  ModeWid := 3;
  PointWid := 2;
  OpWid := 6;
  MemoWid := 7;
  NewMulti1Wid := 5;

  //MainForm.Grid.Cells[colNewMulti1,0] := '';

  MainForm.Grid.ColCount := 11;
  //MainForm.ModeEdit.Visible := False;
  MainForm.SerialEdit.Visible := True;
  if UOptions.Options.MultiOp > 0 then
    begin
      OpWid := 6;
      MemoWid := 5;
    end
  else
    begin
      OpWid := 0;
      MemoWid := 11;
      MainForm.OpEdit.Visible := False;
    end;

  SetGridWidth;
  SetEditFields;
end;

function TIOTAEdit.GetNewMulti1(aQSO : TQSO) : string;
var temp : string;
begin
  //temp := '  '+aQSO.QSO.Multi1;
  if aQSO.QSO.NewMulti1 then
    temp := aQSO.QSO.Multi1;
  Result := temp;
end;

function TGeneralEdit.GetNewMulti1(aQSO : TQSO) : string;
var temp : string;
begin
  if aQSO.QSO.NewMulti1 then
    temp := aQSO.QSO.Multi1
  else
    temp := '';
  Result := temp;
end;

constructor TALLJAEdit.Create;
begin
  inherited;

  colTime := 0;
  colCall := 1;
  colrcvdRST := 2;
  colrcvdNumber := 3;
  colBand := 4;
  colMode := 5;
  colPoint := 6;
  colNewMulti1 := 7;
  colNewPower := 8;
  colOp := 9;
  colMemo := 10;
  MainForm.Grid.ColCount := 11;
  MainForm.NewPowerEdit.Visible := True;
  if UOptions.Options.MultiOp > 0 then
    begin
      OpWid := 6;
      MemoWid := 7;
    end
  else
    begin
      OpWid := 0;
      MemoWid := 13;
      MainForm.OpEdit.Visible := False;
    end;

  SetGridWidth;
  SetEditFields;
 end;

function TALLJAEdit.GetNewMulti1(aQSO : TQSO) : string;
var temp : string;
begin
  if aQSO.QSO.NewMulti1 then
    temp := aQSO.QSO.Multi1
  else
    temp := '';
  Result := temp;
end;

constructor TIARUEdit.Create;
begin
  inherited;

  colTime := 0;
  colCall := 1;
  colrcvdRST := 2;
  colrcvdNumber := 3;
  colBand := 4;
  colMode := 5;
  colPoint := 6;
  colNewMulti1 := 7;
  //colNewPower := 8;
  colOp := 8;
  colMemo := 9;

  NumberWid := 4;
  BandWid := 3;
  NewMulti1Wid := 4;

  MainForm.Grid.ColCount := 10;
  //MainForm.NewPowerEdit.Visible := True;
  if UOptions.Options.MultiOp > 0 then
    begin
      OpWid := 6;
      MemoWid := 11;
    end
  else
    begin
      OpWid := 0;
      MemoWid := 17;
      MainForm.OpEdit.Visible := False;
    end;

  SetGridWidth;
  SetEditFields;
 end;

function TIARUEdit.GetNewMulti1(aQSO : TQSO) : string;
var temp : string;
begin
  if aQSO.QSO.NewMulti1 then
    temp := aQSO.QSO.Multi1
  else
    temp := '';
  Result := temp;
end;

function TARRLDXEdit.GetNewMulti1(aQSO : TQSO) : string;
var temp : string;
begin
  if aQSO.QSO.NewMulti1 then
    temp := aQSO.QSO.Multi1
  else
    temp := '';
  Result := temp;
end;

function TACAGEdit.GetNewMulti1(aQSO : TQSO) : string;
var temp : string;
begin
  if aQSO.QSO.NewMulti1 then
    temp := '*'
  else
    temp := '';
  Result := temp;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var i, j, msec : integer;
    M : TMenuItem;
    s, ss : string;
    B : TBand;
    VerInfo : TOSVersionInfo;
    debugfile : textfile;
//    L : tLabel;
begin
//DEBUGMODE := TRUE;
if DEBUGMODE then
  begin
    assignfile(debugfile, 'DEBUG.TXT');
    rewrite(debugfile);
    writeln(debugfile, 'debug process start');
    closefile(debugfile);
  end;

  defaultTextColor := CallsignEdit.Font.Color;
  OldCallsign := '';
  OldNumber := '';

  EditScreen := nil;
  clStatusLine := clWindowText;
  msec := Options.Settings.CW._interval;
  s := '';

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 1');
    closefile(debugfile);
  end;

  for i := 0 to ParamCount do
    begin
      s := s +' '+ ParamStr(i);
      ss := ParamStr(i);
      if pos('/I',UpperCase(ss))=1 then
        begin
          Delete(ss,1,2);
          try
            j := StrToInt(ss);
          except
            on EConvertError do
              j := 0;
          end;
          if (j > 0) and (j < 100) then
            msec := j;
        end;
    end;

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 2');
    closefile(debugfile);
  end;

  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(VerInfo);

  if VerInfo.dwPlatformId = VER_PLATFORM_WIN32_NT then
    begin
      ZLOG_WIN2KMODE := TRUE;
      BGK32LIB._WIN2KMODE := ZLOG_WIN2KMODE;
    end;

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 3');
    closefile(debugfile);
  end;

  if HiWord(GetKeyState(VK_SHIFT)) <> 0 then // ver 1.9x
    begin
      ZLOG_WIN2KMODE := TRUE;
      BGK32LIB._WIN2KMODE := ZLOG_WIN2KMODE;
    end;

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 4');
    closefile(debugfile);
  end;


  if (pos('/NOBGK', UpperCase(s)) = 0) then
    if HiWord(GetKeyState(VK_SHIFT)) = 0 then // ver 1.9x
       InitializeBGK(msec);

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 5');
    closefile(debugfile);
  end;

  RenewCWToolBar;
  Application.OnHint := ShowHint;
  LastFocus := CallSignEdit; {the place to set focus when ESC is pressed from Grid}

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 6');
    closefile(debugfile);
  end;


  {MyContest := TALLJAContest.Create; }

  CurrentQSO := TQSO.Create;
  Randomize;
  GLOBALSERIAL := Random10*1000;  // for qso id

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 7');
    closefile(debugfile);
  end;

  with CurrentQSO.QSO do
    begin
      NrSent := '';
      Mode := mCW;
      Band := b7;
      Operator := '';
      TX := Options.GetTXNr;
      Reserve3 := NewQSOID;
    end;

  //CallsignEdit.Text := '';
if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 8');
    closefile(debugfile);
  end;


  NumberEdit.Text := '';
  BandEdit.Text := MHzString[CurrentQSO.QSO.Band];
  PowerEdit.Text := CurrentQSO.PowerStr;
  NewPowerEdit.Text := NewPowerString[CurrentQSO.QSO.Power];
  PointEdit.Text := CurrentQSO.PointStr;
  RcvdRSTEdit.Text := CurrentQSO.RSTStr;
  CurrentQSO.UpdateTime;
  TimeEdit.Text := CurrentQSO.TimeStr;
  DateEdit.Text := CurrentQSO.DateStr;


  Grid.RowCount := DisplayedQSOs + 1;

  if Options.Settings._backuppath = '' then
    BackUp1.Enabled := False;

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 9');
    closefile(debugfile);
  end;

  if Options.OpList.Count > 0 then
    begin
      for i := 0 to Options.OpList.Count-1 do
        begin
          M := TMenuItem.Create(Self);
          M.Caption := TrimRight(Copy(Options.OpList.Strings[i], 1, 20));
          M.OnClick := MainForm.OpMenuClick;
          MainForm.OpMenu.Items.Add(M);
          {M.Free;}
        end;
    end;

if DEBUGMODE then
  begin
    append(debugfile);
    writeln(debugfile, 'CHECKPOINT 10');
    closefile(debugfile);
  end;

  TempQSOList := TList.Create;
  ControlPTT(False);

  //SysUtils.Time24Hour := True;

  //ELogJapanese.InitializeFields;

end;

procedure TMainForm.ShowHint(Sender: TObject);
begin
  WriteStatusLine(Application.Hint, false);
end;

procedure TMainForm.FileNew(Sender: TObject);
var R : word;
begin
  if Log.Saved = False then
    begin
      R := MessageDlg('Save changes to '+CurrentFileName+' ?', mtConfirmation,
                  [mbYes, mbNo, mbCancel], 0); {HELP context 0}
      case R of
        mrYes : FileSave(Sender);
        mrCancel : exit;
      end;
    end;
  CurrentFileName := '';
  Hide;
  MyContest.ScoreForm.Close;
  MyContest.MultiForm.Close;
  MenuForm.ShowModal;{ Add code to create a new file }
end;

procedure TMainForm.FileOpen(Sender: TObject);
begin
  OpenDialog.Title := 'Open file';

  OpenDialog.InitialDir := Options.Settings._logspath;

  if OpenDialog.Execute then
  begin
    MainForm.WriteStatusLine('Loading...', false);
    {MyContest.LoadFromFile(OpenDialog.FileName);}
    CurrentFileName := OpenDialog.FileName;
    MainForm.LoadNewContestFromFile(CurrentFileName);
    MyContest.Renew;
    //EditScreen.Renew;
    //EditScreen.RefreshScreen;
    MainForm.WriteStatusLine('', false);
    MainForm.Caption := 'zLog for Windows  ' + ExtractFileName(CurrentFileName);
    { Add code to open OpenDialog.FileName }
  end;
end;

procedure TMainForm.FileSave(Sender: TObject);
begin
   if CurrentFileName <> '' then
     Log.SaveToFile(CurrentFileName)
   else
     FileSaveAs(Self);
   { Add code to save current file under current name }
end;

procedure TMainForm.FileSaveAs(Sender: TObject);
begin
 // CloseBGK; {hangs up when FDD is selected. why?}
  if SaveDialog.Execute then
  begin
    Log.SaveToFile(SaveDialog.FileName);
    CurrentFileName := SaveDialog.FileName;
    MainForm.Caption := 'zLog for Windows  ' + ExtractFileName(CurrentFileName);
    { Add code to save current file under SaveDialog.FileName }
  end;
//  InitializeBGK;
end;

function ExecuteFile(const FileName, Params, DefaultDir: string;
  ShowCmd: Integer): THandle;
var
  zFileName, zParams, zDir: array[0..79] of Char;
begin
  Result := ShellExecute(MainForm.Handle, nil,
    StrPCopy(zFileName, FileName), StrPCopy(zParams, Params),
    StrPCopy(zDir, DefaultDir), ShowCmd);
end;

procedure TMainForm.FilePrint(Sender: TObject);
var R : Integer;
    S : string;
begin

  if Log.Saved = False then
    begin
      R := MessageDlg('Save changes to '+CurrentFileName+' ?', mtConfirmation,
                  [mbYes, mbNo, mbCancel], 0); {HELP context 0}
      case R of
        mrYes : FileSave(Sender);
        mrCancel : exit;
      end;
    end;

  R := ExecuteFile('zprintw', //CurrentFileName,
                              ExtractFileName(CurrentFileName),
                    ExtractFilePath(ParamStr(0)), SW_SHOW);

{
  R := ExecuteFile('zprintw' +CurrentFileName,
                              ExtractFileName(CurrentFileName),
                    ExtractFilePath(ParamStr(0)), SW_SHOW);
}
  //MainFOrm.Caption := CUrrentFileName;
  if R > 32 then
    exit; { successful }
  S := 'Unknown error';
  case R of
    0 : S := 'Out of memory or resources';
    ERROR_FILE_NOT_FOUND : S := 'ZPRINTW.EXE not found';
  end;
  WriteStatusLine(S, true);
end;

procedure TMainForm.FilePrintSetup(Sender: TObject);
begin
  //PrinterSetup.Execute;
end;

procedure _RestoreWinState(var F : TForm);
var B : boolean;
    X, Y, H, W : integer;
begin
  Options.ReadWin(F.Name, B, X, Y, H, W);
  if B = True then
    begin
      F.Show;
      F.Left := X;
      F.Top := Y;
      F.Width := W;
      F.Height := H;
    end;
end;

procedure TMainForm.RestoreWindowStates;
var F : TForm;
    B, BB : boolean;
    X, Y, W, H : integer;
    S : string;
begin
  F := CheckCall2;
  _RestoreWinState(F);
  F := PartialCheck;
  _RestoreWinState(F);
  //_RestoreWinState(F);
  F := SuperCheck;
  _RestoreWinState(F);
  //Options.ReadWin2('SuperCheck', F);
  F := CheckMulti;
  _RestoreWinState(F);
  F := CWKeyBoard;
  _RestoreWinState(F);
  F := RigControl;
  _RestoreWinState(F);
  {F := BandScope;
  _RestoreWinState(F);}
  F := BandScope2;
  _RestoreWinState(F);
  F := ChatForm;
  _RestoreWinState(F);
  F := FreqList;
  _RestoreWinState(F);
  F := CommForm;
  _RestoreWinState(F);
  F := ScratchSheet;
  _RestoreWinState(F);
  F := QuickRef;
  _RestoreWinState(F);

  F := MyContest.MultiForm;
  Options.ReadWin('MultiForm', B, X, Y, H, W);
  if B = True then
    begin
      F.Show;
      F.Left := X;
      F.Top := Y;
    end;
  F := MyContest.ScoreForm;
  Options.ReadWin('ScoreForm', B, X, Y, H, W);
  if B = True then
    begin
      F.Show;
      F.Left := X;
      F.Top := Y;
    end;
  Options.RestoreMainForm(X, Y, W, H, B, BB);
  if (W > 0) and (H > 0) then
    begin
      if B then
        begin
          mnHideCWPhToolbar.Checked := True;
          CWToolBar.Height := 1;
          SSBToolBar.Height := 1;
        end;
      if BB then
        begin
          mnHideMenuToolbar.Checked := True;
          MainToolBar.Height := 1;
        end;
      Left := X;
      Top := Y;
      Width := W;
      Height := H;
    end;
  X := Options.GetSuperCheckColumns;
  SuperCheck.ListBox.Columns := X;
  SuperCheck.SpinEdit.Value := X;
end;

procedure TMainForm.RecordWindowStates;
var F : TForm;
begin
  F := CheckCall2;
  //Options.RecordWin(F.Name, F.Visible, F.Left, F.Top);
  Options.RecordWin2(F.Name, F);
  F := PartialCheck;
  Options.RecordWin2(F.Name, F);
  F := SuperCheck;
  Options.RecordWin2(F.Name, F);
  F := CheckMulti;
  Options.RecordWin2(F.Name, F);
  F := CWKeyBoard;
  Options.RecordWin2(F.Name, F);
  F := RigControl;
  Options.RecordWin2(F.Name, F);
  {F := BandScope;
  Options.RecordWin2(F.Name, F); }
  F := BandScope2;
  Options.RecordWin2(F.Name, F);
  F := ChatForm;
  Options.RecordWin2(F.Name, F);
  F := FreqList;
  Options.RecordWin2(F.Name, F);
  F := CommForm;
  Options.RecordWin2(F.Name, F);
  F := ScratchSheet;
  Options.RecordWin2(F.Name, F);
  F := QuickRef;
  Options.RecordWin2(F.Name, F);

  F := MyContest.MultiForm;
  Options.RecordWin('MultiForm', F.Visible, F.Left, F.Top);
  F := MyContest.ScoreForm;
  Options.RecordWin('ScoreForm', F.Visible, F.Left, F.Top);

  Options.RecordMainForm(Left, Top, Width, Height, mnHideCWPhToolBar.Checked, mnHideMenuToolBar.Checked);
  Options.RecordSuperCheckColumns(SuperCheck.ListBox.Columns);
end;

procedure TMainForm.FileExit(Sender: TObject);
var R : word;
begin
  //RigControl.ZCom1.Disconnect;
  //RigControl.ZCom2.Disconnect;
  //RigControl.ZCom3.Disconnect;
  if Log.Saved = False then
    begin
      R := MessageDlg('Save changes to '+CurrentFileName+' ?', mtConfirmation,
                  [mbYes, mbNo, mbCancel], 0); {HELP context 0}
      case R of
        mrYes : FileSave(Sender);
        mrCancel : exit;
      end;
    end;
  CloseBGK;
  RecordWindowStates;

  if MMTTYRunning then
    ExitMMTTY;

  MenuForm.Close;
end;

procedure TMainForm.EditUndo(Sender: TObject);
begin
  { Add code to perform Edit Undo }
end;

procedure TMainForm.EditCut(Sender: TObject);
begin
  { Add code to perform Edit Cut }
end;

procedure TMainForm.EditCopy(Sender: TObject);
begin
  { Add code to perform Edit Copy }
end;

procedure TMainForm.EditPaste(Sender: TObject);
begin
  { Add code to perform Edit Paste }
end;

procedure TMainForm.HelpContents(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTENTS, 0);
end;

procedure TMainForm.HelpSearch(Sender: TObject);
const
  EmptyString: PChar = '';
begin
  Application.HelpCommand(HELP_PARTIALKEY, Longint(EmptyString));
end;

procedure TMainForm.HelpHowToUse(Sender: TObject);
begin
  Application.HelpCommand(HELP_HELPONHELP, 0);
end;

procedure TMainForm.HelpAbout(Sender: TObject);
begin
  ABoutBox.Show;{ Add code to show program's About Box }
end;

procedure ConsoleRigBandSet(B : TBand);
var Q : TQSO;
begin
  Q := TQSO.Create;
  Q.QSO.Band := B;

  if RigControl.Rig <> nil then
    begin
      RigControl.Rig.SetBand(Q);
      if CurrentQSO.QSO.Mode = mSSB then
        RigControl.Rig.SetMode(CurrentQSO);
      RigControl.SetBandMask; // ver 1.9z
      MainForm.UpdateBand(Q.QSO.Band);
    end
  else
    MainForm.UpdateBand(Q.QSO.Band);

  Q.Free;
end;

procedure TMainForm.SetDispHeight(H : integer);
var i : integer;
begin
  Grid.DefaultRowHeight := H;
  EditPanel.Height := H + 9;
  for i := 0 to EditPanel.ControlCount - 1 do
    EditPanel.Controls[i].Height := H;
  Options.Settings._mainrowheight := H;
  Options.Ini.SetInteger('Preferences','RowHeight', Options.Settings._mainrowheight);
end;

procedure TMainForm.ProcessConsoleCommand(S : string);
var Q : TQSO;
    I : Double;
    j : integer;
    temp, temp2 : string;
begin
  Delete(S, 1, 1);
  Q := TQSO.Create;
  temp := S;

  if S = 'ELOG' then
    ELogJapanese.ShowModal;
    
  if S = 'NTMODE' then
    begin
      if ZLOG_WIN2KMODE = True then
        WriteStatusLine('ZLOG_WIN2KMODE = True', false)
      else
        WriteStatusLine('ZLOG_WIN2KMODE = False', false)
    end;

  if pos('WANTED', S) = 1 then
    begin
      Delete(temp, 1, 6);
      temp := TrimRight(temp);
      if temp <> '' then
        begin
          if temp[1] in ['_', '/', '-'] then
            Delete(temp, 1, 1);
          ZLinkForm.PostWanted(CurrentQSO.QSO.Band, temp);
          MyContest.PostWanted(IntToStr(Ord(CurrentQSO.QSO.Band))+' '+temp);
        end;
    end;

  if (pos('CLEARWANTED', S) = 1) or (S='CLRWANTED') then
    begin
      MyContest.ClearWanted;
    end;

  if pos('DELWANTED', S) = 1 then
    begin
      Delete(temp, 1, 9);
      temp := TrimRight(temp);
      if temp <> '' then
        begin
          if temp[1] in ['_', '/', '-'] then
            Delete(temp, 1, 1);
          ZLinkForm.DelWanted(CurrentQSO.QSO.Band, temp);
          MyContest.DelWanted(IntToStr(Ord(CurrentQSO.QSO.Band))+' '+temp);
        end;
    end;

  if pos('HARDWARE', S) = 1 then
    begin
      if pos('ON', S) > 0 then
        begin
          ZLOG_WIN2KMODE := FALSE;
          BGK32LIB._WIN2KMODE := ZLOG_WIN2KMODE;
          WriteStatusLine('Hardware access enabled', False);
        end
      else
        begin
          ZLOG_WIN2KMODE := TRUE;
          BGK32LIB._WIN2KMODE := ZLOG_WIN2KMODE;
          WriteStatusLine('Hardware access disabled', False);
        end
    end;

  if (pos('AUTOBANDSCOPE', S) = 1) or (pos('AUTOBANDMAP', S) = 1)
     or (pos('AUTOBS', S) = 1) then
    begin
      if pos('OFF', S) > 0 then
        begin
          Options.Settings._autobandmap := False;
          WriteStatusLine('Automatic band map OFF', False);
        end
      else
        begin
          Options.Settings._autobandmap := TRUE;
          WriteStatusLine('Automatic band map ON', False);
        end
    end;


  if S = 'T' then
    if TTYConsole <> nil then
      TTYConsole.Show;

  if S = 'MMTTY' then
    begin
      mnMMTTY.Tag := 1;
      mnMMTTY.Caption := 'Exit MMTTY';
      mnTTYConsole.Visible := True;
      Application.CreateForm(TTTYConsole, TTYConsole);
      TTYConsole.SetTTYMode(ttyMMTTY);
      InitializeMMTTY(MainForm.Handle);
    end;

  if S = 'OP' then
    begin
      for j := 1 to OpMenu.Items.Count - 1 do
        begin
          ConsolePad.AddLine(FillRight(OpMenu.Items[j].Caption, 15)+
                             FillLeft(IntToStr(Log.OpQSO(temp2)),5)
                             );
        end;
      ConsolePad.AddLine('');
    end;

  if (S= 'DELDUPES') or (S='DELDUPE') then
    begin
      Log.RemoveDupes;
      MyContest.Renew;
    end;

  if S= 'EXITMMTTY' then
    begin
      TTYConsole.Close;
      TTYConsole.Destroy;
      ExitMMTTY;
    end;

  if pos('HEIGHT', S) = 1 then
    begin
      temp := S;
      Delete(temp, 1, 6);
      temp := TrimLeft(temp);
      try
        j := StrToInt(temp);
      except
        on EConvertError do
          exit;
      end;
      if (j > 17) and (j < 41) then
        SetDispHeight(j);
    end;

  if S= 'MMCLR' then
    MMTTYBuffer := '';


  if S = 'SF' then
    ZLinkForm.SendRigStatus;

  if S = 'CQ' then
    begin
      SetCQ(True);
      //ZLinkForm.SendRigStatus;
    end;

  if S = 'SP' then
    begin
      SetCQ(False);
      //ZLinkForm.SendRigStatus;
    end;

  if S = 'DEBUG' then
    WriteStatusLine('DEBUG_FLAG='+IntToStr(DEBUG_FLAG), false);

  if S = 'CQ?' then
    if CurrentQSO.QSO.CQ then
      WriteStatusLine('CQ status : CQ', false)
    else
      WriteStatusLine('CQ status : SP', false);

  if (S = 'MUL') or (S = 'MULTI') or (S = 'MULT') then
    begin
      Options.Settings._multistation := True;
      Options.SetTXNr(2);
      CurrentQSO.QSO.TX := Options.GetTXNr;
      WriteStatusLine('Multi station', true);

      if MainForm.SerialEdit.Visible then
        if (Options.Settings._syncserial) and (SerialContestType = SER_MS) then
          begin
            CurrentQSO.QSO.Serial := SerialArrayTX[CurrentQSO.QSO.TX];
            MainForm.SerialEdit.Text := CurrentQSO.SerialStr;
          end;

      MainForm.Caption := 'zLog for Windows - Multi station  ' + ExtractFileName(CurrentFileName);
      ReEvaluateCountDownTimer;
      ReEvaluateQSYCount;
    end;
  if S = 'RUN' then
    begin
      Options.Settings._multistation := False;
      Options.SetTXNr(1);
      CurrentQSO.QSO.TX := Options.GetTXNr;
      WriteStatusLine('Running station', true);

      if MainForm.SerialEdit.Visible then
        if (Options.Settings._syncserial) and (SerialContestType = SER_MS) then
          begin
            CurrentQSO.QSO.Serial := SerialArrayTX[CurrentQSO.QSO.TX];
            MainForm.SerialEdit.Text := CurrentQSO.SerialStr;
          end;

      MainForm.Caption := 'zLog for Windows - Running station  ' + ExtractFileName(CurrentFileName);
      ReEvaluateCountDownTimer;
      ReEvaluateQSYCount;
    end;

  if S = 'SERIALTYPE' then
    WriteStatusLine('SerialContestType = ' + IntToStr(SerialContestType), True);
  if S = 'TUNE' then
    begin
      CtrlZCQLoop := True;
      TuneOn;
    end;
  if (S = 'LF') or (S = 'LASTF') then
    if RigControl.Rig <> nil then
      RigControl.Rig.MoveToLastFreq;
  if S = 'TV' then
    if RigControl.Rig <> nil then
      RigControl.Rig.ToggleVFO;
  if S = 'VA' then
    if RigControl.Rig <> nil then
      RigControl.Rig.SetVFO(0);
  if S = 'VB' then
    if RigControl.Rig <> nil then
      RigControl.Rig.SetVFO(1);
  if S = 'RC' then
    if RigControl.Rig <> nil then
      RigControl.Rig.RitClear;

  if S = 'YAESUTEST' then
    if RigControl.Rig <> nil then
      RigControl.Rig.FILO := not(RigControl.Rig.FILO);

  if S = 'SC' then
    SuperCheckButtonClick(Self);
  if S = 'RESET' then
    if RigControl.Rig <> nil then
      RigControl.Rig.Reset;

  if S = 'R1' then
    RigControl.SetCurrentRig(1);

  if S = 'R2' then
    RigControl.SetCurrentRig(2);

  if pos('R',S) = 1 then
    if length(S) = 2 then
      begin
        case S[2] of
          '3'..'9' : RigControl.SetCurrentRig(ord(S[2]) - ord('0'));
        end;
      end;

  if S = 'TR' then
    RigControl.ToggleCurrentRig;

  if pos('MAXRIG', S) = 1 then
    begin
      if length(temp) = 6 then
        WriteStatusLine('MAXRIG = '+IntToStr(RigControl._maxrig), true)
      else
        begin
          Delete(temp, 1, 6);
          temp := TrimRight(temp);
          try
            j := StrToInt(temp);
          except
            on EConvertError do
              exit;
          end;
          if (j >= 2) and (j <= 9) then
            RigControl._maxrig := j;
          WriteStatusLine('MAXRIG set to '+IntToStr(j), true)
        end;
    end;

  if pos('TXNR', S) = 1 then
    begin
      if length(temp) = 4 then
        WriteStatusLine('TX# = '+IntToStr(Options.Settings._txnr), true)
      else
        begin
          Delete(temp, 1, 4);
          temp := TrimRight(temp);
          try
            j := StrToInt(temp);
          except
            on EConvertError do
              exit;
          end;
          if (j >= 0) and (j <= 99) then
            Options.SetTXNr(j);
          CurrentQSO.QSO.TX := Options.GetTXNr;
          WriteStatusLine('TX# set to '+IntToStr(Options.Settings._txnr), true);
          ReevaluateQSYCount;
        end;
    end;

  if pos('PCNAME', S) = 1 then
    begin
      if length(temp) = 6 then
        WriteStatusLine('PC name is '+Options.Settings._pcname, true)
      else
        begin
          Delete(temp, 1, 7);
          temp := TrimRight(temp);
          Options.Settings._pcname := temp;
          Options.Ini.SetString('Z-Link', 'PCName', temp);
          ChatForm.PCNameSet := True;
          WriteStatusLine('PC name set to '+Options.Settings._pcname, true);
        end;
    end;

  if (S = '19') then
    ConsoleRigBandSet(b19);

  if (S = '35') or (S = '3') or (S='37') or (S='38')  then
    ConsoleRigBandSet(b35);

  if (S = '7') then
    ConsoleRigBandSet(b7);

  if (S = '10') then
    ConsoleRigBandSet(b10);

  if (S = '14') then
    ConsoleRigBandSet(b14);

  if (S = '18') then
    ConsoleRigBandSet(b18);

  if (S = '21') then
    ConsoleRigBandSet(b21);

  if (S = '24') then
    ConsoleRigBandSet(b24);

  if (S = '28') then
    ConsoleRigBandSet(b28);

  if (S = '50') then
    ConsoleRigBandSet(b50);

  if (S = '144') then
    ConsoleRigBandSet(b144);

  if (S = '430') then
    ConsoleRigBandSet(b430);

  if (S = '1200') then
    ConsoleRigBandSet(b1200);

  if (S = '2400') then
    ConsoleRigBandSet(b2400);

  if (S = '5600') then
    ConsoleRigBandSet(b5600);

  if (S = '10G') then
    ConsoleRigBandSet(b10G);

  if (S = 'VOICEON') then
    begin
      SetVoiceFlag(1);
    end;

  if (S = 'VOICEOFF') then
    begin
      SetVoiceFlag(0);
    end;

  if (S = 'TEST') then
    begin
      PaddleThread.Stop := True;
      //PaddleThread.Free;
    end;

   if (S = 'TEST2') then
    begin
      BandScope2.MarkCurrentFreq(7060000);
    end;

  if (S = 'SB1') then
    begin
      if RigControl.Rig <> nil then
        RigControl.Rig.SetStopBits(1);
    end;

  if (S = 'SB2') then
    begin
      if RigControl.Rig <> nil then
        RigControl.Rig.SetStopBits(2);
    end;

  if (S = 'B300') then
    begin
      if RigControl.Rig <> nil then
        RigControl.Rig.SetBaudRate(300);
    end;

  if (S = 'B1200') then
    begin
      if RigControl.Rig <> nil then
        RigControl.Rig.SetBaudRate(1200);
    end;

  if (S = 'B2400') then
    begin
      if RigControl.Rig <> nil then
        RigControl.Rig.SetBaudRate(2400);
    end;

  if (S = 'B4800') then
    begin
      if RigControl.Rig <> nil then
        RigControl.Rig.SetBaudRate(4800);
    end;

  if (S = 'B9600') then
    begin
      if RigControl.Rig <> nil then
        RigControl.Rig.SetBaudRate(9600);
    end;

  if (S = 'MOVETOMEMO') then
    begin
      Options.Settings._movetomemo := True;
    end;

  if (S = 'LQ') or (S = 'L') then
    SwitchLastQSOBandMode;
  if S = 'CWOFF' then
    CloseBGK;
  if S = 'CWON' then
    InitializeBGK(Options.Settings.CW._interval);

  try
    I := StrToFloat(S);
  except
    on EConvertError do
      begin
        I := 0;
      end;
  end;

  if (I > 1799) and (I < 1000000) then
    if RigControl.Rig <> nil then
      begin
        RigControl.Rig.SetFreq(Round(I*1000));
        if CurrentQSO.QSO.Mode = mSSB then
          RigControl.Rig.SetMode(CurrentQSO);
        //ZLinkForm.SendRigStatus;
        ZLinkForm.SendFreqInfo(Round(I*1000));
      end
    else
      begin
        RigControl.TempFreq[CurrentQSO.QSO.Band] := I;
        ZLinkForm.SendFreqInfo(Round(I*1000));
      end;

  if pos('SYNCSERIAL', S) = 1 then
    begin
      if pos('OFF', S) > 0 then
        Options.Settings._syncserial := false
      else
        Options.Settings._syncserial := True;
    end;

  if pos('QSYCOUNT', S) = 1 then
    begin
      if pos('OFF', S) > 0 then
        Options.Settings._qsycount := False
      else
        Options.Settings._qsycount := True;
    end;

  if (pos('HELP', S) = 1) or (S = 'H') then
    begin
      if QuickRef.Visible then
        QuickRef.Close
      else
        begin
          QuickRef.Show;
          CallsignEdit.SetFocus;
        end;
    end;

  if (pos('MULTWARN', S) = 1) or (pos('MULTW', S) = 1) or (pos('MW', S) = 1) then
    begin
      if pos('OFF', S) > 0 then
        Options.Settings._multistationwarning := False
      else
        Options.Settings._multistationwarning := True;
    end;

  Q.Free;
end;

procedure TMainForm.CommonEditKeyProcess(Sender: TObject; var Key: Char);
var E : TEdit;
    i : integer;
    str : string;
begin
  E := TEdit(Sender);
  //WriteStatusLine(IntToStr(ord(Key)));
  case Key of
    ^A : begin
           E.SelStart := 0;
           E.SelLength := 0;
           Key := #0;
         end;
    ^E : begin
           E.SelStart := Length(E.Text);
           E.SelLength := 0;
           Key := #0;
         end;
    ^B : begin
           i := E.SelStart;
           if i > 0 then
             E.SelStart := i - 1;
           Key := #0;
         end;
    ^F : begin
           i := E.SelStart;
           if i < Length(E.Text) then
             E.SelStart := i + 1;
           Key := #0;
         end;
    ^H : begin
           Key := Chr($08);
         end;
    ^D : begin
           i := E.SelStart;
           str := E.Text;
           if i < Length(E.Text) then
             Delete(str, i+1, 1);
           E.Text := str;
           E.SelStart := i;
           Key := #0;
         end;
    ^J : begin
           i := E.SelStart;
           str := E.Text;
           str := copy(str, 1, i);
           E.Text := str;
           E.SelStart := length(str);
           Key := #0;
         end;
  end;
end;

procedure TMainForm.IncFontSize;
var j : integer;
begin
  j := EditPanel.Font.Size;
  if j < 21 then
    inc(j)
  else
    j := 9;
  EditPanel.Font.Size := j;
  Grid.Font.Size := j;
  EditDialog.Font.Size := j;
  Options.Settings._mainfontsize := j;
  Options.Ini.SetInteger('Preferences','FontSize', Options.Settings._mainfontsize);
end;

procedure TMainForm.SwitchCWBank(Action: integer); // 0 : toggle; 1,2 bank#)
var j : integer;
begin
  if Action = 0 then
    begin
      if Options.Settings.CW.CurrentBank = 1 then
        Options.Settings.CW.CurrentBank := 2
      else
        Options.Settings.CW.CurrentBank := 1;
    end
  else
    Options.Settings.CW.CurrentBank := Action;

  if Options.Settings.CW.CurrentBank = 1 then
    begin
      j := clGreen;
      WriteStatusLine('CW Bank A', false)
    end
  else
    begin
      j := clMaroon;
      WriteStatusLine('CW Bank B', false);
    end;

            CWF1.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 1);
            CWF2.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 2);
            CWF3.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 3);
            CWF4.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 4);
            CWF5.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 5);
            CWF6.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 6);
            CWF7.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 7);
            CWF8.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 8);
            CWF1.FaceColor := j;
            CWF2.FaceColor := j;
            CWF3.FaceColor := j;
            CWF4.FaceColor := j;
            CWF5.FaceColor := j;
            CWF6.FaceColor := j;
            CWF7.FaceColor := j;
            CWF8.FaceColor := j;
end;

procedure TMainForm.EditKeyPress(Sender: TObject; var Key: Char);
var j : integer;
    E : Extended;
    Q : TQSO;
    XY : TGridRect;
    Boo : boolean;
label jjj;
begin
  CommonEditKeyProcess(Sender, Key);
  if CallsignEdit.Font.Color = clGrayText then
    begin
      if Key <> ' ' then
        begin
          CallsignEdit.Text := OldCallsign;
          NumberEdit.Text := OldNumber;
        end;
      CallsignEdit.Font.Color := defaultTextColor;
      NumberEdit.Font.Color := defaultTextColor;
      if Key <> ' ' then
        exit;
    end;
  case Key of
    '@' :
      begin
        MyContest.MultiForm.SelectAndAddNewPrefix(CurrentQSO.QSO.Callsign);
        Key := #0;
      end;
    '\' :
      begin
        ControlPTT(not(PTTIsOn)); // toggle PTT;
        Key := #0;
      end;
    'X','x' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            RigControl.ToggleCurrentRig;
            Key := #0;
          end;
      end;
    '!' : ToggleFixedSpeed;
    '-' :   // up key
      begin
        ToggleFixedSpeed;
        Key := #0;
        {
        Grid.Row := Grid.RowCount - 1;
        LastFocus := TEdit(Sender);
        Grid.SetFocus;
        Key := #0;}
      end;
    'V','v' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            if RigControl.Rig <> nil then
              RigControl.Rig.ToggleVFO;
            Key := #0;
          end;
      end;
    ^I :
      begin
        if PartialCheck.Visible then
          begin
            if PartialCheck.HitNumber > 0 then
              CallsignEdit.Text := PartialCheck.HitCall
            else
              if SuperCheck.Visible then
                if SuperCheck.HitNumber > 0 then
                  CallsignEdit.Text := SuperCheck.HitCall;
          end
        else  // partial check is not visible
          begin
            if SuperCheck.Visible then
              if SuperCheck.HitNumber > 0 then
                CallsignEdit.Text := SuperCheck.HitCall;
          end;
        Key := #0;
      end;
    ^S :
      begin
        IncFontSize;
        Key := #0;
      end;
    '+', ';' :
      begin
        DownKeyPress;
        Key := #0;
      end;
    ^N :   // insert band scope
      begin
        if HiWord(GetKeyState(VK_SHIFT))=0 then
          Boo := True
        else
          Boo := False;
        if RigControl.Rig <> nil then
          begin
            j := RigControl.Rig.CurrentFreqHz;
            if j > 0 then
              begin
                //BandScope.CreateBSData(CurrentQSO, j);
                BandScope2.CreateBSData(CurrentQSO, j);
              end
            else
              goto jjj;
            if Boo then
              begin
                CallsignEdit.Clear;
                NumberEdit.Clear;
              end;
          end
        else // no rig control
          begin
            jjj :
            IntegerDialog.SetLabel('Enter frequency in kHz');
            IntegerDialog.ShowModal;
            E := IntegerDialog.GetValueExtended;
            if E > 1000 then
              begin
                //BandScope.CreateBSData(CurrentQSO, Round(E*1000));
                BandScope2.CreateBSData(CurrentQSO, Round(E*1000));
              end;
            if Boo then
              begin
                CallsignEdit.Clear;
                NumberEdit.Clear;
              end;
          end;
        Key := #0;
      end;
    ^O :
      begin
        CurrentQSO.DecTime;
        TimeEdit.Text := CurrentQSO.TimeStr;
        DateEdit.Text := CurrentQSO.DateStr;
        Key := #0;
      end;
    ^P :
      begin
        CurrentQSO.IncTime;
        TimeEdit.Text := CurrentQSO.TimeStr;
        DateEdit.Text := CurrentQSO.DateStr;
        Key := #0;
      end;
    ^W :
      begin
        TEdit(Sender).Clear;
        WriteStatusLine('', false);
        Key := #0;
      end;
    ^R :
      begin
        Options.ReversePaddle;
        Key := #0;
      end;
    ^K :
      begin
        EditedSinceTABPressed := tabstate_normal;
        CallsignEdit.Clear;
        NumberEdit.Clear;
        MemoEdit.Clear;
        Key := #0;
        CallsignEdit.SetFocus;
        WriteStatusLine('', false);
      end;
    'Z' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            if CurrentQSO.QSO.mode = mCW then
              begin
                CQRepeatClick1(Sender);
              end
            else
              begin
                CQRepeatVoice1Click(Sender);
              end;
            Key := #0;
          end;
      end;
    ^Z :
       begin
         if CurrentQSO.QSO.mode = mCW then
           CQRepeatClick2(Sender)
         else
           CQRepeatVoice2Click(Sender);
         Key := #0;
       end;
    ^T :
      begin
        CtrlZCQLoop := True;
        TuneOn;
      end;
    Chr($1B) :  {ESC}
      begin
        CWStopButtonClick(Self);
        VoiceStopButtonClick(Self);
        Key := #0;
      end;
    ' ' :
      begin
        if (TEdit(Sender).Name = 'NumberEdit') or (TEdit(Sender).Name = 'TimeEdit') or
           (TEdit(Sender).Name = 'DateEdit') then
          begin
            Key := #0;
            if PostContest and (TEdit(Sender).Name = 'NumberEdit') then
              begin
                if TimeEdit.Visible then
                  TimeEdit.SetFocus;
                if DateEdit.Visible then
                  DateEdit.SetFocus;
              end
            else
              CallsignEdit.SetFocus;
          end
        else {if space is pressed when Callsign edit is in focus}
          begin
            if NumberEdit.Text = '' then
              begin
                {
                if Not(PostContest) then
                  CurrentQSO.UpdateTime;
                TimeEdit.Text := CurrentQSO.TimeStr;
                DateEdit.Text := CurrentQSO.DateStr;
                }
              end;
            Key := #0;
            //j := Log.IsDupe(CurrentQSO);
            Q := Log.QuickDupe(CurrentQSO);
            if Q <> nil then
              begin
                MessageBeep(0);
                if AllowDupe then
                  begin
                    WriteStatusLineRed(Q.PartialSummary(Options.Settings._displaydatepartialcheck), true);
                    NumberEdit.SetFocus;
                    Exit;
                  end;
                CallsignEdit.SelectAll;
                WriteStatusLineRed(Q.PartialSummary(Options.Settings._displaydatepartialcheck), true);
                exit;
              end
            else {if not dupe}
              begin
                MyContest.SpaceBarProc;
              end;
            NumberEdit.SetFocus;
          end;
        end;
    'Y','y' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            IncCWSpeed;
            Key := #0;
          end;
      end;
    'F','f' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            (*
            if Options.Settings.CW.CurrentBank = 1 then
              begin
                Options.Settings.CW.CurrentBank := 2;
                j := clMaroon;
              end
            else
              begin
                Options.Settings.CW.CurrentBank := 1;
                j := clGreen;
              end;
            if Options.Settings.CW.CurrentBank = 1 then
              WriteStatusLine('CW Bank A', false)
            else
              WriteStatusLine('CW Bank B', false);

            CWF1.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 1);
            CWF2.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 2);
            CWF3.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 3);
            CWF4.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 4);
            CWF5.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 5);
            CWF6.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 6);
            CWF7.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 7);
            CWF8.Hint := Options.CWMessage(Options.Settings.CW.CurrentBank, 8);
            CWF1.FaceColor := j;
            CWF2.FaceColor := j;
            CWF3.FaceColor := j;
            CWF4.FaceColor := j;
            CWF5.FaceColor := j;
            CWF6.FaceColor := j;
            CWF7.FaceColor := j;
            CWF8.FaceColor := j; *)
            SwitchCWBank(0);
            Key := #0;
          end;
      end;
    'T','t' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            CurrentQSO.UpdateTime;
            TimeEdit.Text := CurrentQSO.TimeStr;
            DateEdit.Text := CurrentQSO.DateStr;
            Key := #0;
          end;
      end;
    'U','u' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            DecCWSpeed;
            Key := #0;
          end;
      end;
    'B','b' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            MyContest.ChangeBand(True);
            Key := #0;
          end;
      end;
    'R','r' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            MainForm.SetR(CurrentQSO);
            RcvdRSTEdit.Text := CurrentQSO.RSTStr;
            Key := #0;
          end;
      end;
    'S','s' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            MainForm.SetS(CurrentQSO);
            RcvdRSTEdit.Text := CurrentQSO.RSTStr;
            Key := #0;
          end;
      end;
    'M','m' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            MyContest.ChangeMode;
            Key := #0;
          end;
      end;
    'P','p' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            MyContest.ChangePower;
            Key := #0;
          end;
      end;
    Chr($0D) :
      begin
        if CallsignEdit.Focused and (pos(',',CallsignEdit.Text) = 1) then
          begin
            ProcessConsoleCommand(CallsignEdit.Text);
            CallsignEdit.Text := '';
          end
        else
          begin
           if HiWord(GetKeyState(VK_SHIFT))<>0 then
             CurrentQSO.QSO.Reserve2 := $FF;
             LogButtonClick(Self);
          end;
        Key := #0;
      end;
    end;
 { of case }
end;


procedure TMainForm.CallsignEditChange(Sender: TObject);
begin
  CurrentQSO.QSO.Callsign := CallsignEdit.Text;
  BGK32LIB.SetCallSign(ShortString(CallsignEdit.Text));
  if EditedSinceTABPressed = tabstate_tabpressedbutnotedited then
    EditedSinceTABPressed := tabstate_tabpressedandedited;

 if PartialCheck.Visible and PartialCheck._CheckCall then
    PartialCheck.CheckPartial(CurrentQSO);
  if SuperCheck.Visible then
    SuperCheck.CheckSuper(CurrentQSO);
  if CheckCall2.Visible then
    CheckCall2.Renew(CurrentQSO);

end;


procedure TMainForm.NumberEditChange(Sender: TObject);
begin
  CurrentQSO.QSO.NrRcvd := NumberEdit.Text;
end;

procedure TMainForm.PowerEditClick(Sender: TObject);
begin
  PowerMenu.Popup(PowerEdit.Left + 50, PowerEdit.Top + 40);
end;

procedure TMainForm.PowerMenuClick(Sender: TObject);
begin
  PowerEdit.Text := PowerString[TPower(TMenuItem(Sender).Tag)];
  CurrentQSO.QSO.power := TPower(TMenuItem(Sender).Tag);
  Options.CurrentPower[CurrentQSO.QSO.Band] := CurrentQSO.QSO.Power;
  LastFocus.SetFocus;
end;

procedure TMainForm.BandEditClick(Sender: TObject);
begin
  BandMenu.Popup(MainForm.Left + BandEdit.Left + 20, MainForm.Top + EditPanel.Top+ BandEdit.Top);
end;

procedure TMainForm.ModeMenuClick(Sender: TObject);
begin
{  ModeEdit.Text := ModeString[TMode(TMenuItem(Sender).Tag)];
  CurrentQSO.QSO.mode := TMode(TMenuItem(Sender).Tag);
  If TMenuItem(Sender).Tag in [1..3] then
    begin
      CurrentQSO.QSO.RSTrcvd := 59;
      CurrentQSO.QSO.RSTsent := 59;
      RcvdRSTEdit.Text := '59';
      Grid.Align := alNone;
      SSBToolBar.Visible := True;
      CWToolBar.Visible := False;
      Grid.Align := alClient;
    end
  else
    begin
      CurrentQSO.QSO.RSTrcvd := 599;
      CurrentQSO.QSO.RSTsent := 599;
      RcvdRSTEdit.Text := '599';
      Grid.Align := alNone;
      CWToolBar.Visible := True;
      SSBToolBar.Visible := False;
      Grid.Align := alClient;
    end;}
  UpdateMode(TMode(TMenuItem(Sender).Tag));
  if RigControl.Rig <> nil then
    RigControl.Rig.SetMode(CurrentQSO);
  LastFocus.SetFocus;
end;

procedure TMainForm.MemoEditChange(Sender: TObject);
begin
  CurrentQSO.QSO.memo := MemoEdit.Text;
end;

procedure TMainForm.ModeEditClick(Sender: TObject);
begin
  ModeMenu.Popup(MainForm.Left+ModeEdit.Left+20, MainForm.Top+EditPanel.Top+ModeEdit.Top);
end;

procedure TMainForm.GridMenuPopup(Sender: TObject);
var i : integer;
    M : TMenuItem;
begin
  SendSpot1.Enabled := CommForm.MaybeConnected;

  mChangePower.Visible := NewPowerEdit.Visible;

  for i := 0 to Ord(HiBand) do
    begin
      GBand.Items[i].Visible := BandMenu.Items[i].Visible;
      GBand.Items[i].Enabled := BandMenu.Items[i].Enabled;
    end;

  for i := 1 to GOperator.Count do
    GOperator.Delete(0);
  if Options.OpList.Count > 0 then
    begin
      M := TMenuItem.Create(Self);
      M.Caption := 'Clear';
      M.OnClick := MainForm.GridOperatorClick;
      MainForm.GOperator.Add(M);
      for i := 0 to Options.OpList.Count-1 do
        begin
          M := TMenuItem.Create(Self);
          M.Caption := Options.OpList.Strings[i];
          M.OnClick := MainForm.GridOperatorClick;
          MainForm.GOperator.Add(M);
        end;
    end;


  if Grid.Row > Log.TotalQSO then
    begin
     for i := 0 to GridMenu.Items.Count-1 do
       GridMenu.Items[i].Enabled := False;
    end
  else
    begin
      for i := 0 to GridMenu.Items.Count-1 do
        GridMenu.Items[i].Enabled := True;
    end;
end;

procedure TMainForm.LoadNewContestFromFile(FileName : string);
var f : file of TQSOdata;
    D : TQSOdata;
    Q : TQSO;
    i : word;
    Boo, Boo2 : boolean;
begin
  {Log.Free;}
  Q := TQSO.Create;

  Q.QSO := TQSO(Log.List[0]).QSO;
  Boo := Log.AcceptDifferentMode;
  Boo2 := Log.CountHigherPoints;


  Log.Destroy;
  Log := TQSOList.Create('test');

  Log.AcceptDifferentMode := Boo;
  Log.CountHigherPoints := Boo2;

  TQSO(Log.List[0]).QSO := Q.QSO; // contest info is set to current contest.

  System.assign(f, FileName);
  reset(f);
  read(f,D);
  {if D.memo = 'ALLJA' then}

  {MyContest.Free;
  MyContest := TALLJAContest.Create;}

  GLOBALSERIAL := 0;

  for i := 1 to FileSize(f)-1 do
    begin
      read(f,D);
      Q.QSO := D;
      if Q.QSO.Reserve3 = 0 then
        Q.QSO.Reserve3 := NewQSOID;
      Log.Add(Q);
    end;

  GLOBALSERIAL := (Q.QSO.Reserve3 div 10000) mod 10000;

  System.close(f);

  CurrentQSO.QSO := Q.QSO;
  CurrentQSO.QSO.Band := Q.QSO.Band;
  CurrentQSO.QSO.Mode := Q.QSO.Mode;
  CurrentQSO.QSO.Callsign := '';
  CurrentQSO.QSO.NrRcvd := '';
  CurrentQSO.QSO.Time := Date + Time;
  CurrentQSO.QSO.TX := Options.GetTXNr;
  CurrentQSO.QSO.Serial := Q.QSO.Serial;
  CurrentQSO.QSO.Memo := '';

  inc(CurrentQSO.QSO.Serial);

  //inc(SerialArray[CurrentQSO.QSO.Band]);
  SerialArray[CurrentQSO.QSO.Band] := CurrentQSO.QSO.Serial;



  SerialEdit.Text := CurrentQSO.SerialStr;
  TimeEdit.Text := CurrentQSO.TimeStr;
  DateEdit.Text := CurrentQSO.DateStr;
  CallsignEdit.Text := CurrentQSO.QSO.callsign;
  RcvdRSTEdit.Text := CurrentQSO.RSTStr;
  NumberEdit.Text := CurrentQSO.QSO.NrRcvd;
  ModeEdit.Text := CurrentQSO.ModeStr;
  BandEdit.Text := CurrentQSO.BandStr;
  PowerEdit.Text := CurrentQSO.PowerStr;
  NewPowerEdit.Text := CurrentQSO.NewPowerStr;
  PointEdit.Text := CurrentQSO.PointStr;
  OpEdit.Text := CurrentQSO.QSO.Operator;
  {CallsignEdit.SetFocus;}
  WriteStatusLine('',false);
  Q.Free;
  Log.Saved := True;
end;

Procedure TMainForm.DeleteCurrentRow;
var R : integer;
begin
  {ZLinkForm.DeleteQSO(TQSO(Log.List[Grid.Row]));
  Log.Delete(Grid.Row);
  MyContest.Renew;}
  R := EditScreen.IndexArray[Grid.Row];
  if (R > 0) and (R <= Log.TotalQSO) then
    begin
      ZLinkForm.DeleteQSO(TQSO(Log.List[R]));
      Log.Delete(R);
      MyContest.Renew;
    end;
end;

{
Procedure TMainForm.MultipleDelete(A, B : LongInt);
var i : LongInt;
begin
  for i := 1 to (B-A+1) do
    begin
      if TQSO(Log.List[A]).QSO.Reserve = actLock then
        begin
        end
      else
        begin
          ZLinkForm.DeleteQSO(TQSO(Log.List[A]));
          Log.Delete(A);
        end;
    end;
  MyContest.Renew;
end;
 }

Procedure TMainForm.MultipleDelete(A, B : LongInt);
var i, j : LongInt;
begin
  for i := B downto A do
    begin
      j := EditScreen.IndexArray[i];
      if TQSO(Log.List[j]).QSO.Reserve = actLock then
        begin
        end
      else
        begin
          if (j > 0) and (j <= Log.TotalQSO) then
            begin
              ZLinkForm.DeleteQSO(TQSO(Log.List[j]));
              Log.Delete(j);
            end;
        end;
    end;
  MyContest.Renew;
end;

procedure TMainForm.DeleteQSO1Click(Sender: TObject);
var _top, _bottom, _oldtop : LongInt;
    R : word;
begin
  with MainForm.Grid do
    begin
      _oldtop := TopRow;
      _top := Selection.Top;
      _bottom := Selection.Bottom;
    end;
  if _top = _bottom then
    begin
     if TQSO(Log.List[EditScreen.IndexArray[_top]]).QSO.Reserve = actLock then
       begin
         WriteStatusLine('This QSO is currently locked',true);
         exit;
       end;
      R := MessageDlg('Are you sure to delete this QSO?', mtConfirmation,
                  [mbYes, mbNo], 0); {HELP context 0}
      if R = mrNo then exit;
      DeleteCurrentRow
    end
  else
    begin
      if (_top < Log.TotalQSO) and (_bottom <= Log.TotalQSO) then
        begin
          R := MessageDlg('Are you sure to delete these QSO''s?', mtConfirmation,
            [mbYes, mbNo], 0); {HELP context 0}
          if R = mrNo then exit;
          //if ShowCurrentBandOnly.Checked = False then
          MultipleDelete(_top, _bottom);
          {else
            begin
            end;  }
        end;
    end;
  //Grid.TopRow := _oldtop;
  //EditScreen.RefreshScreen;
end;

procedure TMainForm.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var i, cb : integer;
    S : string;
begin
  case Key of
    VK_DELETE : begin
                  DeleteQSO1Click(Self);
                  Grid.SetFocus;
                end;
    VK_INSERT : begin
                  InsertQSO1Click(Self);
                  Grid.SetFocus;
                end;
    VK_RETURN : if EditScreen.DirectEdit = False then
                  MyContest.EditCurrentRow;
    VK_ESCAPE : begin
                  if EditScreen.DirectEdit then
                    begin
                      if Grid.EditorMode then
                        begin
                          Grid.Cells[Grid.Col, Grid.Row] := EditScreen.BeforeEdit;
                          Grid.EditorMode := False;
                        end
                      else
                        begin
                          Grid.LeftCol := 0;
                          EditScreen.ResetTopRow;
                          LastFocus.SetFocus;
                        end;
                    end
                  else
                    begin
                      Grid.LeftCol := 0;
                      EditScreen.ResetTopRow;
                      LastFocus.SetFocus;
                    end;
                end;

    VK_F1..VK_F8, VK_F11, VK_F12 :
      begin
        i := Key - VK_F1 + 1;


        cb := Options.Settings.CW.CurrentBank;

        {if ssShift in Shift then   // doesn't work. why?
          begin
            if cb = 1 then
              cb := 2
            else
              cb := 1;
          end;
        }
        if GetAsyncKeyState(VK_SHIFT) < 0 then
          begin
            if cb = 1 then
              cb := 2
            else
              cb := 1;
          end;

        case CurrentQSO.QSO.Mode of
          mCW:
            begin
              S := Options.CWMessage(cb,i);
              S := SetStr(S, CurrentQSO);
              zLogSendStr(S);
            end;
          mSSB, mFM, mAM :SendVoice(i);
          mRTTY :
            begin
              S := Options.CWMessage(3,i);
              S := SetStrNoAbbrev(S, CurrentQSO);
              if TTYConsole <> nil then
                TTYConsole.SendStrNow(S);
            end;
        end;
      end;
   end;
end;

procedure TMainForm.EditQSOClick(Sender: TObject);
var x : LongInt;
begin
  MyContest.EditCurrentRow;
end;

procedure TMainForm.OnTabPress;
var S : shortstring;
    j : integer;
    Q : TQSO;
begin
  {not dupe}
  if Main.CurrentQSO.QSO.Mode in [mSSB, mFM, mAM] then
    begin
      Q := Log.QuickDupe(CurrentQSO);
      if Q <> nil then
        begin
          MainForm.WriteStatusLineRed(Q.PartialSummary(Options.Settings._displaydatepartialcheck), True);
          CallsignEdit.SelectAll;
          CallsignEdit.SetFocus;
          SendVoice(4);
          exit;
        end;
      MyContest.SpaceBarProc;
      NumberEdit.SetFocus;
      SendVoice(2);
      exit;
    end;

  if Main.CurrentQSO.QSO.Mode = mRTTY then
    begin
      MenuForm.TabPressed := True;
      if TTYConsole <> nil then
        TTYConsole.SendStrNow(SetStrNoAbbrev(Options.CWMessage(3, 2), CurrentQSO));
      MyContest.SpaceBarProc;
      NumberEdit.SetFocus;
      exit;
    end;

  if NumberEdit.Text = '' then
    begin
      CurrentQSO.UpdateTime;
      TimeEdit.Text := CurrentQSO.TimeStr;
      DateEdit.Text := CurrentQSO.DateStr;
    end;
  //MyContest.SpaceBarProc;

  MenuForm.TabPressed := True;
  MenuForm.TabPressed2 := True;

  if Options.Settings._switchcqsp then
    begin
      S := SetStr(Options.CWMessage(Options.Settings.CW.CurrentBank, 2), CurrentQSO);
      {
      if Options.Settings.CW.CurrentBank = 2 then
        NumberEdit.SetFocus; }
    end
  else
    S := SetStr(Options.CWMessage(1, 2), CurrentQSO);

  BGK32LIB.ClrBuffer;
  BGK32LIB.PauseCW;
  if Options.PTTEnabled then
    S := S + ')'; // PTT is turned on in ResumeCW
  BGK32LIB.SetCWSendBuf(0, S);
  BGK32LIB.SetCallSign(ShortString(CurrentQSO.QSO.Callsign));
  BGK32LIB.ResumeCW;

  if Options.Settings._switchcqsp then
    CallsignSentProc;
end;

procedure TMainForm.DownKeyPress;
var S : shortstring;
begin
  if CallsignEdit.Text = '' then
    exit;
  case CurrentQSO.QSO.mode of
    mCW :
    begin
      if Not(MyContest.MultiForm.ValidMulti(CurrentQSO)) then
        begin
          if Options.Settings._switchcqsp then
            S := Options.CWMessage(Options.Settings.CW.CurrentBank, 5)
          else
            S := Options.CWMessage(1, 5);
          S := SetStr(S, CurrentQSO);
          if Options.FIFO then
            SendStrFIFO(S)
          else
            SendStr(S);
          WriteStatusLine('Invalid Number', false);
          NumberEdit.SetFocus;
          NumberEdit.SelectAll;
          exit;
        end;
      if Options.Settings._switchcqsp then
        S := Options.CWMessage(Options.Settings.CW.CurrentBank, 3)
      else
        S := Options.CWMessage(1, 3);
      S := SetStr(S, CurrentQSO);
      if Options.FIFO then
        SendStrFIFO(S)
      else
        SendStr(S);
      BGK32LIB.SetCallSign(ShortString(CallsignEdit.Text));
      LogButtonClick(Self);
    end;

    mRTTY :
    begin
      if Not(MyContest.MultiForm.ValidMulti(CurrentQSO)) then
        begin
          S := Options.CWMessage(3, 5);
          S := SetStrNoAbbrev(S, CurrentQSO);
          if TTYConsole <> nil then
            TTYConsole.SendStrNow(S);
          WriteStatusLine('Invalid Number', false);
          NumberEdit.SetFocus;
          NumberEdit.SelectAll;
          exit;
        end;
      S := Options.CWMessage(3, 3);
      S := SetStrNoAbbrev(S, CurrentQSO);
      if TTYConsole <> nil then
        TTYConsole.SendStrNow(S);
      LogButtonClick(Self);
    end;


    mSSB, mFM, mAM :
    begin
      if Not(MyContest.MultiForm.ValidMulti(CurrentQSO)) then
        begin
          SendVoice(5);
          WriteStatusLine('Invalid Number', false);
          NumberEdit.SetFocus;
          NumberEdit.SelectAll;
          exit;
        end;
      SendVoice(3);
      LogButtonClick(Self);
    end;
  end;
end;

procedure TMainForm.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var XY : TGridRect;
    i, cb : integer;
    S : string[255];
begin
//  WRITESTATUSLINE(INTTOSTR(KEY));

  case Key of
    29 : {MUHENKAN KEY}
      begin
        ControlPTT(not(PTTIsOn)); // toggle PTT;
      end;

    VK_F9 :
      begin
        MyContest.MultiForm.CheckMulti(CurrentQSO)
      end;
    VK_DOWN :
      begin
        DownKeyPress;
        Key := 0;
      end;
    VK_INSERT :
      begin
        {
        if TEdit(Sender).Name = 'CallsignEdit' then
          begin
            OnTabPress;
            Key := 0;
          end;
        }
      end;
    VK_F1..VK_F8, VK_F11, VK_F12 :
      begin
        i := Key - VK_F1 + 1;

        cb := Options.Settings.CW.CurrentBank;
 //     if ssShift in Shift then   // doesn't work. why?
        if GetAsyncKeyState(VK_SHIFT) < 0 then
          begin
            if cb = 1 then
              cb := 2
            else
              cb := 1;
          end;

        case CurrentQSO.QSO.Mode of
          mCW:
            begin
              S := Options.CWMessage(cb,i);
              S := SetStr(S, CurrentQSO);
              zLogSendStr(S);
            end;
          mSSB, mFM, mAM :SendVoice(i);
          mRTTY :
            begin
              S := Options.CWMessage(3,i);
              S := SetStrNoAbbrev(S, CurrentQSO);
              if TTYConsole <> nil then
                TTYConsole.SendStrNow(S);
            end;
        end;
      end;
    VK_F10 :
      begin
        //MessageBeep(0);
        PartialCheck.Show;
        //Label1.Caption := TEdit(Sender).Name;
        if TEdit(Sender).Name = 'NumberEdit' then
          begin
            PartialCheck.CheckPartialNumber(CurrentQSO);
          end
        else
          PartialCheck.CheckPartial(CurrentQSO);
        //TEdit(Sender).SetFocus;
        Key := 0;
      end;
    VK_UP :
      begin
        Grid.Row := Grid.RowCount - 1;
        if EditScreen.DirectEdit then
          Grid.Col := TEdit(Sender).Tag;
        LastFocus := TEdit(Sender);
        Grid.SetFocus;
        Key := 0;

        {Grid.SetFocus;
        XY.Left := 0;
        XY.Top := Log.TotalQSO;
        XY.Right := Grid.ColCount;
        XY.Bottom := XY.Top;
        Grid.Selection := XY;
        LastFocus := TEdit(Sender);}
      end;
     Ord('A')..Ord('Z'), Ord('0')..Ord('9') :
       begin
         if Shift <> [] then
           exit;
         if (CtrlZCQLoop = True) and (TEdit(Sender).Name = 'CallsignEdit') then
           CtrlZBreak;
         if (CtrlZCQLoopVoice = True) and (TEdit(Sender).Name = 'CallsignEdit') then
           CtrlZBreakVoice;
         if (Options.Settings._jmode) and (TEdit(Sender).Name = 'CallsignEdit') then
           begin
             if CallsignEdit.Text = '' then
               if Key <> ord('7') then
                 begin
                   CallsignEdit.Text := 'J';
                   CallsignEdit.SelStart := 1;
                 end;
           end;
       end;
  end;
end;

procedure TMainForm.GridDblClick(Sender: TObject);
begin
  MyContest.EditCurrentRow;
end;

procedure TMainForm.PartialClick(Sender: TObject);
begin
  PartialCheck.Show;
  if ActiveControl = NumberEdit then
    PartialCheck.CheckPartialNumber(CurrentQSO)
  else
    PartialCheck.CheckPartial(CurrentQSO);
end;

procedure TMainForm.CallsignEditKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
{  if PartialCheck.Visible and PartialCheck._CheckCall then
    PartialCheck.CheckPartial(CurrentQSO);
  if SuperCheck.Visible then
    SuperCheck.CheckSuper(CurrentQSO);
  if CheckCall2.Visible then
    CheckCall2.Renew(CurrentQSO);  }
end;

procedure TMainForm.ScoreClick(Sender: TObject);
begin
  MyContest.ShowScore;
end;

procedure TMainForm.MultiClick(Sender: TObject);
begin
  MyContest.ShowMulti;
end;

procedure TMainForm.RateClick(Sender: TObject);
begin
  RateDialog.Show;
end;

procedure TMainForm.LogButtonClick(Sender: TObject);
//var aQSO : TQSO;
var _dupe, i, j : integer;
    workedZLO : boolean;
    st, st2 : string;
    B : TBand;
label  med;
begin

  EditedSinceTABPressed := tabstate_normal;

  _dupe := Log.IsDupe(CurrentQSO);
  if (_dupe = 0) or (CurrentQSO.QSO.Reserve2 = $FF) then // $FF when forcing to log
    begin
      if (MyContest.MultiForm.ValidMulti(CurrentQSO)=False) and
         (CurrentQSO.QSO.Reserve2 <> $FF) then
        begin
          WriteStatusLine('Invalid Number', false);
          NumberEdit.SetFocus;
          NumberEdit.SelectAll;
          exit;
        end;
      if CurrentQSO.QSO.Callsign = '' then
        begin
          WriteStatusLine('Callsign not entered', false);
          CallSignEdit.SetFocus;
          exit;
        end;
      if CurrentQSO.QSO.Reserve2 = $FF then
        begin
          CurrentQSO.QSO.Reserve2 := $00; {set it back}
          CurrentQSO.QSO.memo := '* '+ CurrentQSO.QSO.memo;
        end;

med:
      MyContest.SetNrSent(CurrentQSO);

      repeat
        i := NewQSOID;
      until Log.CheckQSOID(i) = False;

      CurrentQSO.QSO.Reserve3 := i;

{      if Options.Settings._recrigfreq = True then
        if RigControl.Rig <> nil then
          CurrentQSO.QSO.Memo := CurrentQSO.QSO.Memo + '('+RigControl.Rig.CurrentFreqkHzStr+')';
}
      if RigControl.Rig <> nil then
        begin
          if Options.Settings._recrigfreq = True then
            CurrentQSO.QSO.Memo := CurrentQSO.QSO.Memo + '('+RigControl.Rig.CurrentFreqkHzStr+')';

          if Options.Settings._autobandmap then
            begin
              j := RigControl.Rig.CurrentFreqHz;
              if j > 0 then
              BandScope2.CreateBSData(CurrentQSO, j);
            end;
        end;
      //if MyContest.Name = 'Pedition mode' then
        if not PostContest then
          CurrentQSO.UpdateTime;

      MyContest.LogQSO(CurrentQSO, True);

      WorkedZLO := False;
      if CurrentQSO.QSO.Callsign = 'JA1ZLO' then
        begin
          if MyContest.Name = 'ALL JA ƒRƒ“ƒeƒXƒg' then
            if CurrentQSO.QSO.Points > 0 then
              begin
                inc(ZLOCOUNT);
                WorkedZLO := True;
              end;
        end;

      if CurrentFileName <> '' then
         begin
           if Log.TotalQSO mod Options.Settings._saveevery = 0 then
             begin
               if Options.Settings._savewhennocw then
                 UMenu.SaveInBackGround := True
               else
                 SaveFileAndBackUp;
             end;
         end;
      ZLinkForm.SendQSO(CurrentQSO); {ZLinkForm checks if Z-Link is ON}

      st := MyContest.MultiForm.ExtractMulti(CurrentQSO);
      if st <> '' then
        begin
          for i := 0 to MyContest.WantedList.Count - 1 do
            begin
              if st = TWanted(MyContest.WantedList[i]).Multi then
                begin
                  st2 := '';
                  for B := b19 to HiBand do
                    if B in TWanted(MyContest.WantedList[i]).Bands then
                      st2 := st2 + ' ' + BandString[B];
                  MessageDlg(st+' is wanted by' +st2, mtInformation, [mbOK], 0);
                end;
            end;
        end;

      if (Options.Settings._ritclear = True) and (RigControl.Rig <> nil) then
        RigControl.Rig.RitClear;

      Inc(CurrentQSO.QSO.Serial);
      SerialArrayTX[Options.GetTXNr] := CurrentQSO.QSO.Serial;

      if Not(PostContest) then
        CurrentQSO.UpdateTime;
      CurrentQSO.QSO.CallSign := '';
      CurrentQSO.QSO.NrRcvd := '';
      CurrentQSO.QSO.Memo := '';

      CurrentQSO.QSO.NewMulti1 := False;
      CurrentQSO.QSO.NewMulti2 := False;

      CurrentQSO.QSO.Dupe := False;
      //CurrentQSO.QSO.CQ := False;

      CurrentQSO.QSO.Reserve2 := 0;
      CurrentQSO.QSO.Reserve3 := 0;
      CurrentQSO.QSO.TX := Options.GetTXNr;

      if CurrentQSO.QSO.mode in [mCW, mRTTY] then
        CurrentQSO.QSO.RSTrcvd := 599
      else
        CurrentQSO.QSO.RSTrcvd := 59;

      SerialEdit.Text := CurrentQSO.SerialStr;
      TimeEdit.Text := CurrentQSO.TimeStr;
      DateEdit.Text := CurrentQSO.DateStr;
      CallsignEdit.Text := CurrentQSO.QSO.callsign;
      RcvdRSTEdit.Text := CurrentQSO.RSTStr;
      NumberEdit.Text := CurrentQSO.QSO.NrRcvd;
      ModeEdit.Text := CurrentQSO.ModeStr;
      BandEdit.Text := CurrentQSO.BandStr;
      PowerEdit.Text := CurrentQSO.PowerStr;
      NewPowerEdit.Text := CurrentQSO.NewPowerStr;
      PointEdit.Text := CurrentQSO.PointStr;
      OpEdit.Text := CurrentQSO.QSO.Operator;
      MemoEdit.Text := '';
      if PostContest then
        TimeEdit.SetFocus
      else
        CallsignEdit.SetFocus;
      WriteStatusLine('', false);
      if WorkedZLO then
        begin
           MainForm.WriteStatusLine('QSO‚ ‚è‚ª‚Æ‚¤‚²‚´‚¢‚Ü‚·', False);
        end;
    end
  else
    begin
      if AllowDupe then
        begin
          CurrentQSO.QSO.Dupe := True;
          CurrentQSO.QSO.Points := 0;
          CurrentQSO.QSO.NewMulti1 := False;
          CurrentQSO.QSO.NewMulti2 := False;
          CurrentQSO.QSO.Multi1 := '';
          CurrentQSO.QSO.Multi2 := '';
          CurrentQSO.QSO.Memo := '-DUPE- '+CurrentQSO.QSO.Memo;
          goto med;
        end
      else
        begin
          CallsignEdit.SetFocus;
          CallsignEdit.SelectAll;
          WriteStatusLine('Dupe', false);
        end;
    end;
end;

procedure TMainForm.OptionsButtonClick(Sender: TObject);
begin
  Options.Show;
end;

procedure TMainForm.SuperCheckButtonClick(Sender: TObject);
begin
  SuperCheck.Show;
  SuperCheck.CheckSuper(CurrentQSO);
end;


procedure TMainForm.FormShow(Sender: TObject);
var s : string;
    i : integer;
    B : TBand;
begin
  if FirstTime then
    begin
      FirstTime := False;
      s := '';
      for i := 0 to ParamCount do
      s := s +' '+ ParamStr(i);
      Options.ImplementSettings(False);
      if PostContest then
        MessageDlg('To change the date, double click the time field.', mtInformation,
                    [mbOK], 0); {HELP context 0}
      if pos('WAEDC', MyContest.Name) > 0 then
        MessageDlg('QTC can be sent by pressing Ctrl+Q', mtInformation, [mbOK], 0);


      EditPanel.Font.Size := Options.Settings._mainfontsize;
      EditDialog.Font.Size := Options.Settings._mainfontsize;
      Grid.Font.Size := Options.Settings._mainfontsize;
      SetDispHeight(Options.Settings._mainrowheight);
      RestoreWindowStates;
    end;
  CallsignEdit.SetFocus;
  if PostContest then
    TimeEdit.SetFocus;
  LastFocus := CallSignEdit; {the place to set focus when ESC is pressed from Grid}
  if CurrentQSO.QSO.mode in [mCW, mRTTY] then
    begin
      Grid.Align := alNone;
      CWToolBar.Visible := True;
      SSBToolBar.Visible := False;
      Grid.Align := alClient;
    end
  else
    begin
      Grid.Align := alNone;
      SSBToolBar.Visible := True;
      CWToolBar.Visible := False;
      Grid.Align := alClient;
    end;
  ModeEdit.Text := CurrentQSO.ModeStr;
  rcvdRSTEdit.Text := CurrentQSO.RSTStr;

  //CurrentQSO.QSO.Serial := SerialArray[b19]; // in case SERIALSTART is defined. SERIALSTART applies to all bands.
  SerialEdit.Text := CurrentQSO.SerialStr;

  CurrentQSO.UpdateTime;
  TimeEdit.Text := CurrentQSO.TimeStr;

  for B := b19 to HiBand do
    begin
      if BandMenu.Items[ord(B)].Visible and BandMenu.Items[ord(B)].Enabled then
        break;
    end;
  if Log.TotalQSO = 0 then
    CurrentQSO.QSO.Band := B;
  BandEdit.Text := MHzString[CurrentQSO.QSO.Band];
  CurrentQSO.QSO.TX := Options.GetTXNr;

  UpdateBand(CurrentQSO.QSO.Band);
  UpdateMode(CurrentQSO.QSO.Mode);
  //BandScope.SetBandMode(CurrentQSO.QSO.Band, CurrentQSO.QSO.Mode);
  BandScope2.SetBandMode(CurrentQSO.QSO.Band, CurrentQSO.QSO.Mode);

  EditScreen.ResetTopRow;     // added 2.2e
  EditScreen.RefreshScreen;    // added 2,2e
end;


procedure TMainForm.CWFButtonClick(Sender: TObject);
var i : integer;
    S, S0 : string[255];
begin
  i := THemisphereButton(Sender).Tag;
  if i in [1..9] then
    begin
      if i = 9 then
        begin
          i := 1; {CQ button}
          SetCQ(True);
        end;
      S := Options.CWMessage(Options.Settings.CW.CurrentBank,i);
      S := SetStr(S, CurrentQSO);
      zLogSendStr(S);
    end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  MyContest.Free;
  CloseBGK;
end;

procedure TMainForm.SpeedBarChange(Sender: TObject);
begin
  Options.SetSpeed(SpeedBar.Position);
  SpeedLabel.Caption := IntToStr(SpeedBar.Position)+' wpm';
  if LastFocus <> nil then
    LastFocus.SetFocus;
end;

procedure TMainForm.SideToneButtonClick(Sender: TObject);
begin
  if SideToneButton.Down then
    Options.SetSideTone(True)
  else
    Options.SetSideTone(False);
end;

procedure TMainForm.Button1Click(Sender: TObject);
var S : string;
begin
  IOTAMulti.Show;
end;

procedure TMainForm.CWStopButtonClick(Sender: TObject);
begin
  BGK32LIB.ClrBuffer;
  CWPlayButton.Visible := False;
  CWPauseButton.Visible := True;
end;

procedure TMainForm.VoiceStopButtonClick(Sender: TObject);
var i : integer;
begin
  UzLogVoice.StopVoice;
end;

procedure TMainForm.SetCQ(CQ : boolean);
begin
  CurrentQSO.QSO.CQ := CQ;

  {if CQ then
    StatusLine.Panels[1].Text := 'CQ'
  else
    StatusLine.Panels[1].Text := 'SP'; }

  ZLinkForm.SendRigStatus;
  if RigControl.Rig = nil then
    ZLinkForm.SendFreqInfo(Round(RigControl.TempFreq[CurrentQSO.QSO.Band]*1000));
  if Options.Settings._switchcqsp then
    begin
      if CQ then
        SwitchCWBank(1)
      else
        SwitchCWBank(2);
    end;
end;

procedure TMainForm.CQRepeatClick1(Sender: TObject);
var S : ShortString;
begin
  S := Options.CWMessage(1,1);
  S := SetStr(Uppercase(S), CurrentQSO);
  SendStrLoop(S);
  SetCQ(True);
end;

procedure TMainForm.CQRepeatClick2(Sender: TObject);
var S : ShortString;
begin
  CtrlZCQLoop := True;
  S := Options.CWMessage(1,1);
  S := SetStr(Uppercase(S), CurrentQSO);
  SendStrLoop(S);
  BGK32LIB.SetRandCQStr(SetStr(Options.Settings.CW.CQStrBank[1], CurrentQSO),
                        SetStr(Options.Settings.CW.CQStrBank[2], CurrentQSO));
  SetCQ(True);
end;

procedure TMainForm.SpeedButton12Click(Sender: TObject);
begin
  {Options.Show;
  Options.PageControl.ActivePage := Options.CWTabSheet;}
  CWKeyBoard.Show;
end;

procedure TMainForm.SpeedButton15Click(Sender: TObject);
begin
  Options.Show;
  Options.PageControl.ActivePage := Options.VoiceTabSheet;
end;

procedure TMainForm.OpMenuClick(Sender: TObject);
var O : string;
begin
  O := TMenuItem(Sender).Caption;
  if O = 'Clear' then O := '';
  OpEdit.Text := O;
  CurrentQSO.QSO.Operator := O;
  LastFocus.SetFocus;
  Options.SetOpPower(CurrentQSO);
  NewPowerEdit.Text := CurrentQSO.NewPowerStr;
  ZLinkForm.SendOperator;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {if ActiveControl is TEdit then
    if (TEdit(ActiveControl) = CallsignEdit) or
       (TEdit(ActiveControl) = NumberEdit) then
       if Key = VK_DOWN then
         begin
           Key := 0;
           DownKeyPress;
         end; }
end;

procedure TMainForm.CWPauseButtonClick(Sender: TObject);
begin
  if BGK32LIB.IsPlaying = False then
    exit;
  BGK32LIB.PauseCW;
  CWPauseButton.Visible := False;
  CWPlayButton.Visible := True;
end;

procedure TMainForm.CWPlayButtonClick(Sender: TObject);
begin
  BGK32LIB.ResumeCW;
  CWPlayButton.Visible := False;
  CWPauseButton.Visible := True;
end;

procedure TMainForm.RcvdRSTEditChange(Sender: TObject);
var i : word;
begin
  try
    I := StrToInt(RcvdRSTEdit.Text);
  except
    on EConvertError do
      begin
        if CurrentQSO.QSO.mode in [mCW, mRTTY] then
          I := 599
        else
          I := 59;
      end;
   end;
   CurrentQSO.QSO.RSTRcvd := I;
end;

procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Options.SetTonePitch(Options.Settings.CW._tonepitch);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FileExit(Sender);
  Action := caNone;
end;


procedure TMainForm.Update10MinTimer;
var Diff : TDateTime;
    min, sec : Integer;
    s : string;
begin
  s := TimeToStr(CurrentTime);
  if length(s) = 7 then
    s := '0'+s;
  s := s + ' ';
  if Options.Settings._countdown then
    begin
      if CountDownStartTime > 0 then
        begin
          Diff := CurrentTime - CountDownStartTime;
          if Diff*24*60 > 10.00 then
            begin
              CountDownStartTime := 0;
              //StatusLine.Panels[1].Text := '';
              s := s + '[QSY OK]';
            end
          else
            begin
              if Diff > 0 then
                begin
                  min := Trunc(10 - Diff*24*60);
                  sec := Trunc(Integer(Round(600 - Diff*24*60*60)) mod 60);
                  sec := Trunc(Integer(Round(600 - Diff*24*60*60)) mod 60);
                  if min = 10 then
                    s := s + IntToStr(min)
                  else
                    s := s + '0'+IntToStr(min);
                  if sec >= 10 then
                    s := s + ':'+IntToStr(sec)
                  else
                    s := s + ':0'+IntToStr(sec);
                end;
            end;
        end
      else  //Countdownstarttime = 0;
        begin
          s := s + '[QSY OK]';
        end;
    end
  else
    begin
      //s := '';
    end;

  if Options.Settings._qsycount then
    begin
      s := s + 'QSY# ' + IntToStr(QSYCount);
    end;

  MainForm.StatusLine.Panels[2].Text := s;
end;

procedure TMainForm.CallSignSentProc;
var Q : TQSO;
    S : shortstring;
begin
  if MainForm.CallsignEdit.Focused then
    begin
      Q := Log.QuickDupe(CurrentQSO);
      if MenuForm.TabPressed2 and (Q <> nil) then
        begin
          BGK32LIB.ClrBuffer;
          MainForm.WriteStatusLineRed(Q.PartialSummary(Options.Settings._displaydatepartialcheck), True);

          if Options.Settings._switchcqsp then
            if Options.Settings.CW.CurrentBank = 2 then
              begin
                CallsignEdit.SelectAll;
                MenuForm.TabPressed := False;
                MenuForm.TabPressed2 := False;
                exit;
              end;

          S := ' '+SetStr(Options.CWMessage(1, 4), CurrentQSO);
          BGK32LIB.SendStr(S);
          BGK32LIB.SetCallSign(ShortString(CurrentQSO.QSO.Callsign));

          CallsignEdit.SelectAll;
          MenuForm.TabPressed := False;
          MenuForm.TabPressed2 := False;

          exit; {BECAREFUL!!!!!!!!!!!!!!!!!!!!!!!!}
        end;
      if MenuForm.TabPressed2 then
        begin
          MyContest.SpaceBarProc;
          MainForm.NumberEdit.SetFocus;
          EditedSinceTABPressed := tabstate_tabpressedbutnotedited; // UzLogCW
        end;
    end;
  BGK32LIB.ResumeCW;
  MenuForm.TabPressed := False;
  MenuForm.TabPressed2 := False;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var S : shortstring;
begin
{$ifndef w95}
  //Caption := IntToStr(VoiceFlag);
  if USB_Detected then
    AboutBox.Label4.Caption := 'USBIF4CW detected'
  else
    AboutBox.Label4.Caption := '';
{$endif}

  Update10MinTimer;

  if not PostContest then
    begin
      CurrentQSO.UpdateTime;
      S := CurrentQSO.TimeStr;
      if S <> TimeEdit.Text then
        TimeEdit.Text := S;
    end;
  //Caption := IntToStr(SelectedBuf);
  {S := CurrentQSO.DateStr;
  if S <> DateEdit.Text then
    DateEdit.Text := S;}
  {
  if BGK32LIB.CallsignSent then
    CallsignSentProc; }
end;

procedure TMainForm.InsertQSO1Click(Sender: TObject);
var _top, _bottom, _oldtop : LongInt;
    R : Integer;
begin
  with MainForm.Grid do
    begin
      _oldtop := TopRow;
      _top := Selection.Top;
      _bottom := Selection.Bottom;
    end;
  if _top = _bottom then
    begin
      R := EditScreen.IndexArray[Grid.Row];
      if R <= Log.TotalQSO then
        begin
          MyContest.PastEditForm.Init(TQSO(Log.List[R]), R, _ActInsert);
          MyContest.PastEditForm.ShowModal;
          EditScreen.Renew;
        end;
     end
  else
    begin
    end;
  Grid.TopRow := _oldtop;
  EditScreen.RefreshScreen;
end;

procedure TMainForm.MemoEditKeyPress(Sender: TObject; var Key: Char);
var j : integer;
begin
  CommonEditKeyProcess(Sender, Key);
  case Key of
    'X','x' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            RigControl.ToggleCurrentRig;
            Key := #0;
          end;
      end;
    'V','v' :
      begin
        if HiWord(GetKeyState(VK_SHIFT))<>0 then
          begin
            if RigControl.Rig <> nil then
              RigControl.Rig.ToggleVFO;
            Key := #0;
          end;
      end;
    '+', ';' :
      begin
        DownKeyPress;
        Key := #0;
      end;
    ^W :
      begin
        TEdit(Sender).Clear;
        Key := #0;
      end;
    ^R :
      begin
        Options.ReversePaddle;
        Key := #0;
      end;
    ^K :
      begin
        EditedSinceTABPressed := tabstate_normal;
        CallsignEdit.Clear;
        NumberEdit.Clear;
        MemoEdit.Clear;
        Key := #0;
        CallsignEdit.SetFocus;
      end;
    ^Z :
       begin
         if CurrentQSO.QSO.mode = mCW then
           CQRepeatClick2(Sender);
         Key := #0;
       end;
    Chr($1B) :  {ESC}
      begin
        CWStopButtonClick(Self);
        VoiceStopButtonClick(Self);
        Key := #0;
      end;
    Chr($0D) :
      begin
        LogButtonClick(Self);
        Key := #0;
      end;
    end;
 { of case }
end;

procedure TMainForm.VoiceFButtonClick(Sender: TObject);
begin
  SendVoice(THemisphereButton(Sender).Tag);
end;

procedure TMainForm.TimeEditChange(Sender: TObject);
var T : TDateTime;
    str : string;
begin
 str := TimeEdit.Text;
 if (length(str) = 4) and (pos(':',str) = 0) then
   str := str[1]+str[2]+':'+str[3]+str[4];
 try
    T := StrToTime(str);
  except
    on EConvertError do
      begin
        T := CurrentQSO.QSO.Time;
        exit;
      end;
  end;
  CurrentQSO.QSO.Time := Int(CurrentQSO.QSO.Time)+Frac(T);
end;

procedure TMainForm.Export1Click(Sender: TObject);
var f, ext : string;
begin
  TXTSaveDialog.FileName := copy(CurrentFileName, 1, length(CurrentFileName) - length(ExtractFileExt(CurrentFileName)));

  if TXTSaveDialog.Execute then
  begin
    f := TXTSaveDialog.FileName;
    ext := UpperCase(ExtractFileExt(f));
    if ext = '.ALL' then
      begin
        Log.SaveToFilezLogALL(f);
        {delete(f, length(f) - 3, 4);
        f := f + '.sum';
        MyContest.WriteSummary(f);}
      end;
    if ext = '.TXT' then
      begin
        Log.SaveToFilezLogDOSTXT(f);
      end;
    if ext = '.TX' then
      begin
        Log.SaveToFileByTX(f);
      end;
     if ext = '.ADI' then
      begin
        MyContest.ADIF_Export(f);
      end;

    { Add code to save current file under SaveDialog.FileName }
  end;
end;

procedure TMainForm.ClusterClick(Sender: TObject);
begin
  CommForm.Show;
end;

procedure TMainForm.SpeedButton9Click(Sender: TObject);
begin
  ZLinkForm.Show;
end;

procedure TMainForm.SerialEditChange(Sender: TObject);
var i : integer;
begin
  try
    i := StrToInt(SerialEdit.Text);
  except
    on EConvertError do
      i := 0;
  end;
  if i > 0 then
    CurrentQSO.QSO.Serial := i;
end;

procedure TMainForm.GridBandChangeClick(Sender: TObject);
var i, j, _top, _bottom: integer;
    R : word;
    B : TBand;
    aQSO : TQSO;
begin
  B := TBand(TMenuItem(Sender).Tag);
  //aQSO := TQSO.Create;
  with MainForm.Grid do
    begin
      _top := Selection.Top;
      _bottom := Selection.Bottom;
    end;
  if _top = _bottom then
    begin
      R := EditScreen.IndexArray[_top];
      if (R > 0) and (R <= Log.TotalQSO) then
        begin
          aQSO := TQSO(Log.List[R]);
          IncEditCounter(aQSO);
          aQSO.QSO.Band := B;
          ZLinkForm.EditQSObyID(aQSO); //added 0.24
        end;
    end
  else
    begin
      if {(ShowCurrentBandOnly.Checked = False) and }(_top < Log.TotalQSO) and (_bottom <= Log.TotalQSO) then
        begin
          R := MessageDlg('Are you sure to change the band for these QSO''s?', mtConfirmation,
            [mbYes, mbNo], 0); {HELP context 0}
          if R = mrNo then exit;
          for i := _top to _bottom do
            begin
              j := EditScreen.IndexArray[i]; //1.4b
              if (j > 0) and (j <= Log.TotalQSO) then
                begin
                  aQSO := TQSO(Log.List[j]);
                  aQSO.QSO.Band := B;
                  IncEditCounter(aQSO);
                  ZLinkForm.EditQSObyID(aQSO); // 0.24
                end;
            end;
        end;
    end;
  //aQSO.Free;
  i := Grid.TopRow;
  MyContest.Renew;
  Grid.TopRow := i;
  EditScreen.RefreshScreen;
end;

procedure TMainForm.ZLinkmonitor1Click(Sender: TObject);
begin
  ZLinkForm.Show;
end;

procedure TMainForm.Load1Click(Sender: TObject);
begin
  ZLinkForm.LoadLogFromZLink;
  {
  if ZLinkForm.Transparent then
    ZLinkForm.LoadLogFromZLink   // clears current log
  else
    ZLinkForm.LoadLogFromZServer;  // does not clear  }
end;

procedure TMainForm.SortbyTime1Click(Sender: TObject);
begin
  Log.SortByTime;
  EditScreen.Renew;
  EditScreen.RefreshScreen;
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.DateEditChange(Sender: TObject);
var T : TDateTime;
begin
  try
    T := StrToDate(DateEdit.Text);
  except
    on EConvertError do
      begin
        T := CurrentQSO.QSO.Time;
        exit;
      end;
  end;
  CurrentQSO.QSO.Time := Int(T) + Frac(CurrentQSO.QSO.Time);
end;

procedure TMainForm.TimeEditDblClick(Sender: TObject);
begin
  if TEdit(Sender).Name = 'TimeEdit' then
    begin
      TimeEdit.Visible := False;
      DateEdit.Visible := True;
//      TimeLabel.Caption := 'date';
    end
  else
    begin
      TimeEdit.Visible := True;
      DateEdit.Visible := False;
//      TimeLabel.Caption := 'time';
    end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var P : Pointer;
    w : word;
begin
  P := GetPointerToMemory($0040*16+$8, 2);
  //w := P^;
 //label1.Caption := IntToStr(w);
  //FreeSelector(Device_Selector);
end;


procedure TMainForm.FormResize(Sender: TObject);
var i, j : integer;
    R : double;
begin
  R := (Grid.Height - 4 - Grid.DefaultRowHeight)/(1 + Grid.DefaultRowHeight);
  if Frac(R) > 0.0001 then
    begin
      i := Trunc(R)*(1+Grid.DefaultRowHeight) + Grid.DefaultRowHeight + 4;
      if Grid.Height > i + 1 then
        MainForm.Height := MainForm.Height + 1
      else
        begin
          DisplayedQSOs := Trunc(R);
          if Grid.RowCount <= DisplayedQSOs then
            Grid.RowCount := DisplayedQSOs + 1;
        end;
    end
  else
    begin
      DisplayedQSOs := Trunc(R);
      if Grid.RowCount <= DisplayedQSOs then
        Grid.RowCount := DisplayedQSOs + 1;
    end;
  i := ClientWidth - Grid.GridWidth;
  if i <> 0 then
    begin
      Grid.ColWidths[Grid.ColCount - 1] := Grid.ColWidths[Grid.ColCount - 1] + i;
      if EditScreen <> nil then
        EditScreen.SetEditFields;
    end;
end;

procedure TMainForm.Options1Click(Sender: TObject);
begin
  Options.Show;
end;

procedure TMainForm.Edit1Click(Sender: TObject);
begin
  Options.Show;
  Options.PageControl.ActivePage := Options.CWTabSheet;
  case TMenuItem(Sender).Tag of
    1 : Options.Edit1.SetFocus;
    2 : Options.Edit2.SetFocus;
    3 : Options.Edit3.SetFocus;
    4 : Options.Edit4.SetFocus;
    5 : Options.Edit5.SetFocus;
    6 : Options.Edit6.SetFocus;
    7 : Options.Edit7.SetFocus;
    8 : Options.Edit8.SetFocus;
  end;
end;

procedure TMainForm.CWF1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  CWFMenu.Items[0].Tag := THemisphereButton(Sender).Tag;
end;

procedure TMainForm.HemisphereButton8MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CWFMenu.Items[0].Tag := 1;
end;

procedure TMainForm.Edit2Click(Sender: TObject);
begin
  Options.Show;
  Options.PageControl.ActivePage := Options.VoiceTabSheet;
  case TMenuItem(Sender).Tag of
    1 : Options.vButton1.SetFocus;
    2 : Options.vButton2.SetFocus;
    3 : Options.vButton3.SetFocus;
    4 : Options.vButton4.SetFocus;
    5 : Options.vButton5.SetFocus;
    6 : Options.vButton6.SetFocus;
    7 : Options.vButton7.SetFocus;
    8 : Options.vButton8.SetFocus;
  end;
end;

procedure TMainForm.VoiceF1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  VoiceMenu.Items[0].Tag := THemisphereButton(Sender).Tag;
end;

procedure TMainForm.HemisphereButton1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  VoiceMenu.Items[0].Tag := 1;
end;

procedure TMainForm.Backup1Click(Sender: TObject);
var p : string;
begin
  p := Options.Settings._backuppath;
  if p <> '' then
    Log.SaveToFile(p + ExtractFileName(CurrentFileName));
end;

procedure TMainForm.CWKeyboard1Click(Sender: TObject);
begin
  CWKeyBoard.Show;
end;

procedure TMainForm.EditEnter(Sender: TObject);
var p : integer;
begin
  LastFocus := TEdit(Sender);
  if TEdit(Sender).Name = 'CallsignEdit' then
    begin
      p := pos('.',CallsignEdit.Text);
      if p > 0 then
        begin
          CallsignEdit.SelStart := p - 1;
          CallsignEdit.SelLength := 1;
        end;
    end;
end;

procedure TMainForm.mnMergeClick(Sender: TObject);
begin
  ZLinkForm.MergeLogWithZServer;
end;

procedure TMainForm.ZServer1Click(Sender: TObject);
begin
  ChatForm.Show;
end;

procedure TMainForm.ConnecttoZServer1Click(Sender: TObject);
begin
  {if ZLinkForm.ZServerConnected then
    ZLinkForm.Sock1.Close
  else
    ZLinkForm.Sock1.Open; }
  ZLinkForm.ZSocket.Addr := Options.Settings._zlinkhost;
  ZLinkForm.ZSocket.Port := 'telnet';
  if ZLinkForm.ZServerConnected then
    begin
      ZLinkForm.DisconnectedByMenu := True;
      ZLinkForm.ZSocket.Close;
    end
  else
    ZLinkForm.ZSocket.Connect;
end;

procedure TMainForm.DisableNetworkMenus;
begin
  mnDownload.Enabled := False;
  mnMerge.Enabled := False;
end;

procedure TMainForm.EnableNetworkMenus;
begin
  mnDownload.Enabled := True;
  mnMerge.Enabled := True;
end;

procedure TMainForm.GridModeChangeClick(Sender: TObject);
var i, j,  _top, _bottom : integer;
    R : word;
    M : TMode;
    aQSO : TQSO;
begin
  M := TMode(TMenuItem(Sender).Tag);
  //aQSO := TQSO.Create;
  with MainForm.Grid do
    begin
      _top := Selection.Top;
      _bottom := Selection.Bottom;
    end;
  if _top = _bottom then
    begin
      R := EditScreen.IndexArray[_top];
      if (R > 0) and (R <= Log.TotalQSO) then
        begin
          aQSO := TQSO(Log.List[R]); //added 0.24

          if M in [mSSB, mAM, mFM] then
            begin
              if not (aQSO.QSO.Mode in [mSSB, mAM, mFM]) then
                begin
                  aQSO.QSO.RSTSent := aQSO.QSO.RSTSent div 10;
                  aQSO.QSO.RSTRcvd := aQSO.QSO.RSTRcvd div 10;
                end;
            end
          else
            begin
              if aQSO.QSO.Mode in [mSSB, mAM, mFM] then
                begin
                  aQSO.QSO.RSTSent := aQSO.QSO.RSTSent * 10 + 9;
                  aQSO.QSO.RSTRcvd := aQSO.QSO.RSTRcvd * 10 + 9;
                end;
            end;

          aQSO.QSO.Mode := M;
          IncEditCounter(aQSO);
          ZLinkForm.EditQSObyID(aQSO); //added 0.24
        end;
    end
  else
    begin
      if {(ShowCurrentBandOnly.Checked = False) and }(_top < Log.TotalQSO) and (_bottom <= Log.TotalQSO) then
        begin
          R := MessageDlg('Are you sure to change the mode for these QSO''s?', mtConfirmation,
            [mbYes, mbNo], 0); {HELP context 0}
          if R = mrNo then exit;
          for i := _top to _bottom do
            begin
              j := EditScreen.IndexArray[i];
              if (j > 0) and (j <= Log.TotalQSO) then
                begin
                  aQSO := TQSO(Log.List[j]); //0.24

                  if M in [mSSB, mAM, mFM] then
                    begin
                      if not (aQSO.QSO.Mode in [mSSB, mAM, mFM]) then
                        begin
                          aQSO.QSO.RSTSent := aQSO.QSO.RSTSent div 10;
                          aQSO.QSO.RSTRcvd := aQSO.QSO.RSTRcvd div 10;
                        end;
                    end
                  else
                    begin
                      if aQSO.QSO.Mode in [mSSB, mAM, mFM] then
                        begin
                          aQSO.QSO.RSTSent := aQSO.QSO.RSTSent * 10 + 9;
                          aQSO.QSO.RSTRcvd := aQSO.QSO.RSTRcvd * 10 + 9;
                        end;
                    end;


                  aQSO.QSO.Mode := M;
                  IncEditCounter(aQSO);
                  ZLinkForm.EditQSObyID(aQSO); // 0.24
                end;
            end;
        end;
    end;
  //aQSO.Free;
  i := Grid.TopRow;
  MyContest.Renew;
  Grid.TopRow := i;
  EditScreen.RefreshScreen;
end;


procedure TMainForm.GridOperatorClick(Sender: TObject);
var i, j, _top, _bottom : integer;
    R : word;
    OpName : string;
    aQSO : TQSO;
begin
  OpName := TMenuItem(Sender).Caption;
  if OpName = 'Clear' then
    OpName := '';
  //aQSO := TQSO.Create;
  with MainForm.Grid do
    begin
      _top := Selection.Top;
      _bottom := Selection.Bottom;
    end;
  if _top = _bottom then
    begin
      R := EditScreen.IndexArray[_top];
      if (R > 0) and (R <= Log.TotalQSO) then
        begin
          aQSO := TQSO(Log.List[R]); //added 0.24
          aQSO.QSO.Operator := OpName;
          IncEditCounter(aQSO);
          ZLinkForm.EditQSObyID(aQSO); //added 0.24
        end;
    end
  else
    begin
      if (_top < Log.TotalQSO) and (_bottom <= Log.TotalQSO) then
        begin
          R := MessageDlg('Are you sure to change the operator names for these QSO''s?', mtConfirmation,
            [mbYes, mbNo], 0); {HELP context 0}
          if R = mrNo then exit;

          for i := _top to _bottom do
            begin
              j := EditScreen.IndexArray[i];
              if (j > 0) and (j <= Log.TotalQSO) then
                begin
                  aQSO := TQSO(Log.List[j]); //0.24
                  aQSO.QSO.Operator := OpName;
                  IncEditCounter(aQSO);
                  ZLinkForm.EditQSObyID(aQSO); // 0.24
                end;
            end;
        end;
    end;
  //aQSO.Free;
  i := Grid.TopRow;
  MyContest.Renew;
  Grid.TopRow := i;
  EditScreen.RefreshScreen;
end;


procedure TMainForm.SendSpot1Click(Sender: TObject);
var i, _top, _bottom : integer;
    R : word;
begin
  with MainForm.Grid do
    begin
      _top := Selection.Top;
      _bottom := Selection.Bottom;
    end;
  if _top = _bottom then
    begin
      R := EditScreen.IndexArray[Grid.Row];
      if R <= Log.TotalQSO then
        begin
          SpotForm.Open(TQSO(Log.List[R]));
        end;
     end
  else
    begin
    end;
end;

procedure TMainForm.NumberEditKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if PartialCheck.Visible and not(PartialCheck._CheckCall) then
    PartialCheck.CheckPartialNumber(CurrentQSO);
  if CheckMulti.Visible then
    CheckMulti.Renew(CurrentQSO);
end;

procedure TMainForm.NewPowerMenuClick(Sender: TObject);
begin
  NewPowerEdit.Text := NewPowerString[TPower(TMenuItem(Sender).Tag)];
  CurrentQSO.QSO.power := TPower(TMenuItem(Sender).Tag);
  LastFocus.SetFocus;
end;

procedure TMainForm.NewPowerEditClick(Sender: TObject);
begin
  NewPowerMenu.Popup(MainForm.Left + NewPowerEdit.Left + 20, MainForm.Top + EditPanel.Top+ NewPowerEdit.Top);
end;

procedure TMainForm.OpEditClick(Sender: TObject);
begin
  OpMenu.Popup(MainForm.Left + OpEdit.Left + 20, MainForm.Top + EditPanel.Top+ OpEdit.Top);
end;

procedure TMainForm.PowerEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key in ['A'..'J','L'..'V','X'..'Z'] then
    Key := #0;
end;

procedure TMainForm.PowerEditChange(Sender: TObject);
var i : integer;
begin
  i := 0;
  if (PowerEdit.Text = 'KW') then
    i := 9999;
  if (PowerEdit.Text = '1KW') then
    i := 10000;
  if (PowerEdit.Text = 'K') then
    i := 10001;

  if i > 0 then
    begin
      CurrentQSO.QSO.Power2 := i;
      Options.CurrentPower2[CurrentQSO.QSO.Band] := i;
      exit;
    end;

  try
    i := StrToInt(PowerEdit.Text);
  except
    i := 0;
  end;
  CurrentQSO.QSO.Power2 := i;
  Options.CurrentPower2[CurrentQSO.QSO.Band] := i;
end;

procedure TMainForm.CheckCall1Click(Sender: TObject);
begin
  CheckCall2.Show;
end;

procedure TMainForm.GridClick(Sender: TObject);
begin
  if not(CheckCall2.Visible) then
    exit;
  // CheckCall.Renew(TQSO(Log.List[Grid.Row]));
  CheckCall2.Renew(TQSO(Log.List[EditScreen.IndexArray[Grid.Row]]));
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  LastFocus.SetFocus;
end;

procedure TMainForm.CreateDupeCheckSheetZPRINT1Click(Sender: TObject);
var R : Integer;
    S : string;
begin
  if Log.Saved = False then
    begin
      R := MessageDlg('Save changes to '+CurrentFileName+' ?', mtConfirmation,
                  [mbYes, mbNo, mbCancel], 0); {HELP context 0}
      case R of
        mrYes : FileSave(Sender);
        mrCancel : exit;
      end;
    end;

  R := ExecuteFile('zlistw', '/ro '+ExtractFileName(CurrentFileName),
                    ExtractFilePath(ParamStr(0)), SW_SHOW);
  if R > 32 then
    exit; { successful }
  S := 'Unknown error';
  case R of
    0 : S := 'Out of memory or resources';
    ERROR_FILE_NOT_FOUND : S := 'ZLISTW.EXE not found';
  end;
  WriteStatusLine(S, True);
end;


procedure TMainForm.MemoHotKeyEnter(Sender: TObject);
begin
  MemoEdit.SetFocus;
end;

procedure TMainForm.memo1Click(Sender: TObject);
begin
  MemoEdit.SetFocus;
end;

procedure TMainForm.rst1Click(Sender: TObject);
begin
  rcvdRSTEdit.SetFocus;
end;

procedure TMainForm.callsign1Click(Sender: TObject);
begin
  CallsignEdit.SetFocus;
end;

procedure TMainForm.ShowCurrentBandOnlyClick(Sender: TObject);
begin
  ShowCurrentBandOnly.Checked := not(ShowCurrentBandOnly.Checked);
  EditScreen.Renew;
  EditScreen.RefreshScreen;
end;

procedure TMainForm.pushqso1Click(Sender: TObject);
begin
  PushQSO(CurrentQSO);
end;

procedure TMainForm.pullqso1Click(Sender: TObject);
begin
  PullQSO;
end;

procedure TMainForm.GridTopLeftChanged(Sender: TObject);
begin
  MainForm.EditScreen.{Cheat}RefreshScreen;
  if Grid.LeftCol <> 0 then
    Grid.LeftCol := 0;
end;

procedure TMainForm.TXTSaveDialogTypeChange(Sender: TObject);
var i : integer;
begin
  i := TXTSaveDialog.FilterIndex;
  if i = 2 then
    TXTSaveDialog.DefaultExt := 'txt'
  else
    TXTSaveDialog.DefaultExt := 'all';
end;

procedure TMainForm.GridMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if EditScreen <> nil then
    EditScreen.SetEditFields;
end;

procedure TMainForm.memo21Click(Sender: TObject);
begin
  NumberEdit.SetFocus;
end;

procedure TMainForm.StatusLineResize(Sender: TObject);
begin
  StatusLine.Panels[2].Width := 100;
  if RigControl.Rig <> nil then
    StatusLine.Panels[1].Width := 47
  else
    StatusLine.Panels[1].Width := 0;
  StatusLine.Panels[0].Width := StatusLine.Width - 100 - StatusLine.Panels[1].Width;
end;

procedure TMainForm.PrintLogSummaryzLog1Click(Sender: TObject);
begin
  //PrinterDialog.Execute;
end;


procedure TMainForm.CQRepeatVoice2Click(Sender: TObject);
begin
  CtrlZCQLoopVoice := True;
  CQLoopVoice;
  SetCQ(True);
end;

procedure TMainForm.CQRepeatVoice1Click(Sender: TObject);
begin
  CQLoopVoice;
  SetCQ(True);
end;


procedure TMainForm.mPXListWPXClick(Sender: TObject);
var str : string;
begin
  GeneralSaveDialog.DefaultExt := 'px';
  GeneralSaveDialog.Filter := 'Prefix list files (*.px)|*.px';
  GeneralSaveDialog.Title := 'Save prefix list';
  if CurrentFileName <> '' then
    begin
      str := CurrentFileName;
      str := Copy(str, 0, length(str) - length(ExtractFileExt(str)));
      str := str + '.px';
      GeneralSaveDialog.FileName := str;
    end;
   if GeneralSaveDialog.Execute then
     WPXMulti.SavePXList(GeneralSaveDialog.FileName);
end;

procedure TMainForm.mSummaryFileClick(Sender: TObject);
var str : string;
begin
  GeneralSaveDialog.DefaultExt := 'zsm';
  GeneralSaveDialog.Filter := 'Summary files (*.zsm)|*.zsm';
  GeneralSaveDialog.Title := 'Save summary file';
  if CurrentFileName <> '' then
    begin
      str := CurrentFileName;
      str := Copy(str, 0, length(str) - length(ExtractFileExt(str)));
      str := str + '.zsm';
      GeneralSaveDialog.FileName := str;
    end;
   if GeneralSaveDialog.Execute then
     MyContest.ScoreForm.SaveSummary(GeneralSaveDialog.FileName);
end;

procedure TMainForm.op1Click(Sender: TObject);
begin
  OpEditClick(Self);
end;

procedure TMainForm.GridPowerChangeClick(Sender: TObject);
var i, j, _top, _bottom : integer;
    R : word;
    P : TPower;
    aQSO : TQSO;
begin
  P := TPower(TMenuItem(Sender).Tag);
//  aQSO := TQSO.Create;
  with MainForm.Grid do
    begin
      _top := Selection.Top;
      _bottom := Selection.Bottom;
    end;
  if _top = _bottom then
    begin
      R := EditScreen.IndexArray[_top];
      if (R > 0) and (R <= Log.TotalQSO) then
        begin
          aQSO := TQSO(Log.List[R]); //added 0.24
          aQSO.QSO.Power := P;
          IncEditCounter(aQSO);
          ZLinkForm.EditQSObyID(aQSO); //added 0.24
        end;
    end
  else
    begin
      if (_top < Log.TotalQSO) and (_bottom <= Log.TotalQSO) then
        begin
          R := MessageDlg('Are you sure to change the power for these QSO''s?', mtConfirmation,
            [mbYes, mbNo], 0); {HELP context 0}
          if R = mrNo then exit;
          for i := _top to _bottom do
            begin
              j := EditScreen.IndexArray[i];
              if (j > 0) and (j <= Log.TotalQSO) then
                begin
                  aQSO := TQSO(Log.List[j]);
                  aQSO.QSO.Power := P;
                  IncEditCounter(aQSO);
                  ZLinkForm.EditQSObyID(aQSO);
                end;
            end;
        end;
    end;
//  aQSO.Free;
  i := Grid.TopRow;
  MyContest.Renew;
  Grid.TopRow := i;
  EditScreen.RefreshScreen;
end;


procedure TMainForm.RigControl1Click(Sender: TObject);
begin
  RigControl.Show;
end;

procedure TMainForm.Console1Click(Sender: TObject);
begin
  ConsolePad.Show;
end;

procedure TMainForm.MergeFile1Click(Sender: TObject);
var ff : string;
    i : integer;
begin
  OpenDialog.Title := 'Merge file';
  if OpenDialog.Execute then
  begin
    MainForm.WriteStatusLine('Merging...', false);
    ff := OpenDialog.FileName;
    if ff = CurrentFileName then
      begin
        MainForm.WriteStatusLine('Cannot merge current file', True);
        exit;
      end;
    i := MergeFile(ff);
    if i > 0 then
      begin
        Log.SortByTime;
        MyContest.Renew;
        //EditScreen.Renew;
        EditScreen.RefreshScreen;
        FileSave(Self);
      end;
    MainForm.WriteStatusLine(IntToStr(i)+' QSO(s) merged.', True);
  end;
end;

procedure TMainForm.RunningFrequencies1Click(Sender: TObject);
begin
  FreqList.Show;
end;

procedure TMainForm.SaveFileAndBackUp;
begin
  Log.SaveToFile(CurrentFileName); //this is where the file is saved!!!
  BackUp1Click(Self); //0.32
end;

procedure TMainForm.mnCheckCountryClick(Sender: TObject);
begin
  CheckCountry.Show;
end;

procedure TMainForm.mnCheckMultiClick(Sender: TObject);
begin
  CheckMulti.Show;
end;

procedure TMainForm.StatusLineDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  if Panel = StatusLine.Panels[0] then
    begin
      StatusBar.Canvas.Font.Color := clStatusLine;
      StatusBar.Canvas.TextOut(Rect.Left+1, Rect.Top+1, Panel.Text);
    end;
end;


procedure TMainForm.Bandscope1Click(Sender: TObject);
begin
  //BandScope.Show;
  BandScope2.Show; //BS2 test
end;

procedure TMainForm.mnChangeTXNrClick(Sender: TObject);
var i, j, _top, _bottom, NewTX, R : integer;
    aQSO : TQSO;
begin
  with MainForm.Grid do
    begin
      _top := Selection.Top;
      _bottom := Selection.Bottom;
    end;
  if _top = _bottom then
    begin
      R := EditScreen.IndexArray[_top];
      if (R > 0) and (R <= Log.TotalQSO) then
        begin
          aQSO := TQSO(Log.List[R]);
          IntegerDialog.Init(Options.Settings._txnr, 'Enter new TX#');
          if IntegerDialog.ShowModal = mrOK then
            begin
              NewTX := IntegerDialog.GetValue;
              if (NewTX >= 0) and (NewTX <= 255) then
                begin
                  IncEditCounter(aQSO);
                  aQSO.QSO.TX := NewTX;
                  //aQSO.QSO.Memo := 'TX#'+IntToStr(aQSO.QSO.TX)+' '+aQSO.QSO.Memo;
                  ZLinkForm.EditQSObyID(aQSO); //added 0.24
                end;
            end;
        end;
    end
  else
    begin
      if (_top < Log.TotalQSO) and (_bottom <= Log.TotalQSO) then
        begin
          R := MessageDlg('Are you sure to change the TX# for these QSO''s?', mtConfirmation,
            [mbYes, mbNo], 0); {HELP context 0}
          if R = mrNo then exit;

          aQSO := TQSO(Log.List[EditScreen.IndexArray[_top]]);
          IntegerDialog.Init(Options.Settings._txnr, 'Enter new TX#');
          if IntegerDialog.ShowModal <> mrOK then
            exit;
          NewTX := IntegerDialog.GetValue;
          if (NewTX > 255) or (NewTX < 0) then
            exit;
          for i := _top to _bottom do
            begin
              j := EditScreen.IndexArray[i]; //1.4b
              if (j > 0) and (j <= Log.TotalQSO) then
                begin
                  aQSO := TQSO(Log.List[j]);
                  aQSO.QSO.TX := NewTX;
                  //aQSO.QSO.Memo := 'TX#'+IntToStr(aQSO.QSO.TX)+' '+aQSO.QSO.Memo;
                  IncEditCounter(aQSO);
                  ZLinkForm.EditQSObyID(aQSO); // 0.24
                end;
            end;
        end;
    end;
  //aQSO.Free;
  i := Grid.TopRow;
  MyContest.Renew;
  Grid.TopRow := i;
  EditScreen.RefreshScreen;
end;

procedure TMainForm.GridKeyPress(Sender: TObject; var Key: Char);
var XY : TGridRect;
begin
  case Key of
    'a'..'z' :
      Key := Chr(ord('A') + ord(Key) - ord('a'));
    ^P, '-' :
      begin
        if Grid.Row > 1 then
          Grid.Row := Grid.Row - 1;
      end;
    ^N, '+' :
      begin
        if Grid.Row < Grid.RowCount - 1 then
          Grid.Row := Grid.Row + 1;
      end;
  end;
end;

procedure TMainForm.mnGridAddNewPXClick(Sender: TObject);
var row, ind : LongInt;
    s : string;
begin
  row := Grid.Row;
  if row > 0 then
    begin
      ind := EditScreen.IndexArray[row];
      if (ind > 0) and (ind <= Log.TotalQSO) then
        begin
          s := TQSO(Log.List[ind]).QSO.Callsign;
          MyContest.MultiForm.SelectAndAddNewPrefix(s);
        end;
    end;
end;

procedure TMainForm.GridSelectCell(Sender: TObject; Col, Row: Integer;
  var CanSelect: Boolean);
begin
  if EditScreen.DirectEdit then
    begin
      EditScreen.BeforeEdit := Grid.Cells[Col, Row];
      if (Col = CallsignEdit.Tag) or (Col = NumberEdit.Tag) or
         (Col = MemoEdit.Tag) then
        Grid.Options := Grid.Options + [goEditing]
      else
        Grid.Options := Grid.Options - [goEditing];
     {
      if Grid.EditorMode then
        WriteStatusLine('EDITMODE=TRUE', false)
      else
        WriteStatusLine('EDITMODE=FALSE',false);}
    end;
end;

procedure TMainForm.GridSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: String);
begin
  WriteStatusLine('SetEditTextCalled',false);
end;

procedure TMainForm.GridGetEditText(Sender: TObject; ACol, ARow: Integer;
  var Value: String);
begin
  WriteStatusLine('GetEditTextCalled',false);
end;

procedure TMainForm.Togglerig1Click(Sender: TObject);
begin
  //WriteStatusLine('Alt+.',False);
  RigControl.ToggleCurrentRig;
end;

procedure TMainForm.mnHideCWPhToolBarClick(Sender: TObject);
begin
  if mnHideCWPhToolBar.Checked = False then
    begin
      Grid.Align := alNone;
      CWToolBar.Height := 1;
      SSBToolBar.Height := 1;
      mnHideCWPhToolBar.Checked := True;
      Grid.Align := alClient;
    end
  else
    begin
      Grid.Align := alNone;
      CWToolbar.Height := 33;
      SSBToolbar.Height := 33;
      mnHideCWPhToolBar.Checked := False;
      Grid.Align := alClient;
    end;
  FormResize(Self);
end;

procedure TMainForm.mnHideMenuToolbarClick(Sender: TObject);
begin
  if mnHideMenuToolBar.Checked = False then
    begin
      Grid.Align := alNone;
      MainToolBar.Height := 1;
      mnHideMenuToolBar.Checked := True;
      Grid.Align := alClient;
    end
  else
    begin
      Grid.Align := alNone;
      MainToolbar.Height := 33;
      mnHideMenuToolBar.Checked := False;
      Grid.Align := alClient;
    end;
  FormResize(Self);
end;

procedure TMainForm.Scratchsheet1Click(Sender: TObject);
begin
  ScratchSheet.Show;
end;

procedure TMainForm.SwitchLastQSOBandMode;
var t, mytx, i : integer;
    boo : boolean;
begin
  if Log.TotalQSO > 0 then
    begin
      t := Log.TotalQSO;
      mytx := Options.GetTXnr;
      boo := false;
      for i := t downto 1 do
        begin
          if TQSO(Log.List[i]).QSO.TX = mytx then
            begin
              boo := true;
              break;
            end;
        end;
      if boo = True then
        begin

          UpdateBand(TQSO(Log.List[i]).QSO.Band);
          if RigControl.Rig <> nil then
            begin
              RigControl.Rig.SetBand(CurrentQSO);
              if CurrentQSO.QSO.Mode = mSSB then
                RigControl.Rig.SetMode(CurrentQSO);
            end;
          UpdateMode(TQSO(Log.List[i]).QSO.Mode);
          if RigControl.Rig <> nil then
            RigControl.Rig.SetMode(CurrentQSO);

          LastFocus.SetFocus;
        end;
    end;
end;

procedure TMainForm.IncreaseFontSize1Click(Sender: TObject);
begin
  IncFontSize;
end;

procedure TMainForm.mnMMTTYClick(Sender: TObject);
begin
  if mnMMTTY.Tag = 0 then
    begin
      mnMMTTY.Tag := 1;
      mnMMTTY.Caption := 'Exit MMTTY';
      mnTTYConsole.Visible := True;
      Application.CreateForm(TTTYConsole, TTYConsole);
      repeat until
        TTYConsole <> nil;
      TTYConsole.SetTTYMode(ttyMMTTY);
      InitializeMMTTY(MainForm.Handle);
      TTYConsole.Show;
      TTYConsole.SetFocus;
      exit;
    end
  else
    begin
      mnMMTTY.Tag := 0;
      mnMMTTY.Caption := 'Load MMTTY';
      mnTTYConsole.Visible := False;
      TTYConsole.Close;
      TTYConsole.Destroy;
      ExitMMTTY;
      exit;
    end;
end;

procedure TMainForm.mnTTYConsoleClick(Sender: TObject);
begin
  TTYConsole.Show;
end;

procedure TMainForm.QTC1Click(Sender: TObject);
begin
   if MyContest.Name <> 'WAEDC Contest' then
     exit;
  QTCForm.Show;
  if CurrentQSO.QSO.Callsign = '' then
    begin
      if Log.TotalQSO >= 2 then
        QTCForm.OpenQTC(TQSO(Log.List[Log.TotalQSO]));
    end
  else
    QTCForm.OpenQTC(Main.CurrentQSO);
end;

procedure TMainForm.mnNewBandScopeClick(Sender: TObject);
var i : integer;
begin
  for i := 1 to BSMax do   // BS2test...
    if UBandScope2.BandScopeArray[i] = nil then
      begin
        UBandScope2.BandScopeArray[i] := TBandScope2.Create(Self);
        UBandScope2.BandScopeArray[i].ArrayNumber := i;
        UBandScope2.BandScopeArray[i].Show;
        UBandScope2.BandScopeArray[i].SetBandMode(CurrentQSO.QSO.Band, CurrentQSO.QSO.Mode);
        exit;
      end;
end;

procedure TMainForm.AutoInput(D : TBSData);
begin
  OldCallsign := CallsignEdit.Text;
  OldNumber := NumberEdit.Text;
  CallsignEdit.Text := D.Call;
  NumberEdit.Text := D.Number;
  CallsignEdit.Font.Color := clGrayText;
  NumberEdit.Font.Color := clGrayText;
end;

procedure TMainForm.QuickReference1Click(Sender: TObject);
begin
  QuickRef.Show;
end;

procedure TMainForm.Timer2Timer(Sender: TObject);
begin
  AutoInput(TBSData(BSList2[0]));
end;

procedure TMainForm.CreateELogJARL1Click(Sender: TObject);
begin
  ELogJapanese.ShowModal;
end;

end.
