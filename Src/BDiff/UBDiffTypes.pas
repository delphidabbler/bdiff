{
 * UBDiffTypes.pas
 *
 * Contains type declarations for BDiff.
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


unit UBDiffTypes;


interface


type
  { size_t type is used extensively in C and in original code for this program.
    We therefore define the size_t and "pointer to size_t" types }
  size_t = Cardinal;
  Psize_t = ^size_t;

  { Some uses of *size_t in original C code actually reference an array of
    size_t and are referenced using array[] notation. The following types are
    declared to use in these circumstances to enable similar notation in
    Pascal }
  TBlock = array[0..0] of size_t;
  PBlock = ^TBlock;

  { The original C code refers to the buffered file contents as an array of
    Char. The fact that Char is signed in C (-127..128) and unsigned in Pascal
    (0..255) means that the block sort algorithm and string lookup functions
    operate differently in C and Pascal. We therefore define a signed *ansi*
    char type - SignedAnsiChar - of the correct range and refer to the buffered
    file contents as an array of this new type. Since ShortInt is defined as
    (-127..128) we use this as the basis for SignedAnsiChar}
  SignedAnsiChar = type ShortInt;
  PSignedAnsiChar = ^SignedAnsiChar;
  TSignedAnsiCharArray = array[0..(MaxInt div SizeOf(SignedAnsiChar) - 1)]
    of SignedAnsiChar;
  PSignedAnsiCharArray = ^TSignedAnsiCharArray;

  { Output format to use }
  TFormat = (FMT_BINARY, FMT_FILTERED, FMT_QUOTED);

implementation


end.

