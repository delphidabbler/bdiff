@rem ---------------------------------------------------------------------------
@rem Script used to delete temp and backup source files in BDiff / BPatch source
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 16 Sep 2007 - Original version.
@rem ---------------------------------------------------------------------------

@echo off

setlocal

set SrcDir=..\Src
set DocsDir=..\Docs

echo Deleting *.~* from "%SrcDir%" and subfolders
del /S %SrcDir%\*.~* 
echo.

echo Deleting *.~* from "%DocsDir%" and subfolders
del /S %DocsDir%\*.~*
echo.

echo Done

endlocal
