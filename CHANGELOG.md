# BDiff / BPatch Change Log

## v1.0.0-rc.1 - 2024-10-24

_BDiff_ v1.0.0-rc.1 (build 13) & _BPatch_ v1.0.0-rc.1 (build 13)

* Added 64 bit versions of both _BDiff_ and _BPatch_ [issue #36].
* _BDiff_ and _BPatch_ `--version` commands now display platform information to make it possible to distinguish between 32 and 64 bit versions.
* Changed to compile with Delphi 12.2.
* Revised `Deploy.bat` to compile and package 32 and 64 bit releases in separate zip files.
* Fixed bug in `Deploy.bat` [issue #42].
* Changes to tests:
  * Added new binary patch test for larger (> 64KiB) files [issue #40].
  * Revised to be able to test both 32 and 64 bit executable files located in `_build\Win32` and `_build\Win64` directories using new `Test32.bat` and `Test64.bat` scripts.
  * Refactored `Test.bat`.
* Documentation:
  * Changed link to original C source code in `README.md` [issue #41].
  * Updated `README.md` and `Build.md` re addition of 64 bit build and release of _BDiff_ and _BPatch_.
  * Updated `Test\ReadMe.md` re changes to tests.

## v1.0.0-beta.2 - 2024-08-29

_BDiff_ v1.0.0-beta.2 (build 12) & _BPatch_ v1.0.0-beta.2 (build 12)

* Imposed limits to the value of the _BDiff_ `--min-equal` option. Values must fall with the range 8..1024 [issue #33].
* Increased the size of the _BPatch_ file read buffer from 4KiB to 64KiB [issue #34].
* Set an absolute limit to the size of files that can be processed by _BDiff_ when the `--permit-large-files` is used. This is 2,147,483,647 bytes, the largest file size supported by the binary diff file format [issue #32].
* Fixed bug where the `--version` command of both _BDiff_ and _BPatch_ was not reporting beta status [issue #35].
* Updated the _BDiff_ help screen re the changes to the `--min-equal` option, the absolute file size limit and to add a note of default values, where appropriate. The help screen was reformatted.
* Minor punctuation changes to the _BPatch_ help screen.
* Refactored methods that display _BDiff_ and _BPatch_ help and copyright text to use multi-line string literals.
* Changed to compile with Delphi 12.1 [issue #38].
* Documentation:
  * Updated the _BDiff_ manual page re changes to the `--min-equal` option and the absolute file size limit, to note a default value and to fix a typo.
  * Updated `README.md` to correct error in note of supported Windows versions.
  * Updated `Build.md` re change from Delphi 11 to Delphi 12, along with minor edits.

## v1.0.0-beta - 2023-06-02

_BDiff_ v1.0.0-beta (build 11) & _BPatch_ v1.0.0-beta (build 11)

* Added default limit of 10MiB on size of input files [issue #22].
* Added `--permit-large-files` option to override 10MiB file size limit [issue #22].
* Improved large file handling.
* Fixed potential issue with temporary files [issue #29].
* Fixed problematic detection of errors in opening and creating files [issue #30].
* Changed to compile with Delphi 11.x [issue #12].
* Removed `Makefile` and replaced with script to create and package releases [issue #26].
* Significant refactoring and modernisation of code, including rationalisation of types and unit names.
* License changed to BSD 3-clause license [issue #6].
* Documentation:
  * Rewrote `Build.md` re change from building from a makefile to building entirely from within Delphi IDE.
  * Fixed errors and minor edits to documentation. 
  * Updated BDiff manual page re file size limit and new `--permit-large-files` option.
  * Updated copyright statement in help screens [issue #23].
  * XMLDoc commented source code [issue #27].

## v0.2.9 - 2023-03-28

_BDiff_ v0.2.9 (build 10) & _BPatch_ v0.2.9 (build 10)

* `--version` command of both _BDiff_ and _BPatch_ now display compilation date in international date format.
* Update Makefiles re changes in documentation file names.
* Some refactoring of type and unit names, method signatures and reducing code duplication.
* Standardised type used for Windows handles.
* Updated manifest files to include program compatibility information.
* Documentation:
  * Converted several documents to Markdown format & add some text formatting.
  * Some corrections and revisions.

## v0.2.8 - 2016-09-19

_BDiff_ v0.2.8 (build 9) & _BPatch_ v0.2.8 (build 9)

* Converted to support Unicode file names and use of Unicode strings internally.
* Switched to Delphi XE compiler from Delphi 7.
* Added a new test to the test script.
* Significant overhaul and updates to documentation.

## v0.2.7 - 2014-07-19

_BDiff_ v0.2.7 (build 8) & _BPatch_ v0.2.7 (build 8)

* Bug fixes in _BDiff_:
  * "New" and "old" file names for a diff cannot now be the same.
  * Patch file name specified in `--output` or `-o` switches must now have a different name from other file names specified on command line.
* Major refactoring:
  * Big change from procedural to modularised, mainly OOP code split into several units.
  * Pascalified code in terms of variable names, camel casing etc.
  * Revised logic of some methods.
  * Reduced usage of some pointers, including replacing character pointers with Pascal strings.
* Revised and reformatted documentation: license and read-me files converted to  Markdown format.
* Minor changes to the license.

## v0.2.6a - 2009-08-06

_BDiff_ v0.2.6 (build 7) & _BPatch_ v0.2.6 (build 7)

* Removed source code from distribution.
* Documentation updated re changes.
* No changes to executable code other than to update build numbers.

## v0.2.6 - 2009-08-02

_BDiff_ v0.2.6 (build 6) & _BPatch_ v0.2.6 (build 6)

* Changed to use sytem temporary folder for temporary files instead of current directory.
* Typo in _BDiff_ help screen fixed.
* Some refactoring:
  * Code rationalised to have only one exit point in each application rather than multiple halt points. Achieved this by raising exceptions for fatal errors instead of calling _Halt()_.
  * Some duplicated code pulled into units shared between _BDiff_ and _BPatch_.
  * Ensured code that depends on single byte characters uses fixed size types instead of _Char_, which changes size in later compilers.
* Replaced build scripts with make files.
* Tests rewritten and extended:
  * Three different tests are now provided in place of one: all three patch formats are now tested.
  * Option added to display program version information.
  * Option added to clear temporary files generated by running the tests.
  * Location of _BDiff_ and _BPatch_ programs being tested can now be specified.
* Documentation overhauled.

## v0.2.5 - 2008-08-14

_BDiff_ v0.2.5 (build 5) & _BPatch_ v0.2.5 (build 5)

> Skipped _BDiff_ v0.2.4

* Renamed _BPtch_ back to _BPatch_.
* Added manifests to resources of both _BPatch_ and _BDiff_ to inform Windows Vista to run them as invoked. This prevents Vista from elevating _BPatch_ because of the word "patch" in its name.

## v0.2.4 - 2008-04-07

_BDiff_ v0.2.3 (build 4) & _BPtch_ v0.2.4 (build 4)

* Renamed _BPatch_ as _BPtch_ to prevent Windows Vista from flagging the program as requiring elevation.
* Also altered _BPtch_'s version information to remove the word "patch" for same reason!
* _BDiff_ was not changed except for incrementing build number.

## v0.2.3 - 2007-09-18

_BDiff_ v0.2.3 (build 3) & _BPatch_ v0.2.3 (build 3)

> Skipped _BPatch_ v0.2.2

* Fixed bug where _BPatch_ could not overwrite existing files.
* Fixed small bug in `-h` and `-v` switches in both programs.
* Fixed memory leaks in _BDiff_.
* Switched to Delphi 7 compiler from Delphi 4.
* Prevented compiler warnings in both programs.
* Added batch files to build projects.
* Updated help screens.
* Made some minor refactorings.
* Removed conditional compilation for non-Windows targets.
* Added test batch file a sample files.
* Changed to new binary and source license.

## v0.2.2(pas) - 2003-12-21

_BDiff_ v0.2.2 (build 2) & _BPatch_ v0.2.1 (build 2)

* Fixed bug in _BDiff_ by translating revised C code provided by Stefan Reuther. _BDiff_ is affected by the change while _BPatch_ remains unchanged.

## v0.2.1(pas) - 2003-11-29

_BDiff_ v0.2.1 (build 1) & _BPatch_ v0.2.1 (build 1)

* First Pascal version. This is a direct translation of v0.2 of Stefan Reuther's C code published in 1999.
