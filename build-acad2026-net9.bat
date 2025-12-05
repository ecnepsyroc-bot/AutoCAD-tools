@echo off
echo ========================================
echo AutoCAD 2026 (.NET Core) Build
echo ========================================
echo.
echo Building Command Bridge System...
echo.

echo 1. Building Backend (CommandBridgePlugin)...
dotnet build "Command Bridge\rami\autocad\CommandBridgePlugin\CommandBridgePlugin.csproj" -c Release

if errorlevel 1 (
    echo.
    echo Backend Build Failed!
    pause
    exit /b 1
)

echo.
echo 2. Building Frontend (Luxify.Bridge)...
dotnet build "Luxify\Luxify.Bridge\Luxify.Bridge.csproj" -c Debug

if errorlevel 1 (
    echo.
    echo Frontend Build Failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.
echo Backend DLL: %cd%\Command Bridge\rami\autocad\CommandBridgePlugin\bin\Release\net8.0\FeatureMillwork.CommandBridge.dll
echo Frontend DLL: %cd%\Luxify\Luxify.Bridge\bin\Debug\net8.0-windows\Luxify.Bridge.dll
echo.
echo Installation in AutoCAD 2026:
echo --------------------------------
echo 1. Start AutoCAD 2026
echo 2. Type: NETLOAD
echo 3. Load the Backend DLL
echo 4. Load the Frontend DLL
echo 5. Type: BRIDGE-UI
echo.
pause