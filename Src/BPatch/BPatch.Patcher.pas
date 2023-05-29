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

    ///  <summary>Computes simple checksum of a data buffer.</summary>
    ///  <param name="Data">[in] Pointer to data to be checked.</param>
    ///  <param name="DataSize">[in] Size of data in bytes.</param>
    ///  <param name="BFCheckSum">[in] Checksum b/f from any previous call.
    ///  </param>
    ///  <returns><c>Longint</c>. Updated checksum.</returns>
    class function CheckSum(Data: PAnsiChar; DataSize: Cardinal;
      const BFCheckSum: Longint): Longint;

    ///  <summary>Copies data from one stream to another, computing checksums.
    ///  </summary>
    ///  <param name="SourceFileHandle">[in] Handle to file containing data to
    ///  be copied.</param>
    ///  <param name="DestFileHandle">[in] Handle to file to receive copied
    ///  data.</param>
    ///  <param name="Count">[in] Number of bytes to copy.</param>
    ///  <param name="SourceCheckSum">[in] Checksum of data to be copied or 0 if
    ///  checksum not required.</param>
    ///  <param name="SourceIsPatch">[in] Flag indicating whether
    ///  <c>SourceFileHandle</c> is a patch file (<c>True</c>) or a source file
    ///  (<c>False</c>).</param>
    class procedure CopyData(const SourceFileHandle, DestFileHandle: THandle;
      Count, SourceCheckSum: Longint; const SourceIsPatch: Boolean);

    ///  <summary>Creates a temporary file in the user's temp directory and
    ///  returns its name.</summary>
    class function GetTempFileName: string;

    ///  <summary>Reads and validates patch file header.</summary>
    ///  <param name="SourceLen">[out] Set to length of original file.</param>
    ///  <param name="DestLen">[out] Set to length of file to be recreated.
    ///  </param>
    class procedure ReadHeader(out SourceLen, DestLen: Int32);

    ///  <summary>Reads and validate a common data header.</summary>
    ///  <param name="SourceLen">[in] Source file length.</param>
    ///  <param name="DataSize">[out] Set to length of data being copied.
    ///  </param>
    ///  <param name="SourceFilePos">[out] Set to starting position of data to
    ///  be copied.</param>
    ///  <param name="Checksum">[out] Set to checksum of data being copied.
    ///  </param>
    class procedure ReadCommonHeader(const SourceLen: Int32;
      out DataSize, SourceFilePos, Checksum: Int32);

    ///  <summary>Reads and validate a add data header.</summary>
    ///  <param name="DataSize">[out] Set to size of added data.</param>
    class procedure ReadAddHeader(out DataSize: Int32);

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
  Common.CheckSum,
  Common.Errors,
  Common.PatchHeaders;


{ TPatcher }

class procedure TPatcher.Apply(const SourceFileName, DestFileName: string);
begin
  var TempFileName: string := ''; // temporary file name
  try
    var SourceLen, DestLen: Int32;
    ReadHeader(SourceLen, DestLen);
    var DestFileHandle: THandle := 0;
    // open source file
    var SourceFileHandle: THandle := System.SysUtils.FileOpen(
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
          Integer(TPatchHeaders.CommonIndicator):
          begin
            // common block: copy from source
            var DataSize, SourceFilePos, Checksum: Int32;
            ReadCommonHeader(
              SourceLen, DataSize, SourceFilePos, Checksum
            );
            if not TIO.Seek(SourceFileHandle, SourceFilePos, SEEK_SET) then
              Error('Seek on source file failed');
            CopyData(
              SourceFileHandle, DestFileHandle, DataSize, CheckSum, False
            );
            Dec(DestLen, DataSize);
          end;
          Integer(TPatchHeaders.AddIndicator):
          begin
            // add data from patch file
            var DataSize: Int32;
            ReadAddHeader(DataSize);
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
      System.SysUtils.FileClose(SourceFileHandle);
      System.SysUtils.FileClose(DestFileHandle);
    end;
    // create destination file: overwrites any existing dest file with same name
    System.SysUtils.DeleteFile(DestFileName);
    if not System.SysUtils.RenameFile(TempFileName, DestFileName) then
      Error('Can''t rename temporary file');
  except
    on E: Exception do
    begin
      if (TempFileName = '') and System.SysUtils.FileExists(TempFileName) then
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

class procedure TPatcher.ReadAddHeader(out DataSize: Int32);
begin
  var AddHeader: TPatchHeaders.TAddedData;
  if FileRead(TIO.StdIn, AddHeader, SizeOf(AddHeader))
    <> SizeOf(AddHeader) then
    Error('Patch garbled - unexpected end of data');
  DataSize := AddHeader.DataLength.Unpack;
end;

class procedure TPatcher.ReadCommonHeader(const SourceLen: Int32;
  out DataSize, SourceFilePos, Checksum: Int32);
begin
  // read common data header
  var CommonHeader: TPatchHeaders.TCommonData;
  if FileRead(TIO.StdIn, CommonHeader, SizeOf(CommonHeader))
    <> SizeOf(CommonHeader) then
    Error('Patch garbled - unexpected end of data');
  // get data from header
  DataSize := CommonHeader.CopyLength.Unpack;
  SourceFilePos := CommonHeader.CopyStart.Unpack;
  Checksum := CommonHeader.CheckSum.Unpack;
  // do reality check on header data
  if (SourceFilePos < 0) or (DataSize <= 0)
    or (SourceFilePos > SourceLen) or (DataSize > SourceLen)
    or (DataSize + SourceFilePos > SourceLen) then
    Error('Patch garbled - invalid change request');
end;

class procedure TPatcher.ReadHeader(out SourceLen, DestLen: Int32);
begin
  // read header from patch file on standard input
  var Header: TPatchHeaders.THeader;
  if FileRead(TIO.StdIn, Header, SizeOf(Header)) <> SizeOf(Header) then
    Error('Patch not in BINARY format');
  if not Header.IsValidSignature then
    Error('Patch not in BINARY format');
  // get length of source and destination files from header
  SourceLen := Header.OldDataSize.Unpack;
  DestLen := Header.NewDataSize.Unpack;
end;

end.

