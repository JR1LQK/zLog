unit TRECode;

{Description:  RichEdit component with added events, methods and properties}
{Author:       Richard Shotbolt (100327,2305@compuserve.com)}
{Date:         23 Jan 1996}

interface

uses
   WinProcs, Messages, Classes, ComCtrls, RichEdit;

type
   TNotifyEvent = procedure(Sender:TObject) of object;
{ ************************************************************************* }
   TSRichEdit = class(TRichEdit)
   private
       FOnVScroll: TNotifyEvent;
       FOnHScroll: TNotifyEvent;
       FCurrentLine: integer;
       FCurrentPosition: integer;
       FTopLine: integer;
       FLinesVisible: integer;
       procedure DoOnHScroll (var Msg: TWMHScroll); message WM_HSCROLL;
       procedure DoOnVScroll (var Msg: TWMVScroll); message WM_VSCROLL;
       function GetCurrentLine: integer;
       function GetCurrentPosition: integer;
       function GetTopLine: integer;
       procedure SetCurrentLine(Value: integer);
       procedure SetCurrentPosition(Value: integer);
       procedure SetTopLine(Value: integer);
       function GetLinesVisible: integer;
       function GetMaxLinesVisible: integer;
   protected
   public
       constructor Create(AOwner:TComponent); override;
       destructor Destroy; override;
       {properties}
       property CurrentLine: integer read GetCurrentLine write SetCurrentLine;
       property CurrentPosition: integer read GetCurrentPosition write SetCurrentPosition;
       property Topline: integer read GetTopLine write SetTopLine;
       property LinesVisible: integer read GetLinesVisible;
       property MaxLinesVisible: integer read GetMaxLinesVisible;
       {methods}
   published
       property OnVScroll: TNotifyEvent read FOnVScroll write FOnVScroll;
       property OnHScroll: TNotifyEvent read FOnHScroll write FOnHScroll;
   end;

procedure Register;

implementation
{----------  TSRichEdit ----------}

{ ************************************************************************* }
constructor TSRichEdit.Create(AOwner:TComponent);
begin
inherited Create(AOwner);
end;

{ ************************************************************************* }
procedure TSRichEdit.DoOnHScroll (var Msg: TWMHScroll);
{New event handler - HScroll}

begin
inherited;
if assigned (FOnHScroll) then
   FOnHScroll(Self);
end;

{ ************************************************************************* }
procedure TSRichEdit.DoOnVScroll (var Msg: TWMVScroll);
{New event handler - VScroll}
begin
inherited;
if assigned (FOnVScroll) then
   FOnVScroll(Self);
end;

{ ************************************************************************* }
function TSRichEdit.GetCurrentLine: integer;
{Get line number containing caret}
begin
result := SendMessage(Handle, EM_LINEFROMCHAR, SelStart, 0);
end;

{ ************************************************************************* }
function TSRichEdit.GetCurrentPosition: integer;
{Get character position of caret within line}
begin
result := SelStart - SendMessage(Handle, EM_LINEINDEX,
   (SendMessage(Handle, EM_LINEFROMCHAR, SelStart, 0)), 0);
end;

{ ************************************************************************* }
function TSRichEdit.GetTopLine: integer;
{Get number of topmost visible line}
begin
result := SendMessage(Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
end;

{ ************************************************************************* }
function TSRichEdit.GetMaxLinesVisible: integer;
{Returns number of lines that can be shown in the current font}
var
   hndl: HDC;
   tm: TTextMetric;
begin
if Visible then
   begin
   hndl := GetDC(Handle);
   SelectObject(hndl, Font.Handle);
   GetTextMetrics(hndl, tm);
   ReleaseDC(Handle, hndl);
   result := ClientHeight div tm.tmHeight;
   end
else
   result := -1;
end;

{ ************************************************************************* }
function TSRichEdit.GetLinesVisible: integer;
{Return actual number of lines visible}
var
   c: integer;
   n: integer;
begin
if Visible then
   begin
   n := GetMaxLinesVisible;
   {truncate value to actual number of lines visible if necessary}
   c := Lines.Count - SendMessage(Handle, EM_GETFIRSTVISIBLELINE, 0, 0);
   if c < n then
      result := c
   else
      result := n;
   end
else
   result := 0;
end;

{ ************************************************************************* }
procedure TSRichEdit.SetCurrentLine(Value: integer);
{Put caret on start of selected line}
var
   cl: integer;
begin
cl := Value;
{Restrict range to available lines}
if cl < 0 then
   cl := 0;
if cl > Lines.Count - 1 then
   cl := Lines.Count - 1;
SelLength := 0;
SelStart := SendMessage(Handle, EM_LINEINDEX, cl, 0);
end;

{ ************************************************************************* }
procedure TSRichEdit.SetCurrentPosition(Value: integer);
var
   cl: integer;
   cp: integer;
begin
{Value must be within range}
cl := GetCurrentLine;
cp := Value;
if cp < 0 then
   cp := 0;
if (cp > Length(Lines[cl])) then
   cp := Length(Lines[cl]);
{Put caret in selected position}
SelLength := 0;
SelStart := SendMessage(Handle, EM_LINEINDEX, cl, 0) + cp;
end;

{ ************************************************************************* }
procedure TSRichEdit.SetTopLine(Value: integer);
{Put selected line at top of memo}
var
   tl: integer;
begin
tl := Value;
if tl < 0 then
   tl := 0;
if tl > Lines.Count - 1 then
   tl := Lines.Count - 1;
SendMessage(Handle, EM_LINESCROLL, 0,
   tl - SendMessage(Handle, EM_GETFIRSTVISIBLELINE, 0, 0));
end;

{ ************************************************************************* }
destructor TSRichEdit.Destroy;
begin
inherited Destroy;
end;

{ ************************************************************************* }
procedure Register;
begin
RegisterComponents('Samples',[TSRichEdit]);
end;

end.

