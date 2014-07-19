{
 * Main project file for BPatch.exe.
}


program BPatch;


{$APPTYPE CONSOLE}


uses
  UPatcher in 'UPatcher.pas',
  UBPatchUtils in 'UBPatchUtils.pas',
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

