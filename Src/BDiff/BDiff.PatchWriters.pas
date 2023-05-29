//!  BSD 3-clause license: see LICENSE.md
//!  Patch generation code based on portions of `bdiff.c` by Stefan Reuther,
//!  copyright (c) 1999 Stefan Reuther <Streu@gmx.de>.

///  <summary>Heirachy of classes used to write various types of patch in BDiff.
///  </summary>
///  <remarks>Used by BDiff only.</remarks>

unit BDiff.PatchWriters;


interface


uses
  // Project
  BDiff.Types,
  BDiff.FileData;


type

  ///  <summary>Abstract base class of classes that write patch files.</summary>
  TPatchWriter = class abstract(TObject)
  public

    ///  <summary>Write patch file header.</summary>
    ///  <param name="OldFile">[in] Information about old file.</param>
    ///  <param name="NewFile">[in] Information about new file.</param>
    procedure Header(const OldFile, NewFile: TFileData); virtual; abstract;

    ///  <summary>Write added data record to patch file.</summary>
    ///  <param name="Data">[in] Pointer to data to be written.</param>
    ///  <param name="Length">[in] Length of data, in bytes.</param>
    procedure Add(Data: PCChar; Length: Cardinal); virtual; abstract;

    ///  <summary>Write common block record to patch file.</summary>
    ///  <param name="NewBuf">[in] Data in common block.</param>
    ///  <param name="NewPos">[in] Position of common block in new file.</param>
    ///  <param name="OldPos">[in] Position of common block in old file.</param>
    ///  <param name="Length">[in] Length of common block data.</param>
    procedure Copy(NewBuf: PCCharArray; NewPos: Cardinal; OldPos: Cardinal;
      Length: Cardinal); virtual; abstract;

  end;

  ///  <summary>Factory class that creates <c>TPatchWriter</c> objects to write
  ///  patches in a specified format.</summary>
  TPatchWriterFactory = class(TObject)
  public
    ///  <summary>Creates and returns a <c>TPatchWriter</c> to write in format
    ///  given by <c>Format</c>.</summary>
    ///  <remarks>User must free the created objects.</remarks>
    class function Instance(const Format: TFormat): TPatchWriter;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  // Project
  BDiff.IO,
  Common.AppInfo,
  Common.CheckSum;


type

  ///  <summary>Class that writes a binary patch file.</summary>
  TBinaryPatchWriter = class sealed(TPatchWriter)
  strict private
    type

      ///  <summary>Type of array used to store a packed longint in LSB format.
      ///  </summary>
      TPackedLong = packed array[0..3] of TCChar;

      ///  <summary>Header record written to an added data record.</summary>
      TAddDataHeader = packed record
        ///  <summary>Length of added data.</summary>
        DataLength: TPackedLong;
      end;

      ///  <summary>Header record written to a common block record.</summary>
      TCopyDataHeader = packed record
        ///  <summary>Starting position of copied data.</summary>
        CopyStart: TPackedLong;
        ///  <summary>Length of copied data.</summary>
        CopyLength: TPackedLong;
        ///  <summary>Checksum used to validate copied data.</summary>
        CheckSum: TPackedLong;
      end;

      ///  <summary>Patch file header record.</summary>
      TPatchHeader = packed record
        ///  <summary>File signature.</summary>
        Signature:  TPatchFileSignature;
        ///  <summary>Size of old file data.</summary>
        OldDataSize: TPackedLong;
        ///  <summary>Size of new file data.</summary>
        NewDataSize: TPackedLong;
      end;

    ///  <summary>Packs a long integer in little-endian format into a
    ///  <c>TCChar</c> array.</summary>
    ///  <param name="P">[in] Pointer to an array of <c>TCChar</c> in which the
    ///  long integer is to be packed.</param>
    ///  <param name="L">[in] Long integer to be packed.</param>
    ///  <remarks><c>P</c> must point to a block of memory of at least 4 bytes.
    ///  </remarks>
    procedure PackLong(P: PCChar; L: Longint);

    ///  <summary>Calcultes check sum of given data.</summary>
    ///  <param name="Data">[in] Pointer to memory containing data for which
    ///  check sum is required.</param>
    ///  <param name="Length">[in] Length of <c>Data</c>.</param>
    ///  <returns><c>Longint</c>. Required checksum.</returns>
    function CheckSum(Data: PCChar; Length: Cardinal): Longint;

  public

    ///  <summary>Write patch file header.</summary>
    ///  <param name="OldFile">[in] Information about old file.</param>
    ///  <param name="NewFile">[in] Information about new file.</param>
    procedure Header(const OldFile, NewFile: TFileData); override;

    ///  <summary>Write added data record to patch file.</summary>
    ///  <param name="Data">[in] Pointer to data to be written.</param>
    ///  <param name="Length">[in] Length of data, in bytes.</param>
    procedure Add(Data: PCChar; Length: Cardinal); override;

    ///  <summary>Write common block record to patch file.</summary>
    ///  <param name="NewBuf">[in] Data in common block.</param>
    ///  <param name="NewPos">[in] Position of common block in new file.</param>
    ///  <param name="OldPos">[in] Position of common block in old file.</param>
    ///  <param name="Length">[in] Length of common block data.</param>
    procedure Copy(NewBuf: PCCharArray; NewPos: Cardinal; OldPos: Cardinal;
      Length: Cardinal); override;

  end;

  ///  <summary>Abstract base class of patch writers that emit plain text.
  ///  </summary>
  TTextPatchWriter = class abstract(TPatchWriter)
  strict protected
    ///  <summary>Checks if ANSI character <c>Ch</c> is a printable ASCII
    ///  character.</summary>
    class function IsPrint(const Ch: AnsiChar): Boolean;

    ///  <summary>Writes a common data block header record.</summary>
    ///  <param name="NewPos">[in] Starting position of copied data.</param>
    ///  <param name="OldPos">[in] Length of copied data.</param>
    ///  <param name="Length">[in] Checksum used to validate copied data.
    ///  </param>
    procedure CopyHeader(NewPos: Cardinal; OldPos: Cardinal; Length: Cardinal);

    ///  <summary>Write patch file header.</summary>
    ///  <param name="OldFile">[in] Information about old file.</param>
    ///  <param name="NewFile">[in] Information about new file.</param>
    procedure Header(const OldFile, NewFile: TFileData); override;
  end;

  ///  <summary>Class that writes a patch file in quoted format.</summary>
  TQuotedPatchWriter = class sealed(TTextPatchWriter)
  strict private

    ///  <summary>Writes data in quoted format.</summary>
    ///  <param name="Data">[in] Pointer to data to be written.</param>
    ///  <param name="Length">[in] Length of data.</param>
    procedure QuotedData(Data: PCChar; Length: Cardinal);

    ///  <summary>Returns octal representation of given value as a 3 digit
    ///  string.</summary>
    class function ByteToOct(const Value: Byte): string;

  public

    ///  <summary>Write added data record to patch file.</summary>
    ///  <param name="Data">[in] Pointer to data to be written.</param>
    ///  <param name="Length">[in] Length of data, in bytes.</param>
    procedure Add(Data: PCChar; Length: Cardinal); override;

    ///  <summary>Write common block record to patch file.</summary>
    ///  <param name="NewBuf">[in] Data in common block.</param>
    ///  <param name="NewPos">[in] Position of common block in new file.</param>
    ///  <param name="OldPos">[in] Position of common block in old file.</param>
    ///  <param name="Length">[in] Length of common block data.</param>
    procedure Copy(NewBuf: PCCharArray; NewPos: Cardinal; OldPos: Cardinal;
      Length: Cardinal); override;

  end;

  ///  <summary>Class that writes a patch file in filtered format.</summary>
  TFilteredPatchWriter = class sealed (TTextPatchWriter)
  strict private

    ///  <summary>Writes data in filtered format.</summary>
    ///  <param name="Data">[in] Pointer to data to be written.</param>
    ///  <param name="Length">[in] Length of data.</param>
    procedure FilteredData(Data: PCChar; Length: Cardinal);

  public

    ///  <summary>Write added data record to patch file.</summary>
    ///  <param name="Data">[in] Pointer to data to be written.</param>
    ///  <param name="Length">[in] Length of data, in bytes.</param>
    procedure Add(Data: PCChar; Length: Cardinal); override;

    ///  <summary>Write common block record to patch file.</summary>
    ///  <param name="NewBuf">[in] Data in common block.</param>
    ///  <param name="NewPos">[in] Position of common block in new file.</param>
    ///  <param name="OldPos">[in] Position of common block in old file.</param>
    ///  <param name="Length">[in] Length of common block data.</param>
    procedure Copy(NewBuf: PCCharArray; NewPos: Cardinal; OldPos: Cardinal;
      Length: Cardinal); override;

  end;

{ TPatchWriterFactory }

class function TPatchWriterFactory.Instance(
  const Format: TFormat): TPatchWriter;
begin
  case Format of
    FMT_BINARY: Result := TBinaryPatchWriter.Create;
    FMT_FILTERED: Result := TFilteredPatchWriter.Create;
    FMT_QUOTED: Result := TQuotedPatchWriter.Create;
    else raise Exception.Create('Invalid format type');
  end;
end;

{ TBinaryPatchWriter }

procedure TBinaryPatchWriter.Add(Data: PCChar; Length: Cardinal);
const
  cPlusSign: AnsiChar = '+';  // flags added data
begin
  TIO.WriteStr(TIO.StdOut, cPlusSign);
  var Rec: TAddDataHeader;
  PackLong(@Rec.DataLength, Length);
  TIO.WriteRaw(TIO.StdOut, @Rec, SizeOf(Rec));
  TIO.WriteRaw(TIO.StdOut, Data, Length);
end;

function TBinaryPatchWriter.CheckSum(Data: PCChar; Length: Cardinal): Longint;
begin
  var CS := TCheckSum.Create(0);
  try
    CS.AddBuffer(PInt8(Data), Length);
    Result := CS.CheckSum;
  finally
    CS.Free;
  end;
end;

procedure TBinaryPatchWriter.Copy(NewBuf: PCCharArray; NewPos, OldPos,
  Length: Cardinal);
const
  cAtSign: AnsiChar = '@';    // flags common data in both file
begin
  TIO.WriteStr(TIO.StdOut, cAtSign);
  var Rec: TCopyDataHeader;
  PackLong(@Rec.CopyStart, OldPos);
  PackLong(@Rec.CopyLength, Length);
  PackLong(@Rec.CheckSum, CheckSum(@NewBuf[NewPos], Length));
  TIO.WriteRaw(TIO.StdOut, @Rec, SizeOf(Rec));
end;

procedure TBinaryPatchWriter.Header(const OldFile, NewFile: TFileData);
begin
  var Head: TPatchHeader;
  Assert(Length(TAppInfo.PatchFileSignature) = Length(Head.Signature));
  Move(
    TAppInfo.PatchFileSignature,
    Head.Signature[0],
    Length(TAppInfo.PatchFileSignature)
  );
  PackLong(@Head.OldDataSize, OldFile.Size);
  PackLong(@Head.NewDataSize, NewFile.Size);
  TIO.WriteRaw(TIO.StdOut, @Head, SizeOf(Head));
end;

procedure TBinaryPatchWriter.PackLong(P: PCChar; L: Integer);
begin
  P^ := L and $FF;
  Inc(P);
  P^ := (L shr 8) and $FF;
  Inc(P);
  P^ := (L shr 16) and $FF;
  Inc(P);
  P^ := (L shr 24) and $FF;
end;

{ TTextPatchWriter }

procedure TTextPatchWriter.CopyHeader(NewPos, OldPos, Length: Cardinal);
begin
  TIO.WriteStrFmt(
    TIO.StdOut,
    '@ -[%d] => +[%d] %d bytes'#13#10' ',
    [OldPos, NewPos, Length]
  );
end;

procedure TTextPatchWriter.Header(const OldFile, NewFile: TFileData);
begin
  TIO.WriteStrFmt(
    TIO.StdOut,
    '%% --- %s (%d bytes)'#13#10'%% +++ %s (%d bytes)'#13#10,
    [OldFile.Name, OldFile.Size, NewFile.Name, NewFile.Size]
  );
end;

class function TTextPatchWriter.IsPrint(const Ch: AnsiChar): Boolean;
begin
  Result := Ch in [#32..#126];
end;

{ TQuotedPatchWriter }

procedure TQuotedPatchWriter.Add(Data: PCChar; Length: Cardinal);
begin
  TIO.WriteStr(TIO.StdOut, '+');
  QuotedData(Data, Length);
  TIO.WriteStr(TIO.StdOut, #13#10);
end;

class function TQuotedPatchWriter.ByteToOct(const Value: Byte): string;
begin
  Result := '';
  var Remainder: Byte := Value;
  for var Idx := 1 to 3 do
  begin
    var Digit: Byte := Remainder mod 8;
    Remainder := Remainder div 8;
    Result := Chr(Digit + Ord('0')) + Result;
  end;
end;

procedure TQuotedPatchWriter.Copy(NewBuf: PCCharArray; NewPos, OldPos,
  Length: Cardinal);
begin
  CopyHeader(NewPos, OldPos, Length);
  QuotedData(@NewBuf[NewPos], Length);
  TIO.WriteStr(TIO.StdOut, #13#10);
end;

procedure TQuotedPatchWriter.QuotedData(Data: PCChar; Length: Cardinal);
begin
  while (Length <> 0) do
  begin
    if IsPrint(AnsiChar(Data^)) and (AnsiChar(Data^) <> '\') then
      TIO.WriteStr(TIO.StdOut, AnsiChar(Data^))
    else
      TIO.WriteStr(TIO.StdOut, '\' + ByteToOct(Data^ and $FF));
    Inc(Data);
    Dec(Length);
  end;
end;

{ TFilteredPatchWriter }

procedure TFilteredPatchWriter.Add(Data: PCChar; Length: Cardinal);
begin
  TIO.WriteStr(TIO.StdOut, '+');
  FilteredData(Data, Length);
  TIO.WriteStr(TIO.StdOut, #13#10);
end;

procedure TFilteredPatchWriter.Copy(NewBuf: PCCharArray; NewPos, OldPos,
  Length: Cardinal);
begin
  CopyHeader(NewPos, OldPos, Length);
  FilteredData(@NewBuf[NewPos], Length);
  TIO.WriteStr(TIO.StdOut, #13#10);
end;

procedure TFilteredPatchWriter.FilteredData(Data: PCChar; Length: Cardinal);
begin
  while Length <> 0  do
  begin
    if IsPrint(AnsiChar(Data^)) then
      TIO.WriteStr(TIO.StdOut, AnsiChar(Data^))
    else
      TIO.WriteStr(TIO.StdOut, '.');
    Inc(Data);
    Dec(Length);
  end;
end;

end.

