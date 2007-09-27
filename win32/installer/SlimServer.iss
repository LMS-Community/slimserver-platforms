;
; InnoSetup Script for SqueezeCenter
;
; Slim Devices/Logitech : http://www.slimdevices.com
;
; Script by Chris Eastwood, January 2003 - http://www.vbcodelibrary.co.uk
;

[Setup]
; Uncomment the following line to disable the "Select Setup Language"
; dialog and have it rely solely on auto-detection.
;ShowLanguageDialog=no
; If you want all languages to be listed in the "Select Setup Language"
; dialog, even those that can't be displayed in the active code page,
; uncomment the following line.
;ShowUndisplayableLanguages=yes

[Languages]
Name: en; MessagesFile: "English.isl"
Name: nl; MessagesFile: "Dutch.isl"
Name: de; MessagesFile: "German.isl"
Name: es; MessagesFile: "Spanish.isl"
Name: fr; MessagesFile: "French.isl"
Name: it; MessagesFile: "Italian.isl"
Name: he; MessagesFile: "Hebrew.isl"
; the following languages though not officially supported, are available in SqueezeCenter
Name: cs; MessagesFile: "Czech.isl"
Name: da; MessagesFile: "Danish.isl"
Name: fi; MessagesFile: "Finnish.isl"
Name: ja; MessagesFile: "Japanese.isl"
Name: no; MessagesFile: "Norwegian.isl"
Name: pt; MessagesFile: "Portuguese.isl"
Name: sv; MessagesFile: "Swedish.isl"
Name: zh_cn; MessagesFile: "ChineseSimp.isl"


[CustomMessages]
#include "strings.iss"

[Setup]
AppName=SqueezeCenter
AppVerName=SqueezeCenter 7.0a1
AppPublisher=Logitech
AppPublisherURL=http://www.slimdevices.com
AppSupportURL=http://www.slimdevices.com
AppUpdatesURL=http://www.slimdevices.com
DefaultDirName={pf}\SlimServer
DefaultGroupName=SqueezeCenter
WizardImageFile=slim.bmp
WizardImageBackColor=$ffffff
OutputBaseFilename=SlimSetup
MinVersion=0,4
;AlwaysRestart=yes

;
; Here's where you set the licence/info files to be displayed in the installer....
;
;InfoBeforeFile=preinstall.rtf
;
; And when installation is complete....
;
;InfoAfterFile=postinstall.rtf
;

[Tasks]
Name: desktopicon; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: quicklaunchicon; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: SlimTray.exe; DestDir: {app}; Flags: replacesameversion
Source: Release Notes.html; DestDir: {app}

Source: Getting Started.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: en cs da fi ja no pt sv zh_cn; Flags: isreadme
Source: Getting Started.de.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: de; Flags: isreadme
Source: Getting Started.nl.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: nl; Flags: isreadme
Source: Getting Started.fr.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: fr; Flags: isreadme
Source: Getting Started.it.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: it; Flags: isreadme
Source: Getting Started.es.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: es; Flags: isreadme
Source: Getting Started.he.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: he; Flags: isreadme

; add the english version for all languages as long as we don't have any translation
Source: License.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: en de nl fr it es he cs da fi ja no pt sv zh_cn
;Source: License.de.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: de
;Source: License.nl.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: nl
;Source: License.fr.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: fr
;Source: License.it.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: it
;Source: License.es.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: es
;Source: License.he.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: he

; NOTE: Don't use "Flags: ignoreversion" on any shared system files
;
; Next line takes everything from the source '\server' directory and copies it into the setup
; it's output into the same location from the users choice.
;

Source: server\*.*; DestDir: {app}\server; Excludes: "*freebsd*,*openbsd*,*darwin*,*linux*,*solaris*,*cygwin*"; Flags: comparetimestamp recursesubdirs

[Dirs]
Name: {%ALLUSERSPROFILE}\SlimServer; Permissions: users-modify; MinVersion: 0,6.0
Name: {app}\server\Plugins; Permissions: users-modify

[INI]
Filename: {app}\{cm:SlimDevicesWebSite}.url; Section: InternetShortcut; Key: URL; String: http://www.slimdevices.com; Flags: uninsdeletesection
Filename: {app}\{cm:SlimServerWebInterface}.url; Section: InternetShortcut; Key: URL; String: http://localhost:9000; Flags: uninsdeletesection

[Icons]
Name: {group}\SlimServer; Filename: {app}\SlimTray.exe; Parameters: "--start"; WorkingDir: "{app}";
Name: {group}\{cm:SlimDevicesWebSite}; Filename: {app}\{cm:SlimDevicesWebSite}.url
Name: {group}\{cm:License}; Filename: {app}\{cm:License}.txt
Name: {group}\{cm:GettingStarted}; Filename: {app}\{cm:GettingStarted}.html
Name: {group}\{cm:UninstallSlimServer}; Filename: {uninstallexe}
Name: {userdesktop}\SlimServer; Filename: {app}\SlimTray.exe; Parameters: "--start"; WorkingDir: "{app}"; Tasks: desktopicon
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\SlimServer; Filename: {app}\SlimTray.exe; Parameters: "--start"; WorkingDir: "{app}"; Tasks: quicklaunchicon
Name: {commonstartup}\{cm:SlimServerTrayTool}; Filename: {app}\SlimTray.exe; WorkingDir: "{app}"

[Registry]
;
; The following keys open required SqueezeCenter ports in the XP Firewall
;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9000:TCP"; ValueData: "9000:TCP:*:Enabled:SqueezeCenter 9000 tcp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:UDP"; ValueData: "3483:UDP:*:Enabled:SqueezeCenter 3483 udp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:TCP"; ValueData: "3483:TCP:*:Enabled:SqueezeCenter 3483 tcp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SOFTWARE\SlimDevices\SlimServer; ValueType: string; ValueName: Path; ValueData: {app}; MinVersion: 0,5.01

[UninstallDelete]
Type: dirifempty; Name: {app}
Type: dirifempty; Name: {app}\server
Type: dirifempty; Name: {app}\server\IR
Type: dirifempty; Name: {app}\server\Plugins
Type: dirifempty; Name: {app}\server\HTML
Type: dirifempty; Name: {app}\server\SQL
Type: filesandordirs; Name: {app}\server\Cache
Type: filesandordirs; Name: {%ALLUSERSPROFILE}\SlimServer; MinVersion: 0,6.0
Type: files; Name: {app}\server\slimserver.pref
Type: files; Name: {app}\{cm:SlimDevicesWebSite}.url
Type: files; Name: {app}\{cm:SlimServerWebInterface}.url
Type: files; Name: {commonstartup}\{cm:SlimServerTrayTool}.url

[UninstallRun]
Filename: net; Parameters: stop slimsvc; Flags: runhidden; MinVersion: 0,4.00.1381
Filename: sc; Parameters: stop SlimServerMySQL; Flags: runhidden; MinVersion: 0,4.00.1381
Filename: sc; Parameters: delete SlimServerMySQL; Flags: runhidden; MinVersion: 0,4.00.1381
Filename: {app}\server\slim.exe; Parameters: -remove; WorkingDir: {app}\server; Flags: skipifdoesntexist runhidden; MinVersion: 0,4.00.1381
Filename: {app}\SlimTray.exe; Parameters: --exit --uninstall; WorkingDir: {app}; Flags: skipifdoesntexist runhidden; MinVersion: 0,4.00.1381

[Code]
var
	MyMusicFolder: String;
	MyPlaylistFolder: String;

function GetMusicFolder() : String;
begin
	if (MyMusicFolder='') then begin
		if (not RegQueryStringValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','My Music', MyMusicFolder)) then
			if (not RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','My Music', MyMusicFolder)) then
				if (not RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','CommonMusic', MyMusicFolder)) then
					if (RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Personal', MyMusicFolder)) then
						MyMusicFolder := MyMusicFolder + 'My Music'
					else
						MyMusicFolder := WizardDirValue;
	end;
					
	Result := MyMusicFolder;
end;

function GetPlaylistFolder() : String;
begin
	if (MyPlaylistFolder = '') then begin
		if (GetMusicFolder() <> '') then
			MyPlaylistFolder := GetMusicFolder()
		else
			MyPlaylistFolder := WizardDirValue;
	end;

	Result := MyPlaylistFolder;
end;

// NB don't call this until after {app} is set
function GetPrefsFile() : String;
begin
	if (GetWindowsVersion shr 24 >= 6) then
		Result := AddBackslash(ExpandConstant('{%ALLUSERSPROFILE}')) + AddBackslash('SlimServer') + 'slimserver.pref'
	else
		Result := AddBackslash(ExpandConstant('{app}')) + AddBackslash('server') + 'slimserver.pref';
end;	

procedure CurStepChanged(CurStep: TSetupStep);
var
	ErrorCode: Integer;
	ServicePath: String;
	TrayPath: String;
	NewServerDir: String;
	OldServerDir: String;
	OldTrayDir: String;
	Uninstaller: String;
	delPath: String;
	PrefsFile: String;
	PrefString : String;

begin
	if CurStep = ssInstall then
		begin
			// Queries the specified REG_SZ or REG_EXPAND_SZ registry key/value, and returns the value in ResultStr.
			// Returns True if successful. When False is returned, ResultStr is unmodified.
			if  RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SLIMP3 Server_is1','UninstallString', Uninstaller) then
				begin
				if not Exec(RemoveQuotes(Uninstaller), '/SILENT','', SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode) then
					MsgBox(CustomMessage('ProblemUninstallingSLIMP3') + SysErrorMessage(ErrorCode),mbError, MB_OK);
			end;
			
			NewServerDir:= AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');
			Exec('net', 'stop slimsvc', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
			Exec('sc', 'stop SlimServerMySQL', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
			Exec('sc', 'delete SlimServerMySQL', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);

			if RegQueryStringValue(HKLM, 'System\CurrentControlSet\Services\slimsvc', 'ImagePath', ServicePath) then
				begin
					ServicePath:= RemoveQuotes(ServicePath);
					OldServerDir:= AddBackslash(ExtractFileDir(ServicePath));
				end
			else
				begin
					OldServerDir:= NewServerDir;
					if (FileExists(OldServerDir + 'slimsvc.exe')) then
						ServicePath:= OldServerDir + 'slimsvc.exe'		
					else
						ServicePath:= OldServerDir + 'slim.exe';		
				end;

			Exec(ServicePath, '-remove', OldServerDir, SW_HIDE, ewWaitUntilTerminated, ErrorCode);		

			// Stop the old tray
			OldTrayDir := OldServerDir + AddBackslash('..');
			TrayPath:= OldTrayDir + 'SlimTray.exe';
			if (FileExists(TrayPath)) then
				Exec(TrayPath, '--exit --uninstall', OldTrayDir, SW_HIDE, ewWaitUntilTerminated, ErrorCode);

			if (OldServerDir = NewServerDir) then
				DeleteFile(ServicePath);
			
			delPath := NewServerDir + AddBackslash('CPAN') + AddBackslash('arch');
			DelTree(delPath, true, true, true);

			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Bagpuss'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Dark'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Default'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('EN'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('ExBrowse'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Experimental'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Fishbone'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Gordon'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Handheld'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Moser'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Olson'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Purple'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('NBMU'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Ruttenberg'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('SenseMaker'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('Touch'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('WebPad'), true, true, true);
			DelTree(NewServerDir + AddBackslash('HTML') + AddBackslash('xml'), true, true, true);

			// Remove old Favorites plugin - now standard
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('Favorites'), true, true, true);

			// Remove defunct radio plugins (now replaced by new
			// in their own directories)
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'RadioIO.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'Picks.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'ShoutcastBrowser.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'Live365.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'iTunes.pm');

			// Remove 6.5.x style plugins when updating
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'CLI.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'Rescan.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'RPC.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'RssNews.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'SavePlaylist.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'SlimTris.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'Snow.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'Visualizer.pm');
			DeleteFile(NewServerDir + AddBackslash('Plugins') + 'xPL.pm');
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('DateTime'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('DigitalInput'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('Health'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('iTunes'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('Live365'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('LMA'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('MoodLogic'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('MusicMagic'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('Picks'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('Podcast'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('PreventStandby'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('RadioIO'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('RadioTime'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('RandomPlay'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('Rhapsody'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('RS232'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('ShoutcastBrowser'), true, true, true);
			DelTree(NewServerDir + AddBackslash('Plugins') + AddBackslash('TT'), true, true, true);

			// Remove other defunct pieces
			DeleteFile(AddBackslash(ExpandConstant('{app}')) + 'SlimServer.exe');
			DeleteFile(AddBackslash(ExpandConstant('{app}')) + 'psapi.dll');
			DeleteFile(AddBackslash(ExpandConstant('{group}')) + 'Slim Devices website.lnk');
			DeleteFile(AddBackslash(ExpandConstant('{group}')) + 'Slim Web Interface.lnk');
	
		end;

	if CurStep = ssPostInstall then begin

		// Add firewall rules for Vista
		if (GetWindowsVersion shr 24 >= 6) then
			Exec('netsh', 'advfirewall firewall add rule name="SqueezeCenter" description="Allow SqueezeCenter to accept inbound connections." dir=in action=allow program="' + ExpandConstant('{app}') + '\server\slim.exe' + '"', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);

		PrefsFile := GetPrefsFile();
	
		if not FileExists(PrefsFile) then
			begin
				PrefString := '---' + #13#10 + 'audiodir: ' + GetMusicFolder() + #13#10 + 'playlistdir: ' + GetPlaylistFolder() + #13#10 + 'language: ' + AnsiUppercase(ExpandConstant('{language}')) + #13#10;
				SaveStringToFile(PrefsFile, PrefString, False);
			end;

		NewServerDir := AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');

		Exec(NewServerDir + 'slim.exe', '-install auto', NewServerDir, SW_HIDE, ewWaitUntilTerminated, ErrorCode);
		Exec('net', 'start slimsvc', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);

		Exec(ExpandConstant('{app}') + '\SlimTray.exe', '--install', ExpandConstant('{app}'), SW_SHOW, ewNoWait, ErrorCode);
	end;
	
end;
