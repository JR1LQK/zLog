inherited GeneralScore: TGeneralScore
  Left = 133
  Top = 136
  Caption = 'Score'
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Grid: TStringAlignGrid [0]
    Left = 0
    Top = 8
    Width = 249
    Height = 256
    TabStop = False
    BorderStyle = bsNone
    Color = clBtnFace
    ColCount = 4
    DefaultRowHeight = 16
    FixedCols = 0
    RowCount = 16
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    GridLineWidth = 0
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
    Alignment = alRight
    SelectedCellColor = clBtnFace
    SelectedFontColor = clBtnText
    ColWidths = (
      49
      64
      64
      64)
    Cells = (
      0
      0
      #18509'z'#3438
      0
      1
      #11825'9z'
      0
      2
      #11827'59'
      0
      3
      '7'
      0
      4
      #13361#0
      0
      5
      #12594#0
      0
      6
      #14386#0
      0
      7
      #12341#0
      0
      8
      #13361'4'#0
      0
      9
      #13108'04'
      0
      10
      #12849#12336#0#0
      0
      11
      #13362#12336#0#27749
      0
      12
      #13877#12336#0#30051
      0
      13
      #12337#18503#11130#0#16272#10111
      0
      14
      #28500#24948'l'#29480#16272
      0
      15
      #25427#29295'e'#8224#16272
      1
      0
      #21329'O'#2573
      2
      0
      #28496#28265#29556#0#16272#10111
      3
      0
      #30029#29804#0#8224)
    PropCell = ()
    PropCol = ()
    PropRow = ()
    PropFixedCol = ()
    PropFixedRow = ()
  end
  inherited Panel1: TPanel
    TabOrder = 1
    inherited StayOnTop: TCheckBox
      Caption = 'Stay on Top'
    end
  end
end
