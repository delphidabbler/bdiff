//!  BSD 3-clause license: see LICENSE.md

///  <summary>Handles display of BPatch's version information and help screen.
///  </summary>
///  <remarks>Used by BPatch only.</remarks>

unit BPatch.InfoWriter;


interface


uses
  // Project
  Common.InfoWriter;


type

  ///  <summary>Class that writes BPatch help text and version information to
  ///  stdout.</summary>
  TBPatchInfoWriter = class sealed(TInfoWriter)
  strict protected
    ///  <summary>Writes the main BPatch help text.</summary>
    class function HelpText: string; override;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  // Project
  Common.AppInfo;


{ TBPatchInfoWriter }

class function TBPatchInfoWriter.HelpText: string;
begin
  Result := Format(
    '%0:s: binary ''patch'' - apply binary patch'#13#10
      + #13#10
      + 'Usage: %0:s [options] old-file [new-file] [<patch-file]'#13#10#13#10
      + 'Creates new-file from old-file and patch-file'#13#10
      + 'If new-file is not provided old-file is updated in place'#13#10
      + #13#10
      + 'Valid options:'#13#10
      + ' -i FN --input=FN     Set input file name (instead of stdin)'
      + #13#10
      + ' -h    --help         Show this help screen'#13#10
      + ' -v    --version      Show version information'#13#10,
    [TAppInfo.ProgramFileName]
  );
end;

end.

