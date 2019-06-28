{
  One more of this crazy profile-units :-)

  This unit uses a local ini-File. (the ini has the same path and name
  like the exe) Supports all necessary data-types (e.g. string and PChar too),
  and creates a new entry with the default value, if the requested entry
  is not present or damaged.
  Installable as component.

  It's Freeware by Matthias Weingart, 7 Aug 95
  Comments are welcome: matthias@penthouse.boerde.de
}
unit Ini;

interface

uses
  SysUtils, WinProcs, Classes, WinTypes, Messages, Graphics, Controls, Forms;

type
  TIni = class(TComponent)
  private
    szFileName: array[0..255] of char;
  public
    constructor Create(AOwner: TComponent); override;
    function  FileName: string;
    procedure SetStr(const Section, Entry: PChar; Value: PChar);
    function  GetStr(const Section, Entry: PChar; Default, Value: PChar; SizeValue: Word): PChar;
    procedure SetString(const Section, Entry: PChar; Value: string);
    function  GetString(const Section, Entry: PChar; Default: string): string;
    procedure SetInteger(const Section, Entry: PChar; Value: LongInt);
    function  GetInteger(const Section, Entry: PChar; Default: LongInt): LongInt;
    procedure SetBoolean(const Section, Entry: PChar; Value: boolean);
    function  GetBoolean(const Section, Entry: PChar; Default: boolean): boolean;
    procedure SetFloat(const Section, Entry: PChar; Value: Extended);
    function  GetFloat(const Section, Entry: PChar; Default: Extended): Extended;
  published
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Add', [TIni]);
end;

function StrToBool(strVal: string; var ret: boolean): boolean;
begin { returns false on invalid entry}
  if (UpperCase(strVal) = 'TRUE') or (UpperCase(strVal) = 'YES') or (UpperCase(strVal) = 'ON') or (strVal = '1') then
  begin
    ret := True;
    Result:= True;
  end
  else
    if (UpperCase(strVal) = 'FALSE') or (UpperCase(strVal) = 'NO') or (UpperCase(strVal) = 'OFF') or (strVal = '0') then
    begin
       ret := False;
       Result:= True;
    end
    else
       Result := False;
end;

function BoolToStr(bVal: boolean): string;
begin
  if bVal then
    Result := 'True'
  else
    Result := 'False';
end;

constructor TIni.Create(AOwner: TComponent);
var
  Path: PChar;
begin
  inherited Create(AOwner);
  Path:=StrAlloc( 256 );
  try
     StrPCopy( szFileName, ChangeFileExt(Application.ExeName, '.INI') );
  finally
     StrDispose(Path);
  end;
end;

function TIni.FileName: string;
begin
   FileName := StrPas(szFileName);
end;

procedure TIni.SetStr(const Section, Entry: PChar; Value: PChar);
begin
      WritePrivateProfileString(Section, Entry, Value, szFileName);
end;

function TIni.GetStr(const Section, Entry: PChar; Default, Value: PChar; SizeValue: Word): PChar;
var
  iTemp: PChar;
begin
    iTemp := StrAlloc(256);
    try
      if 0=GetPrivateProfileString(Section, Entry, '', iTemp, 256, szFileName) then
      begin  { on emtpy String write default }
           WritePrivateProfileString(Section, Entry, Default, szFileName);
           StrCopy( iTemp, Default);
      end;
      StrLCopy( Value, iTemp, SizeValue );
    finally
      StrDispose(iTemp);
      Result := Value;
    end;
end;

procedure TIni.SetString(const Section, Entry: PChar; Value: string);
var
  iValue: PChar;
begin
    iValue := StrAlloc(256);
    try
      StrPCopy(iValue, Value);
      SetStr(Section, Entry, iValue);
    finally
      StrDispose(iValue);
    end;
end;

function TIni.GetString(const Section, Entry: PChar; Default: string): string;
var
  iValue, iDefault: PChar;
begin
    iValue := StrAlloc(256);
    iDefault := StrAlloc(256);
    try
      StrPCopy(iDefault, Default);
      GetStr(Section, Entry, iDefault, iValue, 256);
      GetString := StrPas( iValue );
    finally
      StrDispose(iDefault);
      StrDispose(iValue);
    end;
end;

procedure TIni.SetInteger(const Section, Entry: PChar; Value: LongInt);
var
  iValue: PChar;
begin
    iValue := StrAlloc(256);
    try
      StrPCopy(iValue, IntToStr(Value) );
      SetStr(Section, Entry, iValue);
    finally
      StrDispose(iValue);
    end;
end;

function TIni.GetInteger(const Section, Entry: PChar; Default: LongInt): LongInt;
var
  iValue, iDefault: PChar;
begin
    iValue := StrAlloc(256);
    iDefault := StrAlloc(256);
    try
      StrPCopy(iDefault, IntToStr(Default) );
      GetStr(Section, Entry, iDefault, iValue, 256);
      try
         GetInteger := StrToInt( StrPas(iValue) );
      except
         on EConvertError do begin
            GetInteger := Default;
            SetStr(Section, Entry, iDefault); { correct bad entry }
         end;
      end;
    finally
      StrDispose(iDefault);
      StrDispose(iValue);
    end;
end;

procedure TIni.SetBoolean(const Section, Entry: PChar; Value: boolean);
var
  iValue: PChar;
begin
    iValue := StrAlloc(256);
    try
      StrPCopy(iValue, BoolToStr(Value) );
      SetStr(Section, Entry, iValue);
    finally
      StrDispose(iValue);
    end;
end;

function TIni.GetBoolean(const Section, Entry: PChar; Default: boolean): boolean;
var
  iValue, iDefault: PChar;
  b: boolean;
begin
    iValue := StrAlloc(256);
    iDefault := StrAlloc(256);
    try
      StrPCopy(iDefault, BoolToStr(Default) );
      GetStr(Section, Entry, iDefault, iValue, 256);
      if StrToBool( StrPas(iValue), b ) then
         GetBoolean := b
      else begin
         GetBoolean := Default;
         SetStr(Section, Entry, iDefault); { correct bad entry }
      end;
    finally
      StrDispose(iDefault);
      StrDispose(iValue);
    end;
end;

procedure TIni.SetFloat(const Section, Entry: PChar; Value: Extended);
var
  iValue: PChar;
begin
    iValue := StrAlloc(256);
    try
      StrPCopy(iValue, FloatToStr(Value) );
      SetStr(Section, Entry, iValue);
    finally
      StrDispose(iValue);
    end;
end;

function TIni.GetFloat(const Section, Entry: PChar; Default: Extended): Extended;
var
  iValue, iDefault: PChar;
  Value: Extended;
begin
    iValue := StrAlloc(256);
    iDefault := StrAlloc(256);
    try
      StrPCopy(iDefault, FloatToStr(Default) );
      GetStr(Section, Entry, iDefault, iValue, 256);
      if TextToFloat( iValue, Value, fvExtended ) then
         GetFloat := Value
      else begin
         GetFloat := Default;
         SetStr(Section, Entry, iDefault); { correct bad entry }
      end;
    finally
      StrDispose(iDefault);
      StrDispose(iValue);
    end;
end;

end.

