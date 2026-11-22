# QtScrcpy Oxide-форк: передача дел

Дата: 2026-11-22. Владелец общается по-русски.

## Цель

Играть в **Oxide: Survival Island** (Android, `com.catsbit.oxidesurvivalisland`) с телефона Samsung S24 Ultra
(SM-S928N, Android 16, серийный номер `R3CX10PGNKV`, USB) на ПК: экран телефона на весь монитор
1920×1080, управление клавиатурой и мышью как в шутере. Отдельно владелец стримит на Twitch через OBS (см. ниже).

## Где что лежит

| Что | Путь |
|---|---|
| Исходники форка | `D:\Projects\git\QtScrcpy-oxide` (ветка `oxide`) |
| Подмодуль ядра | `QtScrcpy\QtScrcpyCore` (ветка `oxide`) |
| GitHub | `BlackWh1te/QtScrcpy` и `BlackWh1te/QtScrcpyCore`, ветка `oxide`. upstream: `barry-ran/*` |
| Готовая программа | `output\x64\Release\QtScrcpy.exe` |
| Лог программы | `output\x64\Release\qtscrcpy-oxide.log` (перезаписывается при запуске) |
| Раскладка Oxide | `keymap\oxide.json` в репо; рабочая копия `%APPDATA%\QtScrcpy\QtScrcpy\keymap\0-Oxide.json` (имя с `0-`, чтобы шла первой) и `output\x64\Release\keymap\0-Oxide.json`; исходник `C:\Users\Shukhrat\Desktop\STREAM\tools\oxide.json` |
| Конфиг | `%APPDATA%\QtScrcpy\QtScrcpy\config\config.ini` и `output\x64\Release\config\config.ini` (MaxFps=60, LogLevel=warn) |
| Запуск одним кликом | `C:\Users\Shukhrat\Desktop\STREAM\Oxide на ПК.bat` → `QtScrcpy.exe --oxide` |
| Qt 5.15.2 msvc2019_64 | `D:\Qt` (через aqtinstall) |
| Windows SDK 10.0.26100 | `D:\WindowsKits\nuget\...` (NuGet-пакеты распакованы вручную: официальный установщик на D: ставить отказался, на C: уже есть частичные Windows Kits) |
| Компилятор | VS 2022 Build Tools, MSVC 14.44 (C:) |

**Правило владельца: всё новое качать и ставить на диск D:.** На C: мало места.

## Сборка

```
D:\Projects\git\QtScrcpy-oxide\build-oxide.bat
```
Ninja + cl.exe, переменные INCLUDE/LIB/PATH скрипт выставляет сам. Перед сборкой закройте запущенный QtScrcpy.exe,
иначе `LNK1104`. После первой сборки один раз: `D:\Qt\5.15.2\msvc2019_64\bin\windeployqt.exe --release --no-translations --no-compiler-runtime output\x64\Release\QtScrcpy.exe`.
Пути для CMake только с прямыми слэшами (`\n` в `D:\WindowsKits\nuget` CMake читает как перенос строки).

## Что изменено относительно upstream

**QtScrcpyCore** (`src/device/controller/inputconvert/inputconvertgame.*`, `decoder/decoder.cpp`):
- Обзор мышью: дельты копятся и отправляются таймером раз в 4 мс (`MOUSE_FLUSH_INTERVAL_MS`). Раньше одно касание на каждое событие ОС, при мыши 1000 Гц это забивало канал → фризы и рывки.
- Виртуальный палец обзора у края своей зоны мгновенно переставляется на якорь, без выброса движений (в оригинале `ignoreCount=5`). Курсор держится по центру окна. Палец отпускается после 300 мс без движения.
- Игровой режим включается сам при первом событии мыши (`m_autoGameMapPending`).
- ПКМ (switchKey) больше не выключает раскладку, а переключает «режим меню» (`setMenuMode`): курсор виден, клики мышью = касания. Клавиши с `switchMap: true` (Tab, Esc, Q, B, I, M) жмут кнопку и тоже переключают режим меню.
- `hideMouseCursor` идемпотентный (стек override-курсора не разъезжается).
- Бег: `sprintKey` / `sprintUpScale` в корне JSON раскладки. Пока клавиша зажата, W тянет джойстик в `sprintUpScale` раз дальше вверх (`calcSteerWheelOffset`, `retargetSteerWheel`).
- Утечка touch id: при потере фокуса приложением (`applicationStateChanged`) отпускаются все пальцы (`releaseAllTouches`). Повторное нажатие уже зажатой клавиши переиспользует её id. Если id кончились, всё отпускается.
- Лог `[oxide] key ...`: каждое нажатие с режимом и типом узла раскладки.
- Декодер: `AV_CODEC_FLAG_LOW_DELAY`, `AV_CODEC_FLAG2_FAST`.

**QtScrcpy** (`ui/videoform.*`, `ui/dialog.*`, `main.cpp`):
- `--oxide`: выбирает раскладку с «oxide» в имени, 16 Мбит/с, 1920 px, stay awake, ждёт USB-телефон (до 60 с), подключается, окно на весь экран, главное окно сворачивается, отключаются все горячие клавиши, кроме Ctrl+F (иначе Ctrl-присед + S/H/B/W срабатывали бы).
- Tab не переключает фокус (`focusNextPrevChild` → false). Esc не выходит из полного экрана (выход по Ctrl+F).
- Клавиши независимы от раскладки: на Windows буквы, цифры и OEM берутся из `nativeVirtualKey` (при русской раскладке W приходил как «Ц», и ничего не работало).
- Весь лог дублируется в `qtscrcpy-oxide.log` рядом с exe.

## Раскладка (keymap/oxide.json), координаты 0–1 от кадра 1920×886

WASD — джойстик (центр 0.2025, 0.758, смещения 0.09/0.2) · Shift — бег (`sprintUpScale` 2.0) · Space — прыжок (0.904, 0.778)
· ЛКМ — удар/стрельба (0.8075, 0.758) · BackButton (Mouse 4) — прицел (0.875, 0.563) · R — перезарядка (0.7275, 0.771)
· Ctrl/C — присесть (0.8325, 0.937) · E — действие (0.2775, 0.547) · V — голос (0.7135, 0.908)
· Tab/I — рюкзак (0.0725, 0.607) · Q — создание (0.0725, 0.742) · B — стройка (0.0725, 0.867) · Esc/M — меню (0.961, 0.054)
· 1–6 — хотбар (x 0.35…0.65 шаг 0.06, y 0.9025) · ПКМ — режим меню · обзор: якорь (0.7, 0.4), speedRatio 3.

## Текущее состояние и ОТКРЫТАЯ ПРОБЛЕМА

- По 20 снимкам экрана (в 20:58) всё работало: слоты, стрельба, прицел, бег, обзор.
- В 21:01 владелец сообщил: «кнопки не жмутся», при этом картинка на ПК двигается. Лог в этот момент показывает,
  что W/A/D/Ctrl/C получены в `gameMap true menu false` и касания отправлены. Значит, проблема на стороне телефона/игры, причина не найдена.
- Последняя находка, не разобрана: `adb shell dumpsys input` показывает **Display 41** с `logicalSize=1920x886`
  (размер нашего видео). Возможно, сервер scrcpy 4.1 (QtScrcpy master) создаёт или использует виртуальный дисплей,
  и касания идут в него, а не в дисплей 0 с игрой. Проверить: параметры запуска сервера в логе
  (`app_process ... Server 4.1 ...`), нет ли `new_display`/`display_id`, и в какой дисплей уходят инжектированные касания.
- Есть подозрение и на интерференцию с Samsung S Pen / `PointerEventDispatcherOverlay`.
- Владелец часто уходит в другое окно по Alt+Tab, это нормальный сценарий.

### Как диагностировать
- `output\x64\Release\qtscrcpy-oxide.log`: строки `[oxide] key` (код клавиши hex, gameMap, menu, тип узла).
- Показ касаний: `adb -s R3CX10PGNKV shell settings put system show_touches 1` (обязательно вернуть `0`), плюс
  `adb exec-out screencap -p` серией.
- `adb shell dumpsys input` → `TouchStatesByDisplay`, `RecentQueue`.
- Не отправлять синтетические клавиши (keybd_event), если окно `Phone-R3CX10PGNKV` не на переднем плане:
  проверка в `STREAM\tools\fg.ps1`. Однажды тестовые Shift+Tab ушли в чужое окно владельца.

## Связанное: стрим

- OBS: профиль «Twitch MLBB», коллекция «MLBB Twitch», управление через WebSocket (`STREAM\tools\obs-conn.mjs`).
- Для стрима телефон захватывается обычным scrcpy 5.0.1 (`STREAM\Телефон для стрима.bat`, окно «MLBB Phone»).
  В .bat добавлен `SDL_AUDIODRIVER=directsound`: с WASAPI scrcpy падал при BT-гарнитуре.
- Нельзя одновременно держать scrcpy (стрим) и QtScrcpy (игра) на одном телефоне без проверки.

## Вспомогательные скрипты (C:\Users\Shukhrat\Desktop\STREAM\tools)

`uia-*.ps1` (кнопки QtScrcpy через UI Automation), `fullscreen-phone.ps1`, `key-test2.ps1` (синтетическая клавиша,
только если окно телефона спереди), `fg.ps1` (какое окно спереди), `mouse-nudge.ps1`.

## Чего не делать

- Компенсацию отдачи / макросы стрельбы: владелец просил, получил отказ (это чит в онлайне).
- Пушить в upstream, деплоить, массово удалять файлы.
