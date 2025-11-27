@echo off
echo ========================================
echo AutoCAD Command Bridge Installation
echo ========================================
echo.

:: Auto-detect AutoCAD installation
echo Detecting AutoCAD installation...
set ACAD_FOUND=0

:: Check for different AutoCAD versions (newest first)
for %%v in (2026 2025 2024 2023) do (
    if exist "C:\Program Files\Autodesk\AutoCAD %%v" (
        set ACAD_PATH="C:\Program Files\Autodesk\AutoCAD %%v"
        set ACAD_VERSION=%%v
        set ACAD_FOUND=1
        goto :found
    )
)

:: Also check Program Files (x86)
for %%v in (2026 2025 2024 2023) do (
    if exist "C:\Program Files (x86)\Autodesk\AutoCAD %%v" (
        set ACAD_PATH="C:\Program Files (x86)\Autodesk\AutoCAD %%v"
        set ACAD_VERSION=%%v
        set ACAD_FOUND=1
        goto :found
    )
)

:found
if %ACAD_FOUND%==0 (
    echo ERROR: AutoCAD not found in standard locations!
    echo.
    echo Please enter your AutoCAD installation path:
    set /p ACAD_PATH="Path (e.g., C:\Program Files\Autodesk\AutoCAD 2026): "
    set ACAD_VERSION=Custom
) else (
    echo Found AutoCAD %ACAD_VERSION% at %ACAD_PATH%
)

echo.echo Step 1: Building AutoCAD Plugin
echo --------------------------------
cd autocad-plugin

:: Check if .NET SDK is installed
where dotnet >nul 2>&1
if errorlevel 1 (
    echo ERROR: .NET SDK not found!
    echo Please install from: https://dotnet.microsoft.com/download
    echo.
    echo Alternatively, you can use the pre-built DLL if available.
    pause
    exit /b 1
)

:: Build the .NET plugin
echo Building CommandMonitor.dll...
dotnet build -c Release
if errorlevel 1 (
    echo Build failed! Checking for common issues...
    echo.
    echo Possible solutions:
    echo 1. Install .NET Framework 4.8 Developer Pack
    echo 2. Install AutoCAD ObjectARX SDK
    echo 3. Check if Newtonsoft.Json NuGet package needs to be restored
    echo.
    echo Trying to restore packages...
    dotnet restore
    dotnet build -c Release
    
    if errorlevel 1 (
        echo.
        echo Build still failing. Please check error messages above.
        pause
        exit /b 1
    )
)

echo.
echo Step 2: Deploying to AutoCAD
echo --------------------------------
set DLL_PATH=%cd%\bin\Release\FeatureMillwork.CommandBridge.dll

if not exist "%DLL_PATH%" (
    echo ERROR: DLL not found at %DLL_PATH%
    echo Checking for .NET 6+ output location...
    set DLL_PATH=%cd%\bin\Release\net48\FeatureMillwork.CommandBridge.dll
)

echo DLL Path: %DLL_PATH%
:: Create autoload folder if it doesn't exist
if not exist "%APPDATA%\Autodesk\ApplicationPlugins\FeatureMillwork.bundle" (
    mkdir "%APPDATA%\Autodesk\ApplicationPlugins\FeatureMillwork.bundle"
    mkdir "%APPDATA%\Autodesk\ApplicationPlugins\FeatureMillwork.bundle\Contents"
)

:: Copy DLL to plugin folder
echo Copying DLL to AutoCAD plugins...
copy "%DLL_PATH%" "%APPDATA%\Autodesk\ApplicationPlugins\FeatureMillwork.bundle\Contents\" /Y

:: Create PackageContents.xml for autoloading (works with 2023-2026)
echo Creating autoload configuration...
(
echo ^<?xml version="1.0" encoding="utf-8"?^>
echo ^<ApplicationPackage SchemaVersion="1.0"^>
echo   ^<Name^>FeatureMillwork Command Bridge^</Name^>
echo   ^<Description^>Real-time AutoCAD command monitoring^</Description^>
echo   ^<Author^>Feature Millwork^</Author^>
echo   ^<Version^>1.0.0^</Version^>
echo   ^<Components^>
echo     ^<RuntimeRequirements SeriesMax="R26.0" SeriesMin="R23.0" /^>
echo     ^<ComponentEntry^>
echo       ^<ComponentName^>FeatureMillwork.CommandBridge^</ComponentName^>
echo       ^<ComponentType^>Command^</ComponentType^>
echo       ^<LoadOnAutoCADStartup^>True^</LoadOnAutoCADStartup^>
echo       ^<ModuleName^>./Contents/FeatureMillwork.CommandBridge.dll^</ModuleName^>
echo     ^</ComponentEntry^>
echo   ^</Components^>
echo ^</ApplicationPackage^>
) > "%APPDATA%\Autodesk\ApplicationPlugins\FeatureMillwork.bundle\PackageContents.xml"

echo.
echo Step 3: Installing VS Code Extension
echo --------------------------------
cd ..\vscode-extension

:: Check if npm is installed
where npm >nul 2>&1
if errorlevel 1 (
    echo WARNING: npm not found!
    echo VS Code extension requires Node.js/npm
    echo Download from: https://nodejs.org/
    echo.
    echo Skipping VS Code extension setup...
) else (
    if exist node_modules (
        echo Node modules already installed, skipping...
    ) else (
        echo Installing dependencies...
        npm install
    )
)
echo.
echo Step 4: Creating VS Code Launch Configuration
echo --------------------------------
cd ..
if not exist ".vscode" mkdir ".vscode"

(
echo {
echo   "version": "0.2.0",
echo   "configurations": [
echo     {
echo       "type": "extensionHost",
echo       "request": "launch",
echo       "name": "Launch Extension",
echo       "runtimeExecutable": "${execPath}",
echo       "args": [
echo         "--extensionDevelopmentPath=${workspaceFolder}/vscode-extension"
echo       ]
echo     }
echo   ]
echo }
) > ".vscode\launch.json"

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Detected: AutoCAD %ACAD_VERSION%
echo.
echo Next Steps:
echo 1. Start AutoCAD %ACAD_VERSION%
echo 2. The plugin should autoload, but if not:
echo    - Run command: NETLOAD
echo    - Select: %DLL_PATH%
echo 3. Run command: STARTBRIDGE
echo 4. Open VS Code in this folder
echo 5. Press F5 to launch extension
echo 6. Press Ctrl+Shift+M for monitor panel
echo.
echo Quick Test:
echo - In AutoCAD: Run TESTBRIDGE
echo - In VS Code: You should see the test message
echo.
echo For badge development:
echo - Load test-bridge.lsp
echo - Run TESTALL for complete test suite
echo.
pause