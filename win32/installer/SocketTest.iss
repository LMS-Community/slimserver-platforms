[Setup]
AppName=My Program
AppVerName=My Program version 1.5
DefaultDirName={pf}\My Program
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\MyProg.exe

[Files]
Source: "sockettest.dll"; Flags: dontcopy
Source: "FirewallData.xml"; Flags: dontcopy

[Code]
function IsPortOpen(IPAddress, Port: PChar): Boolean;
external 'IsPortOpen@files:sockettest.dll stdcall delayload';

function GetLocalIP: PChar;
external 'GetLocalIP@files:sockettest.dll stdcall delayload';

const
  XMLFileName = 'FirewallData.xml';

function NextButtonClick(CurPage: Integer): Boolean;
var
  ja: String;
  XMLHTTP, XMLDoc, NewNode, RootNode: Variant;

begin
  if CurPage =  wpWelcome then begin

  ja := 'nein';
//  if IsPortOpen('192.168.0.80', '9000') then
   ja := 'ja!!!';

//  ja := GetLocalIP;

  { Load the XML File }

  XMLDoc := CreateOleObject('MSXML2.DOMDocument');
  XMLDoc.async := False;
  XMLDoc.resolveExternals := False;
  XMLDoc.load(ExpandConstant('{tmp}\') + XMLFileName);
  if XMLDoc.parseError.errorCode <> 0 then
    RaiseException('Error on line ' + IntToStr(XMLDoc.parseError.line) + ', position ' + IntToStr(XMLDoc.parseError.linepos) + ': ' + XMLDoc.parseError.reason + '; ' + ExpandConstant('{tmp}\') + XMLFileName);

  MsgBox('Loaded the XML file.', mbInformation, mb_Ok);
  end;
  Result := True;
end;

