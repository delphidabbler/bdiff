{
 * Contains utility functions used by both BDiff and BPatch.
}


unit UUtils;

interface

type
  TCommonIO = class(TObject)
  public
    { Returns Windows standard input handle }
    class function StdIn: THandle;
    { Returns Windows standard output handle }
    class function StdOut: THandle;
    { Returns Windows standard error handle }
    class function StdErr: THandle;
    { Writes binary data to a file }
    class procedure WriteRaw(Handle: THandle; BufPtr: Pointer; Size: Integer);
    { Writes a string to a file }
    class procedure WriteStr(Handle: THandle; const S: UnicodeString); overload;
    class procedure WriteStr(Handle: THandle; const S: AnsiString); overload;
    { Writes a string built from format string and arguments to file }
    class procedure WriteStrFmt(Handle: THandle; const Fmt: string;
      Args: array of const);
  end;

implementation

uses
  // Delphi
  SysUtils, Windows;

{ TCommonIO }

class function TCommonIO.StdErr: THandle;
begin
  Result := Windows.GetStdHandle(STD_ERROR_HANDLE);
end;

class function TCommonIO.StdIn: THandle;
begin
  Result := Windows.GetStdHandle(STD_INPUT_HANDLE);
end;

class function TCommonIO.StdOut: THandle;
begin
  Result := Windows.GetStdHandle(STD_OUTPUT_HANDLE);
end;

class procedure TCommonIO.WriteRaw(Handle: THandle; BufPtr: Pointer;
  Size: Integer);
var
  Dummy: DWORD;
begin
  if Size <= 0 then
    Exit;
  Windows.WriteFile(Handle, BufPtr^, Size, Dummy, nil);
end;

class procedure TCommonIO.WriteStr(Handle: THandle; const S: UnicodeString);
var
  Bytes: TBytes;
begin
  Bytes := TEncoding.Default.GetBytes(S);
  WriteRaw(Handle, Bytes, Length(S));
end;

class procedure TCommonIO.WriteStr(Handle: THandle; const S: AnsiString);
begin
  WriteRaw(Handle, PAnsiChar(S), Length(S));
end;

class procedure TCommonIO.WriteStrFmt(Handle: THandle; const Fmt: string;
  Args: array of const);
begin
  WriteStr(Handle, Format(Fmt, Args));
end;

end.

