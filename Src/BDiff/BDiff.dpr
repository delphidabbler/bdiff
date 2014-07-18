{*
 * Main project file for BDiff.exe.
 *}


program BDiff;


{$APPTYPE CONSOLE}

uses
  UBDiff in 'UBDiff.pas',
  UBlockSort in 'UBlockSort.pas',
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
  UBDiffMain in 'UBDiffMain.pas';

{$Resource VBDiff.res}    // version information
{$Resource BDiff.res}     // general resources

begin
  TMain.Run;
end.

