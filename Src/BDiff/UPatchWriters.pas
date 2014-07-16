{
 * UPatchWriters.pas
 *
 * Heirachy of classes used to write various types of patch, along with factory
 * class.
 *
 * Patch generation code based on portions of bdiff.c by Stefan Reuther,
 * copyright (c) 1999 Stefan Reuther <Streu@gmx.de>.
 *
 * Copyright (c) 2011 Peter D Johnson (www.delphidabbler.com).
 *
 * THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY.
 * IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE
 * USE OF THIS SOFTWARE.
 *
 * For conditions of distribution and use see the LICENSE file of visit
 * http://www.delphidabbler.com/software/bdiff/license
}


unit UPatchWriters;

interface

uses
  // Project
  UBDiffTypes;

type

  TPatchWriter = class(TObject)
  public
    procedure Header(const OldFileName, NewFileName: string;
      const OldFileSize, NewFileSize: Cardinal); virtual; abstract;
    procedure Add(Data: PSignedAnsiChar; Length: Cardinal); virtual; abstract;
    procedure Copy(NewBuf: PSignedAnsiCharArray; NewPos: Cardinal;
      OldPos: Cardinal; Length: Cardinal); virtual; abstract;
  end;

  TPatchWriterFactory = class(TObject)
  public
    class function Instance(const Format: TFormat): TPatchWriter;
  end;

implementation

uses
  // Delphi
  SysUtils,
  // Project
  UBDiffUtils;

type
  TBinaryPatchWriter = class(TPatchWriter)
  private
    procedure PackLong(P: PSignedAnsiChar; L: Longint);
    function CheckSum(Data: PSignedAnsiChar; Length: Cardinal): Longint;
  public
    procedure Header(const OldFileName, NewFileName: string;
      const OldFileSize, NewFileSize: Cardinal); override;
    procedure Add(Data: PSignedAnsiChar; Length: Cardinal); override;
    procedure Copy(NewBuf: PSignedAnsiCharArray; NewPos: Cardinal;
      OldPos: Cardinal; Length: Cardinal); override;
  end;

  TTextPatchWriter = class(TPatchWriter)
  protected
    { Checks if an ANSI character is a printable ASCII character. }
    class function IsPrint(const Ch: AnsiChar): Boolean;
    procedure CopyHeader(NewPos: Cardinal; OldPos: Cardinal; Length: Cardinal);
    procedure Header(const OldFileName, NewFileName: string;
      const OldFileSize, NewFileSize: Cardinal); override;
  end;

  TQuotedPatchWriter = class(TTextPatchWriter)
  private
    procedure QuotedData(Data: PSignedAnsiChar; Length: Cardinal);
    { Returns octal representation of given value as a 3 digit string. }
    class function ByteToOct(const Value: Byte): string;
  public
    procedure Add(Data: PSignedAnsiChar; Length: Cardinal); override;
    procedure Copy(NewBuf: PSignedAnsiCharArray; NewPos: Cardinal;
      OldPos: Cardinal; Length: Cardinal); override;
  end;

  TFilteredPatchWriter = class(TTextPatchWriter)
  private
    procedure FilteredData(Data: PSignedAnsiChar; Length: Cardinal);
  public
    procedure Add(Data: PSignedAnsiChar; Length: Cardinal); override;
    procedure Copy(NewBuf: PSignedAnsiCharArray; NewPos: Cardinal;
      OldPos: Cardinal; Length: Cardinal); override;
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

procedure TBinaryPatchWriter.Add(Data: PSignedAnsiChar; Length: Cardinal);
var
  Rec: packed record
    DataLength: array[0..3] of SignedAnsiChar;  // length of added adata
  end;
const
  cPlusSign: AnsiChar = '+';                // flags added data
begin
  TIO.WriteStr(TIO.StdOut, cPlusSign);
  PackLong(@Rec.DataLength, Length);
  TIO.WriteRaw(TIO.StdOut, @Rec, SizeOf(Rec));
  TIO.WriteRaw(TIO.StdOut, Data, Length);           // data added
end;

{ Compute simple checksum }
function TBinaryPatchWriter.CheckSum(Data: PSignedAnsiChar;
  Length: Cardinal): Longint;
begin
  Result := 0;
  while Length <> 0 do
  begin
    Dec(Length);
    Result := ((Result shr 30) and 3) or (Result shl 2);
    Result := Result xor Ord(Data^);
    Inc(Data);
  end;
end;

procedure TBinaryPatchWriter.Copy(NewBuf: PSignedAnsiCharArray; NewPos, OldPos,
  Length: Cardinal);
var
  Rec: packed record
    CopyStart: array[0..3] of SignedAnsiChar;   // starting pos of copied data
    CopyLength: array[0..3] of SignedAnsiChar;  // length copied data
    CheckSum: array[0..3] of SignedAnsiChar;    // validates copied data
  end;
const
  cAtSign: AnsiChar = '@';                  // flags command data in both file
begin
  TIO.WriteStr(TIO.StdOut, cAtSign);
  PackLong(@Rec.CopyStart, OldPos);
  PackLong(@Rec.CopyLength, Length);
  PackLong(@Rec.CheckSum, CheckSum(@NewBuf[NewPos], Length));
  TIO.WriteRaw(TIO.StdOut, @Rec, SizeOf(Rec));
end;

procedure TBinaryPatchWriter.Header(const OldFileName, NewFileName: string;
  const OldFileSize, NewFileSize: Cardinal);
var
  Head: packed record
    Signature: array[0..7] of SignedAnsiChar;     // file signature
    OldDataSize: array[0..3] of SignedAnsiChar;   // size of old data file
    NewDataSize: array[0..3] of SignedAnsiChar;   // size of new data file
  end;
const
  // File signature. Must be 8 bytes. Format is 'bdiff' + file-version + #$1A
  // where file-version is a two char string, here '02'.
  // If file format is changed then increment the file version
  cFileSignature: array[0..7] of AnsiChar = 'bdiff02'#$1A;
begin
  Assert(Length(cFileSignature) = 8);
  Move(cFileSignature, Head.Signature[0], Length(cFileSignature));
  PackLong(@Head.OldDataSize, OldFileSize);
  PackLong(@Head.NewDataSize, NewFileSize);
  TIO.WriteRaw(TIO.StdOut, @Head, SizeOf(Head));
end;

{ Pack long in little-endian format to P }
{ NOTE: P must point to a block of at least 4 bytes }
procedure TBinaryPatchWriter.PackLong(P: PSignedAnsiChar; L: Integer);
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

procedure TTextPatchWriter.Header(const OldFileName, NewFileName: string;
  const OldFileSize, NewFileSize: Cardinal);
begin
  TIO.WriteStrFmt(
    TIO.StdOut,
    '%% --- %s (%d bytes)'#13#10'%% +++ %s (%d bytes)'#13#10,
    [OldFileName, OldFileSize, NewFileName, NewFileSize]
  );
end;

class function TTextPatchWriter.IsPrint(const Ch: AnsiChar): Boolean;
begin
  Result := Ch in [#32..#126];
end;

{ TQuotedPatchWriter }

procedure TQuotedPatchWriter.Add(Data: PSignedAnsiChar; Length: Cardinal);
begin
  TIO.WriteStr(TIO.StdOut, '+');
  QuotedData(Data, Length);
  TIO.WriteStr(TIO.StdOut, #13#10);
end;

class function TQuotedPatchWriter.ByteToOct(const Value: Byte): string;
var
  Idx: Integer;
  Digit: Byte;
  Remainder: Byte;
begin
  Result := '';
  Remainder := Value;
  for Idx := 1 to 3 do
  begin
    Digit := Remainder mod 8;
    Remainder := Remainder div 8;
    Result := Chr(Digit + Ord('0')) + Result;
  end;
end;

procedure TQuotedPatchWriter.Copy(NewBuf: PSignedAnsiCharArray; NewPos, OldPos,
  Length: Cardinal);
begin
  CopyHeader(NewPos, OldPos, Length);
  QuotedData(@NewBuf[NewPos], Length);
  TIO.WriteStr(TIO.StdOut, #13#10);
end;

procedure TQuotedPatchWriter.QuotedData(Data: PSignedAnsiChar;
  Length: Cardinal);
begin
  while (Length <> 0) do
  begin
    if IsPrint(Char(Data^)) and (Char(Data^) <> '\') then
      TIO.WriteStr(TIO.StdOut, Char(Data^))
    else
      TIO.WriteStr(TIO.StdOut, '\' + ByteToOct(Data^ and $FF));
    Inc(Data);
    Dec(Length);
  end;
end;

{ TFilteredPatchWriter }

procedure TFilteredPatchWriter.Add(Data: PSignedAnsiChar; Length: Cardinal);
begin
  TIO.WriteStr(TIO.StdOut, '+');
  FilteredData(Data, Length);
  TIO.WriteStr(TIO.StdOut, #13#10);
end;

procedure TFilteredPatchWriter.Copy(NewBuf: PSignedAnsiCharArray; NewPos,
  OldPos, Length: Cardinal);
begin
  CopyHeader(NewPos, OldPos, Length);
  FilteredData(@NewBuf[NewPos], Length);
  TIO.WriteStr(TIO.StdOut, #13#10);
end;

procedure TFilteredPatchWriter.FilteredData(Data: PSignedAnsiChar;
  Length: Cardinal);
begin
  while Length <> 0  do
  begin
    if IsPrint(Char(Data^)) then
      TIO.WriteStr(TIO.StdOut, Char(Data^))
    else
      TIO.WriteStr(TIO.StdOut, '.');
    Inc(Data);
    Dec(Length);
  end;
end;

end.

