[Setup]
AppName=Logitech Media Server Troubleshooting Wizard
AppVerName=Logitech Media Server
OutputBaseFilename=Troubleshooter
WizardImageFile=squeezebox.bmp
WizardImageBackColor=$ffffff
WizardSmallImageFile=logitech.bmp
Compression=lzma
DefaultDirName={pf}\Squeezebox
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
Name: en; MessagesFile: "Default.isl"
Name: de; MessagesFile: "German.isl"
Name: da; MessagesFile: "Danish.isl"
Name: es; MessagesFile: "Spanish.isl"
Name: fr; MessagesFile: "French.isl"
Name: fi; MessagesFile: "Finnish.isl"
Name: he; MessagesFile: "Hebrew.isl"
Name: it; MessagesFile: "Italian.isl"
Name: nl; MessagesFile: "Dutch.isl"
Name: no; MessagesFile: "Norwegian.isl"
Name: sv; MessagesFile: "Swedish.isl"

[Messages]
WelcomeLabel1=Welcome to the [name]
WelcomeLabel2=This will help analyzing common Logitech Media Server problems on your computer.%n%nIt is recommended that you close all other applications before continuing.

[CustomMessages]
#include "strings.iss"

[Code]
#include "SocketTest.iss"

var
  Summary: TMemo;
  PortConflict_Problem: TLabel;
  SummaryPage, NoProblemPage, PortConflictPage, PingProblemPage: Integer;
	ProgressPage: TOutputProgressWizardPage;
	Msg: String;
	AllFine: Boolean;

procedure SummaryForm_Activate(Page: TWizardPage);
begin
  if Msg > '' then
    MsgBox(Msg, mbError, MB_OK);
end;

function SummaryForm_CreatePage(PreviousPageId: Integer): Integer;
var
  Page: TWizardPage;
begin
  Page := CreateCustomPage(
    PreviousPageId,
    ExpandConstant('{cm:Caption}'),
    ExpandConstant('{cm:SummaryForm_Description}')
  );

  { Summary }
  Summary := TMemo.Create(Page);
  with Summary do
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
    OnActivate := @SummaryForm_Activate;
  end;

  Result := Page.ID;
end;

function NoProblemForm_CreatePage(PreviousPageId: Integer): Integer;
var
  Page: TWizardPage;
  NoProblemHint: TLabel;
begin
  Page := CreateCustomPage(
    PreviousPageId,
    ExpandConstant('{cm:Caption}'),
    ExpandConstant('{cm:NoProblemForm_Description}')
  );

  { Summary }
  NoProblemHint := TLabel.Create(Page);
  with NoProblemHint do
  begin
    Parent := Page.Surface;
    Left := ScaleX(0);
    Top := ScaleY(0);
    Width := ScaleX(410);
    Height := ScaleY(230);
    Caption := ExpandConstant('{cm:NoProblem}');
    WordWrap := True;
  end;

  Result := Page.ID;
end;

function ProblemForm_CreatePage(PreviousPageId: Integer; Description, ProblemDesc, SolutionDesc: String): Integer;
var
  Page: TWizardPage;
  l: TLabel;
begin
  Page := CreateCustomPage(PreviousPageId, ExpandConstant('{cm:Caption}'), Description);

  l := TLabel.Create(Page);
  with l do
  begin
    Parent := Page.Surface;
    Left := ScaleX(0);
    Top := ScaleY(0);
    Width := ScaleX(410);
    Height := ScaleY(13);
    Caption := ExpandConstant('{cm:Problem}');
    Font.Style := [fsBold];
  end;

  l := TLabel.Create(Page);
  with l do
  begin
    Parent := Page.Surface;
    Left := ScaleX(0);
    Top := ScaleY(20);
    Width := ScaleX(410);
    Height := ScaleY(30);
    Caption := ProblemDesc;
  end;

  l := TLabel.Create(Page);
  with l do
  begin
    Parent := Page.Surface;
    Left := ScaleX(0);
    Top := ScaleY(60);
    Width := ScaleX(410);
    Height := ScaleY(13);
    Caption := ExpandConstant('{cm:Solution}');
    Font.Style := [fsBold];
  end;

  l := TLabel.Create(Page);
  with l do
  begin
    Parent := Page.Surface;
    Left := ScaleX(0);
    Top := ScaleY(80);
    Width := ScaleX(410);
    Height := ScaleY(170);
    Caption := SolutionDesc;
  end;

  Result := Page.ID;
end;

procedure InitializeWizard();
begin
  SummaryPage := SummaryForm_CreatePage(wpWelcome);
  NoProblemPage := NoProblemForm_CreatePage(SummaryPage);
end;

procedure ProbePortMsg(Port: String);
var
  msg: String;
begin
  ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
  ProgressPage.setText('Probing ports to see whether a firewall is blocking: ' + Port, '');

  msg := '-> Port ' + Port + ': ';
  if ProbePort(Port) then
    Summary.Lines.add(msg + 'ok')
  else
    Summary.Lines.add(msg + 'nope');
end;

procedure ProbeProcessList;
var
  XMLDoc, NewNode, RootNode: Variant;
  XMLFile, s: String;
  i: Integer;

begin
  ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
  ProgressPage.setText('Let''s see whether there are some well known processes which might be firewall products or other applications known to be in our way', '');

  Summary.Lines.add('');
  Summary.Lines.add('List of processes known to potentially cause issues with Logitech Media Servers');

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

        if String(NewNode.getAttribute('type')) = 'PortConflict' then
          continue;

        if IsModuleLoaded(NewNode.getAttribute('ServiceName') + '.exe') or IsModuleLoaded(NewNode.getAttribute('ServiceName')) or IsServiceRunning(NewNode.getAttribute('ServiceName')) then
        begin
          AllFine := false;
          Summary.Lines.add('-> ' + NewNode.getAttribute('ServiceName') + ': ' + NewNode.getAttribute('ProgramName'));

          if NewNode.getAttribute('Help') <> Null then

            ProblemForm_CreatePage(
              NoProblemPage,
              ExpandConstant('{cm:AppConflict}'),
              ExpandConstant('{cm:AppConflict_Description}'),
              ExpandConstant('{cm:' + String(NewNode.getAttribute('Help')) + '}')
            );
        end;
      end;
    end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  case PageID of
    SummaryPage:
      Result := (Summary.Lines.Count = 0);
    NoProblemPage:
      Result := not AllFine;
  end;
end;


function NextButtonClick(CurPageID: Integer): Boolean;
var
  x: Integer;
  PortConflict: Integer;
  s: String;

begin
  if CurPageID = wpWelcome then
  begin
    AllFine := true;
    ProgressPage := CreateOutputProgressPage(CustomMessage('ProgressForm_Caption'), CustomMessage('ProgressForm_Description'));

    try
      ProgressPage.setProgress(0, 7);
			ProgressPage.Show;

    	ProgressPage.setText('Checking availability of port 9000 (Logitech Media Server web interface)', '');
    	PortConflict := CheckPort9000();
    	if PortConflict > 100 then
    	begin
        AllFine := false;

        // PageFromID
        s := GetPort9000ResultString(PortConflict);
      	Summary.Lines.add(s);
      	Summary.Lines.add('');

        if PortConflict = 102 then
          PortConflictPage := ProblemForm_CreatePage(
            NoProblemPage,
            ExpandConstant('{cm:PortConflict}'),
            ExpandConstant(s),
            ExpandConstant('{cm:PortConflict_Solution}')
          );

      end;

    	ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
    	ProgressPage.setText('Ping www.squeezenetwork.com', '');
      x := Ping('www.squeezenetwork.com');

      if x < 0 then
      begin
        AllFine := false;

      	Summary.Lines.add('Ping www.squeezenetwork.com');
        Summary.Lines.add('-> nope (' + IntToStr(x) + ')');
      	Summary.Lines.add('');

        PingProblemPage := ProblemForm_CreatePage(
          NoProblemPage,
          ExpandConstant('{cm:PingProblem}'),
          ExpandConstant('{cm:PingProblem_Description}') + ' (' + IntToStr(x) + ')',
          ExpandConstant('{cm:PingProblem_Solution}')
        );
      end;

     	ProgressPage.setProgress(ProgressPage.ProgressBar.Position+1, ProgressPage.ProgressBar.Max);
    	ProgressPage.setText('Connecting to www.squeezenetwork.com...', '');
    	
    	if not IsPortOpen('www.squeezenetwork.com', '3483') then
    	begin
        AllFine := false;

      	Summary.Lines.add('Connecting to www.squeezenetwork.com failed');
      	Summary.Lines.add('');

        PingProblemPage := ProblemForm_CreatePage(
          NoProblemPage,
          ExpandConstant('{cm:SNConnectFailed}'),
          ExpandConstant('{cm:SNConnectFailed_Description}'),
          ExpandConstant('{cm:SNConnectFailed_Solution}')
        );
    	end;

    	Summary.Lines.add('{cm:ProbingPorts}');
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

