# ------------------------------------------------------------------------------
# Makefile
#
# Makefile for the whole project.
#
# Usage:
#   Run one of the following commands on the same directory as this file:
#     Make pascal | Make pas
#       Builds all pascal files. Requires resources to have been built.
#     Make res
#       Builds all resources.
#     Make exe | Make all | Make
#       Builds both executables: same as Make res followed by Make pascal
#     Make clean | Make tidy
#       Cleans up temporary files.
#     Make release
#       Creates a zip file containing all files of a release. Cleans temporary
#       files before creating zip.
#
# Copyright (c) 2009 Peter D Johnson (www.delphidabbler.com)
#
# $Rev$
# $Date$
#
# THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY. IN
# NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE USE
# OF THIS SOFTWARE.
#
# For conditions of distribution and use see the LICENSE file of visit
# http://www.delphidabbler.com/software/bdiff/license
#
# ------------------------------------------------------------------------------


!include "Common.mak"

# Default is to build executables
exe: res pascal

# Synonyms
tidy: clean
pas: pascal
all: exe

# Build resources
res:
  @echo.
  @echo Build Resources
  @echo ---------------
  @cd BDiff
  $(MAKE) -f BDiff.mak res
  @cd ..\BPatch
  $(MAKE) -f BPatch.mak res
  @cd ..

# Build pascal code and link in resources
pascal:
  @echo.
  @echo Build Pascal
  @echo ------------
  @cd BDiff
  $(MAKE) -f BDiff.mak pascal
  @cd ..\BPatch
  $(MAKE) -f BPatch.mak pascal
  @cd ..

# Clean up unwanted files etc created by IDE
clean:
  @echo.
  @echo Clean Unwanted Files
  @echo --------------------
  -@cd ..
  -@del *.~* /S 2>nul
  -@cd Src
  @echo Done.

# Build release files (.zip)
OUTFILE = Release\dd-bdiff.zip
release: clean
  @echo.
  @echo Creating Release File
  @echo ---------------------
  -@cd ..
  -@if exist $(OUTFILE) del $(OUTFILE)
  # Store exe files in zip file root
  @zip -j -9 $(OUTFILE) Exe\*.exe
  # Copy all current source files except .dsk files to Src sub directory
  @zip -r -9 $(OUTFILE) Src
  @zip -d $(OUTFILE) *.dsk
  # Copy .res files to Bin directory
  @zip -r -9 $(OUTFILE) Bin\BDiff\*.res
  @zip -r -9 $(OUTFILE) Bin\BPatch\*.res
  # Copy license and readme files to root
  @zip -j -9 $(OUTFILE) Docs\README Docs\LICENSE
  # Copy other docs to docs sub-directory
  @zip -r -9 $(OUTFILE) Docs\BDiff.txt Docs\BPatch.txt
  @zip -r -9 $(OUTFILE) Docs\PasTrans.txt Docs\ChangeLog.txt
  # Copy test code
  @zip -r -9 $(OUTFILE) Test
  -@cd Src
