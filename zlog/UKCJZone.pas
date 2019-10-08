unit UKCJZone;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ExtCtrls, UzLogGlobal;

type
  TKCJZone = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    cbStayOnTop: TCheckBox;
    Grid1: TStringGrid;
    Grid3: TStringGrid;
    Grid2: TStringGrid;
    procedure cbStayOnTopClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    formMulti: TForm;
    procedure Update;
  end;

implementation

uses
  UKCJMulti;

{$R *.DFM}

function BandCol(B: TBand): integer;
begin
   case B of
      b19:
         Result := 1;
      b35:
         Result := 2;
      b7:
         Result := 3;
      b14:
         Result := 4;
      b21:
         Result := 5;
      b28:
         Result := 6;
      b50:
         Result := 7;
      else
         Result := 1;
   end;
end;

procedure TKCJZone.Update;
var
   i: integer;
   B: TBand;
begin
   for i := 0 to 23 do begin
      for B := b19 to b50 do begin
         if NotWARC(B) then begin
            if TKCJMulti(formMulti).MultiArray[B, i] then begin
               Grid1.Cells[BandCol(B), i + 1] := '*';
            end
            else begin
               Grid1.Cells[BandCol(B), i + 1] := '.';
            end;
         end;
      end;
   end;
   for i := 24 to 47 do begin
      for B := b19 to b50 do begin
         if NotWARC(B) then begin
            if TKCJMulti(formMulti).MultiArray[B, i] then begin
               Grid2.Cells[BandCol(B), i - 23] := '*';
            end
            else begin
               Grid2.Cells[BandCol(B), i - 23] := '.';
            end;
         end;
      end;
   end;
   for i := 48 to maxindex do begin
      for B := b19 to b50 do begin
         if NotWARC(B) then begin
            if TKCJMulti(formMulti).MultiArray[B, i] then begin
               Grid3.Cells[BandCol(B), i - 47] := '*';
            end
            else begin
               Grid3.Cells[BandCol(B), i - 47] := '.';
            end;
         end;
      end;
   end;
end;

procedure TKCJZone.cbStayOnTopClick(Sender: TObject);
begin
   if cbStayOnTop.Checked then begin
      FormStyle := fsStayOnTop;
   end
   else begin
      FormStyle := fsNormal;
   end;
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

