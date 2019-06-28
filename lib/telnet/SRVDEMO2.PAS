{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Demonstration for Server program using TWSocket.
EMail:        francois.piette@ping.be  http://www.rtfm.be/fpiette
              francois.piette@rtfm.be
Creation:     8 december 1997
Version:      1.00
WebSite:      http://www.rtfm.be/fpiette/indexuk.htm
Support:      Use the mailing list twsocket@rtfm.be See website for details.
Legal issues: Copyright (C) 1997 by François PIETTE <francois.piette@ping.be>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

Updates:


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit SrvDemo2;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, WSocket, StdCtrls, Db, DBTables, ExtCtrls;

type
  TCliForm = class(TForm)
    CliSocket: TWSocket;
    DisplayMemo: TMemo;
    Panel1: TPanel;
    SendEdit: TEdit;
    SendButton: TButton;
    Panel2: TPanel;
    LineLabel: TLabel;
    DisconnectButton: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CliSocketDataAvailable(Sender: TObject; Error: Word);
    procedure CliSocketSessionClosed(Sender: TObject; Error: Word);
    procedure SendButtonClick(Sender: TObject);
    procedure DisconnectButtonClick(Sender: TObject);
  private
    { Déclarations privées }
    Initialized : Boolean;
    Buffer : array [0..1023] of char;
    Count  : Integer;
    procedure ProcessCommand(Cmd : String);
  public
    { Déclarations publiques }
    DataTable : TTable;
  end;

var
  CliForm: TCliForm;

implementation

{$R *.DFM}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF VER80}
procedure SetLength(var S: string; NewLength: Integer);
begin
    S[0] := chr(NewLength);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TrimRight(Str : String) : String;
var
    i : Integer;
begin
    i := Length(Str);
    while (i > 0) and (Str[i] = ' ') do
        i := i - 1;
    Result := Copy(Str, 1, i);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TrimLeft(Str : String) : String;
var
    i : Integer;
begin
    if Str[1] <> ' ' then
        Result := Str
    else begin
        i := 1;
        while (i <= Length(Str)) and (Str[i] = ' ') do
            i := i + 1;
        Result := Copy(Str, i, Length(Str) - i + 1);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function Trim(Str : String) : String;
begin
    Result := TrimLeft(TrimRight(Str));
end;
{$ENDIF}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCliForm.FormShow(Sender: TObject);
begin
    if not Initialized then begin
        Initialized   := TRUE;
        DisplayMemo.Clear;
        SendEdit.Text := 'Hello world !';
        ActiveControl := SendEdit;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCliForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    PostMessage(TForm(Owner).Handle, WM_USER, 0, LongInt(Self));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCliForm.ProcessCommand(Cmd : String);
var
    CommandVerb : String;
    CommandTail : String;
    I, J        : Integer;
begin
    { Remove trailing #13 }
    if (Length(Cmd) > 0) and (Cmd[Length(Cmd)] = #13) then
        SetLength(Cmd, Length(Cmd) - 1);

    DisplayMemo.Lines.Add(Cmd);

    { Skip leading spaces }
    I := 1;
    while (I <= Length(Cmd)) and (Cmd[I] in [' ', #9]) do
        Inc(I);

    { Find separator and separe CommandVerb and CommandTail }
    J := I;
    while TRUE do begin
        if (J >= Length(Cmd)) then begin
            CommandTail := '';
            CommandVerb := Cmd;
            break;
        end;

        if Cmd[J] in [' ', #9, '/'] then begin
            CommandTail := Copy(Cmd, J, Length(Cmd) - J + 1);
            CommandVerb := Copy(Cmd, I, J - I);
            break;
        end;
        Inc(J);
    end;
    CommandVerb := UpperCase(CommandVerb);
    CommandTail := Trim(CommandTail);

    if CommandVerb = 'LASTNAME' then begin
        DataTable.IndexName := 'NOM';
        DataTable.SetKey;
        DataTable.FieldByName('NOM').AsString := CommandTail;
    end
    else if CommandVerb = 'FIRSTNAME' then begin
        DataTable.IndexName := 'PRENOM';
        DataTable.SetKey;
        DataTable.FieldByName('PRENOM').AsString := CommandTail;
    end
    else begin
        CliSocket.SendStr('Syntax error !' + #13 + #10);
        Exit;
    end;

    if DataTable.GotoKey then
        CliSocket.SendStr(
            '"' + DataTable.FieldByName('NOM').AsString + '", ' +
            '"' + DataTable.FieldByName('PRENOM').AsString + '", ' +
            '"' + DataTable.FieldByName('ADRESSE').AsString + '", ' +
            '"' + DataTable.FieldByName('CP').AsString + '", ' +
            '"' + DataTable.FieldByName('LOCALITE').AsString + '"' +
            #13 + #10)
    else
        CliSocket.SendStr('Pas trouvé' + #13 + #10);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCliForm.CliSocketDataAvailable(Sender: TObject; Error: Word);
var
    Len : Integer;
    I   : Integer;
begin
    Len := CliSocket.Receive(@Buffer[Count], SizeOf(Buffer) - Count - 1);
    if Len <= 0 then
        Exit;

    Count := Count + Len;
    Buffer[Count] := #0;
    LineLabel.Caption := StrPas(Buffer);

    while TRUE do begin
        I := 0;
        while (I < Count) and (Buffer[I] <> #10) do
            Inc(I);
        if I >= Count then
            Exit;
        ProcessCommand(Copy(StrPas(Buffer), 1, I));
        Count             := 0;
        LineLabel.Caption := '';
        if I >= StrLen(Buffer) then
            break;
        Move(Buffer[I + 1], Buffer, Strlen(Buffer) - I);
        LineLabel.Caption := StrPas(Buffer);
        Count             := StrLen(Buffer);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCliForm.CliSocketSessionClosed(Sender: TObject; Error: Word);
begin
    Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCliForm.SendButtonClick(Sender: TObject);
begin
    CliSocket.SendStr(SendEdit.Text + #13 + #10);
    ActiveControl := SendEdit;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TCliForm.DisconnectButtonClick(Sender: TObject);
begin
    Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

