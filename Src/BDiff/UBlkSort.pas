{
 * UBlkSort.dpr
 *
 * Implements block sort / search mechanism.
 *
 * Based on a blksort.c by Stefan Reuther, copyright (c) 1999 Stefan Reuther
 * <Streu@gmx.de>.
 *
 * Copyright (c) 2003-2009 Peter D Johnson (www.delphidabbler.com).
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


unit UBlkSort;


interface

uses
  // Delphi
  Windows, SysUtils,
  // Project
  UBDiffTypes;


{ "exported" functions: used by main BDiff engine }

function block_sort(data: PSignedAnsiCharArray; dlen: size_t): PBlock;

function find_string(data: PSignedAnsiCharArray; block: PBlock; len: size_t;
  sub: PSignedAnsiChar; max: size_t; index: Psize_t): size_t;


implementation


{
  GENERAL IMPLEMENTATION NOTE (Stefan Reuther)

    Block-sort part of bdiff:

      Taking the data area of length N, we generate N substrings:
      - first substring is data area, length N
      - 2nd is data area sans first character, length N-1
      - ith is data area sans first i-1 characters, length N-i+1
      - Nth is last character of data area, length 1

      These strings are sorted to allow fast (i.e., binary) searching in data
      area. Of course, we don't really generate these N*N/2 bytes of strings: we
      use an array of N size_t's indexing the data.

  PASCAL IMPLEMENTATION NOTE (Peter Johnson)

    The fact that C's (ansi) Char type is signed and Pascal's is unsigned is
    relevant to the string sorting and accessing code described above. Thefore
    we use a specially defined SignedAnsiChar to maintain the data buffer to
    ensure that the the Pascal performs in the same way as the C code.
}


uses
  // Project
  UBDiffUtils;


{ Compare positions a and b in data area, consider maximum length dlen }
function block_sort_compare(a: size_t; b: size_t; data: PSignedAnsiCharArray;
  dlen: size_t): Integer;
var
  pa: PSignedAnsiChar;
  pb: PSignedAnsiChar;
  len: size_t;
begin
  pa := @data[a];
  pb := @data[b];
  len := dlen - a;
  if dlen - b < len then
    len := dlen - b;
  while (len <> 0) and (pa^ = pb^) do
  begin
    Inc(pa);
    Inc(pb);
    Dec(len);
  end;
  if len = 0 then
  begin
    Result := a - b;
    Exit;
  end;
  Result := pa^ - pb^;
end;

{ The 'sink element' part of heapsort }
procedure block_sort_sink(le: size_t; ri: size_t; block: PBlock;
  data: PSignedAnsiCharArray; dlen: size_t);
var
  i, j, x: size_t;
begin
  i := le;
  x := block[i];
  while True do
  begin
    j := 2*i+1;
    if j >= ri then
      Break;
    if j < ri-1 then
      if block_sort_compare(block[j], block[j+1], data, dlen) < 0 then
        Inc(j);
    if block_sort_compare(x, block[j], data, dlen) > 0 then
      Break;
    block[i] := block[j];
    i := j;
  end;
  block[i] := x;
end;

{ Returns array of offsets into data, sorted by position }
{ Raises EOutOfMemory if can't allocate block }
{ Returns reference to allocated block or nil if dlen = 0 }
function block_sort(data: PSignedAnsiCharArray; dlen: size_t): PBlock;
var
  block: PBlock;
  i, le, ri: size_t;
  x: size_t;
begin
  if dlen = 0 then
  begin
    Result := nil;
    Exit;
  end;

  GetMem(block, sizeof(size_t) * dlen);   // replaces call to malloc()

  { initialize unsorted data }
  for i := 0 to Pred(dlen) do
    block[i] := i;

  { heapsort }
  le := dlen div 2;
  ri := dlen;
  while le > 0 do
  begin
    Dec(le);
    block_sort_sink(le, ri, block, data, dlen);
  end;
  while ri > 0 do
  begin
    x := block[le];
    block[le] := block[ri-1];
    block[ri-1] := x;
    Dec(ri);
    block_sort_sink(le, ri, block, data, dlen);
  end;
  Result := block;
end;

{ Find maximum length substring starting at sub, at most max bytes data, block,
  len characterize source fill *index returns found location return value is
  found length }
function find_string(data: PSignedAnsiCharArray; block: PBlock; len: size_t;
  sub: PSignedAnsiChar; max: size_t; index: Psize_t): size_t;
var
  first, last: size_t;
  mid: size_t;
  l0, l: size_t;
  pm: PSignedAnsiChar;
  sm: PSignedAnsiChar;
  retval: size_t;
begin
  first := 0;
  last := len - 1;
  retval := 0;
  index^ := 0;

  while first <= last do
  begin
    mid := (first + last) div 2;
    pm := @data[block[mid]];
    sm := sub;
    l := len - block[mid];
    if l > max then
      l := max;
    l0 := l;
    while (l <> 0) and (pm^ = sm^) do
    begin
      Dec(l);
      Inc(pm);
      Inc(sm);
    end;

    { we found a `match' of length l0-l, position block[mid] }
    if l0 - l > retval then
    begin
      retval := l0 - l;
      index^ := block[mid];
    end;

    if (l = 0) or (pm^ < sm^) then
      first := mid + 1
      else
      begin
        last := mid;
        if last <> 0 then
          Dec(last)
        else
          Break;
      end;
  end;
  Result := retval;
end;

end.

