@echo off
echo ========================================
echo FINAL BUILD - FIXED FOR WINDOWS
echo ========================================
echo.

cd autocad-plugin

echo Cleaning old builds...
if exist bin rmdir /s /q bin
if exist obj rmdir /s /q obj

echo.
echo Building for AutoCAD 2026 (.NET 8 Windows)...
dotnet build Simple.csproj -c Release

if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.
echo Looking for DLL...
dir bin\Release\*.dll /s /b

echo.
echo ========================================
echo NEXT STEPS IN AUTOCAD 2026:
echo ========================================
echo.
echo 1. Type: NETLOAD
echo 2. Browse to the DLL shown above
echo 3. Type: STARTBRIDGE
echo 4. Type: TESTBRIDGE
echo.
pause