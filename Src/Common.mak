# ------------------------------------------------------------------------------
# Common code for inclusion in all make files. Defines common macros and rules.
# Files that require Common.mak must include it using the !include directive.
# ------------------------------------------------------------------------------


# Requires that the BIN macro is defined to point to directory that is to
# receive .res and .dcu output.

# The DELPHIROOT environment variable must be set and must reference the install
# directory of the version of Delphi being used. Delphi XE is the recommended
# compiler, but other Unicode versions of the compiler may be able to be used.

!ifndef DELPHIROOT
!error DELPHIROOT environment variable required.
!endif

# Define macros that access required build tools
# We use same version of MAKE as that used to build this file
MAKE = "$(MAKEDIR)\Make.exe" -$(MAKEFLAGS)
DCC32 = "$(DELPHIROOT)\Bin\DCC32.exe"
BRCC32 = "$(DELPHIROOT)\Bin\BRCC32.exe"

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

