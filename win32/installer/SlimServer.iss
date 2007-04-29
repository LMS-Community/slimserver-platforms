;
; InnoSetup Script for SlimServer
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

[CustomMessages]
#include "strings.iss"

[Setup]
AppName=SlimServer
AppVerName=SlimServer 7.0a1
AppPublisher=Logitech
AppPublisherURL=http://www.slimdevices.com
AppSupportURL=http://www.slimdevices.com
AppUpdatesURL=http://www.slimdevices.com
DefaultDirName={pf}\SlimServer
DefaultGroupName=SlimServer
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

Source: Getting Started.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: en; Flags: isreadme
Source: Getting Started.de.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: de; Flags: isreadme
Source: Getting Started.nl.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: nl; Flags: isreadme
Source: Getting Started.fr.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: fr; Flags: isreadme
Source: Getting Started.it.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: it; Flags: isreadme
Source: Getting Started.es.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: es; Flags: isreadme
Source: Getting Started.he.html; DestName: "{cm:GettingStarted}.html"; DestDir: {app}; Languages: he; Flags: isreadme

Source: License.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: en
Source: License.de.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: de
Source: License.nl.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: nl
Source: License.fr.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: fr
Source: License.it.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: it
Source: License.es.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: es
Source: License.he.txt; DestName: "{cm:License}.txt"; DestDir: {app}; Languages: he

; NOTE: Don't use "Flags: ignoreversion" on any shared system files
;
; Next line takes everything from the source '\server' directory and copies it into the setup
; it's output into the same location from the users choice.
;

Source: server\*.*; DestDir: {app}\server; Excludes: "*freebsd*,*openbsd*,*darwin*,*linux*,*solaris*,*cygwin*"; Flags: comparetimestamp recursesubdirs

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
; The following keys open required SlimServer ports in the XP Firewall
;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9000:TCP"; ValueData: "9000:TCP:*:Enabled:SlimServer 9000 tcp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:UDP"; ValueData: "3483:UDP:*:Enabled:SlimServer 3483 udp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:TCP"; ValueData: "3483:TCP:*:Enabled:SlimServer 3483 tcp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SOFTWARE\SlimDevices\SlimServer; ValueType: string; ValueName: Path; ValueData: {app}; MinVersion: 0,5.01

[Run]
Filename: {app}\SlimTray.exe; Description: {cm:LaunchSlimServerApplication}; WorkingDir: "{app}"; Flags: nowait skipifsilent runmaximized

[UninstallDelete]
Type: dirifempty; Name: {app}
Type: dirifempty; Name: {app}\server
Type: dirifempty; Name: {app}\server\IR
Type: dirifempty; Name: {app}\server\Plugins
Type: dirifempty; Name: {app}\server\HTML
Type: dirifempty; Name: {app}\server\SQL
Type: filesandordirs; Name: {app}\server\Cache
Type: files; Name: {app}\server\slimserver.pref
Type: files; Name: {app}\{cm:SlimDevicesWebSite}.url
Type: files; Name: {app}\{cm:SlimServerWebInterface}.url
Type: files; Name: {commonstartup}\{cm:SlimServerTrayTool}.url

[_ISTool]
EnableISX=true

[UninstallRun]
Filename: {app}\SlimTray.exe; Parameters: -exit; WorkingDir: {app}; Flags: skipifdoesntexist runminimized; MinVersion: 0,4.00.1381
Filename: net; Parameters: stop slimsvc; Flags: runminimized; MinVersion: 0,4.00.1381
Filename: sc; Parameters: stop SlimServerMySQL; Flags: runminimized; MinVersion: 0,4.00.1381
Filename: sc; Parameters: delete SlimServerMySQL; Flags: runminimized; MinVersion: 0,4.00.1381
Filename: {app}\server\slim.exe; Parameters: -remove; WorkingDir: {app}\server; Flags: skipifdoesntexist runminimized; MinVersion: 0,4.00.1381

[Code]
var
	FileName: String;
	MyMusicFolder: String;
	MyPlaylistFolder: String;
	AutoStart: String;
  MusicFolderPage: TInputDirWizardPage;
  PlaylistFolderPage: TInputDirWizardPage;

function InitializeSetup() : Boolean;
begin
	Result := True;
end;

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

procedure InitializeWizard();
begin
	AutoStart := '1';

  MusicFolderPage := CreateInputDirPage(wpSelectDir,
                    CustomMessage('SelectYourMusicFolder'),
                    CustomMessage('WhereLookMusic'),
                    CustomMessage('SelectMusicNext'),
                    False, '');
  MusicFolderPage.Add('');

  MusicFolderPage.Values[0] := GetMusicFolder();
  
  
  PlaylistFolderPage := CreateInputDirPage(wpSelectDir,
                    CustomMessage('SelectPlaylistFolder'),
                    CustomMessage('WhereLookPlaylists'),
                    CustomMessage('SelectPlaylistNext'),
                    False, '');
  PlaylistFolderPage.Add('');

  PlaylistFolderPage.Values[0] := GetPlaylistFolder();


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
			Exec('net', 'stop SlimServerMySQL', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
	
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

			// Stop the old tray
			OldTrayDir := OldServerDir + AddBackslash('..');
			TrayPath:= OldTrayDir + 'SlimTray.exe';
			if (FileExists(TrayPath)) then
				Exec(TrayPath, '--exit', OldTrayDir, SW_HIDE, ewWaitUntilTerminated, ErrorCode);

			Exec(ServicePath, '-remove', OldServerDir, SW_HIDE, ewWaitUntilTerminated, ErrorCode);		

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

			// Remove other defunct pieces
			DeleteFile(AddBackslash(ExpandConstant('{app}')) + 'SlimServer.exe');
			DeleteFile(AddBackslash(ExpandConstant('{app}')) + 'psapi.dll');
			DeleteFile(AddBackslash(ExpandConstant('{group}')) + 'Slim Devices website.lnk');
			DeleteFile(AddBackslash(ExpandConstant('{group}')) + 'Slim Web Interface.lnk');
	
		end;

	if CurStep = ssDone then begin
		if not FileExists(FileName) then
			begin
				PrefString := 'audiodir = ' + MyMusicFolder + #13#10 + 'playlistdir = ' + MyPlaylistFolder + #13#10;
				SaveStringToFile(FileName, PrefString, False);
			end;

			NewServerDir := AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');
			if (AutoStart = '1') then
				begin
					Exec(NewServerDir + 'slim.exe', '-install auto', NewServerDir, SW_SHOWMINIMIZED, ewWaitUntilTerminated, ErrorCode);
					Exec('net', 'start slimsvc', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
				end
			else
				begin
					Exec(NewServerDir + 'slim.exe', '-install', NewServerDir, SW_SHOWMINIMIZED, ewWaitUntilTerminated, ErrorCode);
				end;
	end;
	
end;

[Ignore]

function ScriptDlgPages(CurPage: Integer; BackClicked: Boolean): Boolean;
var
	CurSubPage: Integer;
	Next: Boolean;
begin
	
	if ((not BackClicked and (CurPage = wpSelectDir)) or (BackClicked and (CurPage = wpSelectProgramGroup))) then
		begin
			FileName:=AddBackslash(ExpandConstant('{app}')) + AddBackslash('server') + 'slimserver.pref';

			// Insert a custom wizard page between two non custom pages
			if  (BackClicked or FileExists(FileName)) then
				curSubPage:=2
			else
				curSubPage:=0;
		
			ScriptDlgPageOpen();
		
			while(CurSubPage>=0) and (CurSubPage<=2) and not Terminated do begin
				case CurSubPage of
					0:
						if not FileExists(FileName) then begin
							ScriptDlgPageSetCaption('Select your Music Folder');
							ScriptDlgPageSetSubCaption1('Where should the SlimServer look for your music?');
							ScriptDlgPageSetSubCaption2('Select the folder you would like the SlimServer to look for your music, then click Next.');
		
							if(MyMusicFolder='') then begin
								if (not RegQueryStringValue(HKCU, 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','My Music', MyMusicFolder)) then
									if (not RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','My Music', MyMusicFolder)) then
										if (not RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','CommonMusic', MyMusicFolder)) then
											if (RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders','Personal', MyMusicFolder)) then
												MyMusicFolder := MyMusicFolder + 'My Music'
											else
												MyMusicFolder := WizardDirValue;
							end;
		
							// Ask for a dir until the user has entered one or click Back or Cancel
							Next := InputDir(false, '', MyMusicFolder);
		
							while Next and (MyMusicFolder = '') do begin
								MsgBox(SetupMessage(msgInvalidPath), mbError, MB_OK);
								Next := InputDir(false, '', MyMusicFolder);
							end;
						end;
					1:
						if not FileExists(FileName) then begin
							ScriptDlgPageSetCaption('Select your Playlist Folder');
							ScriptDlgPageSetSubCaption1('Where should SlimServer look for an store your Playlists?');
							ScriptDlgPageSetSubCaption2('Select the folder you would like the SlimServer to look for or store your playlists, then click Next.');
		
							if(MyPlaylistFolder='') then begin
								if(MyMusicFolder<>'') then
									MyPlaylistFolder:=MyMusicFolder
								else
									MyPlaylistFolder := WizardDirValue;
							end;
		
							// Ask for a dir until the user has entered one or click Back or Cancel
							Next := InputDir(false, '', MyPlaylistFolder);
		
							while Next and (MyPlaylistFolder = '') do begin
								MsgBox(SetupMessage(msgInvalidPath), mbError, MB_OK);
								Next := InputDir(false, '', MyPlaylistFolder);
							end;

						end;
					2:
						begin
							if UsingWinNT() then
								begin
									ScriptDlgPageSetCaption('Automatic Startup');
									ScriptDlgPageSetSubCaption1('');
									ScriptDlgPageSetSubCaption2('You can set SlimServer to start automatically when your computer starts up.');
				
									Next := InputOption('Start Automatically', AutoStart);

									if (Next and (AutoStart <> '1')) then
										CurSubPage := CurSubPage + 1;	

								end;
						end;				
				end;
		
				if Next then begin
						{ Go to the next page, but only if the user entered correct information }
					CurSubPage := CurSubPage + 1;
				end else
					CurSubPage := CurSubPage - 1;
		
			end;
			
			if not BackClicked then
				Result:=Next
			else
				Result:=not Next;
		
			ScriptDlgPageClose(not Result);
		end
	else
		begin
			Result := true;
		end;
end;

function NextButtonClick(CurPage: Integer): Boolean;
begin
	Result := ScriptDlgPages(CurPage, False);
end;

function BackButtonClick(CurPage: Integer): Boolean;
begin
	Result := ScriptDlgPages(CurPage, True);
end;

