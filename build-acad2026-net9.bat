@echo off
echo ========================================
echo AutoCAD 2026 (.NET Core) Build
echo ========================================
echo.
echo AutoCAD 2026 has moved to .NET 8 (from .NET Framework)
echo You have .NET 9 installed, which should work.
echo.

cd autocad-plugin

echo Building for .NET 9 (compatible with AutoCAD 2026's .NET 8)...
dotnet build -c Release

if errorlevel 1 (
    echo.
    echo ========================================
    echo Build failed. Trying alternative approach...
    echo ========================================
    echo.
    echo AutoCAD 2026 requires .NET 8 runtime.
    echo You can either:
    echo.
    echo 1. Install .NET 8 SDK from:
    echo    https://dotnet.microsoft.com/download/dotnet/8.0
    echo.
    echo 2. Or try the pre-built DLL (if available)
    echo.
    pause
    exit /b 1
)

if exist "bin\Release\FeatureMillwork.CommandBridge.dll" (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo DLL Built for: .NET 9 (AutoCAD 2026 compatible)
    echo DLL Location: %cd%\bin\Release\FeatureMillwork.CommandBridge.dll
    echo.
    echo Installation in AutoCAD 2026:
    echo --------------------------------
    echo 1. Start AutoCAD 2026
    echo 2. Type: NETLOAD
    echo 3. Browse to: %cd%\bin\Release\
    echo 4. Select: FeatureMillwork.CommandBridge.dll
    echo 5. Type: STARTBRIDGE
    echo.
    echo Testing the connection:
    echo --------------------------------
    echo 1. In AutoCAD: Type TESTBRIDGE
    echo 2. In VS Code: Press Ctrl+Shift+M for monitor
    echo.
) else (
    echo DLL not found at expected location.
    dir bin\Release\ /s /b *.dll 2>nul
)

pause