object frmSingleInstanceDemo: TfrmSingleInstanceDemo
  Left = 0
  Top = 0
  Caption = 'TSingleInstanceGuard Demo'
  ClientHeight = 420
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object lblMutexName: TLabel
    Left = 16
    Top = 16
    Width = 68
    Height = 15
    Caption = 'Mutex Name'
  end
  object edtMutexName: TEdit
    Left = 16
    Top = 37
    Width = 560
    Height = 23
    TabOrder = 0
    Text = 'MutexGuard.Demo.SingleInstance'
  end
  object btnApply: TButton
    Left = 592
    Top = 36
    Width = 152
    Height = 25
    Caption = 'Apply && Recheck'
    TabOrder = 1
    OnClick = btnApplyClick
  end
  object btnTest: TButton
    Left = 16
    Top = 74
    Width = 152
    Height = 25
    Caption = 'How To Test'
    TabOrder = 2
    OnClick = btnTestClick
  end
  object MemoLog: TMemo
    Left = 16
    Top = 108
    Width = 728
    Height = 296
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object SingleInstanceGuard1: TSingleInstanceGuard
    MutexName = 'MutexGuard.Demo.SingleInstance'
    OnSecondInstance = SingleInstanceGuard1SecondInstance
    Left = 320
    Top = 192
  end
end
