#
#  Makefile for bdiff/bpatch
#

# define your options and compiler here. You may need to remove
# `-ansi' on some systems. GCC is not required, the program should
# be perfectly portable (...to systems with a 32bit size_t).
CFLAGS = -W -Wall -ansi -pedantic -O6
GCC = gcc $(CFLAGS)

all: bdiff bpatch

bdiff: bdiff.o blksort.o
	$(GCC) -o bdiff bdiff.o blksort.o

bpatch: bpatch.o
	$(GCC) -o bpatch bpatch.o

.c.o:
	$(GCC) -c $*.c
