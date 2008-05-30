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

[Messages]
WelcomeLabel1=Welcome to the [name]
WelcomeLabel2=This will help analyzing common SqueezeCenter problems on your computer.%n%nIt is recommended that you close all other applications before continuing.

[Files]
Source: "ApplicationData.xml"; Flags: dontcopy
Source: "sockettest.dll"; Flags: dontcopy

; a dll to verify if a process is still running
; http://www.vincenzo.net/isxkb/index.php?title=PSVince
Source: psvince.dll; Flags: dontcopy

[CustomMessages]
#include "strings.iss"
ResultForm_Caption=SqueezeCenter Troubleshooting Wizard
ResultForm_Description=Let's probe your system

[Code]
#include "ServiceManager.iss"
#include "SocketTest.iss"

var
  Memo1: TMemo;
  ResultPage: Integer;
	ProgressPage: TOutputProgressWizardPage;
	Msg: String;

procedure ResultForm_Activate(Page: TWizardPage);
begin
  if Msg > '' then
    MsgBox(Msg, mbError, MB_OK);
end;

{ ResultForm_CreatePage }

function ResultForm_CreatePage(PreviousPageId: Integer): Integer;
var
  Page: TWizardPage;
begin
  Page := CreateCustomPage(
    PreviousPageId,
    ExpandConstant('{cm:ResultForm_Caption}'),
    ExpandConstant('{cm:ResultForm_Description}')
  );

  { Memo1 }
  Memo1 := TMemo.Create(Page);
  with Memo1 do
  begin
    Parent := Page.Surface;
    Left := ScaleX(0);
    Top := ScaleY(0);
    Width := ScaleX(410);
    Height := ScaleY(230);
    TabOrder := 0;
    ReadOnly := true;
    ScrollBars := ssVertical;
  end;

  with Page do
  begin
    OnActivate := @ResultForm_Activate;
  end;

  Result := Page.ID;
end;

{ ResultForm_InitializeWizard }

procedure InitializeWizard();
begin
  ResultPage := ResultForm_CreatePage(wpWelcome);
end;

procedure ProbePortMsg(Port: String);
var
  msg: String;
begin
  ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
  ProgressPage.setText('Probing ports to see whether a firewall is blocking: ' + Port, '');

  msg := '-> Port ' + Port + ': ';
  if ProbePort(Port) then
    Memo1.Lines.add(msg + 'ok')
  else
    Memo1.Lines.add(msg + 'nope');
end;

procedure ProbeProcessList;
var
  XMLDoc, NewNode, RootNode: Variant;
  XMLFile, s: String;
  i: Integer;

begin
  ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
  ProgressPage.setText('Let''s see whether there are some well known processes which might be firewall products or other applications known to be in our way', '');

  Memo1.Lines.add('');
  Memo1.Lines.add('List of processes known to potentially cause issues with SqueezeCenters');

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
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  x: Integer;

begin
  if CurPageID = wpWelcome then
  begin
    ProgressPage := CreateOutputProgressPage(CustomMessage('ResultForm_Caption'), CustomMessage('ResultForm_Description'));

    try
      ProgressPage.setProgress(0, 6);
			ProgressPage.Show;

    	ProgressPage.setText('Checking availability of port 9000 (SqueezeCenter web interface)', '');
    	x := CheckPort9000();
    	Memo1.Lines.add(GetPort9000ResultString(x));
    	if x > 100 then
        Msg := Msg + GetPort9000ResultString(x);

    	ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
    	ProgressPage.setText('Ping www.squeezenetwork.com', '');
    	Memo1.Lines.add('');
    	Memo1.Lines.add('Ping www.squeezenetwork.com');
      x := Ping('www.squeezenetwork.com');
      if x >= 0 then
        Memo1.Lines.add('-> ok (' + IntToStr(x) + ' ms)')
      else
        Memo1.Lines.add('-> nope (' + IntToStr(x) + ')');

    	Memo1.Lines.add('');
    	Memo1.Lines.add('Probing Ports');
      ProbePortMsg('9000');
      ProbePortMsg('9090');
//      ProbePortMsg('9092');
      ProbePortMsg('3483');

      ProbeProcessList;

    finally
      ProgressPage.Hide;
    end;

  end;

  Result := True
end;

