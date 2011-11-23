{
 * UBDiff.pas
 *
 * Main program logic for BDiff.
 *
 * Based on bdiff.c and part of blksort.c by Stefan Reuther, copyright (c) 1999
 * Stefan Reuther <Streu@gmx.de>.
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


unit UBDiff;


interface


{ Program's main interface code: called from the project file }
procedure Main;


implementation

{$IOCHECKS OFF}

uses
  // Delphi
  SysUtils, Windows,
  // Project
  UAppInfo, UBDiffParams, UBDiffTypes, UBDiffUtils, UBlkSort, UErrors,
  UFileData, ULogger, UPatchWriters;

const
  FORMAT_VERSION  = '02';       // binary diff file format version
  BUFFER_SIZE     = 4096;       // size of buffer used to read files


{ Structure for a matching block }
type
  TMatch = record
    OldOffset: Cardinal;
    NewOffset: Cardinal;
    BlockLength: Cardinal;
  end;
  PMatch = ^TMatch;

  TDiffer = class(TObject)
  private
    fMinMatchLength: Cardinal;
    fFormat: TFormat;
    function FindMaxMatch(OldFile: TFileData; SortedOldData: PBlock;
      SearchText: PSignedAnsiChar; SearchTextLength: Cardinal): TMatch;
    ///  <summary>Finds maximum length "sub-string" of CompareData that is in
    ///  Data.</summary>
    ///  <param name="Data">PSignedAnsiCharArray [in] Data to be searched for
    ///  "sub-string".</param>
    ///  <param name="Block">PBlock [in] Block of indexes into Data that sort
    ///  sub-strings of Data.</param>
    ///  <param name="DataSize">Cardinal [in] Size of Data.</param>
    ///  <param name="CompareData">PSignedAnsiChar [in] Pointer to data to be
    ///  compared to Data.</param>
    ///  <param name="CompareDataSize">Cardinal [in] Size of data pointed to by
    ///  CompareData.</param>
    ///  <param name="FoundPos">Cardinal [out] Position in Data where
    ///  "sub-string" was found.</param>
    ///  <returns>Cardinal. Length of found "sub-string".</returns>
    function FindString(Data: PSignedAnsiCharArray; Block: PBlock;
      DataSize: Cardinal; CompareData: PSignedAnsiChar;
      CompareDataSize: Cardinal; out FoundPos: Cardinal): Cardinal;
  public
    constructor Create;
    destructor Destroy; override;
    procedure MakeDiff(const OldFileName, NewFileName: string;
      const Logger: TLogger);
    property MinMatchLength: Cardinal
      read fMinMatchLength write fMinMatchLength default 24;
    property Format: TFormat
      read fFormat write fFormat default FMT_QUOTED;
  end;

{ Display help screen  }
procedure DisplayHelp;
begin
  TIO.WriteStrFmt(
    TIO.StdOut,
    '%0:s: binary ''diff'' - compare two binary files'#13#10#13#10
      + 'Usage: %0:s [options] old-file new-file [>patch-file]'#13#10#13#10
      + 'Difference between old-file and new-file written to standard output'
      + #13#10#13#10
      + 'Valid options:'#13#10
      + ' -q                   Use QUOTED format'#13#10
      + ' -f                   Use FILTERED format'#13#10
      + ' -b                   Use BINARY format'#13#10
      + '       --format=FMT   Use format FMT (''quoted'', ''filter[ed]'' '
      + 'or ''binary'')'#13#10
      + ' -m N  --min-equal=N  Minimum equal bytes to recognize an equal chunk'
      + #13#10
      + ' -o FN --output=FN    Set output file name (instead of stdout)'#13#10
      + ' -V    --verbose      Show status messages'#13#10
      + ' -h    --help         Show this help screen'#13#10
      + ' -v    --version      Show version information'#13#10
      + #13#10
      + '(c) copyright 1999 Stefan Reuther <Streu@gmx.de>'#13#10
      + '(c) copyright 2003-2009 Peter Johnson (www.delphidabbler.com)'#13#10,
    [ProgramFileName]
  );
end;

{ Display version }
procedure DisplayVersion;
begin
  // NOTE: original code displayed compile date using C's __DATE__ macro. Since
  // there is no Pascal equivalent of __DATE__ we display update date of program
  // file instead
  TIO.WriteStrFmt(
    TIO.StdOut,
    '%s-%s %s '#13#10,
    [ProgramBaseName, ProgramVersion, ProgramExeDate]
  );
end;

{ Main routine: parses arguments and creates diff using CreateDiff() }
procedure Main;
var
  PatchFileHandle: Integer;
  Params: TParams;
  Differ: TDiffer;
  Logger: TLogger;
begin
  ExitCode := 0;

  Params := TParams.Create;
  try
    try
      Params.Parse;

      if Params.Help then
      begin
        DisplayHelp;
        Exit;
      end;

      if Params.Version then
      begin
        DisplayVersion;
        Exit;
      end;

      if (Params.PatchFileName <> '') and (Params.PatchFileName <> '-') then
      begin
        // redirect standard output to patch file
        PatchFileHandle := FileCreate(Params.PatchFileName);
        if PatchFileHandle <= 0 then
          OSError;
        TIO.RedirectStdOut(PatchFileHandle);
      end;

      // create the diff
      Logger := TLoggerFactory.Instance(Params.Verbose);
      try
        Differ := TDiffer.Create;
        try
          Differ.MinMatchLength := Params.MinEqual;
          Differ.Format := Params.Format;
          Differ.MakeDiff(Params.OldFileName, Params.NewFileName, Logger);
        finally
          Differ.Free;
        end;
      finally
        Logger.Free;
      end;

    finally
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      ExitCode := 1;
      TIO.WriteStrFmt(
        TIO.StdErr, '%0:s: %1:s'#13#10, [ProgramFileName, E.Message]
      );
    end;
  end;
end;

{ TDiffer }

constructor TDiffer.Create;
begin
  inherited Create;
  fMinMatchLength := 24;   // default minimum match length
  fFormat := FMT_QUOTED;   // default output format
end;

destructor TDiffer.Destroy;
begin
  inherited;
end;

function TDiffer.FindMaxMatch(OldFile: TFileData; SortedOldData: PBlock;
  SearchText: PSignedAnsiChar; SearchTextLength: Cardinal): TMatch;
var
  FoundPos: Cardinal;
  FoundLen: Cardinal;
begin
  Result.BlockLength := 0;  {no match}
  Result.NewOffset := 0;
  while (SearchTextLength <> 0) do
  begin
    FoundLen := FindString(
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

function TDiffer.FindString(Data: PSignedAnsiCharArray; Block: PBlock;
  DataSize: Cardinal; CompareData: PSignedAnsiChar;
  CompareDataSize: Cardinal; out FoundPos: Cardinal): Cardinal;
var
  First: Cardinal;                // first position in Data to search
  Last: Cardinal;                 // last position in Data to search
  Mid: Cardinal;                  // mid point of Data to search
  FoundSize: Cardinal;            // size of matching "sub-string"
  FoundMax: Cardinal;             // maximum size of matching "sub-string"
  PData: PSignedAnsiChar;         // ptr to char in Data to be compared
  PCompareData: PSignedAnsiChar;  // ptr to char in CompareData to be compared
begin
  First := 0;
  Last := DataSize - 1;
  Result := 0;
  FoundPos := 0;

  // Do binary search of Data
  while First <= Last do
  begin
    // Get mid point of (sorted) Data to search
    Mid := (First + Last) div 2;
    // Set pointer to start of Data search string
    PData := @Data[Block[Mid]];
    // Set pointer to start of CompareData
    PCompareData := CompareData;
    // Calculate maximum possible size of matching substring
    FoundMax := DataSize - Block[Mid];
    if FoundMax > CompareDataSize then
      FoundMax := CompareDataSize;
    // Find and count match chars from Data and CompareData
    FoundSize := 0;
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
var
  OldFile: TFileData;
  NewFile: TFileData;
  NewOffset: Cardinal;
  ToDo: Cardinal;
  SortedOldData: PBlock;
  Match: TMatch;
  PatchWriter: TPatchWriter;
begin
  { initialize }
  OldFile := nil;
  NewFile := nil;
  SortedOldData := nil;
  PatchWriter := TPatchWriterFactory.Instance(fFormat);
  try
    Logger.Log('loading old file');
    OldFile := TFileData.Create(OldFileName);
    Logger.Log('loading new file');
    NewFile := TFileData.Create(NewFileName);
    Logger.Log('block sorting old file');
    SortedOldData := BlockSort(OldFile.Data, OldFile.Size);
    if not Assigned(SortedOldData) then
      Error('virtual memory exhausted');
    Logger.Log('generating patch');
    PatchWriter.Header(OldFile.Name, NewFile.Name, OldFile.Size, NewFile.Size);
    { main loop }
    ToDo := NewFile.Size;
    NewOffset := 0;
    while (ToDo <> 0) do
    begin
      Match := FindMaxMatch(
        OldFile, SortedOldData, @NewFile.Data[NewOffset], ToDo
      );
      if Match.BlockLength <> 0 then
      begin
        { found a match }
        if Match.NewOffset <> 0 then
          { preceded by a "copy" block }
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
    // finally section new to v1.1
    if Assigned(SortedOldData) then
      FreeMem(SortedOldData);
    OldFile.Free;
    NewFile.Free;
    PatchWriter.Free;
  end;
end;

end.

