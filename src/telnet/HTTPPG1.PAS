{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


Author:       François PIETTE
Email:        francois.piette@ping.be  http://www.rtfm.be/fpiette
              francois.piette@rtfm.be
Creation:     December 4, 1997
Version:      1.00
Description:  Sample program to demonstrate some of the THttpCli features.
              (POST a message to a CGI)
              (requested by Walter Daniel Leon Salas"
<wdaniel@hotmail.com>)
Support:      There is a mailing list for support. See web site for
              subscription http://www.rtfm.be/fpiette/supportuk.htm
Legal issues: Copyright (C) 1997 by François PIETTE
<francois.piette@ping.be>

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

              2. Altered source versions must be plainly marked as such,
and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

Updates:


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit HttpPg1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, WSocket, HttpProt;

type
  THttpTestForm = class(TForm)
    UserIDEdit: TEdit;
    EMailEdit: TEdit;
    MessageEdit: TEdit;
    SendButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    HttpCli1: THttpCli;
    procedure FormCreate(Sender: TObject);
    procedure SendButtonClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  HttpTestForm: THttpTestForm;

implementation

{$R *.DFM}

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpTestForm.FormCreate(Sender: TObject);
begin
    UserIDEdit.Text  := '27313';
    EMailEdit.Text   := 'francois.piette@ping.be';
    MessageEdit.Text := 'Hello World !';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function Encode(const msg : String) : String;
var
    I : Integer;
begin
    Result := '';
    for I := 1 to Length(msg) do begin
        if msg[I] = ' ' then
            Result := Result + '+'
        else if msg[I] in ['a'..'z', 'A'..'Z'] then
            Result := Result + '%' + IntToHex(ord(msg[I]), 2)
        else
            Result := Result + msg[I];
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure THttpTestForm.SendButtonClick(Sender: TObject);
var
    DataIn  : TMemoryStream;
    DataOut : TMemoryStream;
    Buf     : String;
begin
    DataIn  := TMemoryStream.Create;
    DataOut := TMemoryStream.Create;
    try
        Buf     := 'ID=' + UserIDEdit.Text +
                   '&REMITE=' + EMailEdit.Text +
                   '&MENSAJE=' + Encode(MessageEdit.Text);
        DataOut.Write(Buf[1], Length(Buf));
        DataOut.Seek(0, soFromBeginning);

        httpcli1.SendStream := DataOut;
        httpcli1.RcvdStream := DataIn;
        httpcli1.Proxy      := '';
        httpcli1.ProxyPort  := '80';
        HttpCli1.URL        := 'http://www.unired.net.pe/cgi-bin/a.out';

        SendButton.Enabled := FALSE;
        try
            httpcli1.Post;
        finally
            SendButton.Enabled := TRUE;
        end;
    finally
        DataOut.Free;
        DataIn.Free;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
