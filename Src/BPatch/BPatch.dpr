{
  ------------------------------------------------------------------------------
  BPatch.dpr

  Main project file for Pascal version of BPatch.exe.

  Copyright (c) 2003-2007 Peter D Johnson (www.delphidabbler.com).

  THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY. IN
  NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE USE
  OF THIS SOFTWARE.

  For conditions of distribution and use see the BDiff / BPatch license
  available from http://www.delphidabbler.com/software/bdiff/license

  Change log
  v1.0 of 28 Nov 2003  -  Original version.
  v1.1 of 18 Sep 2007  -  Changed copyright and license notice.
  v1.2 of 07 Apr 2008  -  Renamed from BPatch.dpr to BPtch.dpr. "BPatch" caused
                          Windows Vista to flag the program for elevation!
  v1.3 of 14 Aug 2008  -  Renamed back to BPatch.dpr from BPtch.dpr.
                       -  Included BPatch.res containing manifest that causes
                          program to be run as invoked, overriding Vista's
                          desire to elevate the program because "patch" is
                          included in name.
  ------------------------------------------------------------------------------
}


program BPatch;


{$APPTYPE CONSOLE}


uses
  Windows,
  UBPatch in 'UBPatch.pas',
  UBPatchUtils in 'UBPatchUtils.pas',
  UBPatchTypes in 'UBPatchTypes.pas';

{$Resource VBPatch.res}     // version information
{$Resource BPatch.res}      // other resources

begin
  UBPatch.Main;
end.

