================================================================================

NOTES ON THE PASCAL TRANSLATION OF BDIFF / BPATCH

================================================================================

Release 0.2.1 (pas)
-------------------

This version is a fairly literal, line by line, translation of Stefan Reuther's
BDiff v0.2 and BPatch v0.2. The differences are:

+ The Pascal translation is only suitable for use on Windows targets - it
  compiles to a Win32 console application and uses the Windows API.

+ The C version encounters problems reading and writing binary difference files
  via shell redirection: MS-DOS / Windows could garble input or output because
  of end-of-line character translations. Therefore Stefan provided the --output
  (or -o) and --input (or -i) switches to overcome this problem. These switches
  are used instead of shell redirection on MS-DOS / Windows.

  The Pascal translation does not have this problem and shell redirection can be
  used safely on Windows systems. Therefore the --input and --output switches
  are not required, but have been retained.

+ The numeric parameter to BDiff's -m or --min-equal switches can be specified
  in decimal, octal or hexadecimal notation on the C version. The Pascal
  translation supports only decimal notation.

+ The Pascal versions of BDiff and BPatch contain embedded Windows version
  information.

+ Both the C and Pascal versions share a BPatch bug: the program crashes if only
  one file is supplied on the command line.


Release 0.2.2 (pas)
------------------

This version is again a fairly literal translation. The only change (except for
updated version information) is that BDiff contains a Pascal translation of a
bug fix in the block sort code for which Stefan provided updated C source code.


Release 0.2.3 and later
-----------------------

From this release BDiff and BPatch broke the link with the original C source and
began to develop separately, so further translation notes are not provided.

Note though that all 0.2.x releases remained functionally equivalent other than
for bug fixes.

--------------------------------------------------------------------------------
