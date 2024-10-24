//!  BSD 3-clause license: see LICENSE.md

///  <summary>Provides various pieces of information about the currently running
///  program.</summary>
///  <remarks>Code common to both BDiff and BPatch.</remarks>

unit Common.AppInfo;


interface


type

  ///  <summary>Provides information about the program.</summary>
  TAppInfo = class(TObject)
  strict private
    ///  <summary>Returns absolute path of program .exe file.</summary>
    class function ProgramPath: string;
  public
    ///  <summary>Name of program's executable file, without path.</summary>
    class function ProgramFileName: string;
    ///  <summary>Name of program, without file extension.</summary>
    class function ProgramBaseName: string;
    ///  <summary>Program's product version number.</summary>
    ///  <remarks>Read from version information resources.</remarks>
    class function ProgramVersion: string;
    ///  <summary>Last modification date of program's executable file.</summary>
    class function ProgramExeDate: string;
    ///  <summary>The platform for which the program was compiled.</summary>
    class function ProgramPlatform: string;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  Winapi.Windows;


{ TAppInfo }

class function TAppInfo.ProgramBaseName: string;
begin
  Result := ChangeFileExt(ProgramFileName, '');
end;

class function TAppInfo.ProgramExeDate: string;
const
  InternationalDateFmtStr = 'yyyy"-"mm"-"dd';
begin
  var FileDate: TDateTime;
  if FileAge(ProgramPath, FileDate) then
    // Use international date format
    Result := FormatDateTime(InternationalDateFmtStr, FileDate)
  else
    Result := '';
end;

class function TAppInfo.ProgramFileName: string;
begin
  Result := ExtractFileName(ProgramPath);
end;

class function TAppInfo.ProgramPath: string;
begin
  Result := ParamStr(0);
end;

class function TAppInfo.ProgramPlatform: string;
begin
  {$IF Defined(WIN32)}
  Result := 'Windows 32 bit';
  {$ELSEIF Defined(WIN64)}
  Result := 'Windows 64 bit';
  {$ELSE}
  {$Message Fatal 'Unsupported platform'}
  {$IFEND}
end;

class function TAppInfo.ProgramVersion: string;
begin
  Result := '';
  // Get fixed file info from program's version info
  // get size of version info
  var Dummy: DWORD;
  var VerInfoSize := GetFileVersionInfoSize(PChar(ProgramPath), Dummy);
  if VerInfoSize = 0 then
    Exit;

  // create buffer and read version info into it
  var VerInfoBuf: Pointer;
  GetMem(VerInfoBuf, Integer(VerInfoSize));
  try
    if not GetFileVersionInfo(
      PChar(ProgramPath), Dummy, VerInfoSize, VerInfoBuf
    ) then
      Exit;
    var PBuf: Pointer;
    var Len: UINT;
    const SubBlock = '\StringFileInfo\080904E4\ProductVersion';
    if not VerQueryValue(VerInfoBuf, PChar(SubBlock), PBuf, Len) then
      Exit;
    Result := PChar(PBuf);
  finally
    FreeMem(VerInfoBuf);
  end;
end;

end.

