{*
 * BDiff.dpr   
 *
 * Main project file for BDiff.exe.
 *
 * Copyright (c) 2003-2011 Peter D Johnson (www.delphidabbler.com).
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
  UBDiffParams in 'UBDiffParams.pas',
  UPatchWriters in 'UPatchWriters.pas',
  UUtils in '..\Common\UUtils.pas',
  UBaseParams in '..\Common\UBaseParams.pas',
  ULogger in 'ULogger.pas',
  UInfoWriter in '..\Common\UInfoWriter.pas',
  UBDiffInfoWriter in 'UBDiffInfoWriter.pas',
  UMain in 'UMain.pas';

{$Resource VBDiff.res}    // version information
{$Resource BDiff.res}     // general resources

begin
  TMain.Run;
end.

