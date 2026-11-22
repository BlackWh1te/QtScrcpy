@echo off
rem Сборка QtScrcpy (Oxide-форк) под Windows x64.
rem Нужны: Qt 5.15.2 msvc2019_64 в D:\Qt, VS 2022 Build Tools (компилятор), Windows SDK из NuGet в D:\WindowsKits\nuget.
setlocal
set "QT=D:\Qt\5.15.2\msvc2019_64"
set "VS=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
set "MSVC=%VS%\VC\Tools\MSVC\14.44.35207"
set "SDKC=D:\WindowsKits\nuget\microsoft.windows.sdk.cpp\c"
set "SDKX=D:\WindowsKits\nuget\microsoft.windows.sdk.cpp.x64\c"
set "SDKV=10.0.26100.0"
set "CMAKEDIR=%VS%\Common7\IDE\CommonExtensions\Microsoft\CMake"

set "INCLUDE=%MSVC%\include;%SDKC%\Include\%SDKV%\ucrt;%SDKC%\Include\%SDKV%\um;%SDKC%\Include\%SDKV%\shared;%SDKC%\Include\%SDKV%\winrt"
set "LIB=%MSVC%\lib\x64;%SDKX%\um\x64;%SDKX%\ucrt\x64"
set "PATH=%MSVC%\bin\Hostx64\x64;%SDKC%\bin\%SDKV%\x64;%CMAKEDIR%\Ninja;%CMAKEDIR%\CMake\bin;%QT%\bin;%PATH%"

cd /d "%~dp0"
rem пути для CMake только с прямыми слэшами: "\n" в D:\WindowsKits\nuget CMake читает как перенос строки
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=D:/Qt/5.15.2/msvc2019_64 ^
  -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl -DCMAKE_RC_COMPILER=rc -DCMAKE_MT=mt || exit /b 1
cmake --build build || exit /b 1
echo.
echo Готово. Папка с программой: %~dp0output
