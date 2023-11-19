unit ah_tool;
{ Copyright 1995-200 Andreas Hörstemeier            Version 1.1 2001-06-04   }
{ this utility functions are public domain. They are used by several of my   }
{ components. In case you have several version of this file always use the   }
{ latest one. Please check the file readme.txt of the component you found    }
{ this file at for more detailed info on usage and distributing.             }
(*@/// interface *)
interface

(*$b- *)
  (*$i ah_def.inc *)

uses
(*$ifdef delphi_1 *)
  winprocs,
  wintypes,
(*$else *)
  windows,
(*$endif *)
  messages,
  sysutils,
  classes,
  controls,
  forms;

(*@/// String utility functions *)
{ Find n'th occurence of a substring, from left or from right }
function posn(const s,t:string; count:integer):integer;

{ Find the n'th char unequal from left or from right }
function poscn(c:char; const s:string; n: integer):integer;

{ Exchange all occurances of a string by another (e.g. ,->.) }
function exchange_s(const prior,after: string; const s:string):string;

{ Delphi 1 didn't know these, but they are useful/necessary for D2/D3 }
(*$ifdef delphi_1 *)
function trim(const s:string):string;
procedure setlength(var s:string; l: byte);
(*$endif *)

{ Write a string into a stream }
procedure String2Stream(stream:TMemorystream; const s:string);
(*@\\\0000001101*)

{ The offset to UTC/GMT in minutes of the local time zone }
function TimeZoneBias:longint;

{ Convert a string to HTML - currently only for latin 1 }
function text2html(const s:string):string;

{ Why are these not in the language itself? }
function min(x,y: longint):longint;
function max(x,y: longint):longint;

(*@/// Create a windows HWnd avoiding the stuff from forms *)
type
  TWndProc = procedure (var Message: TMessage) of object;

function AH_AllocateHWnd(Method: TWndProc): HWND;
procedure AH_DeallocateHWnd(Wnd: HWND);
(*@\\\*)

(*@/// The routines to make the applications events use a list of methods *)
(*$ifndef delphi_ge_3 *)
procedure AddShowHintProc(proc:TShowHintEvent);
procedure RemoveShowHintProc(proc:TShowHintEvent);
(*$endif *)
procedure AddIdleProc(proc:TIdleEvent);
procedure RemoveIdleProc(proc:TIdleEvent);
(*@\\\*)

(*@/// Make Stream and Clipboard work together *)
procedure Stream2Clipboard(stream:TStream; format:integer);
procedure Clipboard2Stream(stream:TStream; format:integer);
(*@\\\*)

(*@/// Windows Resources and Languages *)
(*$ifdef delphi_gt_1 *)
function LoadStrEx(id:word; languageid: word):string;
(*$endif *)
function LoadStr(id:word):string;
(*@\\\*)

function ScrollBarVisible(control: TWinControl; vertical: boolean):boolean;
(*@\\\0000002501*)
(*@/// implementation *)
implementation

(*@/// Some string utility functions *)
(*@/// function posn(const s,t:string; count:integer):integer; *)
function posn(const s,t:string; count:integer):integer;

{ find the count'th occurence of the substring,
  if count<0 then look from the back }

var
  i,h,last: integer;
  u: string;
begin
  u:=t;
  if count>0 then begin
    result:=length(t);
    for i:=1 to count do begin
      h:=pos(s,u);
      if h>0 then
        u:=copy(u,pos(s,u)+1,length(u))
      else begin
        u:='';
        inc(result);
        end;
      end;
    result:=result-length(u);
    end
  else if count<0 then begin
    last:=0;
    for i:=length(t) downto 1 do begin
      u:=copy(t,i,length(t));
      h:=pos(s,u);
      if (h<>0) and (h+i<>last) then begin
        last:=h+i-1;
        inc(count);
        if count=0 then BREAK;
        end;
      end;
    if count=0 then result:=last
               else result:=0;
    end
  else
    result:=0;
  end;
(*@\\\*)
(*@/// function exchange_s(const prior,after: string; const s:string):string; *)
function exchange_s(const prior,after: string; const s:string):string;
var
  h,p: integer;
begin
  result:=s;
  p:=length(prior);
  while true do begin
    h:=pos(prior,result);
    if h=0 then BREAK;
    result:=copy(result,1,h-1)+after+copy(result,h+p,length(result));
    end;
  end;
(*@\\\*)
(*@/// function poscn(c:char; const s:string; n: integer):integer; *)
function poscn(c:char; const s:string; n: integer):integer;

{ Find the n'th occurence of a character different to c,
  if n<0 look from the back }

var
  i: integer;
begin
  if n=0 then  n:=1;
  if n>0 then begin
    for i:=1 to length(s) do begin
      if s[i]<>c then begin
        dec(n);
        result:=i;
        if n=0 then begin
          EXIT;
          end;
        end;
      end;
    end
  else begin
    for i:=length(s) downto 1 do begin
      if s[i]<>c then begin
        inc(n);
        result:=i;
        if n=0 then begin
          EXIT;
          end;
        end;
      end;
    end;
  poscn:=0;
  end;
(*@\\\*)
(*@/// function filename_of(const s:string):string; *)
function filename_of(const s:string):string;
var
  t:integer;
begin
  t:=posn('\',s,-1);
  if t>0 then
    result:=copy(s,t+1,length(s))
  else begin
    t:=posn(':',s,-1);
    if t>0 then
      result:=copy(s,t+1,length(s))
    else
      result:=s;
    end;
  end;
(*@\\\*)
(*$ifdef delphi_1 *)
(*@/// function trim(const s:string):string; *)
function trim(const s:string):string;
var
  h: integer;
begin
  (* trim from left *)
  h:=poscn(' ',s,1);
  if h>0 then
    result:=copy(s,h,length(s))
  else
    result:=s;
  (* trim from right *)
  h:=poscn(' ',result,-1);
  if h>0 then
    result:=copy(result,1,h);
  end;
(*@\\\*)
(*@/// procedure setlength(var s:string; l: byte); *)
procedure setlength(var s:string; l: byte);
begin
  s[0]:=char(l);
  end;
(*@\\\*)
(*$endif *)
(*@/// procedure String2Stream(stream:TMemorystream; const s:string); *)
procedure String2Stream(stream:TMemorystream; const s:string);
begin
  stream.write(s[1],length(s));
  end;
(*@\\\*)
(*@\\\*)

(*@/// function min(x,y: longint):longint; *)
function min(x,y: longint):longint;
begin
  if x<y then result:=x
         else result:=y;
  end;
(*@\\\*)
(*@/// function max(x,y: longint):longint; *)
function max(x,y: longint):longint;
begin
  if x>y then result:=x
         else result:=y;
  end;
(*@\\\*)

(*@/// function TimeZoneBias:longint;          // in minutes ! *)
function TimeZoneBias:longint;
(*@/// 16 bit way: try a 32bit API call via thunking layer, if that fails try the TZ *)
(*$ifdef delphi_1 *)
(*@/// function GetEnvVar(const s:string):string; *)
function GetEnvVar(const s:string):string;
var
  L: Word;
  P: PChar;
begin
  L := length(s);
  P := GetDosEnvironment;
  while P^ <> #0 do begin
    if (StrLIComp(P, PChar(@s[1]), L) = 0) and (P[L] = '=') then begin
      GetEnvVar := StrPas(P + L + 1);
      EXIT;
      end;
    Inc(P, StrLen(P) + 1);
    end;
  GetEnvVar := '';
  end;
(*@\\\*)

(*@/// function day_in_month(month,year,weekday: word; count: integer):TDateTime; *)
function day_in_month(month,year,weekday: word; count: integer):TDateTime;
var
  h: integer;
begin
  if count>0 then begin
    h:=dayofweek(encodedate(year,month,1));
    h:=((weekday-h+7) mod 7) +1 + (count-1)*7;
    result:=encodedate(year,month,h);
    end
  else begin
    h:=dayofweek(encodedate(year,month,1));
    h:=((weekday-h+7) mod 7) +1 + 6*7;
    while count<0 do begin
      h:=h-7;
      try
        result:=encodedate(year,month,h);
        inc(count);
        if count=0 then EXIT;
      except
        end;
      end;
    end;
  end;
(*@\\\*)
(*@/// function DayLight_Start:TDateTime;     // american way ! *)
function DayLight_Start:TDateTime;
var
  y,m,d: word;
begin
  DecodeDate(now,y,m,d);
  result:=day_in_month(4,y,1,1);
  (* for european one: day_in_month(3,y,1,-1) *)
  end;
(*@\\\*)
(*@/// function DayLight_End:TDateTime;       // american way ! *)
function DayLight_End:TDateTime;
var
  y,m,d: word;
begin
  DecodeDate(now,y,m,d);
  result:=day_in_month(10,y,1,-1);
  end;
(*@\\\*)
type    (* stolen from windows.pas *)
  (*@/// TSystemTime = record ... end; *)
  PSystemTime = ^TSystemTime;
  TSystemTime = record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliseconds: Word;
  end;
  (*@\\\*)
  (*@/// TTimeZoneInformation = record ... end; *)
  TTimeZoneInformation = record
    Bias: Longint;
    StandardName: array[0..31] of word;  (* wchar *)
    StandardDate: TSystemTime;
    StandardBias: Longint;
    DaylightName: array[0..31] of word;  (* wchar *)
    DaylightDate: TSystemTime;
    DaylightBias: Longint;
    end;
  (*@\\\*)
var
  tz_info: TTimeZoneInformation;
  LL32:function (LibFileName: PChar; handle: longint; special: longint):Longint;
  FL32:function (hDll: Longint):boolean;
  GA32:function (hDll: Longint; functionname: PChar):longint;
  CP32:function (buffer:TTimeZoneInformation; prochandle,adressconvert,dwParams:Longint):longint;
  hdll32,dummy,farproc: longint;
  hdll:THandle;
  sign: integer;
  s: string;
begin
  hDll:=GetModuleHandle('kernel');                  { get the 16bit handle of kernel }
  @LL32:=GetProcAddress(hdll,'LoadLibraryEx32W');   { get the thunking layer functions }
  @FL32:=GetProcAddress(hdll,'FreeLibrary32W');
  @GA32:=GetProcAddress(hdll,'GetProcAddress32W');
  @CP32:=GetProcAddress(hdll,'CallProc32W');
  (*@/// if possible then   call GetTimeZoneInformation via Thunking *)
  if (@LL32<>NIL) and
     (@FL32<>NIL) and
     (@GA32<>NIL) and
     (@CP32<>NIL) then begin
    hDll32:=LL32('kernel32.dll',dummy,1);            { get the 32bit handle of kernel32 }
    farproc:=GA32(hDll32,'GetTimeZoneInformation');  { get the 32bit adress of the function }
    case CP32(tz_info,farproc,1,1) of                { and call it }
      1: result:=tz_info.StandardBias+tz_info.Bias;
      2: result:=tz_info.DaylightBias+tz_info.Bias;
      else result:=0;
      end;
    FL32(hDll32);                                    { and free the 32bit dll }
    end
  (*@\\\*)
  (*@/// else  calculate the bias out of the TZ environment variable *)
  else begin
    s:=GetEnvVar('TZ');
    while (length(s)>0) and (not(s[1] in ['+','-','0'..'9'])) do
      s:=copy(s,2,length(s));
    case s[1] of
      (*@/// '+': *)
      '+': begin
        sign:=1;
        s:=copy(s,2,length(s));
        end;
      (*@\\\*)
      (*@/// '-': *)
      '-': begin
        sign:=-1;
        s:=copy(s,2,length(s));
        end;
      (*@\\\*)
      else sign:=1;
      end;
    try
      result:=strtoint(copy(s,1,2))*60;
      s:=copy(s,3,length(s));
    except
      try
        result:=strtoint(s[1])*60;
        s:=copy(s,2,length(s));
      except
        result:=0;
        end;
      end;
    (*@/// if s[1]=':' then    minutes offset *)
    if s[1]=':' then begin
      try
        result:=result+strtoint(copy(s,2,2));
        s:=copy(s,4,length(s));
      except
        try
          result:=result+strtoint(s[2]);
          s:=copy(s,3,length(s));
        except
          end;
        end;
      end;
    (*@\\\*)
    (*@/// if s[1]=':' then    seconds offset - ignored *)
    if s[1]=':' then begin
      try
        strtoint(copy(s,2,2));
        s:=copy(s,4,length(s));
      except
        try
          strtoint(s[2]);
          s:=copy(s,3,length(s));
        except
          end;
        end;
      end;
    (*@\\\*)
    result:=result*sign;
    (*@/// if length(s)>0 then daylight saving activated, calculate it *)
    if length(s)>0 then begin
      (* forget about the few hours on the start/end day *)
      if (now>daylight_start) and (now<DayLight_End+1) then
        result:=result-60;
      end;
    (*@\\\*)
    end;
  (*@\\\*)
  end;
(*@\\\0000001C01*)
(*@/// 32 bit way: API call GetTimeZoneInformation *)
(*$else *)
var
  tz_info: TTimeZoneInformation;
begin
  case GetTimeZoneInformation(tz_info) of
    1: result:=tz_info.StandardBias+tz_info.Bias;
    2: result:=tz_info.DaylightBias+tz_info.Bias;
    else result:=0;
    end;
  end;
(*$endif *)
(*@\\\*)
(*@\\\0000000301*)

(*@/// function text2html(const s:string):string; *)
function text2html(const s:string):string;
var
  i: integer;
  t: string;
begin
  result:='';
  for i:=1 to length(s) do begin
    case s[i] of
      (*@/// iso latin 1 *)
      (*$ifdef iso_latin1 *)
            '&' : t:='&amp;';
            '<' : t:='&lt;';
            '>' : t:='&gt;';
            #160: t:='&nbsp;';
            '¡' : t:='&iexcl;';
            '¢' : t:='&cent;';
            '£' : t:='&pound;';
            '¤' : t:='&curren;';   (* &euro; ??? *)
            '¥' : t:='&yen;';
            '¦' : t:='&brvbar;';
            '§' : t:='&sect;';
            '¨' : t:='&uml;';
            '©' : t:='&copy;';
            'ª' : t:='&ordf;';
            '«' : t:='&laquo;';
            '¬' : t:='&not;';
            '­' : t:='&shy;';
            '®' : t:='&reg;';
            '¯' : t:='&macr;';
            '°' : t:='&deg;';
            '±' : t:='&plusmn;';
            '²' : t:='&sup2;';
            '³' : t:='&sup3;';
            '´' : t:='&acute;';
            'µ' : t:='&micro;';
            '¶' : t:='&para;';
            '·' : t:='&middot;';
            '¸' : t:='&cedille;';
            '¹' : t:='&sup1;';
            'º' : t:='&ordm;';
            '»' : t:='&raquo;';
            '¼' : t:='&frac14;';
            '½' : t:='&frac12;';
            '¾' : t:='&frac34;';
            '¿' : t:='&iquest;';
            'À' : t:='&Agrave;';
            'Á' : t:='&Aacute;';
            'Â' : t:='&Acirc;';
            'Ã' : t:='&Atilde;';
            'Ä' : t:='&Auml;';
            'Å' : t:='&Aring;';
            'Æ' : t:='&AElig;';
            'Ç' : t:='&Ccedil;';
            'È' : t:='&Egrave;';
            'É' : t:='&Eacute;';
            'Ê' : t:='&Ecirc;';
            'Ë' : t:='&Euml;';
            'Ì' : t:='&Igrave;';
            'Í' : t:='&Iacute;';
            'Î' : t:='&Icirc;';
            'Ï' : t:='&Iuml;';
            'Ð' : t:='&ETH;';
            'Ñ' : t:='&Ntilde;';
            'Ò' : t:='&Ograve;';
            'Ó' : t:='&Oacute;';
            'Ô' : t:='&Ocirc;';
            'Õ' : t:='&Otilde;';
            'Ö' : t:='&Ouml;';
            '×' : t:='&times;';
            'Ø' : t:='&Oslash;';
            'Ù' : t:='&Ugrave;';
            'Ú' : t:='&Uacute;';
            'Û' : t:='&Ucirc;';
            'Ü' : t:='&Uuml;';
            'Ý' : t:='&Yacute;';
            'Þ' : t:='&THORN;';
            'ß' : t:='&szlig;';
            'à' : t:='&agrave;';
            'á' : t:='&aacute;';
            'â' : t:='&acirc;';
            'ã' : t:='&atilde;';
            'ä' : t:='&auml;';
            'å' : t:='&aring;';
            'æ' : t:='&aelig;';
            'ç' : t:='&ccedil;';
            'è' : t:='&egrave;';
            'é' : t:='&eacute;';
            'ê' : t:='&ecirc;';
            'ë' : t:='&euml;';
            'ì' : t:='&igrave;';
            'í' : t:='&iacute;';
            'î' : t:='&icirc;';
            'ï' : t:='&iuml;';
            'ð' : t:='&eth;';
            'ñ' : t:='&ntilde;';
            'ò' : t:='&ograve;';
            'ó' : t:='&oacute;';
            'ô' : t:='&ocirc;';
            'õ' : t:='&otilde;';
            'ö' : t:='&ouml;';
            '÷' : t:='&divide;';
            'ø' : t:='&oslash;';
            'ù' : t:='&ugrave;';
            'ú' : t:='&uacute;';
            'û' : t:='&ucirc;';
            'ü' : t:='&uuml;';
            'ý' : t:='&yacute;';
            'þ' : t:='&thorn;';
            #255: t:='&yuml;';
      (*$endif *)
      (*@\\\000000650C*)
      else  t:=s[i];
      end;
    result:=result+t;
    end;
  end;
(*@\\\*)

(*@/// To have OnShowHint/OnIdle lists instead of single methods *)
{ These are just a few help tools for the Application.OnShowHint and      }
{ Application.OnIdle methods - Borland didn't thought of the need to      }
{ put more than one method in these places, so I had to do it myself.     }
{ At least there's a way to avoid this stuff with Delphi 2/3 with         }
{ the cm_hintshow message which is sent just before the OnSHowHint event, }
{ but as this stuff should work with any version of Delphi I stay with    }
{ the event list...                                                       }
{ Some nice internals how to work with method pointer are presented here. }

(*@/// TObjectList = class(TList)       // A list which frees it's objects *)
type
  TObjectList = class(TList)
  public
    destructor Destroy; override;

{ Why hasn't Borland made the delete method virtual??? Now I must create      }
{ a new virtual slot with all the problems this may cause just because        }
{ of a missing word... - first cause is the remove method which is absolutely }
{ the same as in TList, but as Delete isn't virtual I need it here again.     }

{ I you want to use this component anywhere else be VERY careful, any call    }
{ as a TList may cause problems                                               }

    procedure Delete(Index:Integer);  virtual;
    function Remove(Item:Pointer):Integer; virtual;
    end;

{ TObjectList }
(*@/// destructor TObjectList.Destroy; *)
destructor TObjectList.Destroy;
var
  i: integer;
begin
  for i:=count-1 downto 0 do
    TObject(items[i]).Free;
  inherited destroy;
  Clear;
end;
(*@\\\*)
(*@/// procedure TObjectList.Delete(Index:Integer); *)
procedure TObjectList.Delete(Index:Integer);
begin
  TObject(items[index]).Free;
  inherited delete(index);
  end;
(*@\\\*)
(*@/// function TObjectList.Remove(Item:Pointer):Integer; *)
function TObjectList.Remove(Item:Pointer):Integer;
begin
  Result := IndexOf(Item);
  if Result <> -1 then Delete(Result);
  end;
(*@\\\*)
(*@\\\*)

type
  TMethodPointer = procedure of object;
  (*@/// TMethod = class(TObject)       // Object with just one methodpointer *)
  TMethod = class(TObject)
  public
    methodpointer: TMethodPointer;
    end;
  (*@\\\*)

const
(*$ifndef delphi_ge_3 *)
  ShowHintProcs: TObjectList =NIL;
(*$endif *)
  IdleProcs: TObjectList     =NIL;

(*@/// TDummyObject = class(TObject)    // A dummy object for the Application events *)
{ TDummyObject }

{ A little dummy object which provides the methods to be put in the     }
{ application's method pointers; if you use this you shouldn't access   }
{ Application.OnIdle and Application.OnShowHint directly but always use }
{ the Add/RemoveXXXProc routines                                        }
{ You can add any other Application.OnXXX method here if you need it    }

type
  TDummyObject=class(TObject)
(*$ifndef delphi_ge_3 *)
(*$ifdef shortstring *)
  procedure ShowHint(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo);
(*$else *)
  procedure ShowHint(var HintStr: ansistring; var CanShow: Boolean; var HintInfo: THintInfo);
(*$endif *)
(*$endif *)
  procedure DoIdle(sender: TObject; var done:Boolean);
  end;
(*$ifndef delphi_ge_3 *)
(*@/// procedure TDummyObject.ShowHint(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo); *)

(*$ifdef shortstring *)
procedure TDummyObject.ShowHint(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo);
(*$else *)
procedure TDummyObject.ShowHint(var HintStr: ansistring; var CanShow: Boolean; var HintInfo: THintInfo);
(*$endif *)
var
  i:integer;
begin
  for i:=ShowHintProcs.Count-1 downto 0 do
    if ShowHintProcs.Items[i]<>NIL then begin
      TShowHintEvent(TMethod(ShowHintProcs.Items[i]).methodpointer)(HintStr,CanShow,HintInfo);
      end;
  end;
(*@\\\*)
(*$endif *)
(*@/// procedure TDummyObject.DoIdle(sender: TObject; var done:Boolean); *)
procedure TDummyObject.DoIdle(sender: TObject; var done:Boolean);
var
  i:integer;
  temp_done: boolean;
begin
  done:=false;
  for i:=IdleProcs.Count-1 downto 0 do
    if IdleProcs.Items[i]<>NIL then begin
      TIdleEvent(TMethod(IdleProcs.Items[i]).methodpointer)(sender, temp_done);
      done:=done and temp_done;   (* done when all idle procs say done *)
      end;
  end;
(*@\\\*)
(*@\\\0000000301*)

const
  Dummy: TDummyObject        =NIL;

(*@/// Compare two method pointers *)
function compare_method(proc1,proc2:TMethodpointer):boolean;

{ A method pointer is just a record of two pointers, one the procedure }
{ pointer itself, then the self pointer which is pushed as the first   }
{ parameter of the procedure                                           }

type
  (*@/// T_Method=packed record *)
  T_Method=packed record
    proc: Pointer;
    self: TObject;
    end;
  (*@\\\*)
begin
  result:=(T_Method(proc1).proc=T_Method(proc2).proc) and
          (T_Method(proc1).self=T_Method(proc2).self);
  end;
(*@\\\*)
(*@/// Include and remove the Methodpointer from the according lists *)
(*$ifndef delphi_ge_3 *)
(*@/// procedure AddShowHintProc(proc:TShowHintEvent); *)
procedure AddShowHintProc(proc:TShowHintEvent);
var
  method: TMethod;
begin
  if (dummy=NIL) or (showhintprocs=NIL) then exit;
  method:=TMethod.Create;
  method.methodpointer:=TMethodPointer(proc);
  showhintprocs.add(method);
  Application.OnShowHint:=dummy.ShowHint;
  end;
(*@\\\0000000501*)
(*@/// procedure RemoveShowHintProc(proc:TShowHintEvent); *)
procedure RemoveShowHintProc(proc:TShowHintEvent);
var
  i: integer;
begin
  if (dummy=NIL) or (showhintprocs=NIL) then exit;
  for i:=showhintprocs.count-1 downto 0 do
    if (showhintprocs.items[i]<>NIL) and
       compare_method(TMethod(showhintprocs.items[i]).methodpointer,
                      TMethodpointer(proc))  then
      showhintprocs.delete(i);
  end;
(*@\\\*)
(*$endif *)
(*@/// procedure AddIdleProc(proc:TIdleEvent); *)
procedure AddIdleProc(proc:TIdleEvent);
var
  method: TMethod;
begin
  if (dummy=NIL) or (idleprocs=NIL) then exit;
  method:=TMethod.Create;
  method.methodpointer:=TMethodPointer(proc);
  idleprocs.add(method);
  Application.OnIdle:=dummy.DoIdle;
  end;
(*@\\\*)
(*@/// procedure RemoveIdleProc(proc:TIdleEvent); *)
procedure RemoveIdleProc(proc:TIdleEvent);
var
  i: integer;
begin
  if (dummy=NIL) or (idleprocs=NIL) then exit;
  for i:=idleprocs.count-1 downto 0 do
    if (idleprocs.items[i]<>NIL) and
       compare_method(TMethod(idleprocs.items[i]).methodpointer,
                      TMethodpointer(proc))  then
      idleprocs.delete(i);
  end;
(*@\\\*)
(*@\\\000000062B*)
(*@\\\*)
(*@/// Generating HWnd's without the routines in forms *)
{ Creating a new HWnd with a WndProc for an arbitrary class. Just the same   }
{ as the routines in forms, but without the assembler stuff and using simple }
{ TList's for the storage - maybe not as fast the original routines, but     }
{ much easier to understand and to use. This is only for fun here as the     }
{ routines in forms do absolutely the same, but this stuff may be used to    }
{ create an console application without using forms but receiving Windows    }
{ messages.                                                                  }

const
  (*@/// UtilWindowClass: TWndClass = (...); *)
  UtilWindowClass: TWndClass = (
    style: 0;
    lpfnWndProc: @DefWindowProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'TAHUtilWindow');
  (*@\\\*)
  WndProcs: TObjectList =NIL;
  WndWnds: TList        =NIL;

{ Converts a Windows WndProc (HWnd as parameter) to a Delphi method with }
{ self as implicit first parameter by looking up the HWnd in the List    }
(*@/// function AH_StdWndProc(Window: HWND; Message,WParam,LParam: Word/Longint); *)
(*$ifdef delphi_1 *)
function AH_StdWndProc(Window: HWND; Message: Longint; WParam: Word;
  LParam: Longint): Longint; export;
(*$else *)
function AH_StdWndProc(Window: HWND; Message: Word; WParam: Longint;
  LParam: Longint): Longint; stdcall;
(*$endif *)
var
  p: integer;
  m: TMessage;
begin
  m.msg:=message;
  m.wparam:=wparam;
  m.lparam:=lparam;
  m.result:=0;
  p:=wndwnds.indexof(pointer(window));
  if p>=0 then
    TWndProc(TMethod(wndprocs.Items[p]).methodpointer)(m);
  result:=m.result;
  end;
(*@\\\0000000112*)
{ Creates a new HWnd and link it with the given Method }
(*@/// function AH_AllocateHWnd(Method: TWndProc): HWND; *)
function AH_AllocateHWnd(Method: TWndProc): HWND;
var
  tempmethod: TMethod;
  TempClass: TWndClass;
begin
  result:=0;
  if (wndprocs=NIL) then exit;

  UtilWindowClass.hInstance := HInstance;
  if not GetClassInfo(HInstance, UtilWindowClass.lpszClassName, TempClass) then
(*$ifdef delphi_1 *)
    WinProcs.RegisterClass(UtilWindowClass);
(*$else *)
    Windows.RegisterClass(UtilWindowClass);
(*$endif *)
  Result := CreateWindow(UtilWindowClass.lpszClassName, '', 0,
    0, 0, 0, 0, 0, 0, HInstance, nil);

  tempmethod:=TMethod.Create;
  tempmethod.methodpointer:=TMethodPointer(method);

  { These two lists must be absolutely parallel, otherwise the messages may }
  { go to the wrong object                                                  }
  wndprocs.add(tempmethod);
  wndwnds.add(pointer(result));

  SetWindowLong(Result, GWL_WNDPROC, Longint(@AH_StdWndProc));
end;
(*@\\\0000000B12*)
{ Removes the HWnd both in Windows an in the internal lists }
(*@/// procedure AH_DeallocateHWnd(Wnd: HWND); *)
procedure AH_DeallocateHWnd(Wnd: HWND);
var
  p: integer;
begin
  DestroyWindow(Wnd);
  p:=wndwnds.remove(pointer(Wnd));
  if p>=0 then
    wndprocs.delete(p);
end;
(*@\\\*)
(*@\\\0000001401*)

(*@/// Make Stream and Clipboard work together *)
(*@/// function GetPointer(index: integer; memblock: THandle):pointer; *)
function GetPointer(index: integer; memblock: THandle):pointer;
(*$ifdef delphi_1 *)
var
  selector, offset: word;
  P: pointer;
begin
  selector:=(index div 65536) * selectorinc + memblock;
  offset:=(index mod 65536);
  p:=GlobalLock(Selector);
  result:=Ptr(selector,offset);
  end;
(*$else *)
begin
  result:=pointer(longint(GlobalLock(memblock))+index);
  end;
(*$endif *)
(*@\\\0000000212*)
(*@/// procedure Stream2Clipboard(stream:TStream; format:integer); *)
procedure Stream2Clipboard(stream:TStream; format:integer);
const
  max_write = $8000;    (* must obey ($10000 mod max_write = 0) for Delphi 1 *)
var
  size: longint;
  s: word;
  curpos: longint;
  Memblock: THandle;
  FClipboardWindow: THandle;
begin
  FClipboardWindow := Application.Handle;
  if FClipboardWindow = 0 then
    FClipboardWindow := AllocateHWnd(NIL);
  OpenClipboard(FClipboardWindow);

  stream.seek(0,0);
  size:=stream.size;
  stream.seek(0,0);
  MemBlock:=GlobalAlloc(gmem_moveable or gmem_zeroinit,size+1);
  curpos:=0;
  while curpos+1<size do begin
    s:=stream.read(getPointer(curpos,MemBlock)^,min(max_write,size-curpos));
    inc(curpos,s);
    GlobalUnLock(MemBlock);
    if s=0 then BREAK;
    end;
  char(getPointer(curpos,memblock)^):=#0;
  GlobalUnLock(MemBlock);
  EmptyClipBoard;
  SetClipBoardData(format,memblock);

  CloseClipboard;
  if FClipboardWindow<>Application.Handle then
    DeallocateHWnd(FClipboardWindow);
  end;
(*@\\\0000001601*)
(*@/// procedure Clipboard2Stream(stream:TStream; format:integer); *)
procedure Clipboard2Stream(stream:TStream; format:integer);
const
  max_read = $8000;   (* must obey ($10000 mod max_read = 0) for Delphi 1 *)
var
  size: longint;
  curpos: longint;
  Memblock: THandle;
  FClipboardWindow: THandle;
begin
  FClipboardWindow := Application.Handle;
  if FClipboardWindow = 0 then
    FClipboardWindow := AllocateHWnd(NIL);
  OpenClipboard(FClipboardWindow);

  stream.seek(0,0);
  MemBlock:=GetClipboardData(format);
  size:=GlobalSize(Memblock);
  curpos:=0;
  while curpos+1<size do begin
    stream.write(getPointer(curpos,MemBlock)^,min(max_read,size-curpos-1));
    inc(curpos,min(max_read,size-curpos-1));
    GlobalUnLock(MemBlock);
    end;

  CloseClipboard;
  if FClipboardWindow<>Application.Handle then
    DeallocateHWnd(FClipboardWindow);
  end;
(*@\\\0000000C01*)
(*@\\\0000000301*)

(*@/// Windows Resources and Languages *)
(*$ifdef delphi_gt_1 *)
(*@/// function makelangid(language,sublanguage: word):longint; *)
function makelangid(language,sublanguage: word):longint;
begin
  result:=((language and $3FF) or ((sublanguage and $3F) shl 10)) and $FFFF;
  end;
(*@\\\*)
(*@/// function primarylangid(language:word):word; *)
function primarylangid(language:word):word;
begin
  result:=language and $3FF;
  end;
(*@\\\*)
(*@/// function sublangid(language:word):word; *)
function sublangid(language:word):word;
begin
  result:=(language shr 10) and $3F;
  end;
(*@\\\*)
(*@/// function langidfromlcid(lcid:longint):word; *)
function langidfromlcid(lcid:longint):word;
begin
  result:=lcid and $FFFF;
  end;
(*@\\\*)

(*@/// function MyLoadStringInternal(Instance: THandle; Id: word; languageid: word):string; *)
function MyLoadStringInternal(Instance: THandle; Id: word; languageid: word):string;
var
  h,h1: THandle;
  p: ^word;
  _length: word;
  i: integer;
begin
  h:=FindResourceEx(Instance,rt_string,MakeIntResource((id div 16)+1),languageid);
  if h<>0 then begin
    h1:=Loadresource(Instance,h);
    p:=LockResource(h1);
    i:=id mod 16;
    while i>0 do begin
      _length:=p^;
      inc(p,_length+1);
      dec(i);
      end;
    _length:=p^;
    inc(p);
    setlength(result,WideCharToMultiByte(cp_acp,0,PWideChar(p),_length,NIL,0,NIL,NIL));
    WideCharToMultiByte(cp_acp,0,PWideChar(p),_length,@result[1],length(result),NIL,NIL);
    FreeResource(h1);
    end
  else
    result:='';
  end;
(*@\\\*)
(*@/// function MyLoadString(Instance: THandle; Id: word; languageid: word):string; *)
function MyLoadString(Instance: THandle; Id: word; languageid: word):string;
begin
  result:=MyLoadStringInternal(Instance,id,languageid);
  if result='' then
    result:=MyLoadStringInternal(Instance,id,makelangid(primarylangid(languageid),sublang_default));
  if result='' then
    result:=MyLoadStringInternal(Instance,id,makelangid(primarylangid(languageid),sublang_neutral));
  if result='' then
    result:=MyLoadStringInternal(Instance,id,makelangid(lang_neutral,sublang_neutral));
  end;
(*@\\\*)
(*@/// function LoadStrEx(id:word; languageid: word):string; *)
function LoadStrEx(id:word; languageid: word):string;
begin
  result:=MyLoadString(HInstance,id,languageid);
  end;
(*@\\\*)
(*$endif *)
(*@/// function LoadStr(id:word):string; *)
function LoadStr(id:word):string;
begin
  (*$ifdef delphi_gt_1 *)
  result:=MyLoadString(HInstance,id,GetUserDefaultLangId);
  (*$else *)
  result:=sysutils.loadstr(id);
  (*$endif *)
  end;
(*@\\\003C00050100060100070100080100070B*)
(*@\\\*)

(*@/// function ScrollBarVisible(control: TWinControl; vertical: boolean):boolean; *)
function ScrollBarVisible(control: TWinControl; vertical: boolean):boolean;
(*$ifdef delphi_1 *)
var
  code: integer;
  min,max: integer;
begin
  if vertical then
    code:=sb_vert
  else
    code:=sb_horz;
  GetScrollRange(control.handle,code,min,max);
  result:=(min<>max);
  end;
(*$else *)
var
  code: integer;
  ScrollInfo: TScrollInfo;
begin
  if vertical then
    code:=sb_vert
  else
    code:=sb_horz;
  scrollinfo.cbsize:=sizeof(scrollinfo);
  scrollinfo.fmask:=sif_all;
  if GetScrollInfo(control.handle,code,scrollinfo) then
    result:=(scrollinfo.nmax<>scrollinfo.nmin)
  else
    result:=false;
  end;
(*$endif *)
(*@\\\*)

(*@/// procedure DoneUnit;  // The cleanup of the unit, called in finalization *)
procedure DoneUnit; far;
begin
(*$ifndef delphi_ge_3 *)
{ For design mode: relink the OnShowHint back to it's default value;   }
{ only needed since with Delphi 3 packages the finalization may be     }
{ called without Delphi itself is closed                               }

  if (ShowHintProcs<>NIL) and
     (ShowHintProcs.Count>0) then
       Application.OnShowHint:=TShowHintEvent(TMethod(ShowHintProcs.Items[0]).methodpointer);

{ The explicit removing of the list entries is needed since the delete method }
{  of the TLIst isn't virtual an therefore not called by the Free             }
  if ShowHintProcs<>NIL then
    while ShowHintProcs.Count>0 do
      ShowHintProcs.delete(0);
  ShowHintProcs.Free;
  ShowHintProcs:=NIL;
(*$endif *)
  if IdleProcs<>NIL then
    while IdleProcs.Count>0 do
      IdleProcs.delete(0);
  IdleProcs.Free;
  IdleProcs:=NIL;
  Dummy.Free;
  Dummy:=NIL;

{ The explicit removing of the list entries is needed since the delete method }
{  of the TLIst isn't virtual an therefore not called by the Free             }
  if WndProcs<>NIL then
    while WndProcs.Count>0 do
      WndProcs.delete(0);
  WndProcs.Free;
  WndProcs:=NIL;
  WndWnds.Free;
  WndWnds:=NIL;
  end;
(*@\\\*)
(*@\\\0000001101*)
(*@/// initialization *)
(*$ifndef delphi_ge_3 *)
var
  t:TShowHintEvent;
(*$endif *)
(*$ifdef delphi_1 *)
begin
(*$else *)
initialization
begin
(*$endif *)
  Dummy:=TDummyObject.Create;
  IdleProcs:=TObjectList.Create;

  (* Since Delphi 3 there is the CM_HINTSHOW instead,
     so this isn't needed anymore *)
(*$ifndef delphi_ge_3 *)
  ShowHintProcs:=TObjectList.Create;
  t:=application.OnShowHint;
  if assigned(t) then      { D1 can't do a assigned of a property          }
    AddShowHintProc(t);    { In design mode the OnShowHint is responsible  }
                           { for the hints of the component palette so I   }
                           { need to remember this                         }
(*$endif *)
  WndProcs:=TObjectList.Create;
  WndWnds:=TList.Create;
(*@\\\000000040C*)
(*@/// finalization *)
(*$ifdef delphi_1 *)
  AddExitProc(DoneUnit);
(*$else *)
  end;
finalization
  DoneUnit;
(*$endif *)
(*@\\\0000000201*)
end.
(*@\\\0003000701000011000701*)
