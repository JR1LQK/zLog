{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Demonstration for Client program using TWSocket.
Creation:     8 december 1997
Version:      1.04
EMail:        http://www.overbyte.be       francois.piette@overbyte.be
              http://www.rtfm.be/fpiette   francois.piette@rtfm.be
              francois.piette@pophost.eunet.be
Support:      Use the mailing list twsocket@rtfm.be See website for details.
Legal issues: Copyright (C) 1997-2001 by François PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@overbyte.be>

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
Dec 09, 1997 V1.01 Made it compatible with Delphi 1
Jul 09, 1998 V1.02 Adapted for Delphi 4
Dec 05, 1998 V1.03 Don't use TWait component
Dec 15, 2001 V1.04 Use LineMode

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit CliDemo1;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IniFiles, ExtCtrls,
  { Don't forget to add your vc32 directory to Delphi library path }
  WSocket;

const
  IniFileName = 'CliDemo.ini';

type
  TClientForm = class(TForm)
    CliSocket: TWSocket;
    DisplayMemo: TMemo;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    SendEdit: TEdit;
    SendButton: TButton;
    DisconnectButton: TButton;
    PortEdit: TEdit;
    ServerEdit: TEdit;
    procedure DisconnectButtonClick(Sender: TObject);
    procedure SendButtonClick(Sender: TObject);
    procedure CliSocketDataAvailable(Sender: TObject; Error: Word);
    procedure CliSocketSessionConnected(Sender: TObject; Error: Word);
    procedure CliSocketSessionClosed(Sender: TObject; Error: Word);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    Buffer       : array [0..1023] of char;
    ConnectError : Word;
    Initialized  : Boolean;
    procedure Display(Msg : String);
    procedure ProcessCommand(Cmd : String);
  end;

var
  ClientForm: TClientForm;

implementation

{$R *.DFM}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientForm.DisconnectButtonClick(Sender: TObject);
begin
    CliSocket.Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientForm.SendButtonClick(Sender: TObject);
begin
    if CliSocket.State <> wsConnected then begin
        CliSocket.Proto    := 'tcp';
        CliSocket.Port     := PortEdit.Text;
        CliSocket.Addr     := ServerEdit.Text;
        CliSocket.LineMode := TRUE;
        CliSocket.LineEnd  := #13#10;
        CliSocket.Connect;
        { Connect is asynchronous (non-blocking). We will wait while the }
        { session is connecting or application terminated.               }
        while CliSocket.State in [wsConnecting] do begin
            Application.ProcessMessages;
            if Application.Terminated then
                Exit;
        end;
    end;
    { Be sure we are connected before sending anything }
    if CliSocket.State = wsConnected then
        CliSocket.SendStr(SendEdit.Text + #13 + #10);
    ActiveControl := SendEdit;
    SendEdit.SelectAll;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientForm.ProcessCommand(Cmd : String);
begin
    { Here you should write your command interpreter.                       }
    { For simplicity, we just display received command !                    }
    { First remove EndOfLine marker                                         }
    if (Length(Cmd) >= Length(CliSocket.LineEnd)) and
       (Copy(Cmd, Length(Cmd) - Length(CliSocket.LineEnd) + 1,
             Length(CliSocket.LineEnd)) = CliSocket.LineEnd) then
        Cmd := Copy(Cmd, 1, Length(Cmd) - Length(CliSocket.LineEnd));
    { Then display in memo                                                  }
    Display(Cmd);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientForm.CliSocketDataAvailable(Sender: TObject; Error: Word);
var
    Len : Integer;
begin
    { We use line mode, we will receive a complete line }
    Len := CliSocket.Receive(@Buffer, SizeOf(Buffer) - 1);
    if Len <= 0 then
        Exit;

    Buffer[Len]       := #0;              { Nul terminate  }
    ProcessCommand(StrPas(Buffer));       { Pass as string }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientForm.CliSocketSessionConnected(
    Sender : TObject;
    Error  : Word);
begin
    ConnectError := Error;
    if Error <> 0 then
        Display('Can''t connect, error #' + IntToStr(Error))
    else
        DisconnectButton.Enabled := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientForm.CliSocketSessionClosed(Sender: TObject; Error: Word);
begin
    DisconnectButton.Enabled := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
    IniFile : TIniFile;
begin
    IniFile := TIniFile.Create(IniFileName);
    IniFile.WriteInteger('Window', 'Top',    Top);
    IniFile.WriteInteger('Window', 'Left',   Left);
    IniFile.WriteInteger('Window', 'Width',  Width);
    IniFile.WriteInteger('Window', 'Height', Height);
    IniFile.WriteString('Data', 'Server',  ServerEdit.Text);
    IniFile.WriteString('Data', 'Port',    PortEdit.Text);
    IniFile.WriteString('Data', 'Command', SendEdit.Text);
    IniFile.Free;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientForm.FormShow(Sender: TObject);
var
    IniFile : TIniFile;
begin
    if Initialized then
        Exit;
    Initialized := TRUE;
    IniFile         := TIniFile.Create(IniFileName);
    
    Top             := IniFile.ReadInteger('Window', 'Top',    Top);
    Left            := IniFile.ReadInteger('Window', 'Left',   Left);
    Width           := IniFile.ReadInteger('Window', 'Width',  Width);
    Height          := IniFile.ReadInteger('Window', 'Height', Height);

    PortEdit.Text   := IniFile.ReadString('Data', 'Port',    'telnet');
    ServerEdit.Text := IniFile.ReadString('Data', 'Server',  'localhost');
    SendEdit.Text   := IniFile.ReadString('Data', 'Command', 'LASTNAME CAESAR');

    IniFile.Free;

    DisplayMemo.Clear;
    ActiveControl := SendEdit;
    SendEdit.SelectAll;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Display a message in our display memo. Delete lines to be sure to not     }
{ overflow the memo which may have a limited capacity.                      }
procedure TClientForm.Display(Msg : String);
var
    I : Integer;
begin
    DisplayMemo.Lines.BeginUpdate;
    try
        if DisplayMemo.Lines.Count > 200 then begin
            for I := 1 to 50 do
                DisplayMemo.Lines.Delete(0);
        end;
        DisplayMemo.Lines.Add(Msg);
    finally
        DisplayMemo.Lines.EndUpdate;
{$IFNDEF VER80}
        SendMessage(DisplayMemo.Handle, EM_SCROLLCARET, 0, 0);
{$ENDIF}
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TClientForm.Timer1Timer(Sender: TObject);
begin
    if CliSocket.State = wsConnecting then
        Exit;

    if CliSocket.State <> wsConnected then
        SendButtonClick(nil)
    else
        DisconnectButtonClick(nil);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

