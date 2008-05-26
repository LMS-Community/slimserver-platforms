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
Source: "ApplicationData.xml"; Flags: dontcopy
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
#include "ServiceManager.iss"

function IsPortOpen(IPAddress, Port: PChar): Boolean;
external 'IsPortOpen@files:sockettest.dll stdcall delayload';

function ProbePort(Port: PChar): Boolean;
external 'ProbePort@files:sockettest.dll stdcall delayload';

function GetLocalIP: PChar;
external 'GetLocalIP@files:sockettest.dll stdcall delayload';

function IsModuleLoaded(modulename: String): Boolean;
external 'IsModuleLoaded@files:psvince.dll stdcall';

const
  XMLFileName = 'ApplicationData.xml';

var
  Label1: TLabel;
  Memo1: TMemo;
  ProgressPage: Integer;
  Done: Boolean;

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
    Left := ScaleX(0);
    Top := ScaleY(0);
    Width := ScaleX(319);
    Height := ScaleY(13);
  end;

  { Memo1 }
  Memo1 := TMemo.Create(Page);
  with Memo1 do
  begin
    Parent := Page.Surface;
    Left := ScaleX(0);
    Top := ScaleY(20);
    Width := ScaleX(420);
    Height := ScaleY(210);
    TabOrder := 0;
    ReadOnly := true;
    ScrollBars := ssVertical;
  end;

  with Page do
  begin
//    OnActivate := @CustomForm_Activate;
  end;

  Result := Page.ID;
end;

{ CustomForm_InitializeWizard }

procedure InitializeWizard();
begin
  Done := False;
  ProgressPage := CustomForm_CreatePage(wpWelcome);
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
  msg := '-> Port ' + Port + ': ';
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
  if CurPage = ProgressPage then
    if Done then
      Result := True
    else
  begin
    Done := true;

    // check whether our ports are used by other applications or SC already running
    Memo1.Lines.add('Checking availability of port 9000 to be used by SqueezeCenter web interface:');

    if (IsServiceRunning('squeezesvc') or IsServiceRunning('slimsvc') or IsModuleLoaded('squeeze~1.exe') or IsModuleLoaded('squeezecenter.exe') or IsModuleLoaded('slimserver.exe')) then
      if IsPortOpen('127.0.0.1', '9000') then
        Memo1.Lines.add('-> SqueezeCenter seems to be running and available')
      else
        Memo1.Lines.add('-> SqueezeCenter seems to be running but con''t be connected to on port 9000')
    else
      if IsPortOpen('127.0.0.1', '9000') then
        Memo1.Lines.add('-> SqueezeCenter seems not to be running, but port 9000 is busy')
      else
        Memo1.Lines.add('-> Port 9000 seems to be unused - let''s grab it before someone else does!')


    Memo1.Lines.add('');
    Memo1.Lines.add('Probing our ports to see whether a firewall is blocking:');

    // probe connection to our ports
    ProbePortMsg('9000');
    ProbePortMsg('9090');
    ProbePortMsg('3483');

    Memo1.Lines.add('');
    Memo1.Lines.add('Let''s see whether there are some well known process which might be firewall products or other applications known to be in our way:');

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
        RootNode := XMLDoc.getElementsByTagName('d:process');

        // Loop through the list of known firewall service IDs
        for i := 0 to RootNode.length - 1 do
        begin
          NewNode := RootNode.item(i);

          if IsModuleLoaded(NewNode.getAttribute('ServiceName') + '.exe') or IsModuleLoaded(NewNode.getAttribute('ServiceName')) or IsServiceRunning(NewNode.getAttribute('ServiceName')) then
            Memo1.Lines.add('-> ' + NewNode.getAttribute('ServiceName') + ': ' + NewNode.getAttribute('ProgramName'));

        end;
      end;
      Result := False;

    Memo1.Lines.add('');
    Memo1.Lines.add('The End.');

    end
  else
    Result := True;
end;

