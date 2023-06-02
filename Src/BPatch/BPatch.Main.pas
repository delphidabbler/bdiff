//!  BSD 3-clause license: see LICENSE.md

///  <summary>Main BPatch program logic.</summary>
///  <remarks>Used by BPatch only.</remarks>

unit BPatch.Main;


interface


type

  ///  <summary>Class containing main BPatch program logic.</summary>
  TMain = class(TObject)
  strict private
    ///  <summary>Displays the program help screen.</summary>
    class procedure DisplayHelp;
    ///  <summary>Displays the program version information.</summary>
    class procedure DisplayVersion;
    ///  <summary>Redirects a file to standard input.</summary>
    ///  <param name="FileName">[in] Name of file to redirect.</param>
    ///  <exception>Raises <c>EOSError</c> if file can't be redirected.
    ///  </exception>
    class procedure RedirectStdIn(const FileName: string);
  public
    ///  <summary>Runs the program.</summary>
    class procedure Run;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  // Project
  BPatch.InfoWriter,
  BPatch.IO,
  BPatch.Patcher,
  BPatch.Params,
  Common.AppInfo,
  Common.Errors;


{ TMain }

class procedure TMain.DisplayHelp;
begin
  TBPatchInfoWriter.HelpScreen;
end;

class procedure TMain.DisplayVersion;
begin
  TBPatchInfoWriter.VersionInfo;
end;

class procedure TMain.RedirectStdIn(const FileName: string);
begin
  var PatchFileHandle: THandle := FileOpen(
    FileName, fmOpenRead or fmShareDenyNone
  );
  if PatchFileHandle = INVALID_HANDLE_VALUE then
    OSError;
  TIO.RedirectStdIn(PatchFileHandle);
end;

class procedure TMain.Run;
begin
  ExitCode := 0;
  var Params := TParams.Create;
  try
    try
      Params.Parse;
      if Params.Help then
        DisplayHelp
      else if Params.Version then
        DisplayVersion
      else
      begin
        if (Params.PatchFileName <> '') and (Params.PatchFileName <> '-') then
          RedirectStdIn(Params.PatchFileName);
        TPatcher.Apply(Params.OldFileName, Params.NewFileName);
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

