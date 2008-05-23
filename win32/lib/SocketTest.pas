library SocketTest;

uses
        classes, blcksock;


function IsPortOpen(Address, Port: PChar): Boolean; stdcall;
var
        sock: TTCPBlockSocket;

begin
        sock := TTCPBlockSocket.Create;
        sock.Connect(Address, Port);
        IsPortOpen := (sock.LastError = 0);
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


function GetLocalIP : PChar; stdcall;
var
        IPList : TStringList;
        a, IP : AnsiString;

begin
        IPLIst := TStringList.Create;
        GetLocalIPs(IPList);

        if IPList.Count > 0 then
        begin
                IPList.GetNameValue(0, a, IP);
                GetLocalIP := IP;
        end;
end;


exports
        IsPortOpen, GetLocalIP;

end.

