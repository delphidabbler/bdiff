{
 * UBPatch.pas
 *
 * Main program logic for BPatch.
 *
 * Based on bpatch.c by Stefan Reuther, copyright (c) 1999 Stefan Reuther
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


unit UBPatch;


interface


{ The program's main interface code: called from the project file }
procedure Main;


implementation

{$IOCHECKS OFF}

uses
  // Delphi
  Windows, SysUtils,
  // Project
  UAppInfo, UBPatchUtils, UBPatchTypes, UErrors;


const
  FORMAT_VERSION = '02';  // binary diff file format version
  BUFFER_SIZE = 4096;     // size of buffer used to read files


{ Compute simple checksum }
function checksum(data: PAnsiChar; len: size_t; l: Longint): Longint;
begin
  while len <> 0 do
  begin
    Dec(len);
    l := ((l shr 30) and 3) or (l shl 2);
    l := l xor PShortInt(data)^;
    Inc(data);
  end;
  Result := l;
end;

{ Get 32-bit quantity from char array }
function getlong(p: PAnsiChar): Longint;
var
  q: PByte;
  l: LongWord;
begin
  q := PByte(p);
  l := q^;  Inc(q);
  l := l + 256 * q^;  Inc(q);
  l := l + 65536 * q^;  Inc(q);
  l := l + 16777216 * q^;
  Result := l;
end;

{ Copy data from one stream to another, computing checksums (allows dest = 0) }
procedure copy_data(src, dest: Integer; amount, check: Longint;
  src_is_patch: Integer);
var
  chk: Longint;
  buffer: array[0..BUFFER_SIZE-1] of AnsiChar;
  now: size_t;
begin
  chk := 0;

  while amount <> 0 do
  begin
    if amount > BUFFER_SIZE then
      now := BUFFER_SIZE
    else
      now := amount;
    if fread(@buffer, 1, now, src) <> now then
    begin
      if feof(src) then
      begin
        if src_is_patch <> 0 then
          Error('Patch garbled - unexpected end of data')
        else
          Error('Source file does not match patch');
      end
      else
      begin
        if src_is_patch <> 0 then
          Error('Error reading patch file')
        else
          Error('Error reading source file');
      end;
    end;
    if dest <> 0 then
      if fwrite(@buffer, 1, now, dest) <> now then
        Error('Error writing temporary file');
    chk := checksum(buffer, now, chk);
    Dec(amount, now);
  end;
  if (src_is_patch = 0) and (chk <> check) then
    Error('Source file does not  match patch');
end;

{ Creates a temporary file in user's temp directory and returns its name }
function GetTempFileName: string;
begin
  // Get temporary folder
  SetLength(Result, Windows.MAX_PATH);
  Windows.GetTempPath(Windows.MAX_PATH, PChar(Result));
  // Get unique temporary file name (it is created as side effect of this call)
  if Windows.GetTempFileName(
    PChar(Result), '', 0, PChar(Result)
  ) = 0 then
    Error('Can''t create temporary file');
  Result := PChar(Result)
end;

{ Apply patch }
procedure bpatch_(const src, dest: string);
var
  sf: Integer; {source file}
  df: Integer; {destination file}
  header: array[0..15] of AnsiChar;
  srclen, destlen: Longint;
  size: Longint;
  ofs: Longint;
  c: Integer;
  tempfile: string;
  tempfd: Integer;
const
  error_msg = 'Patch garbled - invalid section ''%''';
begin
  tempfd := 0;
  tempfile := '';
  try
    { read header }
    if fread(@header, 1, 16, stdin) <> 16 then
      Error('Patch not in BINARY format');
    if StrLComp(header, PAnsiChar('bdiff' + FORMAT_VERSION + #$1A), 8) <> 0 then
      Error('Patch not in BINARY format');
    srclen := getlong(@header[8]);
    destlen := getlong(@header[12]);

    { open source file }
    sf := FileOpen(src, fmOpenRead + fmShareDenyNone);
    if sf <= 0 then
      OSError;
    { create temporary file }
    if dest = '' then
      Error('Empty destination file name');

    tempfile := GetTempFileName;
    df := FileCreate(tempfile);
    if df <= 0 then
      Error('Can''t create temporary file');
    tempfd := df;

    { apply patch }
    while True do
    begin
      c := fgetc(stdin);
      if c = EOF then
        Break;
      case c of
        Integer('@'):
        begin
          { copy from source }
          if fread(@header, 1, 12, stdin) <> 12 then
            Error('Patch garbled - unexpected end of data');
          size := getlong(@header[4]);
          ofs := getlong(@header[0]);
          if (ofs < 0) or (size <= 0) or (ofs > srclen) or (size > srclen)
            or (size+ofs > srclen) then
            Error('Patch garbled - invalid change request');
          if fseek(sf, ofs, SEEK_SET) <> 0 then
            Error('''fseek'' on source file failed');
          copy_data(sf, df, size, getlong(@header[8]), 0);
          Dec(destlen, size);
        end;
        Integer('+'):
        begin
          { copy N bytes from patch }
          if fread(@header, 1, 4, stdin) <> 4 then
            Error('Patch garbled - unexpected end of data');
          size := getlong(@header[0]);
          copy_data(stdin, df, size, 0, 1);
          Dec(destlen, size);
        end;
        else
        begin
          fclose(sf);
          fclose(df);
          StrRScan(error_msg, '%')^ := Char(c);
          Error(error_msg);
        end;
      end;
      if destlen < 0 then
        Error(
          'Patch garbled - patch file longer than announced in header'
        );
    end;
    if destlen <> 0 then
      Error(
        'Patch garbled - destination file shorter than announced in header'
      );

    fclose(sf);
    fclose(df);
    tempfd := 0;

    SysUtils.DeleteFile(dest);    // Added in v1.1: bug fix
    if not RenameFile(tempfile, dest) then
      Error('Can''t rename temporary file');
    tempfile := '';
  except
    on E: Exception do
    begin
      if tempfd > 0 then
        fclose(tempfd);
      if tempfile <> '' then
        SysUtils.DeleteFile(tempfile);
      raise;
    end;
  end;
end;

{ Help & exit }
procedure help;
begin
  fprintf(stdout, '%0:s: binary ''patch'' - apply binary patch'#13#10
    + #13#10
    + 'Usage: %0:s [options] old-file [new-file] [<patch-file]'#13#10#13#10
    + 'Creates new-file from old-file and patch-file'#13#10
    + 'If new-file is not provided old-file is updated in place'#13#10
    + #13#10
    + 'Valid options:'#13#10
    + ' -i FN --input=FN     Set input file name (instead of stdin)'
    + #13#10
    + ' -h    --help         Show this help screen'#13#10
    + ' -v    --version      Show version information'#13#10
    + #13#10
    + '(c) copyright 1999 Stefan Reuther <Streu@gmx.de>'#13#10
    + '(c) copyright 2003-2009 Peter Johnson (www.delphidabbler.com)'#13#10,
    [ProgramFileName]);
end;

{ Version & exit }
procedure version;
begin
  // NOTE: original code displayed compile date using C's __DATE__ macro. Since
  // there is no Pascal equivalent of __DATE__ we display update date of program
  // file instead
  fprintf(
    stdout, '%s-%s %s '#13#10, [ProgramBaseName, ProgramVersion, ProgramExeDate]
  );
end;

{ Control }
procedure Main;
var
  oldfn: string;
  newfn: string;
  infn: string;
  i: Integer;
  p: PChar;       // scans parameter list
  argv: PChar;    // each command line paramter
  fp: Integer;
begin
  ExitCode := 0;

  oldfn := '';
  newfn := '';
  infn := '';

  try
    i := 1;
    while i <= ParamCount do
    begin
      argv := PChar(ParamStr(i) + #0#0#0);
      if argv[0] = '-' then
      begin
        if argv[1] = '-' then
        begin
          { long option }
          p := argv + 2;
          if StrComp(p, 'help') = 0 then
          begin
            help;
            Exit;
          end
          else if StrComp(p, 'version') = 0 then
          begin
            version;
            Exit;
          end
          else if StrComp(p, 'input') = 0 then
          begin
            Inc(i);
            argv := PChar(ParamStr(i));
            if (argv^ = #0) then
              Error('missing argument to ''--input''')
            else
              infn := argv;
          end
          else if StrLComp(p, 'input=', 6) = 0 then
            infn := p + 6
          else
            Error('unknown option ''--%s''', [p])
        end
        else
        begin
          { short option }
          p := argv + 1;
          while p^ <> #0 do
          begin
            case p^ of
              'h':
                if StrComp(p, 'h') = 0 then
                begin
                  help;
                  Exit;
                end;
              'v':
                if StrComp(p, 'v') = 0 then
                begin
                  version;
                  Exit;
                end;
              'i':
              begin
                Inc(i);
                argv := PChar(ParamStr(i));
                if argv^ = #0 then
                  Error('missing argument to ''-i''')
                else
                  infn := argv;
              end
              else
                Error('unknown option ''-%s''', [p^])
            end;
            Inc(p);
          end;
        end;
      end
      else
      begin
        if oldfn = '' then
          oldfn := ParamStr(i)
        else if newfn = '' then
          newfn := ParamStr(i)
        else
          Error('Too many file names on command line');
      end;
      Inc(i);
    end;

    if oldfn = '' then
      Error('File name argument missing');
    if newfn = '' then
      newfn := oldfn;

    if (infn <> '') and (infn <> '-') then
    begin
      fp := FileOpen(infn, fmOpenRead or fmShareDenyNone);
      if fp <= 0 then
        OSError;
      RedirectStdIn(fp);
    end;

    bpatch_(oldfn, newfn);
  except
    on E: Exception do
    begin
      ExitCode := 1;
      fprintf(StdErr, '%0:s: %1:s'#13#10, [ProgramFileName, E.Message]);
    end;
  end;
end;

end.

