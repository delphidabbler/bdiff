# Notes On The Pascal Translation Of BDiff / BPatch

## Release 0.2.1 (pas)

This version is a fairly literal, line by line, translation of Stefan Reuther's _BDiff_ v0.2 and _BPatch_ v0.2. The differences are:

+ The Pascal translation is only suitable for use on Windows targets - it compiles to a Win32 console application and uses the Windows API.

+ The C version encounters problems reading and writing binary difference files via shell redirection: MS-DOS / Windows could garble input or output because of end-of-line character translations. Therefore Stefan provided the `--output` (or `-o`) and `--input` (or `-i`) commands to overcome this problem. These commands are used instead of shell redirection on MS-DOS / Windows.

  The Pascal translation does not have this problem and shell redirection can be used safely on Windows systems. Therefore the `--input` and `--output` commands are not strictly necessary, although they have been retained in this version.

+ The numeric parameter to _BDiff_'s `-m` or `--min-equal` commands can be specified in decimal, octal or hexadecimal notation with the C version. The Pascal translation supports only decimal notation.

+ The Pascal versions of _BDiff_ and _BPatch_ contain embedded Windows version information.

Both the C and Pascal versions share a _BPatch_ bug: the program crashes if only one file is supplied on the command line.

## Release 0.2.2 (pas)

This version is again a fairly literal translation. The only change (except for updated version information) is that _BDiff_ contains a Pascal translation of a bug fix in the block sort code for which Stefan provided updated C source code.

## Release 0.2.3 and later

From release 0.2.3 _BDiff_ and _BPatch_ began to diverge from the original C source code. This divergence means there is no need for any further translation notes.

Note that all v0.2.x releases will remain functionally very similar to v0.2.1, other than for bug fixes.
