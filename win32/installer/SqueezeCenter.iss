;
; InnoSetup Script for SqueezeCenter
;
; Slim Devices/Logitech : http://www.slimdevices.com
;
; Script by Chris Eastwood, January 2003 - http://www.vbcodelibrary.co.uk

[Languages]
Name: en; MessagesFile: "Default.isl"
Name: de; MessagesFile: "German.isl"
Name: da; MessagesFile: "Danish.isl"
Name: es; MessagesFile: "Spanish.isl"
Name: fr; MessagesFile: "French.isl"
Name: fi; MessagesFile: "Finnish.isl"
Name: he; MessagesFile: "Hebrew.isl"
Name: it; MessagesFile: "Italian.isl"
Name: nl; MessagesFile: "Dutch.isl"
Name: no; MessagesFile: "Norwegian.isl"
Name: sv; MessagesFile: "Swedish.isl"

[CustomMessages]
#include "strings.iss"

[Setup]
AppName=SqueezeCenter
AppVerName=SqueezeCenter 7.3.0
AppVersion=7.3.0
VersionInfoProductName=SqueezeCenter 7.3.0
VersionInfoProductVersion=7.3.0
VersionInfoVersion=0.0.0.0

AppPublisher=Logitech
AppPublisherURL=http://www.slimdevices.com
AppSupportURL=http://www.slimdevices.com
AppUpdatesURL=http://www.slimdevices.com
DefaultDirName={code:GetInstallFolder}
DefaultGroupName=SqueezeCenter
DisableProgramGroupPage=yes
WizardImageFile=squeezebox.bmp
WizardImageBackColor=$ffffff
WizardSmallImageFile=logitech.bmp
OutputBaseFilename=SqueezeSetup
DirExistsWarning=no
MinVersion=0,4

[Files]
Source: SqueezeTray.exe; DestDir: {app}; Flags: ignoreversion
Source: ServiceEnabler.exe; DestDir: {app}; Flags: ignoreversion
Source: strings.txt; DestDir: {app}; Flags: ignoreversion
Source: Release Notes.html; DestDir: {app}; Flags: ignoreversion

; a dll to verify if a process is still running
; http://www.vincenzo.net/isxkb/index.php?title=PSVince
Source: psvince.dll; Flags: dontcopy

Source: Getting Started.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: en sv fi no da; Flags: ignoreversion
Source: Getting Started.de.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: de; Flags: ignoreversion
Source: Getting Started.nl.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: nl; Flags: ignoreversion
Source: Getting Started.fr.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: fr; Flags: ignoreversion
Source: Getting Started.it.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: it; Flags: ignoreversion
Source: Getting Started.es.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: es; Flags: ignoreversion
Source: Getting Started.he.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: he; Flags: ignoreversion

; add the english version for all languages as long as we don't have any translation
Source: License.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: de en es fr he it nl; Flags: ignoreversion
;Source: License.de.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: de
;Source: License.nl.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: nl
;Source: License.fr.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: fr
;Source: License.it.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: it
;Source: License.es.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: es
;Source: License.he.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: he

; Next line takes everything from the source '\server' directory and copies it into the setup
; it's output into the same location from the users choice.
Source: server\*.*; DestDir: {app}\server; Excludes: "*freebsd*,*openbsd*,*darwin*,*linux*,*solaris*,*cygwin*"; Flags: recursesubdirs ignoreversion

[Dirs]
Name: {commonappdata}\SqueezeCenter; Permissions: users-modify
Name: {app}\server\Plugins; Permissions: users-modify

[INI]
Filename: {app}\{cm:SlimDevicesWebSite}.url; Section: InternetShortcut; Key: URL; String: http://www.slimdevices.com; Flags: uninsdeletesection
Filename: {app}\{cm:SqueezeCenterWebInterface}.url; Section: InternetShortcut; Key: URL; String: http://localhost:9000; Flags: uninsdeletesection

[Icons]
Name: {group}\SqueezeCenter; Filename: {app}\SqueezeTray.exe; Parameters: "--start"; WorkingDir: "{app}";
Name: {group}\{cm:ManageService}; Filename: {app}\ServiceEnabler.exe;
Name: {group}\{cm:SlimDevicesWebSite}; Filename: {app}\{cm:SlimDevicesWebSite}.url
Name: {group}\{cm:License}; Filename: {app}\{cm:License}.txt
Name: {group}\{cm:GettingStarted}; Filename: {app}\{cm:GettingStarted}.html
Name: {group}\{cm:UninstallSqueezeCenter}; Filename: {uninstallexe}
Name: {commonstartup}\{cm:SqueezeCenterTrayTool}; Filename: {app}\SqueezeTray.exe; WorkingDir: "{app}"

[Registry]
;
; The following keys open required SqueezeCenter ports in the XP Firewall
;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "{code:GetHttpPort}:TCP"; ValueData: "{code:GetHttpPort}:TCP:*:Enabled:SqueezeCenter {code:GetHttpPort} tcp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:UDP"; ValueData: "3483:UDP:*:Enabled:SqueezeCenter 3483 udp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:TCP"; ValueData: "3483:TCP:*:Enabled:SqueezeCenter 3483 tcp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SOFTWARE\Logitech\SqueezeCenter; ValueType: string; ValueName: Path; ValueData: {app}

[UninstallDelete]
Type: dirifempty; Name: {app}
Type: dirifempty; Name: {app}\server
Type: dirifempty; Name: {app}\server\IR
Type: dirifempty; Name: {app}\server\Plugins
Type: dirifempty; Name: {app}\server\HTML
Type: dirifempty; Name: {app}\server\SQL
Type: filesandordirs; Name: {app}\server\Cache
Type: filesandordirs; Name: {commonappdata}\SqueezeCenter\Cache
Type: filesandordirs; Name: {code:GetWritablePath}\Cache
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
Filename: {app}\SqueezeTray.exe; Parameters: "--exit --uninstall"; WorkingDir: {app}; Flags: skipifdoesntexist runhidden; MinVersion: 0,4.00.1381

[Code]
#include "SocketTest.iss"

var
	ProgressPage: TOutputProgressWizardPage;
	StartupMode: String;
	HttpPort: String;

const
	SSRegKey = 'Software\SlimDevices\SlimServer';
	SCRegKey = 'Software\Logitech\SqueezeCenter';

function GetHttpPort(Param: String) : String;
begin
  if HttpPort = '' then
  begin
     if CheckPort9000 = 102 then
       HttpPort := '9010'
     else
       HttpPort := '9000';
  end
  Result := HttpPort
end;

function GetInstallFolder(Param: String) : String;
var
	InstallFolder: String;
begin
	if (not RegQueryStringValue(HKLM, SCRegKey, 'Path', InstallFolder)) then
		InstallFolder := AddBackslash(ExpandConstant('{pf}')) + 'SqueezeCenter';

	Result := InstallFolder;
end;


function GetWritablePath(Param: String) : String;
var
	DataPath: String;
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

	Result := AddBackslash(DataPath) + 'SqueezeCenter';
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
	Executable: String;
	MySQLSvc: String;
	TrayExe: String;
	Wait: Integer;
	MaxProgress: Integer;

begin
	ProgressPage.show();
	ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

	// remove SlimTray if it's still running
	if (UpperCase(Version) = 'SC') then
		begin
			RegKey := SCRegKey;
			InstallDefault := ExpandConstant('{app}');
			Svc := 'squeezesvc';
			Executable := 'squeez~1.exe';
			MySQLSvc := 'SqueezeMySQL';
			TrayExe := 'SqueezeTray.exe';

			// stop SqueezeCenter services if installed
			StopService(Svc);
		end
	else
		begin
			RegKey := SSRegKey;
			InstallDefault := AddBackslash(ExpandConstant('{pf}')) + 'SlimServer';
			Svc := 'slimsvc';
			Executable := 'slimserver.exe';
			MySQLSvc := 'SlimServerMySQL';
			TrayExe := 'SlimTray.exe';

			// old SlimServer services
			StopService(Svc);
			RemoveService(Svc);
		end;

	StopService(MySQLSvc);
	RemoveService(MySQLSvc);

	ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

	if ((RegQueryStringValue(HKLM, RegKey, 'Path', InstallFolder) and DirExists(AddBackslash(InstallFolder)))) then
		InstallFolder := AddBackslash(InstallFolder)
	else
		InstallFolder := InstallDefault;

	if (FileExists(AddBackslash(InstallFolder) + TrayExe)) then
		Exec(AddBackslash(InstallFolder) + TrayExe, '--exit --uninstall', InstallFolder, SW_HIDE, ewWaitUntilTerminated, ErrorCode)

	ProgressPage.setText(CustomMessage('WaitingForServices'), '');

	// wait up to 120 seconds for the services to be deleted
	Wait := 120;
	MaxProgress := ProgressPage.ProgressBar.Position + Wait;
	while (Wait > 0) and (IsServiceRunning(Svc) or IsServiceRunning(MySQLSvc) or IsModuleLoaded(Executable) or IsModuleLoaded(TrayExe) or IsModuleLoaded('squeezecenter.exe')) do
	begin
		ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
		Sleep(1000);
		Wait := Wait - 1;
	end;	
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

			if ((RegQueryStringValue(HKLM, SSRegKey, 'Path', OldPrefsPath) and DirExists(AddBackslash(OldPrefsPath) + 'server'))) then
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
			if RegQueryStringValue(HKCU, SSRegKey, 'StartAtBoot', StartAtBoot) then
				if (StartAtBoot = '1') then
					StartupMode := 'logon';
		end;
end;

procedure InitializeWizard();
begin
	// try to remember whether SS/SC was running as a service before we're uninstalling
	GetStartupMode();
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
	ErrorCode: Integer;
	NewServerDir, PrefsFile, PrefsPath, PrefString, PortConflict, s: String;

begin
	if CurStep = ssInstall then
  if (RegQueryStringValue(HKLM, SCRegKey, 'Path', PrefsPath) or RegQueryStringValue(HKLM, SSRegKey, 'Path', PrefsPath)) then
		begin
			// add custom progress bar to be displayed while unregistering services
			ProgressPage := CreateOutputProgressPage(CustomMessage('UnregisterServices'), CustomMessage('UnregisterServicesDesc'));

			try
				ProgressPage.setProgress(0, 160);
				UninstallSliMP3();

				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				UninstallSlimServer();
				RemoveServices('SC');

				RemoveLegacyFiles();

			finally
				ProgressPage.Hide;
			end;
		end;

	if CurStep = ssPostInstall then 
		begin

			ProgressPage := CreateOutputProgressPage(CustomMessage('RegisterServices'), CustomMessage('RegisterServicesDesc'));

			try
				ProgressPage.Show;
				ProgressPage.setProgress(0, 5);

				// check network configuration and potential port conflicts
				ProgressPage.setText(CustomMessage('ProgressForm_Description'), CustomMessage('PortConflict'));
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);

				// we discovered a port conflict with another application - user alternative port
				if GetHttpPort('') <> '9000' then
				begin
					PrefString := 'httpport: ' + GetHttpPort('') + #13#10;
					PortConflict := GetConflictingApp('PortConflict');
				end;

				// probing ports to see whether we have a firewall blocking or something
				ProgressPage.setText(CustomMessage('ProgressForm_Description'), CustomMessage('ProbingPorts'));
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);

// bug 8537 - disabling port probing until we've decided how to continue
//				if not ProbePort(GetHttpPort('')) and not ProbePort('9090') and not ProbePort('3483') then
//				begin
//					s := GetConflictingApp('Firewall');
//					if s <> '' then
//						MsgBox(s, mbInformation, MB_OK)
//					else
//						MsgBox(CustomMessage('UnknownFirewall'), mbInformation, MB_OK);
//				end;

				// Add firewall rules for Windows XP/Vista
				if (GetWindowsVersion shr 24 >= 6) then
					Exec('netsh', 'advfirewall firewall add rule name="SqueezeCenter" description="Allow SqueezeCenter to accept inbound connections." dir=in action=allow program="' + ExpandConstant('{app}') + '\server\squeezecenter.exe' + '"', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
	
				PrefsFile := GetPrefsFile();
	
				if (not DirExists(PrefsPath)) then
					ForceDirectories(PrefsPath);
		
				if not FileExists(PrefsFile) then
					begin
						PrefString := '---' + #13#10 + 'cachedir: ' + AddBackslash(GetWritablePath('')) + 'Cache' + #13#10 + 'language: ' + AnsiUppercase(ExpandConstant('{language}')) + #13#10 + PrefString;
						SaveStringToFile(PrefsFile, PrefString, False);
					end
				else if PrefString <> '' then
					MsgBox(PortConflict + #13#10 + #13#10 + CustomMessage('PrefsExistButPortConflict'), mbInformation, MB_OK);

				NewServerDir := AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');

				// trying to connect to SN
				ProgressPage.setText(CustomMessage('ProgressForm_Description'), CustomMessage('SNConnecting'));
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);

				if not IsPortOpen('www.squeezenetwork.com', '3483') then
				begin
					MsgBox(CustomMessage('SNConnectFailed_Description') + #13#10 + #13#10 + CustomMessage('SNConnectFailed_Solution'), mbInformation, MB_OK);
				end;

				ProgressPage.setText(CustomMessage('RegisteringServices'), 'SqueezeCenter');
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);

				RegisterPort('9000');
				RegisterPort(GetHttpPort(''));
				RegisterPort('9090');
				RegisterPort('9092');
				RegisterPort('3483');

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

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
	if CurUninstallStep = usPostUninstall then
  	if MsgBox(CustomMessage('UninstallPrefs'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then
		begin
      DelTree(GetWritablePath(''), True, True, True);
      RegDeleteKeyIncludingSubkeys(HKCU, SCRegKey);
      RegDeleteKeyIncludingSubkeys(HKLM, SCRegKey);
      RegDeleteKeyIncludingSubkeys(HKCU, SSRegKey);
      RegDeleteKeyIncludingSubkeys(HKLM, SSRegKey);
		end;	
end;

