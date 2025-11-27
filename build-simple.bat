@echo off
echo ========================================
echo Building for AutoCAD 2026
echo ========================================
echo.

cd autocad-plugin

:: Add nuget.org as a source if needed
echo Ensuring NuGet sources are configured...
dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org 2>nul

echo Building plugin...
dotnet restore
dotnet build -c Release

if errorlevel 1 (
    echo.
    echo Build failed. Trying without package restore...
    dotnet build -c Release --no-restore
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