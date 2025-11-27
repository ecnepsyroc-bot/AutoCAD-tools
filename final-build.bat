@echo off
echo ========================================
echo AutoCAD 2026 (.NET 8) Final Build
echo ========================================
echo.

cd autocad-plugin

:: Clean previous attempts
echo Cleaning previous build attempts...
if exist bin rmdir /s /q bin
if exist obj rmdir /s /q obj

echo.
echo Building for AutoCAD 2026 with .NET 8...
dotnet build FeatureMillwork.CommandBridge.csproj -c Release

if errorlevel 1 (
    echo.
    echo Build failed. Checking .NET SDKs...
    dotnet --list-sdks
    pause
    exit /b 1
)

echo.
if exist "bin\Release\net8.0\FeatureMillwork.CommandBridge.dll" (
    set DLL_PATH=%cd%\bin\Release\net8.0\FeatureMillwork.CommandBridge.dll
) else if exist "bin\Release\FeatureMillwork.CommandBridge.dll" (
    set DLL_PATH=%cd%\bin\Release\FeatureMillwork.CommandBridge.dll
) else (
    echo Searching for DLL...
    dir bin /s /b *.dll
    pause
    exit /b 1
)

echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.
echo DLL Location: %DLL_PATH%
echo.
echo ========================================
echo AUTOCAD 2026 SETUP:
echo ========================================
echo.
echo 1. Start AutoCAD 2026
echo.
echo 2. Type: NETLOAD
echo.
echo 3. Browse to and select:
echo    %DLL_PATH%
echo.
echo 4. Type: STARTBRIDGE
echo    (This starts the monitoring)
echo.
echo 5. Type: TESTBRIDGE  
echo    (This tests the connection)
echo.
pause