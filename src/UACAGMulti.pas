unit UACAGMulti;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, Grids, zLogGlobal, JLLabel, UBasicMulti, checklst,
  Cologrid, UMultipliers;


type
  TACAGMulti = class(TBasicMulti)
    Panel1: TPanel;
    Button3: TButton;
    Panel: TPanel;
    Label1R9: TRotateLabel;
    Label3R5: TRotateLabel;
    Label7: TRotateLabel;
    Label14: TRotateLabel;
    Label21: TRotateLabel;
    Label28: TRotateLabel;
    Label50: TRotateLabel;
    Label144: TRotateLabel;
    Label430: TRotateLabel;
    Label1200: TRotateLabel;
    Label2400: TRotateLabel;
    Label5600: TRotateLabel;
    Edit1: TEdit;
    Label10g: TRotateLabel;
    Button1: TButton;
    Grid: TMgrid;
    StayOnTop: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure GoButtonClick2(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure GridSetting(ARow, Acol: Integer; var Fcolor: Integer;
      var Bold, Italic, underline: Boolean);
    procedure StayOnTopClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    LatestMultiAddition : integer; // Grid.TopRow
    CityList : TCityList;
    procedure Update; override;
    procedure AddNoUpdate(var aQSO : TQSO); override;
    procedure Add(var aQSO : TQSO); override; {NewMulti}
    function ValidMulti(aQSO : TQSO) : boolean; override;
    procedure Reset; override;
    procedure CheckMulti(aQSO : TQSO); override;
    function ExtractMulti(aQSO : TQSO) : string; override;
    procedure SetNumberEditFocus; override;
    { Public declarations }
  end;

var
  ACAGMulti: TACAGMulti;

implementation

uses Main;

{$R *.DFM}

procedure TACAGMulti.Add(var aQSO : TQSO);
begin
  inherited;
  //AddNoUpdate(aQSO);
  //Update;
end;

procedure TACAGMulti.Update;
var i : integer;
    C : TCity;
    str : string;
begin
  for i := 0 to CityList.List.Count-1 do
    begin
      C := TCity(CityList.List[i]);
      str := C.Summary;
      str[30] := ' ';
      Grid.Cells[0,i] := str;
    end;
  Grid.TopRow := LatestMultiAddition;
end;

procedure TACAGMulti.CheckMulti(aQSO : TQSO);
var str : string;
    i : integer;
    C : TCity;
begin
  inherited;
  str := aQSO.QSO.NrRcvd;
  if str = '' then
    exit;
  if str[length(str)] in ['H', 'P', 'L', 'M'] then
    System.Delete(str, length(str), 1);
  for i := 0 to CityList.List.Count-1 do
    begin
      C := TCity(CityList.List[i]);
      if str = C.CityNumber then
        begin
          //ListBox.TopIndex := i;
          Grid.TopRow := i;
          str := C.Summary2;
          if C.Worked[aQSO.QSO.Band] then
            Insert('Worked on this band. ',str, 27)
          else
            Insert('Needed on this band. ',str, 27);
          MainForm.WriteStatusLine(str, false);
          exit;
        end;
    end;
  MainForm.WriteStatusLine('Invalid number', false);
end;

function TACAGMulti.ExtractMulti(aQSO : TQSO) : string;
var str : string;
begin
  Result := '';
  str := aQSO.QSO.NrRcvd;
  if str = '' then
    exit;
  if not(str[length(str)] in ['0'..'9']) then
    Delete(str, length(str),1);
  Result := str;
end;

procedure TACAGMulti.AddNoUpdate(var aQSO : TQSO);
var str, str2 : string;
    B : TBand;
    i, j : integer;
    C : TCity;
begin
  aQSO.QSO.NewMulti1 := False;
  str := aQSO.QSO.NrRcvd;
  Delete(str,length(str),1);
  aQSO.QSO.Multi1 := str;

  if aQSO.QSO.Dupe then
    exit;

  C := CityList.GetCity(str);
  if C <> nil then
    begin
      if C.Worked[aQSO.QSO.band] = False then
        begin
          C.Worked[aQSO.QSO.band] := True;
          aQSO.QSO.NewMulti1 := True;
        end;
      LatestMultiAddition := C.Index;
    end;
  {for i := 0 to CityList.List.Count-1 do
    begin
      C := TCity(CityList.List[i]);
      if str = C.CityNumber then
        begin
          if C.Worked[aQSO.QSO.band] = False then
            begin
              C.Worked[aQSO.QSO.band] := True;
              aQSO.QSO.NewMulti1 := True;
            end;
          LatestMultiAddition := i;
          break;
        end;
    end; }
end;

procedure TACAGMulti.Reset;
var i, j : integer;
    B : TBand;
    str : string;
begin
  if CityList.List.Count = 0 then exit;
  //j := ListBox.TopIndex;
  j := Grid.TopRow;
  Grid.RowCount := 0;
  Grid.RowCount := CityList.List.Count;
  //ListBox.Items.Clear;
  for i := 0 to CityList.List.Count-1 do
    begin
      for B := b19 to HiBand do
        TCity(CityList.List[i]).Worked[B] := false;
      str := TCity(CityList.List[i]).Summary;
      str[30] := ' ';
      Grid.Cells[0,i] := str;
      //ListBox.Items.Add(str);
      //ListBox.Checked[i] := False;
    end;
  //ListBox.TopIndex := j;
  Grid.TopRow := j;
end;

function TACAGMulti.ValidMulti(aQSO : TQSO) : boolean;
var str : string;
    B : TBand;
    i, j : integer;
    C : TCity;
    boo : boolean;
begin
  Result := False;
  str := aQSO.QSO.NrRcvd;
  if not(length(str) in [5..7]) then
    exit;
  if not(str[length(str)] in ['P','L','M','H']) then
    exit;
  Delete(str, length(str), 1);

  boo := false;
  for i := 0 to CityList.List.Count-1 do
    begin
      C := TCity(CityList.List[i]);
      if str = C.CityNumber then
        begin
           boo := true;
           break;
        end;
    end;
  Result := boo;
end;


procedure TACAGMulti.FormCreate(Sender: TObject);
var i : integer;
begin
  LatestMultiAddition := 0;
  CityList := TCityList.Create;
  CityList.LoadFromFile('ACAG.DAT');
  if CityList.List.Count = 0 then exit;
  Reset;
  {
  for i := 0 to CityList.List.Count-1 do
    begin
      ListBox.Items.Add(TCity(CityList.List[i]).Summary);
    end;
  }
end;

procedure TACAGMulti.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TACAGMulti.GoButtonClick2(Sender: TObject);
var temp : string;
    i : integer;
begin
  temp := Edit1.Text;
  for i := 0 to CityList.List.Count-1 do
    begin
      if pos(temp,TCity(CityList.List[i]).CityNumber) = 1 then
        begin
          Grid.TopRow := i;
          //ListBox.TopIndex := i;
          break;
        end;
    end;
end;


procedure TACAGMulti.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = Chr($0D) then
    begin
      GoButtonClick2(Self);
      Key := #0;
    end;
end;

procedure TACAGMulti.FormShow(Sender: TObject);
begin
  inherited;
  Update;
end;

procedure TACAGMulti.GridSetting(ARow, Acol: Integer; var Fcolor: Integer;
  var Bold, Italic, underline: Boolean);
var B : TBand;
begin
  inherited;
  if ARow > CityList.List.Count - 1 then
    exit;
  B := Main.CurrentQSO.QSO.Band;
  if TCity(CityList.List[ARow]).Worked[B] then
    FColor := clRed
  else
    FColor := clBlack;
end;

procedure TACAGMulti.StayOnTopClick(Sender: TObject);
begin
  if StayOnTop.Checked then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

procedure TACAGMulti.FormResize(Sender: TObject);
var i, j : integer;
begin
  inherited;
  i := Self.Width - 20 - Button3.Width;
  j := i - Edit1.Width - 10;
  if j < (StayOnTop.Left + StayOnTop.Width + 10) then
    begin
      j := 176;
      i := 224;
    end;
  Edit1.Left := j;
  Button3.Left := i;
end;

procedure TACAGMulti.SetNumberEditFocus;
begin
  SetNumberEditFocusJARL;
end;

end.
