//!  BSD 3-clause license: see LICENSE.md

///  <summary>Code to calculate the check sum used to validate patch files.
///  </summary>
///  <remarks>Code common to both BDiff and BPatch.</remarks>

unit Common.CheckSum;


interface


type

  ///  <summary>Pointer to <c>Int8</c> type.</summary>
  PInt8 = ^Int8;

  ///  <summary>Checksum builder.</summary>
  TCheckSum = class(TObject)
  strict private
    var
      // Property value
      fCheckSum: Int32;
  public
    ///  <summary>Object constructor. Initialises checksum to <c>Seed</c>.
    ///  </summary>
    constructor Create(Seed: Int32);
    ///  <summary>Adds a given signed byte to the checksum.</summary>
    procedure Add(Value: Int8);
    ///  <summary>Adds data from buffer of signed bytes pointed to by
    ///  <c>Data</c>, where buffer contains <c>Length</c>.</summary>
    procedure AddBuffer(Data: PInt8; Length: Int32);
    ///  <summary>The current checksum.</summary>
    property CheckSum: Int32 read fCheckSum;
  end;


implementation


{ TCheckSum }

procedure TCheckSum.Add(Value: Int8);
begin
  fCheckSum := ((fCheckSum shr 30) and 3) or (fCheckSum shl 2);
  fCheckSum := fCheckSum xor Value;
end;

procedure TCheckSum.AddBuffer(Data: PInt8; Length: Int32);
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

