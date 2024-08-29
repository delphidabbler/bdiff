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
const
  Content = '''
    %0:s: binary 'patch' - apply binary patch

    Usage: %0:s [options] old-file [new-file] [<patch-file]

    Creates new-file from old-file and patch-file
    If new-file is not provided old-file is updated in place

    Valid options:
     -i FN --input=FN     Set input file name (instead of stdin).
     -h    --help         Show this help screen.
     -v    --version      Show version information.

    ''';
begin
  Result := Format(Content, [TAppInfo.ProgramFileName]);
end;

end.

