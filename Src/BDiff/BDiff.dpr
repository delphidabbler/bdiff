{*
 * Main project file for BDiff.exe.
 *}


program BDiff;


{$APPTYPE CONSOLE}

uses
  UDiffer in 'UDiffer.pas',
  UBlockSort in 'UBlockSort.pas',
  UBDiffIO in 'UBDiffIO.pas',
  UBDiffTypes in 'UBDiffTypes.pas',
  UAppInfo in '..\Common\UAppInfo.pas',
  UErrors in '..\Common\UErrors.pas',
  UFileData in 'UFileData.pas',
  UBDiffParams in 'UBDiffParams.pas',
  UPatchWriters in 'UPatchWriters.pas',
  UCommonIO in '..\Common\UCommonIO.pas',
  UBaseParams in '..\Common\UBaseParams.pas',
  ULogger in 'ULogger.pas',
  UInfoWriter in '..\Common\UInfoWriter.pas',
  UBDiffInfoWriter in 'UBDiffInfoWriter.pas',
  UBDiffMain in 'UBDiffMain.pas',
  UCheckSum in '..\Common\UCheckSum.pas';

{$Resource VBDiff.res}    // version information
{$Resource BDiffAssets.res}     // general resources

begin
  TMain.Run;
end.

