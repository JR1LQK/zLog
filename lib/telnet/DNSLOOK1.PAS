{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Description:  Demonstrate how to use TWSocket to asynchroneously resolve a
              host name to an IP address.
EMail:        francois.piette@ping.be  http://www.rtfm.be/fpiette
              francois.piette@f2202.n293.z2.fidonet.org
              2:293/2202@fidonet.org, BBS +32-4-3651395
Creation:     October 29, 1997
Version:      1.02
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
Oct 30, 1997 V1.01 Made the code compatible with Delphi 1.
Oct 31, 1997 V1.02 Added a cancel button

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit DnsLook1;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, WinSock, WSocket, StdCtrls;

type
  TDnsLookupForm = class(TForm)
    WSocket1: TWSocket;
    HostEdit: TEdit;
    Label1: TLabel;
    IPLabel: TLabel;
    LookupButton: TButton;
    CancelButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure LookupButtonClick(Sender: TObject);
    procedure WSocket1DnsLookupDone(Sender: TObject; Error: Word);
    procedure CancelButtonClick(Sender: TObject);
  end;

var
  DnsLookupForm: TDnsLookupForm;

implementation

{$R *.DFM}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDnsLookupForm.FormCreate(Sender: TObject);
begin
    IPLabel.Caption      := '';
    LookupButton.Enabled := TRUE;
    CancelButton.Enabled := FALSE;
    HostEdit.Text        := LocalHostName;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDnsLookupForm.LookupButtonClick(Sender: TObject);
begin
    LookupButton.Enabled := FALSE;     { Prevent recursive call            }
    CancelButton.Enabled := TRUE;      { Enable canceling                  }
    HostEdit.SelectAll;                { handy for the user                }
    ActiveControl   := HostEdit;       { he likes to have the cursor there }
    IPLabel.Caption := 'Waiting for DNS...';
    WSocket1.DnsLookup(HostEdit.Text); { Start DnsLookup                   }
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDnsLookupForm.WSocket1DnsLookupDone(Sender: TObject;
  Error: Word);
begin
    if Error = 0 then
        IPLabel.Caption  := WSocket1.DnsResult
    else
        IPLabel.Caption  := 'NOT FOUND, ERROR #' + IntToStr(Error);
    LookupButton.Enabled := TRUE;
    CancelButton.Enabled := FALSE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TDnsLookupForm.CancelButtonClick(Sender: TObject);
begin
    IPLabel.Caption      := '';
    LookupButton.Enabled := TRUE;
    CancelButton.Enabled := FALSE;
    ActiveControl        := HostEdit;
    WSocket1.CancelDnsLookup;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

