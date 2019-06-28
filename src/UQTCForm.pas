unit UQTCForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, zLogGlobal, Main, uzLogCW, UZLinkForm, BGK32LIB;

type
  TQTCForm = class(TForm)
    btnSend: TButton;
    btnBack: TButton;
    Label1: TLabel;
    SpinEdit: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    ListBox: TListBox;
    procedure btnSendClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure SpinEditChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    QTCToBeSent : integer;
    PastQTC : integer;
    QTCList : TList;
    QTCReqStn : TQSO;
  public
    { Public declarations }
    QTCSeries : integer;
    procedure OpenQTC(Q : TQSO);
  end;

var
  QTCForm: TQTCForm;

implementation

{$R *.DFM}

procedure TQTCForm.OpenQTC(Q : TQSO);
var i, j, k : integer;
    QQ : TQSO;
    SS, SSS : String;
label BYPASS;

begin
  QTCReqStn := Q;
  QTCList := TList.Create;
  QTCSeries := 0;
  PastQTC := 0;
  QTCToBeSent := 0;
  for i := 1 to Log.TotalQSO do
    begin
      QQ := TQSO(Log.List[i]);
      if QQ.QSO.Dupe or (QQ.QSO.Points = 0) then goto BYPASS;
      j := pos('[QTC', QQ.QSO.memo);
      if j = 0 then
        begin
          if CoreCall(QQ.QSO.CallSign) <> CoreCall(Q.QSO.Callsign) then
            begin
              if QTCList.Count < 10 then
                QTCList.Add(QQ);
            end;
        end
      else // get QTC Series and check for QTCs sent in the past
        begin
          SS := QQ.QSO.Memo;
          Delete(SS, 1, j-1); // SS = [QTC??/?? CALLSIGN date time band]
          j := pos('/', SS);
          if j > 0 then
            begin
              SSS := copy(SS, 5, j-5);
              try
                if StrToInt(SSS) > QTCSeries then
                  QTCSeries := StrToInt(SSS);
              except
                on EConvertError do
                  begin
                  end;
              end;

              k := pos(' ', SS);
              if k > 0 then
                begin
                  Delete(SS, 1, k);
                  j := pos(' ', SS);
                    if j > 0 then
                      begin
                        SSS := copy(SS, 1, j-1);
                        if CoreCall(Q.QSO.Callsign) = CoreCall(SSS) then
                          inc(PastQTC);
                      end;
                end;
            end;
        end;
      BYPASS:
    end;
  SpinEdit.Value := QTCList.Count;

  ListBox.Clear;
  for i := 0 to QTCList.Count - 1 do
    ListBox.Items[i] := TQSO(QTCList[i]).QTCStr;

  if PastQTC > 0 then
    Label2.Caption := IntToStr(PastQTC) + ' QTCs have been sent to ' + Q.QSO.Callsign + ' already'
  else
    Label2.Caption := '';

  SpinEdit.Value := QTCList.Count - PastQTC;
    for i := SpinEdit.Value  to 9 do
      ListBox.Items[i] := '';

  if QTCList.Count > 0 then
    begin
      Inc(QTCSeries);
      Label1.Caption := Q.QSO.Callsign + ' QTC ' + IntToStr(QTCSeries) + '/' +
                        IntToStr(SpinEdit.Value);
    end;
end;

procedure TQTCForm.btnSendClick(Sender: TObject);
var cQ : TQSO;
    S : string;
begin
  SpinEdit.Enabled := False;

  if btnSend.Caption = 'Done' then
    begin
      close;
      exit;
    end;

  if QTCToBeSent = 0 then
    begin
      if QTCReqStn.QSO.Mode = mCW then
        begin
          S := '   '+QTCReqStn.QSO.Callsign + ' QTC ' + IntToStr(QTCSeries) + '/' +
               IntToStr(SpinEdit.Value);
          zLogSendStr(S+'"');

          btnSend.Enabled := False;
          btnBack.Enabled := False;
          UserFlag := True;
          repeat
            Application.ProcessMessages;
          until UserFlag = False;
          btnSend.Enabled := True;
          btnBack.Enabled := True;
       end;
    end
  else
    begin
      ListBox.Selected[QTCToBeSent-1] := True;
      cQ := TQSO(QTCList[QTCToBeSent-1]);
      if pos('[QTC', cQ.QSO.Memo) = 0 then
        cQ.QSO.Memo := '[QTC'+IntToSTr(QTCSeries)+'/'+IntToStr(SpinEdit.Value) + ' ' + QTCReqStn.QSO.Callsign +
                       FormatDateTime(' yyyy-mm-dd hhnn ', CurrentTime) + ADIFBandString[QTCReqStn.QSO.Band] + ']'
                       +cQ.QSO.Memo;

      ZLinkForm.EditQSObyID(cQ);

      if QTCReqStn.QSO.Mode = mCW then
        begin
          //S := SetStr(cQ.QTCStr, cQ);
          S := cQ.QTCStr;
          zLogSendStr(S+'"');

          btnSend.Enabled := False;
          btnBack.Enabled := False;
          UserFlag := True;
          repeat
            Application.ProcessMessages;
          until UserFlag = False;
          btnSend.Enabled := True;
          btnBack.Enabled := True;
        end;
    end;
  inc(QTCToBeSent);

  if (QTCToBeSent = QTCList.Count + 1) or (QTCToBeSent = SpinEdit.Value + 1) then
    begin
      btnSend.Caption := 'Done';
      //close;
      Label1.Caption := 'QTC '+ IntToStr(QTCSeries) + '/' + IntToStr(SpinEdit.Value)
                        +' sent';
      exit;
    end;

  Label1.Caption := '[QTC ' + IntToStr(QTCSeries) + '/' + IntToStr(SpinEdit.Value)+'-'+
                     IntToStr(QTCToBeSent)+'] '+ TQSO(QTCList[QTCToBeSent-1]).QTCStr;
end;

procedure TQTCForm.btnBackClick(Sender: TObject);
begin
  if QTCToBeSent >= 1 then
    Dec(QTCToBeSent);
  if btnSend.Caption = 'Done' then
    btnSend.Caption := 'Send';
  if QTCToBeSent = 0 then
    Label1.Caption := QTCReqStn.QSO.Callsign + ' QTC ' + IntToStr(QTCSeries) + '/' +
                     IntToStr(SpinEdit.Value)
  else
    Label1.Caption := '[QTC ' + IntToStr(QTCSeries) + '/' +
                     IntToStr(QTCToBeSent)+'] '+ TQSO(QTCList[QTCToBeSent-1]).QTCStr;
end;



procedure TQTCForm.SpinEditChange(Sender: TObject);
var i, maxQTC : integer;
begin
  maxQTC := 10-PastQTC;
  if QTCList.Count < maxQTC then
    maxQTC := QTCList.Count;
  if SpinEdit.Value > maxQTC then
    SpinEdit.Value := MaxQTC;
  for i := 0 to SpinEdit.Value - 1 do
    ListBox.Items[i] := TQSO(QTCList[i]).QTCStr;
  for i := SpinEdit.Value to 9 do
    ListBox.Items[i] := '';
  Label1.Caption := QTCReqStn.QSO.Callsign + ' QTC ' + IntToStr(QTCSeries) + '/' +
    IntToStr(SpinEdit.Value);
end;

procedure TQTCForm.FormClose(Sender: TObject; var Action: TCloseAction);
var i, j, xpos : integer;
    Q : TQSO;
    S : string;
begin
   btnSend.Caption := 'Send';

   if QTCtobeSent - 1 < SpinEdit.Value then // didn't send all QTC. [QTC??/?? CALLSIGN date time band]
     begin
       for i := 0 to QTCtoBeSent - 2 do
         begin
           Q := TQSO(QTCList[i]);
           S := Q.QSO.Memo;
           j := pos('[QTC', S);
           if j > 0 then
             begin
               xpos := j + length(IntToStr(QTCSeries)) + 5;
               if SpinEdit.Value = 10 then
                 Delete(S, xpos, 1);
               S[xpos] := IntToStr(QTCtobeSent-1)[1];
               Q.QSO.Memo := S;
             end;
         end;
     end;
   QTCList.Free;
   Main.MyContest.Renew;
   SpinEdit.Enabled := True;
end;

procedure TQTCForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    Chr($08), 'B', 'b': btnBackClick(Self);
    'F', 'f' : btnSendClick(Self);
    '\' : ControlPTT(not(PTTIsOn)); // toggle PTT;
  end;
end;

procedure TQTCForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    29 : {MUHENKAN KEY}
      begin
        ControlPTT(not(PTTIsOn)); // toggle PTT;
      end;
  end;
end;

end.
