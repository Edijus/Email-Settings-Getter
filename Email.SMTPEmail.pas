unit Email.SMTPEmail;

interface

uses
  {Delphi}
  System.SyncObjs
  , WinAPI.Windows
  , System.IOUtils
  , System.Types
  , Vcl.Dialogs
  , System.SysUtils
  , IdMessage
  , IdSMTP
  , IdEMailAddress
  , System.RegularExpressions
  , idText
  , IdAttachment
  , IdAttachmentFile
  , idGlobal
  , UrlMon
  {Project}
  , Email.EmailIntf
  , SMTPAuth
  ;

type
  TSMTPEmail = class(TInterfacedObject, IEmail)
  strict private
    FSMTPClient: TidSMTP;
    FSMTPAuth: TSMTPAuth;
    FLastErrorMsg: string;
    FSender: string;
    function FindMimeType(const AFile: string): string;
    procedure SetLastErrorMsg(const AMessage: string);
  public
    constructor Create(const AHost, AUser, AUserPassw, ASender: string;
      const APort: DWord; const ASMTPAuth: TSMTPAuth; const AReadTimeOut, AConnectTimeOut: integer);
    destructor Destroy; override;
    function SendEmail(const AMsgBody, ASubject: string; const AReceivers: TStringDynArray;
      const AFileList: TStringDynArray = nil): Boolean;
    function GetLastErrorMsg: string;
  end;

implementation

uses
  {Delphi}
  IdSASLLogin
  , IdUserPassProvider
  , IdSSLOpenSSL
  , System.StrUtils
  {Project}
  ;

var
  FCriticalSection: TCriticalSection;

constructor TSMTPEmail.Create(const AHost, AUser, AUserPassw, ASender: string;
  const APort: DWord; const ASMTPAuth: TSMTPAuth; const AReadTimeOut, AConnectTimeOut: integer);
begin
  inherited Create;

  if (Trim(AHost) = '') then
    raise EArgumentException.Create('TSMTPEmail.Create: Host is not provided');

  if (Trim(AUser) = '') then
    raise EArgumentException.Create('TSMTPEmail.Create: User is not provided');

  if (Trim(AUserPassw) = '') then
    raise EArgumentException.Create
      ('TSMTPEmail.Create: Password is not provided');

  if (Trim(ASender) = '') then
    raise EArgumentException.Create
      ('TSMTPEmail.Create: Sender is not provided');

  FSender := ASender;
  FSMTPAuth := ASMTPAuth;

  FSMTPClient := TidSMTP.Create(nil);
  FSMTPClient.Host := AHost;
  FSMTPClient.Username := AUser;
  FSMTPClient.Password := AUserPassw;
  FSMTPClient.Port := APort;

  FSMTPClient.ConnectTimeout := AConnectTimeOut;
  FSMTPClient.ReadTimeout := AReadTimeOut;
end;

function TSMTPEmail.GetLastErrorMsg: string;
begin
  Result := FLastErrorMsg;
end;

destructor TSMTPEmail.Destroy;
begin
  FreeAndNil(FSMTPClient);
  inherited;
end;

function TSMTPEmail.FindMimeType(const AFile: string): string;
var
  _MimeType: PWideChar;
begin
  Result := 'application/pdf';
  if not FileExists(AFile) then
    Exit;

  _MimeType := nil;
  FindMimeFromData(nil, PWideChar(AFile), nil, 0, nil, 0, _MimeType, 0);
  Result := _MimeType;
  if (Trim(Result) = '') then
    Result := 'application/pdf';
end;

function TSMTPEmail.SendEmail(const AMsgBody, ASubject: string; const AReceivers: TStringDynArray;
  const AFileList: TStringDynArray = nil): Boolean;
const
  METHOD_NAME = 'TSMTPEmail.SendEmail';
var
  _IdMessage: TIdMessage;
  i: integer;
  _FileList: string;
  _SASLLogin: TIdSASLLogin;
  _UserPassProvider: TIdUserPassProvider;
  _AuthError: string;
  _Body: TStringDynArray;
begin
  Result := False;

  FCriticalSection.Acquire;
  try
    if Length(AReceivers) < 1 then
    begin
      SetLastErrorMsg(METHOD_NAME + ': Nenurodyti gavėjų adresai.');
      Exit;
    end;

    for i := 0 to Length(AReceivers) - 1 do
    begin
      if not TRegEx.IsMatch(AReceivers[i],
        '^[a-z0-9][-a-z0-9.!#$%&''*+-=?^_`{|}~\/]+@([-a-z0-9]+\.)+[a-z]{2,5}$')
      then
      begin
        SetLastErrorMsg(METHOD_NAME + ': Neteisingas gavėjo adresas: ' + AReceivers[i]);
        Exit;
      end;
    end;

    FSMTPClient.Disconnect(False);

    FSMTPClient.AuthType := FSMTPAuth.AuthType;

    if FSMTPClient.AuthType <> satNone then
    begin
      FSMTPClient.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FSMTPClient);
      FSMTPClient.UseTLS := FSMTPAuth.UseTLS;
      TIdSSLIOHandlerSocketOpenSSL(FSMTPClient.IOHandler).SSLOptions.Method := FSMTPAuth.SSLVersion;

      if FSMTPClient.AuthType = satSASL then
      begin
        _SASLLogin := TIdSASLLogin.Create(FSMTPClient);
        _UserPassProvider := TIdUserPassProvider.Create(_SASLLogin);

        _SASLLogin.UserPassProvider := _UserPassProvider;
        _UserPassProvider.Username := FSMTPClient.Username;
        _UserPassProvider.Password := FSMTPClient.Password;

        FSMTPClient.SASLMechanisms.Add.SASL := _SASLLogin;
      end;
    end;

    try
      FSMTPClient.Connect;
    except
      on E: Exception do
      begin
        SetLastErrorMsg(METHOD_NAME + ': Connecting error: ' + E.Message);
        Result := False;
        Exit;
      end;
    end;

    try
      _AuthError := 'Nepavyko autentifikuoti ' + FSMTPClient.Username + '@' + FSMTPClient.Host + ':' +
          IntToStr(FSMTPClient.Port) + '. Gal bloga konfigūracija?';

      if not FSMTPClient.Authenticate then
      begin
        SetLastErrorMsg(METHOD_NAME + ': ' + _AuthError);
        Exit;
      end;
    except
      on E: Exception do
      begin
        if AnsiContainsText(E.Message, 'authentication failed') then
        begin
          SetLastErrorMsg(METHOD_NAME + ': ' + _AuthError);
          Exit;
        end
        else
          raise;
      end;
    end;

    _IdMessage := TIdMessage.Create(nil);
    try

      with TIdText.Create(_IdMessage.MessageParts, nil) do
      begin
        _Body := SplitString(AMsgBody, sLineBreak);
        for i := 0 to Length(_Body) - 1 do
          Body.Add(_Body[i]);
        ContentType := 'text/plain; charset=UTF-8';
      end;

      _FileList := '';
      if Length(AFileList) <> 0 then
      begin
        for i := 0 to Length(AFileList) - 1 do
        begin
          if (Trim(AFileList[i]) = '') then
            Continue;

          if (not FileExists(AFileList[i])) then
          begin
            SetLastErrorMsg (METHOD_NAME + ': Siunčiamas failas: "' + AFileList[i] + '" nerastas');
            Exit;
          end;

          with TIdAttachmentFile.Create(_IdMessage.MessageParts,
            AFileList[i]) do
          begin
            ContentID := '12345';
            ContentType := FindMimeType(AFileList[i]);
            FileName := ExtractFileName(AFileList[i]);
          end;

          _FileList := _FileList + AFileList[i] + ', ';
        end;
      end;

      _IdMessage.From.Name := ASubject;
      _IdMessage.From.Address := FSender;
      _IdMessage.Subject := ASubject;
      _IdMessage.CharSet := 'UTF-8';
      _IdMessage.ContentType := 'multipart/related; type="text/html"';

      for i := 0 to Length(AReceivers) - 1 do
        _IdMessage.Recipients.Add.Address := AReceivers[i];

      try
        FSMTPClient.Send(_IdMessage);
        Result := True;

        if Length(_FileList) <> 0 then
          _FileList := Copy(_FileList, 1, Length(_FileList) - 2);

        if _FileList <> '' then
          SetLastErrorMsg(METHOD_NAME + ': El. laiškas su failais "' + _FileList + '" iš ' + FSender + ' į ' +
            AReceivers[0] + ' išsiųstas sėkmingai.')
        else
          SetLastErrorMsg(METHOD_NAME + ': El. laiškas iš ' + FSender + ' į ' + AReceivers[0] + ' išsiųstas sėkmingai.');
      except
        on E: Exception do
        begin
          SetLastErrorMsg(METHOD_NAME + ': Nepavyko nusiųsti laiško tema "' + ASubject + '" iš ' + FSender + ' į ' +
            AReceivers[0] + ': ' + E.Message);
          Result := False;
        end;
      end;
    finally
      FreeAndNil(_IdMessage);
    end;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TSMTPEmail.SetLastErrorMsg(const AMessage: string);
begin
  FLastErrorMsg := AMessage;
end;

initialization

FCriticalSection := TCriticalSection.Create;

finalization

FreeAndNil(FCriticalSection);

end.
