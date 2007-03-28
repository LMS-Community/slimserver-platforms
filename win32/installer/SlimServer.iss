;
; InnoSetup Script for SlimServer
;
; Slim Devices/Logitech : http://www.slimdevices.com
;
; Script by Chris Eastwood, January 2003 - http://www.vbcodelibrary.co.uk
;


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
Name: desktopicon; Description: Create a &desktop icon; GroupDescription: Additional icons:
Name: quicklaunchicon; Description: Create a &Quick Launch icon; GroupDescription: Additional icons:; Flags: unchecked

[Files]
Source: SlimTray.exe; DestDir: {app}; Flags: replacesameversion
Source: Getting Started.html; DestDir: {app}
Source: Release Notes.html; DestDir: {app}
Source: License.txt; DestDir: {app}
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

;
; Next line takes everything from the source '\server' directory and copies it into the setup
; it's output into the same location from the users choice.
;

Source: server\*.*; DestDir: {app}\server; Excludes: "*freebsd*,*openbsd*,*darwin*,*linux*,*solaris*,*cygwin*"; Flags: comparetimestamp recursesubdirs

[INI]
Filename: {app}\Visit Slim Devices/Logitech.url; Section: InternetShortcut; Key: URL; String: http://www.slimdevices.com; Flags: uninsdeletesection
Filename: {app}\SlimServer Web Interface.url; Section: InternetShortcut; Key: URL; String: http://localhost:9000; Flags: uninsdeletesection

[Icons]
Name: {group}\SlimServer; Filename: {app}\SlimTray.exe; Parameters: "--start"; WorkingDir: "{app}";
Name: {group}\Go to Slim Devices/Logitech Web Site; Filename: {app}\Visit Slim Devices/Logitech.url
Name: {group}\License; Filename: {app}\License.txt
Name: {group}\Getting Started; Filename: {app}\Getting Started.html
Name: {group}\Uninstall SlimServer; Filename: {uninstallexe}
Name: {userdesktop}\SlimServer; Filename: {app}\SlimTray.exe; Parameters: "--start"; WorkingDir: "{app}"; Tasks: desktopicon
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\SlimServer; Filename: {app}\SlimTray.exe; Parameters: "--start"; WorkingDir: "{app}"; Tasks: quicklaunchicon
Name: {commonstartup}\SlimServer Tray Tool; Filename: {app}\SlimTray.exe; WorkingDir: "{app}"

[Registry]
;
; The following keys open required SlimServer ports in the XP Firewall
;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "9000:TCP"; ValueData: "9000:TCP:*:Enabled:SlimServer 9000 tcp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:UDP"; ValueData: "3483:UDP:*:Enabled:SlimServer 3483 udp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List; ValueType: string; ValueName: "3483:TCP"; ValueData: "3483:TCP:*:Enabled:SlimServer 3483 tcp"; MinVersion: 0,5.01;
Root: HKLM; Subkey: SOFTWARE\SlimDevices\SlimServer; ValueType: string; ValueName: Path; ValueData: {app}; MinVersion: 0,5.01

[Run]
Filename: {app}\SlimTray.exe; Description: Launch SlimServer application; WorkingDir: "{app}"; Flags: nowait skipifsilent runmaximized
Filename: {app}\Getting Started.html; Description: Read Getting Started document; Flags: shellexec skipifsilent postinstall

[UninstallDelete]
Type: dirifempty; Name: {app}
Type: dirifempty; Name: {app}\server
Type: dirifempty; Name: {app}\server\IR
Type: dirifempty; Name: {app}\server\Plugins
Type: dirifempty; Name: {app}\server\HTML
Type: dirifempty; Name: {app}\server\SQL
Type: filesandordirs; Name: {app}\server\Cache
Type: files; Name: {app}\server\slimserver.pref
Type: files; Name: {app}\Visit Slim Devices/Logitech.url
Type: files; Name: {app}\SlimServer Web Interface.url
Type: files; Name: {commonstartup}\SlimServer Tray Tool.url

[_ISTool]
EnableISX=true

[UninstallRun]
Filename: {app}\SlimTray.exe; Parameters: -exit; WorkingDir: {app}; Flags: skipifdoesntexist runminimized; MinVersion: 0,4.00.1381
Filename: net; Parameters: stop slimsvc; Flags: runminimized; MinVersion: 0,4.00.1381
Filename: sc; Parameters: stop SlimServerMySQL; Flags: runminimized; MinVersion: 0,4.00.1381
Filename: sc; Parameters: delete SlimServerMySQL; Flags: runminimized; MinVersion: 0,4.00.1381
Filename: {app}\server\slim.exe; Parameters: -remove; WorkingDir: {app}\server; Flags: skipifdoesntexist runminimized; MinVersion: 0,4.00.1381

[Code]
{
	This section, along with [_ISTool] EnableISX=true
	means that you must compile the script with My Inno Setup Extensions -
	- see : http://www.wintax.nl/isx/ for the latest version.
}

var
	MyPlayListFolder: String;
	MyMusicFolder: String;
	FileName: String;
	AutoStart: String;

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
		
							if(MyPlayListFolder='') then begin
								if(MyMusicFolder<>'') then
									MyPlayListFolder:=MyMusicFolder
								else
									MyPlayListFolder := WizardDirValue;
							end;
		
							// Ask for a dir until the user has entered one or click Back or Cancel
							Next := InputDir(false, '', MyPlayListFolder);
		
							while Next and (MyPlayListFolder = '') do begin
								MsgBox(SetupMessage(msgInvalidPath), mbError, MB_OK);
								Next := InputDir(false, '', MyPlayListFolder);
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

function GetMusicFolder(S: String): String;
begin
	// Return the selected DataDir
	Result := MyMusicFolder;
end;

function InitializeSetup() : Boolean;
begin
	Result := True;
end;

procedure InitializeWizard();
begin
	AutoStart := '1';
end;


procedure CurStepChanged(CurStep: Integer);
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
	if CurStep = csCopy then
		begin
			// Queries the specified REG_SZ or REG_EXPAND_SZ registry key/value, and returns the value in ResultStr.
			// Returns True if successful. When False is returned, ResultStr is unmodified.
			if  RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SLIMP3 Server_is1','UninstallString', Uninstaller) then
				begin
				if not InstExec(RemoveQuotes(Uninstaller), '/SILENT','', True, True, SW_SHOWNORMAL, ErrorCode) then
					MsgBox('Problem uninstalling SLIMP3 software: ' + SysErrorMessage(ErrorCode),mbError, MB_OK);
			end;
			
			NewServerDir:= AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');
			InstExec('net', 'stop slimsvc', '', true, false, SW_HIDE, ErrorCode);
			InstExec('net', 'stop SlimServerMySQL', '', true, false, SW_HIDE, ErrorCode);
	
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
				InstExec(TrayPath, '--exit', OldTrayDir, true, false, SW_HIDE, ErrorCode);

			InstExec(ServicePath, '-remove', OldServerDir, true, false, SW_HIDE, ErrorCode);		

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
			DeleteFile(AddBackslash(ExpandConstant('{group}')) + 'Slim Devices/Logitech website.lnk');
			DeleteFile(AddBackslash(ExpandConstant('{group}')) + 'Slim Web Interface.lnk');
	
		end;

	if CurStep = csFinished then begin
		if not FileExists(FileName) then
			begin
				PrefString := 'audiodir = ' + MyMusicFolder + #13#10 + 'playlistdir = ' + MyPlayListFolder + #13#10;
				SaveStringToFile(FileName, PrefString, False);
			end;

			NewServerDir := AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');
			if (AutoStart = '1') then
				begin 
					InstExec(NewServerDir + 'slim.exe', '-install auto', NewServerDir, True, False, SW_SHOWMINIMIZED, ErrorCode); 
					InstExec('net', 'start slimsvc', '', true, false, SW_HIDE, ErrorCode);
				end
			else
				begin
					InstExec(NewServerDir + 'slim.exe', '-install', NewServerDir, True, False, SW_SHOWMINIMIZED, ErrorCode); 
				end;
	end;
	
end;
