{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Program:      TNCLIENT.PAS
Object:       Delphi application which is a basic telnet program demonstrating
              WSocket, TnCnx, TnEmulVT, EmulVT components.
Author:       François PIETTE
Copyright:    You can use this software freely, at your own risks
              If you use my work, a little credit is appreciated.
EMail:        francois.piette@ping.be  http://www.rtfm.be/fpiette
              francois.piette@f2202.n293.z2.fidonet.org
              2:293/2202@fidonet.org, BBS +32-4-3651395
Creation:     July 22, 1997
Version:      2.04
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
Sep 05, 1997  Added display of windows socket version info.
Sep 23, 1997  Added local echo check box
Sep 24, 1997  V203. Added TnEmulVT1.RestoreOptions just before connecting
              Added interactive support for telnet echo option.
Sep 25, 1997  V204. Port to C++Builder

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit TnCli1;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, EmulVT, TnEmulVT, WSocket, Winsock;

type
  TTelnetForm = class(TForm)
    TnEmulVT1: TTnEmulVT;
    ConnectButton: TButton;
    Label1: TLabel;
    HostNameEdit: TEdit;
    Label2: TLabel;
    PortEdit: TEdit;
    DisconnectButton: TButton;
    StatusLabel: TLabel;
    SendButton: TButton;
    OptionsButton: TButton;
    LocalEchoCheckBox: TCheckBox;
    RequestLocalEchoOnButton: TButton;
    RequestLocalEchoOffButton: TButton;
    procedure ConnectButtonClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DisconnectButtonClick(Sender: TObject);
    procedure TnEmulVT1SessionConnected(Sender: TObject);
    procedure TnEmulVT1SessionClosed(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SendButtonClick(Sender: TObject);
    procedure OptionsButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LocalEchoCheckBoxClick(Sender: TObject);
    procedure TnEmulVT1LocalEcho(Sender: TObject);
    procedure RequestLocalEchoOnButtonClick(Sender: TObject);
    procedure RequestLocalEchoOffButtonClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  TelnetForm: TTelnetForm;

implementation

{$R *.DFM}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.ConnectButtonClick(Sender: TObject);
begin
    StatusLabel.Caption := 'Connecting';
    Refresh;
    ConnectButton.Enabled := FALSE;
    try
        TnEmulVT1.Disconnect;
        TnEmulVT1.Port     := PortEdit.Text;
        TnEmulVT1.HostName := HostNameEdit.Text;
        TnEmulVT1.RestoreOptions;
        { This can take quite a long time when hostname is unknown and }
        { if DNS feature is enabled (2 or 3 minutes !)                 }
        TnEmulVT1.Connect;
    except
        ConnectButton.Enabled := TRUE;
        raise;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.DisconnectButtonClick(Sender: TObject);
begin
    TnEmulVT1.Disconnect;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.TnEmulVT1SessionConnected(Sender: TObject);
begin
    DisconnectButton.Enabled := TRUE;
    StatusLabel.Caption      := 'Connected';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.TnEmulVT1SessionClosed(Sender: TObject);
begin
    DisconnectButton.Enabled := FALSE;
    ConnectButton.Enabled    := TRUE;
    StatusLabel.Caption      := 'Not connected';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.FormCreate(Sender: TObject);
begin
    StatusLabel.Caption := 'Not connected';
    TnEmulVT1.RestoreOptions;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.FormResize(Sender: TObject);
begin
    TnEmulVT1.Width  := ClientWidth;
    TnEmulVT1.Height := ClientHeight - TnEmulVT1.Top;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.SendButtonClick(Sender: TObject);
begin
    TnEmulVT1.SendStr('Hello world !' + #13#10);
    ActiveControl := TnEmulVT1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.OptionsButtonClick(Sender: TObject);
begin
    TnEmulVT1.HostName := HostNameEdit.Text;
    TnEmulVT1.EditOptions;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.FormShow(Sender: TObject);
var
    WinsockData : TWSADATA;
begin
    WinsockData := WinsockInfo;
    StatusLabel.Caption := StrPas(WinsockData.szDescription);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.TnEmulVT1LocalEcho(Sender: TObject);
begin
    if TnEmulVT1.GetLocalEcho then
        StatusLabel.Caption := 'Remote will not echo'
    else
        StatusLabel.Caption := 'Remote will echo';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.LocalEchoCheckBoxClick(Sender: TObject);
begin
    TnEmulVT1.LocalEcho := LocalEchoCheckBox.Checked;
    ActiveControl       := TnEmulVT1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.RequestLocalEchoOnButtonClick(Sender: TObject);
begin
    TnEmulVT1.RequestLocalEcho(TRUE);
    ActiveControl       := TnEmulVT1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TTelnetForm.RequestLocalEchoOffButtonClick(Sender: TObject);
begin
    TnEmulVT1.RequestLocalEcho(FALSE);
    ActiveControl       := TnEmulVT1;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

