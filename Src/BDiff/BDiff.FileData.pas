//!  BSD 3-clause license: see LICENSE.md

///  <summary>Handles file input and provides access to the file's data.
///  </summary>
///  <remarks>Used by BDiff only.</remarks>

unit BDiff.FileData;


interface


uses
  // Project
  BDiff.Types;


type

  ///  <summary>Class that encapsulates a file, reads its data and provides
  ///  access to it.</summary>
  TFileData = class(TObject)
  strict private
    var
      // Property values
      fData: PCCharArray;
      fSize: Cardinal;
      fName: string;
    ///  <summary>Loads data from the file into a memory block pointed to by the
    ///  <c>Data</c> property.</summary>
    procedure LoadFile;
  public
    ///  <summary>Object constructor. Loads the data from the given file.
    ///  </summary>
    constructor Create(const FileName: string);
    ///  <summary>Object destructor. Frees memory used to store file data.
    ///  </summary>
    destructor Destroy; override;
    ///  <summary>Name of file.</summary>
    property Name: string read fName;
    ///  <summary>Size of file's data.</summary>
    property Size: Cardinal read fSize;
    ///  <summary>Pointer to memory containing file's content.</summary>
    ///  <remarks>Callers must not free the memory.</remarks>
    property Data: PCCharArray read fData;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  Winapi.Windows,
  // Project
  BDiff.IO,
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
begin
  var FileHandle: THandle := FileOpen(fName, fmOpenRead or fmShareDenyWrite);
  try
    if FileHandle = INVALID_HANDLE_VALUE then
      Error('Cannot open file %s', [fName]);
    var FileSize: Int64 := TIO.FileSize(FileHandle);
    if FileSize = -1 then
      Error('Cannot find size of file %s', [fName]);
    if FileSize = 0 then
      Error('File %s is empty', [fName]);
    if FileSize > MaxInt then
      Error('File %s is too large (>= 2GiB)', [fName]);
    fSize := Cardinal(FileSize);
    try
      GetMem(fData, fSize);
      var BytesRead: Integer := FileRead(FileHandle, fData^, fSize);
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
    if FileHandle <> INVALID_HANDLE_VALUE then
      FileClose(FileHandle);
  end;
end;

end.

