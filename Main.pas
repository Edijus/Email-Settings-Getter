unit Main;

interface

uses
  Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Variants
  , System.Classes
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , Vcl.StdCtrls
  , Vcl.Buttons
  , SMTPAuth
  ;

type
  TfrmMain = class(TForm)
    lblHost: TLabel;
    lblPort: TLabel;
    lblUser: TLabel;
    lblPassword: TLabel;
    eHost: TEdit;
    ePassword: TEdit;
    eUser: TEdit;
    ePort: TEdit;
    lblReadTimeout: TLabel;
    btnSearch: TBitBtn;
    memLog: TMemo;
    eReadTimeout: TEdit;
    lblConnectTimeout: TLabel;
    eConnectTimeout: TEdit;
    cbCheckAll: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
  private
    { Private declarations }
    procedure LogTry(const AMessage: string; const ASMTPAuth: TSMTPAuth);
    procedure Log(const AMessage: string);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  idSMTP
  , IdExplicitTLSClientServerBase
  , IdSSLOpenSSL
  , RTTI
  , Email.SMTPEmail
  , Email.EmailIntf
  , System.Types
  ;

procedure TfrmMain.Log(const AMessage: string);
begin
  memLog.Lines.Add(FormatDateTime('HH:NN:SS.ZZZ', Now) + ': ' + AMessage);
end;

function SMTPAuthToStr(const ASMTPAuth: TSMTPAuth): string;
begin
  Result := TRttiEnumerationType.GetName(ASMTPAuth.AuthType) + ', ' +
    TRttiEnumerationType.GetName(ASMTPAuth.UseTLS) + ', ' +
    TRttiEnumerationType.GetName(ASMTPAuth.SSLVersion);
end;

procedure TfrmMain.LogTry(const AMessage: string; const ASMTPAuth: TSMTPAuth);
begin
  Log(Trim(AMessage) + ' ' + SMTPAuthToStr(ASMTPAuth));
end;

procedure TfrmMain.btnSearchClick(Sender: TObject);
var
 _SSLVersion: TIdSSLVersion;
 _AuthType: TIdSMTPAuthenticationType;
 _UseTLS: TIdUseTLS;
 _SMTPAuth: TSMTPAuth;
 _SMTPEmail: IEMail;
 _Receivers: TStringDynArray;
begin
  for _AuthType := Low(TIdSMTPAuthenticationType) to High(TIdSMTPAuthenticationType) do
  begin
    for _SSLVersion := Low(TIdSSLVersion) to High(TIdSSLVersion) do
    begin
      for _UseTLS := Low(TIdUseTLS) to High(TIdUseTLS) do
      begin
        _SMTPAuth.AuthType := _AuthType;
        _SMTPAuth.UseTLS := _UseTLS;
        _SMTPAuth.SSLVersion := _SSLVersion;

        _SMTPEmail := TSMTPEmail.Create(eHost.Text, eUser.Text, ePassword.Text, eUser.Text,
          StrToInt(ePort.Text), _SMTPAuth, StrToInt(eReadTimeout.Text), StrToInt(eConnectTimeout.Text));

        SetLength(_Receivers, 1);
        _Receivers[0] := eUser.Text;

        try
          if not _SMTPEmail.SendEmail('Rasti nustatymai: ' + SMTPAuthToStr(_SMTPAuth),
            'Rasti SMTP nustatymai', _Receivers, nil) then
            LogTry(_SMTPEmail.GetLastErrorMsg, _SMTPAuth)
          else
          begin
            LogTry('Rasti nustatymai:', _SMTPAuth);
            if not cbCheckAll.Checked then
              Exit;
          end;
        except
          on E: Exception do
            LogTry(E.Message, _SMTPAuth);
        end;
      end;
    end;
  end;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  memLog.Clear;
end;

end.
