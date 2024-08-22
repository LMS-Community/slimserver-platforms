#define ServiceName "squeezesvc"
#define LMSPerlBin  "Perl\perl\bin\perl.exe"

[Setup]
AppName=Lyrion Music Server Service Enabler
AppVerName=Lyrion Music Server
OutputBaseFilename=SqzSvcMgr
WizardImageFile=squeezebox.bmp
WizardSmallImageFile=logo.bmp
DefaultDirName="{commonpf64}\Lyrion"
SolidCompression=yes
DisableDirPage=yes
DisableFinishedPage=yes
DisableProgramGroupPage=yes
DisableReadyMemo=yes
DisableReadyPage=yes
DisableStartupPrompt=yes
ShowLanguageDialog=no
SetupIconFile=SqueezeCenter.ico
Uninstallable=no

[Files]
Source: instsvc.pl; Flags: dontcopy
Source: grant.exe; Flags: dontcopy

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

[Run]
Filename: {sys}\sc.exe; Parameters: "failure {#ServiceName} reset= 180 actions= restart/1000/restart/1000/restart/1000"; Flags: runhidden
Filename: {sys}\sc.exe; Parameters: "config {#ServiceName} start= delayed-auto"; Flags: runhidden

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
	StartupMode := GetStartType('{#ServiceName}');
	Startup_CreatePage(wpWelcome, StartupMode);
end;

procedure CurPageChanged(CurPageID: Integer);
begin
	case CurPageID of
		wpWelcome: WizardForm.NextButton.OnClick(nil);
	end;
end;

function ShouldSkipPage(Page: Integer): Boolean;
begin
  Result := (Page = wpWelcome);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
	if not FileExists(ExpandConstant('{app}\{#LMSPerlBin}')) then
	begin
		Log(ExpandConstant('{cm:ServiceEnablerNeedsLMS}'));
		Result := ExpandConstant('{cm:ServiceEnablerNeedsLMS}');
	end;
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
				ProgressPage.setProgress(0, 150);

				StopService('{#ServiceName}');
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+20, ProgressPage.ProgressBar.Max);

				if DisableService.checked or RadioAtBootConfig.checked then
					RemoveService('{#ServiceName}');

				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+20, ProgressPage.ProgressBar.Max);

				Wait := 60;
				MaxProgress := ProgressPage.ProgressBar.Position + Wait;
				while (Wait > 0) and IsServiceInstalled('{#ServiceName}') and not RadioAtBoot.checked do
				begin
					ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
					Sleep(1000);
					Wait := Wait - 1;
				end;
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+MaxProgress, ProgressPage.ProgressBar.Max);

				if (RadioAtBoot.checked or RadioAtBootConfig.checked) and not IsServiceInstalled('{#ServiceName}') then
				begin
					ServerDir := AddBackslash(ExpandConstant('{app}')) + AddBackslash('server');

					if (Length(EditUsername.text) > 0) and (Length(EditPassword1.text) > 0) then
						Credentials := ' "' + EditUsername.text + '" "' + EditPassword1.text + '"';

					ExtractTemporaryFile('instsvc.pl');
					ExtractTemporaryFile('grant.exe');
					if not FileExists(ExpandConstant('{tmp}\instsvc.pl')) then
						Log('Failed to extract ' + ExpandConstant('{tmp}\instsvc.pl'))
					else if not FileExists(ExpandConstant('{tmp}\grant.exe')) then
						Log('Failed to extract ' + ExpandConstant('{tmp}\grant.exe'))
					else
						begin
							Exec(ExpandConstant('{tmp}\grant.exe'), 'add SeServiceLogonRight ' + EditUsername.text, '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
							Exec(ExpandConstant('{app}\{#LMSPerlBin}'), ExpandConstant('{tmp}\instsvc.pl "' + ServerDir + 'slimserver.pl"' + Credentials), '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
						end;

				end;
				ProgressPage.setProgress(ProgressPage.ProgressBar.Position+20, ProgressPage.ProgressBar.Max);

				if not DisableService.checked then
					StartService('{#ServiceName}');

				ProgressPage.setProgress(ProgressPage.ProgressBar.Max-10, ProgressPage.ProgressBar.Max);
			finally
				ProgressPage.Hide;
			end;
		end;
end;

// don't ask for confirmation before cancelling the dialog
procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
	Confirm := False;
end;
