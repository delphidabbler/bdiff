//!  BSD 3-clause license: see LICENSE.md

///  <summary>Handles display of BDiff's version information and help screen.
///  </summary>
///  <remarks>Used by BDiff only.</remarks>

unit BDiff.InfoWriter;


interface


uses
  // Project
  Common.InfoWriter;


type

  ///  <summary>Class that writes BDiff help text and version information to
  ///  stdout.</summary>
  TBDiffInfoWriter = class sealed(TInfoWriter)
  strict protected
    ///  <summary>Writes the main BDiff help text.</summary>
    class function HelpText: string; override;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  // Project
  Common.AppInfo;


{ TBDiffInfoWriter }

class function TBDiffInfoWriter.HelpText: string;
const
  Content = '''
    %0:s: binary 'diff' - compare two binary files

    Usage: %0:s [options] old-file new-file [>patch-file]

    Difference between old-file and new-file written to standard output

    Valid options:
     -q                         Use QUOTED format (default).
     -f                         Use FILTERED format.
     -b                         Use BINARY format.
           --format=FMT         Use format FMT ('quoted', 'filter[ed]' or
                                'binary'). Default 'quoted'.
     -m N  --min-equal=N        Minimum equal bytes to recognize an equal
                                chunk. Range 8..1024. Default 24.
     -o FN --output=FN          Set output file name (instead of stdout).
           --permit-large-files Lifts the maximum file size limit from 10MiB
                                to 2GiB-1.
     -V    --verbose            Show status messages.
     -h    --help               Show this help screen.
     -v    --version            Show version information.

    ''';
begin
  Result := Format(Content, [TAppInfo.ProgramFileName]);
end;

end.

