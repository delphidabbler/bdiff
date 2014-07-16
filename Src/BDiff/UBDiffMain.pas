{
 * UBDiffMain.pas
 *
 * Static class containing main program logic for BDiff program.
 *
 * Copyright (c) 2011 Peter D Johnson (www.delphidabbler.com).
 *
 * THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY.
 * IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE
 * USE OF THIS SOFTWARE.
 *
 * For conditions of distribution and use see the LICENSE file of visit
 * http://www.delphidabbler.com/software/bdiff/license
}


unit UBDiffMain;

interface

uses
  UBDiffParams;

type
  TMain = class(TObject)
  private
    class procedure DisplayHelp;
    class procedure DisplayVersion;
    class procedure CreateDiff(Params: TParams);
    class procedure RedirectStdOut(const FileName: string);
  public
    class procedure Run;
  end;

implementation

uses
  SysUtils,
  UAppInfo, UBDiff, UBDiffInfoWriter, UBDiffUtils, UErrors, ULogger;

{ TMain }

class procedure TMain.CreateDiff(Params: TParams);
var
  Differ: TDiffer;
  Logger: TLogger;
begin
  // create the diff
  Logger := TLoggerFactory.Instance(Params.Verbose);
  try
    Differ := TDiffer.Create;
    try
      Differ.MinMatchLength := Params.MinEqual;
      Differ.Format := Params.Format;
      Differ.MakeDiff(Params.OldFileName, Params.NewFileName, Logger);
    finally
      Differ.Free;
    end;
  finally
    Logger.Free;
  end;
end;

class procedure TMain.DisplayHelp;
begin
  TBDiffInfoWriter.HelpScreen;
end;

class procedure TMain.DisplayVersion;
begin
  TBDiffInfoWriter.VersionInfo;
end;

class procedure TMain.RedirectStdOut(const FileName: string);
var
  PatchFileHandle: Integer;
begin
  // redirect standard output to patch file
  PatchFileHandle := FileCreate(FileName);
  if PatchFileHandle <= 0 then
    OSError;
  TIO.RedirectStdOut(PatchFileHandle);
end;

class procedure TMain.Run;
var
  Params: TParams;
begin
  ExitCode := 0;
  try
    Params := TParams.Create;
    try
      Params.Parse;
      if Params.Help then
        DisplayHelp
      else if Params.Version then
        DisplayVersion
      else
      begin
        if (Params.PatchFileName <> '') and (Params.PatchFileName <> '-') then
          RedirectStdOut(Params.PatchFileName);
        CreateDiff(Params);
      end;
    finally
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      ExitCode := 1;
      TIO.WriteStrFmt(
        TIO.StdErr, '%0:s: %1:s'#13#10, [ProgramFileName, E.Message]
      );
    end;
  end;
end;

end.
