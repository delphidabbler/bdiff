# BDiff / BPatch

Binary diff and patch programs for the Windows command line.

## Introduction

_BDiff_ computes the differences between two files, say _file1_ and _file2_. Output can be either a somewhat human-readable protocol in plain text, or a binary file that is readable by _BPatch_.

_BPatch_ applies a binary patch generated by _BDiff_ to _file1_ to recreate _file2_.

See the files `BDiff.md` and `BPatch.md` in the `Docs` directory for details of how to use the programs.

_BDiff_ and _BPatch_ are derived from Stefan Reuther's _bdiff_ and _bpatch_ v0.2 and a later bug fix by Stefan.

The original C source was translated into Object Pascal by [Peter D Johnson](https://gravatar.com/delphidabbler). The programs are based on updates of the Pascal code base.

The programs should run on Windows 7 SP1 and later.

For more information see the see the [project web pages](http://delphidabbler.com/software/bdiff).

## Installation

Copy the provided executable files to the required location. No further installation is required.

You may want to modify the Windows PATH environment variable to include the location of the programs.

To uninstall simply delete the programs. They make no changes to the system. If you changed the PATH environment variable you may wish to adjust this.

## Tests

You can test the operation of _BDiff_ and _BPatch_ using the `Test.bat` script in the `Test` directory. See `ReadMe.md` in that directory for details.

## Source Code

### Pascal Source

The current source code is maintained in the [delphidabbler/bdiff](https://github.com/delphidabbler/bdiff) Git repository on GitHub. It contains releases going back to v0.2.5. Earlier versions were not under version control and are no longer available.

> **Note:** Until February 2014 the source code was maintained in a Subversion repository. A dump of the repo is available from [Google Drive](https://drive.google.com/file/d/0B8qEVqTUMgmJcF9zVnk0Zk1VMDQ/view?usp=sharing).

For information on how to build the Pascal source, see `Build.md` in the root of the Git repo.

### C Source

The original C source code can be downloaded from http://phost.de/~stefan/Files/bdiff-02.zip.

## Copyright and License

See the file `LICENSE.md` for details of copyright and the license that applies to this software.

## Change Log

The change log is provided in the file `CHANGELOG.md`.
