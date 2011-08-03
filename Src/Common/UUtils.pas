{
 * UUtils.pas
 *
 * Contains utility functions used by both BDiff and BPatch.
 *
 * Copyright (c) 2011 Peter D Johnson (www.delphidabbler.com).
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


unit UUtils;

interface

const
  // Value representing end of file (as returned from TIO.GetCh).
  EOF: Integer = -1;

type
  TIO = class(TObject)
  public
    { Returns Windows standard input handle }
    class function StdIn: Integer;
    { Returns Windows standard output handle }
    class function StdOut: Integer;
    { Returns Windows standard error handle }
    class function StdErr: Integer;
    { Redirects standard input from a given file handle }
    class procedure RedirectStdIn(const Handle: Integer);
    { Redirects standard output to a given file handle }
    class procedure RedirectStdOut(const Handle: Integer);
    { Writes binary data to a file }
    class procedure WriteRaw(Handle: THandle; BufPtr: Pointer; Size: Integer);
    { Writes a string to a file }
    class procedure WriteStr(Handle: THandle; const S: string);
    { Writes a string built from format string and arguments to file }
    class procedure WriteStrFmt(Handle: THandle; const Fmt: string;
      Args: array of const);
    { Seeks to given offset from given origin in file specified by Handle.
      Returns True on success, false on failure. }
    class function Seek(Handle: Integer; Offset: Longint; Origin: Integer):
      Boolean;
    { Checks if given file handle is at end of file. }
    class function AtEOF(Handle: Integer): Boolean;
    { Gets a single ANSI character from file specified by Handle and returns it,
      or EOF. }
    class function GetCh(Handle: Integer): Integer;
  end;

implementation

uses
  SysUtils, Windows;

{ TIO }

class function TIO.AtEOF(Handle: Integer): Boolean;
var
  CurPos: Integer;
  Size: Integer;
begin
  CurPos := SysUtils.FileSeek(Handle, 0, 1);
  Size := Windows.GetFileSize(Handle, nil);
  Result := CurPos = Size;
end;

class function TIO.GetCh(Handle: Integer): Integer;
var
  Ch: AnsiChar;
begin
  if AtEOF(Handle) then
    Result := EOF
  else
  begin
    SysUtils.FileRead(Handle, Ch, SizeOf(Ch));
    Result := Integer(Ch);
  end;
end;

class procedure TIO.RedirectStdIn(const Handle: Integer);
begin
  Windows.SetStdHandle(STD_INPUT_HANDLE, Cardinal(Handle));
end;

class procedure TIO.RedirectStdOut(const Handle: Integer);
begin
  Windows.SetStdHandle(STD_OUTPUT_HANDLE, Cardinal(Handle));
end;

class function TIO.Seek(Handle, Offset, Origin: Integer): Boolean;
begin
  Result := SysUtils.FileSeek(Handle, Offset, Origin) >= 0;
end;

class function TIO.StdErr: Integer;
begin
  Result := Integer(Windows.GetStdHandle(STD_ERROR_HANDLE));
end;

class function TIO.StdIn: Integer;
begin
  Result := Integer(Windows.GetStdHandle(STD_INPUT_HANDLE));
end;

class function TIO.StdOut: Integer;
begin
  Result := Integer(Windows.GetStdHandle(STD_OUTPUT_HANDLE));
end;

class procedure TIO.WriteRaw(Handle: THandle; BufPtr: Pointer;
  Size: Integer);
var
  Dummy: DWORD;
begin
  Windows.WriteFile(Handle, BufPtr^, Size, Dummy, nil);
end;

class procedure TIO.WriteStr(Handle: THandle; const S: string);
begin
  WriteRaw(Handle, PChar(S), Length(S));
end;

class procedure TIO.WriteStrFmt(Handle: THandle; const Fmt: string;
  Args: array of const);
begin
  WriteStr(Handle, Format(Fmt, Args));
end;

end.

