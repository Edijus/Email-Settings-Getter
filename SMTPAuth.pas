unit SMTPAuth;

interface

uses
  {Delphi}
  idSMTP
  , IdExplicitTLSClientServerBase
  , IdSSLOpenSSL
  , System.SysUtils
  {Project}
  ;

type
  TSMTPAuth = record
    AuthType: TIdSMTPAuthenticationType;
    UseTLS: TIdUseTLS;
    SSLVersion: TIdSSLVersion;
  end;

function StrToSMTPAuthenticationType(const AString: string; out ASMTPAuthenticationType: TIdSMTPAuthenticationType): Boolean;
function StrToSSLVersion(const AString: string; out ASSLVersion: TIdSSLVersion): Boolean;
function StrToUseTLS(const AString: string; out AUseTLS: TIdUseTLS): Boolean;

implementation

function StrToSSLVersion(const AString: string; out ASSLVersion: TIdSSLVersion): Boolean;
begin
  Result := False;

  if LowerCase(AString) = LowerCase('sslvSSLv2') then
  begin
    ASSLVersion := sslvSSLv2;
    Result := True;
  end
  else if LowerCase(AString) = LowerCase('sslvSSLv23') then
  begin
    ASSLVersion := sslvSSLv23;
    Result := True;
  end
  else if LowerCase(AString) = LowerCase('sslvSSLv3') then
  begin
    ASSLVersion := sslvSSLv3;
    Result := True;
  end
  else if LowerCase(AString) = LowerCase('sslvTLSv1') then
  begin
    ASSLVersion := sslvTLSv1;
    Result := True;
  end
  else if LowerCase(AString) = LowerCase('sslvTLSv1_1') then
  begin
    ASSLVersion := sslvTLSv1_1;
    Result := True;
  end
  else if LowerCase(AString) = LowerCase('sslvTLSv1_2') then
  begin
    ASSLVersion := sslvTLSv1_2;
    Result := True;
  end
end;

function StrToUseTLS(const AString: string; out AUseTLS: TIdUseTLS): Boolean;
begin
  Result := False;

  if LowerCase(AString) = LowerCase('utNoTLSSupport') then
  begin
    AUseTLS := utNoTLSSupport;
    Result := True;
  end
  else if LowerCase(AString) = LowerCase('utUseImplicitTLS') then
  begin
    AUseTLS := utUseImplicitTLS;
    Result := True;
  end
  else if LowerCase(AString) = LowerCase('utUseRequireTLS') then
  begin
    AUseTLS := utUseRequireTLS;
    Result := True;
  end
  else if LowerCase(AString) = LowerCase('utUseExplicitTLS') then
  begin
    AUseTLS := utUseExplicitTLS;
    Result := True;
  end;
end;

function StrToSMTPAuthenticationType(const AString: string; out ASMTPAuthenticationType: TIdSMTPAuthenticationType): Boolean;
begin
  Result := False;

  if LowerCase(AString) = LowerCase('satNone') then
  begin
    ASMTPAuthenticationType := satNone;
    Result := True;
  end
  else if LowerCase(AString) = LowerCase('satDefault') then
  begin
    ASMTPAuthenticationType := satDefault;
    Result := True;
  end
  else if LowerCase(AString) = LowerCase('satSASL') then
  begin
    ASMTPAuthenticationType := satSASL;
    Result := True;
  end;
end;

end.
