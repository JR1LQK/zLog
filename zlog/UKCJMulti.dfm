inherited KCJMulti: TKCJMulti
  Left = 577
  Top = 55
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Multipliers info'
  ClientHeight = 221
  ClientWidth = 296
  ExplicitWidth = 312
  ExplicitHeight = 259
  PixelsPerInch = 96
  TextHeight = 13
  object Grid: TStringAlignGrid
    Left = 0
    Top = 0
    Width = 296
    Height = 181
    TabStop = False
    Align = alClient
    BorderStyle = bsNone
    Color = clBtnFace
    ColCount = 12
    DefaultColWidth = 25
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 12
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial Narrow'
    Font.Style = []
    GridLineWidth = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 1
    Alignment = alCenter
    SelectedCellColor = clBtnFace
    SelectedFontColor = clWindowText
    ColWidths = (
      25
      25
      25
      25
      25
      25
      25
      25
      25
      25
      25
      25)
    Cells = (
      0
      0
      #14399'?'#25971
      0
      1
      #41210#0#25971
      0
      2
      '?'#0
      0
      3
      '?'#0
      0
      4
      '?'#0
      0
      5
      '?'#0
      0
      6
      #49561#0#0
      0
      7
      '?'#0
      0
      8
      ' '
      1
      0
      #14399#0#0
      1
      1
      '?'#0
      1
      2
      '?'#0
      1
      3
      #36505#0#0
      1
      4
      '?'#0
      1
      5
      '?'#0
      1
      6
      #65533#0#0
      1
      7
      '?'#0
      1
      8
      ' '
      2
      0
      #14143#0#0
      2
      1
      '?'#0
      2
      2
      #57484#0#0
      2
      3
      '?'#0
      2
      4
      '?'#0
      2
      5
      '?'#0
      2
      6
      #48793#0#0
      2
      7
      ' '
      2
      8
      ' '
      3
      0
      #12351#0#0
      3
      1
      '?'#0
      3
      2
      #49548#0#0
      3
      3
      ' '
      3
      4
      ' '
      3
      5
      ' '
      3
      6
      ' '
      3
      7
      ' '
      3
      8
      ' '
      4
      0
      #12607#0#0
      4
      1
      '?'#0
      4
      2
      #22164#0#0
      4
      3
      '?'#0
      4
      4
      '?'#0
      4
      5
      '?'#0
      4
      6
      '?'#0
      4
      7
      '?'#0
      4
      8
      #45961#0#0
      4
      9
      '?'#0
      4
      10
      '?'#0
      4
      11
      '?'#0
      5
      0
      #12863#0#0
      5
      1
      #52369#0#0
      5
      2
      '?'#0
      5
      3
      '?'#0
      5
      4
      '?'#0
      5
      5
      ' '
      5
      6
      ' '
      5
      7
      ' '
      5
      8
      ' '
      6
      0
      #13119#0#0
      6
      1
      '?'#0
      6
      2
      '?'#0
      6
      3
      '?'#0
      6
      4
      '?'#0
      6
      5
      '?'#0
      6
      6
      '?'#0
      6
      7
      ' '
      6
      8
      ' '
      7
      0
      #14655#44688#0#0
      7
      1
      #31382#0#25972
      7
      2
      '?'#0
      7
      3
      '?'#0
      8
      0
      #13375#44688#0#0
      8
      1
      #29841#0#25972
      8
      2
      '?'#0
      8
      3
      '?'#0
      8
      4
      '?'#0
      8
      5
      #65533#0#0
      9
      0
      #13631#0#0
      9
      1
      '?'#0
      9
      2
      #42635#0#0
      9
      3
      '?'#0
      9
      4
      '?'#0
      10
      0
      #13887#0#0
      10
      1
      #16786#0#0
      10
      2
      '?'#0
      10
      3
      '?'#0
      10
      4
      '?'#0
      10
      5
      '?'#0
      10
      6
      '?'#0
      10
      7
      '?'#0
      10
      8
      '?'#0
      10
      9
      #21142#0#0
      11
      0
      #50827'?'#0#0#17488
      11
      1
      '?'#0
      11
      2
      #23695#0#0
      11
      3
      '?'#0
      11
      4
      '?'#0
      11
      5
      #21914#0#0
      11
      6
      '?'#0
      11
      7
      '?'#0)
    PropCell = ()
    PropCol = ()
    PropRow = (
      0
      6
      255
      -11
      'Arial Narrow'
      0
      955490304
      0)
    PropFixedCol = ()
    PropFixedRow = (
      0
      6
      16711680
      -11
      'Arial Narrow'
      0
      955490304
      0
      1
      6
      8388608
      -11
      'Arial Narrow'
      0
      955490304
      0)
  end
  object Panel1: TPanel
    Left = 0
    Top = 181
    Width = 296
    Height = 40
    Align = alBottom
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 12
      Width = 57
      Height = 17
      Caption = 'OK'
      TabOrder = 0
      OnClick = Button1Click
    end
    object cbStayOnTop: TCheckBox
      Left = 144
      Top = 11
      Width = 81
      Height = 17
      Caption = 'Stay on top'
      TabOrder = 1
      OnClick = cbStayOnTopClick
    end
    object combBand: TComboBox
      Left = 224
      Top = 10
      Width = 73
      Height = 21
      ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
      TabOrder = 2
      Text = 'combBand'
      OnChange = combBandChange
      Items.Strings = (
        '1.9 MHz'
        '3.5 MHz'
        '7 MHz'
        '14 MHz'
        '21 MHz'
        '28 MHz'
        '50 MHz')
    end
    object Button2: TButton
      Left = 77
      Top = 12
      Width = 57
      Height = 17
      Caption = 'Multi map'
      TabOrder = 3
      OnClick = Button2Click
    end
  end
end
