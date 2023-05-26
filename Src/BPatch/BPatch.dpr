{
 * Main project file for BPatch.exe.
}

program BPatch;

{$APPTYPE CONSOLE}

uses
  BPatch.InfoWriter in 'BPatch.InfoWriter.pas',
  BPatch.IO in 'BPatch.IO.pas',
  BPatch.Main in 'BPatch.Main.pas',
  BPatch.Params in 'BPatch.Params.pas',
  BPatch.Patcher in 'BPatch.Patcher.pas',
  Common.AppInfo in '..\Common\Common.AppInfo.pas',
  Common.Params in '..\Common\Common.Params.pas',
  Common.CheckSum in '..\Common\Common.CheckSum.pas',
  Common.IO in '..\Common\Common.IO.pas',
  Common.Errors in '..\Common\Common.Errors.pas',
  Common.InfoWriter in '..\Common\Common.InfoWriter.pas';

{$Resource VBPatch.res}     // version information
{$Resource BPatchAssets.res}      // other resources

begin
  TMain.Run;
end.

