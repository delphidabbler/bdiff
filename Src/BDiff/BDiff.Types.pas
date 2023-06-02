//!  BSD 3-clause license: see LICENSE.md

///  <summary>General type declarations specific to BDiff.</summary>
///  <remarks>Used by BDiff only.</remarks>

unit BDiff.Types;


interface


uses
  // Project
  Common.Types;


type

  ///  <summary>Type that enables array <c>[]</c> notation to be used with
  ///  pointers to blocks of <c>Int32</c>.</summary>
  ///  <remarks>The original C code uses <c>*size_t</c> pointers that are
  ///  accessed using array <c>[]</c> notation. <c>TBlock</c> enables this to be
  ///  done in Pascal, except that <c>size_t</c> is replaced by <c>Int32</c>,
  ///  since all file sizes and positions are in range 0..<c>MaxInt</c>.
  ///  </remarks>
  TBlock = array[0..0] of Int32;

  ///  <summary>Pointer to a <c>TBlock</c> array.</summary>
  PBlock = ^TBlock;

  ///  <summary>Array of <c>TCChar</c>.</summary>
  ///  <remarks>This class is provided to ease translation of the original C
  ///  code, which used <c>char</c> array pointers access via the array
  ///  <c>[]</c> operator.</remarks>
  TCCharArray = array[0..(MaxInt div SizeOf(TCChar) - 1)] of TCChar;

  ///  <summary>Pointer to an array of <c>TCChar</c>.</summary>
  PCCharArray = ^TCCharArray;

  ///  <summary>Enumeration of supported patch file formats.</summary>
  TFormat = (FMT_BINARY, FMT_FILTERED, FMT_QUOTED);


implementation


end.

