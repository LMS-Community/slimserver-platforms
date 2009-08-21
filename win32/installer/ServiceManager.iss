// Service management routines on http://www.vincenzo.net/isxkb/index.php?title=Service
type
	SERVICE_STATUS = record
    	dwServiceType				: cardinal;
    	dwCurrentState				: cardinal;
    	dwControlsAccepted			: cardinal;
    	dwWin32ExitCode				: cardinal;
    	dwServiceSpecificExitCode	: cardinal;
    	dwCheckPoint				: cardinal;
    	dwWaitHint					: cardinal;
	end;
	HANDLE = cardinal;

const
	SERVICE_QUERY_CONFIG		= $1;
	SERVICE_CHANGE_CONFIG		= $2;
	SERVICE_QUERY_STATUS		= $4;
	SERVICE_START			= $10;
	SERVICE_STOP			= $20;
	SERVICE_ALL_ACCESS		= $f01ff;
	SC_MANAGER_ALL_ACCESS		= $f003f;
	SERVICE_WIN32_OWN_PROCESS	= $10;
	SERVICE_WIN32_SHARE_PROCESS	= $20;
	SERVICE_WIN32			= $30;
	SERVICE_INTERACTIVE_PROCESS	= $100;
	SERVICE_BOOT_START		= $0;
	SERVICE_SYSTEM_START		= $1;
	SERVICE_AUTO_START		= $2;
	SERVICE_DEMAND_START		= $3;
	SERVICE_DISABLED			= $4;
	SERVICE_DELETE 			= $10000;
	SERVICE_CONTROL_STOP		= $1;
	SERVICE_CONTROL_PAUSE		= $2;
	SERVICE_CONTROL_CONTINUE	= $3;
	SERVICE_CONTROL_INTERROGATE	= $4;
	SERVICE_STOPPED			= $1;
	SERVICE_START_PENDING		= $2;
	SERVICE_STOP_PENDING		= $3;
	SERVICE_RUNNING			= $4;
	SERVICE_CONTINUE_PENDING	= $5;
	SERVICE_PAUSE_PENDING		= $6;
	SERVICE_PAUSED			= $7;

function OpenSCManager(lpMachineName, lpDatabaseName: AnsiString; dwDesiredAccess: cardinal): HANDLE;
external 'OpenSCManagerA@advapi32.dll stdcall';

function OpenService(hSCManager: HANDLE; lpServiceName: AnsiString; dwDesiredAccess: cardinal): HANDLE;
external 'OpenServiceA@advapi32.dll stdcall';

function CloseServiceHandle(hSCObject: HANDLE): boolean;
external 'CloseServiceHandle@advapi32.dll stdcall';

function StartNTService(hService: HANDLE; dwNumServiceArgs: cardinal; lpServiceArgVectors: cardinal) : boolean;
external 'StartServiceA@advapi32.dll stdcall';

function DeleteService(hService: HANDLE): boolean;
external 'DeleteService@advapi32.dll stdcall';

function ControlService(hService :HANDLE; dwControl :cardinal;var ServiceStatus :SERVICE_STATUS) : boolean;
external 'ControlService@advapi32.dll stdcall';

function QueryServiceStatus(hService :HANDLE;var ServiceStatus :SERVICE_STATUS) : boolean;
external 'QueryServiceStatus@advapi32.dll stdcall';

function OpenServiceManager() : HANDLE;
begin
	if UsingWinNT() = true then begin
		Result := OpenSCManager('', 'ServicesActive', SC_MANAGER_ALL_ACCESS);
		if Result = 0 then
			MsgBox('the servicemanager is not available', mbError, MB_OK)
	end
end;

function IsServiceInstalled(ServiceName: AnsiString) : boolean;
var
	hSCM	: HANDLE;
	hService: HANDLE;
begin
	hSCM := OpenServiceManager();
	Result := false;
	if hSCM <> 0 then begin
		hService := OpenService(hSCM, ServiceName, SERVICE_QUERY_CONFIG);
		if hService <> 0 then begin
			Result := true;
			CloseServiceHandle(hService)
		end;
		CloseServiceHandle(hSCM)
	end
end;

function IsServiceRunning(ServiceName: AnsiString) : boolean;
var
	hSCM	: HANDLE;
	hService: HANDLE;
	Status	: SERVICE_STATUS;
begin
	hSCM := OpenServiceManager();
	Result := false;
	if hSCM <> 0 then begin
		hService := OpenService(hSCM,ServiceName,SERVICE_QUERY_STATUS);
    	if hService <> 0 then begin
			if QueryServiceStatus(hService,Status) then begin
				Result :=(Status.dwCurrentState = SERVICE_RUNNING)
        	end;
            CloseServiceHandle(hService)
		    end;
        CloseServiceHandle(hSCM)
	end
end;

function RemoveService(ServiceName: AnsiString) : boolean;
var
	hSCM	: HANDLE;
	hService: HANDLE;
begin
	hSCM := OpenServiceManager();
	Result := false;
	if hSCM <> 0 then begin
		hService := OpenService(hSCM,ServiceName,SERVICE_DELETE);
		if hService <> 0 then begin
			Result := DeleteService(hService);
			CloseServiceHandle(hService)
		end;
		CloseServiceHandle(hSCM)
	end
end;

function StartService(ServiceName: AnsiString) : boolean;
var
	hSCM	: HANDLE;
	hService: HANDLE;
begin
	hSCM := OpenServiceManager();
	Result := false;
	if hSCM <> 0 then begin
		hService := OpenService(hSCM,ServiceName,SERVICE_START);
        if hService <> 0 then begin
        	Result := StartNTService(hService,0,0);
            CloseServiceHandle(hService)
		end;
        CloseServiceHandle(hSCM)
	end;
end;

function StopService(ServiceName: AnsiString) : boolean;
var
	hSCM	: HANDLE;
	hService: HANDLE;
	Status	: SERVICE_STATUS;
begin
	hSCM := OpenServiceManager();
	Result := false;
	if hSCM <> 0 then begin
		hService := OpenService(hSCM,ServiceName,SERVICE_STOP);
        if hService <> 0 then begin
        	Result := ControlService(hService,SERVICE_CONTROL_STOP,Status);
            CloseServiceHandle(hService)
		end;
        CloseServiceHandle(hSCM)
	end;
end;

function GetStartType(ServiceName: AnsiString) : AnsiString;
var
	StartType: cardinal;
begin
	Result := '';
	if RegQueryDWordValue(HKLM, 'SYSTEM\CurrentControlSet\Services\' + ServiceName, 'Start', StartType) then
		if (StartType = 2) then
			Result := 'auto'
		else
			Result := 'demand'
end;