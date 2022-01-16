unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShlObj, IniFiles;

type
  TSettingsForm = class(TForm)
    PathsLB: TListBox;
    FoldersLbl: TLabel;
    AddPathBtn: TButton;
    RemBtn: TButton;
    HiddenPathsLB: TListBox;
    HiddenFoldersLbl: TLabel;
    AddHdnPathBtn: TButton;
    RemHdnPathBtn: TButton;
    PasswordLbl: TLabel;
    PasswordEdt: TEdit;
    OkBtn: TButton;
    CancelBtn: TButton;
    Button5: TButton;
    SwapMouseFuncCB: TCheckBox;
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure AddPathBtnClick(Sender: TObject);
    procedure RemBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure AddHdnPathBtnClick(Sender: TObject);
    procedure RemHdnPathBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SettingsForm: TSettingsForm;

implementation

uses Unit1;

{$R *.dfm}

function BrowseFolderDialog(Title: PChar): string;
var
  TitleName: string;
  lpItemid: pItemIdList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array[0..MAX_PATH] of Char;
  TempPath: array[0..MAX_PATH] of Char;
begin
  FillChar(BrowseInfo, SizeOf(TBrowseInfo), #0);
  BrowseInfo.hwndOwner:=GetDesktopWindow;
  BrowseInfo.pSzDisplayName:=@DisplayName;
  TitleName:=Title;
  BrowseInfo.lpSzTitle:=PChar(TitleName);
  BrowseInfo.ulFlags:=BIF_NEWDIALOGSTYLE;
  lpItemId:=shBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then begin
    shGetPathFromIdList(lpItemId, TempPath);
    Result:=TempPath;
    GlobalFreePtr(lpItemId);
  end;
end;

procedure TSettingsForm.Button5Click(Sender: TObject);
begin
  Application.MessageBox(PChar(IDS_TITLE + ' 0.4' + #13#10 +
  ID_LAST_UPDATE + ' 16.01.22' + #13#10 +
  'https://r57zone.github.io' + #13#10 +
  'r57zone@gmail.com'), PChar(IDS_TITLE), MB_ICONINFORMATION);
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
begin
  Caption:=IDS_SETTINGS;
  FoldersLbl.Caption:=IDS_FOLDERS;
  HiddenFoldersLbl.Caption:=IDS_HIDDEN_FOLDERS;
  AddPathBtn.Caption:=IDS_ADD;
  AddHdnPathBtn.Caption:=IDS_ADD;
  RemBtn.Caption:=IDS_REMOVE;
  RemHdnPathBtn.Caption:=IDS_REMOVE;
  PasswordLbl.Caption:=IDS_PASSWORD;
  SwapMouseFuncCB.Caption:=IDS_SWAP_MOUSE_BTNS;
  CancelBtn.Caption:=IDS_CANCEL;

  PasswordEdt.Text:=Password;
  PathsLB.Items.Text:=MenuCats.Text;
  HiddenPathsLB.Items.Text:=HiddenMenuCats.Text;
  SwapMouseFuncCB.Checked:=SwapMouseButtons;
end;

procedure TSettingsForm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TSettingsForm.AddPathBtnClick(Sender: TObject);
var
  TempPath: string;
begin
  TempPath:=BrowseFolderDialog(PChar(IDS_SELECT_FOLDER));
  if TempPath <> '' then begin
    MenuCats.Add(TempPath);
    PathsLB.Items.Text:=MenuCats.Text;
    MenuCats.SaveToFile(ExtractFilePath(ParamStr(0)) + CatsFileName);
  end;
end;

procedure TSettingsForm.RemBtnClick(Sender: TObject);
begin
  if PathsLB.ItemIndex = -1 then Exit;
  PathsLB.DeleteSelected;
  MenuCats.Text:=PathsLB.Items.Text;
  MenuCats.SaveToFile(ExtractFilePath(ParamStr(0)) + CatsFileName);
end;

procedure TSettingsForm.OkBtnClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.dat');
  Ini.WriteString('Main', 'Password', PasswordEdt.Text);
  Ini.WriteBool('Main', 'SwapMouseButtons', SwapMouseFuncCB.Checked);
  Ini.Free;
  WinExec(PChar(ParamStr(0)), SW_SHOW);
  Main.Close;
end;

procedure TSettingsForm.AddHdnPathBtnClick(Sender: TObject);
var
  TempPath: string;
begin
  TempPath:=BrowseFolderDialog(PChar(IDS_SELECT_FOLDER));
  if TempPath <> '' then begin
    HiddenMenuCats.Add(TempPath);
    HiddenPathsLB.Items.Text:=HiddenMenuCats.Text;
    HiddenMenuCats.SaveToFile(ExtractFilePath(ParamStr(0)) + HiddenCatsFileName);
  end;
end;

procedure TSettingsForm.RemHdnPathBtnClick(Sender: TObject);
begin
  if HiddenPathsLB.ItemIndex = -1 then Exit;
  HiddenPathsLB.DeleteSelected;
  HiddenMenuCats.Text:=HiddenPathsLB.Items.Text;
  HiddenMenuCats.SaveToFile(ExtractFilePath(ParamStr(0)) + HiddenCatsFileName);
end;

end.
