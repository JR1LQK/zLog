{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


Author:       François PIETTE
Object:       How to use TSmtpCli component
Creation:     09 october 1997
Version:      2.03
EMail:        http://www.overbyte.be        http://www.rtfm.be/fpiette
              francois.piette@overbyte.be   francois.piette@rtfm.be
                                            francois.piette@pophost.eunet.be
Support:      Use the mailing list twsocket@elists.org
              Follow "support" link at http://www.overbyte.be for subscription.
Legal issues: Copyright (C) 1997-2002 by François PIETTE
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
Oct 26, 1997  V1.00 Released
Jan 10, 1998  V1.01 Added a Port property
Feb 15, 1998  V1.02 Added file attachement support
Mar 06, 1998  V1.03 Check for DisplayMemo overflow (100 lines allowed)
Aug 03, 1998  V2.00 Revised for new asynchronous SMTP component version
Jul 26, 2001  V2.01 Added authentification
Sep 07, 2002  V2.02 Added Cc and Bcc fields.
              Added AllInOne demo to show how to "chain" several operations
              using OnRequest done, avoiding any wait loop. This is how event
              driven operation has to be done.
Sep 15, 2002  V2.02 Corrected typo error in BuildRcptList where CcEdi was used
              where ToEdit should.
              Thanks to konstantinos.Kokkorogiannis@diala.greenpeace.org


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit MailSnd1;

{$B-}           { Enable partial boolean evaluation   }
{$T-}           { Untyped pointers                    }
{$X+}           { Enable extended syntax              }

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, SmtpProt, StdCtrls, ExtCtrls, IniFiles;

const
    SmtpTestVersion    = 2.03;
    CopyRight : String = ' MailSnd (c) 1997-2002 F. Piette V2.03 ';

type
  TSmtpTestForm = class(TForm)
    MsgMemo: TMemo;
    DisplayMemo: TMemo;
    ToolsPanel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Subject: TLabel;
    Label4: TLabel;
    HostEdit: TEdit;
    FromEdit: TEdit;
    ToEdit: TEdit;
    SubjectEdit: TEdit;
    SignOnEdit: TEdit;
    PortEdit: TEdit;
    Label5: TLabel;
    AttachPanel: TPanel;
    Label6: TLabel;
    FileAttachMemo: TMemo;
    InfoPanel: TPanel;
    Label7: TLabel;
    ClearDisplayButton: TButton;
    ConnectButton: TButton;
    HeloButton: TButton;
    MailFromButton: TButton;
    RcptToButton: TButton;
    DataButton: TButton;
    AbortButton: TButton;
    QuitButton: TButton;
    MailButton: TButton;
    OpenButton: TButton;
    Label8: TLabel;
    SmtpClient: TSmtpCli;
    Label9: TLabel;
    Label10: TLabel;
    UsernameEdit: TEdit;
    PasswordEdit: TEdit;
    AuthComboBox: TComboBox;
    Label11: TLabel;
    EhloButton: TButton;
    AuthButton: TButton;
    Label12: TLabel;
    CcEdit: TEdit;
    Label13: TLabel;
    BccEdit: TEdit;
    AllInOneButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ClearDisplayButtonClick(Sender: TObject);
    procedure ConnectButtonClick(Sender: TObject);
    procedure SmtpClientRequestDone(Sender: TObject; RqType: TSmtpRequest;
      Error: Word);
    procedure HeloButtonClick(Sender: TObject);
    procedure MailFromButtonClick(Sender: TObject);
    procedure RcptToButtonClick(Sender: TObject);
    procedure DataButtonClick(Sender: TObject);
    procedure AbortButtonClick(Sender: TObject);
    procedure QuitButtonClick(Sender: TObject);
    procedure MailButtonClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EhloButtonClick(Sender: TObject);
    procedure AuthButtonClick(Sender: TObject);
    procedure AllInOneButtonClick(Sender: TObject);
    procedure SmtpClientDisplay(Sender: TObject; Msg: String);
    procedure SmtpClientGetData(Sender: TObject; LineNum: Integer;
      MsgLine: Pointer; MaxLen: Integer; var More: Boolean);
    procedure SmtpClientHeaderLine(Sender: TObject; Msg: Pointer;
      Size: Integer);
  private
    FIniFileName  : String;
    FInitialized  : Boolean;
    FAllInOneFlag : Boolean;
    procedure Display(const Msg : String);
    procedure BuildRcptList;
    procedure ExceptionHandler(Sender: TObject; E: Exception);
  end;

var
  SmtpTestForm: TSmtpTestForm;

implementation

{$R *.DFM}
const
    SectionData   = 'Data';
    KeyHost       = 'HostName';
    KeyPort       = 'Port';
    KeyFrom       = 'From';
    KeyTo         = 'To';
    KeyCc         = 'Cc';
    KeyBcc        = 'Bcc';
    KeySubject    = 'Subject';
    KeySignOn     = 'SignOn';
    KeyUser       = 'UserName';
    KeyPass       = 'Password';
    KeyAuth       = 'Authentification';
    SectionWindow = 'Window';
    KeyTop        = 'Top';
    KeyLeft       = 'Left';
    KeyWidth      = 'Width';
    KeyHeight     = 'Height';

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Display a message in display memo box, making sure we don't overflow it.  }
procedure TSmtpTestForm.Display(const Msg : String);
begin
    DisplayMemo.Lines.BeginUpdate;
    try
        if DisplayMemo.Lines.Count > 200 then begin
            { We preserve only 200 lines }
            while DisplayMemo.Lines.Count > 200 do
                DisplayMemo.Lines.Delete(0);
        end;
        DisplayMemo.Lines.Add(Msg);
    finally
        DisplayMemo.Lines.EndUpdate;
        { Makes last line visible }
        {$IFNDEF VER80}
        SendMessage(DisplayMemo.Handle, EM_SCROLLCARET, 0, 0);
        {$ENDIF}
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.FormCreate(Sender: TObject);
begin
    Application.OnException := ExceptionHandler;
    DisplayMemo.Clear;
    FIniFileName := LowerCase(ExtractFileName(Application.ExeName));
    FIniFileName := Copy(FIniFileName, 1, Length(FIniFileName) - 3) + 'ini';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.FormShow(Sender: TObject);
var
    IniFile : TIniFile;
begin
    if not FInitialized then begin
        FInitialized := TRUE;
        IniFile := TIniFile.Create(FIniFileName);
        HostEdit.Text    := IniFile.ReadString(SectionData, KeyHost,
                                               'localhost');
        PortEdit.Text    := IniFile.ReadString(SectionData, KeyPort,
                                               'smtp');
        FromEdit.Text    := IniFile.ReadString(SectionData, KeyFrom,
                                               'first.last@company.com');
        ToEdit.Text      := IniFile.ReadString(SectionData, KeyTo,
                                               'john.doe@acme;tartempion@brol.fr');
        CcEdit.Text      := IniFile.ReadString(SectionData, KeyCc,
                                               '');
        BccEdit.Text     := IniFile.ReadString(SectionData, KeyBcc,
                                               'francois.piette@swing.be');
        SubjectEdit.Text := IniFile.ReadString(SectionData, KeySubject,
                                               'This is the message subject');
        SignOnEdit.Text  := IniFile.ReadString(SectionData, KeySignOn,
                                               'your name');
        UsernameEdit.Text :=  IniFile.ReadString(SectionData, KeyUser,
                                               'account name');
        PasswordEdit.Text      :=  IniFile.ReadString(SectionData, KeyPass,
                                               'account password');
        AuthComboBox.ItemIndex :=  IniFile.ReadInteger(SectionData, KeyAuth,
                                               0);

        Top    := IniFile.ReadInteger(SectionWindow, KeyTop,    (Screen.Height - Height) div 2);
        Left   := IniFile.ReadInteger(SectionWindow, KeyLeft,   (Screen.Width - Width) div 2);
        Width  := IniFile.ReadInteger(SectionWindow, KeyWidth,  Width);
        Height := IniFile.ReadInteger(SectionWindow, KeyHeight, Height);

        IniFile.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
    IniFile : TIniFile;
begin
    IniFile := TIniFile.Create(FIniFileName);
    IniFile.WriteString(SectionData, KeyHost,      HostEdit.Text);
    IniFile.WriteString(SectionData, KeyPort,      PortEdit.Text);
    IniFile.WriteString(SectionData, KeyFrom,      FromEdit.Text);
    IniFile.WriteString(SectionData, KeyTo,        ToEdit.Text);
    IniFile.WriteString(SectionData, KeyCc,        CcEdit.Text);
    IniFile.WriteString(SectionData, KeyBcc,       BccEdit.Text);
    IniFile.WriteString(SectionData, KeySubject,   SubjectEdit.Text);
    IniFile.WriteString(SectionData, KeySignOn,    SignOnEdit.Text);
    IniFile.WriteString(SectionData, KeyUser,      UsernameEdit.Text);
    IniFile.WriteString(SectionData, KeyPass,      PasswordEdit.Text);
    IniFile.WriteInteger(SectionData, KeyAuth,     AuthComboBox.ItemIndex);
    IniFile.WriteInteger(SectionWindow, KeyTop,    Top);
    IniFile.WriteInteger(SectionWindow, KeyLeft,   Left);
    IniFile.WriteInteger(SectionWindow, KeyWidth,  Width);
    IniFile.WriteInteger(SectionWindow, KeyHeight, Height);
    IniFile.Free;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF VER80}
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
procedure TSmtpTestForm.BuildRcptList;
var
    Buf : String;
    I   : Integer;
begin
    SmtpClient.RcptName.Clear;
    // Recipient list is the sum of To, Cc and Bcc fields
    Buf := '';
    if Length(Trim(ToEdit.Text)) > 0 then
        Buf := Trim(ToEdit.Text);
    if Length(Trim(CcEdit.Text)) > 0 then
        Buf := Buf + ';' + Trim(CcEdit.Text);
    if Length(Trim(BccEdit.Text)) > 0 then
        Buf := Buf + ';' + Trim(BccEdit.Text);
    if (Length(Buf) > 0) and (Buf[1] = ';') then
        Buf := Trim(Copy(Buf, 2, Length(Buf)));
    while TRUE do begin
        I := Pos(';', Buf);
        if I <= 0 then begin
            SmtpClient.RcptName.Add(Trim(Buf));
            break;
        end
        else begin
            SmtpClient.RcptName.Add(Trim(Copy(Buf, 1, I - 1)));
            Delete(Buf, 1, I);
        end;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.SmtpClientDisplay(Sender: TObject; Msg: String);
begin
    Display(Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.SmtpClientGetData(
    Sender  : TObject;
    LineNum : Integer;
    MsgLine : Pointer;
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
procedure TSmtpTestForm.SmtpClientHeaderLine(
    Sender : TObject;
    Msg    : Pointer;
    Size   : Integer);
begin
    { This demonstrate how to add a line to the message header              }
    { Just detect one of the header lines and add text at the end of this   }
    { line. Use #13#10 to form a new line                                   }
    { Here we check for the From: header line and add a Comments: line      }
    if StrLIComp(Msg, 'From:', 5) = 0 then
        StrCat(Msg, #13#10 + 'Comments: This is a test');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.ClearDisplayButtonClick(Sender: TObject);
begin
    DisplayMemo.Clear;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.ExceptionHandler(Sender: TObject; E: Exception);
begin
    Application.ShowException(E);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Connect to the mail server }
procedure TSmtpTestForm.ConnectButtonClick(Sender: TObject);
begin
    FAllInOneFlag   := FALSE;
    SmtpClient.Host := HostEdit.Text;
    SmtpClient.Port := PortEdit.Text;
    SmtpClient.Connect;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Send HELO command with our local identification }
procedure TSmtpTestForm.HeloButtonClick(Sender: TObject);
begin
    FAllInOneFlag              := FALSE;
    SmtpClient.SignOn          := SignOnEdit.Text;
    SmtpClient.Helo;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.EhloButtonClick(Sender: TObject);
begin
    FAllInOneFlag              := FALSE;
    SmtpClient.SignOn          := SignOnEdit.Text;
    SmtpClient.EHlo;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.AuthButtonClick(Sender: TObject);
begin
    FAllInOneFlag              := FALSE;
    SmtpClient.Username        := UsernameEdit.Text;
    SmtpClient.Password        := PasswordEdit.Text;
    SmtpClient.AuthType        := TSmtpAuthType(AuthComboBox.ItemIndex);
    SmtpClient.Auth;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Open is Connect and Helo methods combined }
procedure TSmtpTestForm.OpenButtonClick(Sender: TObject);
begin
    FAllInOneFlag              := FALSE;
    SmtpClient.Host   := HostEdit.Text;
    SmtpClient.Port   := PortEdit.Text;
    SmtpClient.SignOn := SignOnEdit.Text;
    SmtpClient.Open;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Send originator }
procedure TSmtpTestForm.MailFromButtonClick(Sender: TObject);
begin
    FAllInOneFlag              := FALSE;
    SmtpClient.FromName        := FromEdit.Text;
    SmtpClient.MailFrom;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Send recipients }
procedure TSmtpTestForm.RcptToButtonClick(Sender: TObject);
begin
    FAllInOneFlag              := FALSE;
    BuildRcptList;
    SmtpClient.RcptTo;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ Send text and attached files to mail server }
procedure TSmtpTestForm.DataButtonClick(Sender: TObject);
begin
    FAllInOneFlag              := FALSE;
    BuildRcptList;
    SmtpClient.HdrFrom         := FromEdit.Text;
    SmtpClient.HdrTo           := ToEdit.Text;
    SmtpClient.HdrCc           := CcEdit.Text;
    SmtpClient.HdrSubject      := SubjectEdit.Text;
    SmtpClient.EmailFiles      := FileAttachMemo.Lines;
    SmtpClient.Data;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ MailFrom, RcptTo and Data methods combined }
procedure TSmtpTestForm.MailButtonClick(Sender: TObject);
begin
    FAllInOneFlag              := FALSE;
    BuildRcptList;
    SmtpClient.HdrFrom         := FromEdit.Text;
    SmtpClient.HdrTo           := ToEdit.Text;
    SmtpClient.HdrTo           := CcEdit.Text;
    SmtpClient.HdrSubject      := SubjectEdit.Text;
    SmtpClient.SignOn          := SignOnEdit.Text;
    SmtpClient.FromName        := FromEdit.Text;
    SmtpClient.EmailFiles      := FileAttachMemo.Lines;
    SmtpClient.Host            := HostEdit.Text;
    SmtpClient.Port            := PortEdit.Text;
    SmtpClient.Mail;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.QuitButtonClick(Sender: TObject);
begin
    FAllInOneFlag              := FALSE;
    SmtpClient.Quit;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.AbortButtonClick(Sender: TObject);
begin
    FAllInOneFlag              := FALSE;
    SmtpClient.Abort;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.SmtpClientRequestDone(
    Sender : TObject;
    RqType : TSmtpRequest;
    Error  : Word);
begin
    { For every operation, we display the status }
    Display('RequestDone Rq=' + IntToStr(Ord(RqType)) +
                          ' Error='+ IntToStr(Error));
    { Check if the user has asked for "All-In-One" demo }
    if not FAllInOneFlag then
        Exit;             { No, nothing more to do here }
    { We are in "All-In-One" demo, start next operation }
    { But first check if previous one was OK            }
    if Error <> 0 then begin
        FAllInOneFlag := FALSE;   { Terminate All-In-One demo }
        Display('Error, stoped All-In-One demo');
        Exit;
    end;
    case RqType of
    smtpConnect:  SmtpClient.Helo;
    smtpHelo:     SmtpClient.MailFrom;
    smtpMailFrom: SmtpClient.RcptTo;
    smtpRcptTo:   SmtpClient.Data;
    smtpData:     SmtpClient.Quit;
    smtpQuit:     Display('All-In-One done !');
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSmtpTestForm.AllInOneButtonClick(Sender: TObject);
begin
    if SmtpClient.Connected then begin
        MessageBeep(MB_OK);
        Display('All-In-One demo start in non connected state.');
        Display('Please quit or abort the connection first.');
        Exit;
    end;

    FAllInOneFlag              := TRUE;

    { Initialize all SMTP component properties from our GUI }
    SmtpClient.Host            := HostEdit.Text;
    SmtpClient.Port            := PortEdit.Text;
    SmtpClient.SignOn          := SignOnEdit.Text;
    SmtpClient.FromName        := FromEdit.Text;
    SmtpClient.HdrFrom         := FromEdit.Text;
    SmtpClient.HdrTo           := ToEdit.Text;
    SmtpClient.HdrCc           := CcEdit.Text;
    SmtpClient.HdrSubject      := SubjectEdit.Text;
    SmtpClient.EmailFiles      := FileAttachMemo.Lines;
    { Recipient list is computed from To, Cc and Bcc fields }
    { We use a little function to do that.                  }
    BuildRcptList;
    { Start first operation to do to send an email          }
    { Next operations are started from OnRequestDone event  }
    SmtpClient.Connect
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

