//!  BSD 3-clause license: see LICENSE.md

///  <summary>Implements a heirachy of classes used for message logging for
///  BDiff.</summary>
///  <remarks>Used by BDiff only.</remarks>

unit BDiff.Logger;


interface


type

  ///  <summary>Abstract logger class.</summary>
  TLogger = class abstract(TObject)
  public
    ///  <summary>Logs message <c>Msg</c> to the supported output.</summary>
    procedure Log(const Msg: string); virtual; abstract;
  end;

  ///  <summary>Logger class factory.</summary>
  TLoggerFactory = class(TObject)
  public
    ///  <summary>Creates an instance of a logger class of a requested type.
    ///  </summary>
    ///  <param name="Verbose">[in] Determines if the logger will write to
    ///  stderr (<c>True</c>) or will be silent (<c>False</c>).</param>
    ///  <returns><c>TLogger</c> required logger instance.</returns>
    ///  <remarks>Caller is reponsible for freeing the returned object instance.
    ///  </remarks>
    class function Instance(Verbose: Boolean): TLogger;
  end;


implementation


uses
  // Project
  BDiff.IO,
  Common.AppInfo;


type

  ///  <summary>Logger class that writes to stderr.</summary>
  TVerboseLogger = class sealed(TLogger)
  public
    ///  <summary>Writes message <c>Msg</c> to stderr.</summary>
    procedure Log(const Msg: string); override;
  end;

  ///  <summary>Null logger class that writes no output.</summary>
  TSilentLogger = class sealed(TLogger)
  public
    ///  <summary>Outputs nothing.</summary>
    procedure Log(const Msg: string); override;
  end;


{ TVerboseLogger }

procedure TVerboseLogger.Log(const Msg: string);
begin
  TIO.WriteStrFmt(TIO.StdErr, '%s: %s'#13#10, [TAppInfo.ProgramFileName, Msg]);
end;

{ TSilentLogger }

procedure TSilentLogger.Log(const Msg: string);
begin
  // Do nothing: no output required
end;

{ TLoggerFactory }

class function TLoggerFactory.Instance(Verbose: Boolean): TLogger;
begin
  if Verbose then
    Result := TVerboseLogger.Create
  else
    Result := TSilentLogger.Create;
end;

end.

