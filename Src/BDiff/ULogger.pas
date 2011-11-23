{
 * ULogger.pas
 *
 * Classes used to log messages plus a factory class. One logger class logs to
 * standard error while the second does nothing.
 *
 * Copyright (c) 2011 Peter D Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY.
 * IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE
 * USE OF THIS SOFTWARE.
 *
 * For conditions of distribution and use see the LICENSE file of visit
 * http://www.delphidabbler.com/software/bdiff/license
}


unit ULogger;

interface

type
  TLogger = class(TObject)
  public
    procedure Log(const Msg: string); virtual; abstract;
  end;

type
  TLoggerFactory = class(TObject)
  public
    class function Instance(Verbose: Boolean): TLogger;
  end;

implementation

uses
  UAppInfo, UBDiffUtils;

type
  TVerboseLogger = class(TLogger)
  public
    procedure Log(const Msg: string); override;
  end;

type
  TSilentLogger = class(TLogger)
  public
    procedure Log(const Msg: string); override;
  end;

{ TVerboseLogger }

procedure TVerboseLogger.Log(const Msg: string);
begin
  TIO.WriteStrFmt(TIO.StdErr, '%s: %s'#13#10, [ProgramFileName, Msg]);
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
