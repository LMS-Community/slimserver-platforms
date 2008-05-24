[Setup]
AppName=SqueezeCenter Troubleshooting Wizard
AppVerName=SqueezeCenter
OutputBaseFilename=Troubleshooter
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
Name: en; MessagesFile: "English.isl"
Name: nl; MessagesFile: "Dutch.isl"
Name: fr; MessagesFile: "French.isl"
Name: de; MessagesFile: "German.isl"
Name: he; MessagesFile: "Hebrew.isl"
Name: it; MessagesFile: "Italian.isl"
Name: es; MessagesFile: "Spanish.isl"

[Files]
Source: "FirewallData.xml"; Flags: dontcopy
Source: "sockettest.dll"; Flags: dontcopy

; a dll to verify if a process is still running
; http://www.vincenzo.net/isxkb/index.php?title=PSVince
Source: psvince.dll; Flags: dontcopy

[CustomMessages]
#include "strings.iss"
CustomForm_Caption=SqueezeCenter Troubleshooting Wizard
CustomForm_Description=Let's probe your system
CustomForm_Label1_Caption0=The following processes have been found running on your system:

[Code]
function IsPortOpen(IPAddress, Port: PChar): Boolean;
external 'IsPortOpen@files:sockettest.dll stdcall delayload';

function ProbePort(Port: PChar): Boolean;
external 'ProbePort@files:sockettest.dll stdcall delayload';

function GetLocalIP: PChar;
external 'GetLocalIP@files:sockettest.dll stdcall delayload';

function IsModuleLoaded(modulename: String): Boolean;
external 'IsModuleLoaded@files:psvince.dll stdcall';

const
  XMLFileName = 'FirewallData.xml';

var
  Label1: TLabel;
  Memo1: TMemo;

{ CustomForm_Activate }

procedure CustomForm_Activate(Page: TWizardPage);
begin
  // enter code here...
end;

{ CustomForm_CancelButtonClick }

procedure CustomForm_CancelButtonClick(Page: TWizardPage; var Cancel, Confirm: Boolean);
begin
  // enter code here...
end;

{ CustomForm_CreatePage }

function CustomForm_CreatePage(PreviousPageId: Integer): Integer;
var
  Page: TWizardPage;
begin
  Page := CreateCustomPage(
    PreviousPageId,
    ExpandConstant('{cm:CustomForm_Caption}'),
    ExpandConstant('{cm:CustomForm_Description}')
  );

{ Label1 }
  Label1 := TLabel.Create(Page);
  with Label1 do
  begin
    Parent := Page.Surface;
    Caption := ExpandConstant('{cm:CustomForm_Label1_Caption0}');
    Left := ScaleX(8);
    Top := ScaleY(16);
    Width := ScaleX(319);
    Height := ScaleY(13);
  end;

  { Memo1 }
  Memo1 := TMemo.Create(Page);
  with Memo1 do
  begin
    Parent := Page.Surface;
    Left := ScaleX(8);
    Top := ScaleY(40);
    Width := ScaleX(393);
    Height := ScaleY(185);
    TabOrder := 0;
  end;

  with Page do
  begin
    OnActivate := @CustomForm_Activate;
    OnCancelButtonClick := @CustomForm_CancelButtonClick;
  end;

  Result := Page.ID;
end;

{ CustomForm_InitializeWizard }

procedure InitializeWizard();
begin
  CustomForm_CreatePage(wpWelcome);
end;



procedure CurPageChanged(CurPageID: Integer);
begin
	case CurPageID of
		wpWelcome: WizardForm.NextButton.OnClick(nil);
	end;
end;


procedure ProbePortMsg(Port: String);
var
  msg: String;
begin
  msg := 'Port ' + Port + ': ';
  if ProbePort(Port) then
    Memo1.Lines.add(msg + 'ok')
  else
    Memo1.Lines.add(msg + 'ok');
end;

function NextButtonClick(CurPage: Integer): Boolean;
var
  XMLDoc, NewNode, RootNode: Variant;
  XMLFile: String;
  i, x: Integer;

begin
  if CurPage = wpWelcome then begin
    // probe connection to our ports
    ProbePortMsg('9000');
    ProbePortMsg('9090');
    ProbePortMsg('3483');

    // Load the firewall data
    XMLDoc := CreateOleObject('MSXML2.DOMDocument');
    XMLDoc.async := False;
    XMLDoc.resolveExternals := False;

    XMLFile := ExpandConstant('{tmp}\') + XMLFileName;
    ExtractTemporaryFile(XMLFileName);
    XMLDoc.load(XMLFile);

    if XMLDoc.parseError.errorCode <> 0 then
      RaiseException('Error on line ' + IntToStr(XMLDoc.parseError.line) + ', position ' + IntToStr(XMLDoc.parseError.linepos) + ': ' + XMLDoc.parseError.reason)

    else
      begin
        RootNode := XMLDoc.getElementsByTagName('d:Firewall');

        // Loop through the list of known firewall service IDs
        for i := 0 to RootNode.length - 1 do
        begin
          NewNode := RootNode.item(i);

          if IsModuleLoaded(NewNode.getAttribute('ServiceName') + '.exe') or  IsModuleLoaded(NewNode.getAttribute('ServiceName')) then
            Memo1.Lines.add(NewNode.getAttribute('ServiceName') + ': ' + NewNode.getAttribute('ProgramName'));

        end;
      end;
    end;
    Result := True;
end;

