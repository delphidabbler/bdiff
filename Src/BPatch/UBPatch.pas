{
 * UBPatch.pas
 *
 * Main program logic for BPatch.
 *
 * Based on bpatch.c by Stefan Reuther, copyright (c) 1999 Stefan Reuther
 * <Streu@gmx.de>.
 *
 * Copyright (c) 2003-2011 Peter D Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY.
 * IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE
 * USE OF THIS SOFTWARE.
 *
 * For conditions of distribution and use see the LICENSE file of visit
 * http://www.delphidabbler.com/software/bdiff/license
}


unit UBPatch;


interface


{ The program's main interface code: called from the project file }
procedure Main;


implementation

{$IOCHECKS OFF}

uses
  // Delphi
  Windows, SysUtils,
  // Project
  UAppInfo, UBPatchParams, UBPatchUtils, UBPatchTypes, UErrors, UUtils;


const
  FORMAT_VERSION = '02';  // binary diff file format version
  BUFFER_SIZE = 4096;     // size of buffer used to read files


{ Compute simple checksum }
function CheckSum(Data: PAnsiChar; DataSize: size_t;
  const BFCheckSum: Longint): Longint;
begin
  Result := BFCheckSum;
  while DataSize <> 0 do
  begin
    Dec(DataSize);
    Result := ((Result shr 30) and 3) or (Result shl 2);
    Result := Result xor PShortInt(Data)^;
    Inc(Data);
  end;
end;

{ Get 32-bit quantity from char array }
function GetLong(PCh: PAnsiChar): Longint;
var
  PB: PByte;
  LW: LongWord;
begin
  PB := PByte(PCh);
  LW := PB^;
  Inc(PB);
  LW := LW + 256 * PB^;
  Inc(PB);
  LW := LW + 65536 * PB^;
  Inc(PB);
  LW := LW + 16777216 * PB^;
  Result := LW;
end;

{ Copy data from one stream to another, computing checksums
  @param SourceFileHandle [in] Handle to file containing data to be copied.
  @param DestFileHandle [in] Handle to file to receive copied data.
  @param Count [in] Number of bytes to copy.
  @param SourceCheckSum [in] Checksum for data to be copied
  @param SourceIsPatch [in] Flag True when SourceFileHandle is patch file and
    False when SourceFileHandle is source file.
}
procedure CopyData(const SourceFileHandle, DestFileHandle: Integer;
  Count, SourceCheckSum: Longint; const SourceIsPatch: Boolean);
var
  DestCheckSum: Longint;
  Buffer: array[0..BUFFER_SIZE-1] of AnsiChar;
  BytesToCopy: size_t;
begin
  DestCheckSum := 0;

  while Count <> 0 do
  begin
    if Count > BUFFER_SIZE then
      BytesToCopy := BUFFER_SIZE
    else
      BytesToCopy := Count;
    if FileRead(SourceFileHandle, Buffer, BytesToCopy)
      <> Integer(BytesToCopy) then
    begin
      if feof(SourceFileHandle) then
      begin
        if SourceIsPatch then
          Error('Patch garbled - unexpected end of data')
        else
          Error('Source file does not match patch');
      end
      else
      begin
        if SourceIsPatch then
          Error('Error reading patch file')
        else
          Error('Error reading source file');
      end;
    end;
    if DestFileHandle <> 0 then
      if FileWrite(DestFileHandle, Buffer, BytesToCopy)
        <> Integer(BytesToCopy) then
        Error('Error writing temporary file');
    DestCheckSum := CheckSum(Buffer, BytesToCopy, DestCheckSum);
    Dec(Count, BytesToCopy);
  end;
  if not SourceIsPatch and (DestCheckSum <> SourceCheckSum) then
    Error('Source file does not match patch');
end;

{ Creates a temporary file in user's temp directory and returns its name }
function GetTempFileName: string;
begin
  // Get temporary folder
  SetLength(Result, Windows.MAX_PATH);
  Windows.GetTempPath(Windows.MAX_PATH, PChar(Result));
  // Get unique temporary file name (it is created as side effect of this call)
  if Windows.GetTempFileName(
    PChar(Result), '', 0, PChar(Result)
  ) = 0 then
    Error('Can''t create temporary file');
  Result := PChar(Result)
end;

procedure ApplyPatch(const SourceFileName, DestFileName: string);
var
  SourceFileHandle: Integer;        // source file handle
  DestFileHandle: Integer;          // destination file handle
  TempFileName: string;             // temporary file name
  Header: array[0..15] of AnsiChar; // patch file header
  SourceLen: Longint;               // expected length of source file
  DestLen: Longint;                 // expected length of destination file
  DataSize: Longint;                // size of data to be copied to destination
  SourceFilePos: Longint;           // position in source file
  Ch: Integer;                      // next character from patch, or EOF
const
  ErrorMsg = 'Patch garbled - invalid section ''%''';
begin
  try
    // read header from patch file
    if FileRead(StdIn, Header, 16) <> 16 then
      Error('Patch not in BINARY format');
    if StrLComp(Header, PAnsiChar('bdiff' + FORMAT_VERSION + #$1A), 8) <> 0 then
      Error('Patch not in BINARY format');
    // get length of source and destination files from header
    SourceLen := GetLong(@Header[8]);
    DestLen := GetLong(@Header[12]);

    DestFileHandle := 0;
    // open source file
    SourceFileHandle := FileOpen(SourceFileName, fmOpenRead + fmShareDenyNone);
    try
      if SourceFileHandle <= 0 then
        OSError;

      // check destination file name
      if Length(DestFileName) = 0 then
        Error('Empty destination file name');

      // create temporary file
      TempFileName := GetTempFileName;
      DestFileHandle := FileCreate(TempFileName);
      if DestFileHandle <= 0 then
        Error('Can''t create temporary file');

      { apply patch }
      while True do
      begin
        Ch := fgetc(StdIn);
        if Ch = EOF then
          Break;
        case Ch of
          Integer('@'):
          begin
            // common block: copy from source
            if FileRead(StdIn, Header, 12) <> 12 then
              Error('Patch garbled - unexpected end of data');
            DataSize := GetLong(@Header[4]);
            SourceFilePos := GetLong(@Header[0]);
            if (SourceFilePos < 0) or (DataSize <= 0)
              or (SourceFilePos > SourceLen) or (DataSize > SourceLen)
              or (DataSize + SourceFilePos > SourceLen) then
              Error('Patch garbled - invalid change request');
            if fseek(SourceFileHandle, SourceFilePos, SEEK_SET) <> 0 then
              Error('''fseek'' on source file failed');
            CopyData(
              SourceFileHandle,
              DestFileHandle,
              DataSize,
              GetLong(@Header[8]),
              False
            );
            Dec(DestLen, DataSize);
          end;
          Integer('+'):
          begin
            // add data from patch file
            if FileRead(StdIn, Header, 4) <> 4 then
              Error('Patch garbled - unexpected end of data');
            DataSize := GetLong(@Header[0]);
            CopyData(StdIn, DestFileHandle, DataSize, 0, True);
            Dec(DestLen, DataSize);
          end;
          else
            Error('Patch garbled - invalid section ''%s''', [Char(Ch)]);
        end;
        if DestLen < 0 then
          Error('Patch garbled - patch file longer than announced in header');
      end;
      if DestLen <> 0 then
        Error(
          'Patch garbled - destination file shorter than announced in header'
        );

    finally
      FileClose(SourceFileHandle);
      FileClose(DestFileHandle);
    end;
    // create destination file: overwrites any existing dest file with same name
    SysUtils.DeleteFile(DestFileName);
    if not RenameFile(TempFileName, DestFileName) then
      Error('Can''t rename temporary file');
  except
    on E: Exception do
    begin
      SysUtils.DeleteFile(TempFileName);
      raise;
    end;
  end;
end;

procedure DisplayHelp;
begin
  WriteStrFmt(StdOut, '%0:s: binary ''patch'' - apply binary patch'#13#10
    + #13#10
    + 'Usage: %0:s [options] old-file [new-file] [<patch-file]'#13#10#13#10
    + 'Creates new-file from old-file and patch-file'#13#10
    + 'If new-file is not provided old-file is updated in place'#13#10
    + #13#10
    + 'Valid options:'#13#10
    + ' -i FN --input=FN     Set input file name (instead of stdin)'
    + #13#10
    + ' -h    --help         Show this help screen'#13#10
    + ' -v    --version      Show version information'#13#10
    + #13#10
    + '(c) copyright 1999 Stefan Reuther <Streu@gmx.de>'#13#10
    + '(c) copyright 2003-2009 Peter Johnson (www.delphidabbler.com)'#13#10,
    [ProgramFileName]);
end;

procedure DisplayVersion;
begin
  // NOTE: original code displayed compile date using C's __DATE__ macro. Since
  // there is no Pascal equivalent of __DATE__ we display update date of program
  // file instead
  WriteStrFmt(
    StdOut, '%s-%s %s '#13#10, [ProgramBaseName, ProgramVersion, ProgramExeDate]
  );
end;

{ Control }
procedure Main;
var
  PatchFileHandle: Integer;
  Params: TParams;
begin
  ExitCode := 0;

  Params := TParams.Create;
  try
    try
      Params.Parse;

      if Params.Help then
      begin
        DisplayHelp;
        Exit;
      end;

      if Params.Version then
      begin
        DisplayVersion;
        Exit;
      end;

      if (Params.PatchFileName <> '') and (Params.PatchFileName <> '-') then
      begin
        PatchFileHandle := FileOpen(
          Params.PatchFileName, fmOpenRead or fmShareDenyNone
        );
        if PatchFileHandle <= 0 then
          OSError;
        RedirectStdIn(PatchFileHandle);
      end;

      ApplyPatch(Params.OldFileName, Params.NewFileName);

    finally
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      ExitCode := 1;
      WriteStrFmt(StdErr, '%0:s: %1:s'#13#10, [ProgramFileName, E.Message]);
    end;
  end;

end;

end.

