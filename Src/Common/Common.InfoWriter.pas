{
 * Abstract base class for classes that emit version information and help
 * screens on standard output.
}

unit Common.InfoWriter;

interface

type
  TInfoWriter = class(TObject)
  strict private
    class function CopyrightHelpText: string;
  protected
    class function HelpText: string; virtual; abstract;
  public
    class procedure VersionInfo;
    class procedure HelpScreen;
  end;

implementation

uses
  Common.AppInfo, Common.IO;

{ TInfoWriter }

class function  TInfoWriter.CopyrightHelpText: string;
begin
  Result := #13#10
    + '(c) copyright 1999 Stefan Reuther <Streu@gmx.de>'#13#10
    + '(c) copyright 2003-2023 Peter Johnson <https://delphidabbler.com>'
    + #13#10;
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
