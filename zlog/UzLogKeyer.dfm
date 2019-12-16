object dmZLogKeyer: TdmZLogKeyer
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 150
  Width = 215
  object HidController: TJvHidDeviceController
    OnEnumerate = DoEnumeration
    OnDeviceChange = DoDeviceChanges
    Left = 104
    Top = 64
  end
end
