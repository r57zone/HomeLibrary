unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls, ShellAPI, MSHTML, IniFiles, ActiveX;

type
  TMain = class(TForm)
    WebView: TWebBrowser;
    procedure FormCreate(Sender: TObject);
    procedure WebViewBeforeNavigate2(Sender: TObject;
      const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    procedure WebViewDocumentComplete(Sender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    procedure MessageHandler(var Msg: TMsg; var Handled: Boolean);
    procedure AddItem(ItemName: string);
    { Private declarations }
  public
    procedure LoadLibrary;
    procedure ScanItems;
    procedure UpdateMenu;
    { Public declarations }
  end;

var
  Main: TMain;
  SaveMessageHandler: TMessageEvent;
  FOleInPlaceActiveObject: IOleInPlaceActiveObject;
  OldWidth, OldHeight: integer;
  CurCat, CurDir, CurItem: string;
  BreakScaning: boolean;
  ShowHiddenCats: boolean;
  MenuCats, HiddenMenuCats: TStringList;
  StyleName, Password: string;
  AllowLoadLibrary: boolean = true;
  SwapMouseButtons: boolean;

  IDS_TITLE, IDS_PASS_QUESTION, IDS_CHOOSE_MEDIA_TYPE: string;
  IDC_MOVIE, IDC_TVSHOW, IDC_GAME, IDC_BOOK, IDC_CANCEL: string;

  IDS_YEAR, IDS_COUNTRY, IDS_STUDIO, IDS_DIRECTOR, IDS_CREDITS,
  IDS_PUBLISHER, IDS_DEVELOPER, IDS_AUTHOR, IDS_GENRE, IDS_PREMIERED,
  IDS_RUNTIME, IDS_MINUTES: string;

  IDC_VIEW, IDC_INSTALL, IDC_OPEN, IDC_FOLDER: string;

const
  StyleMainFile = 'main.html';

implementation

uses Unit2;

{$R *.dfm}

function GetLocaleInformation(Flag: integer): string;
var
  pcLCA: array [0..20] of Char;
begin
  if GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, Flag, pcLCA, 19) <= 0 then
    pcLCA[0]:=#0;
  Result:=pcLCA;
end;

procedure TMain.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
begin
  //Перевод
  if GetLocaleInformation(LOCALE_SENGLANGUAGE) = 'Russian' then begin
    IDS_TITLE:='Домашняя библиотека';
    IDS_PASS_QUESTION:='Введите пароль:';
    IDS_CHOOSE_MEDIA_TYPE:='Выберите тип контента';
    IDC_MOVIE:='Фильм';
    IDC_TVSHOW:='Сериал';
    IDC_GAME:='Игра';
    IDC_BOOK:='Книга';
    IDC_CANCEL:='Отмена';
    //Описание
    IDS_YEAR:='год';
    IDS_COUNTRY:='страна';
    IDS_STUDIO:='студия';
    IDS_DIRECTOR:='режиссёр';
    IDS_CREDITS:='сценарий';
    IDS_PUBLISHER:='издатель';
    IDS_DEVELOPER:='разработчик';
    IDS_AUTHOR:='автор';
    IDS_GENRE:='жанр';
    IDS_PREMIERED:='дата выхода';
    IDS_RUNTIME:='время';
    IDS_MINUTES:='мин.';
    //Кнопки
    IDC_VIEW:='Посмотреть';
    IDC_INSTALL:='Установить';
    IDC_OPEN:='Открыть';
    IDC_FOLDER:='Открыть папку';
  end else begin
    IDS_TITLE:='Home library';
    IDS_PASS_QUESTION:='Enter password:';
    IDS_CHOOSE_MEDIA_TYPE:='Choose content type';
    IDC_MOVIE:='Movie';
    IDC_TVSHOW:='TV show';
    IDC_GAME:='Game';
    IDC_BOOK:='Book';
    IDC_CANCEL:='Cancel';
    //Описание
    IDS_YEAR:='year';
    IDS_COUNTRY:='country';
    IDS_STUDIO:='studio';
    IDS_DIRECTOR:='director';
    IDS_CREDITS:='credits';
    IDS_PUBLISHER:='publisher';
    IDS_DEVELOPER:='developer';
    IDS_AUTHOR:='author';
    IDS_GENRE:='genre';
    IDS_PREMIERED:='premiered';
    IDS_RUNTIME:='runtime';
    IDS_MINUTES:='min.';
    //Кнопки
    IDC_VIEW:='View';
    IDC_INSTALL:='Install';
    IDC_OPEN:='Open';
    IDC_FOLDER:='Open folder';
  end;
  Caption:=IDS_TITLE;
  Application.Title:=IDS_TITLE;

  MenuCats:=TStringList.Create;
  if FileExists(ExtractFilePath(ParamStr(0)) + 'Categories.txt') then
    MenuCats.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Categories.txt');
  HiddenMenuCats:=TStringList.Create;
  if FileExists(ExtractFilePath(ParamStr(0)) + 'HiddenCategories.txt') then
    HiddenMenuCats.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'HiddenCategories.txt');
    
  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
  StyleName:='Styles\' + Ini.ReadString('Main', 'Style', 'Cupboard') + '\';
  SwapMouseButtons:=Ini.ReadBool('Main', 'SwapMouseButtons', false);
  Password:=Ini.ReadString('Main', 'Password', '');
  Width:=Ini.ReadInteger('Main', 'Width', Width);
  Height:=Ini.ReadInteger('Main', 'Height', Height);
  OldWidth:=Width;
  OldHeight:=Height;
  Ini.Free;
  Application.Title:=Caption;
  WebView.Navigate(ExtractFilePath(ParamStr(0)) + StyleName + 'main.html');
end;

procedure TMain.UpdateMenu;
var
  i:integer;
begin
  WebView.OleObject.Document.getElementById('menu').innerHTML:='';
  for i:=0 to MenuCats.Count - 1 do
    WebView.OleObject.Document.getElementById('menu').innerHTML:=WebView.OleObject.Document.getElementById('menu').innerHTML +
    '<a href="#view=' + StringReplace(MenuCats.Strings[i], ' ', '%20', [rfReplaceAll]) + //Заменяем пробелы на "%20", чтобы передать их в пути
    '">' + ExtractFileName(MenuCats.Strings[i]) + '</a>';

  //Если пароль введен показываем скрытые категории
  if ShowHiddenCats then begin
    for i:=0 to HiddenMenuCats.Count - 1 do
      WebView.OleObject.Document.getElementById('menu').innerHTML:=WebView.OleObject.Document.getElementById('menu').innerHTML +
      '<a href="#view=' + StringReplace(HiddenMenuCats.Strings[i], ' ', '%20', [rfReplaceAll]) + //Заменяем пробелы на "%20", чтобы передать их в пути
      '">' + ExtractFileName(HiddenMenuCats.Strings[i]) + '</a>';
  end else
  //Показываем значок скрытых категорий
    if Trim(HiddenMenuCats.Text) <> '' then
      WebView.OleObject.Document.getElementById('menu').innerHTML:=WebView.OleObject.Document.getElementById('menu').innerHTML +
      '<a href="#showHidden">...</a>';
end;

procedure TMain.WebViewBeforeNavigate2(Sender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
  sUrl, sValue: string;
begin
  sUrl:=Copy(URL, Pos(StyleMainFile, URL), Length(URL) - Pos(StyleMainFile, URL) + 1);

  if Pos(StyleMainFile, sUrl) = 0 then Cancel:=true;

  if Pos(StyleMainFile + '#view=', sUrl) > 0 then begin
    Delete(sUrl, 1, Pos('#view=', sUrl) + 5);
    CurCat:=sUrl;
    CurCat:=StringReplace(CurCat, '%20', ' ', [rfReplaceAll]); //Возвращаем пробелы назад (пробелы в пути URL)
    //При изменении категории останавливать поиск
    BreakScaning:=true;

    LoadLibrary;
  end;

  if Pos(StyleMainFile + '#open=', sUrl) > 0 then begin
    Delete(sUrl, 1, Pos('#open=', sUrl) + 5);
    sUrl:=StringReplace(sUrl, '%20', ' ', [rfReplaceAll]);
    CurDir:=CurCat + '\' + sURL;
    ShellExecute(Handle, 'open', PChar(CurDir), nil, nil, SW_SHOW);
  end;

  if Pos(StyleMainFile + '#openInfo=', sUrl) > 0 then begin
    Delete(sUrl, 1, Pos('#openInfo=', sUrl) + 9);
    sUrl:=StringReplace(sUrl, '%20', ' ', [rfReplaceAll]);
    CurDir:=CurCat + '\' + sURL;
    CurItem:=sUrl;
    DescriptionForm.Show;
  end;

  if (sUrl = StyleMainFile + '#showHidden') and InputQuery(IDS_TITLE, IDS_PASS_QUESTION, sValue) and (sValue = Password) then begin
    ShowHiddenCats:=true;
    UpdateMenu;
  end;
end;

procedure TMain.WebViewDocumentComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
begin
  if pDisp=(Sender as TWebBrowser).Application then
    if ExtractFileName(StringReplace(URL, '/', '\', [rfReplaceAll])) = StyleMainFile then begin
      UpdateMenu;
      CurCat:=MenuCats.Strings[0];
      LoadLibrary;
      WebView.Visible:=true;
      if WebView.Document <> nil then
        (WebView.Document as IHTMLDocument2).ParentWindow.Focus;
    end;
end;

procedure TMain.AddItem(ItemName: string);
var
  CoverImage, ItemHTML: string;
begin
  CoverImage:='';

  if FileExists(CurCat + '\' + ItemName + '\cover-small.jpg') then CoverImage:=CurCat + '\' + ItemName + '\cover-small.jpg';
  if CoverImage = '' then
    if FileExists(CurCat + '\' + ItemName + '\cover-small.png') then CoverImage:=CurCat + '\' + ItemName + '\cover-small.png';
  if CoverImage = '' then
    if FileExists(CurCat + '\' + ItemName + '\cover-small.gif') then CoverImage:=CurCat + '\' + ItemName + '\cover-small.gif';
  if CoverImage = '' then
    if FileExists(CurCat + '\' + ItemName + '\cover-small.jpeg') then CoverImage:=CurCat + '\' + ItemName + '\cover-small.jpeg';
  if CoverImage = '' then
    if FileExists(CurCat + '\' + ItemName + '\cover-small.hpic') then CoverImage:=CurCat + '\' + ItemName + '\cover-small.hpic';

  if CoverImage = '' then
    if FileExists(CurCat + '\' + ItemName + '\cover.jpg') then CoverImage:=CurCat + '\' + ItemName + '\cover.jpg';
  if CoverImage = '' then
    if FileExists(CurCat + '\' + ItemName + '\cover.png') then CoverImage:=CurCat + '\' + ItemName + '\cover.png';
  if CoverImage = '' then
    if FileExists(CurCat + '\' + ItemName + '\cover.gif') then CoverImage:=CurCat + '\' + ItemName + '\cover.gif';
  if CoverImage = '' then
    if FileExists(CurCat + '\' + ItemName + '\cover.jpeg') then CoverImage:=CurCat + '\' + ItemName + '\cover.jpeg';
  if CoverImage = '' then
    if FileExists(CurCat + '\' + ItemName + '\cover.hpic') then CoverImage:=CurCat + '\' + ItemName + '\cover.hpic';

  if CoverImage = '' then
    CoverImage:='default.png';

  ItemHTML:='<div id="cover">';
  if SwapMouseButtons = false then begin
    ItemHTML:=ItemHTML + '<span><img onclick="document.location=''#openInfo=' + ItemName + ''';" oncontextmenu="document.location=''#open=' + ItemName + ''';" title="' + ItemName + '" src="' + CoverImage + '" /></span>';
    ItemHTML:=ItemHTML + '<div onclick="document.location=''#openInfo=' + ItemName + ''';" oncontextmenu="document.location=''#open=' + ItemName + ''';" title="' + ItemName + '" id="name">' + ItemName + '</div></div>';
  end else begin
    ItemHTML:=ItemHTML + '<span><img onclick="document.location=''#open=' + ItemName + ''';" oncontextmenu="document.location=''#openInfo=' + ItemName + ''';" title="' + ItemName + '" src="' + CoverImage + '" /></span>';
    ItemHTML:=ItemHTML + '<div onclick="document.location=''#open=' + ItemName + ''';" oncontextmenu="document.location=''#openInfo=' + ItemName + ''';" title="' + ItemName + '" id="name">' + ItemName + '</div></div>';
  end;

  WebView.OleObject.Document.getElementById('items').innerHTML:=WebView.OleObject.Document.getElementById('items').innerHTML + ItemHTML;
end;

procedure TMain.ScanItems;
var
  SearchResult: TSearchRec;
begin
  //Очистка списка
  WebView.OleObject.Document.getElementById('items').innerHTML:='';

  if FindFirst(CurCat + '\*.*', faAnyFile, SearchResult) = 0 then begin
      repeat
        if BreakScaning then //При изменении категории останавливать поиск
          Break;
        if (SearchResult.Name <> '.') and (SearchResult.Name <> '..') and (SearchResult.Attr = faDirectory) then begin
          AddItem(SearchResult.Name);
          Application.ProcessMessages;
        end;
      until FindNext(SearchResult) <> 0;
      FindClose(SearchResult);
  end;
  AllowLoadLibrary:=true;
end;

procedure TMain.LoadLibrary;
begin
  Application.ProcessMessages;

  if AllowLoadLibrary = false then Exit;
  AllowLoadLibrary:=false;
  //Снова разрешаем поиск
  BreakScaning:=false;

  Caption:=IDS_TITLE + ': ' + ExtractFileName(CurCat);
  Application.Title:=Caption;

  //Ищем
  ScanItems;
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Ini: TIniFile;
begin
  if (Main.WindowState <> wsMaximized) then
    if (OldWidth <> Width) or (OldHeight <> Height) then begin
      Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
      Ini.WriteInteger('Main', 'Width', Width);
      Ini.WriteInteger('Main', 'Height', Height);
      Ini.Free;
    end;
  MenuCats.Free;
  HiddenMenuCats.Free;
  Application.OnMessage:=SaveMessageHandler;
  FOleInPlaceActiveObject:=nil;
end;

procedure TMain.MessageHandler(var Msg: TMsg; var Handled: Boolean);
var
  iOIPAO: IOleInPlaceActiveObject;
  Dispatch: IDispatch;
begin
  if not Assigned(WebView) then begin
    Handled := False;
    Exit;
  end;
  Handled := (IsDialogMessage(WebView.Handle, Msg) = True);
  if (Handled) and (not WebView.Busy) then
  begin
    if FOleInPlaceActiveObject = nil then
    begin
      Dispatch := WebView.Application;
      if Dispatch <> nil then
      begin
        Dispatch.QueryInterface(IOleInPlaceActiveObject, iOIPAO);
        if iOIPAO <> nil then
          FOleInPlaceActiveObject:=iOIPAO;
      end;
    end;
    if FOleInPlaceActiveObject <> nil then
      if ((Msg.message = WM_KEYDOWN) or (Msg.message = WM_KEYUP)) and
        ((Msg.wParam = VK_BACK) or (Msg.wParam = VK_LEFT) or (Msg.wParam = VK_RIGHT)
        or (Msg.wParam = VK_UP) or (Msg.wParam = VK_DOWN)) then exit;
        FOleInPlaceActiveObject.TranslateAccelerator(Msg);
  end;
end;

procedure TMain.FormActivate(Sender: TObject);
begin
  SaveMessageHandler:=Application.OnMessage;
  Application.OnMessage:=MessageHandler;
end;

procedure TMain.FormDeactivate(Sender: TObject);
begin
  Application.OnMessage:=SaveMessageHandler;
end;

initialization
 OleInitialize(nil);

finalization
 OleUninitialize;

end.
