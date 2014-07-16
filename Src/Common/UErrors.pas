{
 * UErrors.pas
 *
 * Helper routines to generate exceptions.
 * Common code used by both BDiff and BPatch.
 *
 * Copyright (c) 2009 Peter D Johnson (www.delphidabbler.com).
 *
 * THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY.
 * IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE
 * USE OF THIS SOFTWARE.
 *
 * For conditions of distribution and use see the LICENSE file of visit
 * http://www.delphidabbler.com/software/bdiff/license
}


unit UErrors;


interface


{ Raises an exception with given message }
procedure Error(const Msg: string); overload;

{ Raises an exception with message created from format string and values }
procedure Error(const Fmt: string; const Args: array of const); overload;

{ Raises exception determined by last operating system error }
procedure OSError;


implementation


uses
  // Project
  Sysutils;


{ Raises an exception with given message }
procedure Error(const Msg: string);
begin
  raise Exception.Create(Msg);
end;

{ Raises an exception with message created from format string and values }
procedure Error(const Fmt: string; const Args: array of const);
begin
  raise Exception.CreateFmt(Fmt, Args);
end;

{ Raises exception determined by last operating system error }
procedure OSError;
var
  LastError: Integer;
  Err: EOSError;
begin
  LastError := GetLastError;
  if LastError <> 0 then
    Err := EOSError.Create(SysErrorMessage(LastError))
  else
    Err := EOSError.Create('Unknown operating system error');
  Err.ErrorCode := LastError;
  raise Err;
end;

end.
