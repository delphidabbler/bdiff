# ------------------------------------------------------------------------------
# Makefile for BDiff.
#
# Usage:
#   Run one of the following commands on the same directory as this file:
#     Make -f BDiff.mak config
#       Configure source folder
#     Make -f BDiff.mak exe
#     Make -f BDiff.mak
#       Builds the executable file: builds resources and pascal.
#     Make -f BDiff.mak res
#       Builds all resources.
#     Make -f BDiff.mak pascal
#     Make -f BDiff.mak pas
#       Builds all pascal files. Requires resources to have been built.
# ------------------------------------------------------------------------------


!include "..\Common.mak"

# Define location of binary output directory relative to Src\BDiff
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

# Configure source folder
config:
  -@del BDiff.cfg
  -@del BDiff.dof
  -@copy BDiff.cfg.tplt BDiff.cfg
  -@copy BDiff.dof.tplt BDiff.dof
