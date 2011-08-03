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

{ writes binary data to a file }
procedure WriteBin(Handle: THandle; BufPtr: Pointer; Size: Integer);

{ writes a string to a file  }
procedure WriteStr(Handle: THandle; const S: string);

{ writes a string built from format string and arguments to file }
procedure WriteStrFmt(Handle: THandle; const Fmt: string; Args: array of const);

implementation

uses
  SysUtils, Windows;

{ writes binary data to a file }
procedure WriteBin(Handle: THandle; BufPtr: Pointer; Size: Integer);
var
  Dummy: DWORD;
begin
  Windows.WriteFile(Handle, BufPtr^, Size, Dummy, nil);
end;

{ writes a string to a file  }
procedure WriteStr(Handle: THandle; const S: string);
begin
  WriteBin(Handle, PChar(S), Length(S));
end;

{ writes a string built from format string and arguments to file }
procedure WriteStrFmt(Handle: THandle; const Fmt: string; Args: array of const);
begin
  WriteStr(Handle, Format(Fmt, Args));
end;

end.
