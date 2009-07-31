{
  ------------------------------------------------------------------------------
  UBPatchUtils.pas

  Contains utility functions used for BPatch program, including Pascal
  implementation of some standard C library code.

  Copyright (c) 2003-2007 Peter D Johnson (www.delphidabbler.com).

  THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY. IN
  NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE USE
  OF THIS SOFTWARE.

  For conditions of distribution and use see the BDiff / BPatch license
  available from http://www.delphidabbler.com/software/bdiff/license

  Change log
  v1.0 of 28 Nov 2003  -  Original version.
  v1.1 of 18 Sep 2007  -  Added RedirectStdIn() routine.
                       -  Explicitly cast handles of stdin, stdout and stderr to
                          correct types.
                       -  Changed copyright and license notice.
  ------------------------------------------------------------------------------
}


unit UBPatchUtils;


interface


uses
  // Delphi
  Windows,
  // Project
  UBPatchTypes;


{ emulates C std lib fread function using Windows file handle }
function fread(ptr: Pointer; size: size_t; nobj: size_t;
  stream: Integer): size_t;

{ emulates C std lib fwrite function using Windows file handle }
function fwrite(ptr: Pointer; size: size_t; nobj: size_t;
  stream: Integer): size_t;

{ emulates C std lib fgetc function using Windows file handle }
function fgetc(stream: Integer): Integer;

{ emulates C std lib feof function using Windows file handle }
function feof(stream: Integer): Boolean;

{ emulates C std lib fseek function using Windows file handle }
function fseek(stream: Integer; offset: Longint; origin: Integer): Integer;

{ emulates C std lib fclose function using Windows file handle }
procedure fclose(stream: Integer);

{ emulates C std lib fprintf function using Windows file handle: \n etc not
  supported and parameters and string format specifiers are in Object Pascal
  format }
function fprintf(stream: Integer; const Fmt: string;
  Args: array of const): Integer;

{ emulates C std lib perror function: displays given message followed by
  description of last Windows error }
procedure perror(const Msg: string);

{ emulates C std lib stdin value by returning Windows standard input handle }
function stdin: Integer;

{ emulates C std lib stdin value by returning Windows standard output handle }
function stdout: Integer;

{ emulates C std lib stdin value by returning Windows standard error handle }
function stderr: Integer;

{ redirects a given file handle to stdin }
procedure RedirectStdIn(const Handle: Integer);


implementation


uses
  // Delphi
  SysUtils;


{ emulates C std lib fread function using Windows file handle }
function fread(ptr: Pointer; size: size_t; nobj: size_t;
  stream: Integer): size_t;
begin
  Result := size_t(SysUtils.FileRead(stream, ptr^, size * nobj)) div size;
end;

{ emulates C std lib fwrite function using Windows file handle }
function fwrite(ptr: Pointer; size: size_t; nobj: size_t;
  stream: Integer): size_t;
begin
  Result := size_t(SysUtils.FileWrite(stream, ptr^, size * nobj)) div size;
end;

{ emulates C std lib fgetc function using Windows file handle}
function fgetc(stream: Integer): Integer;
var
  Ch: Char;
begin
  if feof(stream) then
    Result := EOF
  else
  begin
    fread(@Ch,1, 1, stream);
    Result := Integer(Ch);
  end;
end;

{ emulates C std lib feof function using Windows file handle}
function feof(stream: Integer): Boolean;
var
  CurPos: Integer;
  Size: Integer;
begin
  CurPos := SysUtils.FileSeek(stream, 0, 1);
  Size := Windows.GetFileSize(stream, nil);
  Result := CurPos = Size;
end;

{ emulates C std lib fseek function using Windows file handle}
function fseek(stream: Integer; offset: Longint; origin: Integer): Integer;
begin
  if SysUtils.FileSeek(stream, offset, origin) = -1 then
    Result := -1
  else
    Result := 0;
end;

{ emulates C std lib fclose function using Windows file handle}
procedure fclose(stream: Integer);
begin
  SysUtils.FileClose(stream);
end;

{ emulates C std lib fprintf function using Windows file handle: \n etc not
  supported and parameters and string format specifiers are in Object Pascal
  format }
function fprintf(stream: Integer; const Fmt: string;
  Args: array of const): Integer;
var
  FormattedStr: string;
begin
  FormattedStr := Format(Fmt, Args);
  Result := Length(FormattedStr);
  fwrite(PChar(FormattedStr), Result, 1, stream);
end;

{ emulates C std lib perror function: displays given message followed by
  description of last Windows error }
procedure perror(const Msg: string);
begin
  fprintf(stderr, '%s: %s'#13#10,
    [Msg, SysUtils.SysErrorMessage(Windows.GetLastError)]);
end;

{ emulates C std lib stdin value by returning Windows standard input handle }
function stdin: Integer;
begin
  Result := Integer(Windows.GetStdHandle(STD_INPUT_HANDLE));
end;

{ emulates C std lib stdin value by returning Windows standard output handle }
function stdout: Integer;
begin
  Result := Integer(Windows.GetStdHandle(STD_OUTPUT_HANDLE));
end;

{ emulates C std lib stdin value by returning Windows standard error handle }
function stderr: Integer;
begin
  Result := Integer(Windows.GetStdHandle(STD_ERROR_HANDLE));
end;

{ redirects stdout to a given file handle }
procedure RedirectStdIn(const Handle: Integer);
begin
  Windows.SetStdHandle(STD_INPUT_HANDLE, Cardinal(Handle));
end;

end.

