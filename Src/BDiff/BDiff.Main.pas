//!  BSD 3-clause license: see LICENSE.md

///  <summary>Main BDiff program logic.</summary>
///  <remarks>Used by BDiff only.</remarks>

unit BDiff.Main;


interface


uses
  // Project
  BDiff.Params;


type

  ///  <summary>Class containing main BDiff program logic.</summary>
  TMain = class(TObject)
  strict private
    const
      ///  <summary>Maximum file size for which diffs can be calculated unless
      ///  maximum file size limit is overridden.
      ///  </summary>
      RestrictedMaxFileSize: Int32 = 10_485_760;  // 10 MiB
      ///  <summary>Absolute maximum file size supported by binary diff file
      ///  format.</summary>
      AbsoluteMaxFileSize: Int32 = High(Int32);   // 2GiB - 1
    ///  <summary>Displays the program help screen.</summary>
    class procedure DisplayHelp;
    ///  <summary>Displays the program version information.</summary>
    class procedure DisplayVersion;
    ///  <summary>Creates and outputs the diff.</summary>
    ///  <param name="Params">[in] Command line parameters object containing
    ///  options used to customise diff output.</param>
    class procedure CreateDiff(Params: TParams);
    ///  <summary>Redirects a file to standard output.</summary>
    ///  <param name="FileName">[in] Name of file to redirect.</param>
    ///  <exception>Raises <c>EOSError</c> if file can't be redirected.
    ///  </exception>
    class procedure RedirectStdOut(const FileName: string);
    ///  <summary>Checks that both input files are under the maximum supported
    ///  file size. Does nothing if <c>--permit-large-files</c> option
    ///  specified.</summary>
    ///  <param name="Params">[in] Command line parameters object containing
    ///  the old and new file names.</param>
    ///  <exception>Raises <c>Exception</c> if either file is larger than
    ///  maximum permitted.</exception>
    class procedure CheckFileSizes(Params: TParams);
  public
    ///  <summary>Runs the program.</summary>
    class procedure Run;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  System.IOUtils,
  // Project
  BDiff.Differ,
  BDiff.InfoWriter,
  BDiff.IO,
  BDiff.Logger,
  Common.AppInfo,
  Common.Errors;


{ TMain }

class procedure TMain.CheckFileSizes(Params: TParams);

  procedure SizeError(const AFileName: string; AMaxSize: Int32);
  begin
    Error(
      '"%s" is too large (> %.0n bytes)',
      [AFileName, Extended(AMaxSize)],
      TFormatSettings.Create
    );
  end;

  function IsFileTooLarge(const AFileName: string; AMaxSize: Int32): Boolean;
  begin
    Result := TFile.GetSize(AFileName) > AMaxSize;
  end;

begin
  var MaxFileSize: Int32;
  if Params.OverrideMaxSize then
    MaxFileSize := AbsoluteMaxFileSize
  else
    MaxFileSize := RestrictedMaxFileSize;
  if IsFileTooLarge(Params.OldFileName, MaxFileSize) then
    SizeError(Params.OldFileName, MaxFileSize);
  if IsFileTooLarge(Params.NewFileName, MaxFileSize) then
    SizeError(Params.NewFileName, MaxFileSize);
end;

class procedure TMain.CreateDiff(Params: TParams);
begin
  var Logger := TLoggerFactory.CreateInstance(Params.Verbose);
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
  var PatchFileHandle: THandle := FileCreate(FileName);
  if PatchFileHandle = INVALID_HANDLE_VALUE then
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
        CheckFileSizes(Params);
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

