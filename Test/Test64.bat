::!  BSD 3-clause license: see LICENSE.md

:: ---------------------------------------------------------------------------
:: Script used to run tests on the 64 bit versions of BDiff and BPatch from
:: their default compiler build directory.
::
:: See file ReadMe.md for a description of available tests and requirements.
:: ---------------------------------------------------------------------------


@echo off

setlocal

:: Set path to 64 bit exe directory relative to Test directory
set BDIFFPATH=..\_build\Win64\exe

:: Run Test script, passing along all parameters
call Test %*

endlocal
