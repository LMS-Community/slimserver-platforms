unit SocketListener;

{$Mode Delphi}

interface

uses
  Classes, blcksock, synsock;

type
  TTCPTestDaemon = Class(TThread)
  private
    Sock: TTCPBlockSocket;
    Port: PChar;

  public
    Constructor Create(UsePort: PChar);

    Destructor Destroy; override;
    procedure Execute; override;
    function lastError: Integer;
  end;

  TTCPTestThrd = Class(TThread)
  private
    Sock: TTCPBlockSocket;
    CSock: TSocket;
  public
    Constructor Create (hsock: tSocket);
    procedure Execute; override;
  end;

implementation

{ TTestDaemon }

Constructor TTCPTestDaemon.Create(UsePort: PChar);

begin
  inherited Create(false);
  Sock := TTCPBlockSocket.Create;
  Port := UsePort;
  FreeOnTerminate := true;
end;

function TTCPTestDaemon.lastError: Integer;
begin
  lastError := Sock.lastError;
end;

Destructor TTCPTestDaemon.Destroy;
begin
  Sock.Destroy;
end;

procedure TTCPTestDaemon.Execute;
var
  ClientSock: TSocket;
begin
  with Sock do
    begin
      CreateSocket;
      setLinger(true, 10);
      bind('0.0.0.0', Port);
      listen;
      repeat
        if terminated then break;
        if canread(1000) then
          begin
            ClientSock := accept;
            if lastError=0 then TTCPTestThrd.create(ClientSock);
          end;
      until false;
  end;
end;

{ TTestThrd }

Constructor TTCPTestThrd.Create(Hsock: TSocket);
begin
  inherited Create(false);
  Csock := Hsock;
  FreeOnTerminate := true;
end;

procedure TTCPTestThrd.Execute;
begin
  Sock := TTCPBlockSocket.create;
  try
    Sock.socket:=CSock;
    Sock.GetSins;
    with Sock do
      begin
        repeat
          if terminated then break;
          RecvPacket(60000);
          if lastError <> 0 then break;

        until false;
      end;
  finally
    Sock.Free;
  end;
end;

end.
