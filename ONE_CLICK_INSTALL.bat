@echo off
cls
echo ========================================
echo ONE-CLICK AUTOCAD 2026 BRIDGE INSTALLER
echo ========================================
echo.
echo This script will do EVERYTHING automatically:
echo - Check your system
echo - Install what's needed
echo - Build the plugin
echo - Tell you exactly what to do
echo.
pause

:: Step 1: Check if .NET 8 is installed
echo.
echo [1/4] Checking for .NET 8 SDK...
dotnet --list-sdks | findstr "8.0" >nul 2>&1
if errorlevel 1 (
    echo .NET 8 not found. Installing now...
    echo.
    powershell -Command "Start-Process winget -ArgumentList 'install','Microsoft.DotNet.SDK.8','-e','--silent' -Wait"
    echo .NET 8 SDK installed!
) else (
    echo .NET 8 SDK already installed!
)

:: Step 2: Navigate to plugin folder
echo.
echo [2/4] Setting up build environment...
cd /d "G:\My Drive\_Feature\_Millwork_Projects\autocad-command-bridge\autocad-plugin"

:: Step 3: Create a SIMPLE project file that JUST WORKS
echo.
echo [3/4] Creating build configuration...
(
echo ^<Project Sdk="Microsoft.NET.Sdk"^>
echo   ^<PropertyGroup^>
echo     ^<TargetFramework^>net8.0^</TargetFramework^>
echo     ^<AssemblyName^>CommandBridge^</AssemblyName^>
echo   ^</PropertyGroup^>
echo   ^<ItemGroup^>
echo     ^<Reference Include="acdbmgd"^>
echo       ^<HintPath^>C:\Program Files\Autodesk\AutoCAD 2026\acdbmgd.dll^</HintPath^>
echo       ^<Private^>False^</Private^>
echo     ^</Reference^>
echo     ^<Reference Include="acmgd"^>
echo       ^<HintPath^>C:\Program Files\Autodesk\AutoCAD 2026\acmgd.dll^</HintPath^>
echo       ^<Private^>False^</Private^>
echo     ^</Reference^>
echo     ^<Reference Include="accoremgd"^>
echo       ^<HintPath^>C:\Program Files\Autodesk\AutoCAD 2026\accoremgd.dll^</HintPath^>
echo       ^<Private^>False^</Private^>
echo     ^</Reference^>
echo   ^</ItemGroup^>
echo ^</Project^>
) > Simple.csproj

:: Step 4: Build it
echo.
echo [4/4] Building plugin...
dotnet build Simple.csproj -c Release

:: Check if it worked
if exist "bin\Release\net8.0\CommandBridge.dll" (
    cls
    echo ========================================
    echo          SUCCESS! ALL DONE!
    echo ========================================
    echo.
    echo The plugin is built and ready!
    echo.
    echo NOW DO THIS IN AUTOCAD 2026:
    echo --------------------------------
    echo 1. Open AutoCAD 2026
    echo 2. Type: NETLOAD [press Enter]
    echo 3. Browse to this file:
    echo.
    echo    %cd%\bin\Release\net8.0\CommandBridge.dll
    echo.
    echo 4. Type: STARTBRIDGE [press Enter]
    echo.
    echo THAT'S IT! The bridge is running!
    echo.
    echo To test: Type TESTBRIDGE in AutoCAD
    echo ========================================
) else (
    echo.
    echo ========================================
    echo Something went wrong...
    echo ========================================
    echo Let's try a different approach.
    echo Contact support or try manually building.
)

echo.
pause