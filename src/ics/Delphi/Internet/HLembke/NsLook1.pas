{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Program:      NsLookup
Description:  Demo for DnsQuery ICS component.
Author:       Fran�ois Piette
EMail:        francois.piette@pophost.eunet.be    francois.piette@rtfm.be
              http://www.rtfm.be/fpiette
Creation:     January 29, 1999
Version:      1.02
Support:      Use the mailing list twsocket@rtfm.be See website for details.
Legal issues: Copyright (C) 1999 by Fran�ois PIETTE
              Rue de Grady 24, 4053 Embourg, Belgium. Fax: +32-4-365.74.56
              <francois.piette@pophost.eunet.be>

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

History:
Feb 27, 1999 V1.01 Added PTR lookup (reverse DNS lookup)
Mar 07, 1999 V1.02 Adapted for Delphi 1

Aug 11, 2002 V1.99 Modified for new TDnsQuery-Oject
                   all changed lines have been commented with a //!!KAP!!

 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit NsLook1;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles, WinSock, DnsQuery, StdCtrls, ExtCtrls, Buttons;

type
  TNsLookupForm = class(TForm)
    DisplayMemo: TMemo;
    Panel1: TPanel;
    DnsEdit: TEdit;
    NameEdit: TEdit;
    MXLookupButton: TButton;
    DnsQuery1: TDnsQuery;
    ClearDisplayBitBtn: TBitBtn;
    ALookupButton: TButton;
    PTRLookupButton: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MXLookupButtonClick(Sender: TObject);
    procedure DnsQuery1RequestDone(Sender: TObject; Error: Word);
    procedure ClearDisplayBitBtnClick(Sender: TObject);
    procedure ALookupButtonClick(Sender: TObject);
    procedure PTRLookupButtonClick(Sender: TObject);
  private
    FIniFileName : String;
    FInitialized : Boolean;
    FRequestID   : Integer;
    procedure Display(Msg : String);
    procedure DumpDnsResponse;
  public
    property IniFileName : String read FIniFileName write FIniFileName;
  end;

var
  NsLookupForm: TNsLookupForm;

implementation

{$R *.DFM}

const
    SectionWindow      = 'Window';
    KeyTop             = 'Top';
    KeyLeft            = 'Left';
    KeyWidth           = 'Width';
    KeyHeight          = 'Height';
    SectionData        = 'Data';
    KeyName            = 'Name';
    KeyDns             = 'Dns';


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNsLookupForm.FormCreate(Sender: TObject);
begin
    FIniFileName := LowerCase(ExtractFileName(Application.ExeName));
    FIniFileName := Copy(FIniFileName, 1, Length(FIniFileName) - 3) + 'ini';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNsLookupForm.FormShow(Sender: TObject);
var
    IniFile : TIniFile;
begin
    if not FInitialized then begin
        FInitialized := TRUE;

        IniFile       := TIniFile.Create(FIniFileName);
        Width         := IniFile.ReadInteger(SectionWindow, KeyWidth,  Width);
        Height        := IniFile.ReadInteger(SectionWindow, KeyHeight, Height);
        Top           := IniFile.ReadInteger(SectionWindow, KeyTop,
                                             (Screen.Height - Height) div 2);
        Left          := IniFile.ReadInteger(SectionWindow, KeyLeft,
                                             (Screen.Width  - Width)  div 2);
        NameEdit.Text := IniFile.ReadString(SectionData, KeyName, 'inprise.com');
        DnsEdit.Text  := IniFile.ReadString(SectionData, KeyDns,  '193.121.171.135');
        DisplayMemo.Clear;
        IniFile.Destroy;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNsLookupForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
    IniFile : TIniFile;
begin
    IniFile := TIniFile.Create(FIniFileName);
    IniFile.WriteInteger(SectionWindow, KeyTop,         Top);
    IniFile.WriteInteger(SectionWindow, KeyLeft,        Left);
    IniFile.WriteInteger(SectionWindow, KeyWidth,       Width);
    IniFile.WriteInteger(SectionWindow, KeyHeight,      Height);
    IniFile.WriteString(SectionData, KeyName, NameEdit.Text);
    IniFile.WriteString(SectionData, KeyDns,  DnsEdit.Text);
    IniFile.Destroy;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNsLookupForm.Display(Msg : String);
begin
    if DisplayMemo.Lines.Count > 200 then
        DisplayMemo.Lines.Delete(0);
    DisplayMemo.Lines.Add(Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNsLookupForm.DumpDnsResponse;
var
    P      : PChar;
    I      : Integer;
    Len    : Integer;
    Buf    : String;
begin
    Display('Response dump (' + IntToStr(DnsQuery1.Response.len) + ' bytes):'); //!!KAP!!
    P   := DnsQuery1.ResponseBuf;
    Len := DnsQuery1.Response.Len; //!!KAP!!
    Buf := '';
    I   := 0;
    while I < Len do begin
        if P^ in [' '..'~'] then
            Buf := Buf + P^
        else
            Buf := Buf + '<' + IntToStr(Ord(P^)) + '>';
        Inc(I);
        Inc(P);
        if (I mod 16) = 0 then begin
            Display('  ' + Buf);
            Buf := '';
        end;
    end;
    if Length(Buf) > 0 then
        Display('  ' + Buf);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNsLookupForm.DnsQuery1RequestDone(Sender: TObject; Error: Word);
var
    I      : Integer;
    nIndex : Integer;
begin
    if Error <> 0 then begin
        Display('Error #' + IntToStr(Error));
        Exit;
    end;
    // !!KAP!! start of changes
    //!!KAP!! added lots of '.'...
    Display('ID                 : ' + IntToStr(DnsQuery1.Response.ID));
    Display('ResponseCode       : ' + IntToStr(DnsQuery1.Response.rCode)); //!!KAP!! added ..r
    Display('OpCode             : ' + IntToStr(DnsQuery1.Response.OpCode));
    Display('Authoritative      : ' + IntToStr(Ord(DnsQuery1.Response.AuthoritativeAnswer))); //!!KAP!! added ..Answer
    Display('Truncation         : ' + IntToStr(Ord(DnsQuery1.Response.Truncation)));
    Display('RecursionAvailable : ' + IntToStr(Ord(DnsQuery1.Response.RecursionAvailable)));
    Display('QDCount            : ' + IntToStr(DnsQuery1.Response.QDCount));
    Display('ANCount            : ' + IntToStr(DnsQuery1.Response.ANCount));
    Display('NSCount            : ' + IntToStr(DnsQuery1.Response.NSCount));
    Display('ARCount            : ' + IntToStr(DnsQuery1.Response.ARCount));
    Display('ResponseLen        : ' + IntToStr(DnsQuery1.Response.Len));
    Display('QuestionName       : ' + DnsQuery1.Question.QuestionName);            //!!KAP!! added Question...
    Display('QuestionType       : ' + IntToStr(DnsQuery1.Question.QuestionType));  //!!KAP!! added Question...
    Display('QuestionClass      : ' + IntToStr(DnsQuery1.Question.QuestionClass)); //!!KAP!! added Question...


    // !!KAP!! new style of access
    // Attention: some records only exists, if the appropriated request has been done
    // display the Name Server items
    Display('');
    for i:=0 to DnsQuery1.ResponseCount[DnsQueryNS]-1 do begin
      Display(' Nameserver: '+DnsQuery1.ResponseItem[DnsQueryNS,i].nsdname);
    end;
    Display('');
    // or the MX records
    for i:=0 to DnsQuery1.ResponseCount[DnsQueryMX]-1 do begin
      Display(' MailExchange: '+DnsQuery1.ResponseItem[DnsQueryMX,i].mx.exchange);
    end;
    Display('');

    // !!KAP!! but possible to loop throu all items
    for i:=0 to dnsquery1.ResponseCount[0]-1 do begin
      Display('Item for: '+dnsquery1.ResponseItem[0,i].name);
      case dnsquery1.ResponseItem[0,i].rrtype of
        DnsQueryA      : Display(' DnsQueryA:    ' + dnsquery1.ResponseItem[0,i].ipnummer);
        DnsQueryMD,
        DnsQueryMB,
        DnsQueryMF     : Display(' Answer:       ' + dnsquery1.ResponseItem[0,i].madname);
        DnsQueryCNAME  : Display(' Cname:        ' + dnsquery1.ResponseItem[0,i].cname);
        DnsQueryMG     : Display(' MGMName:      ' + dnsquery1.ResponseItem[0,i].mgmname);
        DnsQueryMR     : Display(' NewName:      ' + dnsquery1.ResponseItem[0,i].newname);
        DnsQueryPTR    : Display(' PTRName:      ' + dnsquery1.ResponseItem[0,i].ptrname);
        DnsQueryAAAA   : Display(' AAAA (ipv6):  ' + dnsquery1.ResponseItem[0,i].ip6nummer);
        DnsQueryMINFO  : Display(' MInfo r:      ' + dnsquery1.ResponseItem[0,i].minfo.rmailbx+
                                 ' MInfo re:     ' + dnsquery1.ResponseItem[0,i].minfo.remailbx);
        DnsQueryTXT    : Display(' TXT:          ' + dnsquery1.ResponseItem[0,i].txt);
        DnsQueryHINFO  : Display(' HInfo:         CPU=' + inttostr(dnsquery1.ResponseItem[0,i].hinfo.cpu)+
                                                 ' OS=' + inttostr(dnsquery1.ResponseItem[0,i].hinfo.os));
        DnsQueryNS     : Display(' Nameserver:   ' + dnsquery1.ResponseItem[0,i].nsdname);
        DnsQueryMX     : Display(' MailExchange: ' + dnsquery1.ResponseItem[0,i].mx.exchange+
                                                ' '+
                                                     inttostr(dnsquery1.ResponseItem[0,i].mx.preference));
      end;
    end;
    Display('');
    // !!KAP!! end of changes

(* !!KAP!! This type of access is not longer possible
    for I := 0 to DnsQuery1.ResponseANCount - 1 do begin
        Display('Answer #' + IntToStr(I + 1));
        Display('  AnswerName       : ' + DnsQuery1.AnswerName[I]);
        Display('  AnswerType       : ' + IntToStr(DnsQuery1.AnswerType[I]));
        Display('  AnswerClass      : ' + IntToStr(DnsQuery1.AnswerClass[I]));
        Display('  AnswerTTL        : ' + IntToStr(DnsQuery1.AnswerTTL[I]));
        nIndex := DnsQuery1.AnswerTag[I];
        if nIndex >= 0 then begin
            case DnsQuery1.AnswerType[I] of
            DnsQueryMX:
                begin
                    Display('  MXPreference     : ' + IntToStr(DnsQuery1.MXPreference[nIndex]));
                    Display('  MXExchange       : ' + DnsQuery1.MXExchange[nIndex]);
                end;
            DnsQueryA:
                begin
                    Display('  Address          : ' + StrPas(inet_ntoa(DnsQuery1.Address[nIndex])));
                end;
            DnsQueryPTR:
                begin
                    Display('  Hostname         : ' + DnsQuery1.Hostname[nIndex]);
                end;
            end;
        end;
    end;
*)
    { Dump complete response }
    DumpDnsResponse;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNsLookupForm.ClearDisplayBitBtnClick(Sender: TObject);
begin
    DisplayMemo.Clear;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNsLookupForm.MXLookupButtonClick(Sender: TObject);
begin
    DnsQuery1.Addr := DnsEdit.Text;
    FRequestID     := DnsQuery1.MXLookup(NameEdit.Text);
    Display('Request ID         : ' + IntToStr(FRequestID));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNsLookupForm.ALookupButtonClick(Sender: TObject);
begin
    DnsQuery1.Addr := DnsEdit.Text;
    FRequestID     := DnsQuery1.ALookup(NameEdit.Text);
    Display('Request ID         : ' + IntToStr(FRequestID));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TNsLookupForm.PTRLookupButtonClick(Sender: TObject);
begin
    DnsQuery1.Addr := DnsEdit.Text;
    FRequestID     := DnsQuery1.PTRLookup(NameEdit.Text);
    Display('Request ID         : ' + IntToStr(FRequestID));
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.
