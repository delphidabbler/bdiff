//!  BSD 3-clause license: see LICENSE.md

///  <summary>BDiff command line parser.</summary>
///  <remarks>Used by BDiff only.</remarks>

unit BDiff.Params;


interface


uses
  // Project
  BDiff.Types,
  Common.Params;


type

  ///  <summary>BDiff command line parser class.</summary>
  TParams = class sealed(TBaseParams)
  strict private
    var
      // Property values
      fVerbose: Boolean;
      fMinEqual: Integer;
      fOldFileName: string;
      fPatchFileName: string;
      fNewFileName: string;
      fFormat: TFormat;
      fOverrideMaxSize: Boolean;

    ///  <summary>Write accessor for <c>Format</c> property.</summary>
    ///  <remarks>Parses and validates property value <c>Value</c>.</remarks>
    procedure SetFormat(const Value: string);

    ///  <summary>Write accessor for <c>MinEqual</c> property.</summary>
    ///  <remarks>Parses and validates property value <c>Value</c>.</remarks>
    procedure SetMinEqual(const Value: string);

  strict protected

    ///  <summary>Parses options in long format (<c>--xxx</c>).</summary>
    ///  <param name="Option">[in] The option to be processed.</param>
    ///  <param name="ParamIdx">[in/out] The option index is passed in. If the
    ///  option takes a parameter then this parameter must be increaed by one.
    ///  </param>
    ///  <param name="Terminated">[in/out] This parameter will always be
    ///  <c>False</c> when called. It should be set to <c>True</c> if option
    ///  processing should cease after processing this option.</param>
    ///  <remarks>This method parses options unique to BDiff. The version and
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
    ///  <remarks>This method parses options unique to BDiff. The version and
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

    ///  <summary>Minimum length of data chunks that can be recognized as equal.
    ///  </summary>
    property MinEqual: Integer read fMinEqual default 24;

    ///  <summary>Flag indicating whether output is to be verbose (<c>True</c>)
    ///  or silent (<c>False</c>).</summary>
    property Verbose: Boolean read fVerbose default False;

    ///  <summary>Format of patch output.</summary>
    property Format: TFormat read fFormat default FMT_QUOTED;

    ///  <summary>Flag indicating whether to override maximum file size limit to
    ///  permit oversize files to be diffed.</summary>
    property OverrideMaxSize: Boolean read fOverrideMaxSize default False;

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
  System.SysUtils,
  System.StrUtils;


{ TParams }

constructor TParams.Create;
begin
  inherited;
  fOldFileName := '';
  fNewFileName := '';
  fPatchFileName := '';
  fMinEqual := 24;
  fVerbose := False;
  fFormat := FMT_QUOTED;
  fOverrideMaxSize := False;
end;

procedure TParams.Finalize;
begin
  if fNewFileName = '' then
    Error('need two filenames');
  if SameFileName(fOldFileName, fNewFileName) then
    Error('file names must not be the same');
  if SameFileName(fOldFileName, fPatchFileName)
    or SameFileName(fNewFileName, fPatchFileName) then
    Error('output file name must differ from other file names');
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

  if Option = '--verbose' then
    fVerbose := True

  else if Option = '--output' then
  begin
    Inc(ParamIdx);
    if ParamStr(ParamIdx) = '' then
      Error('missing argument to ''--output''');
    fPatchFileName := ParamStr(ParamIdx);
  end
  else if AnsiStartsStr('--output=', Option) then
    fPatchFileName := StripLeadingChars(Option, Length('--output='))

  else if Option = '--format' then
  begin
    Inc(ParamIdx);
    SetFormat(ParamStr(ParamIdx));
  end
  else if AnsiStartsStr('--format=', Option) then
    SetFormat(StripLeadingChars(Option, Length('--format=')))

  else if Option = '--min-equal' then
  begin
    Inc(ParamIdx);
    SetMinEqual(ParamStr(ParamIdx));
  end
  else if AnsiStartsStr('--min-equal=', Option) then
    SetMinEqual(StripLeadingChars(Option, Length('--min-equal=')))

  else if AnsiStartsStr('--permit-large-files', Option) then
    fOverrideMaxSize := True

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
    'V':
      fVerbose := True;
    'q':
      fFormat := FMT_QUOTED;
    'f':
      fFormat := FMT_FILTERED;
    'b':
      fFormat := FMT_BINARY;
    'm':
    begin
      Inc(ParamIdx);
      SetMinEqual(ParamStr(ParamIdx));
    end;
    'o':
    begin
      Inc(ParamIdx);
      if ParamStr(ParamIdx) = '' then
        Error('missing argument to ''-o''');
      fPatchFileName := ParamStr(ParamIdx);
    end;
    else
      Result := False;
  end;
end;

procedure TParams.SetFormat(const Value: string);
begin
  if Value = '' then
    Error('missing argument to ''--format''');
  if Value = 'quoted' then
    fFormat := FMT_QUOTED
  else if (Value = 'filter') or (Value = 'filtered') then
    fFormat := FMT_FILTERED
  else if Value = 'binary' then
    fFormat := FMT_BINARY
  else
    Error('invalid format specification');
end;

procedure TParams.SetMinEqual(const Value: string);
begin
  if Value = '' then
    Error('missing argument to ''--min-equal'' / ''-m''');
  var X: Int64;
  if not TryStrToInt64(Value, X) or (X < 0) then
    Error('malformed number on command line');
  if (X = 0) or (X > $7FFF) then
    Error('number out of range on command line');
  fMinEqual := Integer(X);
end;

end.

