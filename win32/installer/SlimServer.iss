;
; InnoSetup Script for SlimServer
;
; Slim Devices : http://www.slimdevices.com
;
; Script by Chris Eastwood, January 2003 - http://www.vbcodelibrary.co.uk
;


[Setup]
AppName=SlimServer
AppVerName=SlimServer 5.1.6
AppPublisher=Slim Devices
AppPublisherURL=http://www.slimdevices.com
AppSupportURL=http://www.slimdevices.com
AppUpdatesURL=http://www.slimdevices.com
DefaultDirName={pf}\SlimServer
DefaultGroupName=SlimServer
WizardImageFile=slim.bmp
WizardImageBackColor=$ffffff
OutputBaseFilename=SlimSetup
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
Source: SlimServer.exe; DestDir: {app}
Source: firmware\MAIN.HEX; DestDir: {app}\firmware\
Source: firmware\SLIMP3 Updater.exe; DestDir: {app}\firmware\
Source: Getting Started.html; DestDir: {app}
Source: psapi.dll; DestDir: {app}
Source: Release Notes.html; DestDir: {app}
Source: License.txt; DestDir: {app}
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

;
; Next line takes everything from the source '\server' directory and copies it into the setup
; it's output into the same location from the users choice.
;

Source: server\*.*; DestDir: {app}\server; Flags: comparetimestamp recursesubdirs

[INI]
Filename: {app}\Visit Slim Devices.url; Section: InternetShortcut; Key: URL; String: http://www.slimdevices.com; Flags: uninsdeletesection
Filename: {app}\SlimServer Web Interface.url; Section: InternetShortcut; Key: URL; String: http://localhost:9000; Flags: uninsdeletesection

[Icons]
Name: {group}\SlimServer; Filename: {app}\SlimServer.exe
Name: {group}\Slim Devices website; Filename: {app}\Visit Slim Devices.url
Name: {group}\Slim Web Interface; Filename: {app}\Slim Web Control.url;
Name: {group}\License; Filename: {app}\License.txt
Name: {group}\Getting Started; Filename: {app}\Getting Started.html
Name: {group}\Uninstall SlimServer; Filename: {uninstallexe}
Name: {userdesktop}\SlimServer; Filename: {app}\SlimServer.exe; Tasks: desktopicon
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\SlimServer; Filename: {app}\SlimServer.exe; Tasks: quicklaunchicon

[Registry]
;
; Create the registry key to run the service if running on Win9X (inc. ME)
;
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\CurrentVersion\Run; ValueType: string; ValueName: slimserver; ValueData: {app}\SlimServer.exe; MinVersion: 4.0,0; OnlyBelowVersion: 4.90.3001,0; Flags: uninsdeletevalue

[Run]
Filename: {app}\server\slim.exe; StatusMsg: "Setting up auto-start..."; Flags: runminimized; MinVersion: 0,4.00.1381; Parameters: "-install auto"; WorkingDir: {app}\server; Check: ShouldAutostart
Filename: net; StatusMsg: "Starting up..."; Flags: runminimized; MinVersion: 0,4.00.1381; Parameters: "start slimsvc"; WorkingDir: {app}\server; Check: ShouldAutostart
Filename: {app}\SlimServer.exe; Description: Launch SlimServer application; Flags: nowait postinstall skipifsilent runmaximized
Filename: {app}\Getting Started.html; Description: Read Getting Started document; Flags: shellexec skipifsilent postinstall

[UninstallDelete]
Type: dirifempty; Name: {app}
Type: dirifempty; Name: {app}\server
Type: dirifempty; Name: {app}\server\IR
Type: dirifempty; Name: {app}\server\Plugins
Type: dirifempty; Name: {app}\server\HTML
Type: files; Name: {app}\server\slimserver.pref
Type: files; Name: {app}\Visit Slim Devices.url
Type: files; Name: {app}\SlimServer Web Interface.url

[_ISTool]
EnableISX=true

[UninstallRun]
Filename: net; Parameters: stop slimsvc; Flags: runminimized; MinVersion: 0,4.00.1381
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

		  if (not FileExists(FileName) or UsingWinNT()) then
	       begin
         	
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
							Next := InputDir( '', MyMusicFolder);
		
							while Next and (MyMusicFolder = '') do begin
								MsgBox(SetupMessage(msgInvalidPath), mbError, MB_OK);
								Next := InputDir('', MyMusicFolder);
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
							Next := InputDir( '', MyPlayListFolder);
		
							while Next and (MyPlayListFolder = '') do begin
								MsgBox(SetupMessage(msgInvalidPath), mbError, MB_OK);
								Next := InputDir('', MyPlayListFolder);
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
		  end
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
	AutoStart := '1';
	Result := True;
end;

function ShouldAutostart() : Boolean;
begin
  if (AutoStart = '1') then 
  	Result := true
  else
  	Result := false;
end;

procedure CurStepChanged(CurStep: Integer);
var
	ErrorCode: Integer;
	ServicePath: String;
	ServerDir: String;
	Uninstaller: String;
begin
	if CurStep = csCopy then
		begin
			// Queries the specified REG_SZ or REG_EXPAND_SZ registry key/value, and returns the value in ResultStr. 
			// Returns True if successful. When False is returned, ResultStr is unmodified.
			if  RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SLIMP3 Server_is1','UninstallString', Uninstaller) then
				begin
				if not InstExec(RemoveQuotes(Uninstaller), '/SILENT','', True, True, SW_SHOWNORMAL, ErrorCode) then
					MsgBox('Problem uninstalling older SLIMP3 software: ' + SysErrorMessage(ErrorCode),mbError, MB_OK);
			end;

			if  RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimServer_is1','UninstallString', Uninstaller) then
				begin
				if not InstExec(RemoveQuotes(Uninstaller), '/SILENT','', True, True, SW_SHOWNORMAL, ErrorCode) then
					MsgBox('Problem uninstalling older SlimServer software: ' + SysErrorMessage(ErrorCode),mbError, MB_OK);
			end;
			
		end;


	if CurStep = csFinished then 
		if not FileExists(FileName) then
			SaveStringToFile(FileName, 'mp3dir = ' + MyMusicFolder + #13#10 + 'playlistdir = ' + MyPlayListFolder + #13#10, False);
	
end;
