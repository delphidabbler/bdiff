//!  BSD 3-clause license: see LICENSE.md

///  <summary>BPatch command line parser.</summary>
///  <remarks>Used by BPatch only.</remarks>

unit BPatch.Params;


interface


uses
  // Project
  Common.Params;


type

  ///  <summary>BPatch command line parser class.</summary>
  TParams = class sealed(TBaseParams)
  strict private
    var
      // Property values
      fOldFileName: string;
      fNewFileName: string;
      fPatchFileName: string;

  strict protected

    ///  <summary>Parses options in long format (<c>--xxx</c>).</summary>
    ///  <param name="Option">[in] The option to be processed.</param>
    ///  <param name="ParamIdx">[in/out] The option index is passed in. If the
    ///  option takes a parameter then this parameter must be increaed by one.
    ///  </param>
    ///  <param name="Terminated">[in/out] This parameter will always be
    ///  <c>False</c> when called. It should be set to <c>True</c> if option
    ///  processing should cease after processing this option.</param>
    ///  <remarks>This method parses options unique to BPatch. The version and
    ///  help options are parsed in the base class.</remarks>
    function ParseLongOption(const Option: string; var ParamIdx: Integer;
      var Terminated: Boolean): Boolean; override;

    ///  <summary>Parses options in long format (<c>-x</c>).</summary>
    ///  <param name="Option">[in] The option to be processed.</param>
    ///  <param name="ParamIdx">[in/out] The option index is passed in. If the
    ///  option takes a parameter then this parameter must be increaed by one.
    ///  </param>
    ///  <param name="Terminated">[in/out] This parameter will always be
    ///  <c>False</c> when called. It should be set to <c>True</c> if option
    ///  processing should cease after processing this option.</param>
    ///  <remarks>This method parses options unique to BPatch. The version and
    ///  help options are parsed in the base class.</remarks>
    function ParseShortOption(const Options: string; const OptionIdx: Integer;
      var ParamIdx: Integer; var Terminated: Boolean): Boolean; override;

    ///  <summary>Parses and validates the given file name. Determines whether
    ///  the file name is either the old or new file name.</summary>
    procedure ParseFileName(const FileName: string); override;

    ///  <summary>Finalizes command line processing.</summary>
    ///  <remarks>Validates the required file names have been provided.
    ///  </remarks>
    procedure Finalize; override;

  public

    ///  <summary>Object constructor. Sets default property values.</summary>
    constructor Create;

    ///  <summary>Name of old file.</summary>
    property OldFileName: string read fOldFileName;

    ///  <summary>Name of new file.</summary>
    property NewFileName: string read fNewFileName;

    ///  <summary>Name of patch file.</summary>
    property PatchFileName: string read fPatchFileName;

    ///  <summary>Flag indicating whether the program's help screen is to be
    ///  displayed or not.</summary>
    property Help;

    ///  <summary>Flag indicating whether the program's version information is
    ///  to be displayed.</summary>
    property Version;

  end;


implementation


uses
  // Delphi
  System.StrUtils;


{ TParams }

constructor TParams.Create;
begin
  inherited;
  fOldFileName := '';
  fNewFileName := '';
  fPatchFileName := '';
end;

procedure TParams.Finalize;
begin
  if fOldFileName = '' then
    Error('file name argument missing');
  if fNewFileName = '' then
    fNewFileName := fOldFileName;
end;

procedure TParams.ParseFileName(const FileName: string);
begin
  if fOldFileName = '' then
    fOldFileName := FileName
  else if fNewFileName = '' then
    fNewFileName := FileName
  else
    Error('too many file names on command line');
end;

function TParams.ParseLongOption(const Option: string; var ParamIdx: Integer;
  var Terminated: Boolean): Boolean;
begin
  Result := inherited ParseLongOption(Option, ParamIdx, Terminated);
  if Result then
    Exit;
  Result := True;
  if Option = '--input' then
  begin
    Inc(ParamIdx);
    if ParamStr(ParamIdx) = '' then
      Error('missing argument to ''--input''');
    fPatchFileName := ParamStr(ParamIdx);
  end
  else if AnsiStartsStr('--input=', Option) then
    fPatchFileName := StripLeadingChars(Option, Length('--input='))
  else
    Result := False;
end;

function TParams.ParseShortOption(const Options: string;
  const OptionIdx: Integer; var ParamIdx: Integer; var Terminated: Boolean):
  Boolean;
begin
  Result := inherited ParseShortOption(
    Options, OptionIdx, ParamIdx, Terminated
  );
  if Result then
    Exit;
  Result := True;
  case Options[OptionIdx] of
    'i':
    begin
      Inc(ParamIdx);
      if ParamStr(ParamIdx) = '' then
        Error('missing argument to ''-i''');
      fPatchFileName := ParamStr(ParamIdx);
    end
    else
      Result := False;
  end;
end;

end.

