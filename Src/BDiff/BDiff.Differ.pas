//!  BSD 3-clause license: see LICENSE.md
//!  Based on `bdiff.c` and part of `blksort.c` by Stefan Reuther, copyright (c)
//!  1999 Stefan Reuther <Streu@gmx.de>.

///  <summary>Main diff generation code.</summary>
///  <remarks>Used by BDiff only.</remarks>

unit BDiff.Differ;


interface


uses
  // Project
  BDiff.FileData,
  BDiff.Logger,
  BDiff.Types;


type

  ///  <summary>Class that generates the diff.</summary>
  TDiffer = class(TObject)
  strict private

    type
      ///  <summary>Structure for a matching block.</summary>
      TMatch = record
        OldOffset: Cardinal;
        NewOffset: Cardinal;
        BlockLength: Cardinal;
      end;

    var
      // Property values
      fMinMatchLength: Cardinal;
      fFormat: TFormat;

    ///  <summary>Finds a maximum length match a given search string in the old
    ///  file and returns a <c>TMatch</c> record that describes the match.
    ///  </summary>
    function FindMaxMatch(OldFile: TFileData; SortedOldData: PBlock;
      SearchText: PCChar; SearchTextLength: Cardinal): TMatch;

    ///  <summary>Finds maximum length sub-string of <c>CompareData</c> that is
    ///  in <c>Data</c>.</summary>
    ///  <param name="Data">[in] Data to be searched for sub-string.</param>
    ///  <param name="Block">[in] Block of indexes into <c>Data</c> that sort
    ///  sub-strings of <c>Data</c>.</param>
    ///  <param name="DataSize">[in] Size of <c>Data</c>.</param>
    ///  <param name="CompareData">[in] Pointer to data to be compared to
    ///  <c>Data</c>.</param>
    ///  <param name="CompareDataSize">[in] Size of data pointed to by
    ///  <c>CompareData</c>.</param>
    ///  <param name="FoundPos">[out] Position in <c>Data</c> where sub-string
    ///  was found.</param>
    ///  <returns><c>Cardinal</c>. Length of found sub-string.</returns>
    function FindString(Data: PCCharArray; Block: PBlock; DataSize: Cardinal;
      CompareData: PCChar; CompareDataSize: Cardinal; out FoundPos: Cardinal):
      Cardinal;

  public

    ///  <summary>Object constructor. Sets default property values.</summary>
    constructor Create;

    ///  <summary>Generate diff in required format and write to patch file.
    ///  </summary>
    ///  <param name="OldFileName">[in] Name of old file.</param>
    ///  <param name="NewFileName">[in] Name of new file to be compared to old
    ///  file.</param>
    ///  <param name="Logger">[in] Object to be used to log output information.
    ///  </param>
    procedure MakeDiff(const OldFileName, NewFileName: string;
      const Logger: TLogger);

    ///  <summary>Minimum length of data chunks that can be recognized as equal.
    ///  </summary>
    property MinMatchLength: Cardinal
      read fMinMatchLength write fMinMatchLength default 24;

    ///  <summary>Format of generated diff.</summary>
    property Format: TFormat
      read fFormat write fFormat default FMT_QUOTED;
  end;


implementation


{$IOCHECKS OFF}


uses
  // Project
  BDiff.BlockSort,
  BDiff.PatchWriters,
  Common.Errors;


{ TDiffer }

constructor TDiffer.Create;
begin
  inherited Create;
  fMinMatchLength := 24;   // default minimum match length
  fFormat := FMT_QUOTED;   // default output format
end;

function TDiffer.FindMaxMatch(OldFile: TFileData; SortedOldData: PBlock;
  SearchText: PCChar; SearchTextLength: Cardinal): TMatch;
begin
  Result.BlockLength := 0;  {no match}
  Result.NewOffset := 0;
  while (SearchTextLength <> 0) do
  begin
    var FoundPos: Cardinal;
    var FoundLen := FindString(
      OldFile.Data,
      SortedOldData,
      OldFile.Size,
      SearchText,
      SearchTextLength,
      FoundPos
    );
    if FoundLen >= fMinMatchLength then
    begin
      Result.OldOffset := FoundPos;
      Result.BlockLength := FoundLen;
      Exit;
    end;
    Inc(SearchText);
    Inc(Result.NewOffset);
    Dec(SearchTextLength);
  end;
end;

function TDiffer.FindString(Data: PCCharArray; Block: PBlock;
  DataSize: Cardinal; CompareData: PCChar; CompareDataSize: Cardinal;
  out FoundPos: Cardinal): Cardinal;
begin
  var First: Cardinal := 0;
  var Last: Cardinal := DataSize - 1;
  Result := 0;
  FoundPos := 0;

  // Do binary search of Data
  while First <= Last do
  begin
    // Get mid point of (sorted) Data to search
    var Mid: Cardinal := (First + Last) div 2;
    // Set pointer to start of Data search string
    var PData: PCChar := @Data[Block[Mid]];
    // Set pointer to start of CompareData
    var PCompareData: PCChar := CompareData;
    // Calculate maximum possible size of matching substring
    var FoundMax: Cardinal := DataSize - Block[Mid];
    if FoundMax > CompareDataSize then
      FoundMax := CompareDataSize;
    // Find and count match chars from Data and CompareData
    var FoundSize: Cardinal := 0;
    while (FoundSize < FoundMax) and (PData^ = PCompareData^) do
    begin
      Inc(FoundSize);
      Inc(PData);
      Inc(PCompareData);
    end;

    // We found a "match" of length FoundSize, position Block[Mid]
    if FoundSize > Result then
    begin
      Result := FoundSize;
      FoundPos := Block[Mid];
    end;

    // Determine next search area
    // Note: If FoundSize = FoundMatch then substrings match
    if (FoundSize = FoundMax) or (PData^ < PCompareData^) then
      // substring <= current data string: search above
      First := Mid + 1
    else
      // substring < current data string: search below
      begin
        Last := Mid;
        if Last <> 0 then
          Dec(Last)
        else
          Break;
      end;
  end;
end;

procedure TDiffer.MakeDiff(const OldFileName, NewFileName: string;
  const Logger: TLogger);
begin
  // initialize
  var OldFile: TFileData := nil;
  var NewFile: TFileData := nil;
  var SortedOldData: PBlock := nil;
  var PatchWriter := TPatchWriterFactory.CreateInstance(fFormat);
  try
    Logger.Log('loading old file');
    OldFile := TFileData.Create(OldFileName);
    Logger.Log('loading new file');
    NewFile := TFileData.Create(NewFileName);
    Logger.Log('block sorting old file');
    SortedOldData := TBlockSort.Execute(OldFile.Data, OldFile.Size);
    if not Assigned(SortedOldData) then
      Error('virtual memory exhausted');
    Logger.Log('generating patch');
    PatchWriter.Header(OldFile, NewFile);
    // main loop
    var ToDo := NewFile.Size;
    var NewOffset: Cardinal := 0;
    while (ToDo <> 0) do
    begin
      var Match := FindMaxMatch(
        OldFile, SortedOldData, @NewFile.Data[NewOffset], ToDo
      );
      if Match.BlockLength <> 0 then
      begin
        // found a match
        if Match.NewOffset <> 0 then
          // preceded by a "copy" block
          PatchWriter.Add(@NewFile.Data[NewOffset], Match.NewOffset);
        Inc(NewOffset, Match.NewOffset);
        Dec(ToDo, Match.NewOffset);
        PatchWriter.Copy(
          NewFile.Data, NewOffset, Match.OldOffset, Match.BlockLength
        );
        Inc(NewOffset, Match.BlockLength);
        Dec(ToDo, Match.BlockLength);
      end
      else
      begin
        PatchWriter.Add(@NewFile.Data[NewOffset], ToDo);
        Break;
      end;
    end;
    Logger.Log('done');
  finally
    if Assigned(SortedOldData) then
      FreeMem(SortedOldData);
    OldFile.Free;
    NewFile.Free;
    PatchWriter.Free;
  end;
end;

end.

