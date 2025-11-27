@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   AutoCAD Command Bridge - Build Script
echo   C# Migration (v2.0)
echo ============================================
echo.

:: Check for .NET SDK
where dotnet >nul 2>&1
if errorlevel 1 (
    echo ERROR: .NET SDK not found. Please install .NET 8.0 SDK.
    echo Download from: https://dotnet.microsoft.com/download/dotnet/8.0
    pause
    exit /b 1
)

:: Get .NET version
for /f "tokens=*" %%i in ('dotnet --version') do set DOTNET_VERSION=%%i
echo .NET SDK Version: %DOTNET_VERSION%
echo.

:: Set build configuration
set CONFIG=Release
if "%1"=="debug" set CONFIG=Debug
if "%1"=="Debug" set CONFIG=Debug

echo Building in %CONFIG% mode...
echo.

:: Restore packages
echo [1/4] Restoring NuGet packages...
dotnet restore FeatureMillwork.CommandBridge.sln
if errorlevel 1 (
    echo ERROR: Package restore failed.
    pause
    exit /b 1
)
echo.

:: Build Shared library
echo [2/4] Building Shared library...
dotnet build src\FeatureMillwork.CommandBridge.Shared\FeatureMillwork.CommandBridge.Shared.csproj -c %CONFIG% --no-restore
if errorlevel 1 (
    echo ERROR: Shared library build failed.
    pause
    exit /b 1
)
echo.

:: Build AutoCAD plugin
echo [3/4] Building AutoCAD plugin...
dotnet build src\FeatureMillwork.CommandBridge.AutoCAD\FeatureMillwork.CommandBridge.AutoCAD.csproj -c %CONFIG% --no-restore
if errorlevel 1 (
    echo ERROR: AutoCAD plugin build failed.
    pause
    exit /b 1
)
echo.

:: Build WPF Client
echo [4/4] Building WPF Client application...
dotnet build src\FeatureMillwork.CommandBridge.Client\FeatureMillwork.CommandBridge.Client.csproj -c %CONFIG% --no-restore
if errorlevel 1 (
    echo ERROR: Client application build failed.
    pause
    exit /b 1
)
echo.

echo ============================================
echo   BUILD SUCCESSFUL
echo ============================================
echo.
echo Output locations:
echo   AutoCAD Plugin: src\FeatureMillwork.CommandBridge.AutoCAD\bin\%CONFIG%\net8.0-windows\
echo   Client App:     src\FeatureMillwork.CommandBridge.Client\bin\%CONFIG%\net8.0-windows\
echo.
echo Next steps:
echo   1. In AutoCAD: NETLOAD the plugin DLL
echo   2. In AutoCAD: Run STARTBRIDGE
echo   3. Launch the Client application
echo.

pause
