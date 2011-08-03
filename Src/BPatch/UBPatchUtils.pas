{
 * UBPatchUtils.pas
 *
 * Contains utility functions used for BPatch. Includes Pascal implementations
 * of some standard C library code.
 *
 * Copyright (c) 2003-2001 Peter D Johnson (www.delphidabbler.com).
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


unit UBPatchUtils;


interface


uses
  // Delphi
  Windows,
  // Project
  UBPatchTypes;


{ emulates C std lib fgetc function using Windows file handle }
function fgetc(stream: Integer): Integer;

{ emulates C std lib feof function using Windows file handle }
function feof(stream: Integer): Boolean;

{ emulates C std lib fseek function using Windows file handle }
function fseek(stream: Integer; offset: Longint; origin: Integer): Integer;


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
  Ch: AnsiChar; 
begin
  if feof(stream) then
    Result := EOF
  else
  begin
    fread(@Ch, 1, 1, stream);
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

end.

