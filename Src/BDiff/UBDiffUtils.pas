{
 * UBDiffUtils.pas
 *
 * Contains utility functions used for BDiff. Includes Pascal implementations
 * of, or alternatives for, some standard C library code.
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


unit UBDiffUtils;


interface


uses
  // Delphi
  Windows;


{ emulates C std lib stdin value by returning Windows standard output handle }
function stdout: Integer;

{ emulates C std lib stdin value by returning Windows standard error handle }
function stderr: Integer;

{ redirects stdout to a given file handle }
procedure RedirectStdOut(const Handle: Integer);

{ emulates C std lib isprint function: does not support locales }
function isprint(Ch: AnsiChar): Boolean;  // todo: note changed to ansichar from char

{ cut down version of C std lib strtoul function that only supports base 10 }
function StrToULDec(const s: PChar; var endp: PChar): LongWord;

{ helper function that returns the octal representation of the given byte as a
  string: note that the value has no leading '\', just the digits }
function ByteToOct(V: Byte): string;

{ writes binary data to a file: this is a C fwrite replacement }
procedure WriteBin(Handle: THandle; BufPtr: Pointer; Size: Integer);

{ writes a single character or string to a file: used in place of C's string or
  char output functions where string does not need formatting }
procedure WriteStr(Handle: THandle; const S: string);

{ writes a string built from format string and arguments to file: used in place
  of C's fprintf and printf functions (but doesn't handle \n etc }
procedure WriteStrFmt(Handle: THandle; const Fmt: string; Args: array of const);


implementation


uses
  // Delphi
  SysUtils;


{ helper function that returns the octal representation of the given byte as a
  string: note that the value has no leading '\', just the digits }
function ByteToOct(V: Byte): string;
var
  Idx: Integer;
  M: Byte;
begin
  Result := '';
  for Idx := 1 to 3 do
  begin
    M := V mod 8;
    V := V div 8;
    Result := Chr(M + Ord('0')) + Result;
  end;
end;

{ emulates C std lib stdin value by returning Windows standard output handle }
function stdout: Integer;
begin
  Result := Integer(GetStdHandle(STD_OUTPUT_HANDLE));
end;

{ emulates C std lib stdin value by returning Windows standard error handle }
function stderr: Integer;
begin
  Result := Integer(GetStdHandle(STD_ERROR_HANDLE));
end;

{ redirects stdout to a given file handle }
procedure RedirectStdOut(const Handle: Integer);
begin
  SetStdHandle(STD_OUTPUT_HANDLE, Cardinal(Handle));
end;

{ emulates C std lib isprint function: does not support locales }
function isprint(Ch: AnsiChar): Boolean;
begin
  Result := Ch in [#32..#126];
end;

{ cut down version of C std lib strtoul function that only supports base 10 }
function StrToULDec(const s: PChar; var endp: PChar): LongWord;
begin
  endp := s;
  Result := 0;
  while endp^ in ['0'..'9'] do
  begin
    Result := 10 * Result + LongWord((Ord(endp^) - Ord('0')));
    inc(endp);
  end;
end;

{ writes binary data to a file: this is a C fwrite replacement }
procedure WriteBin(Handle: THandle; BufPtr: Pointer; Size: Integer);
var
  Dummy: DWORD;
begin
  Windows.WriteFile(Handle, BufPtr^, Size, Dummy, nil);
end;

{ writes a single character or string to a file: used in place of C's string or
  char output functions where string does not need formatting }
procedure WriteStr(Handle: THandle; const S: string);
begin
  WriteBin(Handle, PChar(S), Length(S));
end;

{ writes a string built from format string and arguments to file: used in place
  of C's fprintf and printf functions (but doesn't handle \n etc }
procedure WriteStrFmt(Handle: THandle; const Fmt: string; Args: array of const);
begin
  WriteStr(Handle, Format(Fmt, Args));
end;

end.

