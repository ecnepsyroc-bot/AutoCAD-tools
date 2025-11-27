@echo off
echo ========================================
echo SIMPLE BUILD - NO JSON REQUIRED
echo ========================================
echo.
cd autocad-plugin

echo Building simplified version...
dotnet build Simple.csproj -c Release

if exist bin\Release\net8.0\FeatureMillwork.CommandBridge.dll (
    echo.
    echo SUCCESS! DLL at: %cd%\bin\Release\net8.0\FeatureMillwork.CommandBridge.dll
    echo.
    echo In AutoCAD 2026:
    echo 1. NETLOAD (select the DLL above)
    echo 2. STARTBRIDGE
    echo 3. TESTBRIDGE
) else (
    echo.
    echo Checking all locations...
    dir /s /b *.dll 2>nul
)
pause