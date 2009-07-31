@rem ---------------------------------------------------------------------------
@rem Script used to build all BDiff/BPatch applications.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 16 Sep 2007 - First version.
@rem ---------------------------------------------------------------------------

@echo off

setlocal

rem First build binary resource files
:Build_Resources
call BuildResources.bat

rem Next build pascal files (requires resource file to exist)
:Build_Pascal
call BuildPascal.bat

endlocal
