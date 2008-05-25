[Files]
Source: "sockettest.dll"; Flags: dontcopy

[Code]
function IsPortOpen(IPAddress, Port: PChar): Boolean;
external 'IsPortOpen@files:sockettest.dll stdcall delayload';

function ProbePort(Port: PChar): Boolean;
external 'ProbePort@files:sockettest.dll stdcall delayload';

function GetLocalIP: PChar;
external 'GetLocalIP@files:sockettest.dll stdcall delayload';

