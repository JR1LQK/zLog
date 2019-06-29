unit DateDb97;

(******************************************************************************
TDbDateEdit97

Derived from
    tDateEdit97

Properties
    DataSource, DataField : Database informations
    ReadOnly : Can modify field

Author name=BOURMAD Mehdi
Author E-mail=bourmad@mygale.org
Author URL=www.mygale.org/~bourmad
******************************************************************************)

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Dialogs, Forms, StdCtrls, Buttons, Db, DbCtrls, DbTables, DateEd97;

type
  TDbDateEdit97 = class(TDateEdit97)
  private
    FDataLink: TFieldDataLink;
    FCanvas: TControlCanvas;
    FAlignment: TAlignment;
    FFocused: Boolean;
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetField: TField;
    function GetReadOnly: Boolean;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetFocused(Value: Boolean);
    procedure SetReadOnly(Value: Boolean);
    procedure UpdateData(Sender: TObject);
    procedure WMCut(var message: TMessage); message WM_CUT;
    procedure WMPaste(var message: TMessage); message WM_PASTE;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
  protected
    function GetDate: TDateTime;
    procedure SetDate(dtArg: TDateTime);
    procedure Change; override;
    procedure KeyPress(var Key: char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;
    property Date: TDateTime read GetDate write SetDate;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
  end;

implementation

{-------------------------------------------------------------}
{-------------------- TDbDateEdit97 --------------------------}
{-------------------------------------------------------------}
constructor TDbDateEdit97.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  inherited ReadOnly := True;
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
end;

destructor TDbDateEdit97.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  FCanvas.Free;
  inherited Destroy;
end;

procedure TDbDateEdit97.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
     (AComponent = DataSource) then DataSource := nil;
end;

function TDbDateEdit97.GetDate: TDateTime;
begin
  GetDate := inherited Date;
end;

procedure TDbDateEdit97.SetDate(dtArg: TDateTime);
begin
  inherited SetDate(dtArg);
  if FDataLink.Field.AsDateTime <> dtArg then
  begin
    FDataLink.Field.AsDateTime := dtArg;
    FDataLink.Modified;
  end;
end;

procedure TDbDateEdit97.Click;
begin
  FDataLink.Edit;
  inherited Click;
end;

procedure TDbDateEdit97.KeyPress(var Key: char);
begin
  if (FDataLink.Field <> nil) and not FDataLink.Field.IsValidChar(Key)
  then begin
    MessageBeep(0);
    Key := #0;
  end;

  case Key of
    ^H, ^V, ^X, '0'..'9': begin
      FDataLink.Edit;
    end;

    #27: begin
      inherited SetDateValid(True);
      FDataLink.Reset;
      SelectAll;
      Key := #0;
    end;
  end;

  inherited KeyPress(Key);
end;

procedure TDbDateEdit97.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if FDataLink.Editing
  then inherited KeyDown(Key, Shift)
  else
  begin
    if (Key <> ShortCutClear) and
       (Key <> ShortCutPopup) and
       (Key <> ShortCutValidate)
    then inherited KeyDown(Key, Shift);
  end;

  if (Key = VK_DELETE) or ((Key = VK_INSERT) and (ssShift in Shift))
    then FDataLink.Edit;
end;

procedure TDbDateEdit97.SetFocused(Value: Boolean);
begin
  if FFocused <> Value then
  begin
    FFocused := Value;
    if (FAlignment <> taLeftJustify)
      then Invalidate;
{    FDataLink.Reset;   {comment, because raise problem when clear a date}
  end;
end;

procedure TDbDateEdit97.Change;
begin
  FDataLink.Modified;
  inherited Change;
end;

procedure TDbDateEdit97.DataChange(Sender: TObject);
begin
  if Assigned(FBtnClear)
    then FBtnClear.Enabled := FDataLink.Active;
  if (Assigned(FBtnPopup)) and CanPopup
    then FBtnPopup.Enabled := FDataLink.Active;
  if Assigned(FBtnValidate)
    then FBtnValidate.Enabled := FDataLink.Active;

  if FDataLink.Field <> nil then
  begin
    if FAlignment <> FDataLink.Field.Alignment then
    begin
      Text := '';  {forces update}
      FAlignment := FDataLink.Field.Alignment;
    end;

    if FDataLink.Field.AsDateTime = 0
    then Text := ''
    else begin
      inherited Date := FDataLink.Field.AsDateTime;
    end;
  end
  else begin
    FAlignment := taLeftJustify;
    MaxLength := 0;
    if csDesigning in ComponentState
      then Text := Name
    else Text := '';
  end;


  if FDataLink.Editing
  then begin
    {Transform date to number before edit necessary if
     the cursor is already on the edit box}
    if Focused
      then AdjustEdit;
(*  end
  else begin
    {Transform number in date for display purpose necessary if
     the cursor is already on the edit box}
    if Focused
      then begin
        Text := DateToStr(Date);
        SetDateValid(True);
        AdjustEdit;
      end;*)
  end;
end;

procedure TDbDateEdit97.EditingChange(Sender: TObject);
begin
  inherited ReadOnly := not FDataLink.Editing;
end;

procedure TDbDateEdit97.UpdateData(Sender: TObject);
begin
  if Length(Text) > 0
    then AdjustDate
    else begin
      inherited Date := 0;    {User now Can delete the date!}
      Modified := False;
      FDatalink.Field.AsString := '';
    end;


  if (Date <> 0) or (Length(Text) > 0)
  then
    try
      SetDate(StrToDate(Text));
      SetDateValid(True);
    except
      Text := DateToStr(Date);
      AdjustEdit;
      SetDateValid(False);
      SelectAll;
      SetFocus;
      raise;
    end;
end;

procedure TDbDateEdit97.WMPaste(var message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TDbDateEdit97.WMCut(var message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TDbDateEdit97.CMEnter(var Message: TCMEnter);
begin
  SetFocused(True);
  FDataLink.Edit;
  inherited;
end;

procedure TDbDateEdit97.CMExit(var Message: TCMExit);
begin
  FDataLink.UpdateRecord;

  inherited;

  SetFocused(False);
  SetCursor(0);
end;

function TDbDateEdit97.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDbDateEdit97.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

function TDbDateEdit97.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDbDateEdit97.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TDbDateEdit97.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TDbDateEdit97.SetReadOnly(Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
end;

function TDbDateEdit97.GetField: TField;
begin
  Result := FDataLink.Field;
end;


end.

