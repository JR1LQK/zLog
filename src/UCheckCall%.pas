unit UCheckCall;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, zLogGlobal;

type
  TCheckCall = class(TForm)
    Panel1: TPanel;
    Button3: TButton;
    ListBox: TListBox;
    StayOnTop: TCheckBox;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Button3Click(Sender: TObject);
    procedure StayOnTopClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    BandRow : array[b19..HiBand] of Integer;
    procedure ResetListBox;
  public
    { Public declarations }
    procedure Renew(aQSO : TQSO);
  end;

var
  CheckCall: TCheckCall;

implementation

uses Main;

{$R *.DFM}

procedure TCheckCall.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TCheckCall.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TCheckCall.StayOnTopClick(Sender: TObject);
begin
  If StayOnTop.Checked then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

procedure TCheckCall.ResetListBox;
var B : TBand;
begin
  ListBox.Items.Clear;
  for B := b19 to HiBand do
    if BandRow[B] >= 0 then
      ListBox.Items.Add(MHzString[B]);
end;

procedure TCheckCall.Renew(aQSO : TQSO);
var PartialStr : string;
    i : LongInt;
    B : TBand;
begin
  //TempQSO := aQSO;
  ResetListBox;
  PartialStr := CoreCall(aQSO.QSO.Callsign);
  if PartialStr <> '' then
    begin
      for B := b19 to HiBand do
        for i := 1 to SubLog[B].TotalQSO do
          if PartialStr = CoreCall(TQSO(SubLog[B].List[i]).QSO.Callsign) then
            if BandRow[B] >= 0 then
              begin
                ListBox.Items.Delete(BandRow[B]);
                ListBox.Items.Insert(BandRow[B],TQSO(SubLog[B].List[i]).CheckCallSummary);
              end;

      for i := 1 to Log.TotalQSO do
        if PartialStr = CoreCall(TQSO(Log.List[i]).QSO.Callsign) then
          begin
            B := TQSO(Log.List[i]).QSO.Band;
            if BandRow[B] >= 0 then
              begin
                ListBox.Items.Delete(BandRow[B]);
                ListBox.Items.Insert(BandRow[B],TQSO(Log.List[i]).CheckCallSummary);
              end;
          end;
    end;
end;



procedure TCheckCall.FormShow(Sender: TObject);
var i : integer;
    B : TBand;
begin
  i := 0;
  for B := b19 to HiBand do
//    if MainForm.BandMenu.Items[ord(B)].Visible then
    if (MainForm.BandMenu.Items[ord(B)].Enabled) and
       (MainForm.BandMenu.Items[ord(B)].Visible) then
      begin
        BandRow[B] := i;
        inc(i);
      end
    else
      BandRow[B] := -1;
  CheckCall.Height := 14*i + 59;
  ResetListBox;
  Renew(Main.CurrentQSO);
end;

procedure TCheckCall.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : MainForm.LastFocus.SetFocus;
  end;
end;

end.
