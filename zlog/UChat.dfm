object ChatForm: TChatForm
  Left = 199
  Top = 287
  Caption = 'Z-Server Messages'
  ClientHeight = 154
  ClientWidth = 364
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 120
    Width = 364
    Height = 34
    Align = alBottom
    TabOrder = 0
    object Edit: TEdit
      Left = 80
      Top = 7
      Width = 281
      Height = 20
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #65325#65331' '#12468#12471#12483#12463
      Font.Style = []
      ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
      ParentFont = False
      TabOrder = 0
      OnKeyPress = EditKeyPress
    end
    object Button1: TButton
      Left = 8
      Top = 7
      Width = 65
      Height = 21
      Caption = 'OK'
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object ListBox: TListBox
    Left = 0
    Top = 25
    Width = 364
    Height = 95
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #65325#65331' '#12468#12471#12483#12463
    Font.Style = []
    ImeName = 'MS-IME97 '#26085#26412#35486#20837#21147#65404#65405#65411#65425
    ItemHeight = 12
    ParentFont = False
    TabOrder = 1
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 364
    Height = 25
    Align = alTop
    TabOrder = 2
    object CheckBox: TCheckBox
      Left = 8
      Top = 4
      Width = 161
      Height = 17
      Caption = 'Pop up on new message'
      TabOrder = 0
    end
    object Button2: TButton
      Left = 294
      Top = 4
      Width = 67
      Height = 18
      Caption = 'Clear'
      TabOrder = 1
      OnClick = Button2Click
    end
    object cbStayOnTop: TCheckBox
      Left = 168
      Top = 4
      Width = 97
      Height = 17
      Caption = 'Stay on top'
      TabOrder = 2
      OnClick = cbStayOnTopClick
    end
  end
end
