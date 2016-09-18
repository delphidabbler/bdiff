# ------------------------------------------------------------------------------
# Makefile for BPatch.
#
# Usage:
#   Run one of the following commands on the same directory as this file:
#     Make -f BPatch.mak config
#       Configure source folder
#     Make -f BPatch.mak exe
#     Make -f BPatch.mak
#       Builds the executable file: builds resources and pascal.
#     Make -f BPatch.mak res
#       Builds all resources.
#     Make -f BPatch.mak pascal
#     Make -f BPatch.mak pas
#       Builds all pascal files. Requires resources to have been built.
# ------------------------------------------------------------------------------


!include "..\Common.mak"

# Define location of binary output directory relative to Src\BPatch
BIN = ..\..\Bin\BPatch

# Default is to build all
exe: res pascal

# Synonyms
pas: pascal

# Build resources and delete intermediate file created by VIED
res: BPatch.res VBPatch.res
  -@del VBPatch.rc

# Build pascal source and link in resources
pascal: BPatch.exe

# Configure source folder
config:
  -@del BPatch.cfg
  -@copy BPatch.cfg.tplt BPatch.cfg
s