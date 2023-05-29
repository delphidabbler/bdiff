//!  BSD 3-clause license: see LICENSE.md

///  <summary>Main BDiff project file.</summary>

program BDiff;

{$APPTYPE CONSOLE}
{$Resource VBDiff.res}        // version information
{$Resource BDiffAssets.res}   // general resources

uses
  BDiff.BlockSort in 'BDiff.BlockSort.pas',
  BDiff.Differ in 'BDiff.Differ.pas',
  BDiff.FileData in 'BDiff.FileData.pas',
  BDiff.InfoWriter in 'BDiff.InfoWriter.pas',
  BDiff.IO in 'BDiff.IO.pas',
  BDiff.Logger in 'BDiff.Logger.pas',
  BDiff.Main in 'BDiff.Main.pas',
  BDiff.Params in 'BDiff.Params.pas',
  BDiff.PatchWriters in 'BDiff.PatchWriters.pas',
  BDiff.Types in 'BDiff.Types.pas',
  Common.AppInfo in '..\Common\Common.AppInfo.pas',
  Common.CheckSum in '..\Common\Common.CheckSum.pas',
  Common.Errors in '..\Common\Common.Errors.pas',
  Common.InfoWriter in '..\Common\Common.InfoWriter.pas',
  Common.IO in '..\Common\Common.IO.pas',
  Common.Params in '..\Common\Common.Params.pas',
  Common.PatchHeaders in '..\Common\Common.PatchHeaders.pas';

begin
  TMain.Run;
end.

