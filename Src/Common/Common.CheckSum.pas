{
  Class that calculates check sum that is written to binary patch files by
  BDiff and checked by BPatch when reading patch files.

  This class centralises previously duplicated checksum methods.
}

unit Common.CheckSum;

interface

type
  PInt8 = ^Int8;

  TCheckSum = class(TObject)
  private
    fCheckSum: Longint;
  public
    constructor Create(Seed: Int32);
    procedure Add(Value: Int8);
    procedure AddBuffer(Data: PInt8; Length: UInt32);
    property CheckSum: Int32 read fCheckSum;
  end;

implementation

{ TCheckSum }

procedure TCheckSum.Add(Value: Int8);
begin
  fCheckSum := ((fCheckSum shr 30) and 3) or (fCheckSum shl 2);
  fCheckSum := fCheckSum xor Value;
end;

procedure TCheckSum.AddBuffer(Data: PInt8; Length: UInt32);
begin
  while Length > 0 do
  begin
    Dec(Length);
    Add(Data^);
    Inc(Data);
  end;
end;

constructor TCheckSum.Create(Seed: Int32);
begin
  inherited Create;
  fCheckSum := Seed;
end;

end.
