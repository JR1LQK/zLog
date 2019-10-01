object BasicScore: TBasicScore
  Left = 271
  Top = 308
  Caption = 'BasicScore'
  ClientHeight = 230
  ClientWidth = 278
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Scaled = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 197
    Width = 278
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object CWButton: TSpeedButton
      Left = 240
      Top = 4
      Width = 33
      Height = 25
      AllowAllUp = True
      GroupIndex = 33
      Caption = 'CW'
      Visible = False
      OnClick = CWButtonClick
    end
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 57
      Height = 20
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = Button1Click
    end
    object StayOnTop: TCheckBox
      Left = 72
      Top = 8
      Width = 81
      Height = 17
      Caption = 'Stay on top'
      TabOrder = 1
      OnClick = StayOnTopClick
    end
  end
end
