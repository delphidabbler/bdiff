{
 * Provides information about program: file name, date and version info.
 * Common code used by both BDiff and BPatch.
}

unit Common.AppInfo;


interface


type
  TPatchFileSignature = array[0..7] of AnsiChar;

  TAppInfo = class(TObject)
  strict private
    { Fully specified file name of program, with absolute path }
    class function ProgramPath: string;
  public
    const
      // Patch file signature. Must be 8 bytes.
      // Format is 'bdiff' + file-version + Ctrl+Z.
      // where file-version is a two char string, here '02'.
      // If file format is changed then increment the file version.
      PatchFileSignature: TPatchFileSignature = 'bdiff02'#$1A;
    { Name of program's executable file, without path }
    class function ProgramFileName: string;
    { Name of program, without file extension }
    class function ProgramBaseName: string;
    { Program's product version number }
    class function ProgramVersion: string;
    { Last modification date of program's executable file }
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

