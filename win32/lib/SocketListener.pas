unit SocketListener;

{$Mode Delphi}

interface

uses
  Classes, blcksock, synsock;

type
  TTCPTestDaemon = Class(TThread)
  private
    Sock:TTCPBlockSocket;
    Port:String;
  public
    Constructor Create(UsePort:String);
    Destructor Destroy; override;
    procedure Execute; override;
    function lastError: Integer;
  end;

  TTCPTestThrd = class(TThread)
  private
    Sock:TTCPBlockSocket;
    CSock: TSocket;
  public
    Constructor Create (hsock:tSocket);
    procedure Execute; override;
  end;

implementation

{ TTestDaemon }

Constructor TTCPTestDaemon.Create(UsePort:String);
begin
  inherited create(false);
  sock:=TTCPBlockSocket.create;
  Port:=UsePort;
  FreeOnTerminate:=true;
end;

function TTCPTestDaemon.lastError: Integer;
begin
  lastError := sock.lastError;
end;

Destructor TTCPTestDaemon.Destroy;
begin
  Sock.free;
end;

procedure TTCPTestDaemon.Execute;
var
  ClientSock:TSocket;
begin
  with sock do
    begin
      CreateSocket;
      setLinger(true,10);
      bind('0.0.0.0',Port);
      listen;
      repeat
        if terminated then break;
        if canread(1000) then
          begin
            ClientSock:=accept;
            if lastError=0 then TTCPTestThrd.create(ClientSock);
          end;
      until false;
  end;
end;

{ TTestThrd }

Constructor TTCPTestThrd.Create(Hsock:TSocket);
begin
  inherited create(false);
  Csock := Hsock;
  FreeOnTerminate:=true;
end;

procedure TTCPTestThrd.Execute;
var
  s: string;
begin
  sock:=TTCPBlockSocket.create;
  try
    Sock.socket:=CSock;
    sock.GetSins;
    with sock do
      begin
        repeat
          if terminated then break;
          s := RecvPacket(60000);
          if lastError<>0 then break;
        until false;
      end;
  finally
    Sock.Free;
  end;
end;

end.
