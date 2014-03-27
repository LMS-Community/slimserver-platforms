;
; InnoSetup Script for Logitech Media Server
;
; Logitech : http://www.logitech.com
;
; Script by Chris Eastwood, January 2003 - http://www.vbcodelibrary.co.uk

#define AppName "Logitech Media Server"
#define AppVersion "7.8.1"
#define ProductURL "http://www.mysqueezebox.com/support"
#define SSRegKey = "Software\SlimDevices\SlimServer"
#define SCRegKey = "Software\Logitech\SqueezeCenter"
#define SBRegKey = "Software\Logitech\Squeezebox"

#define VCRedistKey  = "SOFTWARE\Microsoft\VisualStudio\10.0\VC\VCRedist\x86"

[Languages]
; order of languages is important when falling back when a localization is missing
Name: en; MessagesFile: "Default.isl"
Name: cz; MessagesFile: "Czech.isl"
Name: da; MessagesFile: "Danish.isl"
Name: de; MessagesFile: "German.isl"
Name: es; MessagesFile: "Spanish.isl"
Name: fi; MessagesFile: "Finnish.isl"
Name: fr; MessagesFile: "French.isl"
Name: it; MessagesFile: "Italian.isl"
Name: nl; MessagesFile: "Dutch.isl"
Name: no; MessagesFile: "Norwegian.isl"
Name: pl; MessagesFile: "Polish.isl"
Name: ru; MessagesFile: "Russian.isl"
Name: sv; MessagesFile: "Swedish.isl"

[CustomMessages]
#include "strings.iss"

[Setup]
AppName={#AppName}
AppVerName={#AppName} {#AppVersion}
AppVersion={#AppVersion}
VersionInfoProductName={#AppName} {#AppVersion}
VersionInfoProductVersion={#AppVersion}
VersionInfoVersion=0.0.0.0

AppPublisher=Logitech
AppPublisherURL={#ProductURL}
AppSupportURL={#ProductURL}
AppUpdatesURL={#ProductURL}
DefaultDirName={code:GetInstallFolder}
DefaultGroupName={#AppName}
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
WizardImageFile=squeezebox.bmp
WizardImageBackColor=$ffffff
WizardSmallImageFile=logitech.bmp
OutputBaseFilename=SqueezeSetup
DirExistsWarning=no
MinVersion=0,5.1

[Files]
Source: Release Notes.html; DestDir: {app}; Flags: ignoreversion

; a dll to verify if a process is still running
; http://www.vincenzo.net/isxkb/index.php?title=PSVince
Source: psvince.dll; Flags: dontcopy
Source: vcredist.exe; Destdir: "{tmp}"; Flags: deleteafterinstall

; add the english version for all languages as long as we don't have any translation
Source: License.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Flags: ignoreversion

; Next line takes everything from the source '\server' directory and copies it into the setup
; it's output into the same location from the users choice.
Source: server\*.*; DestDir: {app}\server; Excludes: "*freebsd*,*openbsd*,*darwin*,*linux*,*solaris*"; Flags: recursesubdirs ignoreversion
Source: SqueezeTray.exe; DestDir: {app}; Flags: ignoreversion

[Dirs]
Name: {commonappdata}\Squeezebox; Permissions: users-modify
Name: {app}\server\Plugins; Permissions: users-modify

[Icons]
Name: {group}\{#AppName}; Filename: {app}\SqueezeTray.exe; Parameters: "--start"; WorkingDir: "{app}";
Name: {group}\{cm:ControlPanel}; Filename: {app}\server\squeezeboxcp.exe; WorkingDir: "{app}\server";
Name: {group}\{cm:License}; Filename: {app}\{cm:License}.txt
Name: {group}\{cm:UninstallSqueezeCenter}; Filename: {uninstallexe}
Name: {commonstartup}\{cm:SqueezeCenterTrayTool}; Filename: {app}\SqueezeTray.exe; WorkingDir: "{app}"
Name: {userdesktop}\{#AppName}; Filename: {app}\SqueezeTray.exe; Parameters: "--start"; WorkingDir: "{app}";

[Registry]
;
; The following keys open required ports in the XP Firewall
;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "{code:GetHttpPort}:TCP"; ValueData: "{code:GetHttpPort}:TCP:*:Enabled:{#AppName} {code:GetHttpPort} tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9001:TCP"; ValueData: "9001:TCP:*:Enabled:{#AppName} 9001 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9002:TCP"; ValueData: "9002:TCP:*:Enabled:{#AppName} 9002 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9003:TCP"; ValueData: "9003:TCP:*:Enabled:{#AppName} 9003 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9004:TCP"; ValueData: "9004:TCP:*:Enabled:{#AppName} 9004 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9005:TCP"; ValueData: "9005:TCP:*:Enabled:{#AppName} 9005 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9006:TCP"; ValueData: "9006:TCP:*:Enabled:{#AppName} 9006 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9007:TCP"; ValueData: "9007:TCP:*:Enabled:{#AppName} 9007 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9008:TCP"; ValueData: "9008:TCP:*:Enabled:{#AppName} 9008 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9009:TCP"; ValueData: "9009:TCP:*:Enabled:{#AppName} 9009 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9010:TCP"; ValueData: "9010:TCP:*:Enabled:{#AppName} 9010 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9100:TCP"; ValueData: "9100:TCP:*:Enabled:{#AppName} 9100 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "8000:TCP"; ValueData: "8000:TCP:*:Enabled:{#AppName} 8000 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "10000:TCP"; ValueData: "10000:TCP:*:Enabled:{#AppName} 10000 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9090:TCP"; ValueData: "9090:TCP:*:Enabled:{#AppName} 9090 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:UDP"; ValueData: "3483:UDP:*:Enabled:{#AppName} 3483 udp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:TCP"; ValueData: "3483:TCP:*:Enabled:{#AppName} 3483 tcp"; MinVersion: 0,5.01;

Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "{code:GetHttpPort}:TCP"; ValueData: "{code:GetHttpPort}:TCP:*:Enabled:{#AppName} {code:GetHttpPort} tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9001:TCP"; ValueData: "9001:TCP:*:Enabled:{#AppName} 9001 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9002:TCP"; ValueData: "9002:TCP:*:Enabled:{#AppName} 9002 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9003:TCP"; ValueData: "9003:TCP:*:Enabled:{#AppName} 9003 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9004:TCP"; ValueData: "9004:TCP:*:Enabled:{#AppName} 9004 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9005:TCP"; ValueData: "9005:TCP:*:Enabled:{#AppName} 9005 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9006:TCP"; ValueData: "9006:TCP:*:Enabled:{#AppName} 9006 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9007:TCP"; ValueData: "9007:TCP:*:Enabled:{#AppName} 9007 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9008:TCP"; ValueData: "9008:TCP:*:Enabled:{#AppName} 9008 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9009:TCP"; ValueData: "9009:TCP:*:Enabled:{#AppName} 9009 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9010:TCP"; ValueData: "9010:TCP:*:Enabled:{#AppName} 9010 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9100:TCP"; ValueData: "9100:TCP:*:Enabled:{#AppName} 9100 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "8000:TCP"; ValueData: "8000:TCP:*:Enabled:{#AppName} 8000 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "10000:TCP"; ValueData: "10000:TCP:*:Enabled:{#AppName} 10000 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9090:TCP"; ValueData: "9090:TCP:*:Enabled:{#AppName} 9090 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:UDP"; ValueData: "3483:UDP:*:Enabled:{#AppName} 3483 udp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:TCP"; ValueData: "3483:TCP:*:Enabled:{#AppName} 3483 tcp"; MinVersion: 0,5.01;

Root: HKLM; Subkey: SOFTWARE\Logitech\Squeezebox; ValueType: string; ValueName: Path; ValueData: {app}
Root: HKLM; Subkey: SOFTWARE\Logitech\Squeezebox; ValueType: string; ValueName: DataPath; ValueData: {code:GetWritablePath}
; flag the squeezesvc.exe to be run as administrator on Vista
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers; ValueType: string; ValueName: {app}\server\squeezesvc.exe; ValueData: RUNASADMIN; Flags: uninsdeletevalue; MinVersion: 0,6.0;

[InstallDelete]
Type: filesandordirs; Name: {group}

[UninstallDelete]
Type: dirifempty; Name: {app}
Type: dirifempty; Name: {app}\server
Type: dirifempty; Name: {app}\server\IR
Type: dirifempty; Name: {app}\server\Plugins
Type: dirifempty; Name: {app}\server\HTML
Type: dirifempty; Name: {app}\server\SQL
Type: files; Name: {commonstartup}\{cm:SqueezeCenterTrayTool}.url

[Run]
Filename: {app}\server\squeezeboxcp.exe; Description: {cm:StartupControlPanel}; Flags: postinstall nowait skipifsilent
; remove potential left-overs from earlier installations
Filename: "sc"; Parameters: "stop SqueezeMySQL"; Flags: runhidden; MinVersion: 0,4.00.1381
Filename: "sc"; Parameters: "delete SqueezeMySQL"; Flags: runhidden; MinVersion: 0,4.00.1381

[UninstallRun]
Filename: "sc"; Parameters: "stop squeezesvc"; Flags: runhidden; MinVersion: 0,4.00.1381
Filename: "sc"; Parameters: "delete squeezesvc"; Flags: runhidden; MinVersion: 0,4.00.1381
Filename: {app}\server\SqueezeSvr.exe; Parameters: -remove; WorkingDir: {app}\server; Flags: skipifdoesntexist runhidden; MinVersion: 0,4.00.1381
Filename: {app}\SqueezeTray.exe; Parameters: "--exit --uninstall"; WorkingDir: {app}; Flags: skipifdoesntexist runhidden; MinVersion: 0,4.00.1381

[Code]
#include "SocketTest.iss"

var
	ProgressPage: TOutputProgressWizardPage;
	StartupMode: String;
	HttpPort: String;
	
	// custom exit codes
	// 1001 - SC configuration was found using port 9000, but port 9000 seems to be busy with an other application (PrefsExistButPortConflict)
	// 1002 - SC wasn't able to establish a connection to mysqueezebox.com on port 3483 (SNConnectFailed_Description)
	// 1101 - SliMP3 uninstall failed
	// 1102 - SlimServer uninstall failed
	// 1103 - SqueezeCenter uninstall failed
	// 1104 - Squeezebox Server uninstall failed
	// 1201 - VC Runtime Libraries can't be installed
	CustomExitCode: Integer;

function GetHttpPort(Param: String) : String;
begin
	if HttpPort = '' then
		begin
			if CheckPort9000 = 102 then
				HttpPort := '9001'
			else
				HttpPort := '9000';
		end;
		
	Result := HttpPort
end;

function GetInstallFolder(Param: String) : String;
var
	InstallFolder: String;
begin
	if (not RegQueryStringValue(HKLM, '{#SBRegKey}', 'Path', InstallFolder)) then
		InstallFolder := AddBackslash(ExpandConstant('{pf}')) + 'Squeezebox';

	Result := InstallFolder;
end;


function GetWritablePath(Param: String) : String;
var
	DataPath: String;
begin

	if (not RegQueryStringValue(HKLM, '{#SBRegKey}', 'DataPath', DataPath)) then
		begin

			if ExpandConstant('{commonappdata}') = '' then
				begin
					if GetEnv('ProgramData') = '' then
						DataPath := 'c:\ProgramData'
					else
						DataPath := GetEnv('ProgramData');
				end
			else
				DataPath := ExpandConstant('{commonappdata}');
		
			DataPath := AddBackslash(DataPath) + 'Squeezebox';
		end;

	Result := DataPath;
end;	

function GetPrefsFolder() : String;
begin
	Result := AddBackslash(GetWritablePath('')) + 'prefs'
end;	


function GetPrefsFile() : String;
begin
	Result := AddBackslash(GetPrefsFolder()) + 'server.prefs';
end;	


procedure RegisterPort(Port: String);
var
	RegKey, RegValue, ReservedPorts: String;

begin
	RegKey := 'System\CurrentControlSet\Services\Tcpip\Parameters';
	RegValue := 'ReservedPorts';

	RegQueryMultiStringValue(HKLM, RegKey, RegValue, ReservedPorts);

	if Pos(Port, ReservedPorts) = 0 then
		RegWriteMultiStringValue(HKLM, RegKey, RegValue, ReservedPorts + #0 + Port + '-' + Port);
end;

procedure UninstallSliMP3();
var
	ErrorCode: Integer;
	Uninstaller: String;
begin
	// Queries the specified REG_SZ or REG_EXPAND_SZ registry key/value, and returns the value in ResultStr.
	// Returns True if successful. When False is returned, ResultStr is unmodified.
	if RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SLIMP3 Server_is1','UninstallString', Uninstaller) then
		begin
			if not Exec(RemoveQuotes(Uninstaller), '/SILENT','', SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode) then
				begin
					SuppressibleMsgBox(CustomMessage('ProblemUninstallingSLIMP3') + SysErrorMessage(ErrorCode), mbError, MB_OK, IDOK);
					CustomExitCode := 1101;
				end
		end;
end;

procedure RemoveServices(Version: String);
var
	ErrorCode: Integer;
	RegKey: String;
	InstallFolder: String;
	InstallDefault: String;
	Svc: String;
	Executable: String;
	LongExecutable: String;
	MySQLSvc: String;
	TrayExe: String;
	Wait: Integer;
	MaxProgress: Integer;

begin
	ProgressPage.show();
	ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

	// remove SlimTray if it's still running
	if (UpperCase(Version) = 'SB') then
		begin
			RegKey := '{#SBRegKey}';
			InstallDefault := ExpandConstant('{app}');
			Svc := 'squeezesvc';
			Executable := 'squeez~3.exe';
			LongExecutable := 'SqueezeSvr.exe';
			TrayExe := 'SqueezeTray.exe';
			MySQLSvc := 'SqueezeMySQL';

			// stop services if installed
			StopService(Svc);
		end
	else if (UpperCase(Version) = 'SC') then
		begin
			RegKey := '{#SCRegKey}';
			InstallDefault := ExpandConstant('{app}');
			Svc := 'squeezesvc';
			Executable := 'squeez~1.exe';
			LongExecutable := 'squeezecenter.exe';
			MySQLSvc := 'SqueezeMySQL';
			TrayExe := 'SqueezeTray.exe';

			// stop SqueezeCenter services if installed
			StopService(Svc);
		end
	else
		begin
			RegKey := '{#SSRegKey}';
			InstallDefault := AddBackslash(ExpandConstant('{pf}')) + 'SlimServer';
			Svc := 'slimsvc';
			Executable := 'slimserver.exe';
			LongExecutable := Executable;
			MySQLSvc := 'SlimServerMySQL';
			TrayExe := 'SlimTray.exe';

			// old SlimServer services
			StopService(Svc);
			RemoveService(Svc);
		end;

	if (MySQLSvc <> '') then
		begin
			StopService(MySQLSvc);
			RemoveService(MySQLSvc);
		end;

	ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

	if ((RegQueryStringValue(HKLM, RegKey, 'Path', InstallFolder) and DirExists(AddBackslash(InstallFolder)))) then
		InstallFolder := AddBackslash(InstallFolder)
	else
		InstallFolder := InstallDefault;

	if (FileExists(AddBackslash(InstallFolder) + TrayExe)) then
		Exec(AddBackslash(InstallFolder) + TrayExe, '--exit --uninstall', InstallFolder, SW_HIDE, ewWaitUntilTerminated, ErrorCode);

	ProgressPage.setText(CustomMessage('WaitingForServices'), '');

	// wait up to 120 seconds for the services to be deleted
	Wait := 120;
	MaxProgress := ProgressPage.ProgressBar.Position + Wait;
	while (Wait > 0) and (IsServiceRunning(Svc) or IsServiceRunning(MySQLSvc) or IsModuleLoaded(Executable) or IsModuleLoaded(TrayExe) or IsModuleLoaded(LongExecutable)) do
	begin
	
		if (Wait mod 10 = 0) then
			Log('Waiting for service to stop...');
	
		ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
		Sleep(1000);
		Wait := Wait - 1;
	end;	
end;


procedure MigrateSlimServer();
var
	ErrorCode: Integer;
	PrefsFile: String;
	PrefsPath: String;
	OldPrefsPath: String;
	Uninstaller: String;
	UninstallPath: String;
 
begin
	// if we don't have a Squeezebox prefs file yet, migrate preference file before uninstalling SlimServer
	if not FileExists(GetPrefsFile()) then
		begin
			PrefsPath := GetPrefsFolder();
			if (not DirExists(PrefsPath)) then
				ForceDirectories(PrefsPath);

			PrefsFile := AddBackslash(PrefsPath) + '..\slimserver.pref';

			if ((RegQueryStringValue(HKLM, '{#SSRegKey}', 'Path', OldPrefsPath) and DirExists(AddBackslash(OldPrefsPath) + 'server'))) then
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
				begin
					SuppressibleMsgBox(CustomMessage('ProblemUninstallingSlimServer') + SysErrorMessage(ErrorCode), mbError, MB_OK, IDOK);
					CustomExitCode := 1102;
				end
		end;

	// some manual cleanup work, in case previous uninstall didn't succeed
	RemoveServices('SS');
	DeleteFile(AddBackslash(ExpandConstant('{group}')) + 'Slim Devices website.lnk');
	DeleteFile(AddBackslash(ExpandConstant('{group}')) + 'Slim Web Interface.lnk');
	DelTree(AddBackslash(ExpandConstant('{group}')) + 'SlimServer', true, true, true);
	RegDeleteKeyIncludingSubkeys(HKLM, 'SOFTWARE\SlimDevices');
end;


procedure MigrateSqueezeCenter();
var
	ErrorCode: Integer;
	PrefsFile: String;
	PrefsPath: String;
	PluginsPath: String;
	OldPrefsPath: String;
	Uninstaller: String;
	UninstallPath: String;
	FindRec: TFindRec;
	StartAtBoot: String;

begin
	// if we don't have a server.prefs file yet, migrate preference file before uninstalling SlimServer
	if not FileExists(GetPrefsFile()) then
		begin
			PrefsPath := AddBackslash(GetPrefsFolder());
			if (not DirExists(PrefsPath)) then
				ForceDirectories(PrefsPath);

			PluginsPath := AddBackslash(PrefsPath) + AddBackslash('plugin');
			if (not DirExists(PluginsPath)) then
				ForceDirectories(PluginsPath);

			PrefsFile := PrefsPath + 'server.prefs';

			if ((RegQueryStringValue(HKLM, '{#SCRegKey}', 'DataPath', OldPrefsPath) and DirExists(AddBackslash(OldPrefsPath) + 'prefs'))) then begin
			
				OldPrefsPath := AddBackslash(OldPrefsPath) + AddBackslash('prefs');
				if (FindFirst(OldPrefsPath + '*.*', FindRec)) then begin
					try
						repeat
							FileCopy(OldPrefsPath + FindRec.Name, PrefsPath + FindRec.Name, false);
						until not FindNext(FindRec);
					finally
						FindClose(FindRec);
					end;
				end;
			
				// migrate plugin prefs
				OldPrefsPath := OldPrefsPath + AddBackslash('plugin');
				if (FindFirst(OldPrefsPath + '*.*', FindRec)) then begin
					try
						repeat
							FileCopy(OldPrefsPath + FindRec.Name, PluginsPath + FindRec.Name, false);
						until not FindNext(FindRec);
					finally
						FindClose(FindRec);
					end;
				end;
				
			end;
		end;

	// call the SqueezeCenter uninstaller
	if (RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SqueezeCenter_is1', 'QuietUninstallString', Uninstaller)
		and RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SqueezeCenter_is1', 'InstallLocation', UninstallPath)) then
		begin
			if not Exec(RemoveQuotes(Uninstaller), '', UninstallPath, SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode) then
				begin
					SuppressibleMsgBox(CustomMessage('ProblemUninstallingSqueezeCenter') + SysErrorMessage(ErrorCode), mbError, MB_OK, IDOK);
					CustomExitCode := 1103;
				end
		end;

	// remove some legacy stuff
	if (RegQueryStringValue(HKLM, '{#SCRegKey}', 'DataPath', OldPrefsPath)) then begin
		OldPrefsPath := AddBackslash(OldPrefsPath);
		
		if (DirExists(AddBackslash(OldPrefsPath) + 'Cache')) then begin
			Deltree(AddBackslash(OldPrefsPath) + AddBackslash('Cache') + 'Artwork', True, True, True);
			Deltree(AddBackslash(OldPrefsPath) + AddBackslash('Cache') + 'DownloadedPlugins', True, True, True);
			Deltree(AddBackslash(OldPrefsPath) + AddBackslash('Cache') + 'FileCache', True, True, True);
			Deltree(AddBackslash(OldPrefsPath) + AddBackslash('Cache') + 'icons', True, True, True);
			Deltree(AddBackslash(OldPrefsPath) + AddBackslash('Cache') + 'InstalledPlugins', True, True, True);
			Deltree(AddBackslash(OldPrefsPath) + AddBackslash('Cache') + 'MySQL', True, True, True);
			Deltree(AddBackslash(OldPrefsPath) + AddBackslash('Cache') + 'templates', True, True, True);
		end;
		
	end;

	if (StartupMode = '') and (RegQueryStringValue(HKCU, '{#SCRegKey}', 'StartAtBoot', StartAtBoot)) then
		if (StartAtBoot = '1') then
			StartupMode := 'logon';

	RegDeleteKeyIncludingSubkeys(HKLM, '{#SCRegKey}');
end;


procedure UninstallSqueezeboxServer();
var
	ErrorCode: Integer;
	Uninstaller: String;
begin
	// Queries the specified REG_SZ or REG_EXPAND_SZ registry key/value, and returns the value in ResultStr.
	// Returns True if successful. When False is returned, ResultStr is unmodified.
	if RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\Squeezebox Server_is1','UninstallString', Uninstaller) then
		begin
			if not Exec(RemoveQuotes(Uninstaller), '/SILENT','', SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode) then
				begin
					SuppressibleMsgBox(CustomMessage('ProblemUninstallingSqueezboxServer') + SysErrorMessage(ErrorCode), mbError, MB_OK, IDOK);
					CustomExitCode := 1104;
				end
		end;
end;


procedure RemoveLegacyFiles();
var
	ServerDir: String;
	DelDir: String;

begin
	ServerDir := AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');

	DelTree(ServerDir + AddBackslash('CPAN') + AddBackslash('arch'), true, true, true);

	// as of SC 7.4.1 we include everything but the Plugin folder with the binary

	DelTree(ServerDir + AddBackslash('Slim'), true, true, true);

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
	DelTree(DelDir + AddBackslash('ScreenReader'), true, true, true);
	DelTree(DelDir + AddBackslash('SenseMaker'), true, true, true);
	DelTree(DelDir + AddBackslash('Touch'), true, true, true);
	DelTree(DelDir + AddBackslash('WebPad'), true, true, true);
	DelTree(DelDir + AddBackslash('xml'), true, true, true);
	DelTree(DelDir + AddBackslash('xmlTelCanto'), true, true, true);

	DelDir := ServerDir + AddBackslash('Plugins');

	// Remove old Favorites plugin - now standard
	DelTree(DelDir + AddBackslash('Favorites'), true, true, true);
	DelTree(DelDir + AddBackslash('MyRadio'), true, true, true);

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

	// Remove other defunct pieces
	DeleteFile(ServerDir + 'psapi.dll');
	DeleteFile(ServerDir + 'SlimServer.exe');

	// bug 9698: remove old (<=7.5) artwork cache, as it can take a loooong time to check permissions and we don't use it any more
	DelDir := AddBackslash(GetWritablePath('')) + AddBackslash('Cache');
	Deltree(DelDir + AddBackslash('Artwork'), true, true, true);
	Deltree(DelDir + AddBackslash('ArtworkCache'), true, true, true);
	
	// bug 17734: dito for the FileCache folder. Under certain circumstances this can have grown to tens of thousands of files
	Deltree(DelDir + AddBackslash('FileCache'), true, true, true);
end;

procedure GetStartupMode();
var
	StartAtBoot: String;

begin
	// 'auto'  - service to be started automatically
	// 'logon' - to be started on at logon (application mode)
	StartupMode := '';

	if GetStartType('squeezesvc') <> '' then
		StartupMode := GetStartType('squeezesvc')

	else if GetStartType('slimsvc') <> '' then
		StartupMode := GetStartType('slimsvc')

	else
		begin
			if RegQueryStringValue(HKCU, '{#SBRegKey}', 'StartAtBoot', StartAtBoot) then
				if (StartAtBoot = '1') then
					StartupMode := 'logon';
		end;
end;

// check whether the VC redistributable libraries are installed
function HasVCRedist(): Boolean;
var
	VCRedistInstalled: Cardinal;
begin
	if ( RegQueryDWordValue(HKLM, '{#VCRedistKey}', 'Installed', VCRedistInstalled) and (VCRedistInstalled >= 1) ) then
		Result := true
	else
		Result := false;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
	if (WizardSilent and (not HasVCRedist())) then
		begin
			ExtractTemporaryFile('vcredist.exe');
			if (DirExists('d:\shares\software') and FileCopy(ExpandConstant('{tmp}') + 'vcredist.exe', 'd:\shares\software\vcredist.exe', false)) then
				Result := CustomMessage('PleaseInstallVCRedist2010') + CustomMessage('FindVCRedist')
			else
				Result := CustomMessage('PleaseInstallVCRedist2010') + CustomMessage('FindVCRedist2010Online');
		end
	else
		Result := '';
end;

procedure InitializeWizard();
begin
	// try to remember whether SS/SC was running as a service before we're uninstalling
	GetStartupMode();
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
	Wait, ErrorCode, i: Integer;
	NewServerDir, PrefsFile, PrefsPath, PrefString, PortConflict, s: String;
	Started, Silent, TrayIcon, NoTrayIcon, InstallService: Boolean;

begin
	if CurStep = ssInstall then
		begin
			CustomExitCode := 0;

			if ( RegQueryStringValue(HKLM, '{#SBRegKey}', 'Path', PrefsPath)
					or RegQueryStringValue(HKLM, '{#SCRegKey}', 'Path', PrefsPath)
					or RegQueryStringValue(HKLM, '{#SSRegKey}', 'Path', PrefsPath) ) then
				begin
					// add custom progress bar to be displayed while unregistering services
					ProgressPage := CreateOutputProgressPage(CustomMessage('UnregisterServices'), CustomMessage('UnregisterServicesDesc'));
	
					try
						ProgressPage.setProgress(0, 170);
						if (StartupMode = '') and (IsServiceRunning('squeezesvc') or IsServiceRunning('slimsvc') or IsModuleLoaded('SqueezeSvr.exe') or IsModuleLoaded('squeez~3.exe')
							or IsModuleLoaded('squeez~1.exe') or IsModuleLoaded('squeezecenter.exe') or IsModuleLoaded('slimserver.exe')) then
							StartupMode := 'running';
	
						UninstallSliMP3();
	
						ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);
	
						MigrateSlimServer();

						RemoveServices('SC');
						ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);
						MigrateSqueezeCenter();

						UninstallSqueezeboxServer();

						RemoveServices('SB');
	
						ProgressPage.setProgress(0, 0);
						ProgressPage.SetText(CustomMessage('RemoveLegacyFiles'), CustomMessage('RemoveLegacyFilesWarning'));

						RemoveLegacyFiles();
	
					finally
						ProgressPage.Hide;
					end;
	
				end
			else
				if (StartupMode = '') then
					StartupMode := 'logon';
		end;

	if CurStep = ssPostInstall then 
		begin

			// remove server.version file to prevent repeated update prompts
			DeleteFile(AddBackslash(GetWritablePath('')) + AddBackslash('Cache') + AddBackslash('updates') + 'server.version');

			for i:= 0 to ParamCount() do begin
				if (pos('/silent', lowercase(ParamStr(i))) > 0) then
					Silent := true
				else if (pos('/verysilent', lowercase(ParamStr(i))) > 0) then
					Silent:= true
				else if (pos ('/notrayicon', lowercase(ParamStr(i))) > 0) then
					NoTrayIcon := true
				else if (pos('/trayicon', lowercase(ParamStr(i))) > 0) then
					TrayIcon := true
				else if (pos('/installservice', lowercase(ParamStr(i))) > 0) then
					InstallService := true
			end;
			
			Silent := Silent or WizardSilent;

			// run VC runtime installer if not already installed
			// http://blogs.msdn.com/b/astebner/archive/2010/05/05/10008146.aspx
			if ( (TrayIcon or not Silent) and (not HasVCRedist()) ) then
				Exec(AddBackslash(ExpandConstant('{tmp}')) + 'vcredist.exe', '/q:a /c:"msiexec /i vcredist.msi /qb!"', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode);

			ProgressPage := CreateOutputProgressPage(CustomMessage('RegisterServices'), CustomMessage('RegisterServicesDesc'));

			try
				ProgressPage.Show;
				ProgressPage.setProgress(0, 170);

				// check network configuration and potential port conflicts
				ProgressPage.setText(CustomMessage('ProgressForm_Description'), CustomMessage('PortConflict'));
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				// we discovered a port conflict with another application - use alternative port
				if GetHttpPort('') <> '9000' then
				begin
					PrefString := 'httpport: ' + GetHttpPort('') + #13#10;
					PortConflict := GetConflictingApp('PortConflict');
				end;

				// probing ports to see whether we have a firewall blocking or something
				ProgressPage.setText(CustomMessage('ProgressForm_Description'), CustomMessage('ProbingPorts'));
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				// Add firewall rules for Windows XP/Vista
				if (GetWindowsVersion shr 24 >= 6) then
					Exec('netsh', 'advfirewall firewall add rule name="{#AppName}" description="Allow {#AppName} to accept inbound connections." dir=in action=allow program="' + ExpandConstant('{app}') + '\server\SqueezeSvr.exe' + '"', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
	
				PrefsFile := GetPrefsFile();
	
				if (not DirExists(PrefsPath)) then
					ForceDirectories(PrefsPath);
		
				if not FileExists(PrefsFile) then
					begin
						PrefString := '---' + #13#10 + '_version: 0' + #13#10 + 'cachedir: ' + AddBackslash(GetWritablePath('')) + 'Cache' + #13#10 + 'language: ' + AnsiUppercase(ExpandConstant('{language}')) + #13#10 + PrefString;
						SaveStringToFile(PrefsFile, PrefString, False);
					end
				else if (PrefString <> '') and (not Silent) then
					begin
						SuppressibleMsgBox(PortConflict + #13#10 + #13#10 + CustomMessage('PrefsExistButPortConflict'), mbInformation, MB_OK, IDOK);
						CustomExitCode := 1001;
					end;

				NewServerDir := AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');

				// trying to connect to SN
				ProgressPage.setText(CustomMessage('ProgressForm_Description'), CustomMessage('SNConnecting'));
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				if not IsPortOpen('www.mysqueezebox.com', '3483') then
				begin
					SuppressibleMsgBox(CustomMessage('SNConnectFailed_Description') + #13#10 + #13#10 + CustomMessage('SNConnectFailed_Solution'), mbInformation, MB_OK, IDOK);
 					CustomExitCode := 1002;
				end;

				ProgressPage.setText(CustomMessage('RegisteringServices'), '{#AppName}');
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				RegisterPort('9000');
				RegisterPort(GetHttpPort(''));
				RegisterPort('9090');
				RegisterPort('9092');
				RegisterPort('3483');
				
				if InstallService then
				begin
					Exec(AddBackslash(NewServerDir) + 'SqueezeSvr.exe', '-install auto', NewServerDir, SW_HIDE, ewWaitUntilIdle, ErrorCode);
					StartupMode := 'auto';
				end;

				if StartupMode = 'auto' then
					StartService('squeezesvc');

				ProgressPage.setText(CustomMessage('RegisteringServices'), 'SqueezeTray');
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				if NoTrayIcon then
					DeleteFile(AddBackslash(ExpandConstant('{commonstartup}')) + CustomMessage('SqueezeCenterTrayTool') + '.lnk');

				// in silent mode do not wait for SC to be started before quitting the installer
				if not Silent or (TrayIcon and not NoTrayIcon) then
					begin
						Exec(ExpandConstant('{app}') + '\SqueezeTray.exe', '--install', ExpandConstant('{app}'), SW_SHOW, ewWaitUntilIdle, ErrorCode);

						// "running" means: starting manually only, but was running when installer was launched
						if (StartupMode = 'running') then
							Exec(ExpandConstant('{app}') + '\SqueezeTray.exe', '--start', ExpandConstant('{app}'), SW_SHOW, ewWaitUntilIdle, ErrorCode);
				
						if (StartupMode = 'auto') or (StartupMode = 'logon') or (StartupMode = 'running') then
							begin
							ProgressPage.setText(CustomMessage('RegisteringServices'), '{#AppName}');
			
							// wait up to 120 seconds for the services to be started
								Wait := 120;
								Started := false;
								
								while (Wait > 0) do
									begin
									
										Log('Waiting for the server to be running...');
									
										ProgressPage.setProgress(ProgressPage.ProgressBar.Position+2, ProgressPage.ProgressBar.Max);
										Sleep(2000);
										
										if IsPortOpen('127.0.0.1', GetHttpPort('')) then
											// SC is ready - let's give it some more time to open the browser
											begin
												for i:=1 to 20 do
													begin
														ProgressPage.setProgress(ProgressPage.ProgressBar.Position+2, ProgressPage.ProgressBar.Max);
														Sleep(500);
													end;
												break;
											end
										
										else if (IsServiceRunning('squeezesvc') or IsModuleLoaded('squeez~1.exe') or IsModuleLoaded('SqueezeSvr.exe') or IsModuleLoaded('squeez~3.exe')) then
											Started := true
											
										else if Started then
											break;

										Wait := Wait - 2;
									end;	
							end;
					end;

			finally
				ProgressPage.Hide;
			end;
		end;	
end;

function GetCustomSetupExitCode: Integer;
begin
	Result := CustomExitCode;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
	if CurPageID = wpSelectDir then
		WizardForm.NextButton.Caption:=SetupMessage(msgButtonInstall)
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
	if CurUninstallStep = usPostUninstall then
		begin
			if not UninstallSilent then
				begin
					Deltree(ExpandConstant('{app}\server\Cache'), True, True, True);
					Deltree(ExpandConstant('{commonappdata}\Squeezebox\Cache'), True, True, True);
					Deltree(ExpandConstant('{code:GetWritablePath}\Cache'), True, True, True);
				end;

			if SuppressibleMsgBox(CustomMessage('UninstallPrefs'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2, IDNO) = IDYES then
				begin
					DelTree(GetWritablePath(''), True, True, True);
					RegDeleteKeyIncludingSubkeys(HKCU, '{#SBRegKey}');
					RegDeleteKeyIncludingSubkeys(HKLM, '{#SBRegKey}');
					RegDeleteKeyIncludingSubkeys(HKCU, '{#SCRegKey}');
					RegDeleteKeyIncludingSubkeys(HKLM, '{#SCRegKey}');
					RegDeleteKeyIncludingSubkeys(HKCU, '{#SSRegKey}');
					RegDeleteKeyIncludingSubkeys(HKLM, '{#SSRegKey}');
				end;
		end;	
end;






