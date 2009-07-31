{
  ------------------------------------------------------------------------------
  BDiff.dpr

  Main project file for Pascal version of BDiff.exe.

  Copyright (c) 2003-2007 Peter D Johnson (www.delphidabbler.com).

  THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY. IN
  NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE USE
  OF THIS SOFTWARE.

  For conditions of distribution and use see the BDiff / BPatch license
  available from http://www.delphidabbler.com/software/bdiff/license

  Change log
  v1.0 of 28 Nov 2003  -  Original version.
  v1.1 of 18 Sep 2007  -  Changed copyright and license notice.
  v1.2 of 14 Aug 2008  -  Included BDiff resource that contains a manifest that
                          tells Vista to run program as invoked.
  -----------------------------------------------------------------------------
}


program BDiff;


{$APPTYPE CONSOLE}

uses
  Windows,
  UBDiff in 'UBDiff.pas',
  UBlkSort in 'UBlkSort.pas',
  UBDiffUtils in 'UBDiffUtils.pas',
  UBDiffTypes in 'UBDiffTypes.pas';

{$Resource VBDiff.res}    // version information
{$Resource BDiff.res}     // general resources

begin
  UBDiff.Main;
end.

