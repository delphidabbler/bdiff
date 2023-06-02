//!  BSD 3-clause license: see LICENSE.md

///  <summary>Command line parser for commands common to both programs.</summary>
///  <remarks>Code common to both BDiff and BPatch.</remarks>

unit Common.Params;


interface


uses
  // Delphi
  System.SysUtils;


type

  ///  <summary>Abstract base class for program's command line parser.</summary>
  ///  <remarks>Parses commands that apply to both BDiff and BPatch.</remarks>
  TBaseParams = class abstract(TObject)
  strict private
    var
      // Property values
      fHelp: Boolean;
      fVersion: Boolean;
  strict protected
    ///  <summary>Strips <c>Count</c> leading characters from string <c>S</c>
    ///  and returns the resulting string.</summary>
    class function StripLeadingChars(const S: string; const Count: Integer):
      string;

    ///  <summary>Raises a <c>EParams</c> exception with messsage <c>Msg</c>.
    ///  </summary>
    procedure Error(const Msg: string); overload;

    ///  <summary>Raises a <c>EParams</c> exception with messsage created from
    ///  format string <c>Fmt</c> and arguments <c>Args</c>.</summary>
    procedure Error(const Fmt: string; const Args: array of const); overload;

    ///  <summary>Parses options in long format (<c>--xxx</c>).</summary>
    ///  <param name="Option">[in] The option to be processed.</param>
    ///  <param name="ParamIdx">[in/out] The option index is passed in. If the
    ///  option takes a parameter then this parameter must be increaed by one.
    ///  </param>
    ///  <param name="Terminated">[in/out] This parameter will always be
    ///  <c>False</c> when called. It should be set to <c>True</c> if option
    ///  processing should cease after processing this option.</param>
    ///  <remarks>This method parses the version and help options. Descendants
    ///  should override to process further options.</remarks>
    function ParseLongOption(const Option: string; var ParamIdx: Integer;
      var Terminated: Boolean): Boolean; virtual;

    ///  <summary>Parses options in long format (<c>-x</c>).</summary>
    ///  <param name="Option">[in] The option to be processed.</param>
    ///  <param name="ParamIdx">[in/out] The option index is passed in. If the
    ///  option takes a parameter then this parameter must be increaed by one.
    ///  </param>
    ///  <param name="Terminated">[in/out] This parameter will always be
    ///  <c>False</c> when called. It should be set to <c>True</c> if option
    ///  processing should cease after processing this option.</param>
    ///  <remarks>This method parses the version and help options. Descendants
    ///  should override to process further options.</remarks>
    function ParseShortOption(const Options: string; const OptionIdx: Integer;
      var ParamIdx: Integer; var Terminated: Boolean): Boolean; virtual;

    ///  <summary>Parses the given file name passed on command line.</summary>
    procedure ParseFileName(const FileName: string); virtual; abstract;

    ///  <summary>Finalizes parameter string processing, adjusting parameters
    ///  and checking for errors.</summary>
    procedure Finalize; virtual; abstract;

  public
    ///  <summary>Object constructor. Sets default property values.</summary>
    constructor Create;

    ///  <summary>Parses command line.</summary>
    procedure Parse;

    ///  <summary>Flag indicating whether the program's help screen is to be
    ///  displayed or not.</summary>
    property Help: Boolean read fHelp default False;

    ///  <summary>Flag indicating whether the program's version information is
    ///  to be displayed.</summary>
    property Version: Boolean read fVersion default False;
  end;

type
  EParams = class(Exception);


implementation


uses
  // Delphi
  System.StrUtils,
  // Project
  Common.Errors;


{ TBaseParams }

constructor TBaseParams.Create;
begin
  inherited Create;
  fVersion := False;
  fHelp := False;
end;

procedure TBaseParams.Error(const Msg: string);
begin
  raise EParams.Create(Msg);
end;

procedure TBaseParams.Error(const Fmt: string; const Args: array of const);
begin
  raise EParams.CreateFmt(Fmt, Args);
end;

procedure TBaseParams.Parse;
begin
  // Parse command line
  var Terminated := False;
  var ParamIdx: Integer := 1;
  while ParamIdx <= ParamCount do
  begin
    var Param := ParamStr(ParamIdx);
    if AnsiStartsStr('-', Param) then
    begin
      if AnsiStartsStr('--', Param) then
      begin
        // long option
        if not ParseLongOption(Param, ParamIdx, Terminated) then
          Error('unknown option ''%s''', [Param]);
        if Terminated then
          Exit;
      end
      else
      begin
        // short options
        for var CharIdx := 2 to Length(Param) do
        begin
          if not ParseShortOption(Param, CharIdx, ParamIdx, Terminated) then
            Error('unknown option ''-%s''', [Param[CharIdx]]);
          if Terminated then
            Exit;
        end;
      end;
    end
    else
      ParseFileName(Param);
    Inc(ParamIdx);
  end;
  Finalize;
end;

function TBaseParams.ParseLongOption(const Option: string;
  var ParamIdx: Integer; var Terminated: Boolean): Boolean;
begin
  Result := True;
  if Option = '--help' then
  begin
    fHelp := True;
    Terminated := True;
  end
  else if Option = '--version' then
  begin
    fVersion := True;
    Terminated := True;
  end
  else
    Result := False;
end;

function TBaseParams.ParseShortOption(const Options: string;
  const OptionIdx: Integer; var ParamIdx: Integer;
  var Terminated: Boolean): Boolean;
begin
  Result := True;
  case Options[OptionIdx] of
    'h':
      if OptionIdx = Length(Options) then
      begin
        fHelp := True;
        Terminated := True;
      end;
    'v':
      if OptionIdx = Length(Options) then
      begin
        fVersion := True;
        Terminated := True;
      end;
    else
      Result := False;
  end;
end;

class function TBaseParams.StripLeadingChars(const S: string;
  const Count: Integer): string;
begin
  if Count > 0 then
    Result := AnsiRightStr(S, Length(S) - Count)
  else
    Result := S;
end;

end.

