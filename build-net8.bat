@echo off
echo ========================================
echo Building for AutoCAD 2026 (.NET 8)
echo ========================================
echo.

cd autocad-plugin

echo AutoCAD 2026 uses .NET 8 (not .NET Framework 4.8)
echo Building for .NET 8...
echo.

dotnet build -c Release

if errorlevel 1 (
    echo.
    echo Build failed. Let's try installing .NET 8 SDK...
    echo You may need to download it from:
    echo https://dotnet.microsoft.com/download/dotnet/8.0
    pause
    exit /b 1
)

if exist "bin\Release\FeatureMillwork.CommandBridge.dll" (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo DLL Location: %cd%\bin\Release\FeatureMillwork.CommandBridge.dll
    echo.
    echo Next steps in AutoCAD 2026:
    echo 1. Type: NETLOAD
    echo 2. Browse to the DLL above
    echo 3. Type: STARTBRIDGE
    echo 4. Type: TESTBRIDGE (to test connection)
    echo.
) else (
    echo.
    echo DLL not found. Check build output above.
)

pause