library SocketTest;

uses
        classes, blcksock, socketlistener, pingsend, sysutils;


function IsPortOpen(Address, Port: PChar): Boolean; stdcall;
var
        sock: TTCPBlockSocket;

begin
        sock := TTCPBlockSocket.Create;
        sock.Connect(Address, Port);
        IsPortOpen := ((sock.LastError = 0) and sock.CanWrite(5));
        sock.CloseSocket;
end;


procedure GetLocalIPs(var IPList: TStringList);
var
        sock: TTCPBlockSocket;

begin
        sock := TTCPBlockSocket.Create;
        sock.ResolveNameToIP(sock.LocalName, IPList);
        sock.CloseSocket;
end;


function GetLocalIP : AnsiString; stdcall;
var
        IPList : TStringList;
        a, IP: AnsiString;

begin
        IPLIst := TStringList.Create;
        GetLocalIPs(IPList);

        if IPList.Count > 0 then
        begin
                IPList.GetNameValue(0, a, IP);
                GetLocalIP := IP;
        end;
end;


function ProbePort(Port: PChar): Boolean; stdcall;
var
        socket: TTCPTestDaemon;
begin
        socket := TTCPTestDaemon.Create(Port);
        ProbePort := IsPortOpen(PChar(GetLocalIP), Port);
        socket.Terminate;
end;

function Ping(Host: PChar): LongInt; stdcall;
var
        myPing: TPingSend;
        t: Integer;
begin
        myPing := TPingSend.Create;
        t := -1;
        myPing.ping(Host);
        t := myPing.pingtime;
        myPing.Free;
        Ping := t;
end;


exports
        IsPortOpen, GetLocalIP, ProbePort, Ping;

end.

