{
 * Heirachy of classes used to write various types of patch, along with factory
 * class.
 *
 * Patch generation code based on portions of bdiff.c by Stefan Reuther,
 * copyright (c) 1999 Stefan Reuther <Streu@gmx.de>.
}


unit BDiff.PatchWriters;


interface


uses
  // Project
  BDiff.Types,
  BDiff.FileData;


type

  TPatchWriter = class abstract(TObject)
  public
    procedure Header(const OldFile, NewFile: TFileData); virtual; abstract;
    procedure Add(Data: PCChar; Length: Cardinal); virtual; abstract;
    procedure Copy(NewBuf: PCCharArray; NewPos: Cardinal; OldPos: Cardinal;
      Length: Cardinal); virtual; abstract;
  end;

  TPatchWriterFactory = class(TObject)
  public
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
  TBinaryPatchWriter = class sealed(TPatchWriter)
  strict private
    type
      TPackedLong = packed array[0..3] of TCChar;
      TAddDataHeader = packed record
        DataLength: TPackedLong;
      end;
      TCopyDataHeader = packed record
        CopyStart: TPackedLong;   // starting pos of copied data
        CopyLength: TPackedLong;  // length copied data
        CheckSum: TPackedLong;    // validates copied data
      end;
      TPatchHeader = packed record
        Signature:  TPatchFileSignature;  // file signature
        OldDataSize: TPackedLong;         // size of old data file
        NewDataSize: TPackedLong;         // size of new data file
      end;
    procedure PackLong(P: PCChar; L: Longint);
    function CheckSum(Data: PCChar; Length: Cardinal): Longint;
  public
    procedure Header(const OldFile, NewFile: TFileData); override;
    procedure Add(Data: PCChar; Length: Cardinal); override;
    procedure Copy(NewBuf: PCCharArray; NewPos: Cardinal; OldPos: Cardinal;
      Length: Cardinal); override;
  end;

  TTextPatchWriter = class abstract(TPatchWriter)
  strict protected
    { Checks if an ANSI character is a printable ASCII character. }
    class function IsPrint(const Ch: AnsiChar): Boolean;
    procedure CopyHeader(NewPos: Cardinal; OldPos: Cardinal; Length: Cardinal);
    procedure Header(const OldFile, NewFile: TFileData); override;
  end;

  TQuotedPatchWriter = class sealed(TTextPatchWriter)
  strict private
    procedure QuotedData(Data: PCChar; Length: Cardinal);
    { Returns octal representation of given value as a 3 digit string. }
    class function ByteToOct(const Value: Byte): string;
  public
    procedure Add(Data: PCChar; Length: Cardinal); override;
    procedure Copy(NewBuf: PCCharArray; NewPos: Cardinal; OldPos: Cardinal;
      Length: Cardinal); override;
  end;

  TFilteredPatchWriter = class sealed (TTextPatchWriter)
  strict private
    procedure FilteredData(Data: PCChar; Length: Cardinal);
  public
    procedure Add(Data: PCChar; Length: Cardinal); override;
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
  cPlusSign: AnsiChar = '+';                // flags added data
begin
  TIO.WriteStr(TIO.StdOut, cPlusSign);
  var Rec: TAddDataHeader;
  PackLong(@Rec.DataLength, Length);
  TIO.WriteRaw(TIO.StdOut, @Rec, SizeOf(Rec));
  TIO.WriteRaw(TIO.StdOut, Data, Length);           // data added
end;

{ Compute simple checksum }
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
  cAtSign: AnsiChar = '@';                  // flags command data in both file
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

{ Pack long in little-endian format to P }
{ NOTE: P must point to a block of at least 4 bytes }
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

