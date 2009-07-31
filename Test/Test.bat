@rem ---------------------------------------------------------------------------
@rem Script used to create and test patch files created by BDiff and applied by
@rem BPatch.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2008
@rem
@rem Requires files named Test1 and Test2 in same directory as batch file. These
@rem files should be different.
@rem Also requires that BDiff.exe and BPatch.exe should be located in the
@rem ..\Exe directory, relative to the location of Test.bat.
@rem 
@rem Runs BDiff on Test1 and Test2 to create patch file Patch. Then runs BPatch
@rem on Test1 and Patch to create Test3 which should be a recreation of Test2.
@rem Finally runs Windows' FC command on Test2 and Test3 to check they are same.
@rem
@rem v1.0 of 18 Sep 2007 - First version.
@rem v1.1 of 07 Apr 2008 - Revised to work with BPtch renamed from BPatch.
@rem v1.2 of 14 Aug 2008 - Revised to work with "unrenamed" BPatch.
@rem                     - Forced to work with exe files from Exe folder,
@rem                       preventing calling of any other versions on path.
@rem ---------------------------------------------------------------------------


@echo off

setlocal 

cd ..\Exe
set ErrorMsg=
set BDiff=..\Exe\BDiff.exe
set BPatch=..\Exe\BPatch.exe
set Test=..\Test

echo --- Creating Patch with bdiff ---
%BDiff% %Test%\Test1 %Test%\Test2 --output=%Test%\Patch --verbose -b
if errorlevel 1 set ErrorMsg=BDiff failed
if not "%ErrorMsg%"=="" goto error
echo.

echo --- Applying Patch with bpatch ---
%BPatch% %Test%\Test1 %Test%\Test3 --input=%Test%\Patch
if errorlevel 1 set ErrorMsg=BaPtch failed
if not "%ErrorMsg%"=="" goto error
echo.

echo --- Testing patched file against original with fc ---
fc %Test%\Test2 %Test%\Test3
echo.

goto end

:error
echo.
echo *** ERROR: %ErrorMsg%
echo.

:end
echo Done

endlocal
