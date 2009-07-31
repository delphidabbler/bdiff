# ------------------------------------------------------------------------------
# BDiff.mak
#
# Makefile for BDiff.
#
# Usage:
#   Run one of the following commands on the same directory as this file:
#     Make -f BDiff.mak pascal | Make -f BDiff.mak pas
#       Builds all pascal files. Requires resources to have been built.
#     Make -f BDiff.mak res
#       Builds all resources.
#     Make -f BDiff.mak exe | Make -f BDiff.mak 
#       Builds the executable file: builds resources and pascal.
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


!include "..\Common.mak"

# Define location of Bin directory relative to Src\BDiff
BIN = ..\..\Bin\BDiff

# Default is to build all
exe: res pascal

# Synonyms
pas: pascal

# Build resources and delete intermediate file created by VIED
res : BDiff.res VBDiff.res
  -@del VBDiff.rc 

# Build pascal source and link in resources
pascal: BDiff.exe
