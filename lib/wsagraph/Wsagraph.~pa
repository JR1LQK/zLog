(****************************************************)
(* By : P. Gertzen                                  *)
(* ---------------                                  *)
(* If you'd like any modifications to this          *)
(* simple little component or any help with MS ISS  *)
(* Backend Dll's or Internet Client/Server Apps then*)
(* contact me at pgertzen@websa.com.                *)
(*                                                  *)
(* Check out our Delphi coded Internet server       *)
(* technology at:                                   *)
(* LiveAudit.com, FindProduct.com, Livesite.co.za   *)
(*                                                  *)
(* Check this component at work at LiveAudit.com    *)
(****************************************************)

unit wsaGraph;

interface

Uses Classes,ExtCtrls, StdCtrls,SysUtils, Graphics;

Type
  TDataObject = Class(TObject)
  Private
    FValue : Real;
    FLabel : String;
  Public
    Constructor Create(Value : Real; PosLabel : String);
  End;

  TGauge = Class(TImage)
  Private
    FPercentage : Real;
    FGaugeColor : Integer;
    FBarColor : Integer;
  Public
    Procedure SetGauge(Percentage : Real);
  Published
    Property BarColor : Integer Read FBarColor Write FBarColor;
    Property GaugeColor : Integer Read FGaugecolor Write FGaugeColor;
  End;

  TwsaGraph = Class(TImage)
  Private
    FHeader : String;
    FHeaderFontName : String;
    FYAxisFontName : String;
    FXAxisFontName : String;
    FFooter : String;
    FYHeader: String;
    FXHeader: String;
    FShowHorizLines : Boolean;
    FShowVertLines : Boolean;
    FDataList : TStringList;
    FDataObject : TDataObject;
    FHeaderFontSize : Integer;
    FXFontSize : Integer;
    FXFontColor : Integer;
    FYFontSize : Integer;
    FYFontColor : Integer;
    FHeaderFontColor : Integer;
    FLeftMargin,
    FRightMargin,
    FTopMargin,
    FBottomMargin : Integer;
    FFooterFontName : String;
    FFooterFontSize : Integer;
    FFooterFontColor : Integer;
    FLeftFontName : String;
    FLeftFontSize : Integer;
    FLeftFontColor : Integer;
    FLeftLabel : String;
    FIncValue : Real;
    FXFontName : String;
    FTicks : Integer;
    FMaxValue : Real;
    FGraphColor : Integer;
    FBackgroundColor : Integer;
    Procedure CalcPeriods;
  Public
    Constructor Create(AOwner : TComponent); override;
    Destructor Destroy; override;
    Procedure AddData(X : Integer;Value : Real; PosLabel : String);
    Procedure PlotGraph;
    Procedure ClearGraph;
  Published
    Property BackgroundColor : Integer Read FBackgroundColor Write FBackgroundColor;
    Property HeaderFontName : String Read FHeaderFontName Write FHeaderFontName;
    Property HeaderFontSize : Integer Read FHeaderFontSize Write FHeaderFontSize;
    Property HeaderFontColor : Integer Read FHeaderFontColor Write FHeaderFontColor;
    Property FooterFontName : String Read FFooterFontName Write FFooterFontName;
    Property FooterFontSize : Integer Read FFooterFontSize Write FFooterFontSize;
    Property FooterFontColor : Integer Read FFooterFontColor Write FFooterFontColor;
    Property LeftFontName : String Read FLeftFontName Write FLeftFontName;
    Property LeftFontSize : Integer Read FLeftFontSize Write FLeftFontSize;
    Property LeftFontColor : Integer Read FLeftFontColor Write FLeftFontColor;
    Property XFontName : String Read FXFontName write FXFontName;
    Property XFontSize : Integer Read FXFontSize Write FXFontSize;
    Property YFontSize : Integer Read FYFontSize Write FYFontSize;
    Property XFontColor : Integer Read FXFontColor Write FXFontColor;
    Property YFontColor : Integer Read FYFontColor Write FYFontColor;
    Property YAxisFontName : String Read FYAxisFontName Write FYAxisFontName;
    Property XAxisFontName : String Read FXAxisFontName Write FXAxisFontName;
    Property Header : String Read FHeader Write FHeader;
    Property LeftLabel : String Read FLeftLabel Write FLeftLabel;
    Property Footer : String Read FFooter Write FFooter;
    Property YHeader: String Read FYHeader Write FYHeader;
    Property XHeader: String Read FXHeader Write FXHeader;
    Property ShowHorizLines : Boolean Read FShowHorizLines Write FShowHorizLines;
    Property ShowVertLines : Boolean Read FShowVertLines Write FShowVertLines;
    Property GraphColor : Integer Read FGraphcolor Write FGraphColor;
  End;

Procedure Register;

implementation

Uses Math;

Procedure TGauge.SetGauge(Percentage : Real);
Var XPos,YPos : Integer;
Begin
  Canvas.Brush.Color := GaugeColor;

  //Canvas.Rectangle(0,0,Width,Height);
  Canvas.FillRect(Rect(0,0,Width,Height));

  Canvas.Brush.Color := BarColor;
  Canvas.Rectangle(0,0,Round((Percentage/100)*Width),Height);
  Canvas.Brush.Color := clBlack;
  Canvas.Font.Color := clWhite;
  Canvas.Font.Size := Height Div 2;
  XPos := (Width Div 2) -
          (Canvas.TextWidth(FloatToStr(Percentage)+ '%') Div 2);
  YPos := (Height Div 2) -
          (Canvas.TextHeight(FloatToStr(Percentage)+ '%') Div 2);
  Canvas.TextOut(XPos,YPos,FloatToStr(Percentage)+ '%');
End;

Constructor TDataObject.Create(Value : Real; PosLabel : String);
Begin
  FValue := Value;
  FLabel := PosLabel;
End;

Procedure TwsaGraph.AddData(X : Integer; Value : Real; PosLabel : String);
Var Idx : Integer;
Begin
  Idx := FDataList.IndexOf(FloatToStr(X));
  If Idx <> - 1 Then
  Begin
    TDataObject(FDataList.Objects[Idx]).FValue := Value;
    TDataObject(FDataList.Objects[Idx]).FLabel := PosLabel;
  End
  Else
   FDataList.AddObject(FloatToStr(X),TDataObject.Create(Value,PosLabel));
  If Value > FMaxValue Then
   FMaxValue := Value;
End;

Procedure TwsaGraph.CalcPeriods;
Var PowerVal : Integer;
Begin
   If FMaxValue > 0 Then
    PowerVal := Round(Power(10,Floor(Log10(FMaxValue))-1))
   Else
    PowerVal := 0;
   If (PowerVal = 0) Then
    Begin
      FIncValue := 1;
      FTicks := 10;
    End
   Else
   If (FMaxValue <= 15 * PowerVal) Then
       Begin
         FIncValue := 1 * Power(10,Floor(Log10(FMaxValue))-1);
         FTicks := 15;
       End
    Else
   If (FMaxValue <= 20 * PowerVal) Then
       Begin
         FIncValue := 2 * Power(10,Floor(Log10(FMaxValue))-1);
         FTicks := 10;
       End
    Else
   If (FMaxValue <= 30 * PowerVal) Then
       Begin
         FIncValue := 3 * Power(10,Floor(Log10(FMaxValue))-1);
         FTicks := 10;
       End
    Else
   If (FMaxValue <= 40 * PowerVal) Then
       Begin
         FIncValue := 5 * Power(10,Floor(Log10(FMaxValue))-1);
         FTicks := 8;
       End
    Else
   If (FMaxValue <= 50 * PowerVal) Then
       Begin
         FIncValue := 5 * Power(10,Floor(Log10(FMaxValue))-1);
         FTicks := 10;
       End
    Else
   If (FMaxValue <= 60 * PowerVal) Then
       Begin
         FIncValue := 5 * Power(10,Floor(Log10(FMaxValue))-1);
         FTicks := 12;
       End
    Else
   If (FMaxValue <= 75 * PowerVal) Then
       Begin
         FIncValue := 5 * Power(10,Floor(Log10(FMaxValue))-1);
         FTicks := 15;
       End
    Else
   If (FMaxValue <= 80 * PowerVal) Then
       Begin
         FIncValue := 5 * Power(10,Floor(Log10(FMaxValue))-1);
         FTicks := 16;
       End
    Else
   If (FMaxValue <= 100 * PowerVal) Then
       Begin
         FIncValue := 10 * Power(10,Floor(Log10(FMaxValue))-1);
         FTicks := 10;
       End;

End;

Constructor TwsaGraph.Create(AOwner : TComponent);
Begin
  Inherited Create(AOwner);
  HeaderFontName := 'MS Sans Serif';
  YAxisFontName := 'MS Sans Serif';
  XAxisFontName := 'MS Sans Serif';
  LeftFontName := 'MS Sans Serif';
  HeaderFontSize := 15;
  FooterFontSize := 15;
  LeftLabel := '';
  Header := '';
  Footer := '';
  YHeader := '';
  XHeader := '';
  FLeftMargin := 10;
  FRightMargin := 10;
  FTopMargin := 10;
  FBottomMargin := 20;
  FMaxValue := 0;
  ShowVertLines := False;
  FDataList := TStringList.Create;
  BackgroundColor := clWhite;
  Width := 150;
  Height := 100;
  FooterFontColor := clBlue;
  HeaderFontColor := clBlue;
  ShowHorizLines := True;
  XFontSize := 7;
  GraphColor := clGreen;
End;

Destructor TwsaGraph.Destroy;
Var i : Integer;
Begin
  Inherited Destroy;
  For i := 0 To FDataList.Count - 1 Do
   TDataObject(FDataList.Objects[i]).Destroy;
  FDataList.Destroy;
End;

Procedure TwsaGraph.ClearGraph;
Var i : Integer;
Begin
  For i := 0 To FDataList.Count - 1 Do
   TDataObject(FDataList.Objects[i]).Destroy;
  FDataList.Clear;
  FLeftMargin := 10;
  FRightMargin := 10;
  FTopMargin := 10;
  FBottomMargin := 20;
  FMaxValue := 0;
End;

Procedure TwsaGraph.PlotGraph;
Var BarWidth,
    BarHeight : Integer;
    i : Integer;
    TickWidth : Real;
    CurrPos : Integer;
    GraphBottomPos, GraphLeftPos : Integer;
    DataValue : Real;
    DataLabel : String;
    GraphHeight : Integer;
    GraphWidth : Integer;
    HighGraphVal : Integer;
Begin
  Canvas.Brush.Color := BackgroundColor;
  //Canvas.Rectangle(0,0,Width,Height);
  Canvas.FillRect(Rect(0,0,Width,Height));
  //Header
  Canvas.Font.Name := HeaderfontName;
  Canvas.Font.Size := HeaderFontSize;
  Canvas.Font.Color := HeaderFontColor;
  If Header <> '' Then
   FTopMargin := FTopMargin + Canvas.TextHeight(Header) + 10;
  Canvas.TextOut((Width Div 2) - (Canvas.TextWidth(Header) div 2),10,Header);
  //Footer
  Canvas.Font.Name := FooterFontName;
  Canvas.Font.Size := FooterFontSize;
  Canvas.Font.Color := FooterFontColor;
  If Footer <> '' Then
   FBottomMargin := FBottomMargin + Canvas.TextHeight(Footer);
  Canvas.TextOut((Width Div 2) - (Canvas.TextWidth(Footer) div 2),Height-Canvas.TextHeight(Footer),Footer);
  //Left Label
  Canvas.Font.Name := LeftFontName;
  Canvas.Font.Size := LeftFontSize;
  Canvas.Font.Color := LeftFontColor;
  If LeftLabel <> '' Then
   FLeftMargin := FLeftMargin + Canvas.TextWidth(LeftLabel) + FLeftMargin;
  Canvas.TextOut(10,Height Div 2,LeftLabel);
  CalcPeriods;
  HighGraphVal := Round(FTicks * FIncValue);
  TickWidth := (Height-FTopMargin - FBottomMargin) / FTicks;
  Canvas.Font.Color := YFontColor;
  Canvas.Font.Size := YFontSize;
  Canvas.Font.Name := YAxisFontName;
  FLeftMargin := FLeftMargin + Canvas.TextWidth(FloatToStr(FMaxValue));
  Canvas.Pen.Color := clBlack;

 // Canvas.Pen.Width := 1;

  Canvas.MoveTo(FLeftMargin,Height-FBottomMargin);
  Canvas.LineTo(FLeftMargin,FTopMargin);
  Canvas.MoveTo(FLeftMargin,Height-FBottomMargin);
  Canvas.LineTo(Width-FRightMargin,Height-FBottomMargin);
  GraphBottomPos := Height-FBottomMargin;
  GraphLeftPos := FLeftMargin;
  CurrPos:= GraphBottomPos;
  BarWidth := (Width-FRightMargin-FLeftMargin) Div FDataList.Count;
  For i := 1 To FTicks Do
   Begin
     Currpos := Round(GraphBottomPos - (TickWidth * i));
     Canvas.Font.Color := YFontColor;
     Canvas.Font.Size := YFontSize;
     Canvas.TextOut(GraphLeftPos - Canvas.TextWidth(IntToStr(i*Round(FIncValue))) - 2,
                    CurrPos-(Canvas.TextHeight(IntToStr(i*Round(FIncValue))) Div 2),
                    IntToStr(i*Round(FIncValue)));
     Canvas.MoveTo(FLeftMargin-2,CurrPos);
     Canvas.LineTo(FLeftMargin+2,CurrPos);
     If ShowHorizLines Then
      Begin
        Canvas.Pen.Style := psDot;
        Canvas.Pen.Color := clGray;
        Canvas.LineTo(Width-FRightMargin,CurrPos);
        Canvas.Pen.Color := clBlack;
        Canvas.Pen.Style := psSolid;
      End;
   End;
  Canvas.TextOut(GraphLeftPos-Canvas.TextWidth('0')-2,
                 GraphBottomPos-(Canvas.TextHeight('0') DIV 2),'0');
  CurrPos := GraphLeftPos;
  GraphHeight := Height-FBottomMargin-FTopMargin;
  GraphWidth := Width - FRightMargin - FLeftMargin;
  For i := 0 To FDataList.Count - 1 Do
   Begin
     DataValue := TDataObject(FDataList.Objects[i]).FValue;
     DataLabel := TDataObject(FDataList.Objects[i]).FLabel;
     BarHeight := Floor((DataValue / HighGraphVal) * GraphHeight);
     Canvas.Brush.Color := GraphColor;
{    Canvas.Rectangle(CurrPos,GraphBottomPos - BarHeight,
                      CurrPos + BarWidth,GraphBottomPos);}
     Canvas.FillRect(Rect(CurrPos+1,GraphBottomPos - BarHeight+1,
                      CurrPos + BarWidth -1,GraphBottomPos));
     Canvas.Brush.Color := BackGroundColor;
     Canvas.Font.Color := XFontColor;
     Canvas.Font.Name := XFontName;
     Canvas.Font.Size := XFontSize;
     Canvas.TextOut((BarWidth Div 2)-(Canvas.TextWidth(DataLabel) Div 2)+CurrPos,
                    GraphBottomPos + 1,DataLabel);
     CurrPos := CurrPos + BarWidth;
   End;
End;

procedure Register;
begin
  RegisterComponents('Samples', [TwsaGraph]);
end;
end.
