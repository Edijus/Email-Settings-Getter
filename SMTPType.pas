unit SMTPType;

interface

uses
  {Delphi}
  {Project}
  SMTPAuth
  ;

type
  TSMTPRec = record
    Host: string;
    Port: integer;
    Username: string;
    Password: string;
    Auth: TSMTPAuth;
    EmailFrom: string;
  end;

implementation

end.
