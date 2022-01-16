object SettingsForm: TSettingsForm
  Left = 192
  Top = 125
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 360
  ClientWidth = 460
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object FoldersLbl: TLabel
    Left = 8
    Top = 8
    Width = 35
    Height = 13
    Caption = #1055#1072#1087#1082#1080':'
  end
  object HiddenFoldersLbl: TLabel
    Left = 8
    Top = 144
    Width = 80
    Height = 13
    Caption = #1057#1082#1088#1099#1090#1080#1077' '#1087#1072#1087#1082#1080':'
  end
  object PasswordLbl: TLabel
    Left = 8
    Top = 280
    Width = 41
    Height = 13
    Caption = #1055#1072#1088#1086#1083#1100':'
  end
  object PathsLB: TListBox
    Left = 8
    Top = 24
    Width = 361
    Height = 113
    ItemHeight = 13
    TabOrder = 0
  end
  object AddPathBtn: TButton
    Left = 376
    Top = 24
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 1
    OnClick = AddPathBtnClick
  end
  object RemBtn: TButton
    Left = 376
    Top = 56
    Width = 75
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 2
    OnClick = RemBtnClick
  end
  object HiddenPathsLB: TListBox
    Left = 8
    Top = 160
    Width = 361
    Height = 113
    ItemHeight = 13
    TabOrder = 3
  end
  object AddHdnPathBtn: TButton
    Left = 376
    Top = 160
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 4
    OnClick = AddHdnPathBtnClick
  end
  object RemHdnPathBtn: TButton
    Left = 376
    Top = 192
    Width = 75
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 5
    OnClick = RemHdnPathBtnClick
  end
  object PasswordEdt: TEdit
    Left = 8
    Top = 296
    Width = 161
    Height = 21
    PasswordChar = '*'
    TabOrder = 6
  end
  object OkBtn: TButton
    Left = 8
    Top = 328
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 7
    OnClick = OkBtnClick
  end
  object CancelBtn: TButton
    Left = 88
    Top = 328
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 8
    OnClick = CancelBtnClick
  end
  object Button5: TButton
    Left = 428
    Top = 328
    Width = 25
    Height = 25
    Caption = '?'
    TabOrder = 9
    OnClick = Button5Click
  end
  object SwapMouseFuncCB: TCheckBox
    Left = 184
    Top = 298
    Width = 225
    Height = 17
    Caption = #1055#1086#1084#1077#1085#1103#1090#1100' '#1084#1077#1089#1090#1072#1084#1080' '#1092#1091#1085#1082#1094#1080#1080' '#1084#1099#1096#1080
    TabOrder = 10
  end
end
