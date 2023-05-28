//!  BSD 3-clause license: see LICENSE.md

///  <summary>Code to assist in working with stdin, stdout and stderr in BDiff.
///  </summary>
///  <remarks>Used by BDiff only.</remarks>

unit BDiff.IO;


interface


uses
  // Project
  Common.IO;


type

  ///  <summary>Static class that provides IO functions required by BDiff to
  ///  read/write from/to Windows handles.</summary>
  TIO = class sealed(TCommonIO)
  public
    ///  <summary>Redirects standard output to file handle <c>Handle</c>.
    ///  </summary>
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

