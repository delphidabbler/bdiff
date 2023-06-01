//!  BSD 3-clause license: see LICENSE.md

///  <summary>General type declarations.</summary>
///  <remarks>Code common to both BDiff and BPatch.</remarks>

unit Common.Types;


interface


type

  ///  <summary>Emulation of C's <c>char</c> type.</summary>
  ///  <remarks>This type was defined since the original C code uses
  ///  <c>char</c>, which is signed, while the Pascal <c>Char</c> type is
  ///  unsigned. This type made translation of the C code easier.</remarks>
  TCChar = type Int8;

  ///  <summary>Pointer to <c>TCChar</c>.</summary>
  PCChar = ^TCChar;


implementation


end.
