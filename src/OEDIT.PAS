{ TOvrEdit
  --------
  An improved TEdit component which reflect keyboard
  insert/overwrite mode, Special desiged for Windows
  Traditional Chinese Version.

  by Wolfgang Chien <wolfgang@ms2.hinet.net>
}
unit OEdit;

interface

{$ifdef Windows}
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls;
{$endif}

{$ifdef Win32}
uses
  SysUtils, Windows, Messages, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls;
{$endif}

type
  TInsertKeyStates = (iksInsert, iksOverWrite);

  TOvrEdit = class(TEdit)
  private
    FTabOnEnter: boolean;
    FInsertKeyState: boolean;
    procedure WMChar(var Msg: TWMKey); message WM_Char;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function GetInsertKeyState: TInsertKeyStates;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property InsertKeyState: TInsertKeyStates read GetInsertKeyState;
  published
    property TabOnEnter: boolean
      read FTabOnEnter write FTabOnEnter default True;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TOvrEdit]);
end;

constructor TOvrEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TabOnEnter := True;
end;

(* -------------------------------------------------- *)
destructor TOvrEdit.Destroy;
begin
  inherited Destroy;
end;

(* -------------------------------------------------- *)
procedure TOvrEdit.KeyDown(var Key: Word;
  Shift: TShiftState);
begin
  if TabOnEnter then
  begin
    case Key of
      vk_Down:  { Dn-Arrow Key }
        begin
          SendMessage(GetParentForm(Self).Handle, wm_NextDlgCtl, 0, 0);
          Key := 0;
        end;
      vk_Up:  { Up-Arrow Key }
        begin
          SendMessage(GetParentForm(Self).Handle, wm_NextDlgCtl, 1, 0);
          Key := 0;
        end;
    end;
  end;
  if Key <> 0 then inherited KeyDown(Key, Shift);
end;

(* -------------------------------------------------- *)
procedure TOvrEdit.KeyPress(var Key: Char);
begin
  if TabOnEnter and (Key = #13) then { Enter Key }
  begin
    SendMessage(GetParentForm(Self).Handle, wm_NextDlgCtl, 0, 0);
    Key := #0;
  end;
  if Key <> #0 then inherited KeyPress(Key);
end;

(* -------------------------------------------------- *)
function TOvrEdit.GetInsertKeyState: TInsertKeyStates;
begin
  if GetKeyState(VK_INSERT) = 0 then
    Result := iksInsert
  else
    Result := iksOverWrite;
end;

(* -------------------------------------------------- *)
procedure TOvrEdit.WMChar(var Msg: TWMKey);
begin
  { if Overwrite state and user select nothing }
  if (InsertKeyState = iksOverWrite) and (SelLength = 0)
    and (SelStart < GetTextLen) then
  begin
    { ASCII Extend code > 127 ==> Chinese word Lead-byte, BIG-5 }
    if Msg.CharCode > 127 then
      SelLength := 2
    else
    begin
      SelLength := 2;
      { if char on current Caret positon is a Chinese word }
      if Ord(SelText[1]) > 127 then
        SelLength := 2
      else
        SelLength := 1;
    end;
  end;

  inherited;
end;

end.

