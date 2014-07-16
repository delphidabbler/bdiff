{
 * Provides information about program: file name, date and version info.
 * Common code used by both BDiff and BPatch.
}


unit UAppInfo;


interface

{ Name of program's executable file, without path }
function ProgramFileName: string;

{ Name of program, without file extension }
function ProgramBaseName: string;

{ Program's product version number }
function ProgramVersion: string;

{ Last modification date of program's executable file }
function ProgramExeDate: string;


implementation


uses
  // Delphi
  SysUtils, Windows;


{ Fully specified file name of program, with absolute path }
function ProgramPath: string;
begin
  Result := ParamStr(0);
end;

{ Name of program's executable file, without path }
function ProgramFileName: string;
begin
  Result := ExtractFileName(ProgramPath);
end;

{ Name of program, without file extension }
function ProgramBaseName: string;
begin
  Result := ChangeFileExt(ProgramFileName, '');
end;

{ Program's product version number }
function ProgramVersion: string;
var
  Dummy: DWORD;           // unused variable required in API calls
  VerInfoSize: Integer;   // size of version information data
  VerInfoBuf: Pointer;    // buffer holding version information
  ValPtr: Pointer;        // pointer to a version information value
  FFI: TVSFixedFileInfo;  // fixed file information from version info
begin
  Result := '';
  // Get fixed file info from program's version info
  // get size of version info
  VerInfoSize := GetFileVersionInfoSize(PChar(ProgramPath), Dummy);
  if VerInfoSize > 0 then
  begin
    // create buffer and read version info into it
    GetMem(VerInfoBuf, VerInfoSize);
    try
      if GetFileVersionInfo(
        PChar(ProgramPath), Dummy, VerInfoSize, VerInfoBuf
      ) then
      begin
        // get fixed file info from version info (ValPtr points to it)
        if VerQueryValue(VerInfoBuf, '\', ValPtr, Dummy) then
        begin
          FFI := PVSFixedFileInfo(ValPtr)^;
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

{ Last modification date of program's executable file }
function ProgramExeDate: string;
var
  DOSDate: Integer; // file modification date as integer
begin
  DOSDate := FileAge(ProgramPath);
  Result := FormatDateTime('dd mmm yyyy', FileDateToDateTime(DOSDate));
end;

end.
