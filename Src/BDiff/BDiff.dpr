{*
 * BDiff.dpr
 *
 * Main project file for BDiff.exe.
 *
 * Copyright (c) 2003-2009 Peter D Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY.
 * IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE
 * USE OF THIS SOFTWARE.
 *
 * For conditions of distribution and use see the LICENSE file of visit
 * http://www.delphidabbler.com/software/bdiff/license
 *}


program BDiff;


{$APPTYPE CONSOLE}

uses
  Windows,
  UBDiff in 'UBDiff.pas',
  UBlkSort in 'UBlkSort.pas',
  UBDiffUtils in 'UBDiffUtils.pas',
  UBDiffTypes in 'UBDiffTypes.pas',
  UAppInfo in '..\Common\UAppInfo.pas',
  UErrors in '..\Common\UErrors.pas',
  UFileData in 'UFileData.pas',
  UBDiffParams in 'UBDiffParams.pas';

{$Resource VBDiff.res}    // version information
{$Resource BDiff.res}     // general resources

begin
  UBDiff.Main;
end.

