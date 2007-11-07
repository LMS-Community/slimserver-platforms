[Setup]
AppName=SqueezeCenter Service Enabler
AppVerName=SqueezeCenter
OutputBaseFilename=ServiceEnabler
WizardImageFile=squeezebox.bmp
WizardImageBackColor=$ffffff
WizardSmallImageFile=logitech.bmp
Compression=lzma
DefaultDirName={pf}\SqueezeCenter
SolidCompression=yes
DisableDirPage=yes
DisableFinishedPage=yes
DisableProgramGroupPage=yes
DisableReadyMemo=yes
DisableReadyPage=yes
DisableStartupPrompt=yes
ShowLanguageDialog=no
Uninstallable=no
MinVersion=0,4

[Languages]
Name: nl; MessagesFile: "Dutch.isl"
Name: en; MessagesFile: "English.isl"
Name: fr; MessagesFile: "French.isl"
Name: de; MessagesFile: "German.isl"
Name: he; MessagesFile: "Hebrew.isl"
Name: it; MessagesFile: "Italian.isl"
Name: es; MessagesFile: "Spanish.isl"

[CustomMessages]
#include "strings.iss"

[Code]
#include "StartupModeWizardPage.iss"
#include "ServiceManager.iss"

var
	ProgressPage: TOutputProgressWizardPage;
	StartupMode: String;

procedure InitializeWizard();
begin
	StartupMode := GetStartType('squeezesvc');
	Startup_CreatePage(wpWelcome, StartupMode);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
	case CurPageID of
		wpWelcome: WizardForm.NextButton.OnClick(nil);
	end;
end;

function GetInstallFolder(Param: String) : String;
var
	InstallFolder: String;
begin
	if (not RegQueryStringValue(HKLM, 'Software\Logitech\SqueezeCenter', 'Path', InstallFolder)) then
		InstallFolder := AddBackslash(ExpandConstant('{pf}')) + 'SqueezeCenter';

	Result := InstallFolder;
end;

function ShouldSkipPage(Page: Integer): Boolean;
begin
  Result := (Page = wpWelcome);
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
	ErrorCode: Integer;
	ServerDir: String;
	Credentials: String;
	Wait: Integer;
	MaxProgress: Integer;

begin
	if CurStep = ssInstall then
		begin
			// add custom progress bar to be displayed while unregistering services
			ProgressPage := CreateOutputProgressPage(CustomMessage('RegisterServices'), CustomMessage('RegisterServicesDesc'));
			ProgressPage.show();

			try
				ProgressPage.setProgress(0, 100);

				StopService('squeezesvc');
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				StopService('SqueezeMySQL');
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				RemoveService('squeezesvc');
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				RemoveService('SqueezeMySQL');
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+10, ProgressPage.ProgressBar.Max);

				Wait := 60;
				MaxProgress := ProgressPage.ProgressBar.Position + Wait;
				while (Wait > 0) and (IsServiceInstalled('squeezesvc') or IsServiceInstalled('SqueezeMySQL')) do
				begin
					ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
					Sleep(1000);
					Wait := Wait - 1;
				end;	
				ProgressPage.setProgress(MaxProgress, ProgressPage.ProgressBar.Max);

				if (RadioAtBoot.checked) then
					begin
						ServerDir := AddBackslash(AddBackslash(GetInstallFolder('')) + 'server');
						Credentials := ' --username=' + EditUsername.text + ' --password=' + EditPassword1.text;
	
						Exec(ServerDir + 'squeezecenter.exe', '-install auto' + Credentials, ServerDir, SW_HIDE, ewWaitUntilIdle, ErrorCode);
						ProgressPage.setProgress(ProgressPage.ProgressBar.Max, ProgressPage.ProgressBar.Max);
					end	 
			finally
				ProgressPage.Hide;
			end;
		end;
end;
