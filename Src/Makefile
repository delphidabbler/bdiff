# ------------------------------------------------------------------------------
# Makefile for the whole project.
#
# Usage:
#   Run one of the following commands on the same directory as this file:
#     Make
#     Make everything
#       Configures ready for building, builds executable (resource and pascal)
#       Cleans up and creates release files
#     Make config
#       Configure source directories and creates binary output directories
#     Make exe
#     Make all
#       Builds both executables: same as Make res followed by Make pascal
#     Make res
#       Builds all resources.
#     Make pascal
#     Make pas
#       Builds all pascal files. Requires resources to have been built.
#     Make clean
#     Make tidy
#       Cleans up temporary files.
#     Make release
#       Creates binary release file.
# ------------------------------------------------------------------------------


!include "Common.mak"

# Default is to config, create executable and create release file
everything: config exe release

# Synonyms
tidy: clean
pas: pascal
all: exe

# Build executables
exe: res pascal

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
  @cd ..
  -@del *.~* /S 2>nul
  @cd Src
  @echo Done.

# Build release files (.zip)
!ifndef RELEASEFILENAME
RELEASEFILENAME = dd-bdiff
!endif
OUTFILE = Release\$(RELEASEFILENAME).zip
release: clean
  @echo.
  @echo Creating Release File
  @echo ---------------------
  @cd ..
  -@if exist $(OUTFILE) del $(OUTFILE)
  # Store exe files in zip file root
  @$(ZIP) -j -9 $(OUTFILE) Exe\*.exe
  # Copy license and readme files to root
  @$(ZIP) -j -9 $(OUTFILE) README.md LICENSE.md CHANGELOG.txt
  # Copy other docs to docs sub-directory
  @$(ZIP) -r -9 $(OUTFILE) Docs\BDiff.txt
  @$(ZIP) -r -9 $(OUTFILE) Docs\BPatch.txt
  # Copy test code
  @$(ZIP) -r -9 $(OUTFILE) Test
  @cd Src

# Configure source code ready for compilation
config:
  @echo.
  @echo Configuring
  @echo -----------
  @echo Creating empty output directories
  -@if not exist ..\Exe md ..\Exe
  @del ..\Exe\*.* /Q /S /F
  -@if not exist ..\Release md ..\Release
  @del ..\Release\*.* /Q /S /F
  -@if not exist ..\Bin md ..\Bin
  @del ..\Bin\*.* /Q /S /F
  -@if not exist ..\Bin\BDiff md ..\Bin\BDiff
  -@if not exist ..\Bin\BPatch md ..\Bin\BPatch
  @echo Creating .cfg and .dof files
  @cd BDiff
  @$(MAKE) -f BDiff.mak config >nul
  @cd ..\BPatch
  @$(MAKE) -f BPatch.mak config >nul
  @cd ..
