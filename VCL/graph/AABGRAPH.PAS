{**************************************************************************}
{     Component for simple graphics, it's based upon Timage component.     }
{     (C) 1996-1997 AABsoft, all rights reserved.                          }
{     Distributed as freeware "AS IS"; may be modified as long as this     }
{     copyright text remains unchanged.                                    }
{     Version : 1.11                                                       }
{**************************************************************************}
{     Updates to version 0.5-0.6:                                          }
{     - MAX_XXXXXX - values increased to 100                               }
{     - nXLegendsValue string length set to MAX_STR_LEN compared 160 before}
{     - New types for holding the graph data / temporary graph struct      }
{     - Comments added to the source code                                  }
{     - Event handling for MouseDown, MouseUp                              }
{     - ColorScheme file parameter / procedure added (default COMPASS.INI) }
{     - DefaultYLegends and DefaultGraphType is used by AutoFormatGraph    }
{       procedure to produce nicely formatted charts                       }
{**************************************************************************}
{     Updates to version 0.6-0.7:                                          }
{     - Support for pie charts                                             }
{     - Extended font support procedures                                   }
{     - Support for negative values                                        }
{**************************************************************************}
{     Updates to version 0.7-0.72: (just bug fixes)                        }
{     - Pie legend show only the text that is set by the user              }
{     - AutoFormatGraph rewritten for negative values                      }
{     - Procedure for setting negative Y values count SetNegativeYGapCount }
{     - Ylegend texts remapped to graph for precise output                 }
{**************************************************************************}
{     Updates to version 0.72-1.00:                                        }
{     - Mouse click values correctly mapped                                }
{     - Mouse properties separeted (MouseInfo / MouseEdit)                 }
{     - Chart legend font size change resizes the corresponding header area}
{     - Procedure for setting max and min values (y direction):            }
{**************************************************************************}
{     Updates to version 1.00-1.02:                                        }
{     - New functions for retrieving current chart values; GetValue....    }
{**************************************************************************}
{     Updates to version 1.02-1.05:                                        }
{     - New procedure GraphToClipboardAsMetaFile                           }
{**************************************************************************}
{     Updates to version 1.05-1.10:                                        }
{     - Dropped support for GraphToClipboardAsMetaFile; if anyone knows    }
{       how to draw to the clipboard, please inform me, then I might add it}
{       again. The "current" metafile was so lousy that I did not want to  }
{       keep it.                                                           }
{     - NEW CHART TYPE : delta average=difference from the average line    }
{     - New procedure for printing the chart as part of other print job;   }
{       AddGraphToOpenPrintCanvas                                          }
{     - New procedure to get the current chart type; GetGraphType          }
{     - New properties; color settings for headers etc                     }
{     - Small improvements & bug fixes; layout of stacked 100% chart,      }
{       legends for chart with negative values, etc                        }
{**************************************************************************}
{     Updates to version 1.10-1.11: marked with commented *                }
{     - Bug fix for AutoFormatGraph-function, thanks to Jacques Strydom    }
{       at University of Stellenbosch                                      }
{**************************************************************************}

{**************************************************************************}
{ DUE TO ALL MODIFICATIONS DONE TO THIS COMPONENT, THIS SOURCE IS MESSY!   }
{ IF I HAVE THE TIME, I WILL REWRITE IT...SOMEDAY HOPEFULLY                }
{**************************************************************************}

unit AABGraph;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Printers, Clipbrd, IniFiles;

const
   {MAXIMUM ENTRIES FOR MEMORY ALLOCATION}
   {These values should be identical, otherwise ChangeXValuesWithSeries wont work!}
   MAX_VALUES               = 100;
   MAX_SERIES               = 100;

   MAX_Y_LEGENDS            = 30;
   DEFAULT_Y_LEGENDS        = 20;
   MAX_X_LEGENDS            = 50;

   MAX_STR_LEN              = 70;

   {GRAPH TYPES}
   GRAPH_BAR                = 1;
   GRAPH_STACKED_BAR        = 2;
   GRAPH_LINE               = 3;
   GRAPH_BAR_WITH_AVE       = 4;
   GRAPH_STACKED_BAR_100    = 5;
   GRAPH_PIE                = 6;
   GRAPH_LINE_WITH_MARK     = 7;
   GRAPH_MARK               = 8;
   GRAPH_DELTA_AVERAGE      = 9;

   DEFAULT_GRAPH            = GRAPH_BAR;

   MAX_GRAPH_LEGEND_LEN     = 9;

   DEFAULT_HEADER_FONT_SIZE = 16;
   DEFAULT_LEGEND_FONT_SIZE = 7;
   DEFAULT_AXIS_FONT_SIZE   = 9;

   DEFAULT_INI              = 'COMPASS.INI';

   REALPREC                 = 7;

   DEFAULT_POINT_SIZE       = 3;

   CLIPBOARD_MULTIPLYER     = 15;

type
  TGraphToShow3 = record
     n100Value            : Array[1..MAX_SERIES,1..MAX_VALUES] of real;
  end;

  TGraphToShow2 = record
     nValue               : Array[1..MAX_SERIES,1..MAX_VALUES] of real;
  end;

  TGraphToShow  = record
     nGraphType           : Integer;
     strGraphHeader       : String[MAX_STR_LEN];
     strGraphXHeader      : String[MAX_STR_LEN];
     strGraphYHeader      : String[MAX_STR_LEN];
     nXValueCount         : Integer;
     nYValueCount         : Integer;
     nSeriesCount         : Integer;
     nAveValue            : Array[1..MAX_VALUES] of real;
     nXLegendsValue       : Array[1..MAX_VALUES] of String[MAX_STR_LEN];
     nYLegendsValue       : Array[1..MAX_Y_LEGENDS+1] of String[MAX_STR_LEN];
     nSeriesLegendsValue  : Array[1..MAX_SERIES] of String[MAX_STR_LEN];
     nXGap                : real;
     nYGap                : real;
     nXOrigo              : integer; {which value corresponds to origo}
     nYOrigo              : integer;
     nXStartOffset        : LongInt; {margin}
     nYStartOffset        : LongInt;
     nXEnd                : LongInt; {canvas size, excluding margin}
     nYEnd                : LongInt;
     PointSize            : integer;
  end;


  TAABsoftGraph = class(TImage)
  private
    { Private declarations }
    Bitmap                : TBitmap;
    GraphToShow           : ^TGraphToShow;
    GraphToShow2          : ^TGraphToShow2;
    PrintInSession        : Boolean;
    bStartDrag            : Boolean;
    bMouseLegend          : Boolean;
    bContainsNegative     : Boolean;
    strColorFile          : String;
    strHeaderFontName     : String[70];
    strLegendFontName     : String[70];
    strAxisFontName       : String[70];
    nOldYOrigo            : integer;
    nOldYGap              : real;
    nMouseDownX           : LongInt;
    nMouseDownY           : LongInt;
    nMouseValue           : Integer;
    nMouseSeries          : Integer;
    nOldYValueCount       : Integer;
    gstrText              : Array[0..255] of Char;
    FColorScheme          : Integer;
    FDefaultGraphType     : Integer;
    FDefaultYLegends      : Integer;
    FLegendWidth          : Integer;
    FAutoUpdateGraph      : Boolean;
    FMouseEdit            : Boolean;
    FMouseInfo            : Boolean;
    FShowLegend           : Boolean;
    FThickLineWidth       : Integer;
    FAxisLineWidth        : Integer;
    FHeaderFontSize       : Integer;
    FLegendFontSize       : Integer;
    FAxisFontSize         : Integer;
    FHeaderFontColor      : TColor;
    FLegendFontColor      : TColor;
    FAxisFontColor        : TColor; 
    procedure   MyShowLegend(nXPixelGap, nYPixelGap: LongInt);
    procedure   MyHeader(strText: String);
    procedure   MyXHeader(nXPixelGap, nYPixelGap: LongInt ; strText: String);
    procedure   MyHeaderFont;
    procedure   MyGraphFont;
    procedure   MySmallGraphFont;
    procedure   MyRCTextOut(X, Y: Integer; const Text: string);
    procedure   MyCBTextOut(X, Y: Integer; const Text: string);
    procedure   MyLBTextOut(X, Y: Integer; const Text: string);
    procedure   MyThickLineTo(X,Y: Integer);
    procedure   MyAxisLineTo(X,Y: Integer);
    procedure   MyLineTo(X,Y: Integer);
    procedure   MyMoveTo(X,Y: Integer);
    procedure   MyRectangle(X, Y, X2, Y2: Integer);
    procedure   MyColorRectangle(Series : Integer; X, Y, X2, Y2: Integer);
    procedure   MyPie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Longint);
    procedure   MyArc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
    procedure   MyPolygon(Points: array of TPoint);
    procedure   MyEllipse(X1, Y1, X2, Y2: Integer);
    procedure   MyDrawLine(X1, Y1, X2, Y2: Integer);
    procedure   MyDrawDotLine(X1, Y1, X2, Y2: Integer);
    function    MyTextHeight(strText : String): LongInt;
    function    MyTextWidth(strText : String): LongInt;
    procedure   EditXHeader;
    procedure   EditHeader;
    procedure   SetSolidLines;
    procedure   SetDotLines;
    procedure   SetLineColor(Series : Integer);
    procedure   SetRectangleColor(Series : Integer);
    procedure   SetFontColor(Series : Integer);
    procedure   SaveColorScheme(nScheme : Integer);
    function    GetSelectedScheme: Integer;
    procedure   CountGraphAverage;
    Procedure   DrawSeriesColorBox(nColor,W,H,X,Y:Integer);
    function    GetDefaultColorString(nIndex : Integer): String;
    procedure   MyPiePercentage(X1,Y1,W: LongInt; nPercentage: real);
    procedure   MyDisplayAsPie(nSeries:Integer);
    procedure   MyDisplayAsDeltaAverage;
    procedure   MyPieLegend(nSeries: Integer);
    procedure   ShowMouseMessage(X,Y,nMouseValue,nMouseSeries: Integer);
    procedure   PlotCross(x, y: Integer);
    procedure   PlotDiamond(x, y: Integer);
    procedure   PlotCircle(x, y: Integer);
    procedure   PlotSquare(x, y: Integer);
    function    MyPt(AX, AY: Integer): TPoint;
    function    StrToPChar(strText : string): PChar;
    procedure   ClearScreen;
  protected
    {Protected declarations}
    procedure   MouseDown(Button: TMouseButton;Shift:TShiftState;X,Y:Integer); override;
    procedure   MouseUp(Button: TMouseButton;Shift:TShiftState;X,Y:Integer); override;
  public
    {Public declarations}
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    {General procedures for the graph...}
    procedure   ResetGraphModule;   {Call this before totally new values and series}
    procedure   AutoFormatGraph;    {Call this after new values}
    procedure   PlotGraph;          {Update screen / draw graph to screen}
    procedure   PrintGraph;         {Send picture to printer; all printing done by component}
    procedure   AddGraphToOpenPrintCanvas(XStartPos,YStartPos,GraphWidth,GraphHeight : LongInt); 
                                    {adds the graph to the "OPEN" printer canvas}
                                    {printing control=outside this component; add other text etc}
    procedure   GraphToClipboard;   {Puts picture on clipboard}
    procedure   UpdateGraphToScreen;{Call this after screen resize and after start up}
    {Procedures to update graph values...}
    procedure   SetValue(nSeries,nIndex:Integer; nValue:real); {Values here!}
    function    GetValue(nSeries,nIndex:Integer): real;
    procedure   SetYGap(nValue:real); {Sets the vertical gap between dotted lines}
    function    GetYGap: real;
    procedure   SetYGapCount(nValue:Integer); {How many lines to display...}
    function    GetYGapCount: Integer;
    procedure   SetAverageLineValue(nIndex:Integer; nValue:real); {Overrides the values calculated by AutoFormatGraph}
    procedure   SetNegativeYGapCount(nValue:Integer); {How many lines on the negative side...}
    procedure   SetYMaxMin(nMaxValue,nMinValue:real);
    {Procedures to update graph texts...}
    procedure   SetHeader(strHeader : String);
    function    GetHeader: String;
    procedure   SetXAxisHeader(strHeader : String);
    function    GetXAxisHeader: String;
    procedure   SetSeriesLegend(nSeries:Integer; strLegend:String);
    function    GetSeriesLegend(nSeries: Integer) : String;
    procedure   SetXLegend(nXValue:Integer; strLegend:String);
    function    GetXLegend(nXValue:Integer) :String;
    procedure   SetHeaderFontName(strFont:String);
    procedure   SetLegendFontName(strFont:String);
    procedure   SetAxisFontName(strFont:String);
    function    GetHeaderFontName : String;
    function    GetLegendFontName : String;
    function    GetAxisFontName : String;
    {Display graph in different ways...}
    procedure   ShowAsBar;
    procedure   ShowAsStackedBar;
    procedure   ShowAsLine;
    procedure   ShowAsBarWithAve;
    procedure   ShowAs100StackedBar;
    procedure   ShowAsPie;
    procedure   ShowAsLineWithMark;
    procedure   ShowAsMark;
    procedure   ShowAsDeltaAverage;
    function    GetGraphType: integer;
    procedure   ChangeXValuesWithSeries; {Switches the x values with series! Resets AverageLine}
    {Changes the color of the graph...}
    procedure   SetColorToScheme(nScheme,nIndex:Integer; nColor:TColor);
    function    GetColorFromScheme(nScheme,nIndex:Integer) : TColor;
    procedure   UseColorIniFile(strFileName : string); {COMPASS.INI if not used}
    {These are for my own purpose...or why I did this in the first place}
    procedure   UsePFITemplate;
    procedure   UseICFTemplate;
    procedure   UseTLETemplate;
    procedure   UseBMSTemplate;
    procedure   UseEZTemplate;
    procedure   UseJDSTemplate;
    procedure   UseBackgroundTemplate;
  published
    {Published declarations}
    property    ColorScheme     : Integer read FColorScheme write FColorScheme default 1;
    property    DefaultGraphType: Integer read FDefaultGraphType write FDefaultGraphType default 1;
    property    DefaultYLegends : Integer read FDefaultYLegends write FDefaultYLegends default DEFAULT_Y_LEGENDS;
    property    AutoUpdateGraph : Boolean read FAutoUpdateGraph write FAutoUpdateGraph default False;
    property    MouseEdit       : Boolean read FMouseEdit write FMouseEdit default True;
    property    MouseInfo       : Boolean read FMouseInfo write FMouseInfo default True;
    property    ShowLegend      : Boolean read FShowLegend write FShowLegend default True;
    property    LegendWidth     : Integer read FLegendWidth write FLegendWidth default 150;
    property    ThickLineWidth  : Integer read FThickLineWidth write FThickLineWidth default 3;
    property    AxisLineWidth   : Integer read FAxisLineWidth write FAxisLineWidth default 3;
    property    HeaderFontSize  : Integer read FHeaderFontSize write FHeaderFontSize default DEFAULT_HEADER_FONT_SIZE;
    property    LegendFontSize  : Integer read FLegendFontSize write FLegendFontSize default DEFAULT_LEGEND_FONT_SIZE;
    property    AxisFontSize    : Integer read FAxisFontSize write FAxisFontSize default DEFAULT_AXIS_FONT_SIZE;
    property    HeaderFontColor : TColor  read FHeaderFontColor write FHeaderFontColor default clNavy;
    property    LegendFontColor : TColor  read FLegendFontColor write FLegendFontColor default clNavy;
    property    AxisFontColor   : TColor  read FAxisFontColor write FAxisFontColor default clNavy;
  end;

procedure Register;


implementation


{**************************************************************************}
{ call this function : NEVER!                                              }
{**************************************************************************}
constructor TAABsoftGraph.Create(AOwner: TComponent);
var
   I                      : Integer;
   nXScreenResolution     : LongInt;
begin
   inherited Create(AOwner);  {by TImage...}

   {Add code for my own data...here}
   Bitmap                       := TBitMap.Create;
   New(GraphToShow);
   New(GraphToShow2);
   GraphToShow^.nGraphType      := DEFAULT_GRAPH;
   GraphToShow^.PointSize       := DEFAULT_POINT_SIZE;

   GraphToShow^.nXStartOffset   := 45;  {margin}
   GraphToShow^.nYStartOffset   := 40;
   GraphToShow^.nXEnd           := 360; {canvas size, excluding margin}
   GraphToShow^.nYEnd           := 250;
   PrintInSession               := FALSE;
   strColorFile                 := DEFAULT_INI;
   nOldYGap                     := 1;
   nOldYOrigo                   := 0;
   nOldYValueCount              := 10;
   bStartDrag                   := FALSE;
   bMouseLegend                 := FALSE;
   bContainsNegative            := FALSE;
   nMouseValue                  := 0;
   nMouseSeries                 := 0;
   strHeaderFontName            := 'Arial';
   strLegendFontName            := 'Arial';
   strAxisFontName              := 'Arial';
   HeaderFontColor              := clNavy;
   LegendFontColor              := clNavy;
   AxisFontColor                := clNavy; 

   Width  :=  25; {VCL component initial size, IMPORTANT keep small default!}
   Height :=  25; {VCL component initial size, IMPORTANT keep small default!}

   {Set default values for component fields...}
   FDefaultGraphType := DEFAULT_GRAPH;
   FShowLegend       := True;
   FMouseEdit        := True;
   FMouseInfo        := True;
   FColorScheme      := 1;
   FLegendWidth      := 150;
   FThickLineWidth   := 3;
   FAxisLineWidth    := 3;
   FHeaderFontSize   := DEFAULT_HEADER_FONT_SIZE;
   FLegendFontSize   := DEFAULT_LEGEND_FONT_SIZE;
   FAxisFontSize     := DEFAULT_AXIS_FONT_SIZE;
   FDefaultYLegends  := DEFAULT_Y_LEGENDS;

   {To do when plotting a new graph....}
   ResetGraphModule;
   GraphToShow^.strGraphHeader  := 'Header';
   GraphToShow^.strGraphXHeader := 'x-axis header';
   GraphToShow^.strGraphYHeader := 'y-axis header';
   for I := 1 to MAX_SERIES do
      GraphToShow^.nSeriesLegendsValue[I] :='Series Legend';
   for I := 1 to 25 do
   begin
      GraphToShow2^.nValue[1,I] := I*3.65;
      GraphToShow2^.nValue[2,I] := 0.5*I;
      GraphToShow2^.nValue[3,I] := 100-I*3;
      GraphToShow2^.nValue[4,I] := (I mod 3)* 13.2;
      GraphToShow2^.nValue[5,I] := 0;
      GraphToShow2^.nValue[6,I] := 0;
      GraphToShow2^.nValue[7,I] := 0;
      GraphToShow2^.nValue[8,I] := 0;
      GraphToShow2^.nValue[9,I] := 0;
      GraphToShow2^.nValue[10,I] := 0;
      GraphToShow^.nAveValue[I] := 0;
   end;
   for I := 1 to MAX_Y_LEGENDS do
      GraphToShow^.nYLegendsValue[I] := IntToStr(Round(((I-1)-GraphToShow^.nYOrigo)*GraphToShow^.nYGap));
   for I := 1 to MAX_VALUES do
      GraphToShow^.nXLegendsValue[I] := IntToStr(I);
   AutoFormatGraph;  {Should always be done when completed}
end;


{**************************************************************************}
{ call this function : NEVER!                                              }
{**************************************************************************}
destructor TAABsoftGraph.Destroy;
begin
   {Add code for detroying my own data...here}
   Dispose(GraphToShow);
   Dispose(GraphToShow2);
   Bitmap.Free;
   inherited Destroy;
end;


{device independent functions... no checking for printer / screen needed}

{**************************************************************************}
{ call this function :                                                     }
{  a) before setting totally new values to the graph                       }
{**************************************************************************}
Procedure TAABsoftGraph.ResetGraphModule;
var
   I,J      : Integer;
begin
   bContainsNegative            := FALSE;
   GraphToShow^.strGraphHeader  := '';
   GraphToShow^.strGraphXHeader := '';
   GraphToShow^.strGraphYHeader := '';
   GraphToShow^.nSeriesCount    := 1;
   GraphToShow^.nXValueCount    := 0;
   GraphToShow^.nYValueCount    := DefaultYLegends;
   GraphToShow^.nXOrigo         := 0;
   GraphToShow^.nYOrigo         := 0;
   GraphToShow^.nXGap           := 1;
   GraphToShow^.nYGap           := 1;
   for I := 1 to MAX_SERIES do
      GraphToShow^.nSeriesLegendsValue[I] :='';
   for I := 1 to MAX_VALUES do
   begin
      GraphToShow^.nAveValue[I] := 0;
      for J := 1 to MAX_SERIES do
         GraphToShow2^.nValue[J,I] := 0;
   end;
   for I := 1 to MAX_VALUES do
      GraphToShow^.nXLegendsValue[I] := IntToStr(I);
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) to set or change a single value in the graph                         }
{**************************************************************************}
procedure TAABsoftGraph.SetValue(nSeries,nIndex:Integer; nValue:real);
begin
   if (nSeries<1)          or (nIndex<1) or
      (nSeries>MAX_SERIES) or (nIndex>MAX_VALUES) then
      exit;
   if (nValue<=-1) then
      bContainsNegative            := TRUE;
   GraphToShow2^.nValue[nSeries,nIndex] := nValue;
   if FAutoUpdateGraph then PlotGraph;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) to retrieve current graph value                                      }
{**************************************************************************}
function  TAABsoftGraph.GetValue(nSeries,nIndex:Integer): real;
begin
   GetValue := GraphToShow2^.nValue[nSeries,nIndex];
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) to set the average value used by GRAPH_BAR_WITH_AVE type graph       }
{**************************************************************************}
procedure TAABsoftGraph.SetAverageLineValue(nIndex:Integer; nValue:real);
begin
   if (nIndex<1) or (nIndex>MAX_VALUES) then
      exit;
   if (nValue<0) then
      bContainsNegative           := TRUE;
   GraphToShow^.nAveValue[nIndex] := nValue;
   if FAutoUpdateGraph then PlotGraph;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) to set the header string of the graph                                }
{**************************************************************************}
procedure TAABsoftGraph.SetHeader(strHeader : String);
begin
   GraphToShow^.strGraphHeader  := Copy(strHeader,1,MAX_STR_LEN);
   if FAutoUpdateGraph then PlotGraph;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) to retrieve currrent graph header string                             }
{**************************************************************************}
function TAABsoftGraph.GetHeader : String;
begin
   GetHeader := GraphToShow^.strGraphHeader;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) to set the x axis header string shown below graph                    }
{**************************************************************************}
procedure TAABsoftGraph.SetXAxisHeader(strHeader : String);
begin
   GraphToShow^.strGraphXHeader  := Copy(strHeader,1,MAX_STR_LEN);
   if FAutoUpdateGraph then PlotGraph;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) to retrieve x axis header string shown below graph                   }
{**************************************************************************}
function TAABsoftGraph.GetXAxisHeader : String;
begin
   GetXAxisHeader := GraphToShow^.strGraphXHeader;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) to set the series legend string shown on the right of the graph      }
{**************************************************************************}
procedure TAABsoftGraph.SetSeriesLegend(nSeries:Integer; strLegend:String);
begin
   GraphToShow^.nSeriesLegendsValue[nSeries] := Copy(strLegend,1,MAX_STR_LEN);
   if FAutoUpdateGraph then PlotGraph;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) to retrieve the current series legend string for a specified series  }
{**************************************************************************}
function TAABsoftGraph.GetSeriesLegend(nSeries:Integer) : String;
begin
   GetSeriesLegend := GraphToShow^.nSeriesLegendsValue[nSeries];
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) to set the x axis string for a specified value, show below or to the }
{     right of the graph depending on the length of the string             }
{**************************************************************************}
procedure TAABsoftGraph.SetXLegend(nXValue:Integer; strLegend:String);
begin
   GraphToShow^.nXLegendsValue[nXValue] := Copy(strLegend,1,MAX_STR_LEN);
   if FAutoUpdateGraph then PlotGraph;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) to retrieve x axis legend string for a specified value               }
{**************************************************************************}
function TAABsoftGraph.GetXLegend(nXValue:Integer) : String;
begin
   GetXLegend := GraphToShow^.nXLegendsValue[nXValue];
end;


procedure TAABsoftGraph.SetYGap(nValue:real);
begin
   if (nValue<=0) then
      ShowMessage('YGap must be positive!')
   else
      GraphToShow^.nYGap := nValue;
   if FAutoUpdateGraph then PlotGraph;
end;


function TAABsoftGraph.GetYGap:real;
begin
   GetYGap := GraphToShow^.nYGap;
end;


procedure TAABsoftGraph.SetYGapCount(nValue:Integer);
begin
   if (nValue<=0) or (nValue>=MAX_Y_LEGENDS) then
      ShowMessage('YGapCount must be between 0 and ' + IntToStr(MAX_Y_LEGENDS))
   else
      GraphToShow^.nYValueCount := nValue;
   if FAutoUpdateGraph then PlotGraph;
end;


function TAABsoftGraph.GetYGapCount:Integer;
begin
   GetYGapCount := GraphToShow^.nYValueCount;
end;


procedure TAABsoftGraph.SetNegativeYGapCount(nValue:Integer);
begin
   {How many lines on the negative side...}
   if (nValue<0) or (nValue>=MAX_Y_LEGENDS) then
      ShowMessage('YNegativeGapCount must be between 0 and ' + IntToStr(MAX_Y_LEGENDS))
   else
      GraphToShow^.nYOrigo := nValue;
   if FAutoUpdateGraph then PlotGraph;
end;


procedure TAABsoftGraph.SetYMaxMin(nMaxValue,nMinValue:real);
var
   nMaxMinGap  : real;
begin
   {let's check the input values...}
   if (nMaxValue<=nMinValue) then
   begin
      ShowMessage('Maximum value must be greater than minimum value.');
      exit;
   end;

   nMaxMinGap  := nMaxValue-nMinValue;
   {check if YGap should be changed...}
   if ((nMaxMinGap/9) < GraphToShow^.nYGap) then
      GraphToShow^.nYGap := Round((nMaxMinGap/GraphToShow^.nYValueCount)+0.5);

   if (nMinValue<=0) and (nMaxValue>=0) then
   begin
      {if the nMinValue is zero or less and nMaxValue is positive ...easy!}
      GraphToShow^.nYValueCount := Round((nMaxMinGap/GraphToShow^.nYGap)+0.5)+1;
      SetNegativeYGapCount(Round((Abs(nMinValue)/GraphToShow^.nYGap)));
   end
   else
   begin
      GraphToShow^.nYValueCount := Round(nMaxMinGap/GraphToShow^.nYGap);
      if (nMinValue<=0) then
      begin
         {both limits negative...}
         SetNegativeYGapCount(Round(Abs(nMinValue)/GraphToShow^.nYGap));
      end
      else
      begin
         {both limits positive...}
         SetNegativeYGapCount(0);
         GraphToShow^.nYOrigo      := -(Round(Abs(nMinValue)/GraphToShow^.nYGap));
      end;
   end;

   if FAutoUpdateGraph then PlotGraph;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) you have updated the graph with totally new values                   }
{  b) you have added a new series or x-value to the graph                  }
{  c) the graph looks scrambled                                            }
{ Notice! This procedure does not make a graph perfect, but helps a little }
{         in the layout process of the graph, call SetYGap, SetYGapCount...}
{         for more personalized layouts, or do your own template function. }
{         Remember to call this anyway if you have case a) or b)           }
{**************************************************************************}
Procedure TAABsoftGraph.AutoFormatGraph;
var
   nYMax,nYMin      : real;
   nSeries          : LongInt;
   nMaxXValue       : LongInt;
   I,J              : Integer;
begin
   nYMax            := -99999999;
   nYMin            :=  99999999;
   nMaxXValue       := 0;
   nSeries          := 0;
   {Set graph type according to component property}
   GraphToShow^.nGraphType := FDefaultGraphType;
   {Analyse graph for max and min values...}
   for I := 1 to MAX_VALUES do
   begin
      for J := 1 to MAX_SERIES do
      begin
         if (nYMin > GraphToShow2^.nValue[J,I]) then
            nYMin := GraphToShow2^.nValue[J,I];
         if (I>nMaxXValue) and (GraphToShow2^.nValue[J,I]<>0) then
            nMaxXValue := I;
         if (J>nSeries) and (GraphToShow2^.nValue[J,I]<>0) then
            nSeries := J;
         if (nYMax < GraphToShow2^.nValue[J,I]) then
            nYMax := GraphToShow2^.nValue[J,I];
      end;
   end;

   {Empiric based calculation how to format graph nicely...what a joke!}
   {Seriously, this works for me...might work for you as well.}
   {The following lines does not work with negative values...}
   GraphToShow^.nYGap           := Round((nYMax*1.1) / DefaultYLegends);
   if (GraphToShow^.nGraphType = GRAPH_STACKED_BAR) then
      GraphToShow^.nYGap        := Round((((nYMax+nYMin)/1.9) / DefaultYLegends)*nSeries);

   bContainsNegative            := FALSE;
   if (nYMin < 0) then
   begin
      bContainsNegative         := TRUE;
      GraphToShow^.nYGap        := Round(((nYMax-nYMin)*1.1) / DefaultYLegends);
      if (GraphToShow^.nYGap=0) then {*}
         GraphToShow^.nYGap     := 1;
      GraphToShow^.nGraphType   := GRAPH_LINE;
      GraphToShow^.nYOrigo      := Round(-nYMin/GraphToShow^.nYGap);
   end;

   if (GraphToShow^.nYGap=0) then
   begin
      GraphToShow^.nYGap := 1;
      GraphToShow^.nYValueCount := Round(nYMax*nSeries);
   end;

   if (GraphToShow^.nYValueCount=0) then GraphToShow^.nYValueCount := 1;

   GraphToShow^.nSeriesCount    := nSeries;
   GraphToShow^.nXValueCount    := nMaxXValue;
   for I := 1 to MAX_Y_LEGENDS do
      GraphToShow^.nYLegendsValue[I] := IntToStr(Round(((I-1)-GraphToShow^.nYOrigo)*GraphToShow^.nYGap));
   CountGraphAverage;
   PlotGraph;
end;


Procedure TAABsoftGraph.CountGraphAverage;
var
   I,J      : Integer;
begin
   for I := 1 to MAX_VALUES do
   begin
      GraphToShow^.nAveValue[I] := 0;
      for J := 1 to MAX_SERIES do
         GraphToShow^.nAveValue[I] := GraphToShow^.nAveValue[I] + GraphToShow2^.nValue[J,I];
      if (GraphToShow^.nSeriesCount = 0) then
         GraphToShow^.nAveValue[I] := 0
      else
         GraphToShow^.nAveValue[I] := GraphToShow^.nAveValue[I]/GraphToShow^.nSeriesCount;
   end;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) you want to show the graph stored in memory                          }
{  b) you have changed single graph value (call AutoFormatGraph if all new)}
{  c) you have changed the settings of the graph and if you do not use     }
{     FAutoUpdateGraph option                                              }
{**************************************************************************}
Procedure TAABsoftGraph.PlotGraph;
var
   nXPixelGap  : LongInt;
   nYPixelGap  : LongInt;
   xOrigo      : LongInt;
   yOrigo      : LongInt;
   yOldOrigo   : LongInt;
   I           : Integer;
   J           : Integer;
   nStackGap   : Integer;
   GraphToShow3: ^TGraphToShow3;
   n100Sum     : real;
   nOldY       : LongInt;
   yTempOrigo  : LongInt;
begin
   ClearScreen;

   {Check graph values and correct if wrong. Actually not needed if there are no bugs}
   if (GraphToShow^.nYValueCount>MAX_Y_LEGENDS) then
       GraphToShow^.nYValueCount := MAX_Y_LEGENDS;
   if (GraphToShow^.nYValueCount=0) then
       GraphToShow^.nYValueCount := 1;
   if (GraphToShow^.nXValueCount>MAX_VALUES) then
       GraphToShow^.nXValueCount := MAX_VALUES;
   if (GraphToShow^.nSeriesCount>MAX_SERIES) then
       GraphToShow^.nSeriesCount := MAX_SERIES;
   if (GraphToShow^.nYGap=0) then
       GraphToShow^.nYGap := 1;


   {Resize Header area according to HeaderFont size}
   if not PrintInSession then
   begin
      MyHeaderFont;
      nOldY                        := GraphToShow^.nYStartOffset;
      GraphToShow^.nYStartOffset   := MyTextHeight('Mg') + 8;
      GraphToShow^.nYEnd           := GraphToShow^.nYEnd + (nOldY-GraphToShow^.nYStartOffset);
   end;

   {Draw header and other stuff...}

   {Create texts for y-axis}
   for I := 1 to MAX_Y_LEGENDS do
      GraphToShow^.nYLegendsValue[I] := IntToStr(Round(((I-1)-GraphToShow^.nYOrigo)*GraphToShow^.nYGap));

   if (GraphToShow^.nGraphType=GRAPH_STACKED_BAR) or
      (GraphToShow^.nGraphType=GRAPH_STACKED_BAR_100) then
   begin
      nOldYOrigo                   := GraphToShow^.nYOrigo;
      GraphToShow^.nYOrigo         := 0;
   end else
   begin
      nOldYOrigo                   := GraphToShow^.nYOrigo;
   end;
   if (GraphToShow^.nGraphType=GRAPH_STACKED_BAR_100) then
   begin
      nOldYGap                     := GraphToShow^.nYGap;
      GraphToShow^.nYGap           := 10;
      nOldYValueCount              := GraphToShow^.nYValueCount;
      GraphToShow^.nYValueCount    := 10;
      for I := 1 to (GraphToShow^.nYValueCount+1) do
         GraphToShow^.nYLegendsValue[I] := IntToStr(Round((I-1)*GraphToShow^.nYGap));
   end
   else
   begin
      nOldYValueCount              := GraphToShow^.nYValueCount;
      nOldYGap                     := GraphToShow^.nYGap;
   end;

   {This effects only graph type: GRAPH_STACKED_BAR(_100)}
   nStackGap   := 1;
   if (GraphToShow^.nXEnd>200) then
      nStackGap   := 3;

   MyGraphFont;

   nXPixelGap  := Round((GraphToShow^.nXEnd-GraphToShow^.nXStartOffset) /
                        (GraphToShow^.nXValueCount+1));
   nYPixelGap  := Round(GraphToShow^.nYEnd/(GraphToShow^.nYValueCount+1));

   xOrigo :=GraphToShow^.nXStartOffset + nXPixelGap*(GraphToShow^.nXOrigo);
   yOrigo :=GraphToShow^.nYStartOffset +
            Round(nYPixelGap*(GraphToShow^.nYValueCount-GraphToShow^.nYOrigo));
   if (GraphToShow^.nYOrigo < 0) then
      yTempOrigo := GraphToShow^.nYStartOffset + Round(nYPixelGap*GraphToShow^.nYValueCount)
   else
      yTempOrigo := yOrigo;

   {Draw Y-axis}
   MyMoveTo(xOrigo, GraphToShow^.nYStartOffset);
   MyAxisLineTo(xOrigo,GraphToShow^.nYStartOffset + nYPixelGap*(GraphToShow^.nYValueCount+1));

   {Y-axis legends and lines...}
   for I := 1 to (GraphToShow^.nYValueCount+1) do
   begin
      MyRCTextOut(xOrigo - 3,
                  yOrigo - (nYPixelGap*((I-1)-GraphToShow^.nYOrigo)),
                  GraphToShow^.nYLegendsValue[I]);
      MyDrawDotLine(GraphToShow^.nXStartOffset,
                 yOrigo - (nYPixelGap*((I-1)-GraphToShow^.nYOrigo)),
                 GraphToShow^.nXStartOffset + nXPixelGap*(GraphToShow^.nXValueCount+1),
                 yOrigo - (nYPixelGap*((I-1)-GraphToShow^.nYOrigo))
                 );
   end;

   {Draw X-axis}
   MyMoveTo(GraphToShow^.nXStartOffset,
            yTempOrigo);
   MyAxisLineTo(GraphToShow^.nXStartOffset + nXPixelGap*(GraphToShow^.nXValueCount+1),
                yTempOrigo);

   {X-axis legends...}
   MyShowLegend(nXPixelGap,nYPixelGap);

   {Main Header}
   MyHeader(GraphToShow^.strGraphHeader);

   {X axis header}
   MyXHeader(nXPixelGap,nYPixelGap,GraphToShow^.strGraphXHeader);

   {Create the actual graph...}
   case (GraphToShow^.nGraphType) of
    GRAPH_BAR,
    GRAPH_BAR_WITH_AVE:
       begin
          for I := 1 to GraphToShow^.nSeriesCount do
             for J := 1 to GraphToShow^.nXValueCount do
                 if (GraphToShow^.nSeriesCount=1) then
                    MyColorRectangle(I,
                                xOrigo+J*nXPixelGap+(I-1)*Round(nXPixelGap/(GraphToShow^.nSeriesCount+0.1))
                                      -Round(nXPixelGap/2),
                                yTempOrigo,
                                xOrigo+J*nXPixelGap+I*Round(nXPixelGap/(GraphToShow^.nSeriesCount+0.1))
                                      -Round(nXPixelGap/2),
                                yOrigo-Round((GraphToShow2^.nValue[I,J]/GraphToShow^.nYGap)*nYPixelGap))
                 else
                    MyColorRectangle(I,
                                xOrigo+J*nXPixelGap+(I-1)*Round(nXPixelGap/(GraphToShow^.nSeriesCount+0.5))
                                      -Round(nXPixelGap/2),
                                yTempOrigo,
                                xOrigo+J*nXPixelGap+I*Round(nXPixelGap/(GraphToShow^.nSeriesCount+0.5))
                                      -Round(nXPixelGap/2),
                                yOrigo-Round((GraphToShow2^.nValue[I,J]/GraphToShow^.nYGap)*nYPixelGap));
          {add average line for the type...}
          if (GraphToShow^.nGraphType=GRAPH_BAR_WITH_AVE) then
          begin
             SetLineColor(0);
             MyMoveTo(xOrigo+1*nXPixelGap,
                      yOrigo-Round((GraphToShow^.nAveValue[1]/GraphToShow^.nYGap)*nYPixelGap));
             for J := 2 to GraphToShow^.nXValueCount do
                   MyThickLineTo(xOrigo+J*nXPixelGap,
                                 yOrigo-Round((GraphToShow^.nAveValue[J]/GraphToShow^.nYGap)*nYPixelGap));
             SetLineColor(0);
          end;
       end;
    GRAPH_STACKED_BAR:
       begin
          for J := 1 to GraphToShow^.nXValueCount do
          begin
             yOldOrigo := 0;
             for I := 1 to GraphToShow^.nSeriesCount do
                 begin
                 MyColorRectangle(I,
                             xOrigo+J*nXPixelGap-Round(nXPixelGap/2),
                             yOrigo-yOldOrigo,
                             xOrigo+(J+1)*nXPixelGap-Round(nXPixelGap/2)-nStackGap,
                             (yOrigo-yOldOrigo) -
                             Round((GraphToShow2^.nValue[I,J]/GraphToShow^.nYGap)*nYPixelGap));
                 yOldOrigo := yOldOrigo +
                              Round((GraphToShow2^.nValue[I,J]/GraphToShow^.nYGap)*nYPixelGap);
                 end;
          end;
       end;
    GRAPH_LINE,
    GRAPH_LINE_WITH_MARK:
       begin
          for I := 1 to GraphToShow^.nSeriesCount do
             begin
                SetLineColor(I);
                MyMoveTo(xOrigo+1*nXPixelGap,
                         yOrigo-Round((GraphToShow2^.nValue[I,1]/GraphToShow^.nYGap)*nYPixelGap));
                for J := 2 to GraphToShow^.nXValueCount do
                   MyThickLineTo(xOrigo+J*nXPixelGap,
                                 yOrigo-Round((GraphToShow2^.nValue[I,J]/GraphToShow^.nYGap)*nYPixelGap));
             end;
          if (GraphToShow^.nGraphType=GRAPH_LINE_WITH_MARK) then
             for I := 1 to GraphToShow^.nSeriesCount do
                for J := 1 to GraphToShow^.nXValueCount do
                begin
                   SetLineColor(I);
                   PlotDiamond(xOrigo+J*nXPixelGap,
                            yOrigo-Round((GraphToShow2^.nValue[I,J]/GraphToShow^.nYGap)*nYPixelGap));
                end;
          SetLineColor(0);
       end;
    GRAPH_MARK:
       begin
          for I := 1 to GraphToShow^.nSeriesCount do
          begin
             SetLineColor(I);
             for J := 1 to GraphToShow^.nXValueCount do
                PlotDiamond(xOrigo+J*nXPixelGap,
                            yOrigo-Round((GraphToShow2^.nValue[I,J]/GraphToShow^.nYGap)*nYPixelGap));
          end;
          SetLineColor(0);
       end;
    GRAPH_STACKED_BAR_100:
       begin
          New(GraphToShow3);
          for J := 1 to GraphToShow^.nXValueCount do
          begin
             n100Sum    := 0;
             for I := 1 to GraphToShow^.nSeriesCount do
                 n100Sum    := n100Sum + GraphToShow2^.nValue[I,J];

             for I := 1 to GraphToShow^.nSeriesCount do
                if (n100Sum<>0) then
                   GraphToShow3^.n100Value[I,J] := (GraphToShow2^.nValue[I,J]/n100Sum)*100
                else
                   GraphToShow3^.n100Value[I,J] := 0;
          end;

          for J := 1 to GraphToShow^.nXValueCount do
          begin
             yOldOrigo := 0;
             for I := 1 to GraphToShow^.nSeriesCount do
                 begin
                    if (I = GraphToShow^.nSeriesCount) then {last one; draw it always to the top line}
                       MyColorRectangle(I,
                                        xOrigo+J*nXPixelGap-Round(nXPixelGap/2),
                                        yOrigo-yOldOrigo,
                                        xOrigo+(J+1)*nXPixelGap-Round(nXPixelGap/2)-nStackGap,
                                        GraphToShow^.nYStartOffset)
                    else
                    begin
                       MyColorRectangle(I,
                                        xOrigo+J*nXPixelGap-Round(nXPixelGap/2),
                                        yOrigo-yOldOrigo,
                                        xOrigo+(J+1)*nXPixelGap-Round(nXPixelGap/2)-nStackGap,
                                        (yOrigo-yOldOrigo) -
                                           Round((GraphToShow3^.n100Value[I,J]/GraphToShow^.nYGap)*nYPixelGap));
                       yOldOrigo := yOldOrigo + Round((GraphToShow3^.n100Value[I,J]/GraphToShow^.nYGap)*nYPixelGap);
                    end;
                 end;
          end;
          Dispose(GraphToShow3);
       end;
    GRAPH_PIE:
       MyDisplayAsPie(1);
    GRAPH_DELTA_AVERAGE:
       MyDisplayAsDeltaAverage;
    else ShowMessage('DefaultGraphType not supported');
   end;
end;


Procedure TAABsoftGraph.MyShowLegend(nXPixelGap, nYPixelGap: LongInt);
var
   I           : Integer;
   DoSeparate  : boolean;
   XLegendGap  : LongInt;
   nTextHeight : LongInt;
   nChars      : Integer;
   yTempOrigo  : LongInt;
   nMaxLegend  : Integer;
begin
   {X-LEGEND: ...}
   DoSeparate := FALSE;
   XLegendGap := 0;
   {Count how many characters to show in the separate legend}
   MySmallGraphFont;
   nChars := Round(FLegendWidth / MyTextWidth('1'));
   {Decrease the value due to the color box shown}
   if (nChars>3) and (nChars<35) then nChars := nChars-3;
   {Analyse length of Xlegends; put to separate box if > MAX_GRAPH_LEGEND_LEN}
   for I := 1 to GraphToShow^.nXValueCount do
      if (Length(GraphToShow^.nXLegendsValue[I]) > MAX_GRAPH_LEGEND_LEN) then
         DoSeparate := TRUE;

   {always separate for this type}
   if (GraphToShow^.nGraphType=GRAPH_DELTA_AVERAGE) then
      DoSeparate := TRUE;

   {Find out where the X-axis is in Y direction...}
   if (GraphToShow^.nYOrigo < 0) then
      yTempOrigo := GraphToShow^.nYStartOffset +
                    Round(nYPixelGap*GraphToShow^.nYValueCount)+2
   else
      yTempOrigo := GraphToShow^.nYStartOffset +
                    Round(nYPixelGap*(GraphToShow^.nYValueCount-GraphToShow^.nYOrigo))+2;;

   if (DoSeparate) then
   begin
      if (GraphToShow^.nGraphType=GRAPH_DELTA_AVERAGE) then
         for I := 1 to GraphToShow^.nXValueCount do
            MyRCTextOut(GraphToShow^.nXStartOffset-2,
                        GraphToShow^.nYStartOffset + nXPixelGap*(I-1)+ (nXPixelGap div 2),
                        IntToStr(I))
      else
      if (GraphToShow^.nXValueCount < MAX_X_LEGENDS) then
      begin
         for I := 1 to GraphToShow^.nXValueCount do
            if (bContainsNegative) then {*}
               MyCBTextOut(GraphToShow^.nXStartOffset + nXPixelGap*I,
                           GraphToShow^.nYEnd+3,
                           IntToStr(I))
            else
               MyCBTextOut(GraphToShow^.nXStartOffset + nXPixelGap*I,
                           yTempOrigo,
                           IntToStr(I));
      end
      else
      begin
         for I := 1 to (GraphToShow^.nXValueCount div 10 ) do
            if (bContainsNegative) then {*}
               MyCBTextOut(GraphToShow^.nXStartOffset + nXPixelGap*I,
                           GraphToShow^.nYEnd+3,
                           IntToStr(I*10))
            else
               MyCBTextOut(GraphToShow^.nXStartOffset + nXPixelGap*I*10,
                           yTempOrigo,
                           IntToStr(I*10));
      end;
      MySmallGraphFont;
      nTextHeight := Round(MyTextHeight('Mg')*1.1);

      if FShowLegend then
      begin
         MyColorRectangle(0,
                     GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+6,
                     (GraphToShow^.nYStartOffset+6+4)-nTextHeight,
                     GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+FLegendWidth+6,
                     GraphToShow^.nYStartOffset+(GraphToShow^.nXValueCount-1)*nTextHeight+6+5);
         MyColorRectangle(-1,
                     GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+3,
                     (GraphToShow^.nYStartOffset+3+4)-nTextHeight,
                     GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+FLegendWidth+3,
                     GraphToShow^.nYStartOffset+(GraphToShow^.nXValueCount-1)*nTextHeight+3+5);
         for I := 1 to GraphToShow^.nXValueCount do
              MyLBTextOut(GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+7,
                          GraphToShow^.nYStartOffset+(I-2)*nTextHeight+7,
                          IntToStr(I)+'.'+Copy(GraphToShow^.nXLegendsValue[I],1,nChars));
         XLegendGap := (I-1)*nTextHeight+7+5;
         if PrintInSession then XLegendGap := XLegendGap + 5;
      end;
   end
   else
   begin
      {Put legends in the actual graph...}
      SetLineColor(0);
      if (GraphToShow^.nXValueCount < MAX_X_LEGENDS) then
      begin
         for I := 1 to GraphToShow^.nXValueCount do
            if (bContainsNegative) then
               MyCBTextOut(GraphToShow^.nXStartOffset + nXPixelGap*I,
                           GraphToShow^.nYEnd+3,
                           GraphToShow^.nXLegendsValue[I])
            else
               MyCBTextOut(GraphToShow^.nXStartOffset + nXPixelGap*I,
                           yTempOrigo,
                           GraphToShow^.nXLegendsValue[I]);
      end
      else
      begin
         for I := 1 to (GraphToShow^.nXValueCount div 10) do
            if (bContainsNegative) then
               MyCBTextOut(GraphToShow^.nXStartOffset + nXPixelGap*I*10,
                           GraphToShow^.nYEnd+3,
                           GraphToShow^.nXLegendsValue[I*10])
            else
               MyCBTextOut(GraphToShow^.nXStartOffset + nXPixelGap*I*10,
                           yTempOrigo,
                           GraphToShow^.nXLegendsValue[I*10]);
      end;
   end;

   {SERIES LEGEND: only if series count is greater than one and we want them.}
   if (GraphToShow^.nSeriesCount=1) or (not FShowLegend) then exit;

   MySmallGraphFont;
   {10 % extra space for line height}
   nTextHeight := Round(MyTextHeight('Mg')*1.1);
   MyColorRectangle(0,
               GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+6,
               GraphToShow^.nYStartOffset+XLegendGap+6,
               GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+FLegendWidth+6,
               GraphToShow^.nYStartOffset+GraphToShow^.nSeriesCount*nTextHeight+XLegendGap+6+5);
   MyColorRectangle(-1,
               GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+3,
               GraphToShow^.nYStartOffset+3+XLegendGap,
               GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+FLegendWidth+3,
               GraphToShow^.nYStartOffset+GraphToShow^.nSeriesCount*nTextHeight+3+XLegendGap+5);

   for I := 1 to GraphToShow^.nSeriesCount do
   begin
         DrawSeriesColorBox(I,MyTextWidth('12')-2,nTextHeight-2,
                            GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+7,
                            GraphToShow^.nYStartOffset+(I-1)*nTextHeight+7+XLegendGap);
         SetFontColor(0);
         MyLBTextOut(GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+7 + MyTextWidth('12'){added myTextWidth},
                     GraphToShow^.nYStartOffset+(I-1)*nTextHeight+7+XLegendGap,
                     IntToStr(I)+'.'+Copy(GraphToShow^.nSeriesLegendsValue[I],1,nChars));
   end;
end;


Procedure TAABsoftGraph.DrawSeriesColorBox(nColor,W,H,X,Y:Integer);
begin
   MyColorRectangle(nColor,X, Y, X+W, Y+H);
   SetRectangleColor(-1);
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) when you want to print the graph to Windows default printer          }
{**************************************************************************}
Procedure TAABsoftGraph.PrintGraph;
var
   nXEnd,nYEnd           : LongInt;
   nXStart,nYStart       : LongInt;
   nLegendWidth          : LongInt;
begin
   {Save display values...}
   nXEnd                        := GraphToShow^.nXEnd;
   nYEnd                        := GraphToShow^.nYEnd;
   nXStart                      := GraphToShow^.nXStartOffset;
   nYStart                      := GraphToShow^.nYStartOffset;
   nLegendWidth                 := FLegendWidth;
   {Calculate new values for printer....}
   FLegendWidth                 := Round((FLegendWidth/(nXEnd+FLegendWidth))*Printer.PageWidth);
   GraphToShow^.nXStartOffset   := Round(Printer.PageWidth*0.08); {8%}
   GraphToShow^.nYStartOffset   := Round(Printer.PageHeight*0.1); {10%}
   GraphToShow^.nXEnd           := Round(Printer.PageWidth-(1.2*FLegendWidth))-GraphToShow^.nXStartOffset;
   GraphToShow^.nYEnd           := Round(Printer.PageHeight*0.75);
   if (GraphToShow^.nYEnd > GraphToShow^.nXEnd) then
      GraphToShow^.nYEnd := GraphToShow^.nXEnd;
   {Begin printing...}
   PrintInSession := TRUE;
   Printer.BeginDoc;
   PlotGraph; {Here it goes!}
   Printer.EndDoc;
   PrintInSession := FALSE;
   {Restore display values...}
   GraphToShow^.nXStartOffset   := nXStart; {margin}
   GraphToShow^.nYStartOffset   := nYStart;
   GraphToShow^.nXEnd           := nXEnd;
   GraphToShow^.nYEnd           := nYEnd;
   FLegendWidth                 := nLegendWidth;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) when you want to print the graph to Windows default printer          }
{     AND you add something else on the same paper. This function          }
{     will just add the chart to the OPEN printer canvas at given position }
{**************************************************************************}
Procedure TAABsoftGraph.AddGraphToOpenPrintCanvas(XStartPos,YStartPos,GraphWidth,GraphHeight: LongInt);
var
   nXEnd,nYEnd           : LongInt;
   nXStart,nYStart       : LongInt;
   nLegendWidth          : LongInt;
begin
   {Save display values...}
   nXEnd                        := GraphToShow^.nXEnd;
   nYEnd                        := GraphToShow^.nYEnd;
   nXStart                      := GraphToShow^.nXStartOffset;
   nYStart                      := GraphToShow^.nYStartOffset;
   nLegendWidth                 := FLegendWidth;
   {Set new values for printing the graph at EXISTING print canvas....}
   FLegendWidth                 := Round((FLegendWidth/(nXEnd+FLegendWidth))*GraphWidth);
   GraphToShow^.nXStartOffset   := Round(GraphWidth*0.08); {8%}
   GraphToShow^.nYStartOffset   := Round(GraphHeight*0.1); {10%}
   GraphToShow^.nXEnd           := Round(GraphWidth-(1.2*FLegendWidth))-GraphToShow^.nXStartOffset;
   GraphToShow^.nYEnd           := Round(GraphHeight*0.75);
   {Begin printing...NOTICE BeginDoc And EndDoc must be done OUTSIDE this procedure call}
   PrintInSession := TRUE;
   PlotGraph; {Here it goes!}
   PrintInSession := FALSE;
   {Restore display values...}
   GraphToShow^.nXStartOffset   := nXStart; {margin}
   GraphToShow^.nYStartOffset   := nYStart;
   GraphToShow^.nXEnd           := nXEnd;
   GraphToShow^.nYEnd           := nYEnd;
   FLegendWidth                 := nLegendWidth;
end;


function TAABsoftGraph.StrToPChar(strText : string): PChar;
begin
   StrPCopy(gstrText,strText);
   StrToPChar := gstrText;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) when you resize the canvas for the AABsoftGraph                      }
{  b) at program startup before drawing the first graph                    }
{**************************************************************************}
procedure TAABsoftGraph.UpdateGraphToScreen;
begin
   Bitmap.Width                 := inherited Width;
   Bitmap.Height                := inherited Height;
   inherited Picture.Graphic    := BitMap;
   GraphToShow^.nYEnd           := Bitmap.Height - 2*GraphToShow^.nYStartOffset; {canvas size, excluding margin}
   if (FShowLegend) then
      GraphToShow^.nXEnd        := Round((Bitmap.Width - 1.5*GraphToShow^.nXStartOffset) - FLegendWidth)
   else
      GraphToShow^.nXEnd        := Round(Bitmap.Width - 0.5*GraphToShow^.nXStartOffset);
   if (GraphToShow^.nXEnd<10) then GraphToShow^.nXEnd := 10;
   if (GraphToShow^.nYEnd<10) then GraphToShow^.nYEnd := 10;
   Invalidate;
   PlotGraph;
end;


{This procedure is called when user clicks on the main header}
procedure TAABsoftGraph.EditHeader;
var
   strString : String;
begin
   strString := GraphToShow^.strGraphHeader;
   if InputQuery('AABGraph',GraphToShow^.strGraphHeader+'->',strString) then
      GraphToShow^.strGraphHeader := strString;
   PlotGraph;
end;


{This procedure is called when user clicks on the x-axis header}
procedure TAABsoftGraph.EditXHeader;
var
   strString : String;
begin
   strString := GraphToShow^.strGraphXHeader;
   if InputQuery('AABGraph',GraphToShow^.strGraphXHeader+'->',strString) then
      GraphToShow^.strGraphXHeader := strString;
   PlotGraph;
end;


{**************************************************************************}
{ call this function :                                                     }
{  a) when you want to use other INI file for color settings, default is   }
{     COMPASS.INI                                                          }
{**************************************************************************}
procedure TAABsoftGraph.UseColorIniFile(strFileName : string);
begin
   strColorFile                 := strFileName;
end;


Procedure TAABsoftGraph.MyXHeader(nXPixelGap, nYPixelGap: LongInt ; strText: String);
begin
   MyGraphFont;
   if (bContainsNegative) or (GraphToShow^.nGraphType=GRAPH_DELTA_AVERAGE) then
   begin
      MyCBTextOut(GraphToShow^.nXStartOffset + Round(GraphToShow^.nXEnd/2),
                  GraphToShow^.nYStartOffset + GraphToShow^.nYEnd + MyTextHeight(strText),
                  strText)
   end
   else
   if (GraphToShow^.nYOrigo < 0) then
      MyCBTextOut(GraphToShow^.nXStartOffset + Round(GraphToShow^.nXEnd/2),
                  GraphToShow^.nYStartOffset + MyTextHeight(strText) +
                  Round(nYPixelGap*GraphToShow^.nYValueCount),
                  strText)
   else
      MyCBTextOut(GraphToShow^.nXStartOffset + Round(GraphToShow^.nXEnd/2),
                  GraphToShow^.nYStartOffset + MyTextHeight(strText) +
                  Round(nYPixelGap*(GraphToShow^.nYValueCount-GraphToShow^.nYOrigo)),
                  strText);
   MyGraphFont;
end;


{***************************************************************************}
{ FONT FUNCTIONS AND PROCEDURES                                             }
{***************************************************************************}
procedure TAABsoftGraph.SetHeaderFontName(strFont:String);
begin
   strHeaderFontName            := Copy(strFont,1,70);
   if FAutoUpdateGraph then PlotGraph;
end;


procedure TAABsoftGraph.SetLegendFontName(strFont:String);
begin
   strLegendFontName            := Copy(strFont,1,70);
   if FAutoUpdateGraph then PlotGraph;
end;


procedure TAABsoftGraph.SetAxisFontName(strFont:String);
begin
   strAxisFontName              := Copy(strFont,1,70);
   if FAutoUpdateGraph then PlotGraph;
end;


function  TAABsoftGraph.GetHeaderFontName : String;
begin
   GetHeaderFontName            := strHeaderFontName;
end;


function  TAABsoftGraph.GetLegendFontName : String;
begin
   GetLegendFontName            := strLegendFontName;
end;


function  TAABsoftGraph.GetAxisFontName : String;
begin
   GetAxisFontName              := strAxisFontName;
end;


{***************************************************************************}
{ MOUSE FUNCTIONS AND PROCEDURES                                            }
{***************************************************************************}
{
function  TAABsoftGraph.GetXValue(X,Y:integer): real;
var
   xOrigo    : LongInt;
   nXPixelGap: LongInt;
begin
   if (Y>GraphToShow^.nYStartOffset) and (Y<GraphToShow^.nYStartOffset+GraphToShow^.nYEnd) and
      (X>GraphToShow^.nXStartOffset) and (X<GraphToShow^.nXStartOffset+GraphToShow^.nXEnd) and
      (GraphToShow^.nGraphType <> GRAPH_PIE)
   then
   begin
      nXPixelGap  := Round((GraphToShow^.nXEnd-GraphToShow^.nXStartOffset) /
                           (GraphToShow^.nXValueCount+1));
      xOrigo :=GraphToShow^.nXStartOffset + nXPixelGap*(GraphToShow^.nXOrigo);

      GetXValue   := Round((X-xOrigo)/nXPixelGap);
   end else GetXValue := 0;
end;


function  TAABsoftGraph.GetYValue(X,Y:integer): real;
var
   yOrigo    : LongInt;
   nYPixelGap: LongInt;
begin
   if (Y>GraphToShow^.nYStartOffset) and (Y<GraphToShow^.nYStartOffset+GraphToShow^.nYEnd) and
      (X>GraphToShow^.nXStartOffset) and (X<GraphToShow^.nXStartOffset+GraphToShow^.nXEnd) and
      (GraphToShow^.nGraphType <> GRAPH_PIE)
   then
   begin
      nYPixelGap  := Round(GraphToShow^.nYEnd/(GraphToShow^.nYValueCount+1));
      yOrigo      := GraphToShow^.nYStartOffset +
                     Round(nYPixelGap*(GraphToShow^.nYValueCount-GraphToShow^.nYOrigo));
      GetYValue   := ((yOrigo-Y)/nYPixelGap)*GraphToShow^.nYGap;
   end else GetYValue := 0;
end;
}

procedure TAABsoftGraph.MouseUp(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
  Screen.Cursor := crDefault;
  inherited MouseUp(Button, Shift, X, Y);

  if (bStartDrag) then
  begin
     FLegendWidth := FLegendWidth + (nMouseDownX-X);
     GraphToShow^.nXEnd := GraphToShow^.nXEnd - (nMouseDownX-X);
     PlotGraph;
  end;
  if (bMouseLegend) then
  begin
     PlotGraph;
     bMouseLegend := FALSE;
  end;
  bStartDrag   := FALSE;
end;


procedure TAABsoftGraph.MouseDown(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);
var
  nXPixelGap  : LongInt;
  nYPixelGap  : LongInt;
begin
  inherited MouseDown(Button, Shift, X, Y);

  if (FMouseEdit) then
  begin
     if (Y<GraphToShow^.nYStartOffset) then EditHeader;
     if (Y>(GraphToShow^.nYStartOffset+GraphToShow^.nYEnd)) then EditXHeader;
  end;

  if (FMouseInfo) then
  begin
     bStartDrag   := FALSE;
     nMouseDownX  := X;
     nMouseDownY  := Y;
     if (Y>GraphToShow^.nYStartOffset) and (Y<GraphToShow^.nYStartOffset+GraphToShow^.nYEnd) and
        (X>GraphToShow^.nXStartOffset) and (X<GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+10)
     then
     begin
        {Legend resize...}
        if (X>(GraphToShow^.nXStartOffset+GraphToShow^.nXEnd)-5) then
        begin
           bStartDrag    := TRUE;
           Screen.Cursor := crSizeWE;
        end;
        {Inside the actual graph...}
        if (X<=(GraphToShow^.nXStartOffset+GraphToShow^.nXEnd)-5) and
           (GraphToShow^.nGraphType<>GRAPH_PIE) and
           (GraphToShow^.nGraphType<>GRAPH_DELTA_AVERAGE) then
        begin
           nXPixelGap   := Round((GraphToShow^.nXEnd-GraphToShow^.nXStartOffset) /
                                 (GraphToShow^.nXValueCount+1));
           nMouseValue  := Round((X-GraphToShow^.nXStartOffset)/(nXPixelGap));
           case (GraphToShow^.nGraphType) of
              GRAPH_BAR,
              GRAPH_BAR_WITH_AVE:
                 if (GraphToShow^.nSeriesCount=1) then {check for series count}
                 nMouseSeries := Round( ((X+Round(nXPixelGap/2))-
                                         (GraphToShow^.nXStartOffset+
                                          GraphToShow^.nXOrigo*nXPixelGap+
                                          nXPixelGap*nMouseValue))  /
                                         Round(nXPixelGap/(GraphToShow^.nSeriesCount+0.1))+0.1)
                 else
                 nMouseSeries := Round( ((X+Round(nXPixelGap/2))-
                                         (GraphToShow^.nXStartOffset+
                                          GraphToShow^.nXOrigo*nXPixelGap+
                                          nXPixelGap*nMouseValue))  /
                                         Round(nXPixelGap/(GraphToShow^.nSeriesCount+0.5))+0.5);
              GRAPH_STACKED_BAR,
              GRAPH_LINE,
              GRAPH_STACKED_BAR_100:
                 nMouseSeries := 0;
           end;
           if (nMouseValue>GraphToShow^.nXValueCount) or (nMouseValue < 0) then
              nMouseValue := 0;
           if (nMouseSeries>GraphToShow^.nYValueCount) then nMouseSeries := 0;
           ShowMouseMessage(X,Y,nMouseValue,nMouseSeries);
        end;
     end;
  end;
end;


procedure TAABsoftGraph.ShowMouseMessage(X,Y,nMouseValue,nMouseSeries: Integer);
var
   strMessage1 : String;
   strMessage2 : String;
   strMessage3 : String;
   strMessage5 : String;
   nWidth      : Integer;
   nHeight     : Integer;
   nLineH      : Integer;
   nLineCount  : Integer;
   I           : Integer;
begin
   strMessage1 := 'No values here!';
   nWidth      := MyTextWidth(strMessage1);
   nLineH      := Round(MyTextHeight(strMessage1)*1.07);
   nLineCount  := 0;
   if (nMouseValue=0) then
   begin
      MyColorRectangle(0,X+3,Y+3,X+nWidth+3+5,Y+nLineH+3);
      MyColorRectangle(-1,X,Y,X+nWidth+5,Y+nLineH);
      MyLBTextOut(X+2,Y,strMessage1);
      bMouseLegend := TRUE;
      exit;
   end;
   {We will show some real values...}
   if (nMouseSeries=0) then
   begin
      {show all values in the series...}
      nLineCount  := GraphToShow^.nSeriesCount;
      nHeight     := nLineH*(nLineCount+2);
      strMessage1 := GraphToShow^.nXLegendsValue[nMouseValue];
      strMessage2 := '-';
      if (nWidth < MyTextWidth(strMessage1)) then
         nWidth      := MyTextWidth(strMessage1);
   end
   else
   begin
      nLineCount  := 1;
      nHeight     := nLineH*(nLineCount+2);
      strMessage1 := GraphToShow^.nXLegendsValue[nMouseValue];
      if (nWidth < MyTextWidth(strMessage1)) then
         nWidth      := MyTextWidth(strMessage1);
      if (nMouseSeries>0) then
         strMessage2 := GraphToShow^.nSeriesLegendsValue[nMouseSeries];
      if (MyTextWidth(strMessage2)>nWidth) then
         nWidth      := MyTextWidth(strMessage2);
      strMessage3 := FloatToStrF(GraphToShow2^.nValue[nMouseSeries,nMouseValue],ffFixed,REALPREC,3);
   end;

   nWidth := nWidth  + 25;
   nHeight:= nHeight + 4;
   MyColorRectangle( 0,X+3,Y+3,X+nWidth+3,Y+nHeight+3);
   MyColorRectangle(-2,X,Y,X+nWidth,Y+nHeight);

   MyLBTextOut(X+2,Y,strMessage1);
   MyLBTextOut(X+2,Y+nLineH,strMessage2);
   if (nMouseSeries=0) then
      for I := 1 to nLineCount do
      begin
         strMessage3 := IntToStr(I)+' : ' + FloatToStrF(GraphToShow2^.nValue[I,nMouseValue],ffFixed,REALPREC,3);
         MyLBTextOut(X+2, Y+(1+I)*nLineH, strMessage3);
      end
   else
      MyLBTextOut(X+2, Y+2*nLineH, strMessage3);

   bMouseLegend := TRUE;
end;


{***************************************************************************}
{ PIE FUNCTIONS AND PROCEDURES                                              }
{***************************************************************************}
Procedure TAABsoftGraph.MyDisplayAsPie(nSeries:Integer);
var
   nSize    : Integer;
   I        : Integer;
   nLast    : Integer;
   nXExtra  : Integer;
   nSum     : real;
   n100Sum  : real;
   nP       : real;
begin
   ClearScreen;

   {Main Header}
   MyHeader(GraphToShow^.strGraphHeader);
   MyPieLegend(nSeries);
   if (GraphToShow^.nXEnd<GraphToShow^.nYEnd) then
   begin
      nSize    := GraphToShow^.nXEnd;
      nXExtra  := 0;
   end
   else
   begin
      nSize    := GraphToShow^.nYEnd;
      nXExtra  := Round((GraphToShow^.nXEnd-GraphToShow^.nYEnd)/2);
   end;
   {Count total sum...}
   n100Sum     := 0;
   for I := 1 to MAX_VALUES do
      n100Sum  := n100Sum + GraphToShow2^.nValue[nSeries,I];
   {Show background pie....}
   SetRectangleColor(0); {black...}
   MyPiePercentage(GraphToShow^.nXStartOffset+nXExtra+2,
                   GraphToShow^.nYStartOffset+2,
                   nSize, 100);
   {Show pie if not zero...}
   if (n100Sum <> 0) then
   begin
      nSum  := n100Sum;
      nLast := GraphToShow^.nXValueCount+1;
      if (nLast>MAX_VALUES) then nLast := MAX_VALUES;
      for I := nLast downto 2 do
      begin
         nSum := nSum - GraphToShow2^.nValue[nSeries,I];
         nP := 100*(nSum/n100Sum);
         SetRectangleColor(I-1);
         MyPiePercentage(GraphToShow^.nXStartOffset+nXExtra,
                         GraphToShow^.nYStartOffset,
                         nSize, nP);
      end;
   end;
end;


Procedure TAABsoftGraph.MyPiePercentage(X1,Y1,W: LongInt; nPercentage: real);
var
   nOrigoX, nOrigoY : LongInt;
   nGrade           : real;
   nStartGrade      : real;
   x,y              : real;
   nLen             : real;
begin
   nOrigoX  := Round((W-1.01)/2)+X1;
   nOrigoY  := Round((W-1.01)/2)+Y1;
   nGrade   := (nPercentage/100)*2*Pi;
   nStartGrade := (2/8)*2*Pi;
   nLen     := Round((W-1)/2);
   x := Cos(nStartGrade+nGrade)*nLen;
   y := Sin(nStartGrade+nGrade)*nLen;
   MyPie(X1,Y1,X1+W,Y1+W,
         nOrigoX,Y1,nOrigoX+Round(x),nOrigoY-Round(y));
end;


Procedure TAABsoftGraph.MyPieLegend(nSeries: Integer);
var
   I           : Integer;
   nTextHeight : LongInt;
   nChars      : Integer;
begin
   {Count how many characters to show in the separate legend}
   nChars := Round(FLegendWidth / MyTextWidth('1'));
   {Decrease the value due to the color box shown}
   if (nChars>4) then nChars := nChars-4;

   MySmallGraphFont;
   nTextHeight := Round(MyTextHeight('Mg')*1.2);

   if FShowLegend then
   begin
      MyColorRectangle(0,
                  GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+6,
                  GraphToShow^.nYStartOffset+1*nTextHeight+6+4,
                  GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+FLegendWidth+6,
                  GraphToShow^.nYStartOffset+(GraphToShow^.nXValueCount+1)*nTextHeight+6+4);
      MyColorRectangle(-1,
                  GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+3,
                  GraphToShow^.nYStartOffset+1*nTextHeight+3+4,
                  GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+FLegendWidth+3,
                  GraphToShow^.nYStartOffset+(GraphToShow^.nXValueCount+1)*nTextHeight+3+4);
      for I := 1 to GraphToShow^.nXValueCount do
      begin
         DrawSeriesColorBox(I,MyTextWidth('12')-2,nTextHeight-4,
                            GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+7,
                            GraphToShow^.nYStartOffset+I*nTextHeight+9);
         SetFontColor(0);
         MyLBTextOut(GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+7+MyTextWidth('12'),
                     GraphToShow^.nYStartOffset+I*nTextHeight+7,
                     Copy(GraphToShow^.nXLegendsValue[I],1,nChars))
      end;
   end;
end;


function TAABsoftGraph.MyPt(AX, AY: Integer): TPoint;
begin
   with Result do
   begin
      X := AX;
      Y := AY;
   end;
end;


procedure TAABsoftGraph.PlotSquare(x, y: Integer);
begin
   MyPolygon([MyPt(x - GraphToShow^.PointSize, y - GraphToShow^.PointSize),
              MyPt(x + GraphToShow^.PointSize, y - GraphToShow^.PointSize),
              MyPt(x + GraphToShow^.PointSize, y + GraphToShow^.PointSize),
              MyPt(x - GraphToShow^.PointSize, y + GraphToShow^.PointSize)]);
end;


procedure TAABsoftGraph.PlotCircle(x, y: Integer);
begin
   MyEllipse(x - GraphToShow^.PointSize,
             y - GraphToShow^.PointSize,
             x + GraphToShow^.PointSize,
             y + GraphToShow^.PointSize);
end;


procedure TAABsoftGraph.PlotDiamond(x, y: Integer);
begin
   MyPolygon([MyPt(x, y - GraphToShow^.PointSize),
              MyPt(x + GraphToShow^.PointSize, y),
              MyPt(x, y + GraphToShow^.PointSize),
              MyPt(x - GraphToShow^.PointSize, y)]);
end;


procedure TAABsoftGraph.PlotCross(x, y: Integer);
begin
   MyDrawLine(x - GraphToShow^.PointSize, y, x + GraphToShow^.PointSize, y);
   MyDrawLine(x, y - GraphToShow^.PointSize, x, y + GraphToShow^.PointSize);
end;


procedure TAABsoftGraph.ClearScreen;
begin
   {Clear screen}
   SetLineColor(-1);
   MyColorRectangle(-1,
                  0,
                  0,
                  3*GraphToShow^.nXStartOffset+GraphToShow^.nXEnd+FLegendWidth,
                  5*GraphToShow^.nYStartOffset+GraphToShow^.nYEnd); {6}
   SetRectangleColor(0);
   SetLineColor(0);
end;


{NEW chart type!!!}
procedure TAABsoftGraph.MyDisplayAsDeltaAverage;
var
   nXPixelGap  : LongInt;
   nYPixelGap  : LongInt;
   xOrigo      : LongInt;
   yOrigo      : LongInt;
   I,J         : LongInt;
   nTempyOrigo : LongInt;
begin
   {new type of chart...}
   ClearScreen;

   {Check graph values and correct if wrong. Actually not needed if there are no bugs}
   if (GraphToShow^.nYValueCount>MAX_Y_LEGENDS) then
       GraphToShow^.nYValueCount := MAX_Y_LEGENDS;
   if (GraphToShow^.nYValueCount=0) then
       GraphToShow^.nYValueCount := 1;
   if (GraphToShow^.nXValueCount>MAX_VALUES) then
       GraphToShow^.nXValueCount := MAX_VALUES;
   if (GraphToShow^.nXValueCount=0) then
       GraphToShow^.nXValueCount := 1;
   if (GraphToShow^.nSeriesCount>MAX_SERIES) then
       GraphToShow^.nSeriesCount := MAX_SERIES;
   if (GraphToShow^.nYGap=0) then
       GraphToShow^.nYGap := 1;

   nXPixelGap  := Round((GraphToShow^.nYEnd-GraphToShow^.nYStartOffset) /
                        (GraphToShow^.nXValueCount));
   nYPixelGap  := Round((GraphToShow^.nXEnd-GraphToShow^.nXStartOffset) /
                        (GraphToShow^.nYValueCount+1));

   nTempyOrigo          := GraphToShow^.nYOrigo;
   GraphToShow^.nYOrigo := GraphToShow^.nYValueCount div 2;

   yOrigo  := GraphToShow^.nXStartOffset + (nYPixelGap*GraphToShow^.nYOrigo);
   xOrigo  := GraphToShow^.nYStartOffset;

   {Create texts for y-axis}
   for I := 1 to MAX_Y_LEGENDS do
      GraphToShow^.nYLegendsValue[I] := IntToStr(Round(((I-1)-GraphToShow^.nYOrigo)*GraphToShow^.nYGap));

   {Y-axis legends and lines...}
   MyGraphFont;
   for I := 1 to (GraphToShow^.nYValueCount+1) do
   begin
      MyLBTextOut(yOrigo + (nYPixelGap*((I-1)-GraphToShow^.nYOrigo)),
                  xOrigo+nXPixelGap*GraphToShow^.nXValueCount+2,
                  GraphToShow^.nYLegendsValue[I]);
      MyDrawDotLine(yOrigo - (nYPixelGap*((I-1)-GraphToShow^.nYOrigo)),
                    xOrigo,
                    yOrigo - (nYPixelGap*((I-1)-GraphToShow^.nYOrigo)),
                    xOrigo + (nXPixelGap*(GraphToShow^.nXValueCount))
                    );
   end;

   {Draw Y-axis}
   MyMoveTo(GraphToShow^.nXStartOffset, xOrigo);
   MyAxisLineTo(GraphToShow^.nXEnd, xOrigo);
   {Draw second y-axis}
   MyMoveTo(GraphToShow^.nXStartOffset, xOrigo+nXPixelGap*GraphToShow^.nXValueCount+1);
   MyAxisLineTo(GraphToShow^.nXEnd, xOrigo+nXPixelGap*GraphToShow^.nXValueCount+1);
   {Draw X-axis}
   MyMoveTo(yOrigo, xOrigo);
   MyAxisLineTo(yOrigo, xOrigo+nXPixelGap*GraphToShow^.nXValueCount+1);

   {X-axis legends...}
   MyShowLegend(nXPixelGap,nYPixelGap);

   {Main Header}
   MyHeader(GraphToShow^.strGraphHeader);

   {X axis header}
   MyXHeader(nXPixelGap,nYPixelGap,GraphToShow^.strGraphXHeader);

   for I := 1 to GraphToShow^.nSeriesCount do
       for J := 1 to GraphToShow^.nXValueCount do
           if (GraphToShow^.nSeriesCount=1) then
               MyColorRectangle(I,
                                yOrigo,
                                xOrigo+J*nXPixelGap+(I-1)*Round(nXPixelGap/(GraphToShow^.nSeriesCount+0.1))-nXPixelGap,
                                yOrigo+Round(((GraphToShow2^.nValue[I,J]-GraphToShow^.nAveValue[J])/
                                               GraphToShow^.nYGap)*nYPixelGap),
                                xOrigo+J*nXPixelGap+I*Round(nXPixelGap/(GraphToShow^.nSeriesCount+0.1))-nXPixelGap)
           else
               MyColorRectangle(I,
                                yOrigo,
                                xOrigo+J*nXPixelGap+(I-1)*Round(nXPixelGap/(GraphToShow^.nSeriesCount+0.5))-nXPixelGap,
                                yOrigo+Round(((GraphToShow2^.nValue[I,J]-GraphToShow^.nAveValue[J])/
                                               GraphToShow^.nYGap)*nYPixelGap),
                                xOrigo+J*nXPixelGap+I*Round(nXPixelGap/(GraphToShow^.nSeriesCount+0.5))-nXPixelGap);
   GraphToShow^.nYOrigo := nTempyOrigo;
end;



{***************************************************************************}
{ Device depended functions for the rest of this module...check for printer }
{ or check for metafile output!                                             }
{***************************************************************************}

Procedure TAABsoftGraph.MyHeader(strText: String);
var
   LogFont           : TLogFont;
   hMetaFileFont     : HFont;
   SaveOldFileFont   : THandle;
   OldColor          : TColorRef;
begin
   MyHeaderFont;
   MyCBTextOut(GraphToShow^.nXStartOffset + Round(GraphToShow^.nXEnd/2),
               GraphToShow^.nYStartOffset - (MyTextHeight(strText) + 2),
               strText);
   MyGraphFont;
end;


Procedure TAABsoftGraph.MySmallGraphFont;
begin
   if PrintInSession then
   begin
      Printer.Canvas.Brush.Color := clWhite;
      Printer.Canvas.Font.Name   := strLegendFontName;
      Printer.Canvas.Font.Size   := FLegendFontSize;
      Printer.Canvas.Font.Color  := FLegendFontColor;
   end
   else
   begin
      inherited Canvas.Brush.Color := clWhite;
      inherited Canvas.Font.Name   := strLegendFontName;
      inherited Canvas.Font.Size   := FLegendFontSize;
      inherited Canvas.Font.Color  := FLegendFontColor;
   end;
end;


Procedure TAABsoftGraph.MyGraphFont;
begin
   if PrintInSession then
   begin
      Printer.Canvas.Brush.Color := clWhite;
      Printer.Canvas.Font.Name   := strAxisFontName;
      Printer.Canvas.Font.Size   := FAxisFontSize;
      Printer.Canvas.Font.Color  := FAxisFontColor;
   end
   else
   begin
      inherited Canvas.Brush.Color := clWhite;
      inherited Canvas.Font.Name   := strAxisFontName;
      inherited Canvas.Font.Size   := FAxisFontSize;
      inherited Canvas.Font.Color  := FAxisFontColor;
   end;
end;


Procedure TAABsoftGraph.MyHeaderFont;
begin
   if PrintInSession then
   begin
      Printer.Canvas.Brush.Color := clWhite;
      Printer.Canvas.Font.Name   := strHeaderFontName;
      Printer.Canvas.Font.Size   := FHeaderFontSize;
      Printer.Canvas.Font.Color  := FHeaderFontColor;
   end
   else
   begin
      inherited Canvas.Brush.Color := clWhite;
      inherited Canvas.Font.Name   := strHeaderFontName;
      inherited Canvas.Font.Size   := FHeaderFontSize;
      inherited Canvas.Font.Color  := FHeaderFontColor;
   end;
end;


Procedure TAABsoftGraph.MyMoveTo(X,Y: Integer);
begin
   if PrintInSession then
      Printer.Canvas.MoveTo(X,Y)
   else
      inherited Canvas.MoveTo(X,Y);
end;


Procedure TAABsoftGraph.MyLineTo(X,Y: Integer);
begin
   if PrintInSession then
      Printer.Canvas.LineTo(X,Y)
   else
      inherited Canvas.LineTo(X,Y);
end;


Procedure TAABsoftGraph.MyThickLineTo(X,Y: Integer);
begin
   if PrintInSession then
   begin
      Printer.Canvas.Pen.Width := FThickLineWidth;
      Printer.Canvas.LineTo(X,Y);
      Printer.Canvas.Pen.Width := 1; {restore}
   end
   else
   begin
      inherited Canvas.Pen.Width := FThickLineWidth;
      inherited Canvas.LineTo(X,Y);
      inherited Canvas.Pen.Width := 1; {restore}
   end;
end;


Procedure TAABsoftGraph.MyAxisLineTo(X,Y: Integer);
begin
   if PrintInSession then
   begin
      Printer.Canvas.Pen.Width := FAxisLineWidth;
      Printer.Canvas.LineTo(X,Y);
      Printer.Canvas.Pen.Width := 1; {restore}
   end
   else
   begin
      inherited Canvas.Pen.Width := FAxisLineWidth;
      inherited Canvas.LineTo(X,Y);
      inherited Canvas.Pen.Width := 1; {restore}
   end;
end;


function TAABsoftGraph.MyTextWidth(strText : String): LongInt;
begin
   if PrintInSession then
      MyTextWidth := Printer.Canvas.TextWidth(strText)
   else
      MyTextWidth := inherited Canvas.TextWidth(strText);
end;


function TAABsoftGraph.MyTextHeight(strText : String): LongInt;
begin
   if PrintInSession then
      MyTextHeight := Printer.Canvas.TextHeight(strText)
   else
      MyTextHeight := inherited Canvas.TextHeight(strText);
end;


Procedure TAABsoftGraph.MyLBTextOut(X, Y: Integer; const Text: string);
begin
   if PrintInSession then
      Printer.Canvas.TextOut(X, Y+1, Text)
   else
      inherited Canvas.TextOut(X, Y+1, Text);
end;


Procedure TAABsoftGraph.MyCBTextOut(X, Y: Integer; const Text: string);
begin
   if PrintInSession then
      Printer.Canvas.TextOut(X-Round(Printer.Canvas.TextWidth(Text)/2),
                             Y+1,
                             Text)
   else
      inherited Canvas.TextOut(X-Round(inherited Canvas.TextWidth(Text)/2),
                               Y+1,
                               Text);
end;


Procedure TAABsoftGraph.MyRCTextOut(X, Y: Integer; const Text: string);
begin
   if PrintInSession then
      Printer.Canvas.TextOut(X-Printer.Canvas.TextWidth(Text),
                             Y-Round(Printer.Canvas.TextHeight(Text)/2),
                             Text)
   else
      inherited Canvas.TextOut(X-inherited Canvas.TextWidth(Text),
                               Y-Round(inherited Canvas.TextHeight(Text)/2),
                               Text);
end;


Procedure TAABsoftGraph.MyRectangle(X, Y, X2, Y2: Integer);
begin
   if PrintInSession then
      Printer.Canvas.Rectangle(X, Y, X2, Y2)
   else
      inherited Canvas.Rectangle(X, Y, X2, Y2);
end;


Procedure TAABsoftGraph.MyColorRectangle(Series : Integer; X, Y, X2, Y2: Integer);
begin
   if PrintInSession then
   begin
      SetRectangleColor(Series);
      Printer.Canvas.Rectangle(X, Y, X2, Y2);
   end
   else
   begin
      SetRectangleColor(Series);
      inherited Canvas.Rectangle(X, Y, X2, Y2);
   end;
end;


Procedure TAABsoftGraph.MyPie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Longint);
begin
   if PrintInSession then
      Printer.Canvas.Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4)
   else
      inherited Canvas.Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4);
end;


Procedure TAABsoftGraph.MyArc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
begin
   if PrintInSession then
      Printer.Canvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4)
   else
      inherited Canvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4);
end;


Procedure TAABsoftGraph.MyPolygon(Points: array of TPoint);
begin
   if PrintInSession then
      Printer.Canvas.Polygon(Points)
   else
      inherited Canvas.Polygon(Points);
end;


Procedure TAABsoftGraph.MyEllipse(X1, Y1, X2, Y2: Integer);
begin
   if PrintInSession then
      Printer.Canvas.Ellipse(X1, Y1, X2, Y2)
   else
      inherited Canvas.Ellipse(X1, Y1, X2, Y2);
end;


procedure TAABsoftGraph.MyDrawLine(X1, Y1, X2, Y2: Integer);
begin
   MyMoveTo(X1, Y1);
   MyLineTo(X2, Y2);
end;


procedure TAABsoftGraph.MyDrawDotLine(X1, Y1, X2, Y2: Integer);
begin
   SetDotLines;
   MyMoveTo(X1, Y1);
   MyLineTo(X2, Y2);
   SetSolidLines;
end;


function TAABsoftGraph.GetSelectedScheme: Integer;
begin
   GetSelectedScheme := FColorScheme;
end;


Procedure TAABsoftGraph.SetColorToScheme(nScheme,nIndex:Integer; nColor:TColor);
var
   MyIni   : TIniFile;
begin
   {Default file is 'COMPASS.INI'}
   MyIni := TIniFile.Create(strColorFile);
   With MyIni do
      WriteString('Scheme'+IntToStr(nScheme),
                  IntToStr(nIndex),
                  ColorToString(nColor));
   MyIni.Free;
   if FAutoUpdateGraph then PlotGraph;
end;


Procedure TAABsoftGraph.SaveColorScheme(nScheme : Integer);
var
   MyIni   : TIniFile;
   nIndex  : Integer;
begin
   {Default file is 'COMPASS.INI'}
   MyIni := TIniFile.Create(strColorFile);
   With MyIni do
      for nIndex := 1 to MAX_SERIES do
         WriteString('Scheme'+IntToStr(nScheme),
                     IntToStr(nIndex),
                     ColorToString(GetColorFromScheme(nScheme,nIndex)));
   MyIni.Free;
end;


Function TAABsoftGraph.GetColorFromScheme(nScheme,nIndex : Integer): TColor;
var
   MyIni   : TIniFile;
begin
   {Default file is 'COMPASS.INI'}
   MyIni := TIniFile.Create(strColorFile);
   With MyIni do
      GetColorFromScheme := StringToColor(ReadString('Scheme'+IntToStr(nScheme),
                                                     IntToStr(nIndex),
                                                     GetDefaultColorString(nIndex)));
   MyIni.Free;
end;


function TAABsoftGraph.GetDefaultColorString(nIndex : Integer): String;
begin
   if (nIndex <= 10) then
   begin
      case nIndex of
         -2: GetDefaultColorString := 'clWhite'; {MouseDownBox}
         -1: GetDefaultColorString := 'clWhite';
          0: GetDefaultColorString := 'clBlack';
          1: GetDefaultColorString := 'clLime';
          2: GetDefaultColorString := 'clBlue';
          3: GetDefaultColorString := 'clRed';
          4: GetDefaultColorString := 'clGreen';
          5: GetDefaultColorString := 'clMaroon';
          6: GetDefaultColorString := 'clOlive';
          7: GetDefaultColorString := 'clSilver';
          8: GetDefaultColorString := 'clTeal';
          9: GetDefaultColorString := 'clBlack';
         10: GetDefaultColorString := 'clAqua';
      end;
   end
   else
   begin
         GetDefaultColorString := '$00888888';
   end;
end;


Procedure TAABsoftGraph.SetFontColor(Series : Integer);
begin
   if PrintInSession then
      Printer.Canvas.Font.Color := GetColorFromScheme(GetSelectedScheme,Series)
   else
      inherited Canvas.Font.Color := GetColorFromScheme(GetSelectedScheme,Series);
end;


Procedure TAABsoftGraph.SetRectangleColor(Series : Integer);
begin
   if PrintInSession then
      Printer.Canvas.Brush.Color := GetColorFromScheme(GetSelectedScheme,Series)
   else
      inherited Canvas.Brush.Color := GetColorFromScheme(GetSelectedScheme,Series);
end;


Procedure TAABsoftGraph.SetLineColor(Series : Integer);
begin
   if PrintInSession then
      Printer.Canvas.Pen.Color := GetColorFromScheme(GetSelectedScheme,Series)
   else
      inherited Canvas.Pen.Color := GetColorFromScheme(GetSelectedScheme,Series);
end;


Procedure TAABsoftGraph.SetDotLines;
begin
   if PrintInSession then
      Printer.Canvas.Pen.Style := psDot
   else
      inherited Canvas.Pen.Style := psDot;
end;


Procedure TAABsoftGraph.SetSolidLines;
begin
   if PrintInSession then
      Printer.Canvas.Pen.Style := psSolid
   else
      inherited Canvas.Pen.Style := psSolid;
end;


Procedure TAABsoftGraph.GraphToClipboard;
begin
   {This works with bitmaps at least...how to do it as a metafile?}
   Clipboard.Assign(inherited Picture);
end;


Procedure TAABsoftGraph.ShowAsBar;
begin
   GraphToShow^.nYOrigo      := nOldYOrigo;
   GraphToShow^.nYGap        := nOldYGap;
   GraphToShow^.nYValueCount := nOldYValueCount;
   GraphToShow^.nGraphType   := GRAPH_BAR;
   PlotGraph;
end;


Procedure TAABsoftGraph.ShowAsStackedBar;
begin
   if bContainsNegative then
   begin
      ShowMessage('Not supported for negative values.');
      exit;
   end;
   GraphToShow^.nYOrigo      := nOldYOrigo;
   GraphToShow^.nYGap        := nOldYGap;
   GraphToShow^.nYValueCount := nOldYValueCount;
   GraphToShow^.nGraphType   := GRAPH_STACKED_BAR;
   PlotGraph;
end;


Procedure TAABsoftGraph.ShowAsLine;
begin
   GraphToShow^.nYOrigo      := nOldYOrigo;
   GraphToShow^.nYGap        := nOldYGap;
   GraphToShow^.nYValueCount := nOldYValueCount;
   GraphToShow^.nGraphType   := GRAPH_LINE;
   PlotGraph;
end;


Procedure TAABsoftGraph.ShowAsBarWithAve;
begin
   GraphToShow^.nYOrigo      := nOldYOrigo;
   GraphToShow^.nYGap        := nOldYGap;
   GraphToShow^.nYValueCount := nOldYValueCount;
   GraphToShow^.nGraphType   := GRAPH_BAR_WITH_AVE;
   PlotGraph;
end;


Procedure TAABsoftGraph.ShowAs100StackedBar;
begin
   if bContainsNegative then
   begin
      ShowMessage('Not supported for negative values.');
      exit;
   end;
   if (GraphToShow^.nGraphType = GRAPH_STACKED_BAR_100) then exit;
   GraphToShow^.nYOrigo      := nOldYOrigo;
   GraphToShow^.nYGap        := nOldYGap;
   GraphToShow^.nYValueCount := nOldYValueCount;
   GraphToShow^.nGraphType   := GRAPH_STACKED_BAR_100;
   PlotGraph;
end;


Procedure TAABsoftGraph.ShowAsPie;
begin
   if bContainsNegative then
   begin
      ShowMessage('Not supported for negative values.');
      exit;
   end;
   GraphToShow^.nYOrigo      := nOldYOrigo;
   GraphToShow^.nYGap        := nOldYGap;
   GraphToShow^.nYValueCount := nOldYValueCount;
   if (GraphToShow^.nGraphType = GRAPH_PIE) then exit;
   GraphToShow^.nGraphType := GRAPH_PIE;
   PlotGraph;
end;


Procedure TAABsoftGraph.ShowAsLineWithMark;
begin
   GraphToShow^.nYOrigo      := nOldYOrigo;
   GraphToShow^.nYGap        := nOldYGap;
   GraphToShow^.nYValueCount := nOldYValueCount;
   GraphToShow^.nGraphType   := GRAPH_LINE_WITH_MARK;
   PlotGraph;
end;


Procedure TAABsoftGraph.ShowAsMark;
begin
   GraphToShow^.nYOrigo      := nOldYOrigo;
   GraphToShow^.nYGap        := nOldYGap;
   GraphToShow^.nYValueCount := nOldYValueCount;
   GraphToShow^.nGraphType   := GRAPH_MARK;
   PlotGraph;
end;


procedure TAABsoftGraph.ShowAsDeltaAverage;
begin
   GraphToShow^.nYOrigo      := nOldYOrigo;
   GraphToShow^.nYGap        := nOldYGap;
   GraphToShow^.nYValueCount := nOldYValueCount;
   GraphToShow^.nGraphType   := GRAPH_DELTA_AVERAGE;
   PlotGraph;
end;


function  TAABsoftGraph.GetGraphType: integer;
begin
   GetGraphType := GraphToShow^.nGraphType;
end;


Procedure TAABsoftGraph.ChangeXValuesWithSeries;
var
   I,J                      : Integer;
   nTempXValueCount         : Integer;
   nTempSeriesCount         : Integer;
   TempGraphToShow          : ^TGraphToShow;
   TempGraphToShow2         : ^TGraphToShow2;
begin
   New(TempGraphToShow);
   New(TempGraphToShow2);
   {copy to temp....}
   For I := 1 to MAX_VALUES do
      TempGraphToShow^.nXLegendsValue[I] := GraphToShow^.nXLegendsValue[I];
   For I := 1 to MAX_SERIES do
      TempGraphToShow^.nSeriesLegendsValue[I] := GraphToShow^.nSeriesLegendsValue[I];
   For I := 1 to MAX_SERIES do
      For J := 1 to MAX_VALUES do
         TempGraphToShow2^.nValue[I,J] := GraphToShow2^.nValue[I,J];
   TempGraphToShow^.nXValueCount      := GraphToShow^.nXValueCount;
   TempGraphToShow^.nSeriesCount      := GraphToShow^.nSeriesCount;
   {copy reversed back....}
   For I := 1 to MAX_VALUES do
      GraphToShow^.nXLegendsValue[I] := TempGraphToShow^.nSeriesLegendsValue[I];
   For I := 1 to MAX_SERIES do
      GraphToShow^.nSeriesLegendsValue[I] := TempGraphToShow^.nXLegendsValue[I];
   For I := 1 to MAX_SERIES do
      For J := 1 to MAX_VALUES do
         GraphToShow2^.nValue[I,J] := TempGraphToShow2^.nValue[J,I];
   GraphToShow^.nXValueCount := TempGraphToShow^.nSeriesCount;
   GraphToShow^.nSeriesCount := TempGraphToShow^.nXValueCount;
   Dispose(TempGraphToShow);
   Dispose(TempGraphToShow2);
   {Necessary to count average line... as the old ones do no good}
   CountGraphAverage;
   PlotGraph;
end;


Procedure TAABsoftGraph.UsePFITemplate;
begin
   GraphToShow^.nYGap        := 1;
   GraphToShow^.nYValueCount := 6;
   GraphToShow^.nYOrigo      := 0;
   PlotGraph;
end;


Procedure TAABsoftGraph.UseICFTemplate;
begin
   GraphToShow^.nYGap        := 1;
   GraphToShow^.nYValueCount := 6;
   GraphToShow^.nYOrigo      := 0;
   PlotGraph;
end;


Procedure TAABsoftGraph.UseTLETemplate;
begin
   GraphToShow^.nYGap        := 1;
   GraphToShow^.nYValueCount := 5;
   GraphToShow^.nYOrigo      := 0;
   GraphToShow^.nGraphType   := GRAPH_BAR;
   PlotGraph;
end;


Procedure TAABsoftGraph.UseBMSTemplate;
begin
   GraphToShow^.nYGap        := 10;
   GraphToShow^.nYValueCount := 10;
   GraphToShow^.nYOrigo      := 0;
   GraphToShow^.nGraphType   := GRAPH_BAR;
   PlotGraph;
end;


Procedure TAABsoftGraph.UseEZTemplate;
begin
   GraphToShow^.nYGap        := 1;
   GraphToShow^.nYValueCount := 7;
   GraphToShow^.nYOrigo      := 0;
   GraphToShow^.nGraphType   := GRAPH_BAR;
   PlotGraph;
end;


Procedure TAABsoftGraph.UseJDSTemplate;
begin
   GraphToShow^.nYGap        := 1;
   GraphToShow^.nYValueCount := 9;
   GraphToShow^.nYOrigo      := 0;
   GraphToShow^.nGraphType   := GRAPH_LINE;
   PlotGraph;
end;


Procedure TAABsoftGraph.UseBackgroundTemplate;
begin
   PlotGraph;
   GraphToShow^.nYOrigo      := 0;
   GraphToShow^.nGraphType   := GRAPH_STACKED_BAR_100;
   PlotGraph;
end;


procedure Register;
begin
  RegisterComponents('Samples', [TAABsoftGraph]);
end;

end.
