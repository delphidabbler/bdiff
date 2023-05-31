//!  BSD 3-clause license: see LICENSE.md

///  <summary>Code to calculate the check sum used to validate patch files.
///  </summary>
///  <remarks>Code common to both BDiff and BPatch.</remarks>

unit Common.CheckSum;


interface


uses
  Common.Types;


type

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
    procedure Add(Value: TCChar);
    ///  <summary>Adds data from buffer of signed bytes pointed to by
    ///  <c>Data</c>, where buffer contains <c>Length</c>.</summary>
    procedure AddBuffer(Data: PCChar; Length: Int32);
    ///  <summary>The current checksum.</summary>
    property CheckSum: Int32 read fCheckSum;
  end;


implementation


{ TCheckSum }

procedure TCheckSum.Add(Value: TCChar);
begin
  fCheckSum := ((fCheckSum shr 30) and 3) or (fCheckSum shl 2);
  fCheckSum := fCheckSum xor Value;
end;

procedure TCheckSum.AddBuffer(Data: PCChar; Length: Int32);
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

