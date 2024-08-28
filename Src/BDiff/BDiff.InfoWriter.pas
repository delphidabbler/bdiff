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
begin
  Result := Format(
    '%0:s: binary ''diff'' - compare two binary files'#13#10#13#10
      + 'Usage: %0:s [options] old-file new-file [>patch-file]'#13#10#13#10
      + 'Difference between old-file and new-file written to standard output'
      + #13#10#13#10
      + 'Valid options:'#13#10
      + ' -q                         Use QUOTED format'#13#10
      + ' -f                         Use FILTERED format'#13#10
      + ' -b                         Use BINARY format'#13#10
      + '       --format=FMT         Use format FMT (''quoted'', ''filter[ed]'' '
      + 'or ''binary'')'#13#10
      + ' -m N  --min-equal=N        Minimum equal bytes to recognize an equal '
      + 'chunk'
      + #13#10
      + '                            Range 8..1024. Default 24.'
      + #13#10
      + ' -o FN --output=FN          Set output file name (instead of stdout)'
      + #13#10
      + '       --permit-large-files Lifts the maximum file size limit from '
      + '10MiB to 2GiB-1.'#13#10
      + ' -V    --verbose            Show status messages'#13#10
      + ' -h    --help               Show this help screen'#13#10
      + ' -v    --version            Show version information'#13#10,
    [TAppInfo.ProgramFileName]
  );
end;

end.

