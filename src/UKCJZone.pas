unit UKCJZone;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, Aligrid, StdCtrls, ExtCtrls, zLogGlobal;

type
  TKCJZone = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Grid1: TStringAlignGrid;
    Grid2: TStringAlignGrid;
    Grid3: TStringAlignGrid;
    cbStayOnTop: TCheckBox;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure cbStayOnTopClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Update;
  end;

var
  KCJZone: TKCJZone;

implementation

uses UKCJMulti;

{$R *.DFM}

function BandCol(B : TBand) : integer;
begin
  case B of
    b19 : Result := 1;
    b35 : Result := 2;
    b7  : Result := 3;
    b14 : Result := 4;
    b21 : Result := 5;
    b28 : Result := 6;
    b50 : Result := 7;
  else
    Result := 1;
  end;
end;

procedure TKCJZone.Update;
var i : integer;
    B : TBand;
begin
  for i := 0 to 23 do
    begin
      for B := b19 to b50 do
        if NotWARC(B) then
          begin
            if KCJMulti.MultiArray[B, i] then
              Grid1.Cells[BandCol(B),i+1] := '*'
            else
              Grid1.Cells[BandCol(B),i+1] := '.';
          end;
    end;
  for i := 24 to 47 do
    begin
      for B := b19 to b50 do
        if NotWARC(B) then
          begin
            if KCJMulti.MultiArray[B, i] then
              Grid2.Cells[BandCol(B),i-23] := '*'
            else
              Grid2.Cells[BandCol(B),i-23] := '.';
          end;
    end;
  for i := 48 to maxindex do
    begin
      for B := b19 to b50 do
        if NotWARC(B) then
          begin
            if KCJMulti.MultiArray[B, i] then
              Grid3.Cells[BandCol(B),i-47] := '*'
            else
              Grid3.Cells[BandCol(B),i-47] := '.';
          end;
    end;
end;

procedure TKCJZone.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TKCJZone.cbStayOnTopClick(Sender: TObject);
begin
  if cbStayOnTop.Checked then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

procedure TKCJZone.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TKCJZone.FormShow(Sender: TObject);
begin
  Update;
end;

end.
