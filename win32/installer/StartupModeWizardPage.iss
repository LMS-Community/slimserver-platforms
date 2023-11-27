#define LabelLeft = 17
#define InputLeft = 150

// start startup selection screen...
var
	LabelUsername: TLabel;
	LabelPassword1: TLabel;
	DisableService: TRadioButton;
	RadioAtBootConfig: TRadioButton;
	RadioAtBoot: TRadioButton;
	LabelAtBootDesc: TNewStaticText;
	EditUsername: TEdit;
	EditPassword1: TPasswordEdit;

function Startup_NextButtonClick(Page: TWizardPage): Boolean;
begin
	Result := true;

	if RadioAtBootConfig.checked and (CompareStr(EditUsername.text, '') = 0) then
		begin
			Result := MsgBox(CustomMessage('Startup_CredentialsRequired'), mbConfirmation, MB_YESNO) = IDYES;
		end;

	if (Result and not RadioAtBootConfig.checked) then
		begin
			EditUsername.text := '';
			EditPassword1.text := '';
		end;
end;

procedure EnableCredentials(Sender: TObject);
begin
	EditUsername.Color := clWindow;
	EditUsername.Enabled := True;
	EditPassword1.Color := clWindow;
	EditPassword1.Enabled := True;
end;

procedure DisableCredentials(Sender: TObject);
begin
	EditUsername.Color := cl3DLight;
	EditUsername.Enabled := False;
	EditPassword1.Color := cl3DLight;
	EditPassword1.Enabled := False;
end;

function Startup_CreatePage(PreviousPageId: Integer; StartupMode: String): Integer;
var
	Page: TWizardPage;

begin
	Page := CreateCustomPage(
		PreviousPageId,
		ExpandConstant('{cm:Startup_Caption}'),
		ExpandConstant('{cm:Startup_Description}')
	);

	RadioAtBoot := TRadioButton.Create(Page);
	with RadioAtBoot do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_RadioAtBoot_Caption0}');
		Left := ScaleX(0);
		Top := ScaleY(28);
		Width := ScaleX(409);
		Height := ScaleY(17);
		TabOrder := 2;
		Checked := False;
		OnClick := @DisableCredentials;
	end;

	RadioAtBootConfig := TRadioButton.Create(Page);
	with RadioAtBootConfig do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_RadioAtBootCustom_Caption0}');
		Left := ScaleX(0);
		Top := ScaleY(55);
		Width := ScaleX(409);
		Height := ScaleY(17);
		TabOrder := 4;
		Checked := False;
		OnClick := @EnableCredentials;
	end;

	DisableService := TRadioButton.Create(Page);
	with DisableService do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_DisableService_Caption0}');
		Left := ScaleX(0);
		Top := ScaleY(167);
		Width := ScaleX(409);
		Height := ScaleY(17);
		TabOrder := 9;
		TabStop := True;
		Checked := False;
		OnClick := @DisableCredentials;
	end;

	LabelAtBootDesc := TNewStaticText.Create(Page);
	with LabelAtBootDesc do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_LabelAtBootDesc_Caption0}');
		Left := ScaleX({#LabelLeft});
		Top := ScaleY(76);
		Width := ScaleX(396);
		Height := ScaleY(27);
		WordWrap := True;
	end;

	LabelUsername := TLabel.Create(Page);
	with LabelUsername do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_LabelUsername_Caption0}');
		Left := ScaleX({#LabelLeft});
		Top := ScaleY(114);
		Width := ScaleX(150);
		Height := ScaleY(13);
	end;

	LabelPassword1 := TLabel.Create(Page);
	with LabelPassword1 do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_LabelPassword1_Caption0}');
		Left := ScaleX({#LabelLeft});
		Top := ScaleY(141);
		Width := ScaleX(150);
		Height := ScaleY(13);
	end;

	EditUsername := TEdit.Create(Page);
	with EditUsername do
	begin
		Parent := Page.Surface;
		Left := ScaleX({#InputLeft});
		Top := ScaleY(110);
		Width := ScaleX(217);
		Height := ScaleY(21);
		TabOrder := 6;
	end;

	EditPassword1 := TPasswordEdit.Create(Page);
	with EditPassword1 do
	begin
		Parent := Page.Surface;
		Left := ScaleX({#InputLeft});
		Top := ScaleY(137);
		Width := ScaleX(217);
		Height := ScaleY(21);
		TabOrder := 7;
	end;

	with Page do
	begin
		OnNextButtonClick := @Startup_NextButtonClick;
	end;

	if (StartupMode = 'auto') or (StartupMode = 'demand') then
		begin
			EnableCredentials(Page);
			RadioAtBoot.checked := true;
			DisableService.checked := false;
		end
	else
		begin
			DisableCredentials(Page);
			DisableService.checked := true;
		end;

	Result := Page.ID;
end;
