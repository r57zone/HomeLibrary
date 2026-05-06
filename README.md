[![EN](https://user-images.githubusercontent.com/9499881/33184537-7be87e86-d096-11e7-89bb-f3286f752bc6.png)](https://github.com/r57zone/Home-library/blob/master/README.md) 
[![RU](https://user-images.githubusercontent.com/9499881/27683795-5b0fbac6-5cd8-11e7-929c-057833e01fb1.png)](https://github.com/r57zone/Home-library/blob/master/README.RU.md)
← Choose language | Выберите язык

# Home Library
Catalog for movies, tv shows, games and books.

## Screenshots
<a href="https://user-images.githubusercontent.com/9499881/71446104-4277fb80-2739-11ea-8d18-6574a1de4973.png">
<img src="https://user-images.githubusercontent.com/9499881/71446104-4277fb80-2739-11ea-8d18-6574a1de4973.png" height="150px" />
</a>
<a href="https://user-images.githubusercontent.com/9499881/71446154-ad293700-2739-11ea-8be8-f4ae43b7f686.png">
<img src="https://user-images.githubusercontent.com/9499881/71446154-ad293700-2739-11ea-8be8-f4ae43b7f686.png" height="150px" />
</a>
<a href="https://user-images.githubusercontent.com/9499881/71446166-c7631500-2739-11ea-9d1b-e26a5b92ffdb.png">
<img src="https://user-images.githubusercontent.com/9499881/71446166-c7631500-2739-11ea-9d1b-e26a5b92ffdb.png" height="150px" />
</a>
<a href="https://user-images.githubusercontent.com/9499881/71446243-90d9ca00-273a-11ea-91b6-145253e34131.png">
<img src="https://user-images.githubusercontent.com/9499881/71446243-90d9ca00-273a-11ea-91b6-145253e34131.png" height="150px" />
</a>

## Setup
1. Add the required folders in the settings. Hidden folders are supported. The password for viewing them can be changed in the settings.
2. Add posters or covers for your movies, TV shows, games, and books. To do this, place a file named `Cover` in the folder of the movie, game, TV show, or book. It is also recommended to create `CoverSmall` — a smaller version, so loading is faster and images look cleaner. You can either create this file manually or select the desired folder in the settings and click the `Covers` button. Recommended sizes for `CoverSmall`: for movies — `100x150`, for newer games — `100x133`, for older games — `100x100`. Covers can be downloaded automatically using [MediaElch](https://github.com/Komet/MediaElch).
3. Add descriptions for your movies, TV shows, games, and books if needed. This can be done manually by clicking `+` and entering data, for example, from Wikipedia, or automatically using [MediaElch](https://github.com/Komet/MediaElch) — for movies and TV shows. For games and books, descriptions must be filled in manually. High-resolution covers can be downloaded using the Playnite program (they are located in the program folder — `Playnite\library\files`) or manually. Descriptions are stored in `NFO` files; movies and TV shows will be compatible with the `Kodi` interface.
4. By default, a `Watch` button is created for movies, an `Install` button for games, an `Open` button for books, as well as an `Open Folder` button for all categories. You can also create custom buttons, for example, to open a file, application, or folder. The `NFO` file contains an example of how to create a button; if needed, they can be duplicated (sub-item `button` in the `buttons` section).
5. You can optionally swap the functions of the right and left mouse buttons.

## Features
By default, files with extensions `EXE/MSI`, `MP4/AVI/MKV/MOV`, `ISO/CUE/MDS/NRG/CCD`, `PDF/DJVU/HTML/TXT/EPUB/FB2/RTF/DOC/DOCX/MOBI`, as well as folders, are automatically added to the description. This can be disabled in the settings. For automatic mounting of disk images, you can [install WinCDEmu](https://wincdemu.sysprogs.org/).

To modify automatically added buttons, you need to create a custom button, for example: `<button open="setup_dlc.exe">Addon</button>` in the `NFO` file.

To hide a specific button, add a button with the name `hidden`, for example: `<button open="setup2.exe">hidden</button>`.

## Download
>Supports Windows 7, 8, 8.1, 10, 11.

[Download](https://github.com/r57zone/Home-library/releases)

## Feedback
`r57zone[at]gmail.com`