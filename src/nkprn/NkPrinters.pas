/////////////////////////////////////////////////
//
// NkPrinters.pas
//
// Coded By T.Nakamura
//
// Ver. 0.1   1998.3.30 ����
// Ver. 0.11  1998.3.31
//   (1) BinNames ��2�Ԗڈȍ~�̃r���������������Ȃ�o�O���C��
//   (2) ���������[�N��1���C��
//   (3) PaperExtent Property �̏�������(���[�U��`�T�C�Y)�� 0.1mm �P�ʂ�
//       �Ȃ��Ă��܂��Ă���o�O���C���BPixel �P�ʂƂ���B
// Ver. 0.12  1998.3.31
//   (1) DevMode �\���̂̕ύX�� DocumentProperties ����čs���悤�ɕύX
// Ver. 0.2  1998.4.2
//   (1) �v�����^�̃p�����[�^����ς���Ƒ��̃p�����[�^�����Z�b�g�����
//       ���܂��Ƃ��������ڂ��o�O���C���B
//   (2) Copies, MaxCopies, Collate property ��ǉ�
//   (3) MaxPaperExtebt, MinPaperExtent Property ��ǉ�
//   (4) �v�����^�̒ǉ��폜�ɑΉ��BOnSystemChanged �C�x���g��ǉ�
//
// Ver. 0.21 1998.4.4
//   (1) Port ���ύX����Ă� Index������Ȃ��悤�ɂ����B
//       ���̂��߃\�[�X��啝�C���I�I ����� Port �ύX�@�\�̏��������B
//   (2) Demo �̏C���BCopies/Collate ���@�\���Ă��Ȃ������B
//   (3) ��O�̒�`�����ׂ� Exception �Ɠ����ɂȂ��Ă����̂ŁA�p����
//       �Ȃ�悤�ɏC��(^^�B
//
// Ver. 0.3  1998.4.5
//   (1) Color, Duplex, Scale, ColorBitCount ��ǉ��B
//   (2) Portnames. Port ��ǉ�
// Ver. 0.31 1998.4.7
//   (1) MaxPaperExtent/MinPaperExtent property �̍폜
//   (2) delphi-cw 99 �œ��� ���������炲�񍐂̗L���� Collate ��
//       �o�O���C��(Orientation ���擾�^�ݒ肵�Ă���(^^;)
//   (3) delphi-cw 99 �œ��� ���������炲�񍐂̗L���� MD-1300 �ł̕s�
//       �ɑΉ��B�����^�r�����̍X�V���r���Ǝ��֌W�� Propety ��
//       �A�N�Z�X���邽�тɍs���悤�ɏC���B
//
// Ver. 0.32 1998.4.9
//   (1) Ver 0.31 �� (3) �̑Ώ��Ńf���v���O�������ٗl�ɒx���Ȃ邱�Ɣ����B
//       �����A�r�����ꗗ�̎擾�� DocumentProperties ���x�����Ƃ������B
//       TNkPrintDialog, TNkPrinterSetupDialog �𓱓����邱�ƂɌ��߂��B
//
// Ver. 0.4  1998.4.18
//   (1) ����i���p�� Property ��ǉ�
//       Quality, Qualities NumQuality Property
//   (2) HasPaperSizeNumber, HasBinNumber ���\�b�h��ǉ�
//   (3) BinNumber Property �̒ǉ�
//   (4) PaperSize Property �� PaperSizeNumber Property �ɉ���
//   (5) NumPaperSizes, NumBins Property ��ǉ�
//   (6) PaperNumbers, BinNumbers Property ��ǉ�
// Ver 0.41 1998.4.19
//   (1) PaperExtent Property �Ń��[�U��`���T�C�Y��ݒ肷��Ƃ� Scale
//       ���l�����Ă��Ȃ������_���C���B
//   (2) MMPageExtent(0.1mm �P�ʂ̈���\�̈�̑傫��) Property ��ǉ�
//   (3) ����{�� ���T�|�[�g����Ă��Ȃ��ꍇ Scale �̓ǂݏo���ł� 100% ��
//       �Ԃ�悤�ɕύX�B
//
// Ver 0.42 1998.4.27
//   (1) MMPaperExtent Property ��V�݁B���[�U��`���T�C�Y�� 0.1 mm �P�ʂ�
//       �ݒ�ł���悤�ɂ����B
//   (2) NkPrinter �� IC or DC ��\�킷 Handle Property ��ǉ�
//   (3) �������\�킷�APrinting Property ��ǉ�
// Ver 0.43 1998.4.29
//   (1) Port �ǉ��^�폜�ɑΉ�
//   (2) �|�[�g�ꗗ�ɓ����|�[�g���������o�Ă���̂ɑΏ�(�ΏǗÖ@)
// Ver 0.44 1998.6.1  �����[�X��
//   (1) �w���v���쐬�B
//   (2) Property �̌^���኱�C��
// Ver 0.45 1998.6.6
//   (1)�v�����^�����T�C�Y���A�r�����A����i�����A�ő啔����
//      DeviceCapabilitites �Œ񋟂��Ȃ��ꍇ���L�邱�ƂɑΉ������B
// Ver 0.46 1998.6.8
//   (1) �w���v���C���B
// Ver 0.5  1998.9.13
//   (1) ApplySettings/DiscardModification ���\�b�h Modified �v���p�e�B��ǉ��B
//       �v�����^�ݒ�̕ύX���_�C���N�g�Ƀv�����^�ɐݒ肹���AApplySettings
//       ���\�b�h�ňꊇ�ݒ肷�邱�Ƃɂ����B
//   (2) MMPaperExtent/PaperExtent ��ǂݎ���p�ɕύX�B���[�U��`���T�C�Y��
//       �擾�^�ύX�p�� UserPaperExtent ��V�݁B


unit NkPrinters;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, WinSpool;

type
  ENkPrinter = class(Exception);
  ENKPrinterRangeError = class(ENkPrinter);       // �v�����^�[�ݒ�p�����[�^��
                                                  //  �͈̓G���[��O
  ENKPrinterPaperSizeError = class(ENkPrinter);   // �T�|�[�g���Ă��Ȃ����T�C�Y
  ENkPrinterBinError = class(ENkPrinter);         // �T�|�[�g���Ă��Ȃ��r��
  ENkPrinterNoPrinter = class(ENkPrinter);        // �v�����^�[������
  ENkPrinterNotSupported = class(ENkPrinter);     // �T�|�[�g���Ă��Ȃ��@�\��
                                                  //  �g�����Ƃ���
  ENkPrinterNoInfo = class(ENkPrinter);           // ��񂪒񋟂���Ă��Ȃ�
  ENkPrinterIllegalIndex = class(ENkPrinter);     // PrinterIndex ���B���ꂽ
  ENkPrinterNoUserPaperExtent = class(ENkPrinter);// ���[�U��`�T�C�Y���擾�s��                                               // �v�����^���w���Ă���B

  // �v�����^�̃T�|�[�g���Ă���@�\
  TNkPrintCap = (nkPcOrientation,         // ���̕���
                 nkPcPaperSize,           // ���̃T�C�Y
                 nkPcPaperlength,         // ���̒����i���[�U��`�T�C�Y�j
                 nkPcPaperWidth,          // ���̕��i���[�U��`�T�C�Y�j
                 nkPcScale,               // �X�P�[�����O
                 nkPcCopies,              // ����
                 nkPcDefaultSource,       // �r��
                 nkPcPrintQuality,        // ����i��
                 nkPcColor,               // �J���[���
                 nkPcDuplex,              // ���ʈ��
                 nkPcYResolution,         // Y ���� �𑜓x
                 nkPcTTOption,            // True Type Option
                 nkPcCollate,             // ����
                 nkPcFormName,            // �t�H�[����
                 nkPcLogPixels,           // �_���C���`
                 nkPcMediaType,           // ���f�B�A�^�C�v
                 nkPcDitherType           // �f�B�U�^�C�v
                );

  TNkPrintCaps = set of TNkPrintCap;      // �T�|�[�g�@�\�̏W��

  TNkPaperOrientation = (nkOrPortrait,    // ���̕����F �c
                         nkOrLandScape    // ���̕����F ��
                        );
  TNkDuplex = (nkDupSimplex,              // �Ж�
               nkDupHorizontal,           // ������������
               nkDupVertical              // ������������
              );

  TNkAvailInfo = (nkAvPaperSize,          // ���T�C�Y���L
                  nkAvBin,                // �r�����L
                  nkAvQuality,            // ����i�����L
                  nkAvMaxCopies);         // �ő啔�����L

  TNkAvailInfos = set of TNkAvailInfo;    // �L�����̏W��


  // EnumPrinters �Ŏ��o���������i�[����N���X�B
  TNkAllPrintersInfo = class
  private
    pPrintersInfo: Pointer;   // Printer_Info_2 �̔z��ւ̃|�C���^�B
    nPrinters: DWORD;       // �v�����^�̐��i�B���ꂽ�v�����^���܂ށj

    function GetName(Index: Integer): string;      // �v�����^���̎��o��
    function GetAttributes(Index: Integer): DWORD; // �����̎��o��
  public
    constructor Create;              // �S�v�����^�̏����擾
    destructor Destroy; override;

    // �S�v�����^���̔�r
    function Compare(Another: TNkAllPrintersInfo): Boolean;
    // �v�����^���i�B���ꂽ�v�����^���܂ށj
    property Count: DWORD read nPrinters;
    //�v�����^��
    property Name[Index: Integer]: string read GetName;
    //�v�����^�̑���
    property Attributes[Index: Integer]: DWORD read GetAttributes;
  end;

  // GetInfo, SetInfo, Release Info �̃p�����[�^�̌^
  TNkPrinterInfo = record
    Device, Driver, Port: array[0..511] of Char;
    hDevMode: THandle;
    pDevMode: PDEVICEMODE;
  end;

  TNkPrinter = class
  private
    AllInfo: TNkAllPrintersInfo;    // �S�v�����^���
    pPaperNumbers: Pointer;         // �T�|�[�g���鎆�T�C�Y�ԍ��̔z���ێ�
    FPaperNames: TStrings;          // �T�|�[�g���鎆�T�C�Y���̔z��

    pBinNumbers: Pointer;           // �T�|�[�g����r���ԍ��̔z��
    FBinNames: TStringList;         // �T�|�[�g����r�����̔z��B

    pResolutions: Pointer;          // �T�|�[�g����𑜓x�̔z��
    FNumResolutions: Integer;       // �T�|�[�g����𑜓x�̐�

    FPrinterNames: TStringList;     // �v�����^�[���̔z��
    FPortNames: TStringList;        // �|�[�g���̔z��
    FMaxCopies: Integer;            // �ő啔��

    FIndex: Integer;                // Printer.PrinterIndex �̒l���Z�[�u��������
                                    // Printer.PrinterIndex ���ύX���ꂽ��
                                    // ���o���邽�߂ɗp����B

    FOnSystemChanged: TNotifyEvent; // �V�X�e���ύX���̃C�x���g�B
                                    // �v�����^�̍폜�ǉ�����ߑ�����̂Ɏg���B

    FAvailInfos: TNkAvailInfos;     // ���p�\�ȏ��������W��


    FModified: Boolean;             // �v�����^�ݒ肪�ύX���ꂽ���������t���O�B
    pSettings: PDEVICEMODE;         // �v�����^�ݒ�(DevMode)�̃R�s�[�B�����ɐݒ��
                                    // �ۑ�����B
    PortName: string;               // �v�����^�ݒ�̃|�[�g���B



    // WM_WININICHANGE ��M�p�t�b�N
    function AppHook(var Msg: TMessage): Boolean;

    procedure CheckNoPrinter;       // �v�����^���L�邩�`�F�b�N�B������Η�O��
                                    // ������B

    // �w�肳�ꂽ�v�����^�̋@�\���T�|�[�g����Ă��邩�`�F�b�N����B
    procedure CheckSupport(Value: TNkPrintCap; str: string);


    function GetInfo: TNkPrinterInfo;           // �v�����^���̎擾
    procedure SetInfo(PrnInfo: TNkPrinterInfo); // �v�����^���̍X�V
    // �v�����^�[���̉��
    procedure ReleaseInfo(PrnInfo: TNkPrinterInfo);

    procedure GetSettings;                      // �v�����^�ݒ�̎擾


    //////////////
    // TNkPrinter ���̏��X�V
    procedure GetPaperSizes;       // ���T�C�Y���̎擾
    procedure GetBins;             // �r�����̎擾
    procedure GetResolutions;      // �𑜓x���̎擾
    procedure GetMaxCopiesInfo;    // �ő啔���̎擾
    procedure Update;              // �v�����^�̊e����̍X�V




    ////////////////////
    // ���֌W�� property �A�N�Z�X���\�b�h
    //

    // PaperSizeNumber Property �̃A�N�Z�X���\�b�h
    function GetPaperSizeNumber: Integer;
    procedure SetPaperSizeNumber(Value: Integer);

    // PaperSizeNames Property �̃A�N�Z�X���\�b�h
    function GetPaperSizeNames: TStrings;

    // PaperSizeIndex Property �̃A�N�Z�X���\�b�h
    function GetPaperSizeIndex: Integer;
    procedure SetPaperSizeIndex(Value: Integer);

    // NumPaperSizes propety �̃A�N�Z�X���\�b�h
    function GetNumPaperSizes: Integer;

    // paperSizeNumbers Property �̃A�N�Z�X���\�b�h
    function GetPaperSizeNumbers(Index: Integer): Integer;

    // PageExtent property �̃A�N�Z�X���\�b�h
    function GetPageExtent: TSize;

    // MMPageExtent property �̃A�N�Z�X���\�b�h
    function GetMMPageExtent: TSize;

    // DPI Proeprty �̃A�N�Z�X���\�b�h
    function GetDPI: TSize;

    // PaperExtent Property �̃A�N�Z�X���\�b�h
    function GetPaperExtent: TSize;

    // MMPaperExtent Property �̃A�N�Z�X���\�b�h
    function GetMMPaperExtent: TSize;

    // UserPaperExtent Property �̃A�N�Z�X���\�b�h
    function GetUserPaperExtent: TSize;
    procedure SetUserPaperExtent(Value: TSize);


    // Offset Property �̃A�N�Z�X���\�b�h
    function GetOffset: TSize;



    ////////////////////
    // Bin �֌W �� property �A�N�Z�X���\�b�h
    //

    // Bin Property �̃A�N�Z�X���\�b�h
    function GetBinNumber: Integer;
    procedure SetBinNumber(Value: Integer);

    // BinNames Property �̃A�N�Z�X���\�b�h
    function GetBinNames: TStrings;

    // BinIndex Property �̃A�N�Z�X���\�b�h
    function GetBinIndex: Integer;
    procedure SetBinIndex(Value: Integer);

    // NumBins property �̃A�N�Z�X���\�b�h
    function GetNumBins: Integer;

    // BinNumbers property �̃A�N�Z�X���\�b�h
    function GetBinNumbers(Index: Integer): Integer;


    ////////////////////
    // ����i���֌W property �̃A�N�Z�X���\�b�h
    //

    // Quality Property�A�N�Z�X���\�b�h�G
    function GetQuality: TSize;
    procedure SetQuality(Value: TSize);

    // Qualities Property �̃A�N�Z�X���\�b�h
    function GetQualities(Index: Integer): TSize;

    // NumQualities Property �̃A�N�Z�X���\�b�h
    function GetNumQualities: Integer;




    ////////////////////
    // �|�[�g�֌W property �̃A�N�Z�X���\�b�h
    //

    // PortNames Property �A�N�Z�X���\�b�h
    function GetPortNames: TStrings;

    // Port Property �A�N�Z�X���\�b�h
    function GetPort: string;
    procedure SetPort(Value: string);




    ////////////////////
    // ���̑��� Property �̃A�N�Z�X���\�b�h
    //
    // PrintCaps Property �̃A�N�Z�X���\�b�h
    function GetPrintCaps: TNkPrintCaps;

    // Orientation Property �̃A�N�Z�X���\�b�h
    function GetOrientation: TNkPaperOrientation;
    procedure SetOrientation(Value: TNkPaperOrientation);

    // PrinterNames Property �̃A�N�Z�X���\�b�h
    function GetPrinterNames: TStrings;

    // MaxCopies Property �̃A�N�Z�X���\�b�h
    function GetMaxCopies: WORD;

    // Copies property �̃A�N�Z�X���\�b�h
    function GetCopies: WORD;
    procedure SetCopies(Value: WORD);

    // Collate property �̃A�N�Z�X���\�b�h
    function GetCollate: Boolean;
    procedure SetCollate(Value: Boolean);

    // Color property �̃A�N�Z�X���\�b�h
    function GetColor: Boolean;
    procedure SetColor(Value: Boolean);

    // Duplex property �̃A�N�Z�X���\�b�h
    function GetDuplex: TNkDuplex;
    procedure SetDuplex(Value: TNkDuplex);

    // Scale property �̃A�N�Z�X���\�b�h
    function GetScale: WORD;
    procedure SetScale(Value: WORD);

    // ColorBitCount Property �A�N�Z�X���\�b�h
    function GetColorBitCount: Integer;

    // Index Property �̃A�N�Z�X���\�b�h
    function GetIndex: Integer;
    procedure SetIndex(Value: Integer);

    // Canvas Property �̃A�N�Z�X���\�b�h
    function GetCanvas: TCanvas;

    // Handle Property �̃A�N�Z�X���\�b�h
    function GetHandle: HDC;

    // Printing Property �̃A�N�Z�X���\�b�h
    function GetPrinting: Boolean;

    function GetAvailInfos: TNkAvailInfos;

  public
    // �R���X�g���N�^ �f�X�g���N�^
    constructor Create;
    destructor Destroy; override;




    ////////////////////
    // ���J ���\�b�h
    //

    // ����֌W�̃��\�b�h
    procedure BeginDoc(Title: string); // ����J�n
    procedure Abort;                   // ������~
    procedure Newpage;                 // �V�y�[�W
    procedure EndDoc;                  // ����I��


    // ���T�C�Y�ԍ����T�|�[�g����Ă��邩�`�F�b�N���郁�\�b�h
    function HasPaperSizeNumber(SizeNumber: Integer): Boolean;

    // �r���ԍ����T�|�[�g����Ă��邩�`�F�b�N���郁�\�b�h
    function HasBinNumber(BinNumber: Integer): Boolean;

    // �����I�ȃv�����^���̍X�V
    procedure ForceUpdate;

    // �v�����^�ݒ���v�����^�ɔ��f����
    procedure ApplySettings;

    // �v�����^�ݒ�̕ύX���̂Ă�
    procedure DiscardModification;


    ////////////////////
    // ���J �v���p�e�B
    //

    // Canvas Property:       NkPrinter �� Canvas
    property Canvas: TCanvas read GetCanvas;

    // �v�����^��IC or DC;
    property Handle: HDC read GetHandle;

    // ������t���O
    property Printing: Boolean read GetPrinting;

    // �C�����ꂽ�ݒ肪�L�邱�Ƃ������B�v�����^�̐ݒ���C������� True �ɂȂ�
    // ApplySettings ���Ă�Őݒ���v�����^�ɑ���� False �ɂȂ�B

    property Modified: Boolean read FModified;

    ////////////
    // ���֌W�� Porperty
    //

    // PaperSizeNumber Property: ���T�C�Y�̔ԍ��B���݂̎��T�C�Y�̎Q�Ɓ^�ݒ��
    //                           �p����B�Ⴆ�� A4 ���Z�b�g����ɂ� DMPAPER_A4
    //                           ���Z�b�g����B
    property PaperSizeNumber: Integer read GetPaperSizeNumber
                                   write SetPaperSizeNumber;

    // PaperSizeNames Property:���T�C�Y���̔z��B�ǂݍ��ݐ�p
    property PaperSizeNames: TStrings read GetPaperSizeNames;

    // PaperSizeIndex Property:���T�C�Y�̃C���f�b�N�X�B���T�C�Y��
    //                         �Q�Ɓ^�ݒ�ɗp����BPaperSize Property �Ƃ�
    //                         �قȂ�A���T�C�Y�� PaperSizeNames �z���
    //                         �C���f�b�N�X�Ŏw�肷��
    property PaperSizeIndex: Integer read GetPaperSizeIndex
                                     write SetPaperSizeIndex;

    // NumPaperSizes Property: ���T�C�Y�̐�
    property NumPaperSizes: Integer read GetNumPaperSizes;

    // PaperSizeNumbers Property: ���T�C�Y�ԍ��̔z��B�ǂݍ��ݐ�p
    property PaperSizeNumbers[Index: Integer]: Integer read GetpaperSizeNumbers;

    // �����֘A�� Property
    // PageExtent:    ����\�̈�̑傫���iPixel)
    // MMPageExtent:  ����\�̈�̑傫���i0.1mm �P��)
    // DPI:           �𑜓x(Dot Per Inch)
    // PaperExtent:   ���̑傫��(Pixel)
    // MMPaperExtent: ���̑傫��(0.1mm �P��)
    // Offset:     ���̍���[�������\�̈�̍���[�܂ł̋���(Pixel)
    property PageExtent: TSize read GetPageExtent;
    property MMPageExtent: TSize read GetMMPageExtent;
    property DPI: TSize read GetDPI;
    property PaperExtent: TSize read GetPaperExtent;
    property MMPaperExtent: TSize read GetMMPaperExtent;
    property UserPaperExtent: TSize read getUserPaperExtent
                                    write SetUserPaperExtent;
    property Offset: TSize read GetOffset;




    ////////////
    // �r���֌W�� Porperty
    //

    // BinNumber Property: �r���ԍ��̎擾�^�ݒ�
    property BinNumber: Integer read GetBinNumber write SetBinNumber;

    // BinNames Property:�r�����̔z��B�ǂݍ��ݐ�p
    property BinNames: TStrings read GetBinNames;

    // BinIndex Property:      �r���̃C���f�b�N�X�B�r����
    //                         �Q�Ɓ^�ݒ�ɗp����B�r���� BinNames �z���
    //                         �C���f�b�N�X�Ŏw�肷��
    property BinIndex: Integer read GetBinIndex
                               write SetBinIndex;

    // NumBins Property: �r���̐�
    property NumBins: Integer read GetNumBins;

    // BinNumbers Property: �r���ԍ��̔z��B�ǂݍ��ݐ�p
    property BinNumbers[Index: Integer]: Integer read GetBinNumbers;



    ////////////
    // ����i���֌W�� Porperty
    //

    // Quality Property ����i��
    property Quality: TSize read  GetQuality
                            write SetQuality;

    // NumQualites Property ����i���i�𑜓x�j�̐�
    property NumQualities: Integer read GetNumQualities;

    // Qualities �z�� Property ����i���i�𑜓x�j�̔z��
    property Qualities[Index: Integer]: TSize read GetQualities;




    ////////////
    // �v�����^�֌W�� Porperty
    //

    // Index Property:        ���ݑI�����Ă���v�����^�̃C���f�b�N�X�B
    //                        �C���f�b�N�X�l�� PrinterNames �z��̃C���f�b�N�X
    //                        �Ɠ����B-1 ��������ƃf�t�H���g�v�����^��I��
    //                        �ł���BPrinterNames �z��́u�B���ꂽ�v�v�����^
    //                        ���܂܂Ȃ����߁APrinter.PrinterIndex �Ƃ͒l��
    //                        �قȂ�̂Œ��ӁI
    property Index: Integer read GetIndex
                            write SetIndex;

    // PrintCaps Property:     ���ݑI������Ă���v�����^�̋@�\
    property PrintCaps: TNkPrintCaps read GetPrintCaps;

    // PrinterNames Property:  �C���X�g�[������Ă��邷�ׂẴv�����^����
    //                          �z��B�u�B���ꂽ�v�v�����^�͊܂܂Ȃ��B
    //                          �ǂݏo����p
    property PrinterNames: TStrings read GetPrinterNames;

    // PortNames Property:  �|�[�g�ꗗ
    property PortNames: TStrings read GetPortNames;

    // Port Property  �|�[�g��
    property Port: string read GetPort write SetPort;






    ////////////
    // ���̑��� Porperty
    //

    // Orientation Property:   ���̕������Q�Ɓ^�w�肷��B
    property Orientation: TNkPaperOrientation read GetOrientation
                                              write SetOrientation;

    // MaxCopies Property �ő啔��
    property MaxCopies: WORD read GetMaxCopies;

    // Copies Property ����
    property Copies: WORD read GetCopies write SetCopies;

    // Collate Property ������
    property Collate: Boolean read GetCollate write SetCollate;

    // Color Property �J���[�^�����̎w��
    property Color: Boolean read GetColor write SetColor;

    // Duplex Property ���ʈ��
    property Duplex: TNkDuplex read GetDuplex write SetDuplex;

    // Scale Property ����{��
    property Scale: WORD read GetScale write SetScale;

    // ColorBitCount Property �F�r�b�g��
    property ColorBitCount: Integer read GetColorBitCount;

    // �v�����^�֘A���̗L���t���O
    property AvailInfos: TNkAvailInfos read GetAvailInfos;


    //////////////////////
    // ���J�C�x���g
    //


    // �V�X�e���ύX�C�x���g�B�v�����^�̒ǉ��폜���ɋN����B
    property OnSystemChanged: TNotifyEvent read  FOnSystemChanged
                                           write FOnSystemChanged;
  end;

  // NkPrinter �p����_�C�A���O
  TNkPrintDialog = class(TPrintDialog)
  public
    function Execute: Boolean; override;
  end;

  // NkPrinter �p����ݒ�_�C�A���O
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


// �S�v�����^���̍쐬
constructor TNkAllPrintersInfo.Create;
var Flags: Integer;
    InfoBytes: DWORD;
begin
  nPrinters := 0;

  if Win32Platform = VER_PLATFORM_WIN32_NT
  then Flags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL
  else Flags := PRINTER_ENUM_LOCAL;

  InfoBytes := 0;
  // �o�b�t�@���𓾂�
  EnumPrinters(Flags, nil, 2, nil, 0, InfoBytes, nPrinters);
  if InfoBytes = 0 then Exit;
  GetMem(pPrintersInfo, InfoBytes);

  // �v�����^���(Level = 2)���擾
  Win32Check(EnumPrinters(Flags, nil, 2, pPrintersInfo,
                        InfoBytes, InfoBytes, nPrinters));
end;

// �S�v�����^���̔j��
destructor TNkAllPrintersInfo.Destroy;
begin
  if pPrintersInfo <> Nil then FreeMem(pPrintersInfo);
end;

// �S�v�����^��񂩂�v�����^�������o���B
function TNkAllPrintersInfo.GetName(Index: Integer): string;
begin
  Result := PPrinterInfo2Array(pPrintersInfo)^[Index].pPrinterName;
end;

// �S�v�����^��񂩂�v�����^�̑��������o���B
function TNkAllPrintersInfo.GetAttributes(Index: Integer): DWORD;
begin
  Result := PPrinterInfo2Array(pPrintersInfo)^[Index].Attributes;
end;

// �S�v�����^���̔�r�B
function TNkAllPrintersInfo.Compare(Another: TNkAllPrintersInfo): Boolean;
var i: Integer;
    pInfo1, pInfo2: PPrinterInfo2;
begin
  Result := False;

  // �����������ʖځI
  if nPrinters <> Another.nPrinters then Exit;

  // ��񖳂��Ȃ��v
  if nPrinters = 0 then begin Result := True; Exit; end;

  pInfo1 := pPrintersInfo; pInfo2 := Another.pPrintersInfo;

  // �v�����^���A�|�[�g���A�h���C�o���A�����݂̂��r (^^
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
// �R���X�g���N�^�ł� Printer �ɃA�N�Z�X���Ȃ����Ƃɒ��ӁI�I
// �R���X�g���N�^�� Printer �ɃA�N�Z�X����ƃv�����^�[�������ꍇ
// �A�v���P�[�V�����������オ��Ȃ��Ȃ�B

constructor TNkPrinter.Create;
begin
  FIndex := -1;                   // Update �̌Ăяo���ɔ����� -1 �ɃZ�b�g
  // �S�v�����^����������
  AllInfo := TNkAllPrintersInfo.Create;
  pPaperNumbers := Nil;           // ���T�C�Y���p�o�b�t�@�|�C���^���N���A
  pBinNumbers := Nil;             // �r�����p�o�b�t�@�|�C���^���N���A
  pResolutions := Nil;            // �𑜓x���p�o�b�t�@�|�C���^���N���A

  FModified := False;             // �v�����^�ݒ�ύX�t���O���I�t�B
  pSettings := Nil;                // �v�����^�ݒ�ێ��p�|�C���^���N���A

  // ���T�C�Y���z��A�v�����^���z����N���A
  FPaperNames := TStringList.Create;
  FBinNames := TStringList.Create;
  FPrinterNames := TStringList.Create;
  FPortNames := TStringList.Create;

  // �A�v���P�[�V�����E�B���h�E�ɗ��� WM_WININICHANGE ��M�p�t�b�N��ݒu
  Application.HookMainWindow(AppHook);
end;

destructor TNkPrinter.Destroy;
begin
  // �A�v���P�[�V�����E�B���h�E�ɗ��� WM_WININICHANGE ��M�p�t�b�N���͂���
  Application.UnHookMainWindow(AppHook);
  // �e�탊�\�[�X�����
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


// �v�����^�̒ǉ��폜���u��������������Ȃ��v���̏���
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
    // TPrinter �̓v�����^�̒ǉ��폜�ɑΉ����Ă��Ȃ��̂�
    // �����̃v�����^���X�g��j�����邽�߂ɂ�
    // TPrinter ���̂��̂�j������̂��ł��ȒP�B
    // TPrinter ���� FreePrinters ��Private �Ȃ̂�
    // �Ăяo���Ȃ��B
    //

    NewInfo := TNkAllPrintersInfo.Create;
    if not AllInfo.Compare(NewInfo) then begin
      // �S�v�����^���ɕω����L��Ȃ� TPrinter ��j���I�I
      OldPrinter := Printers.SetPrinter(Nil);
      OldPrinter.Free;
      AllInfo.Free;
      // �S�v�����^�����X�V
      AllInfo := NewInfo;
      FIndex := -1; // �C���f�b�N�X�𖳌���

      // �v�����^�ݒ����j��
      DiscardModification;
      
      if Assigned(FOnSystemChanged) then FOnSystemChanged(Self);
      Exit;
    end
      else NewInfo.Free;  // �X�V�s�v

    ////////////
    //
    // Port �̒ǉ��폜���L������ SystemChanged Event ���N����
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

// TNkPrinter �� Canvas ���擾�BPrinter.Canvas ���g��
function TNkPrinter.GetCanvas: TCanvas;
begin Result := Printer.Canvas; end;

// �v�����^�� IC or DC �̎擾
function TNkPrinter.GetHandle: HDC;
begin Result := Printer.Handle; end;

// ������t���O
function TNkPrinter.GetPrinting: Boolean;
begin result := Printer.Printing; end;

// ����J�n
procedure TNkPrinter.BeginDoc(Title: string);
begin
  Printer.Title := Title;
  Printer.BeginDoc;
end;

// ������~
procedure TNkPrinter.Abort;
begin
  Printer.Abort;
end;

// �V�����y�[�W
procedure TNkPrinter.NewPage;
begin
  Printer.NewPage;
end;

// ����I��
procedure TNkPrinter.EndDoc;
begin
  Printer.EndDoc;
end;


// �v�����^�[���L�邩�`�F�b�N
// �u�B���ꂽ�v�v�����^�����Ȃ��ꍇ����O��������
procedure TNkPrinter.CheckNoPrinter;
var i: Integer;
begin
  if AllInfo.Count > 0 then
    for i := 0 to AllInfo.Count-1 do
      if (AllInfo.Attributes[i] and PRINTER_ATTRIBUTE_HIDDEN) = 0 then
        Exit;

  FIndex := -1; // �v�����^�̔�I����Ԃɖ߂�
  raise ENkPrinterNoPrinter.Create(
    'TNkPrinter.CheckNoPrinter: No Printer');
end;

// �v�����^���w�肳�ꂽ�@�\���T�|�[�g���Ă��邩�`�F�b�N
procedure TNkPrinter.CheckSupport(Value: TNkPrintCap; str: string);
begin
  if not (Value in PrintCaps) then
    raise ENkPrinterNotSupported.Create(str);
END;


// Printer.GetPrinter �Ńv�����^�[�̏����擾
// DevMode �\���̂� GlobalLock �ŃA�N�Z�X�\�ɂ��܂��B
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

// Printer.SetPrinter �Ńv�����^�[�̏����X�V
// �ꉞ DocumentProperties  ���Ԃɓ���āA�v�����^�h���C�o��
// ���f���𗧂ĂĂ���ύX����
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

// DevMode �\���̂� GlobalUnlock ���邾��
// Devnode �\���̂�ύX���Ȃ��ꍇ�ɗ��p����B
procedure TNkPrinter.ReleaseInfo(PrnInfo: TNkPrinterInfo);
begin
  GlobalUnlock(PrnInfo.hDevMode);
end;

// ���݂̃v�����^�ݒ���擾�� pSettings �ɃZ�b�g����
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


// ���T�C�Y�̏����X�V����B
// CheckNoPrinter, CheckSupport �͌Ăԑ��ōs������
procedure TNkPrinter.GetPaperSizes;
var PrnInfo: TNkPrinterInfo;
    pPaperNames: PNameArray;
    nPaperSizes: Integer;
    i: Integer;
begin
  // �Â������̂Ă�
  if pPaperNumbers <> Nil then begin
    FreeMem(pPaperNumbers);
    pPaperNumbers := Nil;
  end;
  FPaperNames.Clear;     // ���T�C�Y����j��

  PrnInfo := GetInfo;
  try
    with PrnInfo do begin
      // ���T�C�Y���𓾂ăo�b�t�@���m��
      nPaperSizes := DeviceCapabilities(Device, Port, DC_PAPERS,
                                        Nil, pDevMode);

      // ���T�C�Y��񂪂Ȃ��Ȃ�A��񖳂��ɂ���B
      if (nPaperSizes = -1) or (nPaperSizes = 0) then Exit;

      // AvailInfos Property �Ɏ��T�C�Y��񂪗L�邱�Ƃ��Z�b�g
      FAvailInfos := FAvailInfos + [nkAvPaperSize];

      GetMem(pPaperNumbers, SizeOf(WORD) * nPaperSizes);
      Getmem(pPaperNames, 64 * nPaperSizes);
      try
        // ���T�C�Y�̔ԍ��z��Ǝ����z��𓾂�B
        DeviceCapabilities(Device, Port, DC_PAPERS,
                             PCHAR(pPaperNumbers), pDevmode);
        DeviceCapabilities(Device, Port, DC_PAPERNAMES,
                             PCHAR(pPaperNames), pDevmode);
        if nPaperSizes > 0 then
          for i := 0 to nPaperSizes-1 do
            FPaperNames.Add(pPaperNames^[i]);
      finally
        FreeMem(pPaperNames); // �����z����̂Ă�B
      end;
    end;
  finally
    ReleaseInfo(PrnInfo);
  end;
end;

// �r�������X�V����B
// CheckNoPrinter, CheckSupport �͌Ăԑ��ōs������
procedure TNkPrinter.GetBins;
var PrnInfo: TNkPrinterInfo;
    pBinNames: PBinNameArray;
    nBins: Integer;
    i: Integer;
begin
  // �Â������̂Ă�
  if pBinNumbers <> Nil then begin
    FreeMem(pBinNumbers);
    pBinNumbers := Nil;
  end;
  FBinNames.Clear;

  PrnInfo := GetInfo;
  try
    with PrnInfo do begin
      // �r�����𓾂ăo�b�t�@���m��
      nBins := DeviceCapabilities(Device, Port, DC_BINS,
                                          Nil, pDevMode);

      // �r����񂪖����Ȃ�A��񖳂��Ƃ���B
      if (nBins = -1) or (nBins = 0) then Exit;

      // AvailInfos Property �Ƀr����񂪗L�邱�Ƃ��Z�b�g
      FAvailInfos := FAvailInfos + [nkAvBin];

      GetMem(pBinNumbers, SizeOf(WORD) * nBins);
      Getmem(pBinNames, 64 * nBins);
      try
        // �r���̔ԍ��z��Ǝ����z��𓾂�B
        DeviceCapabilities(Device, Port, DC_BINS,
                             PCHAR(pBinNumbers), pDevmode);
        DeviceCapabilities(Device, Port, DC_BINNAMES,
                             PCHAR(pBinNames), pDevmode);
        if nBins > 0 then
          for i := 0 to nBins-1 do
            FBinNames.Add(pBinNames^[i]);

      finally
        FreeMem(pBinNames); // �r�����z����̂Ă�B
      end;
    end;
  finally
    ReleaseInfo(PrnInfo);
  end;
end;

// �𑜓x�����X�V����B
// CheckNoPrinter, CheckSupport �͌Ăԑ��ōs������
procedure TNkPrinter.GetResolutions;
var PrnInfo: TNkPrinterInfo;
begin
  // �Â������̂Ă�
  if pResolutions <> Nil then begin
    FreeMem(pResolutions);
    pResolutions := Nil;
  end;

  PrnInfo := GetInfo;
  try
    with PrnInfo do begin
      // �𑜓x���𓾂ăo�b�t�@���m��
      FNumResolutions := DeviceCapabilities(Device, Port, DC_ENUMRESOLUTIONS,
                                            Nil, pDevMode);

      // ����i����񖳂��Ȃ�A�����Ƃ���B

      if FNumResolutions <= 0 then begin
        FNumResolutions := 0; Exit;
      end;

      // AvailInfos Property �Ɉ���i����񂪗L�邱�Ƃ��Z�b�g
      FAvailInfos := FAvailInfos + [nkAvQuality];

      GetMem(pResolutions, SizeOf(TSize) * FNumResolutions);

      // �𑜓x�z��𓾂�B
      Assert(DeviceCapabilities(Device, Port, DC_ENUMRESOLUTIONS,
                                PCHAR(pResolutions), pDevMode) <> -1);
    end;
  finally
    ReleaseInfo(PrnInfo);
  end;
end;

// �ő啔�����X�V����B
// CheckNoPrinter, CheckSupport �͌Ăԑ��ōs������
procedure TNkPrinter.GetMaxCopiesInfo;
var PrnInfo: TNkPrinterInfo;
    ret: Integer;
begin
  PrnInfo := GetInfo;
  try
    Ret := DeviceCapabilities(PrnInfo.Device, PrnInfo.Port, DC_COPIES,
                       Nil, PrnInfo.pDevMode);
    if ret <= 0 then Exit;

    // AvailInfos Property �ɍő啔����񂪗L�邱�Ƃ��Z�b�g
    FAvailInfos := FAvailInfos + [nkAvMaxCopies];
    FMaxCopies := ret;
  finally
    ReleaseInfo(PrnInfo);
  end;
end;



// �e����̍X�V
procedure TNkPrinter.Update;
var Caps: TNkPrintCaps;
begin
  // Printer.PrinterIndex ���ς���ĂȂ��Ȃ牽�����Ȃ��B
  if FIndex = Printer.PrinterIndex then Exit;

  FIndex := Printer.PrinterIndex;

  Caps := PrintCaps;

  FAvailInfos := [];  // AvailInfos �v���p�e�B���N���A�B�ݒ��
                      // GetPaperSizes, GetBins, GetResolutions,
                      // GetMaxCopiesInfo ���s���B

  // ���T�C�Y���̎擾
  //if nkPcPaperSize in Caps then
    GetPaperSizes;

  // �r�������擾
  //if nkPcDefaultSource in Caps then
    GetBins;

  // ����i�������擾
  //if nkPcPrintQuality in caps then
    GetResolutions;

  // �ő啔�����擾
  //if nkPcCopies in caps then
    GetMaxCopiesInfo;
end;

// �����I�Ɋe��v�����^�����X�V
procedure TNkPrinter.ForceUpdate;
begin
  DiscardModification;
  FIndex := -1;
  Update;
end;


// Index Property �̎擾
// Printer.PrinterIndex �� Index �ɕϊ�����B
function TNkPrinter.GetIndex: Integer;
var i, PIndex: Integer;
    PrnInfo: TNkPrinterInfo;
    PrinterFound: Boolean;
begin
  CheckNoPrinter;
  Result := Printer.PrinterIndex;

  if Result = -1 then Exit;

  // ���ݑI������Ă���v�����^�[���u�B���ꂽ�v�v�����^�[�Ȃ�ϊ��s�\

  //////////////////////
  //
  // Note:
  //
  // TPrinter �̓|�[�g���ύX�����ƐV���ȃG���g���� TPrinter ���ɍ��̂�
  // PrinterIndex �� �v�����^�[���ȏ�ɂȂ邱�Ƃ�����B
  // �ȉ��̃R�[�h�͂��̓_���l�����Ă���B

  // PrinterIndex ���B���ꂽ�v�����^�Ȃ�G���[
  if Result < AllInfo.Count then
    if (AllInfo.Attributes[Result] and PRINTER_ATTRIBUTE_HIDDEN) <> 0 then
      raise ENkPrinterIllegalIndex.Create(
        'TNkPrinter.GetIndex: Printers.PrinterIndex is Illegal');

  // �u�B���ꂽ�v�v�����^�[���������C���f�b�N�X�ɕϊ�


  // PrinterIndex �𒼐ڌ���̂ł͂Ȃ��A�v�����^�[���ŃC���f�b�N�X���߂�B
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

  // �u�B���ꂽ�v�v�����^�̐������l�����炷�B
  if PIndex > 0 then
    for i := 0 to PIndex-1 do
      if (AllInfo.Attributes[i] and PRINTER_ATTRIBUTE_HIDDEN) <> 0 then
        Dec(Result);
end;

// Index Property �̐ݒ�
// Printer.PrinterIndex �� Index ��ϊ����Đݒ�
procedure TNkPrinter.SetIndex(Value: Integer);
var Device, Driver, Port: array[0..511] of Char;
    hDevMode: THandle;
    i, IndexForPrinter, IndexForNkPrinter: Integer;
begin
  CheckNoPrinter;

  // Value < -1 �͗L�蓾�Ȃ�
  if Value < -1 then
    raise ENkPrinterRangeError.Create(
      'TNkPrinter.SetIndex: Index is out of Range');

  if Value = Index then Exit;  // �C���f�b�N�X�l�������Ȃ牽�����Ȃ��B

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
  else // Value = -1 -> �f�t�H���g�v�����^�[�ɐݒ�
    IndexForPrinter := -1;

  with Printer do begin
    PrinterIndex := IndexForPrinter;
    // PrinterIndex �̃o�O�΍�
    GetPrinter(Driver, Device, Port, hDevMode);
    SetPrinter(Driver, Device, Port, 0);
    // �ŐV�����擾
    FIndex := -1;
    Update;
  end;

  // �v�����^�ݒ���̔j��
  DiscardModification;
end;


// ���ݐݒ肳��Ă��鎆�T�C�Y�ԍ����擾
function TNkPrinter.GetPaperSizeNumber: Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcPaperSize,
               'TNkPrinter.GetPaperSizeNumber: PaperSize is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  Result := pSettings^.dmPaperSize;
end;


// ���T�C�Y�ԍ���ݒ�
procedure TNkPrinter.SetPaperSizeNumber(Value:Integer);
begin
  CheckNoPrinter;
  CheckSupport(nkPcPaperSize,
               'TNkPrinter.SetPaperSizeNumber: PaperSize is not Supported');
  Update;

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if pSettings^.dmPaperSize <> Value then begin
    pSettings^.dmPaperSize := Value;
    FModified := True;
  end;
end;

// ���ԍ����v�����^�ɃT�|�[�g����Ă��邩�ǂ����`�F�b�N
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

// ���T�C�Y�̐��̎擾
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

//���T�C�Y�C���f�b�N�X���玆�T�C�Y�ԍ����擾
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

// ���T�C�Y���z����擾
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

// ���ݑI������Ă��鎆�T�C�Y�̃C���f�b�N�X���擾
function TNkPrinter.GetPaperSizeIndex: Integer;
var i: Integer;
    PaperNumber: Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcpaperSize,
    'TNkPrinter.GetPaperSizeIndex: PaperSize is not Supported');

  PaperNumber := GetPaperSizeNumber; // ���T�C�Y�ԍ����擾
  Update;

  if not (nkAvPaperSize in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetPaperSizeIndex: No Papersize Info Available');


  // ���T�C�Y�ԍ��z�񂩂玆�T�C�Y�C���f�b�N�X���݂���
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

// ���T�C�Y�C���f�b�N�X��ݒ�
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


// ���ݐݒ肳��Ă���r���ԍ����擾
function TNkPrinter.GetBinNumber: Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcDefaultSource,
               'TNkPrinter.GetBinNumber: Bin is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;
  Result := pSettings^.dmDefaultSource;
end;


// �r���ԍ���ݒ�
procedure TNkPrinter.SetBinNumber(Value: Integer);
begin
  CheckNoPrinter;
  CheckSupport(nkPcDefaultSource,
               'TNkPrinter.SetBinNumber: Bin is not Supported');
  Update;

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if pSettings^.dmDefaultSource <> Value then begin
    pSettings^.dmDefaultSource := Value;
    FModified := True;
  end;
end;

// �r���ԍ����T�|�[�g����Ă��邩�`�F�b�N
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



// �r���̐��̎擾
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

// �r�����z����擾
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

// ���ݑI������Ă���r���̃C���f�b�N�X���擾
function TNkPrinter.GetBinIndex: Integer;
var i: Integer;
    BinNumber: Integer;
begin
  CheckNoPrinter;
  CheckSupport(nkPcDefaultSource,
    'TNkPrinter.GetBinIndex: Bin is not Supported');

  BinNumber := GetBinNumber; // �r���ԍ����擾
  Update;

  if not (nkAvBin in FAvailInfos) then
    raise ENkPrinterNoInfo.Create(
      'TNkPrinter.GetBinIndex: No Bin Info Available');


  Result := -1;
  // �r���ԍ��z�񂩂�r���̃C���f�b�N�X���݂���
  if FBinNames.Count > 0 then
    for i := 0 to FBinNames.Count-1 do
      if PWordArray(pBinNumbers)^[i] = BinNumber then
        Result := i;

  if Result = -1 then
    raise ENkPrinterBinError.Create(
      'TNkPrinter.GetBinIndex: Cannot Get Bin Index');
end;

// �r���C���f�b�N�X��ݒ�
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

//�r���C���f�b�N�X����r���ԍ����擾
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



// �v�����^�[�̃T�|�[�g�@�\�̎擾
function TNkPrinter.GetPrintCaps;
var Cap: TNkPrintcap;
begin
  CheckNoPrinter;

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  Result := [];
  for Cap := Low(TNkPrintCap) to High(TNkPrintCap) do
    if (pSettings^.dmFields and PrintCapValues[ord(Cap)]) <> 0 then
      Include(Result, Cap);
end;

// ���̕����̎擾
function TNkPrinter.GetOrientation: TNkPaperOrientation;
begin
  CheckNoPrinter;
  CheckSupport(nkPcOrientation,
    'TNkPrinter.GetOrientation: Orientation is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if pSettings^.dmOrientation = DMORIENT_PORTRAIT then Result := nkOrPortrait
                                                  else result := nkOrLandScape;
end;

// ���̕����̐ݒ�
procedure TNkPrinter.SetOrientation(Value: TNkPaperOrientation);
begin
  CheckNoPrinter;
  CheckSupport(nkPcOrientation,
    'TNkPrinter.SetOrientation: Orientation is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if pSettings^.dmOrientation <> OrientationValues[Ord(Value)] then begin
    pSettings^.dmOrientation := OrientationValues[Ord(Value)];
    FModified := True;
  end;
end;

// �v�����^�[���z��̎擾
function TNkPrinter.GetPrinterNames: TStrings;
var i: Integer;
begin
  CheckNoPrinter;
  FPrinterNames.Clear; Result := FPrinterNames;

  // �u�B���ꂽ�v�v�����^�[�������v�����^�[�������o��
  if AllInfo.Count > 0 then
    for i := 0 to AllInfo.Count-1 do
      if (AllInfo.Attributes[i] and PRINTER_ATTRIBUTE_HIDDEN) = 0 then
        FPrinterNames.Add(AllInfo.Name[i]);
end;

// ����\�̈�̎擾
function TNkPrinter.GetPageExtent: TSize;
begin
  CheckNoPrinter;
  Result.cx := GetDeviceCaps(Printer.Handle, HORZRES);
  Result.cy := GetDeviceCaps(Printer.Handle, VERTRES);
end;

// ����\�̈�̎擾(mm �P��)
function TNkPrinter.GetMMPageExtent: TSize;
begin
  CheckNoPrinter;
  Result.cx := GetDeviceCaps(Printer.Handle, HORZSIZE) * 10;
  Result.cy := GetDeviceCaps(Printer.Handle, VERTSIZE) * 10;
end;

// DPI�̎擾
function TNkPrinter.GetDPI: TSize;
begin
  CheckNoPrinter;
  Result.cx := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
  Result.cy := GetDeviceCaps(Printer.Handle, LOGPIXELSY);
end;

// ���T�C�Y�̎擾
function TNkPrinter.GetPaperExtent: TSize;
begin
  CheckNoPrinter;
  Result.cx := GetDeviceCaps(Printer.Handle, PHYSICALWIDTH);
  Result.cy := GetDeviceCaps(Printer.Handle, PHYSICALHEIGHT);
end;



// ���T�C�Y�̎擾(0.1mm �P��)
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
  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B

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

  // ���[�U��`�T�C�Y���T�|�[�g���Ă��邩�`�F�b�N
  CheckSupport(nkPcPaperSize,
               'TNkPrinter.SetpaperExtent: PaperSize is not Supported');

  ////////////
  //
  //  Note: nkPcPaperLength, nkPcPaperWidth ���`�F�b�N����̂�
  //        �~�߂ɂ����B���ԍ��� DMPAPER_USER �̎����߂�
  //        ON �ɂȂ�v�����^���L�邩��B���ꐫ�������I


  Update;

  // ���[�U��`�T�C�Y���Z�b�g

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  FModified := True;
  with pSettings^ do begin
    dmPaperSize := DMPAPER_USER;
    dmPaperWidth := Value.cx;
    dmpaperLength := Value.cy;
    dmFields := dmFields or DM_PAPERLENGTH or DM_PAPERWIDTH;
  end;
end;


// ���̍���[�������\�̈�̍���[�܂ł̋���(Pixel)
function TNkPrinter.GetOffset: TSize;
begin
  CheckNoPrinter;
  Result.cx := GetDeviceCaps(Printer.Handle, PHYSICALOFFSETX);
  Result.cy := GetDeviceCaps(Printer.Handle, PHYSICALOFFSETY);
end;


// �ő啔��
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

// �����̎擾
function TNkPrinter.GetCopies: WORD;
begin
  CheckNoPrinter;
  CheckSupport(nkPcCopies, 'TNkPrinter.GetCopies: Copies not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  Result := pSettings^.dmCopies;
end;

// �����̃Z�b�g
procedure TNkPrinter.SetCopies(Value: WORD);
begin
  CheckNoPrinter;
  CheckSupport(nkPcCopies, 'TNkPrinter.SetCopies: Copies not Supported');
  if (Value < 1) then
    raise ENkPrinterRangeError.Create(
      'TNkPrinter.SetCopies: Too Small Copies');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if pSettings^.dmCopies <> Value then begin
    pSettings^.dmCopies := Value;
    FModified := True;
  end;
end;

// �������̎擾
function TNkPrinter.GetCollate: Boolean;
begin
  CheckNoPrinter;
  CheckSupport(nkPcCollate,
    'TNkPrinter.GetCollate: Collate is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if pSettings^.dmCollate = DMCOLLATE_TRUE then Result := True
                                           else result := False;
end;

// �������̐ݒ�
procedure TNkPrinter.SetCollate(Value: Boolean);
begin
  CheckNoPrinter;
  CheckSupport(nkPcCollate,
    'TNkPrinter.SetCollate: Collate is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if (Value = True) and (pSettings^.dmCollate = DMCOLLATE_FALSE) or
     (Value = False) and (pSettings^.dmCollate = DMCOLLATE_TRUE) then begin
    if Value then pSettings^.dmCollate := DMCOLLATE_TRUE
             else pSettings^.dmCollate := DMCOLLATE_FALSE;
    FModified := True;
  end;
end;

// �J���[�̎擾
function TNkPrinter.GetColor: Boolean;
begin
  CheckNoPrinter;
  CheckSupport(nkPcColor,
    'TNkPrinter.GetColor: Color is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if pSettings^.dmColor = DMCOLOR_COLOR then Result := True
                                        else result := False;
end;

// �J���[�̐ݒ�
procedure TNkPrinter.SetColor(Value: Boolean);
begin
  CheckNoPrinter;
  CheckSupport(nkPcColor,
    'TNkPrinter.SetColor: Color is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if (Value = True) and (pSettings^.dmColor = DMCOLOR_MONOCHROME) or
     (Value = False) and (pSettings^.dmColor = DMCOLOR_Color) then begin
    if Value then pSettings^.dmColor := DMCOLOR_COLOR
             else pSettings^.dmColor := DMCOLOR_MONOCHROME;
    FModified := True;
  end;
end;

// ���ʂ̎擾
function TNkPrinter.GetDuplex: TNkDuplex;
begin
  CheckNoPrinter;
  CheckSupport(nkPcDuplex,
    'TNkPrinter.GetDuplex: Duplex is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if pSettings^.dmDuplex = DMDUP_SIMPLEX then
    Result := nkDupSimplex
  else if pSettings^.dmDuplex = DMDUP_HORIZONTAL then
    Result := nkDupHorizontal
  else Result := nkDupVertical;
end;

// ���ʂ̐ݒ�
procedure TNkPrinter.SetDuplex(Value: TNkDuplex);
begin
  CheckNoPrinter;
  CheckSupport(nkPcDuplex,
    'TNkPrinter.SetDuplex: Duplex is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if pSettings^.dmDuplex <> DuplexValues[Ord(Value)] then begin
    pSettings^.dmDuplex := DuplexValues[Ord(Value)];
    FModified := True;
  end;
end;

// �{���̎擾
function TNkPrinter.GetScale: WORD;
begin
  CheckNoPrinter;
  if nkPcScale in PrintCaps then begin
    // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
    if pSettings = Nil then GetSettings;

    Result := pSettings^.dmScale;
  end
  else Result := 100;
end;

// �{���̐ݒ�
procedure TNkPrinter.SetScale(Value: WORD);
begin
  CheckNoPrinter;
  CheckSupport(nkPcScale,
    'TNkPrinter.SetScale: Scale is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;

  if pSettings^.dmScale <> Value then begin
    pSettings^.dmScale := Value;
    FModified := True;
  end;
end;

// �J���[�r�b�g���̎擾
function TNkPrinter.GetColorBitCount: Integer;
begin
  CheckNoPrinter;
  Result := GetDeviceCaps(Printer.Handle, BITSPIXEL) *
            GetDeviceCaps(Printer.Handle, PLANES);
end;

// �|�[�g���z��̎擾
function TNkPrinter.GetPortNames: TStrings;
var InfoBytes, nPorts: DWORD;
    pPortsInfo: PPortInfo1Array;
    i: Integer;
begin
  // CheckNoPrinter;

  FPortNames.Clear;
  Result := FPortNames;
  InfoBytes := 0;
  // �o�b�t�@���𓾂�
  EnumPorts(Nil, 1, nil, 0, InfoBytes, nPorts);
  if InfoBytes = 0 then Exit;
  GetMem(pPortsInfo, InfoBytes);
  try

    // �|�[�g���(Level = 1)���擾
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

// �|�[�g���̎擾
function TNkPrinter.GetPort: string;
begin
  CheckNoPrinter;
  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;
  Result := PortName;
end;

// �|�[�g���̃Z�b�g
procedure TNkPrinter.SetPort(Value: string);
begin
  CheckNoPrinter;
  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;
  if PortName <> Value then begin
    PortName := Value;
    FModified := True;
  end;
end;

// ����i���̎擾
function TNkPrinter.GetQuality: TSize;
begin
  CheckNoPrinter;
  CheckSupport(nkPcPrintQuality,
    'TNkPrinter.GetQuality: PrintQuality is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
  if pSettings = Nil then GetSettings;
  Result.cx := pSettings^.dmPrintQuality;

  if (Result.cx > 0) and
     ((pSettings^.dmFields and DM_YRESOLUTION) <> 0) then
    Result.cy := pSettings^.dmYResolution
  else
    Result.cy := 0;
end;

// ����i���̃Z�b�g
procedure TNkPrinter.SetQuality(Value: TSize);
begin
  CheckNoPrinter;
  CheckSupport(nkPcPrintQuality,
    'TNkPrinter.SetQuality: PrintQuality is not Supported');

  // �v�����^�ݒ薢�쐬�Ȃ� �쐬����B
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

// ����i���i�𑜓x�j�̐��̎擾
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

// ����i���z��̎擾
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
    // �v�����^�ݒ��  TPrinter �� DocumentProperties ����ăR�s�[����B
    Size := GlobalSize(PrnInfo.hDevMode);
    Assert(Size > 0,
           'TNkPrinter.ApplySettings; Devmode Size Should be greater than 0');
    System.Move(pSettings^, PrnInfo.pDevMode^, Size);
    StrCopy(PrnInfo.Port, PCHAR(PortName));
    // �R�s�[���Đݒ肪����Ȃ��Ȃ����̂ŁA���̕ύX�ɔ����Ď̂Ă�B
    DiscardModification;
    // �e�������蒼���悤�� FIndex �𖳌��ɂ���B
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

