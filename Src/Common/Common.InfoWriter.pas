//!  BSD 3-clause license: see LICENSE.md

///  <summary>Code for displaying help and version information to stdout that is
///  common to both programs.</summary>
///  <remarks>Code common to both BDiff and BPatch.</remarks>

unit Common.InfoWriter;


interface


type

  ///  <summary>Abstract base class for classes that write help text and version
  ///  information to stdout.</summary>
  TInfoWriter = class abstract(TObject)
  strict private
    ///  <summary>Writes copyright portion of help text.</summary>
    class function CopyrightHelpText: string;
  strict protected
    ///  <summary>Writes the main help text.</summary>
    class function HelpText: string; virtual; abstract;
  public
    ///  <summary>Writes the program's version information to stdout.</summary>
    class procedure VersionInfo;
    ///  <summary>Writes the program's help screen to stdout.</summary>
    class procedure HelpScreen;
  end;


implementation


uses
  // Project
  Common.AppInfo,
  Common.IO;


{ TInfoWriter }

class function  TInfoWriter.CopyrightHelpText: string;
begin
  Result := '''

    (c) copyright 1999 Stefan Reuther <Streu@gmx.de>
    (c) copyright 2003-2023 Peter Johnson <https://delphidabbler.com>
    ''';
end;

class procedure TInfoWriter.HelpScreen;
begin
  TCommonIO.WriteStr(TCommonIO.StdOut, HelpText);
  TCommonIO.WriteStr(TCommonIO.StdOut, CopyrightHelpText);
end;

class procedure TInfoWriter.VersionInfo;
begin
  // NOTE: original code displayed compile date using C's __DATE__ macro. Since
  // there is no Pascal equivalent of __DATE__ we display update date of program
  // file instead
  TCommonIO.WriteStrFmt(
    TCommonIO.StdOut,
    '%s-%s %s '#13#10,
    [TAppInfo.ProgramBaseName, TAppInfo.ProgramVersion, TAppInfo.ProgramExeDate]
  );
end;

end.

