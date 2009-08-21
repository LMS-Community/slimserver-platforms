[Files]
; a dll to verify if a process is still running
; http://www.vincenzo.net/isxkb/index.php?title=PSVince
Source: psvince.dll; Flags: dontcopy ignoreversion

Source: "ApplicationData.xml"; Flags: dontcopy
Source: "sockettest.dll"; Flags: dontcopy ignoreversion

[CustomMessages]
#include "strings.iss"

[Code]
#include "ServiceManager.iss"

function IsPortOpen(IPAddress, Port: PAnsiChar): Boolean;
external 'IsPortOpen@files:sockettest.dll stdcall delayload';

function ProbePort(Port: PAnsiChar): Boolean;
external 'ProbePort@files:sockettest.dll stdcall delayload';

function GetLocalIP: PAnsiChar;
external 'GetLocalIP@files:sockettest.dll stdcall delayload';

function Ping(Host: PAnsiChar): Integer;
external 'Ping@files:sockettest.dll stdcall delayload';

function IsModuleLoaded(modulename: String): Boolean;
external 'IsModuleLoaded@files:psvince.dll stdcall';

const
  XMLFileName = 'ApplicationData.xml';

function GetConflictingApp(AppType: String): String;
var
  XMLDoc, NewNode, RootNode: Variant;
  XMLFile, s: String;
  i, x: Integer;

begin
  // Load the application data
  XMLDoc := CreateOleObject('MSXML2.DOMDocument');
  XMLDoc.async := False;
  XMLDoc.resolveExternals := False;

  XMLFile := ExpandConstant('{tmp}\') + XMLFileName;
  ExtractTemporaryFile(XMLFileName);
  XMLDoc.load(XMLFile);

  if XMLDoc.parseError.errorCode <> 0 then
    RaiseException('Error on line ' + IntToStr(XMLDoc.parseError.line) + ', position ' + IntToStr(XMLDoc.parseError.linepos) + ': ' + XMLDoc.parseError.reason)

  else
    begin
      RootNode := XMLDoc.getElementsByTagName('d:process');

      // Loop through the list of known firewall service IDs
      for i := 0 to RootNode.length - 1 do
      begin
        NewNode := RootNode.item(i);

        if NewNode.getAttribute('type') = AppType then
        begin
          s := NewNode.getAttribute('ServiceName');
          if IsModuleLoaded(s + '.exe') or IsModuleLoaded(s) or IsServiceRunning(s) then
          begin
            s := CustomMessage('AppConflict_Description') + #13#10 + #13#10 + NewNode.getAttribute('ProgramName');
            if NewNode.getAttribute('Help') > '' then
              s := s + ': ' + ExpandConstant('{cm:' + String(NewNode.getAttribute('Help')) + '}');
              
            Result := s;
          end
        end;
      end;
    end;
end;

function CheckPort9000: Integer;
begin
  if (IsServiceRunning('squeezesvc') or IsServiceRunning('slimsvc') or IsModuleLoaded('SqueezeSvr.exe')
    or IsModuleLoaded('squeez~1.exe') or IsModuleLoaded('squeezecenter.exe') or IsModuleLoaded('slimserver.exe')) then

    if IsPortOpen(GetLocalIP, '9000') then
      Result := 1           // SC running and available
    else
      Result := 101         // SC running, but port blocked
  else
    if IsPortOpen('127.0.0.1', '9000') then
      Result := 102         // Port used by other application
    else
      Result := 0           // Port unused
end;

function GetPort9000ResultString(ErrCode: Integer): String;
var
  r, s: String;
begin
  case ErrCode of
    1:
      r := CustomMessage('Port9000ok');

    101:
      begin
        r := CustomMessage('Port9000blocked')

        s := GetConflictingApp('Firewall');
        if s > '' then
          r := r + ': ' + s;
      end;

    102:
      begin
        r := CustomMessage('Port9000busyOther');

        s := GetConflictingApp('PortConflict');
        if s > '' then
          r := r + ': ' + s;
      end;

    0:
      r := CustomMessage('Port9000unused');
  end;

  Result := r;
end;
