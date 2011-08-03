{
 * UBPatchParams.pas
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


unit UBPatchParams;

interface

uses
  // Delphi
  SysUtils;

type

  TParams = class(TObject)
  private
    fHelp: Boolean;
    fVersion: Boolean;
    fOldFileName: string;
    fNewFileName: string;
    fPatchFileName: string;
    procedure Error(const Msg: string); overload;
    procedure Error(const Fmt: string; const Args: array of const); overload;
  public
    constructor Create;
    procedure Parse;
    property OldFileName: string read fOldFileName;
    property NewFileName: string read fNewFileName;
    property PatchFileName: string read fPatchFileName;
    property Help: Boolean read fHelp default False;
    property Version: Boolean read fVersion default False;
  end;

  EParams = class(Exception);

implementation

{ TParams }

constructor TParams.Create;
begin
  inherited;
  fOldFileName := '';
  fNewFileName := '';
  fPatchFileName := '';
  fVersion := False;
  fHelp := False;
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
  ParamIdx: Integer;  // index of each parameter
  PParam: PChar;      // pointer to each parameter
  PC: PChar;          // pointer to characters in a parameter
begin
  ParamIdx := 1;
  while ParamIdx <= ParamCount do
  begin
    PParam := PChar(ParamStr(ParamIdx) + #0#0#0);
    if PParam[0] = '-' then
    begin
      if PParam[1] = '-' then
      begin
        { long option }
        PC := PParam + 2;
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
        else if StrComp(PC, 'input') = 0 then
        begin
          Inc(ParamIdx);
          PParam := PChar(ParamStr(ParamIdx));
          if (PParam^ = #0) then
            Error('missing argument to ''--input''');
          fPatchFileName := PParam;
        end
        else if StrLComp(PC, 'input=', 6) = 0 then
          fPatchFileName := PC + 6
        else
          Error('unknown option ''--%s''', [PC]);
      end
      else
      begin
        { short option }
        PC := PParam + 1;
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
            'i':
            begin
              Inc(ParamIdx);
              PParam := PChar(ParamStr(ParamIdx));
              if PParam^ = #0 then
                Error('missing argument to ''-i''');
              fPatchFileName := PParam;
            end
            else
              Error('unknown option ''-%s''', [PC^]);
          end;
          Inc(PC);
        end;
      end;
    end
    else
    begin
      if fOldFileName = '' then
        fOldFileName := ParamStr(ParamIdx)
      else if fNewFileName = '' then
        fNewFileName := ParamStr(ParamIdx)
      else
        Error('too many file names on command line');
    end;
    Inc(ParamIdx);
  end;

  if fOldFileName = '' then
    Error('file name argument missing');

  if fNewFileName = '' then
    fNewFileName := fOldFileName;
end;

end.

