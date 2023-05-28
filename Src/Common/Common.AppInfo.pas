//!  BSD 3-clause license: see LICENSE.md

///  <summary>Provides various pieces of information about the currently running
///  program.</summary>
///  <remarks>Code common to both BDiff and BPatch.</remarks>

unit Common.AppInfo;


interface


type

  ///  <summary>Defines 8 character array used to store patch file signature.
  ///  </summary>
  TPatchFileSignature = array[0..7] of AnsiChar;

  ///  <summary>Provides information about the program.</summary>
  TAppInfo = class(TObject)
  strict private
    ///  <summary>Returns absolute path of program .exe file.</summary>
    class function ProgramPath: string;
  public
    const
      ///  <summary>Patch file signature.</summary>
      ///  <remarks>
      ///  <para>Format is <c>bdiff</c> + file-version + Ctrl+Z. Where
      ///  file-version is a two character ANSI string, here <c>02</c>.</para>
      ///  <para>If the file format is changed then increment the file version.
      ///  Keep the length at 8 bytes.</para>
      ///  </remarks>
      PatchFileSignature: TPatchFileSignature = 'bdiff02'#$1A;
    ///  <summary>Name of program's executable file, without path.</summary>
    class function ProgramFileName: string;
    ///  <summary>Name of program, without file extension.</summary>
    class function ProgramBaseName: string;
    ///  <summary>Program's product version number.</summary>
    ///  <remarks>Read from version information resources.</remarks>
    class function ProgramVersion: string;
    ///  <summary>Last modification date of program's executable file.</summary>
    class function ProgramExeDate: string;
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

class function TAppInfo.ProgramVersion: string;
begin
  Result := '';
  // Get fixed file info from program's version info
  // get size of version info
  var Dummy: DWORD;
  var VerInfoSize := GetFileVersionInfoSize(PChar(ProgramPath), Dummy);
  if VerInfoSize > 0 then
  begin
    // create buffer and read version info into it
    var VerInfoBuf: Pointer;
    GetMem(VerInfoBuf, VerInfoSize);
    try
      if GetFileVersionInfo(
        PChar(ProgramPath), Dummy, VerInfoSize, VerInfoBuf
      ) then
      begin
        // get fixed file info from version info (ValPtr points to it)
        var ValPtr: Pointer;
        if VerQueryValue(VerInfoBuf, '\', ValPtr, Dummy) then
        begin
          var FFI := PVSFixedFileInfo(ValPtr)^;
          // Build version info string from product version field of FFI
          Result := Format(
            '%d.%d.%d',
            [
              HiWord(FFI.dwProductVersionMS),
              LoWord(FFI.dwProductVersionMS),
              HiWord(FFI.dwProductVersionLS)
            ]
          );
        end
      end;
    finally
      FreeMem(VerInfoBuf);
    end;
  end;
end;

end.

