program EmailSettingsReader;

uses
  Vcl.Forms,
  Main in 'Main.pas' {frmMain},
  Email.SMTPEmail in 'Email.SMTPEmail.pas',
  Email.EmailIntf in 'Email.EmailIntf.pas',
  SMTPAuth in 'SMTPAuth.pas',
  SMTPType in 'SMTPType.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
