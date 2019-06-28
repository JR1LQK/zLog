{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Email:        francois.piette@ping.be  http://www.rtfm.be/fpiette
              francois.piette@f2202.n293.z2.fidonet.org
              BBS: +32-4-365.13.95
Copyright:    You can use this software freely, at your own risks
Creation:     April 4, 1997
Version:      2.01
Object:       Demo program to show how to use TWSocket object to broadcast
              UDP messages on the network. Use UDPLstn to listen to those
              UDP messages, or other UDP messages.
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
Sep 06, 1997 Version 2.01

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit UdpSend1;

interface

uses
  WinTypes, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FormPos, StdCtrls, Wsocket, IniFiles;

type
  TMainForm = class(TForm)
    WSocket: TWSocket;
    SendButton: TButton;
    MessageEdit: TEdit;
    PortEdit: TEdit;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SendButtonClick(Sender: TObject);
  private
    FIniFileName : String;
    FSectionName : String;
    FKeyName     : String;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMainForm.FormShow(Sender: TObject);
const
    FirstTime : Boolean = TRUE;
var
    IniFile   : TIniFile;
begin
    if FirstTime then begin
        FirstTime        := FALSE;
        FIniFileName     := 'UdpSend';
        FSectionName     := 'Windows';
        FKeyName         := 'MainForm';
        LoadFormPos(Self, FIniFilename, FSectionName, FKeyName);
        IniFile          := TIniFile.Create(FIniFileName);
        PortEdit.Text    := IniFile.ReadString('data', 'port', '600');
        MessageEdit.Text := IniFile.ReadString('data', 'message', '');
        IniFile.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
    IniFile   : TIniFile;
begin
    SaveFormPos(Self, FIniFilename, FSectionName, FKeyName);
    IniFile := TIniFile.Create(FIniFileName);
    IniFile.WriteString('data', 'port', PortEdit.Text);
    IniFile.WriteString('data', 'message', MessageEdit.Text);
    IniFile.Free;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TMainForm.SendButtonClick(Sender: TObject);
begin
    WSocket.Proto := 'udp';
    WSocket.Addr  := '255.255.255.255';
    WSocket.Port  := PortEdit.Text;
    WSocket.Connect;
    WSocket.SendStr(MessageEdit.Text);
    WSocket.Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

