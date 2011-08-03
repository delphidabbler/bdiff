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
  end;

implementation

uses
  SysUtils, Windows;

{ TIO }

class procedure TIO.RedirectStdIn(const Handle: Integer);
begin
  Windows.SetStdHandle(STD_INPUT_HANDLE, Cardinal(Handle));
end;

class procedure TIO.RedirectStdOut(const Handle: Integer);
begin
  Windows.SetStdHandle(STD_OUTPUT_HANDLE, Cardinal(Handle));
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

