//!  BSD 3-clause license: see LICENSE.md

///  <summary>Main BPatch project file.</summary>

program BPatch;

{$APPTYPE CONSOLE}
{$Resource VBPatch.res}       // version information
{$Resource BPatchAssets.res}  // other resources

uses
  BPatch.InfoWriter in 'BPatch.InfoWriter.pas',
  BPatch.IO in 'BPatch.IO.pas',
  BPatch.Main in 'BPatch.Main.pas',
  BPatch.Params in 'BPatch.Params.pas',
  BPatch.Patcher in 'BPatch.Patcher.pas',
  Common.AppInfo in '..\Common\Common.AppInfo.pas',
  Common.CheckSum in '..\Common\Common.CheckSum.pas',
  Common.Errors in '..\Common\Common.Errors.pas',
  Common.InfoWriter in '..\Common\Common.InfoWriter.pas',
  Common.IO in '..\Common\Common.IO.pas',
  Common.Params in '..\Common\Common.Params.pas',
  Common.PatchHeaders in '..\Common\Common.PatchHeaders.pas',
  Common.Types in '..\Common\Common.Types.pas';

begin
  TMain.Run;
end.

