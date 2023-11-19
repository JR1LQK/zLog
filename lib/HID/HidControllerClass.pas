{******************************************************************************}
{                                                                              }
{ Project JEDI                                                                 }
{                                                                              }
{ The contents of this file are subject to the Mozilla Public License Version  }
{ 1.0 (the "License"); you may not use this file except in compliance with the }
{ License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ The Original Code is HidControllerClass.pas.                                 }
{                                                                              }
{ The Initial Developer of the Original Code is Robert Marquardt.              }
{ (robert_marquardt@gmx.de)                                                    }
{                                                                              }
{ Portions created by Robert Marquardt are                                     }
{ Copyright (c) 1999, 2000 Robert Marquardt.                                   }
{                                                                              }
{ Last modified: September 1, 2000                                             }
{                                                                              }
{******************************************************************************}

unit HidControllerClass;

interface

uses
  Windows, Messages, Classes, Forms, SysUtils,
  DBT, SetupAPI, Hid;

const
  // strings from the registry for CheckOutByClass
  cHidKeyboardClass = 'Keyboard';
  cHidMouseClass    = 'Mouse';
  cHidNoClass       = 'HIDClass';

// Definitions to allow SetUpAPI dynamic loading
(*

type
  HDEVINFO = Pointer;

  PSPDevInfoData = ^TSPDevInfoData;
  _SP_DEVINFO_DATA = packed record
    cbSize: DWORD;
    ClassGuid: TGUID;
    DevInst: DWORD; // DEVINST handle
    Reserved: ULONG_PTR;
  end;
  TSPDevInfoData = _SP_DEVINFO_DATA;

  TSetupDiGetDeviceRegistryProperty = function (DeviceInfoSet: HDEVINFO;
  var DeviceInfoData: TSPDevInfoData; Property_: DWORD;
  PropertyRegDataType: PDWORD; PropertyBuffer: PBYTE; PropertyBufferSize: DWORD;
  RequiredSize: PDWORD): LongBool;


*)

type
  // forward declarations
  TJvHidDeviceController = class;
  TJvHidDevice           = class;

  // the Event function declarations
  TJvHidEnumerateEvent  = function (HidDev: TJvHidDevice; Idx: Integer): Boolean of object;
  TJvHidUnplugEvent     = procedure(HidDev: TJvHidDevice) of object;

  // the representation of a HID device

  TJvHidDevice = class(TObject)
  private
    // internal control variables
    FMyController:         TJvHidDeviceController;
    FIsPluggedIn:          Boolean;
    FIsCheckedOut:         Boolean;
    FIsEnumerated:         Boolean;
    FHidFileHandle:        THandle;
    FHidOverlappedHandle:  THandle;
    // internal properties part
    FDeviceID:             DWORD;
    FDevicePath:           string;
    FRegDescr:             string;
    FRegClass:             string;
    FVendorName:           AnsiString;
    FProductName:          AnsiString;
    FPhysicalDescriptor:   AnsiString;
    FSerialNumber:         AnsiString;
    FLanguageStrings:      TStringList;
    FPreparsedData:        PHIDPPreparsedData;
    FAttributes:           THIDDAttributes;
    FCaps:                 THIDPCaps;
    FConfiguration:        THIDDConfiguration;
    FNumInputBuffers:      Integer;
    FNumOverlappedBuffers: Integer;
    FLinkCollection:       array of THIDPLinkCollectionNode;
    FMaxDataListLength:    ULONG;
    FMaxUsageListLength:   ULONG;
    FMaxButtonListLength:  ULONG;
    FReportTypeParam:      THIDPReportType;
    FUsagePageParam:       TUsage;
    FLinkCollectionParam:  WORD;
    FUsageParam:           TUsage;
    FUnplug:               TJvHidUnplugEvent;

    // tells if access to device is allowed
    function  IsAccessible: Boolean;
    procedure GetMax;

    // internal property implementors
    function  GetDeviceString        (Idx: Byte): string;
    function  GetLinkCollectionNode  (Idx: WORD): THIDPLinkCollectionNode;
    procedure SetConfiguration       (Config: THIDDConfiguration);
    procedure SetNumInputBuffers     (const Num: Integer);
    procedure SetNumOverlappedBuffers(const Num: Integer);
    procedure SetReportTypeParam     (const ReportType: THIDPReportType);
    procedure SetUsagePageParam      (const UsagePage: TUsage);

    // Constructor is hidden! Only a TJvHidDeviceController can create a TJvHidDevice object.
    constructor Create(const DevicePath: string; const DevID: DWORD;
                       const DevDesc, ClassDesc: string;
                       Controller: TJvHidDeviceController);

  protected
    // internal property implementors
    procedure DoUnplug;
    procedure SetUnplug(const Event: TJvHidUnplugEvent);

  public
    // indexed properties
    property DeviceStrings      [Idx: Byte]: string                  read GetDeviceString;
    property LinkCollectionNodes[Idx: WORD]: THIDPLinkCollectionNode read GetLinkCollectionNode;

  published
    destructor Destroy; override;

    // methods
    procedure CloseFile;
    procedure CloseFileEx;
    function  DeviceIoControl      (IoControlCode: DWORD; InBuffer: Pointer; InSize: DWORD;
                                    OutBuffer: Pointer; OutSize: DWORD;
                                    var BytesReturned: DWORD):                      Boolean;
    function  FlushQueue:                                                           Boolean;
    function  GetButtonCaps        (ButtonCaps: PHIDPButtonCaps; var Count: WORD):  NTSTATUS;
    function  GetButtons           (UsageList: PUsage; var UsageLength: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  GetButtonsEx         (UsageList: PUsageAndPage; var UsageLength: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  GetData              (DataList: PHIDPData; var DataLength: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  GetFeature           (var Report; const Size: Integer):               Boolean;
    function  GetScaledUsageValue  (var UsageValue: Integer;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  GetSpecificButtonCaps(ButtonCaps: PHIDPButtonCaps; var Count: WORD):  NTSTATUS;
    function  GetSpecificValueCaps (ValueCaps:  PHIDPValueCaps;  var Count: WORD):  NTSTATUS;
    function  GetUsages            (UsageList: PUsage; var UsageLength: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  GetUsagesEx          (UsageList: PUsageAndPage; var UsageLength: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  GetUsageValue        (var UsageValue: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  GetUsageValueArray   (UsageValue: PChar; UsageValueByteLength: WORD;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  GetValueCaps         (ValueCaps:  PHIDPValueCaps;  var Count: WORD):  NTSTATUS;
    function  OpenFile:   Boolean;
    function  OpenFileEx: Boolean;
    function  SetButtons           (UsageList: PUsage; var UsageLength: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  SetData              (DataList: PHIDPData; var DataLength: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  SetFeature           (var Report; const Size: Integer):               Boolean;
    function  SetScaledUsageValue  (UsageValue: Integer;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  SetUsages            (UsageList: PUsage; var UsageLength: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  SetUsageValue        (UsageValue: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  SetUsageValueArray   (UsageValue: PChar; UsageValueByteLength: WORD;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  UnsetButtons         (UsageList: PUsage; var UsageLength: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  UnsetUsages          (UsageList: PUsage; var UsageLength: ULONG;
                                    var Report; ReportLength: ULONG):               NTSTATUS;
    function  ReadFile             (var Report; ToRead:  DWORD; var BytesRead:    DWORD): Boolean;
    function  ReadFileEx           (var Report; ToRead:  DWORD;
                                    CallBack: TPROverlappedCompletionRoutine):            Boolean;
    function  WriteFile            (var Report; ToWrite: DWORD; var BytesWritten: DWORD): Boolean;
    function  WriteFileEx          (var Report; ToWrite: DWORD;
                                    CallBack: TPROverlappedCompletionRoutine):            Boolean;

    // management properties
    property Attributes:            THIDDAttributes    read FAttributes;
    property Caps:                  THIDPCaps          read FCaps;
    property Configuration:         THIDDConfiguration read FConfiguration        write SetConfiguration;
    property DevicePath:            string             read FDevicePath;
    property DeviceID:              DWORD              read FDeviceID;
    property HidFileHandle:         THandle            read FHidFileHandle;
    property HidOverlappedHandle:   THandle            read FHidOverlappedHandle;
    property IsCheckedOut:          Boolean            read FIsCheckedOut;
    property IsPluggedIn:           Boolean            read FIsPluggedIn;
    property LanguageStrings:       TStringList        read FLanguageStrings;
    property LinkCollectionParam:   WORD               read FLinkCollectionParam  write FLinkCollectionParam;
    property MaxButtonListLength:   ULONG              read FMaxButtonListLength;
    property MaxDataListLength:     ULONG              read FMaxDataListLength;
    property MaxUsageListLength:    ULONG              read FMaxUsageListLength;
    property NumInputBuffers:       Integer            read FNumInputBuffers      write SetNumInputBuffers;
    property NumOverlappedBuffers:  Integer            read FNumOverlappedBuffers write SetNumOverlappedBuffers;
    property PhysicalDescriptor:    string             read FPhysicalDescriptor;
    property PreparsedData:         PHIDPPreparsedData read FPreparsedData;
    property ProductName:           string             read FProductName;
    property RegClass:              string             read FRegClass;
    property RegDescr:              string             read FRegDescr;
    property ReportTypeParam:       THIDPReportType    read FReportTypeParam      write SetReportTypeParam;
    property SerialNumber:          string             read FSerialNumber;
    property VendorName:            string             read FVendorName;
    property UsageParam:            TUsage             read FUsageParam           write FUsageParam;
    property UsagePageParam:        TUsage             read FUsagePageParam       write SetUsagePageParam;
    // the only event property
    property OnUnplug:              TJvHidUnplugEvent  read FUnplug               write SetUnplug;
  end;

  // controller class to manage all HID devices

  TJvHidDeviceController = class(TComponent)
  private
    // internal properties part
    FHidGuid:              TGUID;
    FDeviceChangeEvent:    TNotifyEvent;
    FDeviceChangeFired:    Boolean;
    FEnumerateEvent:       TJvHidEnumerateEvent;
    FDevUnplugEvent:       TJvHidUnplugEvent;
    // internal list of all HID device objects
    FList:                 TList;
    // counters for the list
    FNumCheckedInDevices:  Integer;
    FNumCheckedOutDevices: Integer;
    FNumUnpluggedDevices:  Integer;
    // internal worker functions
    function  CheckThisOut(var HidDev: TJvHidDevice; Idx: Integer; Check: Boolean): Boolean;
    procedure FillInList  (var List: TList);
    function  EventPipe   (var Msg: TMessage): Boolean;

  protected
    procedure Loaded; override;
    // internal property implementors
    procedure DoDeviceChange;
    function  DoEnumerate         (HidDev: TJvHidDevice; Idx: Integer): Boolean;
    procedure SetDeviceChangeEvent(const Notifier:   TNotifyEvent);
    procedure SetEnumerate        (const Enumerator: TJvHidEnumerateEvent);
    procedure SetDevUnplug        (const Unplugger:  TJvHidUnplugEvent);

  published
    // normal constructor/destructor
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy;                    override;

    // methods to hand out HID device objects
    procedure CheckIn              (var HidDev: TJvHidDevice);
    function  CheckOut             (var HidDev: TJvHidDevice):                       Boolean;
    function  CheckOutByClass      (var HidDev: TJvHidDevice; ClassName:   string):  Boolean;
    function  CheckOutByID         (var HidDev: TJvHidDevice; Vid, Pid:    Integer): Boolean;
    function  CheckOutByIndex      (var HidDev: TJvHidDevice; const Idx:   Integer): Boolean;
    function  CheckOutByProductName(var HidDev: TJvHidDevice; ProductName: string):  Boolean;
    function  CheckOutByVendorName (var HidDev: TJvHidDevice; VendorName:  string):  Boolean;
    // iterate over the HID devices
    function  Enumerate: Integer;

    // just to be complete the GUID
    property  HidGuid:        TGUID                read FHidGuid;
    property  NumCheckedInDevices:  Integer        read FNumCheckedInDevices;
    property  NumCheckedOutDevices: Integer        read FNumCheckedOutDevices;
    property  NumUnpluggedDevices:  Integer        read FNumUnpluggedDevices;
    // this event is copied to TJvHidDeviceOnUnplug on creation
    property  OnDeviceUnplug: TJvHidUnplugEvent    read FDevUnplugEvent    write SetDevUnplug;
    // the iterator event
    property  OnEnumerate:    TJvHidEnumerateEvent read FEnumerateEvent    write SetEnumerate;
    // the central event for HID device changes
    property  OnDeviceChange: TNotifyEvent         read FDeviceChangeEvent write SetDeviceChangeEvent;
  end;

// helpers to check the HID function and method results
function HidCheck(const RetVal: NTSTATUS): NTSTATUS; overload;
function HidCheck(const RetVal: LongBool): LongBool; overload;
function HidError(const RetVal: NTSTATUS): NTSTATUS;

// to register the component in the palette
procedure Register;

implementation

{$R HidControllerClass.dcr}

type
  EControllerError = class(Exception);
  EHidClientError  = class(Exception);

var
  // counter to prevent a second TJvHidDeviceController instance
  GlobalInstanceCount: Integer = 0;

//== these are declared inconsistent in Windows.pas ===================

function ReadFileEx(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD;
  var Overlapped: TOverlapped; lpCompletionRoutine: TPROverlappedCompletionRoutine): BOOL; stdcall;
  external 'kernel32.dll' name 'ReadFileEx';
function WriteFileEx(hFile: THandle; var Buffer; nNumberOfBytesToWrite: DWORD;
  var Overlapped: TOverlapped; lpCompletionRoutine: TPROverlappedCompletionRoutine): BOOL; stdcall;
 external 'kernel32.dll' name 'WriteFileEx';

//== TJvHidDevice =====================================================

// internal helper to read string values from a devices registry area

function GetRegistryProperty(PnPHandle: HDEVINFO; var DevData: TSPDevInfoData; ClassID: DWORD): string;
var
  BytesReturned: DWORD;
  RegData:       DWORD;
  Buffer:        array [0..256] of Char;
begin
  BytesReturned := 0;
  RegData       := REG_SZ;
  Buffer[0]     := #0;
  SetupDiGetDeviceRegistryProperty(PnPHandle, DevData, ClassID,
    @RegData, @Buffer[0], SizeOf(Buffer), @BytesReturned);
  Result := Buffer;
end;

//-- TJvHidDevice: basics and internals -------------------------------

// create and fill in a HidDevice object
// the constructor is only accessible from TJvHidController
// DevicePath names the device "file"
// DevID is a handle to the individual device
// (differs even for two devices of the same kind)
// DevDesc and ClassDesc are two strings from the devices registry space
// Controller is the devices controller object

constructor TJvHidDevice.Create(const DevicePath: string; const DevID: DWORD;
  const DevDesc, ClassDesc: string; Controller: TJvHidDeviceController);
var
  I:      Integer;
  Len:    ULONG;
  Buffer: array [0..256] of WideChar;
  IDs:    array [0..258] of WORD;
  Name:   array [0..256] of Char;
begin
  inherited Create;

  // initialize private data
  FMyController         := Controller;
  FIsPluggedIn          := True;
  FIsCheckedOut         := False;
  FIsEnumerated         := False;
  FHidOverlappedHandle  := INVALID_HANDLE_VALUE;
  FDeviceID             := 0;
  FDevicePath           := DevicePath;
  FRegDescr             := '';
  FRegClass             := '';
  FVendorName           := '';
  FProductName          := '';
  FPhysicalDescriptor   := '';
  FSerialNumber         := '';
  FLanguageStrings      := TStringList.Create;
  FPreparsedData        := 0;
  FillChar(FCaps, SizeOf(FCaps), #0);
  FillChar(FConfiguration, SizeOf(FConfiguration), #0);
  FNumInputBuffers      := 0;
  FNumOverlappedBuffers := 0;
  SetLength(FLinkCollection, 0);
  FMaxDataListLength    := 0;
  FMaxUsageListLength   := 0;
  FMaxButtonListLength  := 0;
  FReportTypeParam      := HIDP_Input;
  FUsagePageParam       := 0;
  FLinkCollectionParam  := 0;
  FUsageParam           := 0;
  FUnplug               := Controller.FDevUnplugEvent;

  FHidFileHandle := CreateFile(PChar(FDevicePath), GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  if HidFileHandle = INVALID_HANDLE_VALUE then
    FHidFileHandle := CreateFile(PChar(FDevicePath), 0,
      FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  if HidFileHandle <> INVALID_HANDLE_VALUE then
  begin
    // get all device data through HID functions
    // this eliminates the need to redeclare them as methods
    FDeviceID := DevID;
    FRegDescr := DevDesc;
    FRegClass := ClassDesc;
    FAttributes.Size := SizeOf(THIDDAttributes);
    HidD_GetPreparsedData(HidFileHandle, FPreparsedData);
    HidD_GetAttributes   (HidFileHandle, FAttributes);
    FConfiguration.cookie         := nil;
    FConfiguration.size           := 0;
    FConfiguration.RingBufferSize := 0;
    HidD_GetConfiguration(HidFileHandle, FConfiguration, SizeOf(THIDDConfiguration));
    HidP_GetCaps(FPreparsedData, FCaps);
    // calculate length of StringDescriptor 0
    FillChar(IDs, SizeOf(IDs), #0);
    Len := 0;
    for I := 0 to 256 do
    begin
      if HidD_GetIndexedString(HidFileHandle, 0, PWideChar(@IDs), I*SizeOf(WORD)) then
        Break;
      Inc(Len);
    end;
    // transform id into localized language name
    for I := 0 to Len - 1 do
    begin
      Name[0] := #0;
      if GetLocaleInfo(WORD(IDs[I]), LOCALE_SLANGUAGE, Name, SizeOf(Name)) <> 0 then
        FLanguageStrings.Add(Name)
      else
        FLanguageStrings.Add(Format('unknown Locale ID $%.4x',[WORD(IDs[I])]));
    end;
    if HidD_GetManufacturerString(HidFileHandle, Buffer, SizeOf(Buffer)) then
      FVendorName := WideCharToString(Buffer);
    if HidD_GetProductString(HidFileHandle, Buffer, SizeOf(Buffer)) then
      FProductName := WideCharToString(Buffer);
    if HidD_GetPhysicalDescriptor(HidFileHandle, Buffer, SizeOf(Buffer)) then
      FPhysicalDescriptor := WideCharToString(Buffer);
    // compensate for buggy function
    if HidD_GetSerialNumberString(HidFileHandle, Buffer, SizeOf(Buffer)) then
      for I := 0 to Len - 1 do
        if IDs[I] <> WORD(Buffer[I]) then
        begin
          FSerialNumber := WideCharToString(Buffer);
          Break;
        end;
    Len := FCaps.NumberLinkCollectionNodes;
    SetLength(FLinkCollection, Len);
    HidP_GetLinkCollectionNodes(@FLinkCollection[0], Len, FPreparsedData);
  end;
  // the file is closed to stop using up resources
  CloseFile;
end;

// If a TJvHidDevice is destroyed the TJvHidController has to be informed.
// If the device is plugged in this TJvHidDevice instance is destroyed,
// but another instance is created in the controller list

destructor TJvHidDevice.Destroy;
var
  I: Integer;
begin
  // to prevent strange problems
  OnUnplug := nil;
  // free the data which needs special handling
  CloseFile;
  CloseFileEx;
  HidD_FreePreparsedData(FPreparsedData);
  FLanguageStrings.Free;

  // if controller exists
  if FMyController <> nil then
    with FMyController do
    begin
      // delete device from controller list
      for I := 0 to FList.Count - 1 do
        if FList.Items[I] = Self then
        begin
          // if device is plugged in create a checked in copy
          if IsPluggedIn then
          begin
            FList.Items[I] := TJvHidDevice.Create(DevicePath, DeviceID,
              RegDescr, RegClass, FMyController);
            if IsCheckedOut then
            begin
              Dec(FNumCheckedOutDevices);
              Inc(FNumCheckedInDevices);
            end;
          end
          else
          begin
            FList.Delete(I);
            Dec(FNumUnpluggedDevices);
          end;
          Break;
        end;
    end;

  inherited Destroy;
end;

// if check changes change check only here

function TJvHidDevice.IsAccessible: Boolean;
begin
  Result := IsPluggedIn and (IsCheckedOut or FIsEnumerated);
end;

// open the device "file" (for the other methods)

function TJvHidDevice.OpenFile: Boolean;
begin
  // check if open allowed (propagates this state)
  if IsAccessible then
    if HidFileHandle = INVALID_HANDLE_VALUE then // if not already opened
    begin
      FNumInputBuffers := 0;
      FHidFileHandle   := CreateFile(PChar(FDevicePath), GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
      if HidFileHandle <> INVALID_HANDLE_VALUE then
        HidD_GetNumInputBuffers(HidFileHandle, FNumInputBuffers);
    end;
  Result := HidFileHandle <> INVALID_HANDLE_VALUE;
end;

// open second device "file" for ReadFileEx and WriteFileEx

function TJvHidDevice.OpenFileEx: Boolean;
begin
  // check if open allowed (propagates this state)
  if IsAccessible then
    if HidOverlappedHandle = INVALID_HANDLE_VALUE then // if not already opened
    begin
      FNumOverlappedBuffers := 0;
      FHidOverlappedHandle := CreateFile(PChar(FDevicePath), GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
      if FHidOverlappedHandle <> INVALID_HANDLE_VALUE then
        HidD_GetNumInputBuffers(FHidOverlappedHandle, FNumOverlappedBuffers);
    end;
  Result := FHidOverlappedHandle <> INVALID_HANDLE_VALUE;
end;

// implement OnUnplug event

procedure TJvHidDevice.DoUnplug;
begin
  CloseFile;
  CloseFileEx;
  FIsPluggedIn := False;
  // event even for checked in devices
  if Assigned(FUnplug) then
    FUnplug(Self);
  // guarantees that event is only called once
  OnUnplug := nil;
end;

// assign the OnUnplug event

procedure TJvHidDevice.SetUnplug(const Event: TJvHidUnplugEvent);
begin
  if @Event <> @FUnplug then
    FUnplug := Event;
end;

// implementing indexed properties read

function TJvHidDevice.GetDeviceString(Idx: Byte): string;
var
  Buffer: array [0..256] of WideChar;
begin
  Result := '';
  if Idx <> 0 then
    if OpenFile then
      if HidD_GetIndexedString(HidFileHandle, Idx, Buffer, SizeOf(Buffer)) then
        Result := WideCharToString(Buffer);
end;

function TJvHidDevice.GetLinkCollectionNode(Idx: WORD): THIDPLinkCollectionNode;
begin
  FillChar(Result, SizeOf(THIDPLinkCollectionNode), #0);
  if (Idx > 0) and (Idx <= Length(FLinkCollection)) then
    Result := FLinkCollection[Idx-1];
end;

// implementing properties write

procedure TJvHidDevice.SetNumInputBuffers(const Num: Integer);
begin
  if OpenFile then
  begin
    HidD_SetNumInputBuffers(HidFileHandle, Num);
    HidD_GetNumInputBuffers(HidFileHandle, FNumInputBuffers);
  end;
end;

procedure TJvHidDevice.SetNumOverlappedBuffers(const Num: Integer);
begin
  if OpenFileEx then
  begin
    HidD_SetNumInputBuffers(HidOverlappedHandle, Num);
    HidD_GetNumInputBuffers(HidOverlappedHandle, FNumOverlappedBuffers);
  end;
end;

// internal helper for the following functions

procedure TJvHidDevice.GetMax;
begin
  if IsAccessible then
  begin
    FMaxDataListLength   := HidP_MaxDataListLength  (ReportTypeParam, PreparsedData);
    FMaxUsageListLength  := HidP_MaxUsageListLength (ReportTypeParam, UsagePageParam, PreparsedData);
    FMaxButtonListLength := HidP_MaxButtonListLength(ReportTypeParam, UsagePageParam, PreparsedData);
  end;
end;

procedure TJvHidDevice.SetReportTypeParam(const ReportType: THIDPReportType);
begin
  FReportTypeParam := ReportType;
  GetMax;
end;

procedure TJvHidDevice.SetUsagePageParam(const UsagePage: TUsage);
begin
  FUsagePageParam := UsagePage;
  GetMax;
end;

procedure TJvHidDevice.SetConfiguration(Config: THIDDConfiguration);
begin
  if OpenFile then
    if HidD_SetConfiguration(HidFileHandle, Config, SizeOf(THIDDConfiguration)) then
      FConfiguration := Config;
end;

//-- TJvHidDevice methods -----------------------------------------------

// generally the parameter count of the methods is reduced with the Param properties
// first assign the Param properties the desired value then call a method
// normally you will address the same Usage, UsagePage, ReportType or LinkCollection
// with more than one method
//
// the methods will open the device file when needed
// this file is not closed until unplug or destruction to speed up access

// close the device "file"
// if you want to open the file directly close this
// to get undisturbed access

procedure TJvHidDevice.CloseFile;
begin
   if HidFileHandle <> INVALID_HANDLE_VALUE then
      CloseHandle(HidFileHandle);
   FNumInputBuffers := 0;
   FHidFileHandle   := INVALID_HANDLE_VALUE;
end;

// same for the other device "file"

procedure TJvHidDevice.CloseFileEx;
begin
   if HidOverlappedHandle <> INVALID_HANDLE_VALUE then
      CloseHandle(HidOverlappedHandle);
   FNumOverlappedBuffers := 0;
   FHidOverlappedHandle  := INVALID_HANDLE_VALUE;
end;

// all the methods which directly map to a HID-function

function TJvHidDevice.FlushQueue: Boolean;
begin
  Result := False;
  if OpenFile then
    Result := HidD_FlushQueue(HidFileHandle);
end;

function TJvHidDevice.GetFeature(var Report; const Size: Integer): Boolean;
begin
  Result := False;
  if OpenFile then
    Result := HidD_GetFeature(HidFileHandle, Report, Size);
end;

function TJvHidDevice.SetFeature(var Report; const Size: Integer): Boolean;
begin
  Result := False;
  if OpenFile then
    Result := HidD_SetFeature(HidFileHandle, Report, Size);
end;

function TJvHidDevice.GetSpecificButtonCaps(ButtonCaps: PHIDPButtonCaps; var Count: WORD): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetSpecificButtonCaps(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageParam, ButtonCaps, Count, PreparsedData);
end;

function TJvHidDevice.GetButtonCaps(ButtonCaps: PHIDPButtonCaps; var Count: WORD): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetButtonCaps(ReportTypeParam, ButtonCaps, Count, PreparsedData);
end;

function TJvHidDevice.GetSpecificValueCaps(ValueCaps: PHIDPValueCaps; var Count: WORD): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetSpecificValueCaps(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageParam, ValueCaps, Count, PreparsedData);
end;

function TJvHidDevice.GetValueCaps(ValueCaps: PHIDPValueCaps; var Count: WORD): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetValueCaps(ReportTypeParam, ValueCaps, Count, PreparsedData);
end;

function TJvHidDevice.GetData(DataList: PHIDPData; var DataLength: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetData(ReportTypeParam, DataList, DataLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.SetData(DataList: PHIDPData; var DataLength: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_SetData(ReportTypeParam, DataList, DataLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.GetUsages(UsageList: PUsage; var UsageLength: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetUsages(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageList, UsageLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.GetButtons(UsageList: PUsage; var UsageLength: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetButtons(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageList, UsageLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.GetUsagesEx(UsageList: PUsageAndPage; var UsageLength: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetUsagesEx(ReportTypeParam, LinkCollectionParam, UsageList, UsageLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.GetButtonsEx(UsageList: PUsageAndPage; var UsageLength: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetButtonsEx(ReportTypeParam, LinkCollectionParam, UsageList, UsageLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.SetUsages(UsageList: PUsage; var UsageLength: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_SetUsages(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageList, UsageLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.SetButtons(UsageList: PUsage; var UsageLength: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_SetButtons(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageList, UsageLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.UnsetUsages(UsageList: PUsage; var UsageLength: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_UnsetUsages(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageList, UsageLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.UnsetButtons(UsageList: PUsage; var UsageLength: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_UnsetButtons(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageList, UsageLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.GetUsageValue(var UsageValue: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetUsageValue(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageParam,
                                 UsageValue, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.GetScaledUsageValue(var UsageValue: Integer; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetScaledUsageValue(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageParam,
                                       UsageValue, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.GetUsageValueArray(UsageValue: PChar; UsageValueByteLength: WORD; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_GetUsageValueArray(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageParam,
                                      UsageValue, UsageValueByteLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.SetUsageValue(UsageValue: ULONG; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_SetUsageValue(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageParam,
                                 UsageValue, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.SetScaledUsageValue(UsageValue: Integer; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_SetScaledUsageValue(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageParam,
                                       UsageValue, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.SetUsageValueArray(UsageValue: PChar; UsageValueByteLength: WORD; var Report; ReportLength: ULONG): NTSTATUS;
begin
  Result := HIDP_STATUS_NULL;  // for not plugged in
  if IsAccessible then
    Result := HidP_SetUsageValueArray(ReportTypeParam, UsagePageParam, LinkCollectionParam, UsageParam,
                                      UsageValue, UsageValueByteLength, PreparsedData, Report, ReportLength);
end;

function TJvHidDevice.DeviceIoControl(IoControlCode: DWORD; InBuffer: Pointer; InSize: DWORD;
  OutBuffer: Pointer; OutSize: DWORD; var BytesReturned: DWORD): Boolean;
begin
  Result := False;
  if OpenFile then
    Result := Windows.DeviceIoControl(HidFileHandle, IoControlCode, InBuffer, InSize, OutBuffer, OutSize, BytesReturned, nil);
end;

function TJvHidDevice.ReadFile(var Report; ToRead: DWORD; var BytesRead: DWORD): Boolean;
begin
  Result := False;
  if OpenFile then
    Result := Windows.ReadFile(HidFileHandle, Report, ToRead, BytesRead, nil);
end;

function TJvHidDevice.WriteFile(var Report; ToWrite: DWORD; var BytesWritten: DWORD): Boolean;
begin
  Result := False;
  if OpenFile then
    Result := Windows.WriteFile(HidFileHandle, Report, ToWrite, BytesWritten, nil);
end;

// the TOverlapped structure is not needed externally
// the hEvent element is used to transport the device object
// to the callback function
// Better not implement a Delphi event with that

function TJvHidDevice.ReadFileEx(var Report; ToRead: DWORD; CallBack: TPROverlappedCompletionRoutine): Boolean;
var
  Ovl: TOverlapped;
begin
  Result := False;
  if OpenFileEx then
  begin
    FillChar(Ovl, SizeOf(TOverlapped), #0);
    Ovl.hEvent := DWORD(Self);
    Result := HidControllerClass.ReadFileEx(HidOverlappedHandle, Report, ToRead, Ovl, CallBack);
  end;
end;

function TJvHidDevice.WriteFileEx(var Report; ToWrite: DWORD; CallBack: TPROverlappedCompletionRoutine): Boolean;
var
  Ovl: TOverlapped;
begin
  Result := False;
  if OpenFileEx then
  begin
    FillChar(Ovl, SizeOf(TOverlapped), #0);
    Ovl.hEvent := DWORD(Self);
    Result := HidControllerClass.WriteFileEx(HidOverlappedHandle, Report, ToWrite, Ovl, CallBack);
  end;
end;

//== TJvHidDeviceController ===========================================

// internal worker function to find all Hid devices and create their objects

procedure TJvHidDeviceController.FillInList(var List: TList);
var
  PnPHandle:               HDEVINFO;
  DevData:                 TSPDevInfoData;
  DeviceInterfaceData:     TSPDeviceInterfaceData;
  FunctionClassDeviceData: PSPDeviceInterfaceDetailData;
  Success:                 LongBool;
  Devn:                    Integer;
  BytesReturned:           DWORD;
  HidDev:                  TJvHidDevice;
begin
  // create list
  List := TList.Create;

  // Get a handle for the Plug and Play node and request currently active HID devices
  PnPHandle := SetupDiGetClassDevs(@FHidGuid, nil, 0, DIGCF_PRESENT or DIGCF_DEVICEINTERFACE);
  if PnPHandle = Pointer(INVALID_HANDLE_VALUE) then
    Exit;
  Devn := 0;
  repeat
    DeviceInterfaceData.cbSize := SizeOf(TSPDeviceInterfaceData);
    // Is there a HID device at this table entry?
    Success := SetupDiEnumDeviceInterfaces(PnPHandle, nil, FHidGuid, Devn, DeviceInterfaceData);
    if Success then
    begin
      DevData.cbSize := SizeOf(DevData);
      BytesReturned  := 0;
      SetupDiGetDeviceInterfaceDetail(PnPHandle, @DeviceInterfaceData, nil, 0, @BytesReturned, @DevData);
      if (BytesReturned <> 0) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
      begin
        FunctionClassDeviceData := AllocMem(BytesReturned);
        FunctionClassDeviceData.cbSize := 5;
        if SetupDiGetDeviceInterfaceDetail(PnPHandle, @DeviceInterfaceData, FunctionClassDeviceData, BytesReturned, @BytesReturned, @DevData) then
        begin
          // create HID device object and add it to the device list
          HidDev := TJvHidDevice.Create(PChar(@FunctionClassDeviceData.DevicePath), DevData.DevInst,
            GetRegistryProperty(PnPHandle, DevData, SPDRP_DEVICEDESC),
            GetRegistryProperty(PnPHandle, DevData, SPDRP_CLASS),
            Self);
          List.Add(HidDev);
          Inc(Devn);
        end;
        FreeMem(FunctionClassDeviceData);
      end;
    end;
  until not Success;
  SetupDiDestroyDeviceInfoList(PnPHandle);
end;

// the controller fills its list on creation and connects the event pipe

constructor TJvHidDeviceController.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDeviceChangeEvent    := nil;
  FEnumerateEvent       := nil;
  FDevUnplugEvent       := nil;
  FList                 := nil;
  FNumCheckedInDevices  := 0;
  FNumCheckedOutDevices := 0;
  FNumUnpluggedDevices  := 0;
  FDeviceChangeFired    := False;
  HidD_GetHidGuid(FHidGuid);

  // this is just to remind you that one controller is sufficient
  Inc(GlobalInstanceCount);
  if GlobalInstanceCount > 1 then
     raise EControllerError.Create('Only one TJvHidDeviceController allowed per program');

  // nothing done at design time
  if not (csDesigning in ComponentState) then
  begin
    FillInList(FList);
    FNumCheckedInDevices := FList.Count;
    Application.HookMainWindow(EventPipe);
  end;
end;

procedure TJvHidDeviceController.Loaded;
var
   I:   Integer;
   Dev: TJvHidDevice;
begin
  inherited Loaded;

  // after read in of properties
  // propagate the OnUnplug event to the device objects
  if FList <> nil then
     for I := 0 to FList.Count - 1 do
     begin
       Dev := FList.Items[I];
       Dev.OnUnplug := FDevUnplugEvent;
     end;
end;

// unplug or kill all controlled TJvHidDevices on controller destruction

destructor TJvHidDeviceController.Destroy;
var
  I:      Integer;
  HidDev: TJvHidDevice;
begin
  Dec(GlobalInstanceCount);
  // to prevent strange problems
  FDeviceChangeEvent := nil;
  FDevUnplugEvent    := nil;
  OnEnumerate        := nil;
  // nothing done at design time
  if not (csDesigning in ComponentState) then
  begin
    // unhook event pipe
    Application.UnhookMainWindow(EventPipe);
    for I := 0 to FList.Count - 1 do
    begin
      HidDev := FList.Items[I];
      with HidDev do
      begin
        // set to uncontrolled
        FMyController := nil;
        if IsCheckedOut then
          // pull the plug for checked out TJvHidDevices
          DoUnplug
        else
          // kill TJvHidDevices which are not checked out
          Free;
      end;
    end;
  end;
  FList.Free;

  inherited Destroy;
end;

// gets all the Windows events/messages directly

function TJvHidDeviceController.EventPipe(var Msg: TMessage): Boolean;
begin
  Result := False;
  // sort out WM_DEVICECHANGE : DBT_DEVNODES_CHANGED
  if (Msg.Msg = WM_DEVICECHANGE) and (TWMDeviceChange(Msg).Event = DBT_DEVNODES_CHANGED) then
    DoDeviceChange;
end;

// implements OnDeviceChange event

procedure TJvHidDeviceController.DoDeviceChange;
var
  I:       Integer;
  J:       Integer;
  NewList: TList;
  HidDev:  TJvHidDevice;
  Changed: Boolean;
begin
  Changed := False;
  // get new device list
  FillInList(NewList);

  // unplug devices in FList which are not in NewList
  for I := 0 to FList.Count - 1 do
  begin
    HidDev := FList.Items[I];
    for J := 0 to NewList.Count - 1 do
      if (TJvHidDevice(NewList.Items[J]).DeviceID = HidDev.DeviceID) and HidDev.IsPluggedIn then
      begin
        HidDev := nil;
        Break;
      end;
    if HidDev <> nil then
    begin
      HidDev.DoUnplug;
      // prepare for deletion from list
      if not HidDev.IsCheckedOut then
        FList.Items[I] := nil;
      Changed := True;
    end;
  end;

  // delete the nil elements from FList
  I := 0;
  while I < FList.Count do
  begin
    if FList.Items[I] = nil then
      FList.Delete(I)
    else
      Inc(I);
  end;

  // delete devices from NewList which are in FList
  for I := 0 to NewList.Count - 1 do
    for J := 0 to FList.Count - 1 do
      if (TJvHidDevice(NewList[I]).DeviceID = TJvHidDevice(FList[J]).DeviceID) and TJvHidDevice(FList[J]).IsPluggedIn then
      begin
        TJvHidDevice(NewList[I]).FMyController := nil; // prevent Free/Destroy from accessing this controller
        TJvHidDevice(NewList[I]).Free;
        NewList[I] := nil;
        Break;
      end;

  // add the remains in NewList to FList
  for I := 0 to NewList.Count - 1 do
    if NewList[I] <> nil then
    begin
      FList.Add(NewList[I]);
      Changed := True;
    end;

  // throw away helper list
  NewList.Free;

  // recount the devices
  FNumCheckedInDevices  := 0;
  FNumCheckedOutDevices := 0;
  FNumUnpluggedDevices  := 0;
  for I := 0 to FList.Count - 1 do
  begin
    HidDev := FList.Items[I];
    Inc(FNumCheckedInDevices,  Ord(not HidDev.IsCheckedOut));
    Inc(FNumCheckedOutDevices, Ord(HidDev.IsCheckedOut));
    Inc(FNumUnpluggedDevices,  Ord(not HidDev.IsPluggedIn));
  end;
  FNumCheckedOutDevices := FNumCheckedOutDevices - FNumUnpluggedDevices;

  if Assigned(FDeviceChangeEvent) and Changed then
    FDeviceChangeEvent(Self);
end;

// assign OnDeviceChange and immediately fire if needed

procedure TJvHidDeviceController.SetDeviceChangeEvent(const Notifier: TNotifyEvent);
begin
  if @Notifier <> @FDeviceChangeEvent then
  begin
    FDeviceChangeEvent := Notifier;
    if Assigned(FDeviceChangeEvent) and not FDeviceChangeFired then
      FDeviceChangeEvent(Self);
    FDeviceChangeFired := True;
  end;
end;

// implement OnEnumerate event

function TJvHidDeviceController.DoEnumerate(HidDev: TJvHidDevice; Idx: Integer): Boolean;
begin
  Result := False;
  if Assigned(FEnumerateEvent) then
  begin
    HidDev.FIsEnumerated := True;
    Result := FEnumerateEvent(HidDev, Idx);
    HidDev.FIsEnumerated := False;
    if not HidDev.FIsCheckedOut then
    begin
      HidDev.CloseFile;
      HidDev.CloseFileEx;
    end;
  end;
end;

// assign OnEnumerate event

procedure TJvHidDeviceController.SetEnumerate(const Enumerator: TJvHidEnumerateEvent);
begin
  if @Enumerator <> @FEnumerateEvent then
    FEnumerateEvent := Enumerator;
end;

// assign OnDevUnplug event

procedure TJvHidDeviceController.SetDevUnplug(const Unplugger: TJvHidUnplugEvent);
var
   I:   Integer;
   Dev: TJvHidDevice;
begin
  if @Unplugger <> @FDevUnplugEvent then
  begin
    // change all OnUnplug events with the same old value
    if not (csDesigning in ComponentState) then
      for I := 0 to FList.Count - 1 do
      begin
        Dev := FList.Items[I];
        if @Dev.FUnplug = @FDevUnplugEvent then
          Dev.OnUnplug := Unplugger;
      end;
    FDevUnplugEvent := Unplugger;
  end;
end;

// send an OnEnumerate event for ALL controlled HidDevices
// it is explicitly allowed to check out any device in the event

function TJvHidDeviceController.Enumerate: Integer;
var
   I: Integer;
begin
  Result := 0;
  for I := 0 to FList.Count - 1 do
    if TJvHidDevice(FList[I]).IsPluggedIn then
    begin
      Inc(Result);
      if not DoEnumerate(FList[I], I) then
        Break;
    end;
end;

//-- TJvHidDeviceController methods -----------------------------------

// internal worker function to check out a TJvHidDevice

function TJvHidDeviceController.CheckThisOut(var HidDev: TJvHidDevice; Idx: Integer; Check: Boolean): Boolean;
begin
  Result := Check and not TJvHidDevice(FList.Items[Idx]).IsCheckedOut;
  if Result then
  begin
    HidDev := FList[Idx];
    HidDev.FIsCheckedOut := True;
    Inc(FNumCheckedOutDevices);
    Dec(FNumCheckedInDevices);
  end;
end;

// method CheckOutByProductName hands out the first HidDevice with a matching ProductName

function TJvHidDeviceController.CheckOutByProductName(var HidDev: TJvHidDevice; ProductName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  HidDev := nil;
  if ProductName <> '' then
    for I := 0 to FList.Count - 1 do
    begin
      Result := CheckThisOut(HidDev, I, ProductName = TJvHidDevice(FList[I]).ProductName);
      if Result then
        Break;
    end;
end;

// method CheckOutByVendorName hands out the first HidDevice with a matching VendorName

function TJvHidDeviceController.CheckOutByVendorName(var HidDev: TJvHidDevice; VendorName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  HidDev := nil;
  if VendorName <> '' then
    for I := 0 to FList.Count - 1 do
    begin
      Result := CheckThisOut(HidDev, I, VendorName = TJvHidDevice(FList[I]).VendorName);
      if Result then
        Break;
    end;
end;

// method CheckOutByClass hands out the first HidDevice with a matching Class
// Class comes from the registry (examples: 'Mouse', 'Keyboard')

function TJvHidDeviceController.CheckOutByClass(var HidDev: TJvHidDevice; ClassName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  HidDev := nil;
  if ClassName <> '' then
    for I := 0 to FList.Count - 1 do
    begin
      Result := CheckThisOut(HidDev, I, ClassName = TJvHidDevice(FList[I]).RegClass);
      if Result then
        Break;
    end;
end;

// method CheckOutByID hands out the first HidDevice with a matching VendorID and ProductID
// Pid = -1 matches all ProductIDs

function TJvHidDeviceController.CheckOutByID(var HidDev: TJvHidDevice; Vid, Pid: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  HidDev := nil;
  for I := 0 to FList.Count - 1 do
  begin
    Result := CheckThisOut(HidDev, I, (Vid = TJvHidDevice(FList[I]).Attributes.VendorID) and
      ((Pid = TJvHidDevice(FList[I]).Attributes.ProductID) or (Pid = -1)));
    if Result then
      Break;
  end;
end;

// method CheckOutByIndex hands out the HidDevice in the list with the named index
// this is mainly for check out during OnEnumerate

function TJvHidDeviceController.CheckOutByIndex(var HidDev: TJvHidDevice; const Idx: Integer): Boolean;
begin
  Result := False;
  HidDev := nil;
  if (Idx >= 0) and (Idx < FList.Count) then
    Result := CheckThisOut(HidDev, Idx, True);
end;

// method CheckOut simply hands out the first available HidDevice in the list

function TJvHidDeviceController.CheckOut(var HidDev: TJvHidDevice): Boolean;
var
  I: Integer;
begin
  Result := False;
  HidDev := nil;
  for I := 0 to FList.Count - 1 do
  begin
    Result := CheckThisOut(HidDev, I, True);
    if Result then
      Break;
  end;
end;

// method CheckIn hands a checked out HidDevice back in

procedure TJvHidDeviceController.CheckIn(var HidDev: TJvHidDevice);
begin
  if HidDev <> nil then
  begin
    HidDev.CloseFile;
    HidDev.CloseFileEx;

    if HidDev.IsPluggedIn then
    begin
      HidDev.FIsCheckedOut := False;
      Dec(FNumCheckedOutDevices);
      Inc(FNumCheckedInDevices);
    end
    else
      HidDev.Free;
    HidDev := nil;
  end;
end;

// a helper function to check the return values just
// like Win32Check
// the functions return the parameter to be transparent

function HidCheck(const RetVal: NTSTATUS): NTSTATUS;
begin
  if RetVal <> HIDP_STATUS_SUCCESS then
    HidError(RetVal);
  Result := RetVal;
end;

function HidCheck(const RetVal: LongBool): LongBool;
begin
  if not RetVal then
    raise EHidClientError.Create('HidClient Error: a boolean function failed');
  Result := RetVal;
end;

function HidError(const RetVal: NTSTATUS): NTSTATUS;
var
  ErrBuf: string;
begin
  // only check HID errors
  if ((RetVal and NTSTATUS($00FF0000)) = HIDP_STATUS_SUCCESS) and
     ((RetVal and NTSTATUS($C0000000)) <> 0) then
  begin
    case RetVal of
      HIDP_STATUS_NULL:                    ErrBuf := 'device not plugged in';
      HIDP_STATUS_INVALID_PREPARSED_DATA:  ErrBuf := 'invalid preparsed data';
      HIDP_STATUS_INVALID_REPORT_TYPE:     ErrBuf := 'invalid report type';
      HIDP_STATUS_INVALID_REPORT_LENGTH:   ErrBuf := 'invalid report length';
      HIDP_STATUS_USAGE_NOT_FOUND:         ErrBuf := 'usage not found';
      HIDP_STATUS_VALUE_OUT_OF_RANGE:      ErrBuf := 'value out of range';
      HIDP_STATUS_BAD_LOG_PHY_VALUES:      ErrBuf := 'bad logical or physical values';
      HIDP_STATUS_BUFFER_TOO_SMALL:        ErrBuf := 'buffer too small';
      HIDP_STATUS_INTERNAL_ERROR:          ErrBuf := 'internal error';
      HIDP_STATUS_I8042_TRANS_UNKNOWN:     ErrBuf := '8042 key translation impossible';
      HIDP_STATUS_INCOMPATIBLE_REPORT_ID:  ErrBuf := 'incompatible report ID';
      HIDP_STATUS_NOT_VALUE_ARRAY:         ErrBuf := 'not a value array';
      HIDP_STATUS_IS_VALUE_ARRAY:          ErrBuf := 'is a value array';
      HIDP_STATUS_DATA_INDEX_NOT_FOUND:    ErrBuf := 'data index not found';
      HIDP_STATUS_DATA_INDEX_OUT_OF_RANGE: ErrBuf := 'data index out of range';
      HIDP_STATUS_BUTTON_NOT_PRESSED:      ErrBuf := 'button not pressed';
      HIDP_STATUS_REPORT_DOES_NOT_EXIST:   ErrBuf := 'report does not exist';
      HIDP_STATUS_NOT_IMPLEMENTED:         ErrBuf := 'not implemented';
    else
      ErrBuf := Format('unknown HID error %x', [RetVal]);
    end;
    raise EHidClientError.Create('HidClient Error: ' + ErrBuf);
  end;
  Result := RetVal;
end;

// We place the component on the new 'Project JEDI' palette.
// This is to encourage you to become a member.
// Have a look at www.delphi-jedi.org for further details.

procedure Register;
begin
  RegisterComponents('Project JEDI', [TJvHidDeviceController]);
end;

end.

