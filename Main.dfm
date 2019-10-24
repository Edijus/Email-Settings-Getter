object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Email settings reader [Edijs Kolesnikovi'#269's]'
  ClientHeight = 229
  ClientWidth = 657
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblHost: TLabel
    Left = 8
    Top = 8
    Width = 26
    Height = 13
    Caption = 'Host:'
  end
  object lblPort: TLabel
    Left = 8
    Top = 35
    Width = 24
    Height = 13
    Caption = 'Port:'
  end
  object lblUser: TLabel
    Left = 8
    Top = 62
    Width = 52
    Height = 13
    Caption = 'Username:'
  end
  object lblPassword: TLabel
    Left = 8
    Top = 89
    Width = 50
    Height = 13
    Caption = 'Password:'
  end
  object lblReadTimeout: TLabel
    Left = 8
    Top = 116
    Width = 68
    Height = 13
    Caption = 'Read timeout:'
  end
  object lblConnectTimeout: TLabel
    Left = 8
    Top = 143
    Width = 83
    Height = 13
    Caption = 'Connect timeout:'
  end
  object eHost: TEdit
    Left = 96
    Top = 5
    Width = 146
    Height = 21
    TabOrder = 0
    Text = 'mail.nsoft.lt'
  end
  object ePassword: TEdit
    Left = 97
    Top = 86
    Width = 145
    Height = 21
    TabOrder = 3
    Text = 'nekoduotas'
  end
  object eUser: TEdit
    Left = 97
    Top = 59
    Width = 145
    Height = 21
    TabOrder = 2
    Text = 'edijs@nsoft.lt'
  end
  object ePort: TEdit
    Left = 97
    Top = 32
    Width = 145
    Height = 21
    TabOrder = 1
    Text = '25'
  end
  object btnSearch: TBitBtn
    Left = 97
    Top = 194
    Width = 145
    Height = 25
    Caption = 'Take over the word'
    TabOrder = 4
    OnClick = btnSearchClick
  end
  object memLog: TMemo
    Left = 248
    Top = 0
    Width = 409
    Height = 229
    Align = alRight
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'memLog')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 5
    ExplicitHeight = 288
  end
  object eReadTimeout: TEdit
    Left = 97
    Top = 113
    Width = 145
    Height = 21
    TabOrder = 6
    Text = '2000'
  end
  object eConnectTimeout: TEdit
    Left = 97
    Top = 140
    Width = 145
    Height = 21
    TabOrder = 7
    Text = '3000'
  end
  object cbCheckAll: TCheckBox
    Left = 8
    Top = 171
    Width = 177
    Height = 17
    Caption = 'Check all possible combinations'
    TabOrder = 8
  end
end
