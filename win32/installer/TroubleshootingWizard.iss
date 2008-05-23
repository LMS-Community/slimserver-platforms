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

[CustomMessages]
#include "strings.iss"

[Code]

const
  XMLFileName = 'FirewallData.xml';


procedure CurPageChanged(CurPageID: Integer);
begin
	case CurPageID of
		wpWelcome: WizardForm.NextButton.OnClick(nil);
	end;
end;


function NextButtonClick(CurPage: Integer): Boolean;
var
  XMLDoc, NewNode, RootNode: Variant;
  XMLFile: String;
  i, x: Integer;

begin
  if CurPage = wpWelcome then begin

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
          for x := 0 to NewNode.attributes.length do
            if NewNode.attributes.item(x).name = 'ServiceName' then
              break;

          MsgBox(NewNode.attributes.item(x).value, mbInformation, mb_Ok);
        end;
      end;
    end;
    Result := True;
end;

