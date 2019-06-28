{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

   BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA
   BETA                                                             BETA
   BETA              THIS IS BETA CODE. USE ONLY FOR TESTING        BETA
   BETA           EVERYTHING CAN CHANGE IN THE REALEASE VERSION     BETA
   BETA                                                             BETA
   BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA

Author:       François PIETTE
Email:        francois.piette@ping.be  http://www.rtfm.be/fpiette
              francois.piette@rtfm.be
Creation:     November 23, 1997
Version:      0.91 BETA
Description:  Sample program to demonstrate some of the THttpCli features.
Support:      There is a mailing list for support. See web site for
              subscription http://www.rtfm.be/fpiette/supportuk.htm
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

  BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA
  BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA BETA

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit httptst1;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, HttpProt, WSocket, StdCtrls, ExtCtrls, IniFiles;

const
  IniFileName = 'httptest';

type
  THttpTestForm = class(TForm)
    Panel1: TPanel;
    GetButton: TButton;
    HttpCli1: THttpCli;
    URLEdit: TEdit;
    DisplayMemo: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    ProxyHostEdit: TEdit;
    ProxyPortEdit: TEdit;
    PostButton: TButton;
    Check64Button: TButton;
    DataEdit: TEdit;
    Label3: TLabel;
    procedure GetButtonClick(Sender: TObject);
    procedure HttpCli1AnswerLine(Sender: TObject);
    procedure HttpCli1Command(Sender: TObject; const s: String);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure HttpCli1DocBegin(Sender: TObject);
    procedure HttpCli1DocEnd(Sender: TObject);
    procedure PostButtonClick(Sender: TObject);
    procedure Check64ButtonClick(Sender: TObject);
  private
    { Déclarations privées }
    Initialized : Boolean;
  public
    { Déclarations publiques }
  end;

var
  HttpTestForm: THttpTestForm;

implementation

{$R *.DFM}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpTestForm.FormShow(Sender: TObject);
var
    IniFile : TIniFile;
begin
    if not Initialized then begin
        Initialized        := TRUE;
        IniFile            := TIniFile.Create(IniFileName);
        URLEdit.Text       := IniFile.ReadString('Data', 'URL',       '');
        ProxyHostEdit.Text := IniFile.ReadString('Data', 'ProxyHost', '');
        ProxyPortEdit.Text := IniFile.ReadString('Data', 'ProxyPort', '80');
        DataEdit.Text      := IniFile.ReadString('Data', 'Data',      '');
        IniFile.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpTestForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
    IniFile : TIniFile;
begin
    IniFile := TIniFile.Create(IniFileName);
    IniFile.WriteString('Data', 'URL',       URLEdit.Text);
    IniFile.WriteString('Data', 'ProxyHost', ProxyHostEdit.Text);
    IniFile.WriteString('Data', 'ProxyPort', ProxyPortEdit.Text);
    IniFile.WriteString('Data', 'Data',      DataEdit.Text);
    IniFile.Free;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpTestForm.GetButtonClick(Sender: TObject);
var
    I       : Integer;
begin
    DisplayMemo.Clear;

    httpcli1.URL        := URLEdit.Text;
    httpcli1.Proxy      := ProxyHostEdit.Text;
    httpcli1.ProxyPort  := ProxyPortEdit.Text;
    httpcli1.RcvdStream := nil;
    httpcli1.Get;

    for I := 0 to httpcli1.RcvdHeader.Count - 1 do
        DisplayMemo.Lines.Add('hdr>' + httpcli1.RcvdHeader.Strings[I]);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpTestForm.PostButtonClick(Sender: TObject);
var
    Data : TMemoryStream;
    Buf  : String;
begin
    DisplayMemo.Clear;
    Data := TMemoryStream.Create;
    Buf  := DataEdit.Text;
    Data.Write(Buf[1], Length(Buf));
    Data.Seek(0, soFromBeginning);

    httpcli1.SendStream := Data;
    httpcli1.Proxy      := ProxyHostEdit.Text;
    httpcli1.ProxyPort  := ProxyPortEdit.Text;
    httpcli1.URL        := URLEdit.Text;
    httpcli1.Post;

    Data.Free;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpTestForm.HttpCli1AnswerLine(Sender: TObject);
begin
    DisplayMemo.Lines.Add(HttpCli1.AnswerLine);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpTestForm.HttpCli1Command(Sender: TObject; const s: String);
begin
    DisplayMemo.Lines.Add('cmd> ' + s);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpTestForm.HttpCli1DocBegin(Sender: TObject);
begin
    DisplayMemo.Lines.Add(HttpCli1.ContentType + ' => ' + httpcli1.DocName);
    DisplayMemo.Lines.Add('Document = ' + httpcli1.DocName);
    httpcli1.RcvdStream := TFileStream.Create(httpcli1.DocName, fmCreate);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpTestForm.HttpCli1DocEnd(Sender: TObject);
begin
    if httpcli1.RcvdStream <> nil then begin
        httpcli1.RcvdStream.Free;
        httpcli1.RcvdStream := nil;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpTestForm.Check64ButtonClick(Sender: TObject);
const
    Inp : String = 'Aladdin:open sesame';
    Res : String = 'QWxhZGRpbjpvcGVuIHNlc2FtZQ==';
begin
    if EncodeLine(encBase64, @Inp[1], Length(Inp)) <> Res then
        DisplayMemo.Lines.Add('Base64 encoding do not work !')
    else
        DisplayMemo.Lines.Add('Base64 encoding works OK !');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure LoadMemoFromMemoryStream(Memo : TMemo; Stream : TMemoryStream);
var
    p, q, r : PChar;
begin
    p := Stream.Memory;
    q := p + Stream.Size - 1;
    r := p;
    while (p <> nil) and (p < q) do begin
        while (p < q) and (p^<> #13) do
            Inc(p);
        Memo.Lines.Add(Copy(StrPas(r), 1, p - r));
        if (p[0] = #13) and (p[1] = #10) then
           Inc(p, 2)
        else
           Inc(p);
        r := p;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

