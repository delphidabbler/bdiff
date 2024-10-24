::!  BSD 3-clause license: see LICENSE.md

:: ---------------------------------------------------------------------------
:: Script used to run tests on BDiff and BPatch.
::
:: See file ReadMe.md for a description of available tests and requirements.
:: ---------------------------------------------------------------------------


@echo off

setlocal

:: Ensure error message environment variable is clear

set ErrorMsg=

:: Get directory containing BDiff and BPatch

if "%BDIFFPATH%" == "" (
    set ErrorMsg=BDIFFPATH must be set to directory containing BDiff.exe and BPatch.exe
    goto error
)
set ExeDir=%BDIFFPATH%

:: Record and validate path to BDiff and BPatch

set BDiff="%ExeDir%\BDiff.exe"
set BPatch="%ExeDir%\BPatch.exe"
if not exist %BDiff% (
    set ErrorMsg=BDiff.exe does not exist in %BDIFFPATH%
    goto error
)
if not exist %BPatch% (
    set ErrorMsg=BPatch.exe does not exist in %BDIFFPATH%
    goto error
)

:: Decide which test to run based on 1st command line parameter

if "%1" == "" goto usage
if "%1" == "patch" goto DoPatchTest
if "%1" == "quoted" goto DoQuotedTest
if "%1" == "filtered" goto DoFilteredTest
if "%1" == "version" goto DoVersionTest
if "%1" == "help" goto DoHelpTest
if "%1" == "clean" goto DoClean
set ErrorMsg=Unknown test "%1".
goto usage

:: Run patch tests

:DoPatchTest

:: check which patch test to run
if "%2"=="large" goto DoLargePatchTest

:: do small patch test
echo --- Creating binary Patch with bdiff ---
%BDiff% Test1 Test2 --output=Patch --verbose -b
if errorlevel 1 (
    set ErrorMsg=BDiff failed
    goto error
)
echo.
echo --- Testing Patch against expected Diff-b with fc ---
fc /B Patch Diff-b
echo --- Applying binary Patch with bpatch ---
%BPatch% Test1 Test3 --input=Patch
if errorlevel 1 (
    set ErrorMsg=BPatch failed
    goto error
)
echo.
echo --- Testing restored Test3 file against original with fc ---
fc Test2 Test3
echo.
goto end

:: do large patch test
:DoLargePatchTest
echo --- Creating binary Patch_Large with bdiff ---
%BDiff% Test1_Large Test2_Large --output=Patch_Large --verbose -b
if errorlevel 1 (
    set ErrorMsg=BDiff failed
    goto error
)
echo.
echo --- Applying binary Patch_Large with bpatch ---
%BPatch% Test1_Large Test3_Large --input=Patch_Large
if errorlevel 1 (
    set ErrorMsg=BPatch failed
    goto error
)
echo.
echo --- Testing restored Test3_Large file against original with fc ---
fc Test2_Large Test3_Large
echo.
goto end

:: Run quoted diff test

:DoQuotedTest
echo --- Creating quoted diff of Test1 and Test2 ---
%BDiff% --format=quoted --verbose Test1 Test2 >Diff
if errorlevel 1 (
    set ErrorMsg=BDiff failed
    goto error
)
echo.
echo --- Testing Diff file against expected Diff-q with fc ---
fc Diff Diff-q
if "%2" == "view" Notepad Diff
goto end

:: Run filtered diff test

:DoFilteredTest
echo --- Creating filtered diff of Test1 and Test2 ---
%BDiff% --format=filtered --verbose Test1 Test2 >Diff
if errorlevel 1 (
    set ErrorMsg=BDiff failed
    goto error
)
echo.
echo --- Testing Diff file against expected Diff-f with fc ---
fc Diff Diff-f
if "%2" == "view" Notepad Diff
goto end

:: Run version number test

:DoVersionTest
%BDiff% --version
if errorlevel 1 (
    set ErrorMsg=BDiff failed
    goto error
)
%BPatch% --version
if errorlevel 1 (
    set ErrorMsg=BPatch failed
    goto error
)
goto end

:: Run help screen test

:DoHelpTest
echo BDiff --help
echo ------------
%BDiff% --help
echo.
if errorlevel 1 (
    set ErrorMsg=BDiff failed
    goto error
)
echo.
echo BPatch --help
echo -------------
%BPatch% --help
echo.
if errorlevel 1 (
    set ErrorMsg=BPatch failed
    goto error
)
goto end

:: Remove generated files

:DoClean
del Test3 2>nul
del Test3_Large 2>nul
del Diff 2>nul
del Patch 2>nul
del Patch_Large 2>nul
goto end

:: Display usage information

:usage
if not "%ErrorMsg%" == "" echo *** ERROR: %ErrorMsg%
echo Usage is:
echo   test.bat patch [large]
echo     test binary patching (specify large to use larger test files)
echo   test.bat quoted [view]
echo     test quoted text diff (specify view to display diff in notepad)
echo   test.bat filtered [view]
echo     test filtered text diff (specify view to display diff in notepad)
echo   test.bat version
echo     display version information for BDiff and BPatch
echo   test.bat help
echo     display help screens for BDiff and BPatch
echo   test.bat clean
echo     remove all generated files
echo For more information see Tests\ReadMe.md
goto end

:: Show error message

:error
echo.
echo *** ERROR: %ErrorMsg%
echo.

:: Finished

:end
echo Done

endlocal
