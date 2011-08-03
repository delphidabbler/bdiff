unit UFileData;

interface

uses
  UBDiffTypes;

type

  TFileData = class(TObject)
  private
    fData: PSignedAnsiCharArray;
    fSize: size_t;
    fName: string;
    procedure LoadFile;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    property Name: string read fName;
    property Size: size_t read fSize;
    property Data: PSignedAnsiCharArray read fData;
  end;

implementation

uses
  SysUtils, Windows,
  UErrors;

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
    if fSize = size_t(-1) then
      Error('Cannot find size of file %s - may be to large', [fName]);
    if fSize = 0 then
      Error('File %s is empty', [fName]);
    try
      GetMem(fData, fSize);
      BytesRead := FileRead(FileHandle, fData^, fSize);
      if BytesRead = -1 then
        Error('Cannot read from file %s', [fName]);
      if fSize <> size_t(BytesRead) then
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

