{
 * Contains type declarations for BDiff.
}


unit UBDiffTypes;


interface


type
  { Some uses of *size_t in original C code actually reference an array of
    size_t and are referenced using array[] notation. The following types are
    declared to use in these circumstances to enable similar notation in
    Pascal }
  TBlock = array[0..0] of Cardinal;
  PBlock = ^TBlock;

  {
    Some of the original C code, for example the block sort algorithm and string
    lookup functions, depended on the fact that the C char type is signed, with
    range (-127..128). Therefore, where those assumptions hold, we replace char
    with the Pascal Int8 type, which has the same range. Since the C code also
    used char arrays and char pointers, the following types are defined to
    enable the Pascal code to emulate this usage:
  }
  TCChar = type Int8;
  PCChar = ^TCChar;
  TCCharArray = array[0..(MaxInt div SizeOf(TCChar) - 1)] of TCChar;
  PCCharArray = ^TCCharArray;

  { Output format to use }
  TFormat = (FMT_BINARY, FMT_FILTERED, FMT_QUOTED);

implementation


end.

