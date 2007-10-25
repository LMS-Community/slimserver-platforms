;
; InnoSetup Script for SqueezeCenter
;
; Slim Devices/Logitech : http://www.slimdevices.com
;
; Script by Chris Eastwood, January 2003 - http://www.vbcodelibrary.co.uk

[Languages]
Name: nl; MessagesFile: "Dutch.isl"
Name: en; MessagesFile: "English.isl"
Name: fr; MessagesFile: "French.isl"
Name: de; MessagesFile: "German.isl"
Name: he; MessagesFile: "Hebrew.isl"
Name: it; MessagesFile: "Italian.isl"
Name: es; MessagesFile: "Spanish.isl"

[CustomMessages]
#include "strings.iss"

[Setup]
AppName=SqueezeCenter
AppVerName=SqueezeCenter 7.0a1
AppPublisher=Logitech
AppPublisherURL=http://www.slimdevices.com
AppSupportURL=http://www.slimdevices.com
AppUpdatesURL=http://www.slimdevices.com
DefaultDirName={code:GetInstallFolder}
DefaultGroupName=SqueezeCenter
WizardImageFile=squeezebox.bmp
WizardImageBackColor=$ffffff
WizardSmallImageFile=logitech.bmp
OutputBaseFilename=SqueezeSetup
MinVersion=0,4

[Tasks]
Name: desktopicon; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: quicklaunchicon; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: SqueezeTray.exe; DestDir: {app}; Flags: replacesameversion
Source: Release Notes.html; DestDir: {app}

Source: Getting Started.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: en; Flags: isreadme
Source: Getting Started.de.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: de; Flags: isreadme
Source: Getting Started.nl.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: nl; Flags: isreadme
Source: Getting Started.fr.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: fr; Flags: isreadme
Source: Getting Started.it.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: it; Flags: isreadme
Source: Getting Started.es.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: es; Flags: isreadme
Source: Getting Started.he.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: he; Flags: isreadme

; add the english version for all languages as long as we don't have any translation
Source: License.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: de en es fr he it nl
;Source: License.de.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: de
;Source: License.nl.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: nl
;Source: License.fr.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: fr
;Source: License.it.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: it
;Source: License.es.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: es
;Source: License.he.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: he

; Next line takes everything from the source '\server' directory and copies it into the setup
; it's output into the same location from the users choice.
Source: server\*.*; DestDir: {app}\server; Excludes: "*freebsd*,*openbsd*,*darwin*,*linux*,*solaris*,*cygwin*"; Flags: comparetimestamp recursesubdirs

[Dirs]
Name: {%ALLUSERSPROFILE}\SqueezeCenter; Permissions: users-modify; MinVersion: 0,6.0
Name: {app}\server\Plugins; Permissions: users-modify

[INI]
Filename: {app}\{cm:SlimDevicesWebSite}.url; Section: InternetShortcut; Key: URL; String: http://www.slimdevices.com; Flags: uninsdeletesection
Filename: {app}\{cm:SqueezeCenterWebInterface}.url; Section: InternetShortcut; Key: URL; String: http://localhost:9000; Flags: uninsdeletesection

[Icons]
Name: {group}\SqueezeCenter; Filename: {app}\SqueezeTray.exe; Parameters: "--start"; WorkingDir: "{app}";
Name: {group}\{cm:SlimDevicesWebSite}; Filename: {app}\{cm:SlimDevicesWebSite}.url
Name: {group}\{cm:License}; Filename: {app}\{cm:License}.txt
Name: {group}\{cm:GettingStarted}; Filename: {app}\{cm:GettingStarted}.html
Name: {group}\{cm:UninstallSqueezeCenter}; Filename: {uninstallexe}
Name: {userdesktop}\SqueezeCenter; Filename: {app}\SqueezeTray.exe; Parameters: "--start"; WorkingDir: "{app}"; Tasks: desktopicon
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\SqueezeCenter; Filename: {app}\SqueezeTray.exe; Parameters: "--start"; WorkingDir: "{app}"; Tasks: quicklaunchicon
Name: {commonstartup}\{cm:SqueezeCenterTrayTool}; Filename: {app}\SqueezeTray.exe; WorkingDir: "{app}"

[Registry]
;
; The following keys open required SqueezeCenter ports in the XP Firewall
;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9000:TCP"; ValueData: "9000:TCP:*:Enabled:SqueezeCenter 9000 tcp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:UDP"; ValueData: "3483:UDP:*:Enabled:SqueezeCenter 3483 udp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:TCP"; ValueData: "3483:TCP:*:Enabled:SqueezeCenter 3483 tcp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SOFTWARE\Logitech\SqueezeCenter; ValueType: string; ValueName: Path; ValueData: {app}; MinVersion: 0,5.01

[UninstallDelete]
Type: dirifempty; Name: {app}
Type: dirifempty; Name: {app}\server
Type: dirifempty; Name: {app}\server\IR
Type: dirifempty; Name: {app}\server\Plugins
Type: dirifempty; Name: {app}\server\HTML
Type: dirifempty; Name: {app}\server\SQL
Type: filesandordirs; Name: {app}\server\Cache
Type: filesandordirs; Name: {%ALLUSERSPROFILE}\SqueezeCenter; MinVersion: 0,6.0
Type: files; Name: {app}\server\slimserver.pref
Type: files; Name: {app}\{cm:SlimDevicesWebSite}.url
Type: files; Name: {app}\{cm:SqueezeCenterWebInterface}.url
Type: files; Name: {commonstartup}\{cm:SqueezeCenterTrayTool}.url

[UninstallRun]
Filename: "sc"; Parameters: "stop squeezesvc"; Flags: runhidden; MinVersion: 0,4.00.1381
Filename: "sc"; Parameters: "delete squeezesvc"; Flags: runhidden; MinVersion: 0,4.00.1381
Filename: "sc"; Parameters: "stop SqueezeMySQL"; Flags: runhidden; MinVersion: 0,4.00.1381
Filename: "sc"; Parameters: "delete SqueezeMySQL"; Flags: runhidden; MinVersion: 0,4.00.1381
Filename: {app}\server\squeezecenter.exe; Parameters: -remove; WorkingDir: {app}\server; Flags: skipifdoesntexist runhidden; MinVersion: 0,4.00.1381
Filename: {app}\SqueezeTray.exe; Parameters: --exit --uninstall; WorkingDir: {app}; Flags: skipifdoesntexist runhidden; MinVersion: 0,4.00.1381

[Code]
var
	ProgressPage: TOutputProgressWizardPage;
	StartupMode: String;

// Service management routines from http://www.vincenzo.net/isxkb/index.php?title=Service
type
	SERVICE_STATUS = record
		dwServiceType			: cardinal;
		dwCurrentState			: cardinal;
		dwControlsAccepted		: cardinal;
		dwWin32ExitCode			: cardinal;
		dwServiceSpecificExitCode	: cardinal;
		dwCheckPoint			: cardinal;
		dwWaitHint				: cardinal;
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
	SERVICE_DISABLED		= $4;
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

function OpenSCManager(lpMachineName, lpDatabaseName: string; dwDesiredAccess :cardinal): HANDLE;
external 'OpenSCManagerA@advapi32.dll stdcall';

function OpenService(hSCManager :HANDLE;lpServiceName: string; dwDesiredAccess :cardinal): HANDLE;
external 'OpenServiceA@advapi32.dll stdcall';

function CloseServiceHandle(hSCObject :HANDLE): boolean;
external 'CloseServiceHandle@advapi32.dll stdcall';

function StartNTService(hService :HANDLE;dwNumServiceArgs : cardinal;lpServiceArgVectors : cardinal) : boolean;
external 'StartServiceA@advapi32.dll stdcall';

function DeleteService(hService :HANDLE): boolean;
external 'DeleteService@advapi32.dll stdcall';


function OpenServiceManager() : HANDLE;
begin
	if UsingWinNT() = true then begin
		Result := OpenSCManager('', 'ServicesActive', SC_MANAGER_ALL_ACCESS);
		if Result = 0 then
			MsgBox('the servicemanager is not available', mbError, MB_OK)
	end
end;

function IsServiceInstalled(ServiceName: string) : boolean;
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

function RemoveService(ServiceName: string) : boolean;
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

function StartService(ServiceName: string) : boolean;
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

// end of service management...


function GetInstallFolder(Param: String) : String;
var
	InstallFolder: String;
begin
	if (not RegQueryStringValue(HKLM, 'Software\Logitech\SqueezeCenter', 'Path', InstallFolder)) then
		InstallFolder := AddBackslash(ExpandConstant('{pf}')) + 'SqueezeCenter';

	Result := InstallFolder;
end;

// NB don't call this until after {app} is set
function GetWritablePath() : String;
begin
	if (GetWindowsVersion shr 24 >= 6) then
		Result := AddBackslash(ExpandConstant('{%ALLUSERSPROFILE}')) + 'SqueezeCenter'
	else
		Result := AddBackslash(ExpandConstant('{app}')) + 'server'
end;	

function GetPrefsFolder() : String;
begin
	Result := AddBackslash(GetWritablePath()) + 'prefs'
end;	

function GetPrefsFile() : String;
begin
	Result := AddBackslash(GetPrefsFolder()) + 'server.prefs';
end;	


procedure UninstallSliMP3();
var
	ErrorCode: Integer;
	Uninstaller: String;
begin
	// Queries the specified REG_SZ or REG_EXPAND_SZ registry key/value, and returns the value in ResultStr.
	// Returns True if successful. When False is returned, ResultStr is unmodified.
	if  RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SLIMP3 Server_is1','UninstallString', Uninstaller) then
		begin
			if not Exec(RemoveQuotes(Uninstaller), '/SILENT','', SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode) then
				MsgBox(CustomMessage('ProblemUninstallingSLIMP3') + SysErrorMessage(ErrorCode), mbError, MB_OK);
		end;
end;


procedure RemoveServices(Version: String);
var
	ErrorCode: Integer;
	RegKey: String;
	InstallFolder: String;
	InstallDefault: String;
	Svc: String;
	MySQLSvc: String;
	TrayExe: String;
	Wait: Integer;
	MaxProgress: Integer;

begin
	// remove SlimTray if it's still running
	if (UpperCase(Version) = 'SC') then
		begin
			RegKey := 'Software\Logitech\SqueezeCenter';
			InstallDefault := ExpandConstant('{app}');
			Svc := 'squeezesvc';
			MySQLSvc := 'SqueezeMySQL';
			TrayExe := 'SqueezeTray.exe';
		end
	else
		begin
			RegKey := 'Software\SlimDevices\SlimServer';
			InstallDefault := AddBackslash(ExpandConstant('{pf}')) + 'SlimServer';
			Svc := 'slimsvc';
			MySQLSvc := 'SlimServerMySQL';
			TrayExe := 'SlimTray.exe';
		end;

	ProgressPage.show();
	ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

	// stop and remove our services
	RemoveService(Svc);
	RemoveService(MySQLSvc);

	ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

	if ((RegQueryStringValue(HKLM, RegKey, 'Path', InstallFolder) and DirExists(AddBackslash(InstallFolder)))) then
		InstallFolder := AddBackslash(InstallFolder)
	else
		InstallFolder := InstallDefault;

	if (FileExists(AddBackslash(InstallFolder) + TrayExe)) then
		Exec(AddBackslash(InstallFolder) + TrayExe, '--exit --uninstall', InstallFolder, SW_HIDE, ewWaitUntilTerminated, ErrorCode)

	ProgressPage.setText(CustomMessage('WaitingForServices'), '');

	// wait up to 60 seconds for the services to be deleted
	Wait := 60;
	MaxProgress := ProgressPage.ProgressBar.Position + Wait;
	while (Wait > 0) and (IsServiceInstalled(Svc) or IsServiceInstalled(MySQLSvc)) do
	begin
		ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
		Sleep(1000);
		Wait := Wait - 1;
	end;	
	ProgressPage.setProgress(MaxProgress, ProgressPage.ProgressBar.Max);
end;


procedure UninstallSlimServer();
var
	ErrorCode: Integer;
	PrefsFile: String;
	PrefsPath: String;
	OldPrefsPath: String;
	Uninstaller: String;
	UninstallPath: String;
 
begin
	// if we don't have a SlimCenter prefs file yet, migrate preference file before uninstalling SlimServer
	if not FileExists(GetPrefsFile()) then
		begin
			PrefsPath := GetPrefsFolder();
			if (not DirExists(PrefsPath)) then
				ForceDirectories(PrefsPath);

			PrefsFile := AddBackslash(PrefsPath) + '..\slimserver.pref';

			if ((RegQueryStringValue(HKLM, 'Software\SlimDevices\SlimServer', 'Path', OldPrefsPath) and DirExists(AddBackslash(OldPrefsPath) + 'server'))) then
				OldPrefsPath := AddBackslash(OldPrefsPath) + 'server'
			else
				OldPrefsPath := AddBackslash(ExpandConstant('{%ALLUSERSPROFILE}')) + 'SlimServer';

			// try to migrate existing SlimServer prefs file	
			if (FileExists(AddBackslash(OldPrefsPath) + 'slimserver.pref')) then
				FileCopy(AddBackslash(OldPrefspath) + 'slimserver.pref', PrefsFile, true)
			else
				if (DirExists(AddBackslash(OldPrefsPath) + 'prefs')) then
					FileCopy(AddBackslash(OldPrefspath) + 'prefs', PrefsPath, true);
		end;

	// call the SlimServer uninstaller
	if (RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimServer_is1', 'QuietUninstallString', Uninstaller)
		and RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimServer_is1', 'InstallLocation', UninstallPath)) then
		begin
			if not Exec(RemoveQuotes(Uninstaller), '', UninstallPath, SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode) then
				MsgBox(CustomMessage('ProblemUninstallingSlimServer') + SysErrorMessage(ErrorCode), mbError, MB_OK);
		end;

	// some manual cleanup work, in case previous uninstall didn't succeed
	RemoveServices('SS');
	DeleteFile(AddBackslash(ExpandConstant('{group}')) + 'Slim Devices website.lnk');
	DeleteFile(AddBackslash(ExpandConstant('{group}')) + 'Slim Web Interface.lnk');
	DelTree(AddBackslash(ExpandConstant('{group}')) + 'SlimServer', true, true, true);
	RegDeleteKeyIncludingSubkeys(HKLM, 'SOFTWARE\SlimDevices');
end;

procedure RemoveLegacyFiles();
var
	ServerDir: String;
	DelDir: String;

begin
	ServerDir := AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');

	DelTree(ServerDir + AddBackslash('CPAN') + AddBackslash('arch'), true, true, true);

	DelDir := ServerDir + AddBackslash('HTML');
	DelTree(DelDir + AddBackslash('Bagpuss'), true, true, true);
	DelTree(DelDir + AddBackslash('Classic'), true, true, true);
	DelTree(DelDir + AddBackslash('Dark'), true, true, true);
	DelTree(DelDir + AddBackslash('Default'), true, true, true);
	DelTree(DelDir + AddBackslash('EN'), true, true, true);
	DelTree(DelDir + AddBackslash('ExBrowse'), true, true, true);
	DelTree(DelDir + AddBackslash('ExBrowse3'), true, true, true);
	DelTree(DelDir + AddBackslash('Experimental'), true, true, true);
	DelTree(DelDir + AddBackslash('Fishbone'), true, true, true);
	DelTree(DelDir + AddBackslash('Gordon'), true, true, true);
	DelTree(DelDir + AddBackslash('Handheld'), true, true, true);
	DelTree(DelDir + AddBackslash('Moser'), true, true, true);
	DelTree(DelDir + AddBackslash('Olson'), true, true, true);
	DelTree(DelDir + AddBackslash('Purple'), true, true, true);
	DelTree(DelDir + AddBackslash('Nokia770'), true, true, true);
	DelTree(DelDir + AddBackslash('NBMU'), true, true, true);
	DelTree(DelDir + AddBackslash('Ruttenberg'), true, true, true);
	DelTree(DelDir + AddBackslash('SenseMaker'), true, true, true);
	DelTree(DelDir + AddBackslash('Touch'), true, true, true);
	DelTree(DelDir + AddBackslash('WebPad'), true, true, true);
	DelTree(DelDir + AddBackslash('xml'), true, true, true);
	DelTree(DelDir + AddBackslash('xmlTelCanto'), true, true, true);

	DelDir := ServerDir + AddBackslash('Plugins');

	// Remove old Favorites plugin - now standard
	DelTree(DelDir + AddBackslash('Favorites'), true, true, true);

	// Remove defunct radio plugins (now replaced by new
	// in their own directories)
	DeleteFile(DelDir + 'RadioIO.pm');
	DeleteFile(DelDir + 'Picks.pm');
	DeleteFile(DelDir + 'ShoutcastBrowser.pm');
	DeleteFile(DelDir + 'Live365.pm');
	DeleteFile(DelDir + 'iTunes.pm');

	// Remove 6.5.x style plugins when updating
	DeleteFile(DelDir + 'CLI.pm');
	DeleteFile(DelDir + 'Rescan.pm');
	DeleteFile(DelDir + 'RPC.pm');
	DeleteFile(DelDir + 'RssNews.pm');
	DeleteFile(DelDir + 'SavePlaylist.pm');
	DeleteFile(DelDir + 'SlimTris.pm');
	DeleteFile(DelDir + 'Snow.pm');
	DeleteFile(DelDir + 'Visualizer.pm');
	DeleteFile(DelDir + 'xPL.pm');
	DelTree(DelDir + AddBackslash('DateTime'), true, true, true);
	DelTree(DelDir + AddBackslash('DigitalInput'), true, true, true);
	DelTree(DelDir + AddBackslash('Health'), true, true, true);
	DelTree(DelDir + AddBackslash('iTunes'), true, true, true);
	DelTree(DelDir + AddBackslash('Live365'), true, true, true);
	DelTree(DelDir + AddBackslash('LMA'), true, true, true);
	DelTree(DelDir + AddBackslash('MoodLogic'), true, true, true);
	DelTree(DelDir + AddBackslash('MusicMagic'), true, true, true);
	DelTree(DelDir + AddBackslash('Picks'), true, true, true);
	DelTree(DelDir + AddBackslash('Podcast'), true, true, true);
	DelTree(DelDir + AddBackslash('PreventStandby'), true, true, true);
	DelTree(DelDir + AddBackslash('RadioIO'), true, true, true);
	DelTree(DelDir + AddBackslash('RadioTime'), true, true, true);
	DelTree(DelDir + AddBackslash('RandomPlay'), true, true, true);
	DelTree(DelDir + AddBackslash('Rhapsody'), true, true, true);
	DelTree(DelDir + AddBackslash('RS232'), true, true, true);
	DelTree(DelDir + AddBackslash('ShoutcastBrowser'), true, true, true);
	DelTree(DelDir + AddBackslash('TT'), true, true, true);
end;

const
	SSRegkey = 'Software\SlimDevices\SlimServer';
	SCRegkey = 'Software\Logitech\SqueezeCenter';

procedure GetStartupMode();
var
	StartAtBoot: String;

begin
	// 'auto'   - service to be started automatically
	// 'demand' - to be started on demand (application mode)
	StartupMode := 'auto';

	if RegQueryStringValue(HKCU, SSRegkey, 'StartAtBoot', StartAtBoot) then
		begin
			if (StartAtBoot = '0') then
				StartupMode := 'demand';
		end;

	if RegQueryStringValue(HKCU, SCRegkey, 'StartAtBoot', StartAtBoot) then
		begin
			if (StartAtBoot = '0') then
				StartupMode := 'demand';
		end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
	ErrorCode: Integer;
	NewServerDir: String;
	PrefsFile: String;
	PrefsPath: String;
	PrefString: String;

begin
	if CurStep = ssInstall then
		begin
			// try to remember whether SS/SC was running as a service before we're uninstalling
			GetStartupMode();

			// add custom progress bar to be displayed while unregistering services
			ProgressPage := CreateOutputProgressPage(CustomMessage('UnregisterServices'), CustomMessage('UnregisterServicesDesc'));

			try
				ProgressPage.setProgress(0, 160);
				UninstallSliMP3();

				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				UninstallSlimServer();
				RemoveServices('SC');

				RemoveLegacyFiles();

				// Remove other defunct pieces
				DeleteFile(AddBackslash(ExpandConstant('{app}')) + 'psapi.dll');
				DeleteFile(AddBackslash(ExpandConstant('{app}')) + 'SlimServer.exe');

			finally
				ProgressPage.Hide;
			end;
		end;

	if CurStep = ssPostInstall then 
		begin

			ProgressPage := CreateOutputProgressPage(CustomMessage('RegisterServices'), CustomMessage('RegisterServicesDesc'));

			try
				ProgressPage.Show;
				ProgressPage.setProgress(0, 2);

				// Add firewall rules for Vista
				if (GetWindowsVersion shr 24 >= 6) then
					Exec('netsh', 'advfirewall firewall add rule name="SqueezeCenter" description="Allow SqueezeCenter to accept inbound connections." dir=in action=allow program="' + ExpandConstant('{app}') + '\server\squeezecenter.exe' + '"', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
	
				PrefsFile := GetPrefsFile();
	
				if (not DirExists(PrefsPath)) then
					ForceDirectories(PrefsPath);
		
				if not FileExists(PrefsFile) then
					begin
						PrefString := '---' + #13#10 + 'cachedir: ' + AddBackslash(GetWritablePath()) + 'Cache' + #13#10 + 'language: ' + AnsiUppercase(ExpandConstant('{language}')) + #13#10;
						SaveStringToFile(PrefsFile, PrefString, False);
					end;

				NewServerDir := AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');
	
				ProgressPage.setText(CustomMessage('RegisteringServices'), 'SqueezeCenter');
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);

				Exec(NewServerDir + 'squeezecenter.exe', '-install ' + StartupMode, NewServerDir, SW_HIDE, ewWaitUntilTerminated, ErrorCode);

				if StartupMode = 'auto' then
					StartService('squeezesvc');

				ProgressPage.setText(CustomMessage('RegisteringServices'), 'SqueezeTray');
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);

				Exec(ExpandConstant('{app}') + '\SqueezeTray.exe', '--install', ExpandConstant('{app}'), SW_SHOW, ewWaitUntilIdle, ErrorCode);
			finally
				ProgressPage.Hide;
			end;
		end;	
end;
