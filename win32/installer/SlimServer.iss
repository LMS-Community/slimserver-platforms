;
; InnoSetup Script for SLIMP3 Server
;
; Slim Devices : http://www.slimdevices.com
;
; Script by Chris Eastwood, January 2003 - http://www.vbcodelibrary.co.uk
;


[Setup]
AppName=SLIMP3 Server
AppVerName=SLIMP3 Server 4.2.2
AppPublisher=Slim Devices
AppPublisherURL=http://www.slimdevices.com
AppSupportURL=http://www.slimdevices.com
AppUpdatesURL=http://www.slimdevices.com
DefaultDirName={pf}\SLIMP3 Server
DefaultGroupName=SLIMP3 Server
WizardImageFile=slimp3.bmp
WizardImageBackColor=$ffffff
OutputBaseFilename=SLIMP3Setup
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
Source: ..\..\..\build\SLIMP3 Server.exe; DestDir: {app}
Source: ..\..\..\build\firmware\MAIN.HEX; DestDir: {app}\firmware\
Source: ..\..\..\build\firmware\Updater.exe; DestDir: {app}\firmware\
Source: ..\..\..\build\Getting Started.html; DestDir: {app}
Source: ..\..\..\build\psapi.dll; DestDir: {app}
Source: ..\..\..\build\Release Notes.html; DestDir: {app}
Source: ..\..\..\build\License.txt; DestDir: {app}
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

;
; Next line takes everything from the source '\server' directory and copies it into the setup
; it's output into the same location from the users choice.
;

Source: ..\..\..\build\server\*.*; DestDir: {app}\server; Flags: comparetimestamp recursesubdirs

[INI]
Filename: {app}\Visit Slim Devices.url; Section: InternetShortcut; Key: URL; String: http://www.slimdevices.com
Filename: {app}\SLIMP3 Web Control.url; Section: InternetShortcut; Key: URL; String: http://localhost:9000

[Icons]
Name: {group}\SLIMP3 Server; Filename: {app}\SLIMP3 Server.exe
Name: {group}\Slim Devices website; Filename: {app}\Visit Slim Devices.url
Name: {group}\SLIMP3 Web Interface; Filename: {app}\SLIMP3 Web Control.url;
Name: {group}\Firmware Updater; Filename: {app}\firmware\Updater.exe
Name: {group}\License; Filename: {app}\License.txt
Name: {group}\Getting Started; Filename: {app}\Getting Started.html
Name: {group}\Uninstall SLIMP3 Server; Filename: {uninstallexe}
Name: {userdesktop}\SLIMP3 Server; Filename: {app}\SLIMP3 Server.exe; Tasks: desktopicon
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\SLIMP3; Filename: {app}\SLIMP3 Server.exe; Tasks: quicklaunchicon


[Registry]
;
; Create the registry key to run the service if running on Win9X (inc. ME)
;
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\CurrentVersion\Run; ValueType: string; ValueName: slimp3; ValueData: {app}\SliMP3 Server.exe; MinVersion: 4.0,0; OnlyBelowVersion: 4.90.3001,0; Flags: uninsdeletevalue

[Run]
;
; Only give the option to install as a service if running WinNT 4 at a minimum (any 'NT' system is ok - 2k, xp etc)
;
Filename: {app}\server\slimp3svc.exe; Description: Install SLIMP3 Server as a Windows service; Flags: postinstall runminimized; MinVersion: 0,4.00.1381; Parameters: -install auto; WorkingDir: {app}\server
Filename: net; Description: Start SLIMP3 Windows service; Parameters: start slimp3svc; Flags: postinstall runminimized; MinVersion: 0,4.00.1381
Filename: {app}\SLIMP3 Server.exe; Description: Launch SLIMP3 Server application; Flags: nowait postinstall skipifsilent runmaximized
;Filename: {app}\Release Notes.html; Description: View Release Notes; Flags: nowait shellexec postinstall unchecked

[UninstallDelete]
;Type: files; Name: {app}\server\SLIMP3.PRF

[_ISTool]
EnableISX=true

[UninstallRun]
Filename: net; Parameters: stop slimp3svc; Flags: runminimized skipifdoesntexist; MinVersion: 0,4.00.1381
Filename: {app}\server\slimp3svc.exe; Parameters: -remove; WorkingDir: {app}\server; Flags: skipifdoesntexist runminimized; MinVersion: 0,4.00.1381

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
  FileName:=AddBackslash(ExpandConstant('{app}')) + AddBackslash('server') + 'SLIMP3.PRF';
  
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
          ScriptDlgPageSetSubCaption1('Where should SLIMP3 look for your music ?');
          ScriptDlgPageSetSubCaption2('Select the folder you would like the SLIMP3 server to look for your music, then click Next.');

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
          ScriptDlgPageSetSubCaption1('Where should SLIMP3 look for / store your Playlists ?');
          ScriptDlgPageSetSubCaption2('Select the folder you would like the SLIMP3 server to look for or store your playlists, then click Next.');

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
begin
  if CurStep = csFinished then
  	begin
		if not FileExists(FileName) then
			begin
				res:= SaveStringToFile(FileName, 'mp3dir = ' + MyMusicFolder + #13#10, true);
    			res:= SaveStringToFile(FileName, 'playlistdir = ' + MyPlayListFolder + #13#10, true);
	  		end;
   	end;
  if UsingWinNT() then
    begin
    if CurStep = csWizard then
      begin
        InstExec('net', 'stop slimp3svc', '', True, True, SW_HIDE, ErrorCode);
        ServerDir:= AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');
        ServicePath:= ServerDir + AddBackslash('slimp3svc.exe');

        InstExec(ServicePath, '-remove', ServerDir, true, true, SW_HIDE, ErrorCode);
      end;
    end;
end;


