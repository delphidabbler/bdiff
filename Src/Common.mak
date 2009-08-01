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

# DELPHIROOT must point to the install directory for Delphi 7. The preferred
# option is for user to define this in the DELPHI7 environment variable or to
# directly define DELPHIROOT. If neither DELPHIROOT nor DELPHI2006 is defined
# the directory is calculated from Make's directory. In this latter case it is
# important to ensure it is the Delphi 7 version of Make that is used.
!ifndef DELPHIROOT
!ifdef DELPHI7
DELPHIROOT = $(DELPHI7)
!else
DELPHIROOT = $(MAKEDIR)\..
!endif
!endif

# Define macros that access required build tools
# MAKE, DCC32 and BRCC32 should be in same sub-directory of Delphi 7
MAKE = "$(DELPHIROOT)\Bin\Make.exe" -$(MAKEFLAGS)
DCC32 = "$(DELPHIROOT)\Bin\DCC32.exe"
BRCC32 = "$(DELPHIROOT)\Bin\BRCC32.exe"
# VIED is expected to be on the path
VIED = "VIEd.exe" -makerc

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
  @$(VIED) $<

