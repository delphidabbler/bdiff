{
 * BPatch.dpr
 *
 * Main project file for BPatch.exe.
 *
 * Copyright (c) 2003-2011 Peter D Johnson (www.delphidabbler.com).
 *
 * THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY.
 * IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE
 * USE OF THIS SOFTWARE.
 *
 * For conditions of distribution and use see the LICENSE file of visit
 * http://www.delphidabbler.com/software/bdiff/license
}


program BPatch;


{$APPTYPE CONSOLE}


uses
  UBPatch in 'UBPatch.pas',
  UBPatchUtils in 'UBPatchUtils.pas',
  UBPatchTypes in 'UBPatchTypes.pas',
  UAppInfo in '..\Common\UAppInfo.pas',
  UErrors in '..\Common\UErrors.pas',
  UBPatchParams in 'UBPatchParams.pas',
  UUtils in '..\Common\UUtils.pas',
  UBaseParams in '..\Common\UBaseParams.pas',
  UBPatchInfoWriter in 'UBPatchInfoWriter.pas',
  UInfoWriter in '..\Common\UInfoWriter.pas',
  UBPatchMain in 'UBPatchMain.pas';

{$Resource VBPatch.res}     // version information
{$Resource BPatch.res}      // other resources

begin
  TMain.Run;
end.

