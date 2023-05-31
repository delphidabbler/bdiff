//!  BSD 3-clause license: see LICENSE.md

///  <summary>Code to assist in working with stdin, stdout and stderr in BPatch.
///  </summary>
///  <remarks>Used by BPatch only.</remarks>

unit BPatch.IO;


interface


uses
  // Project
  Common.IO;


type

  ///  <summary>Static class that provides IO functions required by BPatch to
  ///  read/write from/to Windows handles.</summary>
  TIO = class sealed(TCommonIO)
  public
    const
      ///  <summary>Value representing end of file (as returned from
      ///  <c>TIO.GetCh</c>).</summary>
      EOF: Integer = -1;
      ///  <summary>Seek flag for use with <c>TIO.Seek</c> to seek from start of
      ///  file.</summary>
      SEEK_START = 0;
      ///  <summary>Seek flag for use with <c>TIO.Seek</c> to seek from current
      ///  possition in file.</summary>
      SEEK_CURRENT = 1;
    ///  <summary>Redirects standard input from file handle <c>Handle</c>.
    ///  </summary>
    class procedure RedirectStdIn(const Handle: THandle);

    ///  <summary>Seeks within a given file.</summary>
    ///  <param name="Handle">[in] Handle of file.</param>
    ///  <param name="Offset">[in] Seek offset within the file.</param>
    ///  <param name="Origin">[in] Origin from which seek takes place.</param>
    ///  <returns><c>True</c> on success or <c>False</c> on failure.</returns>
    class function Seek(Handle: THandle; Offset: Int64; Origin: Integer):
      Boolean;

    ///  <summary>Checks if the given file handle is at end of file.</summary>
    class function AtEOF(Handle: THandle): Boolean;

    ///  <summary>Gets and returns a ASCII character from a file or stdin.
    ///  </summary>
    ///  <param name="Handle">[in] Handle from which character is to be read.
    ///  </param>
    ///  <returns><c>Integer</c>. Character read, cast to integer or <c>EOF</c>
    ///  at end of file.</returns>
    class function GetCh(Handle: THandle): Integer;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  Winapi.Windows;


{ TIO }

class function TIO.AtEOF(Handle: THandle): Boolean;
begin
  var CurPos := System.SysUtils.FileSeek(Handle, Int64(0), SEEK_CURRENT);
  var Size := FileSize(Handle);
  Result := CurPos = Size;
end;

class function TIO.GetCh(Handle: THandle): Integer;
begin
  if AtEOF(Handle) then
    Result := EOF
  else
  begin
    var Ch: AnsiChar;
    System.SysUtils.FileRead(Handle, Ch, SizeOf(Ch));
    Result := Integer(Ch);
  end;
end;

class procedure TIO.RedirectStdIn(const Handle: THandle);
begin
  Winapi.Windows.SetStdHandle(
    Winapi.Windows.STD_INPUT_HANDLE, Cardinal(Handle)
  );
end;

class function TIO.Seek(Handle: THandle; Offset: Int64; Origin: Integer):
  Boolean;
begin
  Result := System.SysUtils.FileSeek(Handle, Offset, Origin) >= 0;
end;

end.

