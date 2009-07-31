@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing release BDiff / BPatch.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2008
@rem
@rem v1.0 of 18 Sep 2007 - First version.
@rem v1.1 of 07 Apr 2008 - Updated to work with renamed BPtch (from BPatch).
@rem                     - Now copy .res files from Bin directories.
@rem v1.2 of 14 Aug 2008 - Changed back to work "unrenamed" BPatch.
@rem ---------------------------------------------------------------------------

@echo off

setlocal

rem tidy up source files

call Tidy.bat

cd ..

set OutFile=Release\dd-bdiff.zip

rem Delete any existing binary release zip file
if exist %OutFile% del %OutFile%

rem Store exe files in zip file root
zip -j -9 %OutFile% Exe\*.exe

rem Copy all current source files except .dsk files to Src sub directory
zip -r -9 %OutFile% Src
zip -d %OutFile% *.dsk

rem Copy .res files to Bin directory
zip -r -9 %OutFile% Bin\BDiff\*.res
zip -r -9 %OutFile% Bin\BPatch\*.res

rem Copy license and readme files to root
zip -j -9 %OutFile% Docs\README Docs\LICENSE

rem Copy other docs to docs sub-directory
zip -r -9 %OutFile% Docs\BDiff.txt Docs\BPatch.txt
zip -r -9 %OutFile% Docs\PasTrans.txt Docs\ChangeLog.txt

rem Copy test code
zip -r -9 %OutFile% Test

endlocal
