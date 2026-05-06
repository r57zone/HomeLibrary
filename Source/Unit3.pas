unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShlObj, IniFiles, Menus, PNGImage, Jpeg;

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
    PopupMenuFolder: TPopupMenu;
    MoveFolderUpBtn: TMenuItem;
    MoveFolderDownBtn: TMenuItem;
    PopupMenuFolder2: TPopupMenu;
    MoveFolderUpBtn2: TMenuItem;
    MoveFolderDownBtn2: TMenuItem;
    AdditionalBtnsCB: TCheckBox;
    CoversBtn: TButton;
    Covers2Btn: TButton;
    UseCoverTemplatesCB: TCheckBox;
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure AddPathBtnClick(Sender: TObject);
    procedure RemBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure AddHdnPathBtnClick(Sender: TObject);
    procedure RemHdnPathBtnClick(Sender: TObject);
    procedure MoveFolderUpBtnClick(Sender: TObject);
    procedure MoveFolderDownBtnClick(Sender: TObject);
    procedure MoveFolderUpBtn2Click(Sender: TObject);
    procedure MoveFolderDownBtn2Click(Sender: TObject);
    procedure CoversBtnClick(Sender: TObject);
    procedure Covers2BtnClick(Sender: TObject);
    procedure UseCoverTemplatesCBClick(Sender: TObject);
  private
    procedure AskCreateCovers;
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TCoverType = (ctCD, ctDVD, ctDefault);

var
  SettingsForm: TSettingsForm;
  CDTemplateBmp: TBitmap;
  SelectedFolderPath: string;

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
  Application.MessageBox(PChar(IDS_TITLE + ' 0.6' + #13#10 +
  ID_LAST_UPDATE + ' 06.05.26' + #13#10 +
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
  AdditionalBtnsCB.Caption:=IDS_ADV_BTNS;
  SwapMouseFuncCB.Caption:=IDS_SWAP_MOUSE_BTNS;
  CancelBtn.Caption:=IDS_CANCEL;
  MoveFolderUpBtn.Caption:=IDS_MOVE_UP;
  MoveFolderDownBtn.Caption:=IDS_MOVE_DOWN;
  MoveFolderUpBtn2.Caption:=IDS_MOVE_UP;
  MoveFolderDownBtn2.Caption:=IDS_MOVE_DOWN;
  PasswordEdt.Text:=Password;
  PathsLB.Items.Text:=MenuCats.Text;
  HiddenPathsLB.Items.Text:=HiddenMenuCats.Text;
  AdditionalBtnsCB.Checked:=ShowAdditionalButtons;
  SwapMouseFuncCB.Checked:=SwapMouseButtons;
  CoversBtn.Caption:=IDS_COVERS;
  Covers2Btn.Caption:=IDS_COVERS;
  UseCoverTemplatesCB.Checked:=UseCoverTemplates;
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
  if TempPath <> '' then
    PathsLB.Items.Add(TempPath);
end;

procedure TSettingsForm.RemBtnClick(Sender: TObject);
begin
  if PathsLB.ItemIndex = -1 then Exit;
  PathsLB.DeleteSelected;
end;

procedure TSettingsForm.OkBtnClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.dat');
  Ini.WriteString('Main', 'CatFolders', Trim(StringReplace(PathsLB.Items.Text, #13#10, ';', [rfReplaceAll])));
  Ini.WriteString('Main', 'CatHiddenFolders', Trim(StringReplace(HiddenPathsLB.Items.Text, #13#10, ';', [rfReplaceAll])));
  Ini.WriteString('Main', 'Password', PasswordEdt.Text);
  Ini.WriteBool('Main', 'AdditionalButtons', AdditionalBtnsCB.Checked);
  Ini.WriteBool('Main', 'SwapMouseButtons', SwapMouseFuncCB.Checked);
  Ini.WriteBool('Main', 'UseCoverTemplates', UseCoverTemplates);
  Ini.Free;
  WinExec(PChar(ParamStr(0)), SW_SHOW);
  Main.Close;
end;

procedure TSettingsForm.AddHdnPathBtnClick(Sender: TObject);
var
  TempPath: string;
begin
  TempPath:=BrowseFolderDialog(PChar(IDS_SELECT_FOLDER));
  if TempPath <> '' then
    HiddenPathsLB.Items.Add(TempPath);
end;

procedure TSettingsForm.RemHdnPathBtnClick(Sender: TObject);
begin
  if HiddenPathsLB.ItemIndex = -1 then Exit;
  HiddenPathsLB.DeleteSelected;
end;

procedure TSettingsForm.MoveFolderUpBtnClick(Sender: TObject);
var
  TempFolderPath: string;
begin
  if (PathsLB.ItemIndex = -1) or (PathsLB.ItemIndex = 0) then Exit;
  TempFolderPath:=PathsLB.Items.Strings[PathsLB.ItemIndex];
  PathsLB.Items.Strings[PathsLB.ItemIndex]:=PathsLB.Items.Strings[PathsLB.ItemIndex - 1];
  PathsLB.Items.Strings[PathsLB.ItemIndex - 1]:=TempFolderPath;
  PathsLB.ItemIndex:=PathsLB.ItemIndex - 1;
end;

procedure TSettingsForm.MoveFolderDownBtnClick(Sender: TObject);
var
  TempFolderPath: string;
begin
  if (PathsLB.ItemIndex = -1) or (PathsLB.ItemIndex = PathsLB.Count - 1) then Exit;
  TempFolderPath:=PathsLB.Items.Strings[PathsLB.ItemIndex];
  PathsLB.Items.Strings[PathsLB.ItemIndex]:=PathsLB.Items.Strings[PathsLB.ItemIndex + 1];
  PathsLB.Items.Strings[PathsLB.ItemIndex + 1]:=TempFolderPath;
  PathsLB.ItemIndex:=PathsLB.ItemIndex + 1;
end;

procedure TSettingsForm.MoveFolderUpBtn2Click(Sender: TObject);
var
  TempFolderPath: string;
begin
  if (HiddenPathsLB.ItemIndex = -1) or (HiddenPathsLB.ItemIndex = 0) then Exit;
  TempFolderPath:=HiddenPathsLB.Items.Strings[HiddenPathsLB.ItemIndex];
  HiddenPathsLB.Items.Strings[HiddenPathsLB.ItemIndex]:=HiddenPathsLB.Items.Strings[HiddenPathsLB.ItemIndex - 1];
  HiddenPathsLB.Items.Strings[HiddenPathsLB.ItemIndex - 1]:=TempFolderPath;
  HiddenPathsLB.ItemIndex:=HiddenPathsLB.ItemIndex - 1;
end;

procedure TSettingsForm.MoveFolderDownBtn2Click(Sender: TObject);
var
  TempFolderPath: string;
begin
  if (HiddenPathsLB.ItemIndex = -1) or (HiddenPathsLB.ItemIndex = HiddenPathsLB.Count - 1) then Exit;
  TempFolderPath:=HiddenPathsLB.Items.Strings[HiddenPathsLB.ItemIndex];
  HiddenPathsLB.Items.Strings[HiddenPathsLB.ItemIndex]:=HiddenPathsLB.Items.Strings[HiddenPathsLB.ItemIndex + 1];
  HiddenPathsLB.Items.Strings[HiddenPathsLB.ItemIndex + 1]:=TempFolderPath;
  HiddenPathsLB.ItemIndex:=HiddenPathsLB.ItemIndex + 1;
end;

procedure LoadBitmapFromFile(const FileName: string; Bmp: TBitmap);
var
  Ext: string;
  Jpg: TJPEGImage;
  PNG: TPNGObject;
begin
  Ext:=LowerCase(ExtractFileExt(FileName));
  if (Ext = '.jpg') or (Ext = '.jpeg') then begin
    Jpg:=TJPEGImage.Create;
    Jpg.Performance:=jpBestQuality;
    try
      Jpg.LoadFromFile(FileName);
      Bmp.Assign(Jpg);
    finally
      Jpg.Free;
    end;
  end else if Ext = '.png' then begin
    PNG:=TPNGObject.Create;
    try
      PNG.LoadFromFile(FileName);
      Bmp.Assign(PNG);
    finally
      PNG.Free;
    end;
  end else
    raise Exception.Create('Unsupported format: ' + FileName);
end;

function DetectCoverType(ImageWidth, H: Integer): TCoverType;
var
  Ratio: Double;
begin
  Ratio:=ImageWidth / H;
  if (Ratio >= 0.9) and (Ratio <= 1.1) then
    Result:=ctCD
  //else if (Ratio >= 1.2) and (Ratio <= 1.5) then
    //Result := ctDVD
  else
    Result:=ctDefault;
end;

procedure FitRect(SrcW, SrcH, MaxW, MaxH: Integer; var DstW, DstH: Integer);
var
  Ratio: Double;
begin
  Ratio:=SrcW / SrcH;
  if (MaxW / MaxH) > Ratio then begin
    DstH:=MaxH;
    DstW:=Round(MaxH * Ratio);
  end else begin
    DstW:=MaxW;
    DstH:=Round(MaxW / Ratio);
  end;
end;

procedure DrawCD(Dst, Src: TBitmap);
var
  ImageWidth, ImageHeight: Integer;
begin
  FitRect(Src.Width, Src.Height, 100, 100, ImageWidth, ImageHeight); // Вписываем в 100x100

  SetStretchBltMode(Dst.Canvas.Handle, HALFTONE);

  StretchBlt(
    Dst.Canvas.Handle,
    11,   // X
    0,    // Y
    ImageWidth,
    ImageHeight,
    Src.Canvas.Handle,
    0,
    0,
    Src.Width,
    Src.Height,
    SRCCOPY
  );
end;

procedure ScaleDVD(const SrcW, SrcH: Integer; var DstW, DstH: Integer);
var
  Ratio: Double;
begin
  DstW:=100;

  Ratio:=SrcH / SrcW;
  DstH:=Round(DstW * Ratio);

  // ограничение по высоте
  if DstH > 200 then begin
    DstH:=200;
    DstW:=Round(DstH / Ratio);
  end;
end;

procedure DrawDVD(Dst, Src: TBitmap);
var
  ImageWidth, ImageHeight: Integer;
begin
  ScaleDVD(Src.Width, Src.Height, ImageWidth, ImageHeight);

  Dst.PixelFormat:=pf24bit;
  Dst.Width:=ImageWidth;
  Dst.Height:=ImageHeight;

  Dst.Canvas.Brush.Color:=clWhite;
  Dst.Canvas.FillRect(Rect(0, 0, ImageWidth, ImageHeight));

  SetStretchBltMode(Dst.Canvas.Handle, HALFTONE);

  StretchBlt(
    Dst.Canvas.Handle,
    0, 0, ImageWidth, ImageHeight,
    Src.Canvas.Handle,
    0, 0, Src.Width, Src.Height,
    SRCCOPY
  );
end;

procedure GenerateCover(const SrcFile, OutFile: string);
var
  SrcBmp: TBitmap;
  DstBmp: TBitmap;
  CoverType: TCoverType;
  Jpg: TJPEGImage;
begin
  SrcBmp:=TBitmap.Create;
  DstBmp:=TBitmap.Create;
  try
    // 1. загрузка исходника
    LoadBitmapFromFile(SrcFile, SrcBmp);

    // 2. тип
    CoverType:=DetectCoverType(SrcBmp.Width, SrcBmp.Height);

    // 3. шаблон только для CD
    if (CoverType = ctCD) and (UseCoverTemplates) then begin
      DstBmp.Assign(CDTemplateBmp);
      DrawCD(DstBmp, SrcBmp);
    end else begin //if CoverType = ctDVD then

      DstBmp.PixelFormat:=pf24bit;
      DrawDVD(DstBmp, SrcBmp);
    end;

    // 4. сохранение JPG
    Jpg:=TJPEGImage.Create;
    try
      Jpg.Assign(DstBmp);
      Jpg.CompressionQuality:=100;
      Jpg.SaveToFile(OutFile);
    finally
      Jpg.Free;
    end;

  finally
    SrcBmp.Free;
    DstBmp.Free;
  end;
end;

procedure ProcessFolder(const RootFolder: string; SkipExists: boolean);
var
  SR, SR2: TSearchRec;
  SubPath: string;
  CoverFile: string;
  Ext: string;
begin
  if FindFirst(RootFolder + '\*', faAnyFile, SR) = 0 then
  try
    repeat
      if (SR.Name <> '.') and (SR.Name <> '..') and ((SR.Attr and faDirectory) <> 0) then begin
        SubPath:=RootFolder + '\' + SR.Name;

        CoverFile := '';

        if SkipExists then begin
          if FileExists(SubPath + '\CoverSmall.jpg') then Continue;
          if FileExists(SubPath + '\CoverSmall.jpeg') then Continue;
          if FileExists(SubPath + '\CoverSmall.png') then Continue;
        end;

        if FileExists(SubPath + '\Cover.jpg') then
          CoverFile:=SubPath + '\Cover.jpg'
        else if FileExists(SubPath + '\Cover.jpeg') then
          CoverFile:=SubPath + '\Cover.jpeg'
        else if FileExists(SubPath + '\Cover.png') then
          CoverFile:=SubPath + '\Cover.png';

        if CoverFile = '' then
          if FindFirst(SubPath + '\*', faAnyFile, SR2) = 0 then
            try
              repeat
                if (SR2.Name <> '.') and (SR2.Name <> '..') and ((SR2.Attr and faDirectory) = 0) then begin
                  Ext:=LowerCase(ExtractFileExt(SR2.Name));
                  if (Ext = '.jpg') or (Ext = '.png') or (Ext = '.jpeg') then begin
                    CoverFile:=SubPath + '\' + SR2.Name;
                    break;
                  end;
                end;
              until FindNext(SR2) <> 0;
            finally
              FindClose(SR2);
            end;

        if CoverFile <> '' then
          GenerateCover(CoverFile, SubPath + '\CoverSmall.jpg');
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

procedure TSettingsForm.AskCreateCovers;
begin
  with CreateMessageDialog(IDS_CREATE_COVERS + #13#10 + '"' + SelectedFolderPath + '"', mtConfirmation, [mbYes, mbNo, mbCancel]) do
    try
      Width:=384;
      Height:=130;

      with TButton(FindComponent('Yes')) do begin
        Caption:=IDS_ONLY_MISSING;
        Width:=160;
        Left:=8;
      end;

      with TButton(FindComponent('No')) do begin
        Caption:=IDS_RECREATE_ALL;
        Width:=120;
        Left:=172;
      end;

      with TButton(FindComponent('Cancel')) do begin
        Caption:=IDS_CANCEL;
        Width:=75;
        Left:=296;
      end;

      case ShowModal of
        // создать только отсутствующие
        mrYes: begin ProcessFolder(SelectedFolderPath, true); MessageBox(0, PChar(IDS_DONE), PChar(IDS_TITLE), MB_ICONINFORMATION); end;

        // пересоздать все
        mrNo: begin ProcessFolder(SelectedFolderPath, false); MessageBox(0, PChar(IDS_DONE), PChar(IDS_TITLE), MB_ICONINFORMATION); end;

        mrCancel: exit;
      end;

    finally
      Free;
    end;
end;

procedure TSettingsForm.CoversBtnClick(Sender: TObject);
begin
  if PathsLB.ItemIndex = -1 then Exit;
  SelectedFolderPath:=PathsLB.Items.Strings[PathsLB.ItemIndex];
  CDTemplateBmp:=TBitmap.Create;
  LoadBitmapFromFile(ExtractFilePath(ParamStr(0)) + 'cd_jewel.jpg', CDTemplateBmp);
  AskCreateCovers;
  CDTemplateBmp.Free;
end;

procedure TSettingsForm.Covers2BtnClick(Sender: TObject);
begin
  if HiddenPathsLB.ItemIndex = -1 then Exit;
  SelectedFolderPath:=HiddenPathsLB.Items.Strings[HiddenPathsLB.ItemIndex];
  CDTemplateBmp:=TBitmap.Create;
  LoadBitmapFromFile(ExtractFilePath(ParamStr(0)) + 'cd_jewel.jpg', CDTemplateBmp);
  AskCreateCovers;
  CDTemplateBmp.Free;
end;

procedure TSettingsForm.UseCoverTemplatesCBClick(Sender: TObject);
begin
  UseCoverTemplates:=UseCoverTemplatesCB.Checked;
end;

end.
