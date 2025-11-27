@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   AutoCAD Command Bridge - Publish Script
echo ============================================
echo.

set OUTPUT_DIR=publish
set CONFIG=Release

:: Clean previous publish
if exist %OUTPUT_DIR% rd /s /q %OUTPUT_DIR%
mkdir %OUTPUT_DIR%
mkdir %OUTPUT_DIR%\autocad-plugin
mkdir %OUTPUT_DIR%\client

echo Building and publishing...
echo.

:: Build solution
call build.bat
if errorlevel 1 exit /b 1

:: Publish AutoCAD plugin
echo Publishing AutoCAD plugin...
dotnet publish src\FeatureMillwork.CommandBridge.AutoCAD\FeatureMillwork.CommandBridge.AutoCAD.csproj -c %CONFIG% -o %OUTPUT_DIR%\autocad-plugin --no-build
echo.

:: Publish Client as self-contained
echo Publishing Client application (self-contained)...
dotnet publish src\FeatureMillwork.CommandBridge.Client\FeatureMillwork.CommandBridge.Client.csproj -c %CONFIG% -r win-x64 --self-contained true -o %OUTPUT_DIR%\client
echo.

:: Copy LISP files
echo Copying LISP scripts...
copy bridge.lsp %OUTPUT_DIR%\ >nul 2>&1
copy test-bridge.lsp %OUTPUT_DIR%\ >nul 2>&1

echo ============================================
echo   PUBLISH COMPLETE
echo ============================================
echo.
echo Published to: %OUTPUT_DIR%\
echo.
echo Contents:
echo   autocad-plugin\  - AutoCAD .NET plugin (NETLOAD this)
echo   client\          - Standalone monitoring application
echo   *.lsp            - AutoLISP scripts
echo.

pause
