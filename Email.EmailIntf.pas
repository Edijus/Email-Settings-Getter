unit Email.EmailIntf;

interface

uses
  {Delphi}
  System.Types
  ;

type
  IEmail = interface
    ['{D3B2C51C-8635-4797-B57A-787327B7133D}']
    function SendEmail(const AMsgBody, ASubject: string; const AReceivers: TStringDynArray;
      const AFileList: TStringDynArray = nil): Boolean;
    function GetLastErrorMsg: string;
  end;

implementation

end.
