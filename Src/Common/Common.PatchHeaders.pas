//!  BSD 3-clause license: see LICENSE.md

///  <summary>Various record types that define and operate on header structures
///  used in patch files.</summary>
///  <remarks>Code common to both BDiff and BPatch.</remarks>

unit Common.PatchHeaders;


interface


type

  ///  <summary>Advanced record used to pack a 32 bit integer in LSB format.
  ///  </summary>
  TPackedInt32 = record
  strict private
    var
      fData: packed array[0..3] of UInt8;
  public
    ///  <summary>Packs and stores integer <c>I</c>.</summary>
    procedure Pack(const I: Int32);
    ///  <summary>Unpacks packed data into an integer and returns it.</summary>
    function Unpack: Int32;
  end;

  ///  <summary>Container record for other records and constants that define
  ///  patch file headers.</summary>
  TPatchHeaders = record
  public
    type

      ///  <summary>Defines 8 character array used to store patch file
      ///  signature.</summary>
      TSignature = array[0..7] of AnsiChar;

      ///  <summary>Patch file header record.</summary>
      THeader = packed record
      strict private
        const
          ///  <summary>Patch file signature.</summary>
          ///  <remarks>
          ///  <para>Format is <c>bdiff</c> + file-version + Ctrl+Z. Where
          ///  file-version is a two character ANSI string, here <c>02</c>.
          ///  </para>
          ///  <para>If the file format is changed then increment the file
          ///  version. Keep the length at 8 bytes.</para>
          ///  </remarks>
          SignatureStr: TSignature = 'bdiff02'#$1A;
      public
        ///  <summary>Patch file signature.</summary>
        Signature: TSignature;
        ///  <summary>Size of old file data.</summary>
        OldDataSize: TPackedInt32;
        ///  <summary>Size of new file data.</summary>
        NewDataSize: TPackedInt32;
        ///  <summary>Checks if the <c>THeader.Signature</c> field contains a
        ///  valid signature.</summary>
        function IsValidSignature: Boolean;
        ///  <summary>Set signature to valid value.</summary>
        procedure SetValidSignature;
      end;

      ///  <summary>Header record written to an added data record.</summary>
      TAddedData = packed record
        ///  <summary>Length of added data.</summary>
        DataLength: TPackedInt32;
      end;

      ///  <summary>Header record written to a common block record.</summary>
      TCommonData = packed record
        ///  <summary>Starting position of copied data.</summary>
        CopyStart: TPackedInt32;
        ///  <summary>Length of copied data.</summary>
        CopyLength: TPackedInt32;
        ///  <summary>Checksum used to validate copied data.</summary>
        CheckSum: TPackedInt32;
      end;

      const
        ///  <summary>Introduces added data section.</summary>
        AddIndicator = '+';
        ///  <summary>Introduces common data section.</summary>
        CommonIndicator = '@';
  end;


implementation


{ TPackedInt32 }

procedure TPackedInt32.Pack(const I: Int32);
begin
  fData[0] := I and $FF;
  fData[1] := (I shr 8) and $FF;
  fData[2] := (I shr 16) and $FF;
  fData[3] := (I shr 24) and $FF;
end;

function TPackedInt32.Unpack: Int32;
begin
  var UI: UInt32 :=
    fData[0] +
    256 * fData[1] +
    65536 * fData[2] +
    16777216 * fData[3];
  Result := Int32(UI);
end;

{ TPatchHeaders.THeader }

function TPatchHeaders.THeader.IsValidSignature: Boolean;
begin
  Result := Signature = SignatureStr;
end;

procedure TPatchHeaders.THeader.SetValidSignature;
begin
  Signature := SignatureStr;
end;

end.

