object Main: TMain
  Left = 192
  Top = 124
  Width = 800
  Height = 600
  Caption = #1044#1086#1084#1072#1096#1085#1103#1103' '#1073#1080#1073#1083#1080#1086#1090#1077#1082#1072
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  PixelsPerInch = 96
  TextHeight = 13
  object WebView: TWebBrowser
    Left = 0
    Top = 0
    Width = 784
    Height = 561
    Align = alClient
    TabOrder = 0
    OnBeforeNavigate2 = WebViewBeforeNavigate2
    OnDocumentComplete = WebViewDocumentComplete
    ControlData = {
      4C00000007510000FB3900000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E12620A000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end
