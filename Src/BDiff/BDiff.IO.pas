{
 * Contains utility functions used for BDiff. Includes Pascal implementations
 * of, or alternatives for, some standard C library code.
}


unit BDiff.IO;

interface

uses
  // Project
  Common.IO;

type
  TIO = class(TCommonIO)
  public
    { Redirects standard output to a given file handle }
    class procedure RedirectStdOut(const Handle: THandle);
  end;

implementation

uses
  // Delphi
  Winapi.Windows;

{ TIO }

class procedure TIO.RedirectStdOut(const Handle: THandle);
begin
  Winapi.Windows.SetStdHandle(Winapi.Windows.STD_OUTPUT_HANDLE, Handle);
end;

end.

