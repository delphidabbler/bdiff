{
 * UBDiffUtils.pas
 *
 * Contains utility functions used for BDiff. Includes Pascal implementations
 * of, or alternatives for, some standard C library code.
 *
 * Copyright (c) 2003-2011 Peter D Johnson (www.delphidabbler.com).
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


unit UBDiffUtils;

interface

uses
  // Project
  UUtils;

type
  TIO = class(TCommonIO)
  public
    { Redirects standard output to a given file handle }
    class procedure RedirectStdOut(const Handle: Integer);
  end;

implementation

uses
  // Delphi
  Windows;

{ TIO }

class procedure TIO.RedirectStdOut(const Handle: Integer);
begin
  Windows.SetStdHandle(STD_OUTPUT_HANDLE, Cardinal(Handle));
end;

end.

