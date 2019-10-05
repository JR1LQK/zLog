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
      #31295'?p'
      0
      1
      #14655'z'#0
      0
      2
      #13631'9'#3438
      0
      3
      '7'
      0
      4
      '?'#0
      0
      5
      '?'#0
      0
      6
      '?'#0
      0
      7
      '?'#0
      0
      8
      #13375#0#0
      0
      9
      #12351'4'#0
      0
      10
      #35463'?'#0#0#18288
      0
      11
      #16191#16128#0#0
      0
      12
      #16191#16128#0#0
      0
      13
      #16191'?'#16191#0#18288#11813
      0
      14
      #35212#53404#16236'?'#18288#11813#932
      0
      15
      #16191#33125#16373#0#18288#11813
      1
      0
      #55956#16207#0#0
      2
      0
      #16191'?'#16191#0#18288#11813
      3
      0
      #22497'?'#62849#0#18288#11813)
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
