object CWKeyBoard: TCWKeyBoard
  Left = 503
  Top = 417
  Caption = 'CW Keyboard'
  ClientHeight = 105
  ClientWidth = 379
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Console: TMemo
    Left = 0
    Top = 0
    Width = 379
    Height = 71
    Align = alClient
    ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
    TabOrder = 0
    OnKeyDown = ConsoleKeyDown
    OnKeyPress = ConsoleKeyPress
  end
  object Panel1: TPanel
    Left = 0
    Top = 71
    Width = 379
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 6
      Top = 8
      Width = 65
      Height = 21
      Caption = 'OK'
      TabOrder = 0
      OnClick = OKClick
    end
    object Button2: TButton
      Left = 80
      Top = 8
      Width = 65
      Height = 21
      Caption = 'Clear'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
end
