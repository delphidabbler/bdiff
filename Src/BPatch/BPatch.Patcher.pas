//!  BSD 3-clause license: see LICENSE.md

///  <summary>Applies patch to file.</summary>
///  <remarks>Used by BPatch only.</remarks>

unit BPatch.Patcher;


interface


type

  ///  <summary>Class that recreates a new version of a file from the old file
  ///  and binary patch.</summary>
  TPatcher = class(TObject)
  strict private

    const
      ///  <summary>Size of buffer used when reading files.</summary>
      BUFFER_SIZE = 4096;

    type
      ///  <summary>Buffer used when reading from a file.</summary>
      TBuffer = array[0..Pred(BUFFER_SIZE)] of AnsiChar;
      ///  <summary>Buffer used to read patch file header into.</summary>
      THeader = array[0..15] of AnsiChar;

    ///  <summary>Computes simple checksum of a data buffer.</summary>
    ///  <param name="Data">[in] Pointer to data to be checked.</param>
    ///  <param name="DataSize">[in] Size of data in bytes.</param>
    ///  <param name="BFCheckSum">[in] Checksum b/f from any previous call.
    ///  </param>
    ///  <returns><c>Longint</c>. Updated checksum.</returns>
    class function CheckSum(Data: PAnsiChar; DataSize: Cardinal;
      const BFCheckSum: Longint): Longint;

    ///  <summary>Extract long integer value packed into a 4 byte array of ANSI
    ///  characters.</summary>
    ///  <param name="PCh">[in] Points to array of ANSI characters. Must be at
    ///  least 4 bytes long.</param>
    ///  <returns><c>Longint</c>. Unpacked long integer.</returns>
    class function GetLong(PCh: PAnsiChar): Longint;

    ///  <summary>Copies data from one stream to another, computing checksums.
    ///  </summary>
    ///  <param name="SourceFileHandle">[in] Handle to file containing data to
    ///  be copied.</param>
    ///  <param name="DestFileHandle">[in] Handle to file to receive copied
    ///  data.</param>
    ///  <param name="Count">[in] Number of bytes to copy.</param>
    ///  <param name="SourceCheckSum">[in] Checksum of data to be copied.
    ///  </param>
    ///  <param name="SourceIsPatch">[in] Flag indicating whether
    ///  <c>SourceFileHandle</c> is a patch file (<c>True</c>) or a source file
    ///  (<c>False</c>).</param>
    class procedure CopyData(const SourceFileHandle, DestFileHandle: THandle;
      Count, SourceCheckSum: Longint; const SourceIsPatch: Boolean);

    ///  <summary>Creates a temporary file in the user's temp directory and
    ///  returns its name.</summary>
    class function GetTempFileName: string;

  public

    ///  <summary>Applies patch from standard input to file
    ///  <c>SourceFileName</c> and regenerates file <c>DestFileName</c>.
    ///  </summary>
    class procedure Apply(const SourceFileName, DestFileName: string);

  end;


implementation


{$IOCHECKS OFF}


uses
  // Delphi
  System.SysUtils,
  System.AnsiStrings,
  Winapi.Windows,
  // Project
  BPatch.InfoWriter,
  BPatch.IO,
  BPatch.Params,
  Common.AppInfo,
  Common.CheckSum,
  Common.Errors;


{ TPatcher }

class procedure TPatcher.Apply(const SourceFileName, DestFileName: string);
begin
  var TempFileName: string; // temporary file name
  try
    // read header from patch file on standard input
    var Header: THeader;
    if FileRead(TIO.StdIn, Header, Length(Header)) <> Length(Header) then
      Error('Patch not in BINARY format');
    if System.AnsiStrings.StrLComp(
      Header, TAppInfo.PatchFileSignature, Length(TAppInfo.PatchFileSignature)
    ) <> 0 then
      Error('Patch not in BINARY format');
    // get length of source and destination files from header
    var SourceLen := GetLong(@Header[8]);
    var DestLen := GetLong(@Header[12]);

    var DestFileHandle: THandle := 0;
    // open source file
    var SourceFileHandle: THandle := FileOpen(
      SourceFileName, fmOpenRead + fmShareDenyNone
    );
    try
      if NativeInt(SourceFileHandle) <= 0 then
        OSError;

      // check destination file name
      if Length(DestFileName) = 0 then
        Error('Empty destination file name');

      // create temporary file
      TempFileName := GetTempFileName;
      DestFileHandle := FileCreate(TempFileName);
      if NativeInt(DestFileHandle) <= 0 then
        Error('Can''t create temporary file');

      // apply patch
      while True do
      begin
        var Ch := TIO.GetCh(TIO.StdIn);
        if Ch = EOF then
          Break;
        case Ch of
          Integer('@'):
          begin
            // common block: copy from source
            if FileRead(TIO.StdIn, Header, 12) <> 12 then
              Error('Patch garbled - unexpected end of data');
            var DataSize := GetLong(@Header[4]);
            var SourceFilePos := GetLong(@Header[0]);
            if (SourceFilePos < 0) or (DataSize <= 0)
              or (SourceFilePos > SourceLen) or (DataSize > SourceLen)
              or (DataSize + SourceFilePos > SourceLen) then
              Error('Patch garbled - invalid change request');
            if not TIO.Seek(SourceFileHandle, SourceFilePos, SEEK_SET) then
              Error('Seek on source file failed');
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
            if FileRead(TIO.StdIn, Header, 4) <> 4 then
              Error('Patch garbled - unexpected end of data');
            var DataSize := GetLong(@Header[0]);
            CopyData(TIO.StdIn, DestFileHandle, DataSize, 0, True);
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
    System.SysUtils.DeleteFile(DestFileName);
    if not RenameFile(TempFileName, DestFileName) then
      Error('Can''t rename temporary file');
  except
    on E: Exception do
    begin
      System.SysUtils.DeleteFile(TempFileName);
      raise;
    end;
  end;
end;

class function TPatcher.CheckSum(Data: PAnsiChar; DataSize: Cardinal;
  const BFCheckSum: Integer): Longint;
begin
  var CS := TCheckSum.Create(BFCheckSum);
  try
    CS.AddBuffer(PInt8(Data), DataSize);
    Result := CS.CheckSum;
  finally
    CS.Free;
  end;
end;

class procedure TPatcher.CopyData(const SourceFileHandle,
  DestFileHandle: THandle; Count, SourceCheckSum: Integer;
  const SourceIsPatch: Boolean);
begin
  var DestCheckSum: Longint := 0;

  while Count <> 0 do
  begin
    var BytesToCopy: Cardinal;
    if Count > BUFFER_SIZE then
      BytesToCopy := BUFFER_SIZE
    else
      BytesToCopy := Count;

    var Buffer: TBuffer;
    if FileRead(SourceFileHandle, Buffer, BytesToCopy)
      <> Integer(BytesToCopy) then
    begin
      if TIO.AtEOF(SourceFileHandle) then
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

class function TPatcher.GetLong(PCh: PAnsiChar): Longint;
begin
  var PB := PByte(PCh);
  var LW: LongWord := PB^;
  Inc(PB);
  LW := LW + 256 * PB^;
  Inc(PB);
  LW := LW + 65536 * PB^;
  Inc(PB);
  LW := LW + 16777216 * PB^;
  Result := LW;
end;

class function TPatcher.GetTempFileName: string;
begin
  // Get temporary folder
  SetLength(Result, Winapi.Windows.MAX_PATH);
  Winapi.Windows.GetTempPath(Winapi.Windows.MAX_PATH, PChar(Result));
  // Get unique temporary file name (it is created as side effect of this call)
  if Winapi.Windows.GetTempFileName(
    PChar(Result), '', 0, PChar(Result)
  ) = 0 then
    Error('Can''t create temporary file');
  Result := PChar(Result)
end;

end.

