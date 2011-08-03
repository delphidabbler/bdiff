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

{ Returns Windows standard input handle }
function StdIn: Integer;

{ Returns Windows standard output handle }
function StdOut: Integer;

{ Returns Windows standard error handle }
function StdErr: Integer;

{ Redirects standard input from a given file handle }
procedure RedirectStdIn(const Handle: Integer);

{ Redirects standard output to a given file handle }
procedure RedirectStdOut(const Handle: Integer);

{ Writes binary data to a file }
procedure WriteBin(Handle: THandle; BufPtr: Pointer; Size: Integer);

{ Writes a string to a file  }
procedure WriteStr(Handle: THandle; const S: string);

{ Writes a string built from format string and arguments to file }
procedure WriteStrFmt(Handle: THandle; const Fmt: string; Args: array of const);

implementation

uses
  SysUtils, Windows;

function StdIn: Integer;
begin
  Result := Integer(Windows.GetStdHandle(STD_INPUT_HANDLE));
end;

function StdOut: Integer;
begin
  Result := Integer(Windows.GetStdHandle(STD_OUTPUT_HANDLE));
end;

function StdErr: Integer;
begin
  Result := Integer(Windows.GetStdHandle(STD_ERROR_HANDLE));
end;

procedure RedirectStdIn(const Handle: Integer);
begin
  Windows.SetStdHandle(STD_INPUT_HANDLE, Cardinal(Handle));
end;

procedure RedirectStdOut(const Handle: Integer);
begin
  Windows.SetStdHandle(STD_OUTPUT_HANDLE, Cardinal(Handle));
end;

procedure WriteBin(Handle: THandle; BufPtr: Pointer; Size: Integer);
var
  Dummy: DWORD;
begin
  Windows.WriteFile(Handle, BufPtr^, Size, Dummy, nil);
end;

procedure WriteStr(Handle: THandle; const S: string);
begin
  WriteBin(Handle, PChar(S), Length(S));
end;

procedure WriteStrFmt(Handle: THandle; const Fmt: string; Args: array of const);
begin
  WriteStr(Handle, Format(Fmt, Args));
end;

end.

