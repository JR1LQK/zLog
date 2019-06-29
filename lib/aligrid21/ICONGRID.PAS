unit icongrid;
(*@/// interface *)
interface
  (*$x+ *)

(*@/// uses *)
uses
  windows,
  sysutils,
  classes,
  graphics,
  grids,
  aligrid;
(*@\\\000000030C*)

type
(*@///   TCellPropertiesIcon=class(TCellProperties) *)
TCellPropertiesIcon=class(TCellProperties)
protected
  f_icon: TIcon;
  procedure SetIcon(value: TIcon);
  procedure ReadSingleProperty(Proptype:integer; Reader:TReader; grid:TStringAlignGrid);  override;
  procedure WriteToWriter(writer:TWriter); override;
public
  property Icon:TIcon read f_icon write SetIcon;
  destructor destroy;                      override;
  procedure assign(value:TCellProperties); override;
  function isempty: boolean;               override;
  function clone:TCellProperties;          override;
end;
(*@\\\*)
(*@///   TIconGrid=class(TStringAlignGrid) *)
TIconGrid=class(TStringAlignGrid)
protected
  procedure DrawCellBack(ACol,ARow:Longint; var ARect:TRect; AState:TGridDrawState); override;
  procedure Initialize;  override;
protected
(*@///   property read/write for the icons *)
function GetIconCell(ACol,ARow: longint):TIcon;
procedure SetIconCell(ACol,ARow: longint; const Value: TIcon);
(*@\\\0000000201*)
  procedure IconChanged(AIcon: TObject);
public
  property CellIcon[ACol,ARow:longint]: TIcon read GetIconCell write SetIconCell;
  end;
(*@\\\0032000401000401000401000401*)

procedure Register;
(*@\\\0000000801*)
(*@/// implementation *)
implementation

const
  prop_icon     = 100;  (* save value to keep space for basic class to expand *)

type
  tp_char=^char;
(*@/// function buf2hexstring(p:tp_char, size:longint):string; *)
function buf2hexstring(p:tp_char; size:longint):string;
begin
  result:='';
  while size>0 do begin
    result:=result+inttohex(ord(p^),2);
    dec(size);
    inc(p);
    end;
  end;
(*@\\\0000000401*)
(*@/// procedure WriteStream(Writer: TWriter; v:TStream); *)
procedure WriteStream(Writer: TWriter; v:TStream);
const
  linesize=100;
var
  buf: pointer;
  size: integer;
begin
  buf:=NIL;
  try
    getmem(buf,linesize);
    size:=linesize;
    while size>0 do begin
      size:=v.read(buf^,linesize);
      if size>0 then
        writer.writestring(buf2hexstring(buf,size));
      end;
    writer.writestring('.');
  finally
    if buf<>NIL then
      freemem(buf,linesize);
    end;
  end;
(*@\\\0000000F01*)
(*@/// function ReadStream(Reader: TReader):TMemoryStream; *)
function ReadStream(Reader: TReader):TMemoryStream;
var
  s: string;
  h: char;
begin
  result:=NIL;
  try
    result:=TMemoryStream.Create;
    repeat
      s:=reader.readstring;
      if s<>'.' then
        while length(s)>0 do begin
          h:=chr(strtoint('$'+copy(s,1,2)));
          result.write(h,1);
          s:=copy(s,3,length(s));
          end;
    until s='.';
    result.seek(0,0);
  except
    result.free;
    RAISE;
    end;
  end;
(*@\\\0000001216*)


(*@/// destructor TCellPropertiesIcon.destroy; *)
destructor TCellPropertiesIcon.destroy;
begin
  f_icon.free;
  inherited destroy;
  end;
(*@\\\0000000415*)
(*@/// procedure TCellPropertiesIcon.ReadSingleProperty(Proptype:integer; Reader:TReader; grid:TStringAlignGrid); *)
procedure TCellPropertiesIcon.ReadSingleProperty(Proptype:integer; Reader:TReader; grid:TStringAlignGrid);
var
  f: TIcon;
  s: TStream;
begin
  case proptype of
    prop_icon   : begin
      f:=NIL;
      s:=NIL;
      try
        f:=TIcon.Create;
        s:=ReadStream(Reader);
        f.loadfromstream(s);
        self.icon:=f;
        self.icon.OnChange:=TIconGrid(grid).iconchanged;
      finally
        f.free;
        s.free;
        end;
      end;
    else inherited ReadSingleProperty(Proptype,Reader,grid);
    end;
  end;
(*@\\\0000000C09*)
(*@/// procedure TCellPropertiesIcon.WriteToWriter(writer:TWriter); *)
procedure TCellPropertiesIcon.WriteToWriter(writer:TWriter);
var
  h: TMemoryStream;
begin
(*@///   if self.icon<>NIL then *)
if self.icon<>NIL then begin
  writer.writeinteger(prop_icon);
  h:=NIL;
  try
    h:=TMemoryStream.Create;
    icon.savetostream(h);
    h.seek(0,0);
    WriteStream(writer,h);
  finally
    h.free;
    end;
  end;
(*@\\\0000000305*)
  inherited WriteToWriter(writer);
  end;
(*@\\\0000000514*)
(*@/// procedure TCellPropertiesIcon.SetIcon(value: TIcon); *)
procedure TCellPropertiesIcon.SetIcon(value: TIcon);
begin
  if value=NIL then begin
    f_icon.free;
    f_icon:=NIL;
    end
  else begin
    if f_icon=NIL then
      f_icon:=TIcon.Create;
    f_icon.assign(value);
    end;
  end;
(*@\\\*)
(*@/// procedure TCellPropertiesIcon.assign(value:TCellProperties); *)
procedure TCellPropertiesIcon.assign(value:TCellProperties);
begin
  inherited assign(value);
  if value is TCellPropertiesIcon then
    SetIcon(TCellPropertiesIcon(value).icon)
  else
    SetIcon(NIL);
  end;
(*@\\\0000000501*)
(*@/// function TCellPropertiesIcon.isempty: boolean; *)
function TCellPropertiesIcon.isempty: boolean;
begin
  result:=inherited isempty and ((f_icon=NIL) or (f_icon.handle=0));
  end;
(*@\\\0000000344*)
(*@/// function TCellPropertiesIcon.clone:TCellProperties; *)
function TCellPropertiesIcon.clone:TCellProperties;
begin
  result:=TCellPropertiesIcon.Create(self.f_grid);
  result.assign(self);
  end;
(*@\\\*)

(*@/// procedure TIconGrid.Initialize; *)
procedure TIconGrid.Initialize;
begin
  inherited Initialize;
  CellPropertiesClass:=TCellPropertiesIcon;
  end;
(*@\\\000C000501000501000501*)
(*@/// procedure TIconGrid.IconChanged(AIcon: TObject); *)
procedure TIconGrid.IconChanged(AIcon: TObject);
begin
  invalidate;
  end;
(*@\\\*)
(*@/// function TIconGrid.GetIconCell(ACol,ARow: longint):TIcon; *)
function TIconGrid.GetIconCell(ACol,ARow: longint):TIcon;
var
  v,w: TCellProperties;
begin
  w:=NIL;
  try
    v:=GetItemCell(ACol,ARow,FPropCell);
    if (v=NIL) or not (v is TCellPropertiesIcon)  then begin
      w:=v;
      v:=CellPropertiesClass.Create(self);
      if w<>NIL then
        v.assign(w);
      setitemcell(ACol,ARow,FPropCell,v);
      end;
    if TCellPropertiesIcon(v).icon=NIL then begin
      TCellPropertiesIcon(v).f_icon:=TIcon.Create;
      TCellPropertiesIcon(v).icon.OnChange:=iconchanged;
      end;
    result:=TCellPropertiesIcon(v).icon;
  finally
    w.free;
    end;
  end;
(*@\\\0000000801*)
(*@/// procedure TIconGrid.SetIconCell(ACol,ARow: longint; const Value: TIcon); *)
procedure TIconGrid.SetIconCell(ACol,ARow: longint; const Value: TIcon);
begin
  (ObjectCell[ACol,ARow] as TCellPropertiesIcon).icon:=value;
  Invalidate;
  end;
(*@\\\0000000301*)
(*@/// procedure TIconGrid.DrawCellBack(ACol,ARow:Longint; ARect:TRect; AState:TGridDrawState); *)
procedure TIconGrid.DrawCellBack(ACol,ARow:Longint; var ARect:TRect; AState:TGridDrawState);
var
  v: TCellProperties;
begin
  inherited DrawCellBack(ACol,ARow,ARect,AState);
  v:=GetItemCell(ACol,ARow,FPropCell);
  if (v<>NIL) and (v is TCellPropertiesIcon) and (TCellPropertiesIcon(v).icon<>NIL) and (TCellPropertiesIcon(v).icon.handle<>0) then begin
    Canvas.Draw(Arect.Left,Arect.Top,TCellPropertiesIcon(v).icon);
    Arect.Left:=ARect.Left+TCellPropertiesIcon(v).icon.width;
    end;
  end;
(*@\\\0000000701*)

(*@/// procedure Register; *)
procedure Register;
begin
  RegisterComponents('Custom', [TIconGrid]);
  end;
(*@\\\*)
(*@\\\0000001601*)
end.
(*@\\\0001000011000201*)
