{
 * UBDiff.pas
 *
 * Main program logic for BDiff.
 *
 * Based on bdiff.c by Stefan Reuther, copyright (c) 1999 Stefan Reuther
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
  UAppInfo, UBDiffTypes, UBDiffUtils, UBlkSort, UErrors;

const
  FORMAT_VERSION  = '02';       // binary diff file format version
  BUFFER_SIZE     = 4096;       // size of buffer used to read files


{ Output format to use }
type
  TFormat = (FMT_BINARY, FMT_FILTERED, FMT_QUOTED);


{ Structure for a matching block }
type
  TMatch = record
    OldFilePos: size_t;
    NewFilePos: size_t;
    Length: size_t;
  end;
  PMatch = ^TMatch;

{ Global variables }
var
  gMinMatchLength: size_t = 24;  // default minimum match length
  gFormat: TFormat = FMT_QUOTED; // default output format
  gVerbose: Integer = 0;         // verbose mode defaults to off / false

{ Record used to reference output generation routines for a format }
type
  TFormatSpec = record
    Header:
      procedure(OldFileName, NewFileName: string;
        OldFileSize, NewFileSize: size_t);
    Add:
      procedure(Data: PSignedAnsiChar; Length: size_t);
    Copy:
      // todo: remove unused OldBuf param
      procedure(NewBuf: PSignedAnsiCharArray; NewPos: size_t;
        OldBuf: PSignedAnsiCharArray; OldPos: size_t; Length: size_t);
  end;

procedure PrintBinaryHeader(OldFileName, NewFileName: string;
  OldFileSize, NewFileSize: size_t);
  forward;
procedure PrintTextHeader(OldFileName, NewFileName: string;
  OldFileSize, NewFileSize: size_t);
  forward;
procedure PrintBinaryAdd(Data: PSignedAnsiChar; Length: size_t);
  forward;
procedure PrintFilteredAdd(Data: PSignedAnsiChar; Length: size_t);
  forward;
procedure PrintQuotedAdd(Data: PSignedAnsiChar; Length: size_t);
  forward;
// todo: remove unused OldBuf param
procedure PrintTextCopy(NewBuf: PSignedAnsiCharArray; NewPos: size_t;
  OldBuf: PSignedAnsiCharArray; OldPos: size_t; Length: size_t);
  forward;
// todo: remove unused OldBuf param
procedure PrintBinaryCopy(NewBuf: PSignedAnsiCharArray; NewPos: size_t;
  OldBuf: PSignedAnsiCharArray; OldPos: size_t; Length: size_t);
  forward;

var
  { References procs used to generate output for different formats }
  FmtSpec: array[TFormat] of TFormatSpec = (
    (
      Header: PrintBinaryHeader;
      Add: PrintBinaryAdd;
      Copy: PrintBinaryCopy;
    ),
    (
      Header: PrintTextHeader;
      Add: PrintFilteredAdd;
      Copy: PrintTextCopy;
    ),
    (
      Header: PrintTextHeader;
      Add: PrintQuotedAdd;
      Copy: PrintTextCopy;
    )
  );

{ Load file, returning pointer to file data, exits with error message if out of
  memory or not found }
function LoadFile(FileName: string; FileDataSize: Psize_t):
  PSignedAnsiCharArray;
var
  FP: File of Byte;                         // file pointer
  Data: PSignedAnsiCharArray;
  Buffer: array[0..BUFFER_SIZE-1] of Byte;  // buffer to read file
  Len: size_t;
  CurLen: size_t;
  Tmp: PSignedAnsiCharArray;
begin
  { open file }
  AssignFile(FP, FileName);
  if (IOResult <> 0) then
    OSError;
  Reset(FP);
  if (IOResult <> 0) then
    OSError;
  { read file }
  CurLen := 0;
  Data := nil;
  BlockRead(FP, Buffer, BUFFER_SIZE, Len);
  while (Len > 0) do
  begin
    Tmp := Data;
    ReallocMem(Tmp, CurLen + Len);
    if not Assigned(Tmp) then
      Error('Virtual memory exhausted');
    Data := Tmp;
    Move(Buffer, Data[CurLen], Len);
    Inc(CurLen, Len);
    BlockRead(FP, Buffer, BUFFER_SIZE, Len);
  end;
  if not EOF(FP) then
  begin
    CloseFile(FP);
    OSError;
  end;

  { exit }
  CloseFile(FP);
  if Assigned(FileDataSize) then
    FileDataSize^ := CurLen;
  Result := Data;
end;

{ Pack long in little-endian format into p }
procedure PackLong(p: PSignedAnsiChar; l: Longint);
begin
  p^ := l and $FF;
  Inc(p);
  p^ := (l shr 8) and $FF;
  Inc(p);
  p^ := (l shr 16) and $FF;
  Inc(p);
  p^ := (l shr 24) and $FF;
end;

{ Compute simple checksum }
function CheckSum(Data: PSignedAnsiChar; Length: size_t): Longint;
var
  l: Longint;
begin
  l := 0;
  while Length <> 0 do
  begin
    Dec(Length);
    l := ((l shr 30) and 3) or (l shl 2);
    l := l xor Ord(Data^);
    Inc(Data);
  end;
  Result := l;
end;

{ Print header for 'BINARY' format }
procedure PrintBinaryHeader(OldFileName, NewFileName: string;
  OldFileSize, NewFileSize: size_t);
var
  head: array[0..15] of SignedAnsiChar;
begin
  Move('bdiff' + FORMAT_VERSION + #$1A, head[0], 8); {8 bytes}
  PackLong(@head[8], OldFileSize);
  PackLong(@head[12], NewFileSize);
  WriteBin(stdout, @head, 16);
end;

{ Print header for text formats }
procedure PrintTextHeader(OldFileName, NewFileName: string;
  OldFileSize, NewFileSize: size_t);
begin
  WriteStrFmt(
    stdout,
    '%% --- %s (%d bytes)'#13#10'%% +++ %s (%d bytes)'#13#10,
    [OldFileName, OldFileSize, NewFileName, NewFileSize]
  );
end;

{ Print data as C-escaped string }
procedure PrintQuotedData(data: PSignedAnsiChar; len: size_t);
begin
  while (len <> 0) do
  begin
    if isprint(AnsiChar(data^)) and (AnsiChar(data^) <> '\') then
      WriteStr(stdout, AnsiChar(data^))
    else
      WriteStr(stdout, '\' + ByteToOct(data^ and $FF));
    Inc(data);
    Dec(len);
  end;
end;

{ Print data with non-printing characters filtered }
procedure PrintFilteredData(Data: PSignedAnsiChar; Length: size_t);
begin
  while Length <> 0  do
  begin
    if isprint(AnsiChar(Data^)) then
      WriteStr(stdout, AnsiChar(Data^))
    else
      WriteStr(stdout, '.');
    Inc(Data);
    Dec(Length);
  end;
end;

{ Print information for binary diff chunk }
procedure PrintBinaryAdd(Data: PSignedAnsiChar; Length: size_t);
var
  buf: array[0..3] of SignedAnsiChar;
begin
  WriteStr(stdout, '+');
  PackLong(@buf[0], Length);
  WriteBin(stdout, @buf, 4);
  WriteBin(stdout, Data, Length);
end;

{ Print information for filtered diff chunk }
procedure PrintFilteredAdd(Data: PSignedAnsiChar; Length: size_t);
begin
  WriteStr(stdout, '+');
  PrintFilteredData(Data, Length);
  WriteStr(stdout, #13#10);
end;

{ Print information for quoted diff chunk }
procedure PrintQuotedAdd(Data: PSignedAnsiChar; Length: size_t);
begin
  WriteStr(stdout, '+');
  PrintQuotedData(Data, Length);
  WriteStr(stdout, #13#10);
end;

{ Print information for copied data in text mode }
procedure PrintTextCopy(NewBuf: PSignedAnsiCharArray; NewPos: size_t;
  OldBuf: PSignedAnsiCharArray; OldPos: size_t; Length: size_t);
begin
  WriteStrFmt(
    stdout,
    '@ -[%d] => +[%d] %d bytes'#13#10' ',
    [OldPos, NewPos, Length]
  );
  if gFormat = FMT_FILTERED then
    PrintFilteredData(@NewBuf[NewPos], Length)
  else
    PrintQuotedData(@NewBuf[NewPos], Length);
  WriteStr(stdout, #13#10);
end;

{ Print information for copied data in binary mode }
procedure PrintBinaryCopy(NewBuf: PSignedAnsiCharArray; NewPos: size_t;
  OldBuf: PSignedAnsiCharArray; OldPos: size_t; Length: size_t);
var
  rec: array[0..11] of SignedAnsiChar;
begin
  WriteStr(stdout, '@');
  PackLong(@rec[0], OldPos);
  PackLong(@rec[4], Length);
  PackLong(@rec[8], CheckSum(@NewBuf[NewPos], Length));
  WriteBin(stdout, @rec, 12);
end;

{ Find maximum-length match }
procedure FindMaxMatch(RetVal: PMatch; Data: PSignedAnsiCharArray;
  SortedData: PBlock; DataSize: size_t; SearchText: PSignedAnsiChar;
  SearchTextLength: size_t);   
var
  FoundPos: size_t;
  FoundLen: size_t;
begin
  RetVal^.Length := 0;  {no match}
  RetVal^.NewFilePos := 0;
  while (SearchTextLength <> 0) do
  begin
    FoundLen := find_string(
      Data, SortedData, DataSize, SearchText, SearchTextLength, @FoundPos
    );
    if FoundLen >= gMinMatchLength then
    begin
      RetVal^.OldFilePos := FoundPos;
      RetVal^.Length := FoundLen;
      Exit;
    end;
    Inc(SearchText);
    Inc(RetVal^.NewFilePos);
    Dec(SearchTextLength);
  end;
end;

{ Print log message, if enabled. Log messages go to stderr because we may be
  writing patch file contents to stdout }
procedure LogStatus(const Msg: string);
begin
  if gVerbose <> 0 then
    WriteStrFmt(stderr, '%s: %s'#13#10, [ProgramFileName, Msg]);
end;

{ Main routine: generate diff }
procedure CreateDiff(OldFileName, NewFileName: string);
var
  OldFileData: PSignedAnsiCharArray;
  NewFileData: PSignedAnsiCharArray;
  OldFileLength: size_t;
  NewFileLength: size_t;
  NewOffset: size_t;
  ToDo: size_t;
  SortedOldData: PBlock;
  Match: TMatch;
begin
  { initialize }
  OldFileData := nil;
  NewFileData := nil;
  SortedOldData := nil;
  try
    LogStatus('loading old file');
    OldFileData := LoadFile(OldFileName, @OldFileLength);
    LogStatus('loading new file');
    NewFileData := LoadFile(NewFileName, @NewFileLength);
    LogStatus('block sorting old file');
    SortedOldData := block_sort(OldFileData, OldFileLength);
    if not Assigned(SortedOldData) then
      Error('virtual memory exhausted');
    LogStatus('generating patch');
    FmtSpec[gFormat].Header(
      OldFileName, NewFileName, OldFileLength, NewFileLength
    );
    { main loop }
    ToDo := NewFileLength;
    NewOffset := 0;
    while (ToDo <> 0) do
    begin
      { invariant: nofs + todo = len2 }
      FindMaxMatch(
        @Match, OldFileData, SortedOldData, OldFileLength,
        @NewFileData[NewOffset], ToDo
      );
      if Match.Length <> 0 then
      begin
        { found a match }
        if Match.NewFilePos <> 0 then
          { preceded by a "copy" block }
          FmtSpec[gFormat].Add(@NewFileData[NewOffset], Match.NewFilePos);
        Inc(NewOffset, Match.NewFilePos);
        Dec(ToDo, Match.NewFilePos);
        FmtSpec[gFormat].Copy(
          NewFileData, NewOffset, OldFileData, Match.OldFilePos, Match.Length
        );
        Inc(NewOffset, Match.Length);
        Dec(ToDo, Match.Length);
      end
      else
      begin
        FmtSpec[gFormat].Add(@NewFileData[NewOffset], ToDo);
        Break;
      end;
    end;
    LogStatus('done');
  finally
    // finally section new to v1.1
    if Assigned(SortedOldData) then
      FreeMem(SortedOldData);
    if Assigned(OldFileData) then
      FreeMem(OldFileData);
    if Assigned(NewFileData) then
      FreeMem(NewFileData);
  end;
end;

{ Display help screen  }
procedure DisplayHelp;
begin
  WriteStrFmt(
    stdout,
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
  WriteStrFmt(
    stdout, '%s-%s %s '#13#10, [ProgramBaseName, ProgramVersion, ProgramExeDate]
  );
end;

{ Read argument of --min-equal }
procedure SetMinEqual(p: PChar);
var
  q: PChar;
  x: LongWord;
begin
  if not Assigned(p) or (p^ = #0) then
    Error('Missing argument to ''--min-equal'' / ''-m''');
  x := StrToULDec(p, q);
  if q^ <> #0 then
    Error('Malformed number on command line');
  if (x = 0) or (x > $7FFF) then
    Error('Number out of range on command line');
  gMinMatchLength := x;
end;

{ Read argument of --format }
procedure SetFormat(p: PChar);
begin
  if not Assigned(p) then
    Error('Missing argument to ''--format''');
  if StrComp(p, 'quoted') = 0 then
    gFormat := FMT_QUOTED
  else if (StrComp(p, 'filter') = 0) or (StrComp(p, 'filtered') = 0) then
    gFormat := FMT_FILTERED
  else if StrComp(p, 'binary') = 0 then
    gFormat := FMT_BINARY
  else
    Error('Invalid format specification');
end;

{ Main routine: parses arguments and calls creates diff using CreateDiff() }
procedure Main;
var
  OldFileName: string;
  NewFileName: string;
  PatchFileName: string;
  i: Integer;
  fp: Integer;
  p: PChar;       // scans parameter list
  argv: PChar;    // each command line paramter
begin
  ExitCode := 0;
  
  OldFileName := '';
  NewFileName := '';
  PatchFileName := '';

  try
    { Parse command line }
    i := 1;
    while (i <= ParamCount) do
    begin
      argv := PChar(ParamStr(i) + #0#0#0);
      if argv[0] = '-' then
      begin
        if argv[1] = '-' then
        begin
          { long options }
          p := argv + 2;
          if StrComp(p, 'help') = 0 then
          begin
            DisplayHelp;
            Exit;
          end
          else if StrComp(p, 'version') = 0 then
          begin
            DisplayVersion;
            Exit;
          end
          else if StrComp(p, 'verbose') = 0 then
            gVerbose := 1
          else if StrComp(p, 'output') = 0 then
          begin
            Inc(i);
            argv := PChar(ParamStr(i));
            if (argv^ = #0) then
              Error('missing argument to ''--output''')
            else
              PatchFileName := argv;
          end
          else if StrLComp(p, 'output=', 7) = 0 then
            PatchFileName := p + 7
          else if StrComp(p, 'format') = 0 then
          begin
            Inc(i);
            argv := PChar(ParamStr(i));
            SetFormat(argv);
          end
          else if StrLComp(p, 'format=', 7) = 0 then
            SetFormat(p + 7)
          else if StrComp(p, 'min-equal') = 0 then
          begin
            Inc(i);
            argv := PChar(ParamStr(i));
            SetMinEqual(argv);
          end
          else if StrLComp(p, 'min-equal=', 10) = 0 then
            SetMinEqual(p + 10)
          else
            Error('unknown option ''--%s''', [p])
        end
        else
        begin
          { short options }
          p := argv + 1;
          while p^ <> #0 do
          begin
            case p^ of
              'h':
                if StrComp(p, 'h') = 0 then
                begin
                  DisplayHelp;
                  Exit;
                end;
              'v':
                if StrComp(p, 'v') = 0 then
                begin
                  DisplayVersion;
                  Exit;
                end;
              'V':
                gVerbose := 1;
              'q':
                gFormat := FMT_QUOTED;
              'f':
                gFormat := FMT_FILTERED;
              'b':
                gFormat := FMT_BINARY;
              'm':
              begin
                Inc(i);
                argv := PChar(ParamStr(i));
                SetMinEqual(argv);
              end;
              'o':
              begin
                Inc(i);
                argv := PChar(ParamStr(i));
                if argv^ = #0 then
                  Error('missing argument to ''-o''')
                else
                  PatchFileName := argv;
              end;
              else
                Error('unknown option ''-%:s''', [p^]);
            end;
            Inc(p);
          end;
        end;
      end
      else
      begin
        { file names }
        if OldFileName = '' then
          OldFileName := ParamStr(i)
        else if NewFileName = '' then
          NewFileName := ParamStr(i)
        else
          Error('Too many file names on command line');
      end;
      Inc(i);
    end;
    if NewFileName = '' then
      Error('Need two filenames');
    if (PatchFileName <> '') and (PatchFileName <> '-') then
    begin
      { redirect stdout to patch file }
      fp := FileCreate(PatchFileName);
      if fp <= 0 then
        OSError;
      RedirectStdOut(fp);
    end;

    { create the diff }
    CreateDiff(OldFileName, NewFileName);
  except
    on E: Exception do
    begin
      ExitCode := 1;
      WriteStrFmt(StdErr, '%0:s: %1:s'#13#10, [ProgramFileName, E.Message]);
    end;
  end;
end;

end.

