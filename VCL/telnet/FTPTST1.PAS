{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE
Email:        francois.piette@ping.be  http://www.rtfm.be/fpiette
              2:293/2202@fidonet.org, BBS +32-4-3651395
Copyright:    You can use this software freely, at your own risks
Creation:     Aug 1997
Object:       Demo for TFtpClient object (RFC 959 implementation)
              It is a graphical FTP client program
              Compatible with Delphi 1, 2 and 3
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
Sep 13, 97  Added directory functions
            Added button to show how to makes several transferts in one session
Sep 27, 97  Change identifiers names to be more standard with other sources

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit Ftptst1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, FtpCli, StdCtrls, Wait; 

type
  TFtpReceiveForm = class(TForm)
    QuitButton: TButton;
    HostNameEdit: TEdit;
    Label1: TLabel;
    HostFileEdit: TEdit;
    Label3: TLabel;
    UserNameEdit: TEdit;
    PassWordEdit: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    ReceiveButton: TButton;
    DisplayMemo: TMemo;
    cbDisplay: TCheckBox;
    LocalFileEdit: TEdit;
    Label2: TLabel;
    cbBinary: TCheckBox;
    HostDirEdit: TEdit;
    Wait1: TWait;
    FtpClient1: TFtpClient;
    SendButton: TButton;
    InfoLabel: TLabel;
    DirectoryButton: TButton;
    ListButton: TButton;
    TestButton: TButton;
    AbortButton: TButton;
    MkdirButton: TButton;
    RmdirButton: TButton;
    DeleteButton: TButton;
    RenameButton: TButton;
    procedure QuitButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ReceiveButtonClick(Sender: TObject);
    procedure Display(Sender: TObject; var Msg : String);
    procedure FormResize(Sender: TObject);
    procedure SendButtonClick(Sender: TObject);
    procedure FtpClient1Progress(Sender: TObject; Count: Longint;
      var Abort: Boolean);
    procedure DirectoryButtonClick(Sender: TObject);
    procedure ListButtonClick(Sender: TObject);
    procedure TestButtonClick(Sender: TObject);
    procedure AbortButtonClick(Sender: TObject);
    procedure MkdirButtonClick(Sender: TObject);
    procedure RmdirButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure RenameButtonClick(Sender: TObject);
  private
  public
  end;

const
  TEMP_FILE_NAME = 'FTPDIR.TXT';

var
  FtpReceiveForm: TFtpReceiveForm;

implementation

uses
  FtpTst2;

{$R *.DFM}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.QuitButtonClick(Sender: TObject);
begin
    Close;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FormCreate(Sender: TObject);
begin
    DisplayMemo.Clear;
    FtpClient1.Left   := -32;
    InfoLabel.Caption := '';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.Display(Sender : TObject; var Msg : String);
begin
    DisplayMemo.Lines.Add(Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.ReceiveButtonClick(Sender: TObject);
begin
    DisplayMemo.Clear;

    ReceiveButton.Enabled := FALSE;
    SendButton.Enabled    := FALSE;
    DisplayMemo.Lines.Add('Trying to connect');
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.Binary          := cbBinary.Checked;
    FtpClient1.DisplayFlag     := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    FtpClient1.Receive;
    DisplayMemo.Lines.Add(FtpClient1.ErrorMessage);
    SendButton.Enabled  := TRUE;
    ReceiveButton.Enabled := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.SendButtonClick(Sender: TObject);
begin
    DisplayMemo.Clear;

    SendButton.Enabled    := FALSE;
    ReceiveButton.Enabled := FALSE;
    DisplayMemo.Lines.Add('Trying to connect');
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.Binary          := cbBinary.Checked;
    FtpClient1.DisplayFlag     := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    FtpClient1.Transmit;
    DisplayMemo.Lines.Add(FtpClient1.ErrorMessage);
    SendButton.Enabled    := TRUE;
    ReceiveButton.Enabled := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FormResize(Sender: TObject);
begin
    DisplayMemo.Width   := ClientWidth - (2 * QuitButton.Width) - 24;
    DisplayMemo.Height  := ClientHeight - DisplayMemo.Top - 6;
    QuitButton.Left     := DisplayMemo.Left + DisplayMemo.Width + 6; //ClientWidth - (2 * QuitButton.Width);
    ReceiveButton.Left  := QuitButton.Left;
    SendButton.Left     := QuitButton.Left;
    DirectoryButton.left:= QuitButton.Left;
    ListButton.Left     := QuitButton.Left;
    TestButton.Left     := QuitButton.Left;
    AbortButton.Left    := QuitButton.Left;
    MkdirButton.Left    := QuitButton.Left;
    InfoLabel.Left      := QuitButton.Left;
    Wait1.Left          := QuitButton.Left;
    Wait1.Width         := QuitButton.Width;
    QuitButton.Top      := ClientHeight - QuitButton.Height - 6;
    ReceiveButton.Top   := QuitButton.Top - ReceiveButton.Height - 6;
    SendButton.Top      := ReceiveButton.Top - SendButton.Height - 6;
    DirectoryButton.Top := SendButton.Top - DirectoryButton.Height - 6;
    ListButton.Top      := DirectoryButton.Top - ListButton.Height - 6;
    TestButton.Top      := ListButton.Top - TestButton.Height - 6;
    AbortButton.Top     := TestButton.Top - AbortButton.Height - 6;
    MkdirButton.Top     := AbortButton.Top - MkdirButton.Height - 6;
    HostFileEdit.Width  := ClientWidth - HostFileEdit.Left - 6;
    LocalFileEdit.Width := ClientWidth - LocalFileEdit.Left - 6;

    RmdirButton.Left    := QuitButton.Left + QuitButton.Width + 6;
    RmdirButton.Top     := MkdirButton.Top;
    DeleteButton.Left   := RmdirButton.Left;
    DeleteButton.Top    := AbortButton.Top;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.FtpClient1Progress(Sender: TObject;
  Count: Longint; var Abort: Boolean);
begin
    InfoLabel.Caption := IntToStr(Count);
    InfoLabel.Repaint;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.DirectoryButtonClick(Sender: TObject);
begin
    DisplayMemo.Clear;

    ReceiveButton.Enabled := FALSE;
    SendButton.Enabled    := FALSE;
    DisplayMemo.Lines.Add('Trying to connect');
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := TEMP_FILE_NAME;
    FtpClient1.Binary          := FALSE;
    FtpClient1.DisplayFlag     := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    FtpClient1.Directory;
    DisplayMemo.Lines.Add(FtpClient1.ErrorMessage);
    try
        DirectoryForm.DirListBox.Items.LoadFromFile(TEMP_FILE_NAME);
    except
        DirectoryForm.DirListBox.Clear;
    end;
    DirectoryForm.ShowModal;
    SendButton.Enabled  := TRUE;
    ReceiveButton.Enabled := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.ListButtonClick(Sender: TObject);
begin
    DisplayMemo.Clear;

    ReceiveButton.Enabled := FALSE;
    SendButton.Enabled    := FALSE;
    DisplayMemo.Lines.Add('Trying to connect');
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := TEMP_FILE_NAME;
    FtpClient1.Binary          := FALSE;
    FtpClient1.DisplayFlag     := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    FtpClient1.List;
    DisplayMemo.Lines.Add(FtpClient1.ErrorMessage);
    DirectoryForm.DirListBox.Items.LoadFromFile(TEMP_FILE_NAME);
    DirectoryForm.ShowModal;
    SendButton.Enabled  := TRUE;
    ReceiveButton.Enabled := TRUE;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.TestButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.Binary          := FALSE;
    FtpClient1.DisplayFlag     := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    if not FtpClient1.Connect then
        Exit;
    if not FtpClient1.Cwd then
        Exit;

    FtpClient1.HostFileName    := 'UPLOAD.TXT';
    FtpClient1.LocalFileName   := 'upload.txt';
    FtpClient1.Get;

    FtpClient1.HostFileName    := 'CDROMS.TXT';
    FtpClient1.LocalFileName   := 'cdroms.txt';
    FtpClient1.Get;

    FtpClient1.Quit;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.AbortButtonClick(Sender: TObject);
begin
    if not FtpClient1.IsConnected then
        DisplayMemo.Lines.Add('Not connected !')
    else begin
        FtpClient1.Abort;
        DisplayMemo.Lines.Add('***** Aborted by user request *****');
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.MkdirButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.DisplayFlag     := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    if not FtpClient1.Mkdir then
        Exit;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.RmdirButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.DisplayFlag     := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    if not FtpClient1.Rmdir then
        Exit;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.DeleteButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.DisplayFlag     := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    if not FtpClient1.Delete then
        Exit;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFtpReceiveForm.RenameButtonClick(Sender: TObject);
begin
    FtpClient1.HostName        := HostNameEdit.Text;
    FtpClient1.UserName        := UserNameEdit.Text;
    FtpClient1.PassWord        := PassWordEdit.Text;
    FtpClient1.HostDirName     := HostDirEdit.Text;
    FtpClient1.HostFileName    := HostFileEdit.Text;
    FtpClient1.LocalFileName   := LocalFileEdit.Text;
    FtpClient1.DisplayFlag     := cbDisplay.Checked;
    FtpClient1.OnDisplay       := Display;
    if not FtpClient1.Rename then
        Exit;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

