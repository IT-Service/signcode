Пакет chocolatey для установки средств подписи шрифтов
======================================================

Репозиторий содержит проект для сборки пакета signcode.install для chocolatey.
Предназначен для обеспечения пакетной подписи файлов True Type и Open Type шрифтов цифровой подписью
в пакетном режиме.

Пакет содержит:

- [signcode][] - утилиту от Microsoft с библиотекой подписи шрифтов
- [signcode-pwd][] - утилиту от Stephan Brenner для передачи signcode пароля к сертификату в пакетном режиме

Пакет доступен [в репозитории chocolatey](https://chocolatey.org/packages/signcode.install). 

Использование пакета
--------------------

Установка пакета требует прав администратора.
После установки пакета в командной строке доступны:

- `signcode.exe`
- `signcode-pwd.exe`
- `signcode.bat`

Последний пакетный файл в дополнение к параметрам signcode.exe позволяет указать пароль к сертификату
в форме `-p password`.

Сборка проекта
--------------

Для внесения изменений в пакет и повторной сборки проекта потребуются следующие продукты:

- [CygWin][]
- [GitVersion][]
- [chocolatey][]

Для подготовки среды сборки следует воспользоваться сценарием `install.ps1` (запускать от имени администратора).
Указанный сценарий установит все необходимые компоненты.

Сборка проекта осуществляется следующим образом:

	make

либо

	make all

[chocolatey]: https://chocolatey.org/
[signcode]: https://www.microsoft.com/en-us/Typography/dsigningtool.aspx
[signcode-pwd]: http://www.stephan-brenner.com/?page_id=9
[CygWin]: http://cygwin.com/install.html "Cygwin"
[GitVersion]: https://github.com/GitTools/GitVersion
