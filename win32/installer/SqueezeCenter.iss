;
; InnoSetup Script for Lyrion Music Server
;
; Lyrion Community: https://www.lyrion.org

#define AppName "Lyrion Music Server"
#define AppVersion "9.0.0"
#define ProductURL "https://forums.slimdevices.com"
#define SBRegKey   "SOFTWARE\Lyrion\Server"
#define LegacyRegkey "SOFTWARE\Logitech\Squeezebox"
#define FolderName "Lyrion"

#define VCRedistKey  = "SOFTWARE\Microsoft\VisualStudio\10.0\VC\VCRedist\x86"

[Languages]
; order of languages is important when falling back when a localization is missing
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "cz"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "da"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "fi"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"
Name: "it"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "nl"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "no"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "pl"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "sv"; MessagesFile: "Swedish.isl"

[CustomMessages]
#include "strings.iss"

[Setup]
AppName={#AppName}
AppVerName={#AppName} {#AppVersion}
AppVersion={#AppVersion}
VersionInfoProductName={#AppName} {#AppVersion}
VersionInfoProductVersion={#AppVersion}
VersionInfoVersion=0.0.0.0

AppPublisher=Lyrion Community
AppPublisherURL={#ProductURL}
AppSupportURL={#ProductURL}
AppUpdatesURL={#ProductURL}
DefaultDirName={code:GetInstallFolder}
DefaultGroupName={#AppName}
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
WizardImageFile=squeezebox.bmp
WizardSmallImageFile=logi.bmp
OutputBaseFilename=SqueezeSetup
DirExistsWarning=no

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
Name: {commonappdata}\{#FolderName}; Permissions: users-modify
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
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9090:TCP"; ValueData: "9090:TCP:*:Enabled:{#AppName} 9090 tcp (UI)"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:UDP"; ValueData: "3483:UDP:*:Enabled:{#AppName} 3483 udp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:TCP"; ValueData: "3483:TCP:*:Enabled:{#AppName} 3483 tcp"; MinVersion: 0,5.01;

Root: HKLM; Subkey: {#SBRegKey}; ValueType: string; ValueName: "Path"; ValueData: {app}
Root: HKLM; Subkey: {#SBRegKey}; ValueType: string; ValueName: "DataPath"; ValueData: {code:GetWritablePath}
; flag the squeezesvc.exe to be run as administrator on Vista
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers; ValueType: string; ValueName: {app}\server\squeezesvc.exe; ValueData: RUNASADMIN; Flags: uninsdeletevalue; MinVersion: 0,6.0;

[InstallDelete]
Type: filesandordirs; Name: {group}
Type: filesandordirs; Name: {app}\server\CPAN
Type: filesandordirs; Name: {app}\server\Slim
Type: filesandordirs; Name: {app}\server\HTML

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

[UninstallRun]
Filename: "sc"; Parameters: "stop squeezesvc"; Flags: runhidden; MinVersion: 0,4.00.1381; RunOnceId: StopSqueezSVC
Filename: "sc"; Parameters: "delete squeezesvc"; Flags: runhidden; MinVersion: 0,4.00.1381; RunOnceId: DeleteSqueezSVC
Filename: {app}\server\SqueezeSvr.exe; Parameters: -remove; WorkingDir: {app}\server; Flags: skipifdoesntexist runhidden; MinVersion: 0,4.00.1381; RunOnceId: SqueezeSvrExe
Filename: {app}\SqueezeTray.exe; Parameters: "--exit --uninstall"; WorkingDir: {app}; Flags: skipifdoesntexist runhidden; MinVersion: 0,4.00.1381; RunOnceId: SqueezeTrayExe

[Code]
#include "SocketTest.iss"

var
	ProgressPage: TOutputProgressWizardPage;
	StartupMode: String;
	HttpPort: String;

	// custom exit codes
	// 1001 - SC configuration was found using port 9000, but port 9000 seems to be busy with an other application (PrefsExistButPortConflict)
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
		InstallFolder := AddBackslash(ExpandConstant('{commonpf32}')) + '{#FolderName}';

	Result := InstallFolder;
end;


function GetWritablePath(Param: String) : String;
var
	DataPath: String;
begin
	// Migrate legacy registry key
	if (RegQueryStringValue(HKLM, '{#LegacyRegkey}', 'DataPath', DataPath)) then
		begin
			RegWriteStringValue(HKLM, '{#SBRegKey}', 'DataPath', DataPath);
			RegDeleteValue(HKLM, '{#LegacyRegkey}', 'DataPath');
		end;

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
			// TODO - need to figure out what this value isn't stored in the registry
			// DataPath := AddBackslash(DataPath) + '{#FolderName}';
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


procedure GetStartupMode();
var
	StartAtBoot: String;

begin
	// 'auto'  - service to be started automatically
	// 'logon' - to be started on at logon (application mode)
	StartupMode := '';

	if GetStartType('squeezesvc') <> '' then
		StartupMode := GetStartType('squeezesvc')

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
	NewServerDir, PrefsFile, PrefsPath, PrefString, PortConflict: String;
	Started, Silent, TrayIcon, NoTrayIcon, InstallService: Boolean;

begin
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

				ProgressPage.setText(CustomMessage('RegisteringServices'), '{#AppName}');
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				RegisterPort('9000');
				RegisterPort(GetHttpPort(''));
				RegisterPort('9090');
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
				end;
		end;
end;






