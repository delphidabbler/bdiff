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
    procedure SetFormat(P: PChar);
    procedure SetMinEqual(P: PChar);
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
  // Project
  UBDiffUtils;

{ cut down version of C std lib strtoul function that only supports base 10 }
function StrToULDec(const PS: PChar; var EndPtr: PChar): LongWord;
begin
  EndPtr := PS;
  Result := 0;
  while EndPtr^ in ['0'..'9'] do
  begin
    Result := 10 * Result + LongWord((Ord(EndPtr^) - Ord('0')));
    Inc(EndPtr);
  end;
end;

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
  Idx: Integer;
  ArgV: PChar;
  PC: PChar;
begin
  { Parse command line }
  Idx := 1;
  while (Idx <= ParamCount) do
  begin
    ArgV := PChar(ParamStr(Idx) + #0#0#0);
    if ArgV[0] = '-' then
    begin
      if ArgV[1] = '-' then
      begin
        { long options }
        PC := ArgV + 2;
        if StrComp(PC, 'help') = 0 then
        begin
          fHelp := True;
          Exit;
        end
        else if StrComp(PC, 'version') = 0 then
        begin
          fVersion := True;
          Exit;
        end
        else if StrComp(PC, 'verbose') = 0 then
          fVerbose := True
        else if StrComp(PC, 'output') = 0 then
        begin
          Inc(Idx);
          ArgV := PChar(ParamStr(Idx));
          if (ArgV^ = #0) then
            Error('missing argument to ''--output''');
          fPatchFileName := ArgV;
        end
        else if StrLComp(PC, 'output=', 7) = 0 then
          fPatchFileName := PC + 7
        else if StrComp(PC, 'format') = 0 then
        begin
          Inc(Idx);
          ArgV := PChar(ParamStr(Idx));
          SetFormat(ArgV);
        end
        else if StrLComp(PC, 'format=', 7) = 0 then
          SetFormat(PC + 7)
        else if StrComp(PC, 'min-equal') = 0 then
        begin
          Inc(Idx);
          ArgV := PChar(ParamStr(Idx));
          SetMinEqual(ArgV);
        end
        else if StrLComp(PC, 'min-equal=', 10) = 0 then
          SetMinEqual(PC + 10)
        else
          Error('unknown option ''--%s''', [PC]);
      end
      else
      begin
        { short options }
        PC := ArgV + 1;
        while PC^ <> #0 do
        begin
          case PC^ of
            'h':
              if StrComp(PC, 'h') = 0 then
              begin
                fHelp := True;
                Exit;
              end;
            'v':
              if StrComp(PC, 'v') = 0 then
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
              Inc(Idx);
              ArgV := PChar(ParamStr(Idx));
              SetMinEqual(ArgV);
            end;
            'o':
            begin
              Inc(Idx);
              ArgV := PChar(ParamStr(Idx));
              if ArgV^ = #0 then
                Error('missing argument to ''-o''');
              fPatchFileName := ArgV;
            end;
            else
              Error('unknown option ''-%s''', [PC^]);
          end;
          Inc(PC);
        end;
      end;
    end
    else
    begin
      { file names }
      if fOldFileName = '' then
        fOldFileName := ParamStr(Idx)
      else if fNewFileName = '' then
        fNewFileName := ParamStr(Idx)
      else
        Error('too many file names on command line');
    end;
    Inc(Idx);
  end;
  if fNewFileName = '' then
    Error('need two filenames');
end;

procedure TParams.SetFormat(P: PChar);
begin
  if not Assigned(p) then
    Error('missing argument to ''--format''');
  if StrComp(p, 'quoted') = 0 then
    fFormat := FMT_QUOTED
  else if (StrComp(p, 'filter') = 0) or (StrComp(p, 'filtered') = 0) then
    fFormat := FMT_FILTERED
  else if StrComp(p, 'binary') = 0 then
    fFormat := FMT_BINARY
  else
    Error('invalid format specification');
end;

procedure TParams.SetMinEqual(P: PChar);
var
  q: PChar;
  x: LongWord;
begin
  if not Assigned(p) or (p^ = #0) then
    Error('missing argument to ''--min-equal'' / ''-m''');
  x := StrToULDec(p, q);
  if q^ <> #0 then
    Error('malformed number on command line');
  if (x = 0) or (x > $7FFF) then
    Error('number out of range on command line');
  fMinEqual := x;
end;

end.

