object ClusterTelnetSet: TClusterTelnetSet
  Left = 180
  Top = 157
  BorderStyle = bsDialog
  Caption = 'TELNET settings'
  ClientHeight = 181
  ClientWidth = 265
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 7
    Top = 7
    Width = 251
    Height = 136
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 16
    Top = 24
    Width = 51
    Height = 13
    Caption = 'Host name'
  end
  object Label2: TLabel
    Left = 16
    Top = 56
    Width = 50
    Height = 13
    Caption = 'Line break'
  end
  object Label3: TLabel
    Left = 152
    Top = 56
    Width = 29
    Height = 13
    Caption = 'Port #'
  end
  object OKBtn: TButton
    Left = 67
    Top = 152
    Width = 63
    Height = 21
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 135
    Top = 152
    Width = 63
    Height = 21
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    OnClick = CancelBtnClick
  end
  object HostName: TComboBox
    Left = 80
    Top = 20
    Width = 169
    Height = 21
    ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
    TabOrder = 2
    Text = 'Host name'
    Items.Strings = (
      'ac4et.ampr.org')
  end
  object LineBreak: TComboBox
    Left = 80
    Top = 52
    Width = 65
    Height = 21
    ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
    TabOrder = 3
    Text = 'Line break'
    Items.Strings = (
      'CR + LF'
      'CR'
      'LF')
  end
  object LocalEcho: TCheckBox
    Left = 16
    Top = 88
    Width = 97
    Height = 17
    Caption = 'Local echo'
    TabOrder = 4
  end
  object spPortNumber: TSpinEdit
    Left = 192
    Top = 52
    Width = 57
    Height = 22
    AutoSize = False
    MaxValue = 0
    MinValue = 0
    TabOrder = 5
    Value = 23
  end
end
