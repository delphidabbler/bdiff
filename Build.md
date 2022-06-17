================================================================================

BDiff / BPatch Build Instructions

================================================================================


Introduction
--------------------------------------------------------------------------------

BDiff / BPatch is written in Object Pascal and is targeted at Delphi XE. The
Delphi IDE can be used to modify the source and to perform test builds. Final
builds should be built using the provided makefile, but you can get away with
using the IDE if you don't change any resources.

These instructions only apply to building the current release of BDiff / BPatch.
Earlier releases back to v0.2.6a will have their own versions of this file.


Requirements
--------------------------------------------------------------------------------

You need the following tools to perform a full build and release of BDiff /
BPatch:

Delphi Command Line compiler (DCC32)
------------------------------------

The preferred version is Delphi XE. If you have this compiler please use it. The
DELPHIROOT environment variable must be set to the install path of the version
Delphi you are using. DCC32.exe must be present in the Bin sub-directory of the
path specified by DELPHIROOT. If DELPHIROOT is not set then Make will fail.

Alternatives:

  + Unicode versions of Delphi other than XE may work, but haven't been tested.
    Non Unicode compilers will fail to compile the code.

  + Only versions of Delphi that ship with the DCC32 command line compiler can
    be used with the make files.

  + As noted above you can compile Pascal code from the Delphi IDE instead of
    running DCC32.

BRCC32 resource compiler (BRCC32)
---------------------------------

BRCC32 is distributed with Delphi. It is needed to compile resource files. The
Makefile expects to find BRCC32 in the same directory as DCC32.

Borland MAKE
------------

This is the make tool that ships with Delphi. You can use any version that
works. I've tested only the version that ships with Delphi XE. The makefile
calls Make recursively: it uses the same command line that you used to call it,
so there are no requirements as to the location of Make.

DelphiDabbler Version Information Editor (VIEd)
-----------------------------------------------

This program is required to convert the .vi files that specify version
information into an intermediate .rc file that is compiled by BRCC32. VIEd is
expected to be on the system path unless the VIEDROOT environment variable is
set to indicate VIEd's installation directory. You can get VIEd here:
https://github.com/delphidabbler/vied

Zip.exe
-------

This program is required to create the release exe file. Again it is assumed to
be on the path unless the ZIPROOT environment variable is set to its install
directory. You can get a Windows version at:
http://stahlforce.com/dev/index.php?tool=zipunzip


Dependencies
--------------------------------------------------------------------------------

The source depends only on the Delphi VCL, so provided you have Delphi
installed, the source should compile without building any other libraries.


Preparations
--------------------------------------------------------------------------------

Get the source code
-------------------

The source code of BDiff / BPatch is maintained in the delphidabbler/bdiff Git
repository on GitHub at https://github.com/delphidabbler/bdiff

Each release from v0.2.5 onwards is available from GitHub. You can download an
archive containing the required release. Note that releases prior to v0.2.7 were
originally maintained in a Subversion repository and therefore their
documentation will refer to Subversion rather than Git.

Once the source is cloned or forked you should end up with a folder structure
like this:

  +--+                { root: .gitignore, this file, and some documentation}
     |
     +-- Docs         { documentation files }
     |
     +-- Src          { project group and master make files }
     |   |
     |   +-- BDiff    { source and makefile for BDiff }
     |   |
     |   +-- BPatch   { source and makefile for BPatch }
     |   |
     |   +-- Common   { code common to both programs }
     |
     +-- Test         { test scripts }

If, by chance you also have a Build directory and sub-directories don't worry.
Git users will also see the usual .git hidden directory.

Configure the source tree
-------------------------

Before you can get hacking, you need to prepare the code. Open a command
console, navigate into the Src sub-folder and do:

  > Make config

You may need to replace "Make" above with the full path to Make if it isn't on
the path, or if the Make that runs isn't the Borland / CodeGear version.

Once "Make config" has completed your folder structure should have changed to:

  +--+
     |
     +-- Build           { contains files created in build process }
     |   |
     |   +-- Bin         { parent of binary folders }
     |   |   |
     |   |   +-- BDiff   { receives binary files for BDiff (.dcu and .res) }
     |   |   |
     |   |   +-- BPatch  { receives binary files for BPatch (.dcu and .res) }
     |   |
     |   +-- Exe         { receives executable files }
     |   |
     |   +-- Release     { receives release zip file }
     |
     +-- Docs
     |
     +-- Src
     |   |
     |   +-- BDiff
     |   |
     |   +-- BPatch
     |
     +-- Test

Git has been configured to ignore the Build folder and its contents. In addition
Make will have created .cfg files from templates. These files are needed for
DCC32 to run correctly. The .cfg files will be ignored by Git.

If you are intending to use the Delphi IDE to compile code, you should also do:

  > Make res

This compiles the resource files that the IDE needs to link into compiled
executables.

Modify the source
-----------------

If you plan to modify the source, you can do it now.

If you are using the Delphi IDE you should load the BDiff.groupproj project
group file from the Src folder into the IDE - this contains both the BDiff and
BPatch targets.

Compile
-------

Compile the code by doing

  > Make exe

This builds the resources then builds the whole of the Pascal source using the
DCC32 command line compiler.

Even if you have built the code in the IDE you advised to run "Make exe".

At any time you can rebuild the resources using "Make res" or rebuild the pascal
code without also building resources by using "Make pascal".

Testing
-------

Some simple tests can be run to check that BDiff and BPatch are working
correctly. For details see ReadMe.txt in the Test folder.

Prepare the executable release file
-----------------------------------

If you want to create a zip file containing the executable programs and required
documentation do:

  > Make release

This deletes any temporary files then creates the required zip file. You can
change the default name of the zip file by defining the RELEASEFILENAME
environment variable with the required name (excluding extension). For example,
to generate a release file named my-file.zip define RELEASEFILENAME as 'my-file'
or do:

  > Make -DRELEASEFILENAME=myfile release

If you issue a Make with no target it will re-run config, build the executable
code and create the release.

Tidy up
-------

At any time you can tidy up temporary files by doing:

  > Make clean

If you also want to remove the .cfg files generated from .cfg.tplt files along
with the entire Build directory you can do:

  > Make deepclean
