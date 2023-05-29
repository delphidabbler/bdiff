//!  BSD 3-clause license: see LICENSE.md
//!  Based, in part, on `blksort.c` by Stefan Reuther, copyright (c) 1999 Stefan
//!  Reuther <Streu@gmx.de>.

///  <summary>Implements the block sort component of the diff generator.
///  </summary>
///  <remarks>Used by BDiff only.</remarks>

unit BDiff.BlockSort;


interface


uses
  // Project
  BDiff.Types;


type

  ///  <summary>Class that implements the block sort part of the diff.</summary>
  TBlockSort = class(TObject)
  strict private
    ///  <summary>Compares elements of array of <c>TCChar</c> characters
    ///  starting from index <c>A</c>, with elements of same array starting at
    ///  index <c>B</c>.</summary>
    class function Compare(A: Cardinal; B: Cardinal; Data: PCCharArray;
      DataSize: Cardinal): Integer;
    ///  <summary>Heap sort sink.</summary>
    class procedure Sink(Left: Cardinal; Right: Cardinal; Block: PBlock;
      Data: PCCharArray; DataSize: Cardinal);
  public
    ///  <summary>Returns array of offsets into data, sorted by position.
    ///  </summary>
    ///  <param name="Data">[in] Data to be sorted. Must not be nil.</param>
    ///  <param name="DataSize"> [in] Size of data to be sorted, must be &gt; 0.
    ///  </param>
    ///  <returns><c>PBlock</c>. Pointer to block of sorted indices into Data.
    ///  Caller must free.</returns>
    ///  <exception>Raises <c>EOutOfMemory</c> if the reutned data block can't
    ///  be allocated.</exception>
    class function Execute(Data: PCCharArray; DataSize: Cardinal): PBlock;
  end;


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

}


{ TBlockSort }

class function TBlockSort.Compare(A, B: Cardinal; Data: PCCharArray;
  DataSize: Cardinal): Integer;
begin
  var PA: PCChar := @Data[A];
  var PB: PCChar := @Data[B];
  var Len: Cardinal := DataSize - A;
  if DataSize - B < Len then
    Len := DataSize - B;
  while (Len <> 0) and (PA^ = PB^) do
  begin
    Inc(PA);
    Inc(PB);
    Dec(Len);
  end;
  if Len = 0 then
    Exit(A - B);
  Result := PA^ - PB^;
end;

class function TBlockSort.Execute(Data: PCCharArray; DataSize: Cardinal):
  PBlock;
begin
  if DataSize = 0 then
    Exit(nil);

  GetMem(Result, SizeOf(Cardinal) * DataSize);

  // initialize unsorted data
  for var I := 0 to Pred(DataSize) do
    Result[I] := I;

  // heapsort
  var Left := DataSize div 2;
  var Right := DataSize;
  while Left > 0 do
  begin
    Dec(Left);
    Sink(Left, Right, Result, Data, DataSize);
  end;
  while Right > 0 do
  begin
    var Temp := Result[Left];
    Result[Left] := Result[Right-1];
    Result[Right-1] := Temp;
    Dec(Right);
    Sink(Left, Right, Result, Data, DataSize);
  end;
end;

class procedure TBlockSort.Sink(Left, Right: Cardinal; Block: PBlock;
  Data: PCCharArray; DataSize: Cardinal);
begin
  var I := Left;
  var X := Block[I];
  while True do
  begin
    var J := 2 * I + 1;
    if J >= Right then
      Break;
    if J < Right - 1 then
      if Compare(Block[J], Block[J+1], Data, DataSize) < 0 then
        Inc(J);
    if Compare(X, Block[J], Data, DataSize) > 0 then
      Break;
    Block[I] := Block[J];
    I := J;
  end;
  Block[I] := X;
end;

end.

