;
; InnoSetup Script for Lyrion Music Server
;
; Lyrion Community: https://www.lyrion.org

#define AppName    "Lyrion Music Server"
#define AppVersion "9.0.0"
#define ProductURL "https://forums.slimdevices.com"
#define FolderName "Lyrion"
#define SBRegKey   "SOFTWARE\Lyrion\Server"
#define LegacyRegkey "SOFTWARE\Logitech\Squeezebox"
#define LegacyUninstaller "SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Logitech Media Server_is1"
#define W32Uninstaller "SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Lyrion Music Server_is1"
#define LMSPerl    "Perl"
#define LMSPerlBin "Perl\perl\bin\perl.exe"
#define ServiceName "squeezesvc"
#define StrawBerryPerlURL "https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-64bit-portable.zip"
#define StrawBerryPerlZIP "strawberry.zip"

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
AppId=abcf9020-4c00-4f53-a6be-ef83d0c62a47
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
DefaultDirName={commonpf64}\{#FolderName}
DefaultGroupName={#AppName}
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
WizardImageFile=squeezebox.bmp
WizardSmallImageFile=logo.bmp
OutputBaseFilename=SqueezeSetup64
DirExistsWarning=no
ArchitecturesAllowed=x64
SolidCompression=yes

[Files]
; a dll to verify if a process is still running
; http://www.vincenzo.net/isxkb/index.php?title=PSVince
Source: psvince.dll; Flags: dontcopy
Source: instsvc.pl; Flags: dontcopy
Source: SqueezeCenter.ico; DestDir: "{app}"

; Next line takes everything from the source '\server' directory and copies it into the setup
; it's output into the same location from the users choice.
Source: server\*.*; DestDir: {app}\server; Excludes: "*freebsd*,*openbsd*,*darwin*,*linux*,*solaris*"; Flags: recursesubdirs ignoreversion
Source: Output\SqzSvcMgr.exe; DestDir: {app}; Flags: ignoreversion

[Dirs]
Name: {commonappdata}\{#FolderName}; Permissions: users-modify
Name: {app}\server\Plugins; Permissions: users-modify

[Icons]
Name: {group}\{cm:SqueezeCenterWebInterface}; Filename: "http://localhost:{code:GetHttpPort}"; IconFilename: "{app}\SqueezeCenter.ico"
Name: {group}\{cm:Startup_Caption}; Filename: {app}\sqzsvcmgr.exe
Name: {group}\{cm:UninstallSqueezeCenter}; Filename: {uninstallexe}
Name: {group}\{cm:Start_LMS}; Filename: "{app}\{#LMSPerlBin}"; Parameters: """{app}\server\slimserver.pl"""; WorkingDir: "{app}\server"; IconFilename: "{app}\SqueezeCenter.ico"; Flags: runminimized

[Registry]
Root: HKLM; Subkey: {#SBRegKey}; ValueType: string; ValueName: "DataPath"; ValueData: {code:GetWritablePath}

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

[Run]
Filename: {sys}\sc.exe; Parameters: "failure {#ServiceName} reset= 180 actions= restart/1000/restart/1000/restart/1000"; Flags: runhidden
Filename: {sys}\sc.exe; Parameters: "config {#ServiceName} start= delayed-auto"; Flags: runhidden
Filename: {sys}\sc.exe; Parameters: "start {#ServiceName}"; Flags: runhidden; MinVersion: 0,4.00.1381
Filename: "http://localhost:{code:GetHttpPort}"; Description: {cm:StartupSqueezeCenterWebInterface}; Flags: postinstall nowait skipifsilent shellexec unchecked

; Remove old firewall rules, then add new
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""Lyrion Music Server"""; Flags: runhidden
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""{#AppName} (Perl)"""; Flags: runhidden
Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""{#AppName} (Perl)"" dir=in program=""{app}\{#LMSPerlBin}"" action=allow"; Flags: runhidden

[UninstallRun]
Filename: {sys}\sc.exe; Parameters: "stop {#ServiceName}"; Flags: runhidden; MinVersion: 0,4.00.1381; RunOnceId: StopSqueezSVC
Filename: {sys}\sc.exe; Parameters: "delete {#ServiceName}"; Flags: runhidden; MinVersion: 0,4.00.1381; RunOnceId: DeleteSqueezSVC

[Code]
#include "SocketTest.iss"

var
	ProgressPage: TOutputProgressWizardPage;
	DownloadPage: TDownloadWizardPage;
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

function OnDownloadProgress(const Url, Filename: string; const Progress, ProgressMax: Int64): Boolean;
begin
	if ProgressMax <> 0 then
		begin
			DownloadPage.setProgress(Progress, ProgressMax);
			Log(Format('  %d of %d bytes done.', [Progress, ProgressMax]));
		end
	else
		begin
			DownloadPage.setProgress(Progress, ProgressMax);
			Log(Format('  %d bytes done.', [Progress]));
		end;

	Result := not DownloadPage.AbortedByUser;
end;

function InitializeSetup(): Boolean;
begin
	StopService('{#ServiceName}');
	Result := True;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
	Shell, ZipFile, TargetFolder: Variant;
	PerlPath, Uninstaller: string;
	ErrorCode: Integer;

begin
	if not FileExists(ExpandConstant('{app}\{#LMSPerlBin}')) then
	begin
		DownloadPage := CreateDownloadPage(CustomMessage('StrawberryPerl'), CustomMessage('NeedStrawberryPerl'), @OnDownloadProgress);
		DownloadPage.setText(CustomMessage('DownloadingPerl'), '');

		DownloadPage.Show();
		DownloadPage.AbortButton.Show();

		try
			Log('Done downloading Strawberry Perl');
			Shell := CreateOleObject('Shell.Application');

			PerlPath := ExpandConstant('{app}\{#LMSPerl}');
			ForceDirectories(PerlPath);
			TargetFolder := Shell.NameSpace(PerlPath);

			if VarIsClear(TargetFolder) then
				RaiseException(Format('Failed to create folder "%s"', [PerlPath]));

			DownloadTemporaryFile('{#StrawBerryPerlURL}', '{#StrawBerryPerlZIP}', '', @OnDownloadProgress);

			DownloadPage.setText(CustomMessage('InstallingPerl'), '');

			ZipFile := Shell.NameSpace(AddBackslash(ExpandConstant('{tmp}')) + '{#StrawBerryPerlZIP}');
			if VarIsClear(ZipFile) then
				RaiseException(Format('ZIP file "%s" does not exist or cannot be opened', [ZipFile]));

			Log(Format('Extracting Strawberry Perl to "%s"', [PerlPath]));
			TargetFolder.CopyHere(ZipFile.Items, 16);    // SHCONTCH_RESPONDYESTOALL = 16; SHCONTCH_NOPROGRESSBOX = 4;
			Log('Done extracting Strawberry Perl');
		except
			Log(GetExceptionMessage);
			Result := GetExceptionMessage;
		finally
			DownloadPage.Hide();
		end;
	end;

	if (RegQueryStringValue(HKLM, '{#LegacyUninstaller}', 'UninstallString', Uninstaller)) then
	begin
		try
			Log('Remove legacy LMS uninstaller');
			StopService('{#ServiceName}');
			RemoveService('{#ServiceName}');
			ShellExec('', Uninstaller, '/SILENT /SUPPRESSMSGBOXES', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode);
		finally
		end;
	end;

	if (RegQueryStringValue(HKLM, '{#W32Uninstaller}', 'UninstallString', Uninstaller)) then
	begin
		try
			Log('Remove 32-bit LMS uninstaller');
			StopService('{#ServiceName}');
			RemoveService('{#ServiceName}');
			ShellExec('', Uninstaller, '/SILENT /SUPPRESSMSGBOXES', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode);
		finally
		end
	end;
end;


procedure CurStepChanged(CurStep: TSetupStep);
var
	ErrorCode, i: Integer;
	NewServerDir, PrefsFile, PrefsPath, PrefString, PortConflict: String;
	Silent: Boolean;

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
			end;

			Silent := Silent or WizardSilent;

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

				ExtractTemporaryFile('instsvc.pl');
				if not FileExists(ExpandConstant('{tmp}\instsvc.pl')) then
					Log('Failed to extract ' + ExpandConstant('{tmp}\instsvc.pl'))
				else
					Exec(ExpandConstant('{app}\{#LMSPerlBin}'), ExpandConstant('{tmp}\instsvc.pl "' + NewServerDir + 'slimserver.pl"'), '', SW_HIDE, ewWaitUntilIdle, ErrorCode);
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
					Deltree(ExpandConstant('{code:GetWritablePath}\Cache'), True, True, True);
				end;

			if SuppressibleMsgBox(CustomMessage('UninstallPrefs'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2, IDNO) = IDYES then
				begin
					DelTree(GetWritablePath(''), True, True, True);
					RegDeleteKeyIncludingSubkeys(HKLM, '{#SBRegKey}');
				end;
		end;
end;






