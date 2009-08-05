# ------------------------------------------------------------------------------
# Common.mak
#
# Common code for inclusion in all make files. Defines common macros and rules.
# Files that require Common.mak must include it using the !include directive.
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
# ------------------------------------------------------------------------------


# Requires that the BIN macro is defined to point to directory that is to
# receive .res and .dcu output.

# The preferred compiler is Delphi 7. If the DELPHI7 evironment variable is set,
# it will be used and expected to Delphi 7 install directory.
# If DELPHI7 is not set then the DELPHIROOT environment variable is examined.
# This can be set to any Delphi compiler (should compile if later than Delphi
# 7). If neither DELPHI7 nor DELPHIROOT is set then a Delphi compiler is
# expected to be present on the system path.
!ifdef DELPHI7
DELPHIROOT = $(DELPHI7)
!endif

# Define macros that access required build tools
# We use same version of MAKE as that used to build this file
MAKE = "$(MAKEDIR)\Make.exe" -$(MAKEFLAGS)
# If DELPHIROOT set assume DCC32 and BRCC32 are in the Bin sub-directory of root
# directory, otherwise assume the tools are on the path
!ifdef DELPHIROOT
DCC32 = "$(DELPHIROOT)\Bin\DCC32.exe"
BRCC32 = "$(DELPHIROOT)\Bin\BRCC32.exe"
!else
DCC32 = DCC32.exe
BRCC32 = BRCC32.exe
!endif
# If VIEDROOT is set then use that directory for VIEd, otherwise assume VIEd is
# on the path
!ifdef VIEDROOT
VIED = "$(VIEDROOT)\VIEd.exe" -makerc
!else
VIED = VIEd.exe -makerc
!endif
# If ZIPROOT is set then use that directory for Zip, otherwise assume Zip is on
# the path
!ifdef ZIPROOT
ZIP = $(ZIPROOT)\Zip.exe
!else
ZIP = Zip.exe
!endif

# Implicit rules
# Delphi projects are assumed to contain required output and search path
# locations in the project options .cfg file.
.dpr.exe:
  @echo +++ Compiling Delphi Project $< +++
  @$(DCC32) $< -B

# Resource files are compiled to the directory specified by BIN macro, which
# must have been set by the caller.
.rc.res:
  @echo +++ Compiling Resource file $< +++
  @$(BRCC32) $< -fo$(BIN)\$(@F)

# Version info files are compiled by VIEd. A temporary .rc file is left behind
.vi.rc:
  @echo +++ Compiling Version Info file $< +++
  @$(VIED) .\$<

