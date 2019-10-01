inherited ALLJAEditDialog: TALLJAEditDialog
  Left = 258
  Top = 324
  Caption = 'Edit QSO'
  ClientHeight = 77
  ClientWidth = 555
  ExplicitWidth = 561
  ExplicitHeight = 126
  PixelsPerInch = 96
  TextHeight = 13
  inherited OKBtn: TButton
    Top = 47
    ExplicitTop = 47
  end
  inherited CancelBtn: TButton
    Top = 47
    ExplicitTop = 47
  end
  inherited Panel1: TPanel
    Width = 555
    ExplicitWidth = 555
    inherited CallsignEdit: TEdit
      Left = 53
      ExplicitLeft = 53
    end
    inherited RcvdRSTEdit: TEdit
      Left = 205
      ExplicitLeft = 205
    end
    inherited NumberEdit: TEdit
      Left = 117
      ExplicitLeft = 117
    end
    inherited BandEdit: TEdit
      Left = 328
      ExplicitLeft = 328
    end
    inherited MemoEdit: TEdit
      Left = 360
      ExplicitLeft = 360
    end
    inherited PointEdit: TEdit
      Left = 216
      ExplicitLeft = 216
    end
    inherited PowerEdit: TEdit
      Left = 389
      Visible = False
      ExplicitLeft = 389
    end
  end
  inherited OpMenu: TPopupMenu
    AutoHotkeys = maManual
  end
end
