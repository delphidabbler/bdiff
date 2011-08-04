{
 * UBDiffParams.pas
 *
 * Implements a class that parses command lines and records parameters.
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


unit UBDiffParams;

interface

uses
  // Delphi
  SysUtils,
  // Project
  UBDiffTypes;

type

  TParams = class(TObject)
  private
    fHelp: Boolean;
    fVerbose: Boolean;
    fVersion: Boolean;
    fMinEqual: Integer;
    fOldFileName: string;
    fPatchFileName: string;
    fNewFileName: string;
    fFormat: TFormat;
    procedure Error(const Msg: string); overload;
    procedure Error(const Fmt: string; const Args: array of const); overload;
    procedure SetFormat(const Value: string);
    procedure SetMinEqual(const Value: string);
  public
    constructor Create;
    procedure Parse;
    property OldFileName: string read fOldFileName;
    property NewFileName: string read fNewFileName;
    property PatchFileName: string read fPatchFileName;
    property MinEqual: Integer read fMinEqual default 24;
    property Verbose: Boolean read fVerbose default False;
    property Help: Boolean read fHelp default False;
    property Version: Boolean read fVersion default False;
    property Format: TFormat read fFormat default FMT_QUOTED;
  end;

  EParams = class(Exception);

implementation

uses
  // Delphi
  StrUtils;

{ TParams }

constructor TParams.Create;
begin
  inherited;
  fOldFileName := '';
  fNewFileName := '';
  fPatchFileName := '';
  fMinEqual := 24;
  fVersion := False;
  fHelp := False;
  fVerbose := False;
  fFormat := FMT_QUOTED;
end;

procedure TParams.Error(const Msg: string);
begin
  raise EParams.Create(Msg);
end;

procedure TParams.Error(const Fmt: string; const Args: array of const);
begin
  raise EParams.CreateFmt(Fmt, Args);
end;

procedure TParams.Parse;
var
  ParamIdx: Integer;
  CharIdx: Integer;
  Param: string;
begin
  // Parse command line
  ParamIdx := 1;
  while (ParamIdx <= ParamCount) do
  begin
    Param := ParamStr(ParamIdx);
    if AnsiStartsStr('-', Param) then
    begin
      // options
      if AnsiStartsStr('--', Param) then
      begin
        // long options
        if Param = '--help' then
        begin
          fHelp := True;
          Exit;
        end
        else if Param = '--version' then
        begin
          fVersion := True;
          Exit;
        end
        else if Param = '--verbose' then
          fVerbose := True
        else if Param = '--output' then
        begin
          Inc(ParamIdx);
          Param := ParamStr(ParamIdx);
          if Param = '' then
            Error('missing argument to ''--output''');
          fPatchFileName := Param;
        end
        else if AnsiStartsStr('--output=', Param) then
          fPatchFileName :=
            AnsiRightStr(Param, Length(Param) - Length('--output='))
        else if Param = '--format' then
        begin
          Inc(ParamIdx);
          SetFormat(ParamStr(ParamIdx));
        end
        else if AnsiStartsStr('--format=', Param) then
          SetFormat(AnsiRightStr(Param, Length(Param) - Length('--format=')))
        else if Param = '--min-equal' then
        begin
          Inc(ParamIdx);
          SetMinEqual(ParamStr(ParamIdx));
        end
        else if AnsiStartsStr('--min-equal=', Param) then
          SetMinEqual(
            AnsiRightStr(Param, Length(Param) - Length('--min-equal='))
          )
        else
          Error('unknown option ''%s''', [Param]);
      end
      else
      begin
        { short options }
        for CharIdx := 2 to Length(Param) do
        begin
          case Param[CharIdx] of
            'h':
              if CharIdx = Length(Param) then
              begin
                fHelp := True;
                Exit;
              end;
            'v':
              if CharIdx = Length(Param) then
              begin
                fVersion := True;
                Exit;
              end;
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
              Error('unknown option ''-%s''', [Param[CharIdx]]);
          end;
        end;
      end;
    end
    else
    begin
      // file names
      if fOldFileName = '' then
        fOldFileName := ParamStr(ParamIdx)
      else if fNewFileName = '' then
        fNewFileName := ParamStr(ParamIdx)
      else
        Error('too many file names on command line');
    end;
    Inc(ParamIdx);
  end;
  if fNewFileName = '' then
    Error('need two filenames');
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
var
  X: Int64; // number parsed from command line
begin
  if Value = '' then
    Error('missing argument to ''--min-equal'' / ''-m''');
  if not TryStrToInt64(Value, X) or (X < 0) then
    Error('malformed number on command line');
  if (X = 0) or (X > $7FFF) then
    Error('number out of range on command line');
  fMinEqual := Integer(X);
end;

end.

