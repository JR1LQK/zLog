object RateDialog: TRateDialog
  Left = 69
  Top = 213
  BorderStyle = bsDialog
  Caption = 'QSO rate'
  ClientHeight = 249
  ClientWidth = 275
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Graph: TwsaGraph
    Left = 0
    Top = 41
    Width = 275
    Height = 148
    Align = alClient
    BackgroundColor = 16777215
    HeaderFontName = 'MS Sans Serif'
    HeaderFontSize = 15
    HeaderFontColor = 16711680
    FooterFontSize = 15
    FooterFontColor = 16711680
    LeftFontName = 'MS Sans Serif'
    LeftFontSize = 0
    LeftFontColor = 0
    XFontSize = 8
    YFontSize = 8
    XFontColor = 0
    YFontColor = 0
    YAxisFontName = 'MS Sans Serif'
    XAxisFontName = 'MS Sans Serif'
    ShowHorizLines = False
    ShowVertLines = False
    GraphColor = 32768
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 275
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 35
      Height = 13
      Caption = 'Last 10'
    end
    object Label2: TLabel
      Left = 8
      Top = 20
      Width = 41
      Height = 13
      Caption = 'Last 100'
    end
    object Last10: TLabel
      Left = 64
      Top = 8
      Width = 66
      Height = 13
      Caption = '0.00 QSOs/hr'
    end
    object Last100: TLabel
      Left = 64
      Top = 20
      Width = 66
      Height = 13
      Caption = '0.00 QSOs/hr'
    end
    object Max10: TLabel
      Left = 152
      Top = 8
      Width = 66
      Height = 13
      Caption = '0.00 QSOs/hr'
    end
    object Max100: TLabel
      Left = 152
      Top = 20
      Width = 66
      Height = 13
      Caption = '0.00 QSOs/hr'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 219
    Width = 275
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object OKBtn: TButton
      Left = 7
      Top = 5
      Width = 57
      Height = 20
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = OKBtnClick
    end
    object StayOnTop: TCheckBox
      Left = 80
      Top = 5
      Width = 81
      Height = 17
      Caption = 'Stay on top'
      TabOrder = 1
      OnClick = StayOnTopClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 189
    Width = 275
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Label3: TLabel
      Left = 8
      Top = 8
      Width = 46
      Height = 13
      Caption = 'Show last'
    end
    object Label4: TLabel
      Left = 112
      Top = 8
      Width = 26
      Height = 13
      Caption = 'hours'
    end
    object ShowLastCombo: TComboBox
      Left = 58
      Top = 4
      Width = 49
      Height = 21
      Ctl3D = True
      ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
      ParentCtl3D = False
      TabOrder = 0
      Text = '12'
      OnChange = ShowLastComboChange
      Items.Strings = (
        '3'
        '6'
        '12'
        '18'
        '24'
        '48')
    end
  end
  object Timer: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = TimerTimer
    Left = 216
    Top = 56
  end
end
