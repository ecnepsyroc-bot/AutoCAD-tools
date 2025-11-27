@echo off
echo ========================================
echo DEBUG BUILD - SHOW ALL ERRORS
echo ========================================
echo.

cd autocad-plugin

echo Current directory:
cd
echo.

echo Files in this directory:
dir *.csproj
echo.

echo Building with detailed output...
dotnet build FeatureMillwork.CommandBridge.csproj -c Release -v normal

echo.
echo ========================================
echo Checking for DLL in all possible locations:
echo ========================================
dir /s /b *.dll 2>nul

pause