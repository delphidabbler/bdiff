{
 * Implements class that reads a file and provides access to its data.
}


unit BDiff.FileData;

interface

uses
  // Project
  BDiff.Types;

type

  TFileData = class(TObject)
  private
    fData: PCCharArray;
    fSize: Cardinal;
    fName: string;
    procedure LoadFile;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    property Name: string read fName;
    property Size: Cardinal read fSize;
    property Data: PCCharArray read fData;
  end;

implementation

uses
  // Delphi
  System.SysUtils, Winapi.Windows,
  // Project
  Common.Errors;

{ TFileData }

constructor TFileData.Create(const FileName: string);
begin
  inherited Create;
  fName := FileName;
  LoadFile;
end;

destructor TFileData.Destroy;
begin
  if Assigned(fData) then
    FreeMem(fData);
  inherited;
end;

procedure TFileData.LoadFile;
var
  FileHandle: Integer;
  BytesRead: Integer;
begin
  FileHandle := FileOpen(fName, fmOpenRead or fmShareDenyWrite);
  try
    if FileHandle = -1 then
      Error('Cannot open file %s', [fName]);
    fSize := GetFileSize(FileHandle, nil);
    if fSize = Cardinal(-1) then
      Error('Cannot find size of file %s - may be to large', [fName]);
    if fSize = 0 then
      Error('File %s is empty', [fName]);
    try
      GetMem(fData, fSize);
      BytesRead := FileRead(FileHandle, fData^, fSize);
      if BytesRead = -1 then
        Error('Cannot read from file %s', [fName]);
      if fSize <> Cardinal(BytesRead) then
        Error('Error reading from file %s', [fName]);
    except
      if Assigned(fData) then
        FreeMem(fData, fSize);
      raise;
    end;
  finally
    if FileHandle <> -1 then
      FileClose(FileHandle);
  end;
end;

end.

