object AgeDialog: TAgeDialog
  Left = 307
  Top = 232
  BorderStyle = bsDialog
  Caption = 'Age'
  ClientHeight = 84
  ClientWidth = 212
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
  object Bevel2: TBevel
    Left = 7
    Top = 7
    Width = 194
    Height = 38
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 24
    Top = 20
    Width = 105
    Height = 13
    Caption = 'Please input your age:'
  end
  object OKBtn: TButton
    Left = 75
    Top = 56
    Width = 63
    Height = 21
    Caption = 'OK'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 0
    OnClick = OKBtnClick
  end
  object Edit1: TEdit
    Left = 144
    Top = 16
    Width = 41
    Height = 20
    AutoSize = False
    CharCase = ecUpperCase
    ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
    MaxLength = 3
    TabOrder = 1
  end
end
