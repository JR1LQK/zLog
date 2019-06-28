{========================================================================}
{=====================  TVicRes class definition  =======================}
{========================================================================}

unit Vic_Res;

interface

uses SysUtils, Windows,Messages,Classes;

//{$DEFINE DEMOVERSION}

//========================================================================
//======================  Windows 95/98     ==============================
//========================================================================

const	ResType_Mem   = $00000001;      // Physical address resource.
const	ResType_IO    = $00000002;      // Physical IO address resource.
const	ResType_DMA   = $00000003;      // DMA channels 0-7 resource.
const	ResType_IRQ   = $00000004;      // IRQ 0-15 resource.

const   MAX_RESOURCE_SIZE = 16;

type TMem95Config = record

        LengthRecord   : dWord;
        TypeRecord     : dWord;   // ResType_Mem   = $00000001;

    	MD_Count       : Word;
	MD_Type        : Word;
	MD_Alloc_Base  : LongInt;
	MD_Alloc_End   : LongInt;
	MD_Flags       : Word;
	MD_Reserved    : Word;

	MR_Align    : LongInt;	// Mask for base alignment
	MR_nBytes   : LongInt;	// Count of bytes
	MR_Min      : LongInt;	// Min Address
	MR_Max      : LongInt;	// Max Address
	MR_Flags    : Word;	// Flags
	MR_Reserved : Word;

     end;

type TPort95Config = record

        LengthRecord     : dWord;
        TypeRecord       : dWord;   // ResType_IO   = $00000002;

	IOD_Count        : Word;
	IOD_Type         : WORD;
	IOD_Alloc_Base   : WORD;
	IOD_Alloc_End    : WORD;
	IOD_DesFlags     : WORD;
	IOD_Alloc_Alias  : BYTE;
	IOD_Alloc_Decode : BYTE;

       	IOR_Align        : WORD;	// Mask for base alignment
	IOR_nPorts       : WORD;	// Number of ports
	IOR_Min          : WORD;	// Min port address
	IOR_Max          : WORD;	// Max port address
	IOR_RangeFlags   : WORD;	// Flags
	IOR_Alias        : BYTE;	// Alias offset
	IOR_Decode       : BYTE;	// Address specified

end;


type TDMA95Config = record
        LengthRecord     : dWord;
        TypeRecord       : dWord;   // ResType_DMA   = $00000003;

        DD_Flags         : BYTE;
	DD_Alloc_Chan    : BYTE;	// Channel number allocated
	DD_Req_Mask      : BYTE;
	DD_Reserved      : BYTE;
end;

type TIRQ95Config = record

        LengthRecord   : dWord;
        TypeRecord     : dWord;         // ResType_IRQ   = $00000004;

     	IRQD_Flags     : WORD;
	IRQD_Alloc_Num : WORD;		// Allocated IRQ number
	IRQD_Req_Mask  : WORD;
	IRQD_Reserved  : WORD;

      end;

//========================================================================
//======================    Windows NT      ==============================
//========================================================================

const CmResourceTypePort             =  1;
const CmResourceTypeInterrupt        =  2;
const CmResourceTypeMemory           =  3;
const CmResourceTypeDma              =  4;

type
  PHYSICAL_ADDRESS = array[0..1] of Longint;

  TPortResource_NT = record
       Start            : PHYSICAL_ADDRESS;
       Length           : Longint;
  end;

  TInterruptResource_NT = record
       Level     : Longint;
       Vector    : Longint;
       Affinity  : Longint;
  end;

  TMemoryResource_NT = record
       Start     : PHYSICAL_ADDRESS;
       Length    : Longint;
  end;

  TDMAResource_NT = record
       Channel    : Longint;
       PortAddr   : Longint;
       Reserved1  : Longint;
  end;

  TDataResource = record
       DataSize    : Longint;
       Reserved1   : Longint;
       Reserved2   : Longint;
  end;

  CM_PARTIAL_RESOURCE_DESCRIPTOR = record
        TypeResource     : Byte;  // Specifies type of resource
        ShareDisposition : Byte;  // Specifies how this resourse can be shared
        Flags            : Word;  // Specifies type-dependent information
      case Integer of
       0 : (PortResource      : TPortResource_NT);
       1 : (InterruptResource : TInterruptResource_NT);
       2 : (MemoryResource    : TMemoryResource_NT);
       3 : (DMAResource       : TDMAResource_NT);
  end;

  CM_PARTIAL_RESOURCE_LIST = record
       Version  : Word;           // The version number of this structure.
       Revision : Word;           // The revision of this structure.
       Count    : Longint;        // The number of partial resource descriptors
       PartialDescriptors : array[1..MAX_RESOURCE_SIZE] of CM_PARTIAL_RESOURCE_DESCRIPTOR;
  end;

  CM_FULL_RESOURCE_DESCRIPTOR = record

       InterfaceType       : DWORD;      // Specifies the bus interface type
       BusNumber           : DWORD;      // The zero-based number for this bus
       PartialResourceList : CM_PARTIAL_RESOURCE_LIST;

  end;

  CM_RESOURCE_LIST = record
       Count : Longint;              // The number of full resource descriptors
       List  : array[1..MAX_RESOURCE_SIZE] of CM_FULL_RESOURCE_DESCRIPTOR;
  end;


type

  TVicRes = class

  private

    fWin95          : Boolean;
    fNT5            : Boolean;

    fClassN         : String;

    fDevices        : Word;
    fHardwareKeys   : array[1..MAX_RESOURCE_SIZE] of String;
    fDeviceDescriptors: array[1..MAX_RESOURCE_SIZE] of String;

    fIRQCounter     : Word;
    fIRQNumber      : array[1..MAX_RESOURCE_SIZE] of Byte;

    fDMACounter     : Word;
    fDMAChannel     : array[1..MAX_RESOURCE_SIZE] of Byte;

    fPortCounter    : Word;
    fPortBase       : array[1..MAX_RESOURCE_SIZE] of Word;
    fPortEnd        : array[1..MAX_RESOURCE_SIZE] of Word;

    fMemCounter     : Word;
    fMemBase        : array[1..MAX_RESOURCE_SIZE] of DWORD;
    fMemEnd         : array[1..MAX_RESOURCE_SIZE] of DWORD;

    function GetIRQNumber(nom:Word):Word;
    function GetDMAChannel(nom:Word):Word;
    function GetPortBase(nom:Word):Word;
    function GetPortEnd(nom:Word):Word;
    function GetMemBase(nom:Word):DWORD;
    function GetMemEnd(nom:Word):DWORD;

    function GetHardwareKey(nom:Word):String;
    function GetDeviceDescriptor(nom:Word):String;

    function SearchByClass_9X(Class_Name:String) : BOOL;
    function SearchByClass_NT(Class_Name:String) : BOOL;
    function SearchByHardwareKey_9X(HWK:String) : BOOL;
    function SearchByHardwareKey_NT(HWK:String) : BOOL;
    function SearchByDeviceDescriptor_9X(DD:String): BOOL;
    function SearchByDeviceDescriptor_NT(DD:String): BOOL;
    procedure   GetAllClasses_9X(ClassList: TStrings);
    procedure   GetAllClasses_NT(ClassList: TStrings);

  public

    constructor Create;

    procedure   GetAllClasses (ClassList: TStrings);

    function    SearchByClassName(Class_Name:String) : BOOL;
    function    SearchByHardwareKey(HWK:String) : BOOL;
    function    SearchByDeviceDescriptor(DD:String): BOOL;

    property    IRQCounter  : Word read fIRQCounter;
    property    IRQNumber[Index:Word]  : Word read GetIRQNumber;

    property    DMACounter  : Word read fDMACounter;
    property    DMAChannel[Index:Word] : Word read GetDMAChannel;

    property    PortCounter : Word read fPortCounter;
    property    PortBase[Index:Word] : Word read GetPortBase;
    property    PortEnd[Index:Word]:Word read GetPortEnd;

    property    MemCounter  : Word read fMemCounter;
    property    MemBase[Index:Word] : DWORD read GetMemBase;
    property    MemEnd[Index:Word] : DWORD read GetMemEnd;

    property    DeviceClassName : String read fClassN;
    property    Devices : Word read fDevices;
    property    HardwareKey[Index:Word] : String read GetHardwareKey;
    property    DeviceDescriptor[Index:Word] : String read GetDeviceDescriptor;

  end;


implementation

{$ifdef DEMOVERSION}
uses Dialogs;
{$endif}

function Hex2ToInt( s : String ) : Byte; forward;

procedure OpenSubKey(MainKey       : HKEY;
                      SubKey       : String;
                  var hSubKey      : HKEY;
                  var cSubKeys     : DWORD;
                  var NumKeys      : DWORD); forward;

function SearchKeyValue(hSubKey    : HKEY;
                        NumKeys    : Word;
                        KeyName    : String;
                    var OutBuffer ): Boolean; forward;
//-------------------------------------------------------

constructor TVicRes.Create; {==}
var
  winver:TOSVersionInfo;
begin
  inherited Create;
  fNT5:=false;
  fWin95:=(GetVersion and $80000000)<>0;
  if not fWin95 then
  begin
    WinVer.dwOSVersionInfoSize:=sizeof(WinVer);
    GetVersionEx(WinVer);
    if WinVer.dwMajorVersion>4 then fNT5:=true;
  end;
  {$ifdef DEMOVERSION}
    ShowMessage('Unregistered shareware TVicRes'+#$0D#$0A+
                'by Victor Ishikeev'+#$0D#$0A+
                'e-mail: ivi@ufanet.ru'+#$0D#$0A+
                'http://www.entechtaiwan.com/tools.htm');
  {$endif}
end;
//-------------------------------------------------------
function TVicRes.GetIRQNumber(nom:Word):Word;
begin
  if (nom=0) or (nom>fIRQCounter) then
    Result := $FFFF
  else
    Result := fIRQNumber[nom];
end;
//-------------------------------------------------------
function TVicRes.GetDMAChannel(nom:Word):Word;
begin
  if (nom=0) or (nom>fDMACounter) then
    Result := $FFFF
  else
    Result := fDMAChannel[nom];
end;
//-------------------------------------------------------
function TVicRes.GetPortBase(nom:Word):Word;
begin
  if (nom=0) or (nom>fPortCounter) then
    Result := $FFFF
  else
    Result := fPortBase[nom];
end;
//-------------------------------------------------------
function TVicRes.GetPortEnd(nom:Word):Word;
begin
  if (nom=0) or (nom>fPortCounter) then
    Result := $FFFF
  else
    Result := fPortEnd[nom];
end;
//-------------------------------------------------------
function TVicRes.GetMemBase(nom:Word):DWORD;
begin
  if (nom=0) or (nom>fMemCounter) then
    Result := $FFFFFFFF
  else
    Result := fMemBase[nom];
end;
//-------------------------------------------------------
function TVicRes.GetMemEnd(nom:Word):DWORD;
begin
  if (nom=0) or (nom>fMemCounter) then
    Result := $FFFFFFFF
  else
    Result := fMemEnd[nom];
end;
//-------------------------------------------------------
function TVicRes.GetHardwareKey(nom:Word):String;
begin
  if (nom=0) or (nom>fDevices) then
    Result := ''
  else
    Result := fHardwareKeys[nom];
end;
//-------------------------------------------------------
function TVicRes.GetDeviceDescriptor(nom:Word):String;
begin
  if (nom=0) or (nom>fDevices) then
    Result := ''
  else
    Result := fDeviceDescriptors[nom];
end;
//-------------------------------------------------------
function TVicRes.SearchByClassName(Class_Name:String) : BOOL;
begin
  fClassN:=Class_Name;
  if fWin95 then
    Result:=SearchByClass_9X(Class_Name)
  else
    Result:=SearchByClass_NT(Class_Name);
end;
//-------------------------------------------------------
function TVicRes.SearchByHardwareKey(HWK:String) : BOOL;
begin
  if fWin95 then
    Result:=SearchByHardwareKey_9X(HWK)
  else
    Result:=SearchByHardwareKey_NT(HWK);
end;
//-------------------------------------------------------
function TVicRes.SearchByDeviceDescriptor(DD:String) : BOOL;
begin
  if fWin95 then
    Result:=SearchByDeviceDescriptor_9X(DD)
  else
    Result:=SearchByDeviceDescriptor_NT(DD);
end;
//-------------------------------------------------------
function  TVicRes.SearchByClass_9X(Class_Name:String) : BOOL;
var s,HWKey,DD    : String;
    MemConfig     : TMem95Config;
    IRQConfig     : TIRQ95Config;
    PortConfig    : TPort95Config;
    DMAConfig     : TDMA95Config;
    achKey                               : array[0..1023] of Char;
    KeysInDynKey,KeysInLM,i,SubKeys,nn   : DWORD;
    hLMKey,hDynKey,hLocDynKey            : HKEY;
    KeyLMValue                           : String;
    Buffer,LogBuffer                     : array[0..1023] of Char;
    BegBuffer                            : DWORD;
    PStatus                              : DWORD;
    TmpMemConfig                         : TMem95Config;
begin

  fDevices    := 0;

  fIRQCounter := 0;
  fDMACounter := 0;
  fPortCounter:= 0;
  fMemCounter := 0;

  FillChar(MemConfig,SizeOf(TMem95Config),0);
  FillChar(IRQConfig,SizeOf(TIRQ95Config),0);
  FillChar(DMAConfig,SizeOf(TDMA95Config),0);
  FillChar(PortConfig,SizeOf(TPort95Config),0);

  OpenSubKey(HKEY_DYN_DATA,'Config Manager\Enum',hDynKey,SubKeys,KeysInDynKey);

  i:=0;

  while (i<SubKeys) do
  begin

    RegEnumKey(hDynKey,i,achKey,1024);

    s:='Config Manager\Enum\'+StrPas(achKey);
    OpenSubKey(HKEY_DYN_DATA,s,hLocDynKey,nn,KeysInDynKey);

    FillChar(Buffer,SizeOf(Buffer),0);
    SearchKeyValue(hLocDynKey,KeysInDynKey,'Problem',Buffer);
    Move(Buffer, PStatus, SizeOf(PStatus));

    FillChar(Buffer,SizeOf(Buffer),0);
    SearchKeyValue(hLocDynKey,KeysInDynKey,'HardWareKey',Buffer);
    HWKey:=StrPas(Buffer);

    FillChar(Buffer,SizeOf(LogBuffer),0);
    SearchKeyValue(hLocDynKey,KeysInDynKey,'Allocation',LogBuffer);

    RegCloseKey(hLocDynKey);

    if HWKey<>'' then
    begin

      OpenSubKey(HKEY_LOCAL_MACHINE,'Enum\'+HWKey,hLMKey,nn,KeysInLM);
      if hLMKey<>0 then
      begin
        SearchKeyValue(hLMKey,KeysInLM,'Class',Buffer);
        KeyLMValue:=StrPas(Buffer);
        SearchKeyValue(hLMKey,KeysInLM,'DeviceDesc',Buffer);
        DD:=StrPas(Buffer);
        RegCloseKey(hLMKey);
      end
      else begin
             KeyLMValue:='';
           end;

      if (AnsiUpperCase(KeyLMValue)=AnsiUpperCase(Class_Name)) and (PStatus=0) then
      begin

        BegBuffer:=8;

        if fDevices<MAX_RESOURCE_SIZE then
        begin
          Inc(fDevices);
          fHardwareKeys[fDevices]:=HWKey;
          fDeviceDescriptors[fDevices]:=DD;
        end;

        while (Byte(LogBuffer[BegBuffer])>0) do
        begin

          Move(LogBuffer[BegBuffer],TmpMemConfig,8);

          if (TmpMemConfig.TypeRecord=ResType_Mem) and (fMemCounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],MemConfig,SizeOf(TMem95Config));
            with MemConfig do
            begin
              Inc(fMemCounter);
              fMemBase[fMemCounter] := MD_Alloc_Base;
              fMemEnd[fMemCounter]  := MD_Alloc_End;
            end;
          end;

          if (TmpMemConfig.TypeRecord=ResType_IO) and (fPortCounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],PortConfig,SizeOf(TPort95Config));
            with PortConfig do
            begin
              Inc(fPortCounter);
              fPortBase[fPortCounter] := IOD_Alloc_Base;
              fPortEnd[fPortCounter]  := IOD_Alloc_End;
            end;
          end;

          if (TmpMemConfig.TypeRecord=ResType_IRQ) and (fIRQCounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],IRQConfig,SizeOf(TIRQ95Config));
            with IRQConfig do
            begin
              Inc(fIRQCounter);
              fIRQNumber[fIRQCounter] := IRQD_Alloc_Num;
            end;
          end;

          if (TmpMemConfig.TypeRecord=ResType_DMA) and (fDMACounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],DMAConfig,SizeOf(TDMA95Config));
            with DMAConfig do
            begin
              Inc(fDMACounter);
              fDMAChannel[fDMACounter] := DD_Alloc_Chan;
            end;
          end;

          BegBuffer:=BegBuffer+TmpMemConfig.LengthRecord;

        end;
      end;
    end;
    Inc(i);
  end;
  RegCloseKey(hDynKey);
  Result := fDevices > 0;
end;
//-------------------------------------------------------
function TVicRes.SearchByClass_NT(Class_Name:String) : BOOL;
var sLevel1,sLevel2,sLevel3,sLevel4 : String;
    ClassString,HWID,DD             : String;
    ResList                         : CM_RESOURCE_LIST;
    i,j                             : Byte;
    achKey                                                  : array[0..1023] of Char;
    KeysInKey0,KeysInKey1,KeysInKey2,KeysInKey3,KeysInKey4  : DWORD;
    SubKeys0,  SubKeys1,  SubKeys2,  SubKeys3,  SubKeys4    : DWORD;
    Level0,    Level1,    Level2                            : DWORD;
    Key0,Key1,Key2,Key3,Key4                                : HKEY;
    Buffer                                                  : array[0..1023] of Char;
const sLevel0 : String = 'SYSTEM\CurrentControlSet\Enum';
begin

  fDevices    := 0;

  fIRQCounter := 0;
  fDMACounter := 0;
  fPortCounter:= 0;
  fMemCounter := 0;


  OpenSubKey(HKEY_LOCAL_MACHINE,sLevel0,Key0,SubKeys0,KeysInKey0);

  for Level0:=0 to SubKeys0-1  do
  begin

    RegEnumKey(Key0,Level0,achKey,1024);
    sLevel1:=sLevel0+'\'+StrPas(achKey);
    OpenSubKey(HKEY_LOCAL_MACHINE,sLevel1,Key1,SubKeys1,KeysInKey1);

    for Level1:=0 to SubKeys1-1 do
    begin

      RegEnumKey(Key1,Level1,achKey,1024);
      sLevel2:=sLevel1+'\'+StrPas(achKey);
      OpenSubKey(HKEY_LOCAL_MACHINE,sLevel2,Key2,SubKeys2,KeysInKey2);

      for Level2:=0 to SubKeys2-1 do
      begin

        RegEnumKey(Key2,Level2,achKey,1024);
        sLevel3:=sLevel2+'\'+StrPas(achKey);
        OpenSubKey(HKEY_LOCAL_MACHINE,sLevel3,Key3,SubKeys3,KeysInKey3);

        FillChar(Buffer,SizeOf(Buffer),0);
        SearchKeyValue(Key3,KeysInKey3,'Class',Buffer);
        ClassString:=StrPas(Buffer);

        FillChar(Buffer,SizeOf(Buffer),0);
        SearchKeyValue(Key3,KeysInKey3,'HardwareID',Buffer);
        HWID:=StrPas(Buffer);

//        if not SearchKeyValue(Key3,KeysInKey3,'FriendlyName',Buffer) then
           SearchKeyValue(Key3,KeysInKey3,'DeviceDesc',Buffer);
        DD:=StrPas(Buffer);

        if AnsiUpperCase(ClassString) = AnsiUpperCase(Class_Name) then
        begin

          sLevel4 := sLevel3 + '\LogConf';
          OpenSubKey(HKEY_LOCAL_MACHINE,sLevel4,Key4,SubKeys4,KeysInKey4);

          inc(fDevices);
          fHardwareKeys[fDevices]:=HWID;
          fDeviceDescriptors[fDevices] := DD;


          if SearchKeyValue(Key4,KeysInKey4,'BootConfig',ResList) then
          begin
            for i:=1 to ResList.Count do
            begin
              for j:=1 to ResList.List[i].PartialResourceList.Count do
              begin
                with ResList.List[i].PartialResourceList.PartialDescriptors[j] do
                begin
                  case TypeResource of
                    CmResourceTypePort:
                    begin
                      Inc(fPortCounter);
                      fPortBase[fPortCounter] := PortResource.Start[0];
                      fPortEnd[fPortCounter]  := PortResource.Start[0]+PortResource.Length-1;
                    end;
                    CmResourceTypeInterrupt:
                    begin
                      Inc(fIRQCounter);
                      fIRQNumber[fIRQCounter] := InterruptResource.Vector;
                    end;
                    CmResourceTypeMemory:
                    begin
                      Inc(fMemCounter);
                      fMemBase[fMemCounter] := MemoryResource.Start[0];
                      fMemEnd[fMemCounter]  := MemoryResource.Start[0]+MemoryResource.Length-1;
                    end;
                    CmResourceTypeDMA:
                    begin
                      Inc(fDMACounter);
                      fDMAChannel[fDMACounter] := DMAResource.Channel;
                    end;

                  end; { case }
                end;
              end;
            end;
          end;
        end;
        RegCloseKey(Key3);
      end;
      RegCloseKey(Key2);
    end;
    RegCloseKey(Key1);
  end;
  RegCloseKey(Key0);
  Result := fDevices > 0;
end;
//-------------------------------------------------------
function TVicRes.SearchByHardwareKey_9X(HWK:String) : BOOL;
var s,HWKey,DD    : String;
    MemConfig     : TMem95Config;
    IRQConfig     : TIRQ95Config;
    PortConfig    : TPort95Config;
    DMAConfig     : TDMA95Config;
    achKey                     : array[0..1023] of Char;
    KeysInDynKey,i,SubKeys,nn,KeysInLM  : DWORD;
    hDynKey,hLocDynKey,hLMKey  : HKEY;
    Buffer,LogBuffer           : array[0..1023] of Char;
    BegBuffer                  : DWORD;
    PStatus                    : DWORD;
    TmpMemConfig               : TMem95Config;
begin

  fDevices    := 0;

  fIRQCounter := 0;
  fDMACounter := 0;
  fPortCounter:= 0;
  fMemCounter := 0;

  FillChar(MemConfig,SizeOf(TMem95Config),0);
  FillChar(IRQConfig,SizeOf(TIRQ95Config),0);
  FillChar(DMAConfig,SizeOf(TDMA95Config),0);
  FillChar(PortConfig,SizeOf(TPort95Config),0);

  OpenSubKey(HKEY_DYN_DATA,'Config Manager\Enum',hDynKey,SubKeys,KeysInDynKey);

  i:=0;

  while (i<SubKeys) do
  begin

    RegEnumKey(hDynKey,i,achKey,1024);

    s:='Config Manager\Enum\'+StrPas(achKey);
    OpenSubKey(HKEY_DYN_DATA,s,hLocDynKey,nn,KeysInDynKey);

    FillChar(Buffer,SizeOf(Buffer),0);
    SearchKeyValue(hLocDynKey,KeysInDynKey,'Problem',Buffer);
    Move(Buffer, PStatus, SizeOf(PStatus));

    FillChar(Buffer,SizeOf(Buffer),0);
    SearchKeyValue(hLocDynKey,KeysInDynKey,'HardWareKey',Buffer);
    HWKey:=StrPas(Buffer);

    FillChar(Buffer,SizeOf(LogBuffer),0);
    SearchKeyValue(hLocDynKey,KeysInDynKey,'Allocation',LogBuffer);

    RegCloseKey(hLocDynKey);

    if (AnsiUpperCase(HWK)=AnsiUpperCase(HWKey)) and (PStatus=0) then
    begin

        OpenSubKey(HKEY_LOCAL_MACHINE,'Enum\'+HWKey,hLMKey,nn,KeysInLM);
        if hLMKey<>0 then
        begin
          SearchKeyValue(hLMKey,KeysInLM,'Class',Buffer);
          fClassN:=StrPas(Buffer);
          SearchKeyValue(hLMKey,KeysInLM,'DeviceDesc',Buffer);
          DD:=StrPas(Buffer);
          RegCloseKey(hLMKey);
        end;

        BegBuffer:=8;
        Inc(fDevices);
        fHardwareKeys[fDevices]:=HWKey;
        fDeviceDescriptors[fDevices]:=DD;

        while (Byte(LogBuffer[BegBuffer])>0) do
        begin

          Move(LogBuffer[BegBuffer],TmpMemConfig,8);

          if (TmpMemConfig.TypeRecord=ResType_Mem) and (fMemCounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],MemConfig,SizeOf(TMem95Config));
            with MemConfig do
            begin
              Inc(fMemCounter);
              fMemBase[fMemCounter] := MD_Alloc_Base;
              fMemEnd[fMemCounter]  := MD_Alloc_End;
            end;
          end;

          if (TmpMemConfig.TypeRecord=ResType_IO) and (fPortCounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],PortConfig,SizeOf(TPort95Config));
            with PortConfig do
            begin
              Inc(fPortCounter);
              fPortBase[fPortCounter] := IOD_Alloc_Base;
              fPortEnd[fPortCounter]  := IOD_Alloc_End;
            end;
          end;

          if (TmpMemConfig.TypeRecord=ResType_IRQ) and (fIRQCounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],IRQConfig,SizeOf(TIRQ95Config));
            with IRQConfig do
            begin
              Inc(fIRQCounter);
              fIRQNumber[fIRQCounter] := IRQD_Alloc_Num;
            end;
          end;

          if (TmpMemConfig.TypeRecord=ResType_DMA) and (fDMACounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],DMAConfig,SizeOf(TDMA95Config));
            with DMAConfig do
            begin
              Inc(fDMACounter);
              fDMAChannel[fDMACounter] := DD_Alloc_Chan;
            end;
          end;

          BegBuffer:=BegBuffer+TmpMemConfig.LengthRecord;

        end;

    end;
    Inc(i);
  end;
  RegCloseKey(hDynKey);
  Result := fDevices > 0;

end;
//-------------------------------------------------------
function TVicRes.SearchByHardwareKey_NT(HWK:String) : BOOL;
var sLevel1,sLevel2,sLevel3,sLevel4 : String;
    ClassString,HWID,DD             : String;
    ResList                         : CM_RESOURCE_LIST;
    i,j                             : Byte;
    achKey                                                  : array[0..1023] of Char;
    KeysInKey0,KeysInKey1,KeysInKey2,KeysInKey3,KeysInKey4  : DWORD;
    SubKeys0,  SubKeys1,  SubKeys2,  SubKeys3,  SubKeys4    : DWORD;
    Level0,    Level1,    Level2                            : DWORD;
    Key0,Key1,Key2,Key3,Key4                                : HKEY;
    Buffer                                                  : array[0..1023] of Char;
const sLevel0 : String = 'SYSTEM\CurrentControlSet\Enum';
begin

  fDevices    := 0;

  fIRQCounter := 0;
  fDMACounter := 0;
  fPortCounter:= 0;
  fMemCounter := 0;


  OpenSubKey(HKEY_LOCAL_MACHINE,sLevel0,Key0,SubKeys0,KeysInKey0);

  for Level0:=0 to SubKeys0-1  do
  begin

    RegEnumKey(Key0,Level0,achKey,1024);
    sLevel1:=sLevel0+'\'+StrPas(achKey);
    OpenSubKey(HKEY_LOCAL_MACHINE,sLevel1,Key1,SubKeys1,KeysInKey1);

    for Level1:=0 to SubKeys1-1 do
    begin

      RegEnumKey(Key1,Level1,achKey,1024);
      sLevel2:=sLevel1+'\'+StrPas(achKey);
      OpenSubKey(HKEY_LOCAL_MACHINE,sLevel2,Key2,SubKeys2,KeysInKey2);

      for Level2:=0 to SubKeys2-1 do
      begin

        RegEnumKey(Key2,Level2,achKey,1024);
        sLevel3:=sLevel2+'\'+StrPas(achKey);
        OpenSubKey(HKEY_LOCAL_MACHINE,sLevel3,Key3,SubKeys3,KeysInKey3);

        FillChar(Buffer,SizeOf(Buffer),0);
        SearchKeyValue(Key3,KeysInKey3,'HardwareID',Buffer);
        HWID:=StrPas(Buffer);

        FillChar(Buffer,SizeOf(Buffer),0);
        SearchKeyValue(Key3,KeysInKey3,'Class',Buffer);
        ClassString:=StrPas(Buffer);

        if not SearchKeyValue(Key3,KeysInKey3,'FriendlyName',Buffer) then
        SearchKeyValue(Key3,KeysInKey3,'DeviceDesc',Buffer);
        DD:=StrPas(Buffer);

        if AnsiUpperCase(HWID) = AnsiUpperCase(HWK) then
        begin

          sLevel4 := sLevel3 + '\LogConf';
          OpenSubKey(HKEY_LOCAL_MACHINE,sLevel4,Key4,SubKeys4,KeysInKey4);

          inc(fDevices);
          fHardwareKeys[fDevices]:=HWID;
          fDeviceDescriptors[fDevices]:=DD;
          fClassN:=ClassString;

          if SearchKeyValue(Key4,KeysInKey4,'BootConfig',ResList) then
          begin

            for i:=1 to ResList.Count do
            begin
              for j:=1 to ResList.List[i].PartialResourceList.Count do
              begin
                with ResList.List[i].PartialResourceList.PartialDescriptors[j] do
                begin
                  case TypeResource of
                    CmResourceTypePort:
                    begin
                      Inc(fPortCounter);
                      fPortBase[fPortCounter] := PortResource.Start[0];
                      fPortEnd[fPortCounter]  := PortResource.Start[0]+PortResource.Length-1;
                    end;
                    CmResourceTypeInterrupt:
                    begin
                      Inc(fIRQCounter);
                      fIRQNumber[fIRQCounter] := InterruptResource.Vector;
                    end;
                    CmResourceTypeMemory:
                    begin
                      Inc(fMemCounter);
                      fMemBase[fMemCounter] := MemoryResource.Start[0];
                      fMemEnd[fMemCounter]  := MemoryResource.Start[0]+MemoryResource.Length-1;
                    end;
                    CmResourceTypeDMA:
                    begin
                      Inc(fDMACounter);
                      fDMAChannel[fDMACounter] := DMAResource.Channel;
                    end;

                  end; { case }
                end;
              end;
            end;
          end;
        end;
        RegCloseKey(Key3);
      end;
      RegCloseKey(Key2);
    end;
    RegCloseKey(Key1);
  end;
  RegCloseKey(Key0);
  Result := fDevices > 0;
end;
//-------------------------------------------------------
function TVicRes.SearchByDeviceDescriptor_9X(DD:String) : BOOL;
var s,HWKey       : String;
    MemConfig     : TMem95Config;
    IRQConfig     : TIRQ95Config;
    PortConfig    : TPort95Config;
    DMAConfig     : TDMA95Config;
    achKey                               : array[0..1023] of Char;
    KeysInDynKey,KeysInLM,i,SubKeys,nn   : DWORD;
    hLMKey,hDynKey,hLocDynKey            : HKEY;
    KeyLMValue                           : String;
    Buffer,LogBuffer                     : array[0..1023] of Char;
    BegBuffer                            : DWORD;
    PStatus                              : DWORD;
    TmpMemConfig                         : TMem95Config;
begin

  fDevices    := 0;

  fIRQCounter := 0;
  fDMACounter := 0;
  fPortCounter:= 0;
  fMemCounter := 0;

  FillChar(MemConfig,SizeOf(TMem95Config),0);
  FillChar(IRQConfig,SizeOf(TIRQ95Config),0);
  FillChar(DMAConfig,SizeOf(TDMA95Config),0);
  FillChar(PortConfig,SizeOf(TPort95Config),0);

  OpenSubKey(HKEY_DYN_DATA,'Config Manager\Enum',hDynKey,SubKeys,KeysInDynKey);

  i:=0;

  while (i<SubKeys) do
  begin

    RegEnumKey(hDynKey,i,achKey,1024);

    s:='Config Manager\Enum\'+StrPas(achKey);
    OpenSubKey(HKEY_DYN_DATA,s,hLocDynKey,nn,KeysInDynKey);

    FillChar(Buffer,SizeOf(Buffer),0);
    SearchKeyValue(hLocDynKey,KeysInDynKey,'Problem',Buffer);
    Move(Buffer, PStatus, SizeOf(PStatus));

    FillChar(Buffer,SizeOf(Buffer),0);
    SearchKeyValue(hLocDynKey,KeysInDynKey,'HardWareKey',Buffer);
    HWKey:=StrPas(Buffer);

    FillChar(Buffer,SizeOf(LogBuffer),0);
    SearchKeyValue(hLocDynKey,KeysInDynKey,'Allocation',LogBuffer);

    RegCloseKey(hLocDynKey);

    if HWKey<>'' then
    begin

      OpenSubKey(HKEY_LOCAL_MACHINE,'Enum\'+HWKey,hLMKey,nn,KeysInLM);
      if hLMKey<>0 then
      begin
        SearchKeyValue(hLMKey,KeysInLM,'Class',Buffer);
        fClassN:=StrPas(Buffer);
        SearchKeyValue(hLMKey,KeysInLM,'DeviceDesc',Buffer);
        KeyLMValue:=StrPas(Buffer);
        RegCloseKey(hLMKey);
      end
      else begin
             KeyLMValue:='';
           end;

      if (AnsiUpperCase(KeyLMValue)=AnsiUpperCase(DD)) and (PStatus=0) then
      begin

        BegBuffer:=8;

        if fDevices<MAX_RESOURCE_SIZE then
        begin
          Inc(fDevices);
          fHardwareKeys[fDevices]:=HWKey;
          fDeviceDescriptors[fDevices]:=DD;
        end;

        while (Byte(LogBuffer[BegBuffer])>0) do
        begin

          Move(LogBuffer[BegBuffer],TmpMemConfig,8);

          if (TmpMemConfig.TypeRecord=ResType_Mem) and (fMemCounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],MemConfig,SizeOf(TMem95Config));
            with MemConfig do
            begin
              Inc(fMemCounter);
              fMemBase[fMemCounter] := MD_Alloc_Base;
              fMemEnd[fMemCounter]  := MD_Alloc_End;
            end;
          end;

          if (TmpMemConfig.TypeRecord=ResType_IO) and (fPortCounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],PortConfig,SizeOf(TPort95Config));
            with PortConfig do
            begin
              Inc(fPortCounter);
              fPortBase[fPortCounter] := IOD_Alloc_Base;
              fPortEnd[fPortCounter]  := IOD_Alloc_End;
            end;
          end;

          if (TmpMemConfig.TypeRecord=ResType_IRQ) and (fIRQCounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],IRQConfig,SizeOf(TIRQ95Config));
            with IRQConfig do
            begin
              Inc(fIRQCounter);
              fIRQNumber[fIRQCounter] := IRQD_Alloc_Num;
            end;
          end;

          if (TmpMemConfig.TypeRecord=ResType_DMA) and (fDMACounter<MAX_RESOURCE_SIZE) then
          begin
            Move(LogBuffer[BegBuffer],DMAConfig,SizeOf(TDMA95Config));
            with DMAConfig do
            begin
              Inc(fDMACounter);
              fDMAChannel[fDMACounter] := DD_Alloc_Chan;
            end;
          end;

          BegBuffer:=BegBuffer+TmpMemConfig.LengthRecord;

        end;
      end;
    end;
    Inc(i);
  end;
  RegCloseKey(hDynKey);
  Result := fDevices > 0;
end;
//-------------------------------------------------------
function TVicRes.SearchByDeviceDescriptor_NT(DD:String) : BOOL;
var sLevel1,sLevel2,sLevel3,sLevel4 : String;
    ClassString,HWID,DevDesc        : String;
    ResList                         : CM_RESOURCE_LIST;
    i,j                             : Byte;
    achKey                                                  : array[0..1023] of Char;
    KeysInKey0,KeysInKey1,KeysInKey2,KeysInKey3,KeysInKey4  : DWORD;
    SubKeys0,  SubKeys1,  SubKeys2,  SubKeys3,  SubKeys4    : DWORD;
    Level0,    Level1,    Level2                            : DWORD;
    Key0,Key1,Key2,Key3,Key4                                : HKEY;
    Buffer                                                  : array[0..1023] of Char;
const sLevel0 : String = 'SYSTEM\CurrentControlSet\Enum';
begin

  fDevices    := 0;

  fIRQCounter := 0;
  fDMACounter := 0;
  fPortCounter:= 0;
  fMemCounter := 0;


  OpenSubKey(HKEY_LOCAL_MACHINE,sLevel0,Key0,SubKeys0,KeysInKey0);

  for Level0:=0 to SubKeys0-1  do
  begin

    RegEnumKey(Key0,Level0,achKey,1024);
    sLevel1:=sLevel0+'\'+StrPas(achKey);
    OpenSubKey(HKEY_LOCAL_MACHINE,sLevel1,Key1,SubKeys1,KeysInKey1);

    for Level1:=0 to SubKeys1-1 do
    begin

      RegEnumKey(Key1,Level1,achKey,1024);
      sLevel2:=sLevel1+'\'+StrPas(achKey);
      OpenSubKey(HKEY_LOCAL_MACHINE,sLevel2,Key2,SubKeys2,KeysInKey2);

      for Level2:=0 to SubKeys2-1 do
      begin

        RegEnumKey(Key2,Level2,achKey,1024);
        sLevel3:=sLevel2+'\'+StrPas(achKey);
        OpenSubKey(HKEY_LOCAL_MACHINE,sLevel3,Key3,SubKeys3,KeysInKey3);

        FillChar(Buffer,SizeOf(Buffer),0);
        SearchKeyValue(Key3,KeysInKey3,'HardwareID',Buffer);
        HWID:=StrPas(Buffer);

        FillChar(Buffer,SizeOf(Buffer),0);
        SearchKeyValue(Key3,KeysInKey3,'Class',Buffer);
        ClassString:=StrPas(Buffer);

        if not SearchKeyValue(Key3,KeysInKey3,'FriendlyName',Buffer) then
        SearchKeyValue(Key3,KeysInKey3,'DeviceDesc',Buffer);
        DevDesc:=StrPas(Buffer);

        if AnsiUpperCase(DevDesc) = AnsiUpperCase(DD) then
        begin

          sLevel4 := sLevel3 + '\LogConf';
          OpenSubKey(HKEY_LOCAL_MACHINE,sLevel4,Key4,SubKeys4,KeysInKey4);

          inc(fDevices);
          fHardwareKeys[fDevices]:=HWID;
          fDeviceDescriptors[fDevices]:=DD;
          fClassN:=ClassString;

          if SearchKeyValue(Key4,KeysInKey4,'BootConfig',ResList) then
          begin

            for i:=1 to ResList.Count do
            begin
              for j:=1 to ResList.List[i].PartialResourceList.Count do
              begin
                with ResList.List[i].PartialResourceList.PartialDescriptors[j] do
                begin
                  case TypeResource of
                    CmResourceTypePort:
                    begin
                      Inc(fPortCounter);
                      fPortBase[fPortCounter] := PortResource.Start[0];
                      fPortEnd[fPortCounter]  := PortResource.Start[0]+PortResource.Length-1;
                    end;
                    CmResourceTypeInterrupt:
                    begin
                      Inc(fIRQCounter);
                      fIRQNumber[fIRQCounter] := InterruptResource.Vector;
                    end;
                    CmResourceTypeMemory:
                    begin
                      Inc(fMemCounter);
                      fMemBase[fMemCounter] := MemoryResource.Start[0];
                      fMemEnd[fMemCounter]  := MemoryResource.Start[0]+MemoryResource.Length-1;
                    end;
                    CmResourceTypeDMA:
                    begin
                      Inc(fDMACounter);
                      fDMAChannel[fDMACounter] := DMAResource.Channel;
                    end;

                  end; { case }
                end;
              end;
            end;
          end;
        end;
        RegCloseKey(Key3);
      end;
      RegCloseKey(Key2);
    end;
    RegCloseKey(Key1);
  end;
  RegCloseKey(Key0);
  Result := fDevices > 0;
end;
//-------------------------------------------------------
procedure  TVicRes.GetAllClasses (ClassList: TStrings);
begin
  if fWin95 then GetAllClasses_9X(ClassList)
            else GetAllClasses_NT(ClassList);
end;
//-------------------------------------------------------
procedure   TVicRes.GetAllClasses_9X(ClassList: TStrings);
var s,HWKey,ClassString                : String;
    achKey                             : array[0..1023] of Char;
    KeysInDynKey,KeysInLM,i,SubKeys,nn : DWORD;
    hLMKey,hDynKey,hLocDynKey          : HKEY;
    Buffer                             : array[0..1023] of Char;
begin

  ClassList.Clear;

  OpenSubKey(HKEY_DYN_DATA,'Config Manager\Enum',hDynKey,SubKeys,KeysInDynKey);

  i:=0;

  while (i<SubKeys) do
  begin

    RegEnumKey(hDynKey,i,achKey,1024);

    s:='Config Manager\Enum\'+StrPas(achKey);
    OpenSubKey(HKEY_DYN_DATA,s,hLocDynKey,nn,KeysInDynKey);
    FillChar(Buffer,SizeOf(Buffer),0);
    SearchKeyValue(hLocDynKey,KeysInDynKey,'HardWareKey',Buffer);
    HWKey:=StrPas(Buffer);
    RegCloseKey(hLocDynKey);

    if HWKey<>'' then
    begin
      OpenSubKey(HKEY_LOCAL_MACHINE,'Enum\'+HWKey,hLMKey,nn,KeysInLM);
      if hLMKey<>0 then
      begin
        SearchKeyValue(hLMKey,KeysInLM,'Class',Buffer);
        ClassString:=StrPas(Buffer);
        if (Length(ClassString)>1) and (ClassList.IndexOf(ClassString)=-1) then
           ClassList.Add(ClassString);
        RegCloseKey(hLMKey);
      end;
    end;
    Inc(i);
  end;
  RegCloseKey(hDynKey);
end;
//-------------------------------------------------------
procedure   TVicRes.GetAllClasses_NT(ClassList: TStrings);
var sLevel1,sLevel2,sLevel3         : String;
    ClassString                     : String;
    achKey                                                  : array[0..1023] of Char;
    KeysInKey0,KeysInKey1,KeysInKey2,KeysInKey3             : DWORD;
    SubKeys0,  SubKeys1,  SubKeys2,  SubKeys3               : DWORD;
    Level0,    Level1,    Level2                            : DWORD;
    Key0,Key1,Key2,Key3                                     : HKEY;
    Buffer                                                  : array[0..1023] of Char;
const sLevel0 : String = 'SYSTEM\CurrentControlSet\Enum';
begin

  ClassList.Clear;

  OpenSubKey(HKEY_LOCAL_MACHINE,sLevel0,Key0,SubKeys0,KeysInKey0);

  for Level0:=0 to SubKeys0-1  do
  begin

    RegEnumKey(Key0,Level0,achKey,1024);
    sLevel1:=sLevel0+'\'+StrPas(achKey);
    OpenSubKey(HKEY_LOCAL_MACHINE,sLevel1,Key1,SubKeys1,KeysInKey1);

    for Level1:=0 to SubKeys1-1 do
    begin

      RegEnumKey(Key1,Level1,achKey,1024);
      sLevel2:=sLevel1+'\'+StrPas(achKey);
      OpenSubKey(HKEY_LOCAL_MACHINE,sLevel2,Key2,SubKeys2,KeysInKey2);

      for Level2:=0 to SubKeys2-1 do
      begin

        RegEnumKey(Key2,Level2,achKey,1024);
        sLevel3:=sLevel2+'\'+StrPas(achKey);
        OpenSubKey(HKEY_LOCAL_MACHINE,sLevel3,Key3,SubKeys3,KeysInKey3);

        FillChar(Buffer,SizeOf(Buffer),0);
        SearchKeyValue(Key3,KeysInKey3,'Class',Buffer);
        ClassString:=StrPas(Buffer);

        if (Length(ClassString)>1) and (ClassList.IndexOf(ClassString)=-1) then
           ClassList.Add(ClassString);

        RegCloseKey(Key3);

      end;
      RegCloseKey(Key2);
    end;
    RegCloseKey(Key1);
  end;
  RegCloseKey(Key0);
end;

//-------------------------------------------------------
//---  Not-member procedures  ---------------------------
//-------------------------------------------------------
function Hex2ToInt(s:String):Byte;
var i : Byte;
begin
  Result:=0;
  for i:=0 to 255 do
    if IntToHex(i,2)=s then begin Result:=i; Exit; end;
end;
//-------------------------------------------------------
procedure OpenSubKey(MainKey:HKEY;
                      SubKey:String;
                  var hSubKey:HKEY;
                  var cSubKeys:DWORD;
                  var NumKeys:DWORD);

var
    achClass                                        : array[0..255] of Char;
    cchClassName,cbMaxSubKey                        : DWORD;
    cchMaxClass,cbMaxValueData,cbSecurityDescriptor : DWORD;
    cchMaxValue, Reserv                             : DWORD;
    ftLastWriteTime                                 : tFileTime;
begin
  achClass:='';
  cchClassName:=255;
  SubKey:=SubKey+#0;
  cSubKeys := 0;
  NumKeys  := 0;

  Reserv:= RegOpenKeyEx(
  MainKey,
                        PChar(@SubKey[1]),
                        0,
                        KEY_READ,
                        hSubKey);
  if Reserv = ERROR_SUCCESS then
  begin
    RegQueryInfoKey ( hSubKey,
                    achClass,
                    @cchClassName,
                    NIL,
                    @cSubKeys,
                    @cbMaxSubKey,
                    @cchMaxClass,
                    @NumKeys,
                    @cchMaxValue,
                    @cbMaxValueData,
                    @cbSecurityDescriptor,
                    @ftLastWriteTime);
  end
  else hSubKey:=0;
end;
//-------------------------------------------------------
function SearchKeyValue(hSubKey:HKEY;
                        NumKeys:Word;
                        KeyName:String;
                    var OutBuffer
                         ):Boolean;
var
    retValue,type_key,LBuf,cchMaxValue : DWORD;
    achValue                           : array[0..511] of Char;
    n                                  : Word;
    s                                  : String;
begin
  Result:=FALSE;
  if NumKeys>0 then
  for n:=0 to NumKeys-1 do
  begin
    cchMaxValue:=512;LBuf:=512;  Result:=FALSE;

    retValue:=RegEnumValue(hSubKey,n,achValue,cchMaxValue,NIL,
                              @type_key,@OutBuffer,@LBuf);
    if (retValue=ERROR_SUCCESS) then
    begin
      s:=StrPas(achValue);
      if s=KeyName then
      begin
        Result:=TRUE; Exit;
      end;
    end;
  end;
end;


end.
