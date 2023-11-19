object QuickRef: TQuickRef
  Left = 506
  Top = 120
  Width = 375
  Height = 480
  Caption = 'Quick Reference'
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 367
    Height = 453
    Align = alClient
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #65325#65331' '#12468#12471#12483#12463
    Font.Style = []
    Lines.Strings = (
      'Memo')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
    OnKeyPress = MemoKeyPress
  end
end
