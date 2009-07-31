@rem ---------------------------------------------------------------------------
@rem Script used to build resource files for all BDiff/BPatch applications.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2008
@rem
@rem v1.0 of 16 Sep 2007 - First version.
@rem v1.1 of 07 Apr 2008 - Modified to work with BPtch renamed from BPatch.
@rem v1.2 of 14 Aug 2008 - Changed back to work "unrenamed" BPatch.
@rem ---------------------------------------------------------------------------

@echo off

rem Build BDiff resources
setlocal
cd ..\Src\BDiff
call build res
endlocal

rem Build BPatch resources
setlocal
cd ..\Src\BPatch
call build res
endlocal
