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


{ emulates C std lib isprint function: does not support locales }
function isprint(Ch: AnsiChar): Boolean;  // todo: note changed to ansichar from char

{ cut down version of C std lib strtoul function that only supports base 10 }
function StrToULDec(const s: PChar; var endp: PChar): LongWord;

{ helper function that returns the octal representation of the given byte as a
  string: note that the value has no leading '\', just the digits }
function ByteToOct(V: Byte): string;


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

end.

