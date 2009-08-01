@rem ---------------------------------------------------------------------------
@rem Script used to run tests on BDiff and BPatch.
@rem
@rem See file ReadMe.txt for a description of available tests and requirements.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2009
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------


@echo off

setlocal 

rem Get directory containing BDiff and BPatch
set ExeDir=..\Exe
if not "%BDIFFPATH%" == "" set ExeDir=%BDIFFPATH%
rem Record path to BDiff and BPatch
set BDiff=%ExeDir%\BDiff.exe
set BPatch=%ExeDir%\BPatch.exe

rem Clear error message
set ErrorMsg=

rem Decide which test to run from command line
if "%1" == "" goto usage
if "%1" == "patch" goto DoPatchTest
if "%1" == "quoted" goto DoQuotedTest
if "%1" == "filtered" goto DoFilteredTest
if "%1" == "version" goto DoVersionTest
if "%1" == "clean" goto DoClean
set ErrorMsg=Unknown test "%1".
goto usage

rem Run patch test
:DoPatchTest
echo --- Creating Patch with bdiff ---
%BDiff% Test1 Test2 --output=Patch --verbose -b
if errorlevel 1 set ErrorMsg=BDiff failed
if not "%ErrorMsg%"=="" goto error
echo.
echo --- Applying Patch with bpatch ---
%BPatch% Test1 Test3 --input=Patch
if errorlevel 1 set ErrorMsg=BPatch failed
if not "%ErrorMsg%"=="" goto error
echo.
echo --- Testing patched file against original with fc ---
rem fc %Test%\Test2 %Test%\Test3
fc Test2 Test3
echo.
goto end

rem Run quoted diff test
:DoQuotedTest
%BDiff% --format=quoted --verbose Test1 Test2 >Diff
if errorlevel 1 set ErrorMsg=BDiff failed
if not "%ErrorMsg%"=="" goto error
Notepad Diff
goto end

rem Run filtered diff test
:DoFilteredTest
%BDiff% --format=filtered --verbose Test1 Test2 >Diff
if errorlevel 1 set ErrorMsg=BDiff failed
if not "%ErrorMsg%"=="" goto error
Notepad Diff
goto end

rem Run version number test
:DoVersionTest
%BDiff% --version
if errorlevel 1 set ErrorMsg=BDiff failed
if not "%ErrorMsg%"=="" goto error
%BPatch% --version
if errorlevel 1 set ErrorMsg=BPatch failed
if not "%ErrorMsg%"=="" goto error
goto end

rem Remove generated files
:DoClean
del Test3 2>nul
del Diff 2>nul
del Patch 2>nul
goto end

:usage
if not "%ErrorMsg%" == "" echo *** ERROR: %ErrorMsg%
echo Usage is:
echo   test.bat patch - test binary patching
echo   test.bat quoted - create quoted text diff and display it
echo   test.bat filtered - create filtered text diff and display it
echo   test.bat version - display version information for BDiff and BPatch
echo   test.bat clean - remove all generated files
echo For more information see ReadMe.txt
goto end

:error
echo.
echo *** ERROR: %ErrorMsg%
echo.

:end
echo Done

endlocal
