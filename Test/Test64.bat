@rem ---------------------------------------------------------------------------
@rem Script used to run tests on the 64 bit versions of BDiff and BPatch from
@rem their default compiler build directory.
@rem
@rem See file ReadMe.md for a description of available tests and requirements.
@rem ---------------------------------------------------------------------------


@echo off

setlocal

set BDIFFPATH=..\_build\Win64\exe
call Test %*

endlocal
