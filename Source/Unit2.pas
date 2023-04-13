unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, MSHTML, ShellAPI, StdCtrls, XPMan;

type
  TDescriptionForm = class(TForm)
    WebView: TWebBrowser;
    XPManifest: TXPManifest;
    procedure WebViewDocumentComplete(Sender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure FormShow(Sender: TObject);
    procedure WebViewBeforeNavigate2(Sender: TObject;
      const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure NFOParse(FileName: string);
    function NFOButtons(FileName: string): string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DescriptionForm: TDescriptionForm;
  NFOFilePath: string;

implementation

uses Unit1;

{$R *.dfm}

{function ExtractYear(Str: string): string; //Извлечь год
begin
  Result:='';
  Str:=Trim(Str);
  if (Str[Length(Str)]=')') and (Str[Length(Str) - 5] = '(') then begin
    Delete(Str, 1, Length(Str) - 5);
    Delete(Str, Length(Str), 1);
    Result:=Str;
  end;
end;

function ExtractWithoutYear(Str: string): string; //Извлечь имя
begin
  Result:=Str;
  Str:=Trim(Str);
  if (Str[Length(Str)] = ')') and (Str[Length(Str) - 5] = '(') then begin
    Delete(Str, Length(Str) - 5, 6);
    Result:=Trim(Str);
  end;
end;}

procedure TDescriptionForm.WebViewDocumentComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
  CoverImage: string;
  SearchResult: TSearchRec;
  FileNameExt, SetupExeName: string;
  ButtonsPaths: string;
begin
  if pDisp=(Sender as TWebBrowser).Application then
    if ExtractFileName(StringReplace(URL, '/', '\', [rfReplaceAll])) = 'description.html' then begin
      WebView.Visible:=true;

      if FileExists(CurDir + '\cover.jpg') then CoverImage:=CurDir + '\cover.jpg'
      else if FileExists(CurDir + '\cover.png') then CoverImage:=CurDir + '\cover.png'
      else if FileExists(CurDir + '\cover.gif') then CoverImage:=CurDir + '\cover.gif'
      else if FileExists(CurDir + '\cover.jpeg') then CoverImage:=CurDir + '\cover.jpeg'
      else if FileExists(CurDir + '\cover.hpic') then CoverImage:=CurDir + '\cover.hpic'

      else if FileExists(CurDir + '\coversmall.jpg') then CoverImage:=CurDir + '\coversmall.jpg'
      else if FileExists(CurDir + '\coversmall.png') then CoverImage:=CurDir + '\coversmall.png'
      else if FileExists(CurDir + '\coversmall.gif') then CoverImage:=CurDir + '\coversmall.gif'
      else if FileExists(CurDir + '\coversmall.jpeg') then CoverImage:=CurDir + '\coversmall.jpeg'
      else if FileExists(CurDir + '\coversmall.hpic') then CoverImage:=CurDir + '\coversmall.hpic'

      else if FileExists(CurDir + '\cover-small.jpg') then CoverImage:=CurDir + '\cover-small.jpg'
      else if FileExists(CurDir + '\cover-small.png') then CoverImage:=CurDir + '\cover-small.png'
      else if FileExists(CurDir + '\cover-small.gif') then CoverImage:=CurDir + '\cover-small.gif'
      else if FileExists(CurDir + '\cover-small.jpeg') then CoverImage:=CurDir + '\cover-small.jpeg'
      else if FileExists(CurDir + '\cover-small.hpic') then CoverImage:=CurDir + '\cover-small.hpic';

      WebView.OleObject.Document.getElementById('header').innerHTML:='<h1>' + CurItem + '</h1>';
      WebView.OleObject.Document.getElementById('links').innerHTML:='';
      WebView.OleObject.Document.getElementById('cover').innerHTML:='<img src="' + CoverImage + '" />';
      WebView.OleObject.Document.getElementById('description').innerHTML:='<a href="#createNFO">+</a>';

      NFOFilePath:='';
      // Поиск NFO файла
      if FindFirst(CurDir + '\*.nfo', faAnyFile, SearchResult) = 0 then begin
          NFOFilePath:=CurDir + '\' + SearchResult.Name;
        ButtonsPaths:=NFOButtons(NFOFilePath); // Загружаем имена кнопок, чтобы не дублировать папки и повысить их приоритет
        FindClose(SearchResult);
      end;

      // Кнопка установить для игр (автоопределение)
      SetupExeName:='';
      if FindFirst(CurDir + '\*.exe', faAnyFile, SearchResult) = 0 then begin
        repeat
          if SearchResult.Attr = faDirectory then Continue;
          if Pos('setup', AnsiLowerCase(SearchResult.Name)) = 0 then Continue;
          WebView.OleObject.Document.getElementById('links').innerHTML:=WebView.OleObject.Document.getElementById('links').innerHTML +
          '<a href="#open=' + StringReplace(CurDir, ' ', '%20', [rfReplaceAll]) + '\' + SearchResult.Name + '">' + IDC_INSTALL + '</a>';
          SetupExeName:=SearchResult.Name;
          Break;
        until FindNext(SearchResult) <> 0;
        FindClose(SearchResult);
      end;

      // Парсинг и специальные кнопки
      if NFOFilePath <> '' then begin
        NFOParse(NFOFilePath);
        WebView.OleObject.Document.getElementById('description').innerHTML:=WebView.OleObject.Document.getElementById('description').innerHTML + '<a id="editBtn" href="#editNFO">&#9998;</a></div>';
      end;

      if ShowAdditionalButtons then begin
      // CD images
      if FindFirst(CurDir + '\*.*', faAnyFile, SearchResult) = 0 then begin
        repeat
          if SearchResult.Attr = faDirectory then Continue;
          FileNameExt:=ExtractFileExt(AnsiLowerCase(SearchResult.Name));
          if (FileNameExt = '.iso') or (FileNameExt = '.cue') then begin
            WebView.OleObject.Document.getElementById('links').innerHTML:=WebView.OleObject.Document.getElementById('links').innerHTML +
            '<a href="#open=' + StringReplace(CurDir, ' ', '%20', [rfReplaceAll]) + '\' + SearchResult.Name + '" title="' + SearchResult.Name + '">' + IDC_MOUNT + ' ' + SearchResult.Name + '</a>';
          end;
        until FindNext(SearchResult) <> 0;
        FindClose(SearchResult);
      end;

      // Патчи и прочее
      if FindFirst(CurDir + '\*.exe', faAnyFile, SearchResult) = 0 then begin
        repeat
          if (ButtonsPaths <> '') and (Pos(SearchResult.Name + #13#10, ButtonsPaths) > 0) then Continue;
          if SearchResult.Attr = faDirectory then Continue;
          if (SetupExeName <> '') and (SetupExeName = SearchResult.Name) then Continue;
          WebView.OleObject.Document.getElementById('links').innerHTML:=WebView.OleObject.Document.getElementById('links').innerHTML +
          '<a href="#open=' + StringReplace(CurDir, ' ', '%20', [rfReplaceAll]) + '\' + SearchResult.Name + '" title="' + SearchResult.Name + '">' + IDC_RUN + ' ' + SearchResult.Name + '</a>';
        until FindNext(SearchResult) <> 0;
        FindClose(SearchResult);
      end;

      // Folders
      if FindFirst(CurDir + '\*.*', faAnyFile, SearchResult) = 0 then begin
        repeat
          if (ButtonsPaths <> '') and (Pos(SearchResult.Name + #13#10, ButtonsPaths) > 0) then Continue;
          if (SearchResult.Attr <> faDirectory) or (SearchResult.Name = '.') or (SearchResult.Name = '..') then Continue;
          WebView.OleObject.Document.getElementById('links').innerHTML:=WebView.OleObject.Document.getElementById('links').innerHTML +
          '<a href="#open=' + StringReplace(CurDir, ' ', '%20', [rfReplaceAll]) + '\' + SearchResult.Name + '" title="' + SearchResult.Name + '">' + SearchResult.Name + '</a>';
        until FindNext(SearchResult) <> 0;
        FindClose(SearchResult);
      end;

      end; // ShowAdditionalButtons

      // Кнопка открыть папку для всех категорий
      WebView.OleObject.Document.getElementById('links').innerHTML:=WebView.OleObject.Document.getElementById('links').innerHTML +
      '<a href="#folder">' + IDC_FOLDER + '</a>';

      if WebView.Document <> nil then
        (WebView.Document as IHTMLDocument2).ParentWindow.Focus;
    end;
end;

function ParseList(OnSet, OutSet, HTMLSource: string): string;
begin
  while (Pos(OnSet, HTMLSource) > 0) or (Pos(OutSet, HTMLSource) > 0) do begin
    if Result = '' then
      Result:=Copy(HTMLSource, Pos(OnSet, HTMLSource) + Length(OnSet), Pos(OutSet, HTMLSource) - Pos(OnSet, HTMLSource) - Length(OnSet)) else
    Result:=Result + ', ' + Copy(HTMLSource, Pos(OnSet, HTMLSource) + Length(OnSet), Pos(OutSet, HTMLSource) - Pos(OnSet, HTMLSource) - Length(OnSet));
    Delete(HTMLSource, 1, Pos(OutSet, HTMLSource) + Length(OutSet) - 1);
  end;
end;

function ParseTag(TagName, HTMLSource: string): string;
begin
  if Pos(TagName, HTMLSource) > 0 then begin
    Delete(HTMLSource, 1, Pos(TagName, HTMLSource));
    Delete(HTMLSource, 1, Pos('>', HTMLSource));
    Result:=Copy(HTMLSource, 1, Pos('</' + TagName, HTMLSource) - 1);
  end else
    Result:='';
end;

function ParseAtribute(AtribName, HTMLSource: string): string;
begin
  if Pos(AtribName, HTMLSource) > 0 then begin
    Delete(HTMLSource, 1, Pos(AtribName + '="', HTMLSource) + Length(AtribName + '="') - 1);
    Result:=Copy(HTMLSource, 1, Pos('"', HTMLSource) - 1);
  end else
    Result:='';
end;

procedure TDescriptionForm.NFOParse(FileName: string);
var
  NFOFile: TStringList; Content, Title, OriginalTitle, Description, Year, Country, Studio, Director, Credits, Publisher, Author, Developer, Genre, Premiered, Runtime, Actors: string;
  Hour, Minutes, FullTime, i: integer;
  NFOType: (MovieNFO, TVShowNFO, GameNFO, BookNFO);
  CustomButtons, CustomButton, ButtonName, ButtonAtrib: string;
  ButtonsList: TStringList;
const
  ItemNameStart = '<div id="item"><div id="title">';
  ItemNameEnd = '</div>';
  ValueNameStart = '<div id="value">';
  ValueNameEnd = '</div></div>';
begin
  NFOFile:=TStringList.Create;
  NFOFile.LoadFromFile(FileName);
  NFOFile.Text:=UTF8ToAnsi(NFOFile.Text);

  Content:='';

  // Определение типа NFO
  if (Pos('<movie>', NFOFile.Text) > 0) then
    NFOType:=MovieNFO
  else if (Pos('<tvshow>', NFOFile.Text) > 0) then
    NFOType:=TVShowNFO
  else if (Pos('<game>', NFOFile.Text) > 0) then
    NFOType:=GameNFO
  else if (Pos('<book>', NFOFile.Text) > 0) then
    NFOType:=BookNFO;

  // Заголовки
  Title:=ParseTag('title', NFOFile.Text);
  OriginalTitle:=ParseTag('originaltitle', NFOFile.Text);

  // У сериалов отличается тег второго заголовка
  if NFOType = TVShowNFO then
    OriginalTitle:=ParseTag('showtitle', NFOFile.Text);

  // Выводим заголовки
  WebView.OleObject.Document.getElementById('header').innerHTML:='<h1>' + Title + '</h1>';
  if (OriginalTitle <> '') and (Title <> OriginalTitle) then
    WebView.OleObject.Document.getElementById('header').innerHTML:=WebView.OleObject.Document.getElementById('header').innerHTML +
    '<h2>' + OriginalTitle + '</h2>';

  // Разбор NFO

  //Год
  if (NFOType = MovieNFO) or (NFOType = TVShowNFO) then begin
    Year:=ParseTag('year', NFOFile.Text);
    if Year <> '' then
      Content:=Content + ItemNameStart + IDS_YEAR + ItemNameEnd + ValueNameStart + Year + ValueNameEnd;
  end;

  // Страна
  Country:=ParseList('<country>', '</country>', NFOFile.Text);
    if Country <> '' then
      Content:=Content + ItemNameStart + IDS_COUNTRY + ItemNameEnd + ValueNameStart + Country + ValueNameEnd;

  if (NFOType = MovieNFO) or (NFOType = TVShowNFO) then begin
    // Студия
    Studio:=ParseList('<studio>', '</studio>', NFOFile.Text);
    if Director <> '' then
      Content:=Content + ItemNameStart + IDS_STUDIO + ItemNameEnd + ValueNameStart + Studio + ValueNameEnd;

    // Режиссёр
    Director:=ParseList('<director>', '</director>', NFOFile.Text);
    if Director <> '' then
      Content:=Content + ItemNameStart + IDS_DIRECTOR + ItemNameEnd + ValueNameStart + Director + ValueNameEnd;

    // Сценарист
    Credits:=ParseList('<credits>', '</credits>', NFOFile.Text);
    if Credits <> '' then
      Content:=Content + ItemNameStart + IDS_CREDITS + ItemNameEnd + ValueNameStart + Credits + ValueNameEnd;

  end;

  if (NFOType = GameNFO) or (NFOType = BookNFO) then begin

  if NFOType = GameNFO then begin
    // Разработчик
    Developer:=ParseList('<developer>', '</developer>', NFOFile.Text);
    if Developer <> '' then
	    Content:=Content + ItemNameStart + IDS_DEVELOPER + ItemNameEnd + ValueNameStart + Developer + ValueNameEnd;
  end;

    // Издатель
    Publisher:=ParseList('<publisher>', '</publisher>', NFOFile.Text);
    if Publisher <> '' then
      Content:=Content + ItemNameStart + IDS_PUBLISHER + ItemNameEnd + ValueNameStart + Publisher + ValueNameEnd;
  end;

  if NFOType = BookNFO then begin
    // Автор
    Author:=ParseList('<author>', '</author>', NFOFile.Text);
    if Publisher <> '' then
      Content:=Content + ItemNameStart + IDS_AUTHOR + ItemNameEnd + ValueNameStart + Author + ValueNameEnd;
  end;

  // Жанры
  Genre:=ParseList('<genre>', '</genre>', NFOFile.Text);
  if Genre <> '' then
    Content:=Content + ItemNameStart + IDS_GENRE + ItemNameEnd + ValueNameStart + Genre + ValueNameEnd;

  // Премьера
  Premiered:=ParseTag('premiered', NFOFile.Text);
  if Premiered <> '' then
    Content:=Content + ItemNameStart + IDS_PREMIERED + ItemNameEnd + ValueNameStart + Premiered + ValueNameEnd;

  if (NFOType = MovieNFO) or (NFOType = TVShowNFO) then begin
    // Время
    Runtime:=ParseTag('runtime', NFOFile.Text);
    if Runtime <> '' then begin

      FullTime:=StrToIntDef(Runtime, 0);
      Content:=Content + ItemNameStart + IDS_RUNTIME + ItemNameEnd + ValueNameStart + Runtime + ' ' + IDS_MINUTES + ' (' + Format('%.2d:%.2d:00', [FullTime div 60, FullTime - (FullTime div 60) * 60]) + ')' + ValueNameEnd;
    end;
  end;

  {if (NFOType = MovieNFO) or (NFOType = TVShowNFO) then begin
  // В главных ролях:
    Actors:=ParseList('<name>', '</name>', ParseList('<actor>', '</actor>', NFOFile.Text));
    if Actors <> '' then
      Content:=Content + ItemNameStart + 'в главных ролях' + ItemNameEnd + '<div>' + Actors + ValueNameEnd;
  end;}

  // Кнопка для MovieNFO
  if NFOType = MovieNFO then
    WebView.OleObject.Document.getElementById('links').innerHTML:='<a href="#movie">' + IDC_VIEW + '</a>';

  // Кнопка для BookNFO
  if NFOType = BookNFO then
    WebView.OleObject.Document.getElementById('links').innerHTML:='<a href="#book">' + IDC_OPEN + '</a>';

  // Кастомные кнопки
  if (Pos('buttons', NFOFile.Text) > 0) then
    CustomButtons:=ParseTag('buttons', NFOFile.Text);
  if CustomButtons <> '' then begin
    ButtonsList:=TStringList.Create;
    ButtonsList.Text:=Trim(CustomButtons);
    ButtonsList.Text:=StringReplace(ButtonsList.Text, '<button', #13#10 + '<button', [rfReplaceAll]); //Если пользователь разместил случайно на одной строке
    for i:=0 to ButtonsList.Count - 1 do
      if (Pos('<button', ButtonsList.Strings[i]) > 0) or (Pos('</button>', ButtonsList.Strings[i]) > 0) then begin

        ButtonName:=ParseTag('button', ButtonsList.Strings[i]) ; //+ '</button>'
        if Trim(AnsiLowerCase(ButtonName)) = 'hidden' then Continue;

        ButtonAtrib:=CurDir + '\' + ParseAtribute('open', ButtonsList.Strings[i]);
        ButtonAtrib:=StringReplace(ButtonAtrib, ' ', '%20', [rfReplaceAll]); //Пробел не передается по URL

        CustomButton:='<a href="#open=' + ButtonAtrib + '">' + ButtonName + '</a>';

        WebView.OleObject.Document.getElementById('links').innerHTML:=
        WebView.OleObject.Document.getElementById('links').innerHTML + CustomButton;
      end;

    ButtonsList.Free;
  end;

  // Описание
  Description:=ParseTag('plot', NFOFile.Text);
  if Description <> '' then
    Content:=Content + '<br>' + Description;

  // Вывод
  WebView.OleObject.Document.getElementById('description').innerHTML:=Content;

  NFOFile.Free;
end;

function TDescriptionForm.NFOButtons(FileName: string): string;
var
  NFOFile: TStringList;
  CustomButtons, ButtonAtrib: string;
  ButtonsList: TStringList;
  i: integer;
begin
  NFOFile:=TStringList.Create;
  NFOFile.LoadFromFile(FileName);
  NFOFile.Text:=UTF8ToAnsi(NFOFile.Text);

  Result:='';
  if (Pos('buttons', NFOFile.Text) > 0) then
    CustomButtons:=ParseTag('buttons', NFOFile.Text);
  if CustomButtons <> '' then begin
    ButtonsList:=TStringList.Create;
    ButtonsList.Text:=Trim(CustomButtons);
    ButtonsList.Text:=StringReplace(ButtonsList.Text, '<button', #13#10 + '<button', [rfReplaceAll]); //Если пользователь разместил случайно на одной строке
    for i:=0 to ButtonsList.Count - 1 do
      if (Pos('<button', ButtonsList.Strings[i]) > 0) or (Pos('</button>', ButtonsList.Strings[i]) > 0) then begin

        ButtonAtrib:=ParseAtribute('open', ButtonsList.Strings[i]);

        Result:=Result + ButtonAtrib + #13#10;
      end;

    ButtonsList.Free;
  end;

  NFOFile.Free;
end;

procedure TDescriptionForm.FormShow(Sender: TObject);
begin
  DescriptionForm.Caption:=IDS_TITLE + ': ' + CurItem;
  WebView.Navigate(ExtractFilePath(ParamStr(0)) + StyleName + 'description.html');

  DescriptionForm.Width:=ViewerWidth;
  DescriptionForm.Height:=ViewerHeight;
end;

procedure TDescriptionForm.WebViewBeforeNavigate2(Sender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
  sUrl, sValue, FileNameExt: string;
  SearchResult: TSearchRec;
begin
  sUrl:=Copy(URL, Pos('description.html', URL), Length(URL) - Pos('description.html', URL) + 1);

  if Pos('description.html', sUrl) = 0 then Cancel:=true;

  if sUrl = 'description.html#movie' then
    if FindFirst(CurDir + '\*.*', faAnyFile, SearchResult) = 0 then begin
      repeat
        if SearchResult.Attr <> faDirectory then begin

          FileNameExt:=AnsiLowerCase(ExtractFileExt(SearchResult.Name)); // Расширение найденного файла

          if (FileNameExt = '.avi') or (FileNameExt = '.mp4') or (FileNameExt = '.mpeg') or
             (FileNameExt = '.mkv') or (FileNameExt = '.mov') then begin
            ShellExecute(Handle, 'open', PChar(CurDir + '\' + SearchResult.Name), nil, nil, SW_SHOW);
            Break;
          end;
        end;
      until FindNext(SearchResult) <> 0;
      FindClose(SearchResult);
    end;


  if sUrl = 'description.html#book' then
    if FindFirst(CurDir + '\*.*', faAnyFile, SearchResult) = 0 then begin
      repeat
        if (SearchResult.Name <> '.') and (SearchResult.Name <> '..') and (SearchResult.Attr <> faDirectory) then begin

          FileNameExt:=AnsiLowerCase(ExtractFileExt(SearchResult.Name)); // Расширение найденного файла

          if (FileNameExt = '.pdf') or (FileNameExt = '.epub') or (FileNameExt = '.txt') or
             (FileNameExt = '.djvu') or (FileNameExt = '.fb2') or (FileNameExt = '.rtf') or
             (FileNameExt = '.doc') or (FileNameExt = '.docx') or (FileNameExt = '.mobi') then begin
            ShellExecute(Handle, 'open', PChar(CurDir + '\' + SearchResult.Name), nil, nil, SW_SHOW);
            Break;
          end;
        end;
      until FindNext(SearchResult) <> 0;
      FindClose(SearchResult);
    end;

  if Pos('description.html#open=', sUrl) > 0 then begin
    Delete(sUrl, 1, Pos('#open=', sUrl) + 5);
    sUrl:=StringReplace(sUrl, '%20', ' ', [rfReplaceAll]);
    if FileExists(sUrl) or DirectoryExists(sUrl) then
      ShellExecute(Handle, 'open', PChar(sUrl), nil, nil, SW_SHOW);
  end;

  if sUrl = 'description.html#folder' then
    ShellExecute(Handle, 'open', PChar(CurDir), nil, nil, SW_SHOW);

  if sUrl = 'description.html#createNFO' then
    with CreateMessageDialog(PChar(IDS_CHOOSE_MEDIA_TYPE), mtConfirmation, [mbOK, mbYes, mbNo, mbAll, mbCancel]) do
    try
      TButton(FindComponent('Yes')).Caption:=IDC_MOVIE;
      TButton(FindComponent('OK')).Caption:=IDC_GAME;
      TButton(FindComponent('No')).Caption:=IDC_TVSHOW;
      TButton(FindComponent('Cancel')).Caption:=IDC_BOOK;
      TButton(FindComponent('All')).Caption:=IDC_CANCEL;
      case ShowModal of
        mrYes:
          begin
            CopyFile(PChar(ExtractFilePath(ParamStr(0)) + 'nfo\movie.nfo'), PChar(CurDir + '\' + CurItem + '.nfo'), true);
            ShellExecute(Handle, 'open', PChar(GetEnvironmentVariable('systemroot')  + '\system32\notepad.exe'), PChar(CurDir + '\' + CurItem + '.nfo'), nil, SW_SHOW);
          end;
        mrNo:
          begin
            CopyFile(PChar(ExtractFilePath(ParamStr(0)) + 'nfo\tvshow.nfo'), PChar(CurDir + '\tvshow.nfo'), true);
            ShellExecute(Handle, 'open', PChar(GetEnvironmentVariable('systemroot')  + '\system32\notepad.exe'), PChar(CurDir + '\tvshow.nfo'), nil, SW_SHOW);
          end;
        mrOK:
          begin
            CopyFile(PChar(ExtractFilePath(ParamStr(0)) + 'nfo\game.nfo'), PChar(CurDir + '\' + CurItem + '.nfo'), true);
            ShellExecute(Handle, 'open', PChar(GetEnvironmentVariable('systemroot')  + '\system32\notepad.exe'), PChar(CurDir + '\' + CurItem + '.nfo'), nil, SW_SHOW);
          end;
        mrCancel:
          begin
            CopyFile(PChar(ExtractFilePath(ParamStr(0)) + 'nfo\book.nfo'), PChar(CurDir + '\' + CurItem + '.nfo'), true);
            ShellExecute(Handle, 'open', PChar(GetEnvironmentVariable('systemroot')  + '\system32\notepad.exe'), PChar(CurDir + '\' + CurItem + '.nfo'), nil, SW_SHOW);
          end;
      end;
    finally
      Free;
    end;

  if sUrl = 'description.html#editNFO' then
    ShellExecute(Handle, 'open', PChar(GetEnvironmentVariable('systemroot')  + '\system32\notepad.exe'), PChar(NFOFilePath), nil, SW_SHOW);
end;

procedure TDescriptionForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (DescriptionForm.WindowState <> wsMaximized) then begin
    ViewerWidth:=DescriptionForm.Width;
    ViewerHeight:=DescriptionForm.Height;
  end;
end;

end.
