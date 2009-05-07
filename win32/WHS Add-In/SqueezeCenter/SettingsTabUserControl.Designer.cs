namespace Microsoft.HomeServer.HomeServerConsoleTab.SqueezeCenter
{
    partial class SettingsTabUserControl
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.PollSCTimer = new System.Windows.Forms.Timer(this.components);
            this.customTabControl1 = new Microsoft.HomeServer.Controls.CustomTabControl();
            this.settings = new System.Windows.Forms.TabPage();
            this.panel1 = new System.Windows.Forms.Panel();
            this.labelUpdate = new System.Windows.Forms.Label();
            this.checkUpdateBtn = new Microsoft.HomeServer.Controls.QButton();
            this.propertyPageSectionLabel4 = new Microsoft.HomeServer.Controls.PropertyPageSectionLabel();
            this.line4 = new Microsoft.HomeServer.Controls.Line();
            this.propertyPageSectionLabel3 = new Microsoft.HomeServer.Controls.PropertyPageSectionLabel();
            this.line3 = new Microsoft.HomeServer.Controls.Line();
            this.linkScannerLog = new System.Windows.Forms.LinkLabel();
            this.propertyPageSectionLabel2 = new Microsoft.HomeServer.Controls.PropertyPageSectionLabel();
            this.linkServerLog = new System.Windows.Forms.LinkLabel();
            this.line2 = new Microsoft.HomeServer.Controls.Line();
            this.propertyPageSectionLabel1 = new Microsoft.HomeServer.Controls.PropertyPageSectionLabel();
            this.cbStartAtBoot = new System.Windows.Forms.CheckBox();
            this.btnStartStopService = new Microsoft.HomeServer.Controls.QButton();
            this.line1 = new Microsoft.HomeServer.Controls.Line();
            this.labelSCStatus = new System.Windows.Forms.Label();
            this.linkSCWebUI = new System.Windows.Forms.LinkLabel();
            this.linkSCSettings = new System.Windows.Forms.LinkLabel();
            this.music = new System.Windows.Forms.TabPage();
            this.panel2 = new System.Windows.Forms.Panel();
            this.linkPlaylistFolder = new System.Windows.Forms.LinkLabel();
            this.linkMusicFolder = new System.Windows.Forms.LinkLabel();
            this.label2 = new System.Windows.Forms.Label();
            this.playlistFolderInput = new System.Windows.Forms.TextBox();
            this.browsePlaylistFolderBtn = new Microsoft.HomeServer.Controls.QButton();
            this.label1 = new System.Windows.Forms.Label();
            this.musicFolderInput = new System.Windows.Forms.TextBox();
            this.browseMusicFolderBtn = new Microsoft.HomeServer.Controls.QButton();
            this.progressTime = new System.Windows.Forms.Label();
            this.scanProgressBar = new System.Windows.Forms.ProgressBar();
            this.progressInformation = new System.Windows.Forms.Label();
            this.progressLabel = new System.Windows.Forms.Label();
            this.rescanOptionsList = new System.Windows.Forms.ComboBox();
            this.rescanBtn = new Microsoft.HomeServer.Controls.QButton();
            this.propertyPageSectionLabel6 = new Microsoft.HomeServer.Controls.PropertyPageSectionLabel();
            this.line6 = new Microsoft.HomeServer.Controls.Line();
            this.propertyPageSectionLabel5 = new Microsoft.HomeServer.Controls.PropertyPageSectionLabel();
            this.line5 = new Microsoft.HomeServer.Controls.Line();
            this.SqueezeNetwork = new System.Windows.Forms.TabPage();
            this.panel4 = new System.Windows.Forms.Panel();
            this.snPassword = new System.Windows.Forms.TextBox();
            this.snStatsOptions = new System.Windows.Forms.ComboBox();
            this.snSyncOptions = new System.Windows.Forms.ComboBox();
            this.linkPrivacyPolicy = new System.Windows.Forms.LinkLabel();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.linkForgotPassword = new System.Windows.Forms.LinkLabel();
            this.linkNeedSNAccount = new System.Windows.Forms.LinkLabel();
            this.snUsername = new System.Windows.Forms.TextBox();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.propertyPageSectionLabel9 = new Microsoft.HomeServer.Controls.PropertyPageSectionLabel();
            this.line9 = new Microsoft.HomeServer.Controls.Line();
            this.propertyPageSectionLabel8 = new Microsoft.HomeServer.Controls.PropertyPageSectionLabel();
            this.line8 = new Microsoft.HomeServer.Controls.Line();
            this.information = new System.Windows.Forms.TabPage();
            this.informationBrowser = new System.Windows.Forms.WebBrowser();
            this.maintenance = new System.Windows.Forms.TabPage();
            this.panel3 = new System.Windows.Forms.Panel();
            this.labelPleaseStopSC = new System.Windows.Forms.Label();
            this.cbCleanupAll = new System.Windows.Forms.CheckBox();
            this.btnCleanup = new Microsoft.HomeServer.Controls.QButton();
            this.cbCleanupCache = new System.Windows.Forms.CheckBox();
            this.cbCleanupPrefs = new System.Windows.Forms.CheckBox();
            this.propertyPageSectionLabel7 = new Microsoft.HomeServer.Controls.PropertyPageSectionLabel();
            this.line7 = new Microsoft.HomeServer.Controls.Line();
            this.ScanPollTimer = new System.Windows.Forms.Timer(this.components);
            this.musicFolderBrowser = new System.Windows.Forms.FolderBrowserDialog();
            this.jsonClient = new Microsoft.HomeServer.HomeServerConsoleTab.SqueezeCenter.JsonRpcClient();
            this.label7 = new System.Windows.Forms.Label();
            this.musicLibraryName = new System.Windows.Forms.TextBox();
            this.customTabControl1.SuspendLayout();
            this.settings.SuspendLayout();
            this.panel1.SuspendLayout();
            this.music.SuspendLayout();
            this.panel2.SuspendLayout();
            this.SqueezeNetwork.SuspendLayout();
            this.panel4.SuspendLayout();
            this.information.SuspendLayout();
            this.maintenance.SuspendLayout();
            this.panel3.SuspendLayout();
            this.SuspendLayout();
            // 
            // PollSCTimer
            // 
            this.PollSCTimer.Enabled = true;
            this.PollSCTimer.Interval = 1000;
            this.PollSCTimer.Tick += new System.EventHandler(this.PollSCTimer_Tick);
            // 
            // customTabControl1
            // 
            this.customTabControl1.Controls.Add(this.settings);
            this.customTabControl1.Controls.Add(this.music);
            this.customTabControl1.Controls.Add(this.SqueezeNetwork);
            this.customTabControl1.Controls.Add(this.information);
            this.customTabControl1.Controls.Add(this.maintenance);
            this.customTabControl1.DrawMode = System.Windows.Forms.TabDrawMode.OwnerDrawFixed;
            this.customTabControl1.HeaderColor = System.Drawing.Color.White;
            this.customTabControl1.HeaderFont = new System.Drawing.Font("Tahoma", 8F);
            this.customTabControl1.HeaderForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.customTabControl1.Location = new System.Drawing.Point(3, 3);
            this.customTabControl1.Name = "customTabControl1";
            this.customTabControl1.SelectedIndex = 0;
            this.customTabControl1.Size = new System.Drawing.Size(384, 404);
            this.customTabControl1.TabHeaderColor = System.Drawing.Color.FromArgb(((int)(((byte)(240)))), ((int)(((byte)(240)))), ((int)(((byte)(240)))));
            this.customTabControl1.TabIndex = 20;
            this.customTabControl1.Selected += new System.Windows.Forms.TabControlEventHandler(this.customTabControl1_Selected);
            // 
            // settings
            // 
            this.settings.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(240)))), ((int)(((byte)(240)))), ((int)(((byte)(240)))));
            this.settings.Controls.Add(this.panel1);
            this.settings.Location = new System.Drawing.Point(4, 22);
            this.settings.Name = "settings";
            this.settings.Padding = new System.Windows.Forms.Padding(3);
            this.settings.Size = new System.Drawing.Size(376, 378);
            this.settings.TabIndex = 0;
            this.settings.Text = "Settings";
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.White;
            this.panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel1.Controls.Add(this.labelUpdate);
            this.panel1.Controls.Add(this.checkUpdateBtn);
            this.panel1.Controls.Add(this.propertyPageSectionLabel4);
            this.panel1.Controls.Add(this.line4);
            this.panel1.Controls.Add(this.propertyPageSectionLabel3);
            this.panel1.Controls.Add(this.line3);
            this.panel1.Controls.Add(this.linkScannerLog);
            this.panel1.Controls.Add(this.propertyPageSectionLabel2);
            this.panel1.Controls.Add(this.linkServerLog);
            this.panel1.Controls.Add(this.line2);
            this.panel1.Controls.Add(this.propertyPageSectionLabel1);
            this.panel1.Controls.Add(this.cbStartAtBoot);
            this.panel1.Controls.Add(this.btnStartStopService);
            this.panel1.Controls.Add(this.line1);
            this.panel1.Controls.Add(this.labelSCStatus);
            this.panel1.Controls.Add(this.linkSCWebUI);
            this.panel1.Controls.Add(this.linkSCSettings);
            this.panel1.Location = new System.Drawing.Point(6, 6);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(364, 366);
            this.panel1.TabIndex = 22;
            // 
            // labelUpdate
            // 
            this.labelUpdate.Location = new System.Drawing.Point(25, 206);
            this.labelUpdate.Name = "labelUpdate";
            this.labelUpdate.Size = new System.Drawing.Size(332, 37);
            this.labelUpdate.TabIndex = 32;
            this.labelUpdate.Text = "labelUpdate";
            // 
            // checkUpdateBtn
            // 
            this.checkUpdateBtn.AutoSize = true;
            this.checkUpdateBtn.BackColor = System.Drawing.Color.Transparent;
            this.checkUpdateBtn.DisabledForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(153)))), ((int)(((byte)(153)))), ((int)(((byte)(153)))));
            this.checkUpdateBtn.FlatAppearance.BorderSize = 0;
            this.checkUpdateBtn.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.checkUpdateBtn.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.checkUpdateBtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.checkUpdateBtn.Font = new System.Drawing.Font("Tahoma", 8F);
            this.checkUpdateBtn.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.checkUpdateBtn.IsHovered = false;
            this.checkUpdateBtn.IsPressed = false;
            this.checkUpdateBtn.Location = new System.Drawing.Point(26, 246);
            this.checkUpdateBtn.Margins = 0;
            this.checkUpdateBtn.MaximumSize = new System.Drawing.Size(360, 21);
            this.checkUpdateBtn.MinimumSize = new System.Drawing.Size(72, 21);
            this.checkUpdateBtn.Name = "checkUpdateBtn";
            this.checkUpdateBtn.Size = new System.Drawing.Size(100, 21);
            this.checkUpdateBtn.TabIndex = 13;
            this.checkUpdateBtn.Text = "Check for update";
            this.checkUpdateBtn.UseVisualStyleBackColor = true;
            this.checkUpdateBtn.Paint += new System.Windows.Forms.PaintEventHandler(this.checkUpdateBtn_Paint);
            this.checkUpdateBtn.Click += new System.EventHandler(this.checkUpdateBtn_Click);
            // 
            // propertyPageSectionLabel4
            // 
            this.propertyPageSectionLabel4.AutoSize = true;
            this.propertyPageSectionLabel4.BackColor = System.Drawing.Color.Transparent;
            this.propertyPageSectionLabel4.Font = new System.Drawing.Font("Tahoma", 8F, System.Drawing.FontStyle.Bold);
            this.propertyPageSectionLabel4.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(64)))));
            this.propertyPageSectionLabel4.Location = new System.Drawing.Point(4, 183);
            this.propertyPageSectionLabel4.Name = "propertyPageSectionLabel4";
            this.propertyPageSectionLabel4.Size = new System.Drawing.Size(111, 13);
            this.propertyPageSectionLabel4.TabIndex = 30;
            this.propertyPageSectionLabel4.Text = "Software Updates ";
            this.propertyPageSectionLabel4.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // line4
            // 
            this.line4.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line4.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line4.Location = new System.Drawing.Point(103, 192);
            this.line4.Name = "line4";
            this.line4.Size = new System.Drawing.Size(255, 1);
            this.line4.TabIndex = 29;
            // 
            // propertyPageSectionLabel3
            // 
            this.propertyPageSectionLabel3.AutoSize = true;
            this.propertyPageSectionLabel3.BackColor = System.Drawing.Color.Transparent;
            this.propertyPageSectionLabel3.Font = new System.Drawing.Font("Tahoma", 8F, System.Drawing.FontStyle.Bold);
            this.propertyPageSectionLabel3.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(64)))));
            this.propertyPageSectionLabel3.Location = new System.Drawing.Point(4, 283);
            this.propertyPageSectionLabel3.Name = "propertyPageSectionLabel3";
            this.propertyPageSectionLabel3.Size = new System.Drawing.Size(66, 13);
            this.propertyPageSectionLabel3.TabIndex = 28;
            this.propertyPageSectionLabel3.Text = "Advanced ";
            this.propertyPageSectionLabel3.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // line3
            // 
            this.line3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line3.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line3.Location = new System.Drawing.Point(61, 292);
            this.line3.Name = "line3";
            this.line3.Size = new System.Drawing.Size(297, 1);
            this.line3.TabIndex = 27;
            // 
            // linkScannerLog
            // 
            this.linkScannerLog.AutoSize = true;
            this.linkScannerLog.Location = new System.Drawing.Point(25, 150);
            this.linkScannerLog.Name = "linkScannerLog";
            this.linkScannerLog.Size = new System.Drawing.Size(91, 13);
            this.linkScannerLog.TabIndex = 15;
            this.linkScannerLog.TabStop = true;
            this.linkScannerLog.Text = "Open scanner.log";
            this.linkScannerLog.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkScannerLog_LinkClicked);
            // 
            // propertyPageSectionLabel2
            // 
            this.propertyPageSectionLabel2.AutoSize = true;
            this.propertyPageSectionLabel2.BackColor = System.Drawing.Color.Transparent;
            this.propertyPageSectionLabel2.Font = new System.Drawing.Font("Tahoma", 8F, System.Drawing.FontStyle.Bold);
            this.propertyPageSectionLabel2.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(64)))));
            this.propertyPageSectionLabel2.Location = new System.Drawing.Point(3, 107);
            this.propertyPageSectionLabel2.Name = "propertyPageSectionLabel2";
            this.propertyPageSectionLabel2.Size = new System.Drawing.Size(54, 13);
            this.propertyPageSectionLabel2.TabIndex = 26;
            this.propertyPageSectionLabel2.Text = "Logging ";
            this.propertyPageSectionLabel2.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // linkServerLog
            // 
            this.linkServerLog.AutoSize = true;
            this.linkServerLog.Location = new System.Drawing.Point(25, 129);
            this.linkServerLog.Name = "linkServerLog";
            this.linkServerLog.Size = new System.Drawing.Size(82, 13);
            this.linkServerLog.TabIndex = 14;
            this.linkServerLog.TabStop = true;
            this.linkServerLog.Text = "Open server.log";
            this.linkServerLog.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkServerLog_LinkClicked);
            // 
            // line2
            // 
            this.line2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line2.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line2.Location = new System.Drawing.Point(50, 116);
            this.line2.Name = "line2";
            this.line2.Size = new System.Drawing.Size(307, 1);
            this.line2.TabIndex = 25;
            // 
            // propertyPageSectionLabel1
            // 
            this.propertyPageSectionLabel1.AutoSize = true;
            this.propertyPageSectionLabel1.BackColor = System.Drawing.Color.Transparent;
            this.propertyPageSectionLabel1.Font = new System.Drawing.Font("Tahoma", 8F, System.Drawing.FontStyle.Bold);
            this.propertyPageSectionLabel1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(64)))));
            this.propertyPageSectionLabel1.Location = new System.Drawing.Point(3, 6);
            this.propertyPageSectionLabel1.Name = "propertyPageSectionLabel1";
            this.propertyPageSectionLabel1.Size = new System.Drawing.Size(98, 13);
            this.propertyPageSectionLabel1.TabIndex = 24;
            this.propertyPageSectionLabel1.Text = "Startup options ";
            this.propertyPageSectionLabel1.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // cbStartAtBoot
            // 
            this.cbStartAtBoot.AutoSize = true;
            this.cbStartAtBoot.BackColor = System.Drawing.Color.White;
            this.cbStartAtBoot.Location = new System.Drawing.Point(28, 31);
            this.cbStartAtBoot.Name = "cbStartAtBoot";
            this.cbStartAtBoot.Size = new System.Drawing.Size(217, 17);
            this.cbStartAtBoot.TabIndex = 11;
            this.cbStartAtBoot.Text = "Start SqueezeCenter when system boots";
            this.cbStartAtBoot.UseVisualStyleBackColor = false;
            this.cbStartAtBoot.CheckedChanged += new System.EventHandler(this.EnableApply);
            // 
            // btnStartStopService
            // 
            this.btnStartStopService.AutoSize = true;
            this.btnStartStopService.BackColor = System.Drawing.Color.Transparent;
            this.btnStartStopService.DisabledForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(153)))), ((int)(((byte)(153)))), ((int)(((byte)(153)))));
            this.btnStartStopService.FlatAppearance.BorderSize = 0;
            this.btnStartStopService.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnStartStopService.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnStartStopService.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnStartStopService.Font = new System.Drawing.Font("Tahoma", 8F);
            this.btnStartStopService.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.btnStartStopService.IsHovered = false;
            this.btnStartStopService.IsPressed = false;
            this.btnStartStopService.Location = new System.Drawing.Point(28, 54);
            this.btnStartStopService.Margins = 0;
            this.btnStartStopService.MaximumSize = new System.Drawing.Size(360, 21);
            this.btnStartStopService.MinimumSize = new System.Drawing.Size(72, 21);
            this.btnStartStopService.Name = "btnStartStopService";
            this.btnStartStopService.Size = new System.Drawing.Size(118, 21);
            this.btnStartStopService.TabIndex = 12;
            this.btnStartStopService.Text = "Start SqueezeCenter";
            this.btnStartStopService.UseVisualStyleBackColor = true;
            this.btnStartStopService.Paint += new System.Windows.Forms.PaintEventHandler(this.btnStartStopService_Paint);
            this.btnStartStopService.Click += new System.EventHandler(this.btnStartStopService_Click);
            // 
            // line1
            // 
            this.line1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line1.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line1.Location = new System.Drawing.Point(97, 15);
            this.line1.Name = "line1";
            this.line1.Size = new System.Drawing.Size(260, 1);
            this.line1.TabIndex = 23;
            // 
            // labelSCStatus
            // 
            this.labelSCStatus.AutoSize = true;
            this.labelSCStatus.BackColor = System.Drawing.Color.White;
            this.labelSCStatus.Location = new System.Drawing.Point(25, 80);
            this.labelSCStatus.Name = "labelSCStatus";
            this.labelSCStatus.Size = new System.Drawing.Size(35, 13);
            this.labelSCStatus.TabIndex = 17;
            this.labelSCStatus.Text = "status";
            // 
            // linkSCWebUI
            // 
            this.linkSCWebUI.AutoSize = true;
            this.linkSCWebUI.BackColor = System.Drawing.Color.White;
            this.linkSCWebUI.Location = new System.Drawing.Point(25, 307);
            this.linkSCWebUI.Name = "linkSCWebUI";
            this.linkSCWebUI.Size = new System.Drawing.Size(18, 13);
            this.linkSCWebUI.TabIndex = 16;
            this.linkSCWebUI.TabStop = true;
            this.linkSCWebUI.Text = "url";
            this.linkSCWebUI.Paint += new System.Windows.Forms.PaintEventHandler(this.linkSCWebUI_Paint);
            this.linkSCWebUI.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkSCWebUI_LinkClicked);
            // 
            // linkSCSettings
            // 
            this.linkSCSettings.AutoSize = true;
            this.linkSCSettings.BackColor = System.Drawing.Color.White;
            this.linkSCSettings.Location = new System.Drawing.Point(25, 330);
            this.linkSCSettings.Name = "linkSCSettings";
            this.linkSCSettings.Size = new System.Drawing.Size(123, 13);
            this.linkSCSettings.TabIndex = 17;
            this.linkSCSettings.TabStop = true;
            this.linkSCSettings.Text = "Open advanced settings";
            this.linkSCSettings.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkSCSettings_LinkClicked);
            // 
            // music
            // 
            this.music.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(240)))), ((int)(((byte)(240)))), ((int)(((byte)(240)))));
            this.music.Controls.Add(this.panel2);
            this.music.Location = new System.Drawing.Point(4, 22);
            this.music.Name = "music";
            this.music.Padding = new System.Windows.Forms.Padding(3);
            this.music.Size = new System.Drawing.Size(376, 378);
            this.music.TabIndex = 1;
            this.music.Text = "Music Library";
            // 
            // panel2
            // 
            this.panel2.BackColor = System.Drawing.Color.White;
            this.panel2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel2.Controls.Add(this.musicLibraryName);
            this.panel2.Controls.Add(this.label7);
            this.panel2.Controls.Add(this.linkPlaylistFolder);
            this.panel2.Controls.Add(this.linkMusicFolder);
            this.panel2.Controls.Add(this.label2);
            this.panel2.Controls.Add(this.playlistFolderInput);
            this.panel2.Controls.Add(this.browsePlaylistFolderBtn);
            this.panel2.Controls.Add(this.label1);
            this.panel2.Controls.Add(this.musicFolderInput);
            this.panel2.Controls.Add(this.browseMusicFolderBtn);
            this.panel2.Controls.Add(this.progressTime);
            this.panel2.Controls.Add(this.scanProgressBar);
            this.panel2.Controls.Add(this.progressInformation);
            this.panel2.Controls.Add(this.progressLabel);
            this.panel2.Controls.Add(this.rescanOptionsList);
            this.panel2.Controls.Add(this.rescanBtn);
            this.panel2.Controls.Add(this.propertyPageSectionLabel6);
            this.panel2.Controls.Add(this.line6);
            this.panel2.Controls.Add(this.propertyPageSectionLabel5);
            this.panel2.Controls.Add(this.line5);
            this.panel2.Location = new System.Drawing.Point(6, 6);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(364, 366);
            this.panel2.TabIndex = 0;
            // 
            // linkPlaylistFolder
            // 
            this.linkPlaylistFolder.AutoSize = true;
            this.linkPlaylistFolder.BackColor = System.Drawing.Color.White;
            this.linkPlaylistFolder.Location = new System.Drawing.Point(25, 179);
            this.linkPlaylistFolder.Name = "linkPlaylistFolder";
            this.linkPlaylistFolder.Size = new System.Drawing.Size(148, 13);
            this.linkPlaylistFolder.TabIndex = 43;
            this.linkPlaylistFolder.TabStop = true;
            this.linkPlaylistFolder.Text = "Open playlist folder in Explorer";
            this.linkPlaylistFolder.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkPlaylistFolder_LinkClicked);
            // 
            // linkMusicFolder
            // 
            this.linkMusicFolder.AutoSize = true;
            this.linkMusicFolder.BackColor = System.Drawing.Color.White;
            this.linkMusicFolder.Location = new System.Drawing.Point(25, 114);
            this.linkMusicFolder.Name = "linkMusicFolder";
            this.linkMusicFolder.Size = new System.Drawing.Size(144, 13);
            this.linkMusicFolder.TabIndex = 42;
            this.linkMusicFolder.TabStop = true;
            this.linkMusicFolder.Text = "Open music folder in Explorer";
            this.linkMusicFolder.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkMusicFolder_LinkClicked);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(25, 139);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(71, 13);
            this.label2.TabIndex = 41;
            this.label2.Text = "Playlist Folder";
            // 
            // playlistFolderInput
            // 
            this.playlistFolderInput.Enabled = false;
            this.playlistFolderInput.Location = new System.Drawing.Point(28, 156);
            this.playlistFolderInput.Name = "playlistFolderInput";
            this.playlistFolderInput.Size = new System.Drawing.Size(230, 20);
            this.playlistFolderInput.TabIndex = 23;
            this.playlistFolderInput.TextChanged += new System.EventHandler(this.EnableApply);
            // 
            // browsePlaylistFolderBtn
            // 
            this.browsePlaylistFolderBtn.AutoSize = true;
            this.browsePlaylistFolderBtn.BackColor = System.Drawing.Color.Transparent;
            this.browsePlaylistFolderBtn.DisabledForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(153)))), ((int)(((byte)(153)))), ((int)(((byte)(153)))));
            this.browsePlaylistFolderBtn.Enabled = false;
            this.browsePlaylistFolderBtn.FlatAppearance.BorderSize = 0;
            this.browsePlaylistFolderBtn.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.browsePlaylistFolderBtn.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.browsePlaylistFolderBtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.browsePlaylistFolderBtn.Font = new System.Drawing.Font("Tahoma", 8F);
            this.browsePlaylistFolderBtn.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.browsePlaylistFolderBtn.IsHovered = false;
            this.browsePlaylistFolderBtn.IsPressed = false;
            this.browsePlaylistFolderBtn.Location = new System.Drawing.Point(264, 155);
            this.browsePlaylistFolderBtn.Margins = 0;
            this.browsePlaylistFolderBtn.MaximumSize = new System.Drawing.Size(360, 21);
            this.browsePlaylistFolderBtn.MinimumSize = new System.Drawing.Size(72, 21);
            this.browsePlaylistFolderBtn.Name = "browsePlaylistFolderBtn";
            this.browsePlaylistFolderBtn.Size = new System.Drawing.Size(83, 21);
            this.browsePlaylistFolderBtn.TabIndex = 24;
            this.browsePlaylistFolderBtn.Text = "Browse";
            this.browsePlaylistFolderBtn.UseVisualStyleBackColor = true;
            this.browsePlaylistFolderBtn.Click += new System.EventHandler(this.browsePlaylistFolderBtn_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(25, 74);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(67, 13);
            this.label1.TabIndex = 38;
            this.label1.Text = "Music Folder";
            // 
            // musicFolderInput
            // 
            this.musicFolderInput.Enabled = false;
            this.musicFolderInput.Location = new System.Drawing.Point(28, 91);
            this.musicFolderInput.Name = "musicFolderInput";
            this.musicFolderInput.Size = new System.Drawing.Size(230, 20);
            this.musicFolderInput.TabIndex = 21;
            this.musicFolderInput.TextChanged += new System.EventHandler(this.EnableApply);
            // 
            // browseMusicFolderBtn
            // 
            this.browseMusicFolderBtn.AutoSize = true;
            this.browseMusicFolderBtn.BackColor = System.Drawing.Color.Transparent;
            this.browseMusicFolderBtn.DisabledForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(153)))), ((int)(((byte)(153)))), ((int)(((byte)(153)))));
            this.browseMusicFolderBtn.Enabled = false;
            this.browseMusicFolderBtn.FlatAppearance.BorderSize = 0;
            this.browseMusicFolderBtn.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.browseMusicFolderBtn.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.browseMusicFolderBtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.browseMusicFolderBtn.Font = new System.Drawing.Font("Tahoma", 8F);
            this.browseMusicFolderBtn.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.browseMusicFolderBtn.IsHovered = false;
            this.browseMusicFolderBtn.IsPressed = false;
            this.browseMusicFolderBtn.Location = new System.Drawing.Point(264, 90);
            this.browseMusicFolderBtn.Margins = 0;
            this.browseMusicFolderBtn.MaximumSize = new System.Drawing.Size(360, 21);
            this.browseMusicFolderBtn.MinimumSize = new System.Drawing.Size(72, 21);
            this.browseMusicFolderBtn.Name = "browseMusicFolderBtn";
            this.browseMusicFolderBtn.Size = new System.Drawing.Size(83, 21);
            this.browseMusicFolderBtn.TabIndex = 22;
            this.browseMusicFolderBtn.Text = "Browse";
            this.browseMusicFolderBtn.UseVisualStyleBackColor = true;
            this.browseMusicFolderBtn.Click += new System.EventHandler(this.browseMusicFolderBtn_Click);
            // 
            // progressTime
            // 
            this.progressTime.AutoSize = true;
            this.progressTime.BackColor = System.Drawing.Color.Transparent;
            this.progressTime.Location = new System.Drawing.Point(300, 293);
            this.progressTime.Name = "progressTime";
            this.progressTime.Size = new System.Drawing.Size(49, 13);
            this.progressTime.TabIndex = 35;
            this.progressTime.Text = "00:00:00";
            // 
            // scanProgressBar
            // 
            this.scanProgressBar.BackColor = System.Drawing.Color.WhiteSmoke;
            this.scanProgressBar.Location = new System.Drawing.Point(28, 292);
            this.scanProgressBar.Name = "scanProgressBar";
            this.scanProgressBar.Size = new System.Drawing.Size(266, 16);
            this.scanProgressBar.Style = System.Windows.Forms.ProgressBarStyle.Continuous;
            this.scanProgressBar.TabIndex = 34;
            // 
            // progressInformation
            // 
            this.progressInformation.AutoEllipsis = true;
            this.progressInformation.Location = new System.Drawing.Point(25, 312);
            this.progressInformation.Name = "progressInformation";
            this.progressInformation.Size = new System.Drawing.Size(322, 47);
            this.progressInformation.TabIndex = 33;
            this.progressInformation.Text = "progressInformation";
            // 
            // progressLabel
            // 
            this.progressLabel.AutoEllipsis = true;
            this.progressLabel.Location = new System.Drawing.Point(25, 253);
            this.progressLabel.Name = "progressLabel";
            this.progressLabel.Size = new System.Drawing.Size(322, 36);
            this.progressLabel.TabIndex = 32;
            this.progressLabel.Text = "progressLabel";
            this.progressLabel.TextAlign = System.Drawing.ContentAlignment.BottomLeft;
            // 
            // rescanOptionsList
            // 
            this.rescanOptionsList.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.rescanOptionsList.Enabled = false;
            this.rescanOptionsList.FormattingEnabled = true;
            this.rescanOptionsList.Items.AddRange(new object[] {
            "Look for new and changed music",
            "Clear library and rescan everything",
            "Only rescan playlists"});
            this.rescanOptionsList.Location = new System.Drawing.Point(28, 229);
            this.rescanOptionsList.Name = "rescanOptionsList";
            this.rescanOptionsList.Size = new System.Drawing.Size(230, 21);
            this.rescanOptionsList.TabIndex = 25;
            // 
            // rescanBtn
            // 
            this.rescanBtn.AutoSize = true;
            this.rescanBtn.BackColor = System.Drawing.Color.Transparent;
            this.rescanBtn.DisabledForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(153)))), ((int)(((byte)(153)))), ((int)(((byte)(153)))));
            this.rescanBtn.Enabled = false;
            this.rescanBtn.FlatAppearance.BorderSize = 0;
            this.rescanBtn.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.rescanBtn.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.rescanBtn.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.rescanBtn.Font = new System.Drawing.Font("Tahoma", 8F);
            this.rescanBtn.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.rescanBtn.IsHovered = false;
            this.rescanBtn.IsPressed = false;
            this.rescanBtn.Location = new System.Drawing.Point(264, 228);
            this.rescanBtn.Margins = 0;
            this.rescanBtn.MaximumSize = new System.Drawing.Size(360, 21);
            this.rescanBtn.MinimumSize = new System.Drawing.Size(72, 21);
            this.rescanBtn.Name = "rescanBtn";
            this.rescanBtn.Size = new System.Drawing.Size(83, 21);
            this.rescanBtn.TabIndex = 26;
            this.rescanBtn.Text = "Rescan";
            this.rescanBtn.UseVisualStyleBackColor = true;
            this.rescanBtn.Click += new System.EventHandler(this.rescanBtn_Click);
            // 
            // propertyPageSectionLabel6
            // 
            this.propertyPageSectionLabel6.AutoSize = true;
            this.propertyPageSectionLabel6.BackColor = System.Drawing.Color.Transparent;
            this.propertyPageSectionLabel6.Font = new System.Drawing.Font("Tahoma", 8F, System.Drawing.FontStyle.Bold);
            this.propertyPageSectionLabel6.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(64)))));
            this.propertyPageSectionLabel6.Location = new System.Drawing.Point(3, 205);
            this.propertyPageSectionLabel6.Name = "propertyPageSectionLabel6";
            this.propertyPageSectionLabel6.Size = new System.Drawing.Size(114, 13);
            this.propertyPageSectionLabel6.TabIndex = 28;
            this.propertyPageSectionLabel6.Text = "Music Scan Details ";
            this.propertyPageSectionLabel6.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // line6
            // 
            this.line6.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line6.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line6.Location = new System.Drawing.Point(102, 214);
            this.line6.Name = "line6";
            this.line6.Size = new System.Drawing.Size(255, 1);
            this.line6.TabIndex = 27;
            // 
            // propertyPageSectionLabel5
            // 
            this.propertyPageSectionLabel5.AutoSize = true;
            this.propertyPageSectionLabel5.BackColor = System.Drawing.Color.Transparent;
            this.propertyPageSectionLabel5.Font = new System.Drawing.Font("Tahoma", 8F, System.Drawing.FontStyle.Bold);
            this.propertyPageSectionLabel5.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(64)))));
            this.propertyPageSectionLabel5.Location = new System.Drawing.Point(3, 6);
            this.propertyPageSectionLabel5.Name = "propertyPageSectionLabel5";
            this.propertyPageSectionLabel5.Size = new System.Drawing.Size(84, 13);
            this.propertyPageSectionLabel5.TabIndex = 26;
            this.propertyPageSectionLabel5.Text = "Music Source ";
            this.propertyPageSectionLabel5.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // line5
            // 
            this.line5.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line5.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line5.Location = new System.Drawing.Point(82, 15);
            this.line5.Name = "line5";
            this.line5.Size = new System.Drawing.Size(275, 1);
            this.line5.TabIndex = 25;
            // 
            // SqueezeNetwork
            // 
            this.SqueezeNetwork.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(240)))), ((int)(((byte)(240)))), ((int)(((byte)(240)))));
            this.SqueezeNetwork.Controls.Add(this.panel4);
            this.SqueezeNetwork.Location = new System.Drawing.Point(4, 22);
            this.SqueezeNetwork.Name = "SqueezeNetwork";
            this.SqueezeNetwork.Padding = new System.Windows.Forms.Padding(3);
            this.SqueezeNetwork.Size = new System.Drawing.Size(376, 378);
            this.SqueezeNetwork.TabIndex = 4;
            this.SqueezeNetwork.Text = "SqueezeNetwork";
            // 
            // panel4
            // 
            this.panel4.BackColor = System.Drawing.Color.White;
            this.panel4.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel4.Controls.Add(this.snPassword);
            this.panel4.Controls.Add(this.snStatsOptions);
            this.panel4.Controls.Add(this.snSyncOptions);
            this.panel4.Controls.Add(this.linkPrivacyPolicy);
            this.panel4.Controls.Add(this.label6);
            this.panel4.Controls.Add(this.label5);
            this.panel4.Controls.Add(this.linkForgotPassword);
            this.panel4.Controls.Add(this.linkNeedSNAccount);
            this.panel4.Controls.Add(this.snUsername);
            this.panel4.Controls.Add(this.label4);
            this.panel4.Controls.Add(this.label3);
            this.panel4.Controls.Add(this.propertyPageSectionLabel9);
            this.panel4.Controls.Add(this.line9);
            this.panel4.Controls.Add(this.propertyPageSectionLabel8);
            this.panel4.Controls.Add(this.line8);
            this.panel4.Location = new System.Drawing.Point(6, 6);
            this.panel4.Name = "panel4";
            this.panel4.Size = new System.Drawing.Size(364, 366);
            this.panel4.TabIndex = 0;
            // 
            // snPassword
            // 
            this.snPassword.Location = new System.Drawing.Point(106, 53);
            this.snPassword.Name = "snPassword";
            this.snPassword.PasswordChar = '*';
            this.snPassword.Size = new System.Drawing.Size(181, 20);
            this.snPassword.TabIndex = 35;
            this.snPassword.TextChanged += new System.EventHandler(this.EnableApply);
            // 
            // snStatsOptions
            // 
            this.snStatsOptions.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.snStatsOptions.Enabled = false;
            this.snStatsOptions.FormattingEnabled = true;
            this.snStatsOptions.Items.AddRange(new object[] {
            "Enabled, keep player settings in sync.",
            "Disabled, do not keep player settings in sync."});
            this.snStatsOptions.Location = new System.Drawing.Point(28, 312);
            this.snStatsOptions.Name = "snStatsOptions";
            this.snStatsOptions.Size = new System.Drawing.Size(230, 21);
            this.snStatsOptions.TabIndex = 37;
            this.snStatsOptions.SelectedIndexChanged += new System.EventHandler(this.EnableApply);
            // 
            // snSyncOptions
            // 
            this.snSyncOptions.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.snSyncOptions.Enabled = false;
            this.snSyncOptions.FormattingEnabled = true;
            this.snSyncOptions.Items.AddRange(new object[] {
            "Enabled, keep player settings in sync.",
            "Disabled, do not keep player settings in sync."});
            this.snSyncOptions.Location = new System.Drawing.Point(28, 210);
            this.snSyncOptions.Name = "snSyncOptions";
            this.snSyncOptions.Size = new System.Drawing.Size(230, 21);
            this.snSyncOptions.TabIndex = 36;
            this.snSyncOptions.SelectedIndexChanged += new System.EventHandler(this.EnableApply);
            // 
            // linkPrivacyPolicy
            // 
            this.linkPrivacyPolicy.Location = new System.Drawing.Point(26, 279);
            this.linkPrivacyPolicy.Name = "linkPrivacyPolicy";
            this.linkPrivacyPolicy.Size = new System.Drawing.Size(331, 30);
            this.linkPrivacyPolicy.TabIndex = 47;
            this.linkPrivacyPolicy.TabStop = true;
            this.linkPrivacyPolicy.Text = "This information is collected in aggregate and is protected under our privacy pol" +
                "icy.";
            this.linkPrivacyPolicy.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkPrivacyPolicy_LinkClicked);
            // 
            // label6
            // 
            this.label6.Location = new System.Drawing.Point(25, 251);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(332, 30);
            this.label6.TabIndex = 46;
            this.label6.Text = "Help improve SqueezeNetwork by reporting statistics on internet radio and music s" +
                "ervice listening.";
            // 
            // label5
            // 
            this.label5.Location = new System.Drawing.Point(25, 164);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(323, 43);
            this.label5.TabIndex = 45;
            this.label5.Text = "By default, many player settings are synchronized between SqueezeCenter and Squee" +
                "zeNetwork. To disable this feature, select the Disabled option below.";
            // 
            // linkForgotPassword
            // 
            this.linkForgotPassword.AutoSize = true;
            this.linkForgotPassword.BackColor = System.Drawing.Color.White;
            this.linkForgotPassword.Location = new System.Drawing.Point(25, 108);
            this.linkForgotPassword.Name = "linkForgotPassword";
            this.linkForgotPassword.Size = new System.Drawing.Size(104, 13);
            this.linkForgotPassword.TabIndex = 44;
            this.linkForgotPassword.TabStop = true;
            this.linkForgotPassword.Text = "I forgot my password";
            this.linkForgotPassword.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkForgotPassword_LinkClicked);
            // 
            // linkNeedSNAccount
            // 
            this.linkNeedSNAccount.AutoSize = true;
            this.linkNeedSNAccount.BackColor = System.Drawing.Color.White;
            this.linkNeedSNAccount.Location = new System.Drawing.Point(25, 86);
            this.linkNeedSNAccount.Name = "linkNeedSNAccount";
            this.linkNeedSNAccount.Size = new System.Drawing.Size(218, 13);
            this.linkNeedSNAccount.TabIndex = 43;
            this.linkNeedSNAccount.TabStop = true;
            this.linkNeedSNAccount.Text = "I need to create a SqueezeNetwork account";
            this.linkNeedSNAccount.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkNeedSNAccount_LinkClicked);
            // 
            // snUsername
            // 
            this.snUsername.Location = new System.Drawing.Point(106, 27);
            this.snUsername.Name = "snUsername";
            this.snUsername.Size = new System.Drawing.Size(181, 20);
            this.snUsername.TabIndex = 34;
            this.snUsername.TextChanged += new System.EventHandler(this.EnableApply);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(25, 56);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(56, 13);
            this.label4.TabIndex = 32;
            this.label4.Text = "Password:";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(25, 30);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(76, 13);
            this.label3.TabIndex = 31;
            this.label3.Text = "Email Address:";
            // 
            // propertyPageSectionLabel9
            // 
            this.propertyPageSectionLabel9.AutoSize = true;
            this.propertyPageSectionLabel9.BackColor = System.Drawing.Color.Transparent;
            this.propertyPageSectionLabel9.Font = new System.Drawing.Font("Tahoma", 8F, System.Drawing.FontStyle.Bold);
            this.propertyPageSectionLabel9.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(64)))));
            this.propertyPageSectionLabel9.Location = new System.Drawing.Point(3, 6);
            this.propertyPageSectionLabel9.Name = "propertyPageSectionLabel9";
            this.propertyPageSectionLabel9.Size = new System.Drawing.Size(157, 13);
            this.propertyPageSectionLabel9.TabIndex = 30;
            this.propertyPageSectionLabel9.Text = "SqueezeNetwork Acccount";
            this.propertyPageSectionLabel9.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // line9
            // 
            this.line9.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line9.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line9.Location = new System.Drawing.Point(82, 15);
            this.line9.Name = "line9";
            this.line9.Size = new System.Drawing.Size(275, 1);
            this.line9.TabIndex = 29;
            // 
            // propertyPageSectionLabel8
            // 
            this.propertyPageSectionLabel8.AutoSize = true;
            this.propertyPageSectionLabel8.BackColor = System.Drawing.Color.Transparent;
            this.propertyPageSectionLabel8.Font = new System.Drawing.Font("Tahoma", 8F, System.Drawing.FontStyle.Bold);
            this.propertyPageSectionLabel8.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(64)))));
            this.propertyPageSectionLabel8.Location = new System.Drawing.Point(3, 142);
            this.propertyPageSectionLabel8.Name = "propertyPageSectionLabel8";
            this.propertyPageSectionLabel8.Size = new System.Drawing.Size(170, 13);
            this.propertyPageSectionLabel8.TabIndex = 28;
            this.propertyPageSectionLabel8.Text = "SqueezeNetwork Integration";
            this.propertyPageSectionLabel8.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // line8
            // 
            this.line8.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line8.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line8.Location = new System.Drawing.Point(82, 151);
            this.line8.Name = "line8";
            this.line8.Size = new System.Drawing.Size(275, 1);
            this.line8.TabIndex = 27;
            // 
            // information
            // 
            this.information.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(240)))), ((int)(((byte)(240)))), ((int)(((byte)(240)))));
            this.information.Controls.Add(this.informationBrowser);
            this.information.Location = new System.Drawing.Point(4, 22);
            this.information.Name = "information";
            this.information.Padding = new System.Windows.Forms.Padding(3);
            this.information.Size = new System.Drawing.Size(376, 378);
            this.information.TabIndex = 3;
            this.information.Text = "Information";
            // 
            // informationBrowser
            // 
            this.informationBrowser.AllowNavigation = false;
            this.informationBrowser.AllowWebBrowserDrop = false;
            this.informationBrowser.Dock = System.Windows.Forms.DockStyle.Fill;
            this.informationBrowser.Location = new System.Drawing.Point(3, 3);
            this.informationBrowser.MinimumSize = new System.Drawing.Size(20, 20);
            this.informationBrowser.Name = "informationBrowser";
            this.informationBrowser.ScriptErrorsSuppressed = true;
            this.informationBrowser.Size = new System.Drawing.Size(370, 372);
            this.informationBrowser.TabIndex = 0;
            // 
            // maintenance
            // 
            this.maintenance.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(240)))), ((int)(((byte)(240)))), ((int)(((byte)(240)))));
            this.maintenance.Controls.Add(this.panel3);
            this.maintenance.Location = new System.Drawing.Point(4, 22);
            this.maintenance.Name = "maintenance";
            this.maintenance.Padding = new System.Windows.Forms.Padding(3);
            this.maintenance.Size = new System.Drawing.Size(376, 378);
            this.maintenance.TabIndex = 2;
            this.maintenance.Text = "Maintenance";
            // 
            // panel3
            // 
            this.panel3.BackColor = System.Drawing.Color.White;
            this.panel3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel3.Controls.Add(this.labelPleaseStopSC);
            this.panel3.Controls.Add(this.cbCleanupAll);
            this.panel3.Controls.Add(this.btnCleanup);
            this.panel3.Controls.Add(this.cbCleanupCache);
            this.panel3.Controls.Add(this.cbCleanupPrefs);
            this.panel3.Controls.Add(this.propertyPageSectionLabel7);
            this.panel3.Controls.Add(this.line7);
            this.panel3.Location = new System.Drawing.Point(6, 6);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(364, 366);
            this.panel3.TabIndex = 23;
            // 
            // labelPleaseStopSC
            // 
            this.labelPleaseStopSC.BackColor = System.Drawing.Color.White;
            this.labelPleaseStopSC.Location = new System.Drawing.Point(22, 141);
            this.labelPleaseStopSC.Name = "labelPleaseStopSC";
            this.labelPleaseStopSC.Size = new System.Drawing.Size(335, 63);
            this.labelPleaseStopSC.TabIndex = 21;
            this.labelPleaseStopSC.Text = "You\'ll have to stop SqueezeCenter before you can run the Cleanup Assistant";
            this.labelPleaseStopSC.Visible = false;
            // 
            // cbCleanupAll
            // 
            this.cbCleanupAll.AutoSize = true;
            this.cbCleanupAll.Location = new System.Drawing.Point(25, 87);
            this.cbCleanupAll.Name = "cbCleanupAll";
            this.cbCleanupAll.Size = new System.Drawing.Size(317, 17);
            this.cbCleanupAll.TabIndex = 31;
            this.cbCleanupAll.Text = "Wipe\'em all - don\'t do this unless you know what you\'re doing!";
            this.cbCleanupAll.UseVisualStyleBackColor = true;
            // 
            // btnCleanup
            // 
            this.btnCleanup.AutoSize = true;
            this.btnCleanup.BackColor = System.Drawing.Color.Transparent;
            this.btnCleanup.DisabledForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(153)))), ((int)(((byte)(153)))), ((int)(((byte)(153)))));
            this.btnCleanup.FlatAppearance.BorderSize = 0;
            this.btnCleanup.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent;
            this.btnCleanup.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent;
            this.btnCleanup.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnCleanup.Font = new System.Drawing.Font("Tahoma", 8F);
            this.btnCleanup.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))));
            this.btnCleanup.IsHovered = false;
            this.btnCleanup.IsPressed = false;
            this.btnCleanup.Location = new System.Drawing.Point(25, 110);
            this.btnCleanup.Margins = 0;
            this.btnCleanup.MaximumSize = new System.Drawing.Size(360, 21);
            this.btnCleanup.MinimumSize = new System.Drawing.Size(72, 21);
            this.btnCleanup.Name = "btnCleanup";
            this.btnCleanup.Size = new System.Drawing.Size(137, 21);
            this.btnCleanup.TabIndex = 40;
            this.btnCleanup.Text = "Run Cleanup Assistant...";
            this.btnCleanup.UseVisualStyleBackColor = true;
            this.btnCleanup.Click += new System.EventHandler(this.btnCleanup_Click);
            // 
            // cbCleanupCache
            // 
            this.cbCleanupCache.AutoSize = true;
            this.cbCleanupCache.Location = new System.Drawing.Point(25, 64);
            this.cbCleanupCache.Name = "cbCleanupCache";
            this.cbCleanupCache.Size = new System.Drawing.Size(335, 17);
            this.cbCleanupCache.TabIndex = 30;
            this.cbCleanupCache.Text = "Clean cache folder, including music database, artwork cache etc.";
            this.cbCleanupCache.UseVisualStyleBackColor = true;
            // 
            // cbCleanupPrefs
            // 
            this.cbCleanupPrefs.AutoSize = true;
            this.cbCleanupPrefs.Location = new System.Drawing.Point(25, 26);
            this.cbCleanupPrefs.Name = "cbCleanupPrefs";
            this.cbCleanupPrefs.Size = new System.Drawing.Size(132, 17);
            this.cbCleanupPrefs.TabIndex = 29;
            this.cbCleanupPrefs.Text = "Delete preference files";
            this.cbCleanupPrefs.UseVisualStyleBackColor = true;
            // 
            // propertyPageSectionLabel7
            // 
            this.propertyPageSectionLabel7.AutoSize = true;
            this.propertyPageSectionLabel7.BackColor = System.Drawing.Color.Transparent;
            this.propertyPageSectionLabel7.Font = new System.Drawing.Font("Tahoma", 8F, System.Drawing.FontStyle.Bold);
            this.propertyPageSectionLabel7.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(64)))));
            this.propertyPageSectionLabel7.Location = new System.Drawing.Point(3, 6);
            this.propertyPageSectionLabel7.Name = "propertyPageSectionLabel7";
            this.propertyPageSectionLabel7.Size = new System.Drawing.Size(303, 13);
            this.propertyPageSectionLabel7.TabIndex = 28;
            this.propertyPageSectionLabel7.Text = "Please select the files and folders you\'d like to reset ";
            this.propertyPageSectionLabel7.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // line7
            // 
            this.line7.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line7.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line7.Location = new System.Drawing.Point(82, 15);
            this.line7.Name = "line7";
            this.line7.Size = new System.Drawing.Size(275, 1);
            this.line7.TabIndex = 27;
            // 
            // ScanPollTimer
            // 
            this.ScanPollTimer.Enabled = true;
            this.ScanPollTimer.Interval = 2300;
            this.ScanPollTimer.Tick += new System.EventHandler(this.ScanPollTimer_Tick);
            // 
            // musicFolderBrowser
            // 
            this.musicFolderBrowser.RootFolder = System.Environment.SpecialFolder.MyComputer;
            // 
            // jsonClient
            // 
            this.jsonClient.Credentials = null;
            this.jsonClient.UseDefaultCredentials = false;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(25, 29);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(100, 13);
            this.label7.TabIndex = 44;
            this.label7.Text = "Music Library Name";
            // 
            // musicLibraryName
            // 
            this.musicLibraryName.Location = new System.Drawing.Point(28, 45);
            this.musicLibraryName.Name = "musicLibraryName";
            this.musicLibraryName.Size = new System.Drawing.Size(230, 20);
            this.musicLibraryName.TabIndex = 45;
            // 
            // SettingsTabUserControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.customTabControl1);
            this.Name = "SettingsTabUserControl";
            this.Size = new System.Drawing.Size(390, 410);
            this.Load += new System.EventHandler(this.SettingsTabUserControl_Load);
            this.customTabControl1.ResumeLayout(false);
            this.settings.ResumeLayout(false);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.music.ResumeLayout(false);
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            this.SqueezeNetwork.ResumeLayout(false);
            this.panel4.ResumeLayout(false);
            this.panel4.PerformLayout();
            this.information.ResumeLayout(false);
            this.maintenance.ResumeLayout(false);
            this.panel3.ResumeLayout(false);
            this.panel3.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Timer PollSCTimer;
        private Microsoft.HomeServer.Controls.CustomTabControl customTabControl1;
        private System.Windows.Forms.TabPage settings;
        private System.Windows.Forms.TabPage music;
        private System.Windows.Forms.TabPage maintenance;
        private System.Windows.Forms.LinkLabel linkSCWebUI;
        private System.Windows.Forms.LinkLabel linkSCSettings;
        private System.Windows.Forms.Label labelPleaseStopSC;
        private Microsoft.HomeServer.Controls.QButton btnCleanup;
        private System.Windows.Forms.TabPage information;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.LinkLabel linkScannerLog;
        private System.Windows.Forms.LinkLabel linkServerLog;
        private Microsoft.HomeServer.Controls.PropertyPageSectionLabel propertyPageSectionLabel1;
        private System.Windows.Forms.CheckBox cbStartAtBoot;
        private Microsoft.HomeServer.Controls.QButton btnStartStopService;
        private Microsoft.HomeServer.Controls.Line line1;
        private System.Windows.Forms.Label labelSCStatus;
        private Microsoft.HomeServer.Controls.PropertyPageSectionLabel propertyPageSectionLabel2;
        private Microsoft.HomeServer.Controls.Line line2;
        private Microsoft.HomeServer.Controls.PropertyPageSectionLabel propertyPageSectionLabel3;
        private Microsoft.HomeServer.Controls.Line line3;
        private Microsoft.HomeServer.Controls.PropertyPageSectionLabel propertyPageSectionLabel4;
        private Microsoft.HomeServer.Controls.Line line4;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.WebBrowser informationBrowser;
        private System.Windows.Forms.Timer ScanPollTimer;
        private Microsoft.HomeServer.Controls.PropertyPageSectionLabel propertyPageSectionLabel5;
        private Microsoft.HomeServer.Controls.Line line5;
        private Microsoft.HomeServer.Controls.PropertyPageSectionLabel propertyPageSectionLabel6;
        private Microsoft.HomeServer.Controls.Line line6;
        private Microsoft.HomeServer.Controls.QButton rescanBtn;
        private System.Windows.Forms.ComboBox rescanOptionsList;
        private System.Windows.Forms.Label progressLabel;
        private System.Windows.Forms.Label progressInformation;
        private System.Windows.Forms.ProgressBar scanProgressBar;
        private System.Windows.Forms.Label progressTime;
        private System.Windows.Forms.TextBox musicFolderInput;
        private Microsoft.HomeServer.Controls.QButton browseMusicFolderBtn;
        private System.Windows.Forms.FolderBrowserDialog musicFolderBrowser;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox playlistFolderInput;
        private Microsoft.HomeServer.Controls.QButton browsePlaylistFolderBtn;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.LinkLabel linkMusicFolder;
        private System.Windows.Forms.LinkLabel linkPlaylistFolder;
        private JsonRpcClient jsonClient;
        private Microsoft.HomeServer.Controls.QButton checkUpdateBtn;
        private System.Windows.Forms.Label labelUpdate;
        private System.Windows.Forms.Panel panel3;
        private Microsoft.HomeServer.Controls.PropertyPageSectionLabel propertyPageSectionLabel7;
        private Microsoft.HomeServer.Controls.Line line7;
        private System.Windows.Forms.CheckBox cbCleanupCache;
        private System.Windows.Forms.CheckBox cbCleanupPrefs;
        private System.Windows.Forms.CheckBox cbCleanupAll;
        private System.Windows.Forms.TabPage SqueezeNetwork;
        private System.Windows.Forms.Panel panel4;
        private Microsoft.HomeServer.Controls.PropertyPageSectionLabel propertyPageSectionLabel9;
        private Microsoft.HomeServer.Controls.Line line9;
        private Microsoft.HomeServer.Controls.PropertyPageSectionLabel propertyPageSectionLabel8;
        private Microsoft.HomeServer.Controls.Line line8;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox snUsername;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.LinkLabel linkNeedSNAccount;
        private System.Windows.Forms.LinkLabel linkForgotPassword;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.LinkLabel linkPrivacyPolicy;
        private System.Windows.Forms.ComboBox snSyncOptions;
        private System.Windows.Forms.ComboBox snStatsOptions;
        private System.Windows.Forms.TextBox snPassword;
        private System.Windows.Forms.TextBox musicLibraryName;
        private System.Windows.Forms.Label label7;

    }
}
