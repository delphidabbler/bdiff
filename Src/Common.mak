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
#
# ------------------------------------------------------------------------------


# Requires that BIN macro is defined to point to required binary directory for
# .res and .dcu output.


# Define DELPHIROOT if not defined externally. Should point to install directory
# for Delphi 7. Preferred option is for user to define this in DELPHI7
# environment variable. If DELPHI7 is not defined the directory is calculated
# from Make's directory
!ifndef DELPHIROOT
!ifdef DELPHI7
DELPHIROOT = $(DELPHI7)
!else
DELPHIROOT = $(MAKEDIR)\..
!endif
!endif

# Define macros that access required programs
# MAKE, DCC32 and BRCC32 should be in same sub-directory of Delphi 7
MAKE = "$(DELPHIROOT)\Bin\Make.exe" -$(MAKEFLAGS) 
DCC32 = "$(DELPHIROOT)\Bin\DCC32.exe"
BRCC32 = "$(DELPHIROOT)\Bin\BRCC32.exe"
# VIED is expected to be on the path
VIED = "VIEd.exe" -makerc

# Implicit rules
# Delphi projects are assumed to contain all required output and search path
# info in project options .cfg file.
.dpr.exe:
  @echo +++ Compiling Delphi Project $< +++
  @$(DCC32) $< -B

# Resource files are compiled to directory specified by BIN macro, which must
# have been set by caller
.rc.res:
  @echo +++ Compiling Resource file $< +++
  @$(BRCC32) $< -fo$(BIN)\$(@F)

# Version info filea are compiled by VIEd: a temporary .rc file is left behind
.vi.rc:
  @echo +++ Compiling Version Info file $< +++
  @$(VIED) $<
