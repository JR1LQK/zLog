object VoiceForm: TVoiceForm
  Left = 675
  Top = 184
  Width = 280
  Height = 67
  Caption = 'Voice Control'
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  object MP: TMediaPlayer
    Left = 0
    Top = 0
    Width = 141
    Height = 30
    VisibleButtons = [btPlay, btPause, btStop, btBack, btRecord]
    TabOrder = 0
  end
  object Timer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerTimer
    Left = 240
  end
end
