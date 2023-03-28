{
 * Contains utility functions used for BDiff. Includes Pascal implementations
 * of, or alternatives for, some standard C library code.
}


unit UBDiffIO;

interface

uses
  // Project
  UCommonIO;

type
  TIO = class(TCommonIO)
  public
    { Redirects standard output to a given file handle }
    class procedure RedirectStdOut(const Handle: THandle);
  end;

implementation

uses
  // Delphi
  Windows;

{ TIO }

class procedure TIO.RedirectStdOut(const Handle: THandle);
begin
  Windows.SetStdHandle(STD_OUTPUT_HANDLE, Handle);
end;

end.

