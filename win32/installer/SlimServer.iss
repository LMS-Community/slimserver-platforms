;
; InnoSetup Script for Slim Server
;
; Slim Devices : http://www.slimdevices.com
;
; Script by Chris Eastwood, January 2003 - http://www.vbcodelibrary.co.uk
;


[Setup]
AppName=Slim Server
AppVerName=Slim Server 5.0
AppPublisher=Slim Devices
AppPublisherURL=http://www.slimdevices.com
AppSupportURL=http://www.slimdevices.com
AppUpdatesURL=http://www.slimdevices.com
DefaultDirName={pf}\Slim Server
DefaultGroupName=Slim Server
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
Source: Slim Server.exe; DestDir: {app}
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
Filename: {app}\Visit Slim Devices.url; Section: InternetShortcut; Key: URL; String: http://www.slimdevices.com
Filename: {app}\Slim Server Web Control.url; Section: InternetShortcut; Key: URL; String: http://localhost:9000

[Icons]
Name: {group}\Slim Server; Filename: {app}\Slim Server.exe
Name: {group}\Slim Devices website; Filename: {app}\Visit Slim Devices.url
Name: {group}\Slim Web Interface; Filename: {app}\Slim Web Control.url;
Name: {group}\License; Filename: {app}\License.txt
Name: {group}\Getting Started; Filename: {app}\Getting Started.html
Name: {group}\Uninstall Slim Server; Filename: {uninstallexe}
Name: {userdesktop}\Slim Server; Filename: {app}\Slim Server.exe; Tasks: desktopicon
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\Slim Server; Filename: {app}\Slim Server.exe; Tasks: quicklaunchicon


[Registry]
;
; Create the registry key to run the service if running on Win9X (inc. ME)
;
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\CurrentVersion\Run; ValueType: string; ValueName: slimserver; ValueData: {app}\Slim Server.exe; MinVersion: 4.0,0; OnlyBelowVersion: 4.90.3001,0; Flags: uninsdeletevalue

[Run]
;
; Only give the option to install as a service if running WinNT 4 at a minimum (any 'NT' system is ok - 2k, xp etc)
;
Filename: {app}\server\slimsvc.exe; Description: Install Slim Server as a Windows service; Flags: postinstall runminimized; MinVersion: 0,4.00.1381; Parameters: -install auto; WorkingDir: {app}\server
Filename: net; Description: Start Slim Windows service; Parameters: start slimsvc; Flags: postinstall runminimized; MinVersion: 0,4.00.1381
Filename: {app}\Slim Server.exe; Description: Launch Slim Server application; Flags: nowait postinstall skipifsilent runmaximized
;Filename: {app}\Release Notes.html; Description: View Release Notes; Flags: nowait shellexec postinstall unchecked

[UninstallDelete]
;Type: files; Name: {app}\server\SLIM.PRF

[_ISTool]
EnableISX=true

[UninstallRun]
Filename: net; Parameters: stop slimsvc; Flags: runminimized skipifdoesntexist; MinVersion: 0,4.00.1381
Filename: {app}\server\slimsvc.exe; Parameters: -remove; WorkingDir: {app}\server; Flags: skipifdoesntexist runminimized; MinVersion: 0,4.00.1381

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

function ScriptDlgPages(CurPage: Integer; BackClicked: Boolean): Boolean;
var
	CurSubPage: Integer;
	Next: Boolean;
begin
	FileName:=AddBackslash(ExpandConstant('{app}')) + AddBackslash('server') + 'SLIM.PRF';
	
	if (not FileExists(FileName) and ((not BackClicked and (CurPage = wpSelectDir)) or (BackClicked and (CurPage = wpSelectProgramGroup)))) then begin
		// Insert a custom wizard page between two non custom pages
	if not BackClicked then
		curSubPage:=0
	else
		curSubPage:=1;

	ScriptDlgPageOpen();

	while(CurSubPage>=0) and (CurSubPage<=1) and not Terminated do begin
		case CurSubPage of
			0:
				begin
					ScriptDlgPageSetCaption('Select your Music Folder');
					ScriptDlgPageSetSubCaption1('Where should the Slim Server look for your music?');
					ScriptDlgPageSetSubCaption2('Select the folder you would like the Slim Server to look for your music, then click Next.');

					if(MyMusicFolder='') then
						MyMusicFolder := WizardDirValue;

					// Ask for a dir until the user has entered one or click Back or Cancel
					Next := InputDir( '', MyMusicFolder);

					while Next and (MyMusicFolder = '') do begin
						MsgBox(SetupMessage(msgInvalidPath), mbError, MB_OK);
						Next := InputDir('', MyMusicFolder);
					end;
				end;
			1:
				begin
					ScriptDlgPageSetCaption('Select your Playlist Folder');
					ScriptDlgPageSetSubCaption1('Where should Slim Server look for / store your Playlists ?');
					ScriptDlgPageSetSubCaption2('Select the folder you would like the Slim Server to look for or store your playlists, then click Next.');

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
		Result := True;
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


function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo,
 MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
	S: String;
begin
	if not FileExists(FileName) then
	begin
		// Fill the 'Ready Memo' with the normal settings and the custom settings
		S := '';

		S := S + MemoDirInfo + NewLine + NewLine;

		S := S + 'Music Folder' + NewLine;
		S := S + Space + MyMusicFolder + NewLine + NewLine;
		S := S + 'Playlist Folder' + NewLine;
		S := S + Space + MyPlayListFolder + NewLine + NewLine;
	end

	Result := S;
end;


procedure CurStepChanged(CurStep: Integer);
var
	res: Boolean;
	ErrorCode: Integer;
	ServicePath: String;
	ServerDir: String;
	Uninstaller: String;
begin
	if CurStep = csFinished then
		begin
		if not FileExists(FileName) then
			begin
				res:= SaveStringToFile(FileName, 'mp3dir = ' + MyMusicFolder + #13#10, true);
					res:= SaveStringToFile(FileName, 'playlistdir = ' + MyPlayListFolder + #13#10, true);
				end;
	 	end;
// Queries the specified REG_SZ or REG_EXPAND_SZ registry key/value, and returns the value in ResultStr. Returns True if successful. When False is returned, ResultStr is unmodified. 
	if not RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\SLIMP3 Server_is1','UninstallString', Uninstaller) then 
		begin
			InstExec(Uninstaller, '/SILENT','', True, True, SW_HIDE, ErrorCode)
		end;			

	if UsingWinNT() then
		begin
		if CurStep = csWizard then
			begin
				InstExec('net', 'stop slimsvc', '', True, True, SW_HIDE, ErrorCode);
				ServerDir:= AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');
				ServicePath:= ServerDir + AddBackslash('slimsvc.exe');

				InstExec(ServicePath, '-remove', ServerDir, true, true, SW_HIDE, ErrorCode);
			end;
		end;
end;


