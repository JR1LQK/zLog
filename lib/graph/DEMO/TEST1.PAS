{******************************************************************}
{  Demo program for AABsoftGraph component.                        }
{  (C) 1996 AABsoft and Mårten Henrichson                          }
{******************************************************************}

unit Test1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Aabgraph, StdCtrls, Buttons, Spin;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    ButtonNewValues: TButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SpeedButton8: TSpeedButton;
    SpinEdit1: TSpinEdit;
    LabelColorScheme: TLabel;
    SpeedButton9: TSpeedButton;
    ColorDialog1: TColorDialog;
    Button2: TButton;
    Button1: TButton;
    Button3: TButton;
    Panel2: TPanel;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    FontDialog1: TFontDialog;
    Button4: TButton;
    AABsoftGraph1: TAABsoftGraph;
    SpeedButton12: TSpeedButton;
    SpeedButton14: TSpeedButton;
    procedure ButtonNewValuesClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure SpeedButton11Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton14Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.ButtonNewValuesClick(Sender: TObject);
var
   I           : Integer;
   nValueCount : Integer;
begin
   Randomize;
   nValueCount := 2+Random(8)*2;
   AABsoftGraph1.ResetGraphModule;
   for I := 1 to nValueCount do
   begin
      AABsoftGraph1.SetValue(1,I,(Random(I+2)+2)*5.74);
      AABsoftGraph1.SetValue(2,I,(Random(I+4)+3)*8.34);
      AABsoftGraph1.SetValue(3,I,(Random(I+6)+4)*10.0);
      AABsoftGraph1.SetValue(4,I,(Random(I+6)+4)*10.0);
      AABsoftGraph1.SetValue(5,I,(Random(I+6)+4)*10.0);
      AABsoftGraph1.SetValue(6,I,(Random(I+6)+4)*10.0);
      AABsoftGraph1.SetValue(7,I,(Random(I+6)+4)*10.0);
      AABsoftGraph1.SetValue(8,I,(Random(I+6)+4)*10.0);
      AABsoftGraph1.SetXLegend(I,'Result :' + IntToStr(I));
   end;
   AABsoftGraph1.SetHeader('Main header!');
   AABsoftGraph1.SetSeriesLegend(1, 'First series');
   AABsoftGraph1.SetSeriesLegend(2, 'Second series');
   AABsoftGraph1.SetSeriesLegend(3, 'Third series');
   AABsoftGraph1.SetSeriesLegend(4, 'Third series');
   AABsoftGraph1.SetSeriesLegend(5, 'Third series');
   AABsoftGraph1.SetSeriesLegend(6, 'Third series');
   AABsoftGraph1.SetSeriesLegend(7, 'Third series');
   AABsoftGraph1.SetSeriesLegend(8, 'Third series');
   AABsoftGraph1.AutoFormatGraph;
   if (not AABsoftGraph1.ShowLegend) then
   begin
      {if "100 values" button had been pressed, we restore legend}
      AABsoftGraph1.ShowLegend     := TRUE;
      AABsoftGraph1.UpdateGraphToScreen;
   end;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
   AABsoftGraph1.GraphToClipboard;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
   AABsoftGraph1.UpdateGraphToScreen;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
   AABsoftGraph1.PrintGraph;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
   AABsoftGraph1.ShowAsBar;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
{   AABsoftGraph1.ShowAsLine; this show it without marks}
   AABsoftGraph1.ShowAsLineWithMark;
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
   AABsoftGraph1.ShowAs100StackedBar;
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
begin
   AABsoftGraph1.ShowAsStackedBar;
end;

procedure TForm1.SpeedButton7Click(Sender: TObject);
begin
   AABsoftGraph1.ChangeXValuesWithSeries;
end;

procedure TForm1.SpeedButton8Click(Sender: TObject);
begin
   AABsoftGraph1.ShowAsBarWithAve;
end;

procedure TForm1.SpeedButton10Click(Sender: TObject);
begin
   AABsoftGraph1.ShowAsPie;
end;

procedure TForm1.SpeedButton12Click(Sender: TObject);
begin
   AABsoftGraph1.ShowAsMark;
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
   AABsoftGraph1.ColorScheme := SpinEdit1.Value;
   AABsoftGraph1.PlotGraph;
end;

procedure TForm1.SpeedButton9Click(Sender: TObject);
var
   strValue : String;
   nSeries  : Integer;
begin
   {this is not very professionally done,
    but it shows the basics how you can set the colors...}
   nSeries   := 1;
   strValue := IntToStr(nSeries);
   if InputQuery('Color for series','Series to change (1-100)?',strValue) then
   begin
      nSeries := StrToInt(strValue);
      {ask the graph for the current color and set it as dialog default...}
      ColorDialog1.Color := AABsoftGraph1.GetColorFromScheme(SpinEdit1.Value,
                                                             nSeries);
      {ask the user for a new color...}
      if ColorDialog1.Execute then
      begin
         {sets the new color...}
         AABsoftGraph1.SetColorToScheme(SpinEdit1.Value,
                                        nSeries,
                                        ColorDialog1.Color);
         {redraw the graph with new color...}
         AABsoftGraph1.PlotGraph;
      end;
   end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   AABsoftGraph1.SetYGap(10);
   AABsoftGraph1.SetYGapCount(15);
   AABsoftGraph1.PlotGraph;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
   {this function demostrates a variety of other graph functions...}
   AABsoftGraph1.SetHeaderFontName('Courier New');
   AABsoftGraph1.SetAxisFontName('Times New Roman');
   AABsoftGraph1.HeaderFontSize := 22;
   AABsoftGraph1.AxisFontSize   := 8;
   AABsoftGraph1.LegendWidth    := 65;
   AABsoftGraph1.UpdateGraphToScreen;
   Application.ProcessMessages;
   AABsoftGraph1.SetXAxisHeader('This text is called: XAxisHeader...');
   AABsoftGraph1.SetAverageLineValue(1, 1.3);
   AABsoftGraph1.SetAverageLineValue(2, 1.7);
   AABsoftGraph1.SetAverageLineValue(3, 1.9);
   AABsoftGraph1.SetAverageLineValue(4, 2.9);
   AABsoftGraph1.ShowAsBarWithAve;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
   I           : Integer;
   nValueCount : Integer;
begin
   {This function demostrates how the component works with 3*100 values}
   Randomize;
   nValueCount := 100;
   AABsoftGraph1.ResetGraphModule;
   AABsoftGraph1.ThickLineWidth := 1;
   AABsoftGraph1.ShowLegend     := FALSE;
   {must be called after ShowLegend changed}
   AABsoftGraph1.UpdateGraphToScreen;
   for I := 1 to nValueCount do
   begin
      AABsoftGraph1.SetValue(1,I,(Random(I+2)+2)*5.74);
      AABsoftGraph1.SetValue(2,I,(Random(I+4)+3)*8.34);
      AABsoftGraph1.SetValue(3,I,(Random(I+6)+4)*10.0);
      if ((I mod 13)=0) then AABsoftGraph1.SetValue(4,I,I) else
      AABsoftGraph1.SetValue(4,I,-(Random(I+6)+2)*2.0);
      AABsoftGraph1.SetValue(5,I,-(Random(I+6)+2)*2.0);
   end;
   AABsoftGraph1.SetHeader('A lot of values!');
   AABsoftGraph1.SetSeriesLegend(1, 'First series');
   AABsoftGraph1.SetSeriesLegend(2, 'Second series');
   AABsoftGraph1.SetSeriesLegend(3, 'Third series');
   AABsoftGraph1.SetSeriesLegend(4, 'Forth series (neg)');
   AABsoftGraph1.SetSeriesLegend(5, 'Fifth series');
   AABsoftGraph1.SetXAxisHeader('This chart contains now 500 values.');
   AABsoftGraph1.AutoFormatGraph;
   AABsoftGraph1.ShowASLine;
end;

procedure TForm1.SpeedButton11Click(Sender: TObject);
begin
   {Get the current font for the Header text...}
   FontDialog1.Font.Size := AABsoftGraph1.HeaderFontSize;
   FontDialog1.Font.Name := AABsoftGraph1.GetHeaderFontName;
   if FontDialog1.Execute then
   begin
      {Set the font for the Header text...}
      AABsoftGraph1.SetHeaderFontName(FontDialog1.Font.Name);
      AABsoftGraph1.HeaderFontSize := FontDialog1.Font.Size;
   end;
   AABsoftGraph1.PlotGraph;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
   AABsoftGraph1.SetYMaxMin(50,10);
   AABsoftGraph1.PlotGraph;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
   {This is needed for Win 3.X, as it does not send Resize message at startup}
   AABsoftGraph1.UpdateGraphToScreen;
end;

procedure TForm1.SpeedButton14Click(Sender: TObject);
begin
   AABsoftGraph1.ShowAsDeltaAverage;
end;

end.
