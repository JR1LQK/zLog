object QTHDialog: TQTHDialog
  Left = 557
  Top = 343
  BorderStyle = bsDialog
  Caption = 'QTH information'
  ClientHeight = 216
  ClientWidth = 346
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 7
    Top = 7
    Width = 330
    Height = 170
    Shape = bsFrame
  end
  object Label14: TLabel
    Left = 98
    Top = 68
    Width = 71
    Height = 13
    Caption = 'Prov/State($V)'
  end
  object Label18: TLabel
    Left = 132
    Top = 92
    Width = 37
    Height = 13
    Caption = 'City($Q)'
  end
  object Label34: TLabel
    Left = 107
    Top = 116
    Width = 62
    Height = 13
    Caption = 'CQ Zone($Z)'
  end
  object Label35: TLabel
    Left = 100
    Top = 140
    Width = 69
    Height = 13
    Caption = 'IARU Zone($I)'
  end
  object Label1: TLabel
    Left = 32
    Top = 24
    Width = 238
    Height = 13
    Caption = 'Please check to see if these QTH data are correct'
  end
  object Label2: TLabel
    Left = 32
    Top = 24
    Width = 199
    Height = 13
    Caption = #20197#19979#12398'QTH'#12487#12540#12479#12364#27491#12375#12356#12363#12393#12358#12363#12372#30906#35469#12367#12384#12373#12356#12290
    Visible = False
  end
  object Label3: TLabel
    Left = 32
    Top = 48
    Width = 70
    Height = 13
    Caption = #37117#24220#30476#25903#24193#30058#21495
    Visible = False
  end
  object Label4: TLabel
    Left = 32
    Top = 64
    Width = 39
    Height = 13
    Caption = 'AJA'#30058#21495
    Visible = False
  end
  object OKBtn: TButton
    Left = 107
    Top = 188
    Width = 63
    Height = 21
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 175
    Top = 188
    Width = 63
    Height = 21
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object ProvEdit: TEdit
    Left = 184
    Top = 64
    Width = 25
    Height = 20
    AutoSize = False
    CharCase = ecUpperCase
    ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
    TabOrder = 2
    Text = 'PROVEDIT'
  end
  object CItyEdit: TEdit
    Left = 184
    Top = 88
    Width = 49
    Height = 20
    AutoSize = False
    CharCase = ecUpperCase
    ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
    TabOrder = 3
    Text = 'CITYEDIT'
  end
  object CQZoneEdit: TEdit
    Left = 184
    Top = 112
    Width = 25
    Height = 20
    AutoSize = False
    CharCase = ecUpperCase
    ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
    MaxLength = 3
    TabOrder = 4
    Text = '25'
  end
  object IARUZoneEdit: TEdit
    Left = 184
    Top = 136
    Width = 25
    Height = 20
    AutoSize = False
    CharCase = ecUpperCase
    ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
    MaxLength = 3
    TabOrder = 5
    Text = '45'
  end
end
