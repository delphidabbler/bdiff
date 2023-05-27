{
 * Static class containing main program logic for BDiff program.
}


unit BDiff.Main;


interface


uses
  BDiff.Params;


type
  TMain = class(TObject)
  strict private
    class procedure DisplayHelp;
    class procedure DisplayVersion;
    class procedure CreateDiff(Params: TParams);
    class procedure RedirectStdOut(const FileName: string);
  public
    class procedure Run;
  end;


implementation


uses
  System.SysUtils,

  BDiff.Differ,
  BDiff.InfoWriter,
  BDiff.IO,
  BDiff.Logger,
  Common.AppInfo,
  Common.Errors;


{ TMain }

class procedure TMain.CreateDiff(Params: TParams);
begin
  // create the diff
  var Logger := TLoggerFactory.Instance(Params.Verbose);
  try
    var Differ := TDiffer.Create;
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
begin
  // redirect standard output to patch file
  var PatchFileHandle: THandle := FileCreate(FileName);
  if NativeInt(PatchFileHandle) <= 0 then
    OSError;
  TIO.RedirectStdOut(PatchFileHandle);
end;

class procedure TMain.Run;
begin
  ExitCode := 0;
  try
    var Params := TParams.Create;
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
        TIO.StdErr, '%0:s: %1:s'#13#10, [TAppInfo.ProgramFileName, E.Message]
      );
    end;
  end;
end;

end.

