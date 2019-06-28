{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


Author:       François PIETTE
Object:       How to use TSMTPClient
EMail:        francois.piette@ping.be
              francois.piette@f2202.n293.z2.fidonet.org
              2:293/2202@fidonet.org, BBS +32-4-3651395
WebSite:      http://www.rtfm.be/fpiette
Creation:     09 october 1997
Version:      1.00
Support:      Use twsocket@rtfm.be mailing list. See website for details.
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
Oct 26, 1997 V1.00 Released


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit smtptst1;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, SmtpCli, StdCtrls, Wait;

type
  TSmtpTestForm = class(TForm)
    SmtpClient: TSmtpClient;
    Wait1: TWait;
    MsgMemo: TMemo;
    DisplayMemo: TMemo;
    Label1: TLabel;
    HostEdit: TEdit;
    Label2: TLabel;
    FromEdit: TEdit;
    Label3: TLabel;
    ToEdit: TEdit;
    ConnectButton: TButton;
    MailButton: TButton;
    SubjectEdit: TEdit;
    Subject: TLabel;
    DisconnectButton: TButton;
    SignOnEdit: TEdit;
    procedure ConnectButtonClick(Sender: TObject);
    procedure MailButtonClick(Sender: TObject);
    procedure SmtpClientDisplay(Sender: TObject; Msg: String);
    procedure DisconnectButtonClick(Sender: TObject);
    procedure SmtpClientGetData(Sender: TObject; LineNum: Integer;
      MsgLine: PChar; MaxLen: Integer; var More: Boolean);
    procedure SmtpClientHeaderLine(Sender: TObject; Msg: PChar;
      Size: Integer);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  SmtpTestForm: TSmtpTestForm;

implementation

{$R *.DFM}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.ConnectButtonClick(Sender: TObject);
begin
    SmtpClient.Host := HostEdit.Text;
    SmtpClient.Connect;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.MailButtonClick(Sender: TObject);
begin
    SmtpClient.Host       := HostEdit.Text;
    SmtpClient.HdrFrom    := FromEdit.Text;
    SmtpClient.HdrTo      := ToEdit.Text;
    SmtpClient.HdrSubject := SubjectEdit.Text;
    SmtpClient.SignOn     := SignOnEdit.Text;           
    SmtpClient.FromName   := FromEdit.Text;
    SmtpClient.RcptName.Clear;
    SmtpClient.RcptName.Add(ToEdit.Text);
    SmtpClient.Mail;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.SmtpClientDisplay(Sender: TObject; Msg: String);
begin
    DisplayMemo.Lines.Add(Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.DisconnectButtonClick(Sender: TObject);
begin
    SmtpClient.Quit;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.SmtpClientGetData(
    Sender  : TObject;
    LineNum : Integer;
    MsgLine : PChar;
    MaxLen  : Integer;
    var More: Boolean);
var
    Len : Integer;
begin
    if LineNum > MsgMemo.Lines.count then
        More := FALSE
    else begin
        Len := Length(MsgMemo.Lines[LineNum - 1]);
        { Truncate the line if too long (should wrap to next line) }
        if Len >= MaxLen then
            StrPCopy(MsgLine, Copy(MsgMemo.Lines[LineNum - 1], 1, MaxLen - 1))
        else
            StrPCopy(MsgLine, MsgMemo.Lines[LineNum - 1]);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.SmtpClientHeaderLine(Sender: TObject; Msg: PChar;
  Size: Integer);
begin
    { This demonstrate how to add a line to the message header              }
    { Just detect one of the header lines and add text at the end of this   }
    { line. Use #13#10 to form a new line                                   }
    { Here we check for the From: header line and add a Comments: line      }
    if StrLIComp(Msg, 'From:', 5) = 0 then
        StrCat(Msg, #13#10 + 'Comments: This is a test');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
