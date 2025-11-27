@echo off
echo ========================================
echo AutoCAD 2026 Quick Build
echo ========================================
echo.

:: Find AutoCAD 2026 DLLs
set ACAD_PATH=C:\Program Files\Autodesk\AutoCAD 2026

if not exist "%ACAD_PATH%" (
    echo AutoCAD 2026 not found at default location
    set /p ACAD_PATH="Enter your AutoCAD 2026 path: "
)

echo Using AutoCAD at: %ACAD_PATH%
echo.

:: Create a simplified project file that references AutoCAD DLLs directly
cd autocad-plugin

echo Creating direct reference project file...
(
echo ^<Project Sdk="Microsoft.NET.Sdk"^>
echo   ^<PropertyGroup^>
echo     ^<TargetFramework^>net48^</TargetFramework^>
echo     ^<AssemblyName^>FeatureMillwork.CommandBridge^</AssemblyName^>
echo     ^<RootNamespace^>FeatureMillwork.CommandBridge^</RootNamespace^>
echo   ^</PropertyGroup^>
echo   ^<ItemGroup^>
echo     ^<Reference Include="AcDbMgd"^>
echo       ^<HintPath^>%ACAD_PATH%\acdbmgd.dll^</HintPath^>
echo       ^<Private^>False^</Private^>
echo     ^</Reference^>
echo     ^<Reference Include="AcMgd"^>
echo       ^<HintPath^>%ACAD_PATH%\acmgd.dll^</HintPath^>
echo       ^<Private^>False^</Private^>
echo     ^</Reference^>
echo     ^<Reference Include="AcCoreMgd"^>
echo       ^<HintPath^>%ACAD_PATH%\accoremgd.dll^</HintPath^>
echo       ^<Private^>False^</Private^>
echo     ^</Reference^>
echo   ^</ItemGroup^>
echo   ^<ItemGroup^>
echo     ^<PackageReference Include="Newtonsoft.Json" Version="13.0.3" /^>
echo   ^</ItemGroup^>
echo ^</Project^>
) > FeatureMillwork.CommandBridge.csproj

echo Building plugin...
dotnet restore
dotnet build -c Release

if errorlevel 1 (
    echo.
    echo Build failed. Trying without Newtonsoft.Json...
    :: Remove JSON serialization for simpler build
    echo You may need to install Visual Studio 2022 with .NET desktop development workload
    pause
    exit /b 1
)

echo.
echo Build successful!
echo DLL Location: %cd%\bin\Release\FeatureMillwork.CommandBridge.dll
echo.
echo To use in AutoCAD 2026:
echo 1. Start AutoCAD
echo 2. Type: NETLOAD
echo 3. Browse to the DLL shown above
echo 4. Type: STARTBRIDGE
echo.
pause