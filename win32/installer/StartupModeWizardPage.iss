// start startup selection screen...
var
	LabelUsername: TLabel;
	LabelPassword1: TLabel;
	LabelPassword2: TLabel;
	RadioAtLogin: TRadioButton;
	RadioAtBoot: TRadioButton;
	LabelAtBootDesc: TNewStaticText;
	EditUsername: TEdit;
	EditPassword1: TPasswordEdit;
	EditPassword2: TPasswordEdit;

function Startup_NextButtonClick(Page: TWizardPage): Boolean;
begin
	Result := true;

	if RadioAtBoot.checked then
		if CompareStr(EditPassword1.text, EditPassword2.text) <> 0 then
			begin
				MsgBox(CustomMessage('Startup_PasswordsDontMatch'), mbInformation, MB_OK);
				Result := false;
			end
	
		else if CompareStr(EditUsername.text, '') = 0 then
			begin
				Result := MsgBox(CustomMessage('Startup_CredentialsRequired'), mbConfirmation, MB_YESNO) = IDYES;
			end;

	if (Result and not RadioAtBoot.checked) then
		begin
			EditUsername.text := '';
			EditPassword1.text := '';
			EditPassword2.text := '';
		end;
end;

procedure EnableCredentials(Sender: TObject);
begin
	EditUsername.Color := clWindow;
	EditUsername.Enabled := True;
	EditPassword1.Color := clWindow;
	EditPassword1.Enabled := True;
	EditPassword2.Color := clWindow;
	EditPassword2.Enabled := True;
end;

procedure DisableCredentials(Sender: TObject);
begin
	EditUsername.Color := cl3DLight;
	EditUsername.Enabled := False;
	EditPassword1.Color := cl3DLight;
	EditPassword1.Enabled := False;
	EditPassword2.Color := cl3DLight;
	EditPassword2.Enabled := False;
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

	LabelUsername := TLabel.Create(Page);
	with LabelUsername do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_LabelUsername_Caption0}');
		Left := ScaleX(18);
		Top := ScaleY(114);
		Width := ScaleX(150);
		Height := ScaleY(13);
	end;
	
	LabelPassword1 := TLabel.Create(Page);
	with LabelPassword1 do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_LabelPassword1_Caption0}');
		Left := ScaleX(18);
		Top := ScaleY(144);
		Width := ScaleX(150);
		Height := ScaleY(13);
	end;
	
	LabelPassword2 := TLabel.Create(Page);
	with LabelPassword2 do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_LabelPassword2_Caption0}');
		Left := ScaleX(18);
		Top := ScaleY(168);
		Width := ScaleX(150);
		Height := ScaleY(13);
	end;
	
	RadioAtLogin := TRadioButton.Create(Page);
	with RadioAtLogin do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_RadioAtLogin_Caption0}');
		Left := ScaleX(0);
		Top := ScaleY(28);
		Width := ScaleX(409);
		Height := ScaleY(17);
		TabOrder := 3;
		TabStop := True;
		Checked := False;
		OnClick := @DisableCredentials;
	end;
	
	RadioAtBoot := TRadioButton.Create(Page);
	with RadioAtBoot do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_RadioAtBoot_Caption0}');
		Left := ScaleX(0);
		Top := ScaleY(55);
		Width := ScaleX(409);
		Height := ScaleY(17);
		TabOrder := 4;
		Checked := False;
		OnClick := @EnableCredentials;
	end;
	
	LabelAtBootDesc := TNewStaticText.Create(Page);
	with LabelAtBootDesc do
	begin
		Parent := Page.Surface;
		Caption := ExpandConstant('{cm:Startup_LabelAtBootDesc_Caption0}');
		Left := ScaleX(18);
		Top := ScaleY(76);
		Width := ScaleX(396);
		Height := ScaleY(27);
		WordWrap := True;
	end;
	
	EditUsername := TEdit.Create(Page);
	with EditUsername do
	begin
		Parent := Page.Surface;
		Left := ScaleX(168);
		Top := ScaleY(110);
		Width := ScaleX(217);
		Height := ScaleY(21);
		TabOrder := 6;
	end;
	
	EditPassword1 := TPasswordEdit.Create(Page);
	with EditPassword1 do
	begin
		Parent := Page.Surface;
		Left := ScaleX(168);
		Top := ScaleY(140);
		Width := ScaleX(217);
		Height := ScaleY(21);
		TabOrder := 7;
	end;
	
	EditPassword2 := TPasswordEdit.Create(Page);
	with EditPassword2 do
	begin
		Parent := Page.Surface;
		Left := ScaleX(168);
		Top := ScaleY(164);
		Width := ScaleX(217);
		Height := ScaleY(21);
		TabOrder := 8;
	end;

	with Page do
	begin
		OnNextButtonClick := @Startup_NextButtonClick;
	end;

	if (StartupMode = 'auto') or (StartupMode = 'demand') then
		begin
			EnableCredentials(Page);
			RadioAtBoot.checked := true;
			RadioAtLogin.checked := false;
			RadioAtLogin.TabOrder := 9;
		end
	else
		begin
			DisableCredentials(Page);
			RadioAtLogin.checked := true;
		end

	Result := Page.ID;
end;
