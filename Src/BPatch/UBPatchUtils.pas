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

end.

