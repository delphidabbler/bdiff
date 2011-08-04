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

uses   UBPatchUtils,
  // Delphi
  StrUtils;

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
  Param: string;
  CharIdx: Integer;
begin
  // Parse command line
  ParamIdx := 1;
  while ParamIdx <= ParamCount do
  begin
    Param := ParamStr(ParamIdx);
    if AnsiStartsStr('-', Param) then
    begin
      // options
      if AnsiStartsStr('--', Param) then
      begin
        // long option
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
        else if Param = '--input' then
        begin
          Inc(ParamIdx);
          if ParamStr(ParamIdx) = '' then
            Error('missing argument to ''--input''');
          fPatchFileName := ParamStr(ParamIdx);
        end
        else if AnsiStartsStr('--input=', Param) then
          fPatchFileName :=
            AnsiRightStr(Param, Length(Param) - Length('--input='))
        else
          Error('unknown option ''%s''', [Param]);
      end
      else
      begin
        // short option
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
            'i':
            begin
              Inc(ParamIdx);
              if ParamStr(ParamIdx) = '' then
                Error('missing argument to ''-i''');
              fPatchFileName := ParamStr(ParamIdx);
            end
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

  if fOldFileName = '' then
    Error('file name argument missing');

  if fNewFileName = '' then
    fNewFileName := fOldFileName;

end;

end.

