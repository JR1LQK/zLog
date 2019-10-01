object MinMaxFreqDlg: TMinMaxFreqDlg
  Left = 219
  Top = 196
  Caption = 'Enter min / max freq'
  ClientHeight = 92
  ClientWidth = 157
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 128
    Top = 16
    Width = 19
    Height = 12
    Caption = 'kHz'
  end
  object Label2: TLabel
    Left = 128
    Top = 38
    Width = 19
    Height = 12
    Caption = 'kHz'
  end
  object Label3: TLabel
    Left = 8
    Top = 16
    Width = 18
    Height = 12
    Caption = 'min'
  end
  object Label4: TLabel
    Left = 8
    Top = 38
    Width = 21
    Height = 12
    Caption = 'max'
  end
  object minEdit: TEdit
    Left = 40
    Top = 12
    Width = 81
    Height = 20
    ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
    TabOrder = 0
    Text = 'minEdit'
  end
  object maxEdit: TEdit
    Left = 40
    Top = 34
    Width = 81
    Height = 20
    ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
    TabOrder = 1
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 16
    Top = 72
    Width = 57
    Height = 20
    Caption = 'OK'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 88
    Top = 72
    Width = 57
    Height = 20
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = Button2Click
  end
end
