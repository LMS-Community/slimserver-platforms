[Files]
Source: "sockettest.dll"; Flags: dontcopy

[CustomMessages]
Port9000ok=SqueezeCenter is running and accessible
Port9000blocked=SqueezeCenter is running but can''t be connected to on port 9000
Port9000busyOther=SqueezeCenter seems not to be running, but port 9000 is busy
Port9000unused=Port 9000 seems to be unused

[Code]
function IsPortOpen(IPAddress, Port: PChar): Boolean;
external 'IsPortOpen@files:sockettest.dll stdcall delayload';

function ProbePort(Port: PChar): Boolean;
external 'ProbePort@files:sockettest.dll stdcall delayload';

function GetLocalIP: PChar;
external 'GetLocalIP@files:sockettest.dll stdcall delayload';

function Ping(Host: PChar): Integer;
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
            Result := NewNode.getAttribute('ProgramName');
        end;
      end;
    end;
end;

function CheckPort9000: Integer;
begin
  if (IsServiceRunning('squeezesvc') or IsServiceRunning('slimsvc')
    or IsModuleLoaded('squeez~1.exe') or IsModuleLoaded('squeezecenter.exe') or IsModuleLoaded('slimserver.exe')) then

    if IsPortOpen(GetLocalIP, '9000') then
      Result := 0
    else
      Result := 101
  else
    if IsPortOpen('127.0.0.1', '9000') then
      Result := 102
    else
      Result := 3
end;

function GetPort9000ResultString(ErrCode: Integer): String;
var
  r, s: String;
begin
  case ErrCode of
    0:
      r := CustomMessage('Port9000ok')

    101:
      r := CustomMessage('Port9000blocked')

    102:
      begin
      r := CustomMessage('Port9000busyOther');

        s := GetConflictingApp('PortConflict');
        if s > '' then
          r := r + ': ' + s;
      end;

    3:
      r := CustomMessage('Port9000unused');
  end;

  Result := r;
end;
