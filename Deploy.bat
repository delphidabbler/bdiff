::! BSD 3-clause license: see LICENSE.md
::
::  Deploy script for BDiff/BPatch.
::
::  This script compiles release versions BDiff, including BDiff & BPatch and
::  places then into a single zip file ready for release.
::
::  This script uses MSBuild and InfoZip's zip.exe. The MSBuild project also
::  requires the DelphiDabbler Version Information Editor.
::
::  Get zip.exe from https://delphidabbler.com/extras/info-zip
::  Get Version Information Editor from https://delphidabbler.com/software/vied

::  To use the script:
::    1) Start the Embarcadero RAD Studio Command Prompt to set the required
::       environment variables for MSBuild.
::    2) Set the BDSBIN variable to %BDS%\bin (required by MSBuild/Delphi).
::    3) Set the ZIPROOT environment variable to the directory where zip.exe is
::       installed.
::    4) Set the VIEDROOT environment variable to the directory where VIEd.exe 
::       is installed.
::    5) Change directory to that where this script is located.
::    6) Run the script.
::
::  Usage:
::    Deploy <version>
::  where
::    <version> is the version number of the release, e.g. 0.5.3-beta or 1.2.0.

@echo off

echo -----------------------
echo Deploying BDiff Release
echo -----------------------

:: Check for required parameter
if "%1"=="" goto paramerror

:: Check for required environment variables
if "%ZipRoot%"=="" goto envvarerror
if "%VIEdRoot%"=="" goto envvarerror

:: Set variables
set Version=%1
set BuildRoot=.\_build
set ExeDir=%BuildRoot%\exe
set ReleaseDir=%BuildRoot%\release
set ZipFile=%ReleaseDir%\bdiff-exe-%Version%.zip
set SrcDir=Src
set DocsDir=Docs

:: Make a clean directory structure
if exist %BuildRoot% rmdir /S /Q %BuildRoot%
mkdir %ReleaseDir%

:: Build Pascal
setlocal
cd %SrcDir%\BDiff
echo.
echo Building BDiff
echo.
msbuild BDiff.dproj /p:config=Base /p:platform=Win32
echo.
endlocal

setlocal
cd %SrcDir%\BPatch
echo.
echo Building BPatch
echo.
msbuild BPatch.dproj /p:config=Base /p:platform=Win32
echo.
endlocal

:: Create zip files
echo.
echo Creating zip files
%ZipRoot%\zip.exe -j -9 %ZipFile% %ExeDir%\BDiff.exe
%ZipRoot%\zip.exe -j -9 %ZipFile% %ExeDir%\BPatch.exe
%ZipRoot%\zip.exe -r -9 %ZipFile% %DocsDir%\BDiff.md
%ZipRoot%\zip.exe -r -9 %ZipFile% %DocsDir%\BPatch.md
%ZipRoot%\zip.exe -j -9 %ZipFile% README.md LICENSE.md CHANGELOG.md
%ZipRoot%\zip.exe -r -9 %ZipFile% Test


del %ReadMe%

echo.
echo ---------------
echo Build completed
echo ---------------

goto end

:: Error messages

:paramerror
echo.
echo ***ERROR: Please specify a version number as a parameter
echo.
goto end

:envvarerror
echo.
echo ***ERROR: ZipRoot and/or VIEdRoot environment variable not set
echo.
goto end

:: End
:end
