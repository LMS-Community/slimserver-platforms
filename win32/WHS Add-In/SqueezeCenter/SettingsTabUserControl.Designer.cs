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
            this.information = new System.Windows.Forms.TabPage();
            this.informationBrowser = new System.Windows.Forms.WebBrowser();
            this.maintenance = new System.Windows.Forms.TabPage();
            this.labelPleaseStopSC = new System.Windows.Forms.Label();
            this.btnCleanup = new Microsoft.HomeServer.Controls.QButton();
            this.ScanPollTimer = new System.Windows.Forms.Timer(this.components);
            this.musicFolderBrowser = new System.Windows.Forms.FolderBrowserDialog();
            this.jsonClient = new Microsoft.HomeServer.HomeServerConsoleTab.SqueezeCenter.JsonRpcClient();
            this.customTabControl1.SuspendLayout();
            this.settings.SuspendLayout();
            this.panel1.SuspendLayout();
            this.music.SuspendLayout();
            this.panel2.SuspendLayout();
            this.information.SuspendLayout();
            this.maintenance.SuspendLayout();
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
            this.checkUpdateBtn.TabIndex = 31;
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
            this.propertyPageSectionLabel4.Size = new System.Drawing.Size(108, 13);
            this.propertyPageSectionLabel4.TabIndex = 30;
            this.propertyPageSectionLabel4.Text = "Software Updates";
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
            this.propertyPageSectionLabel3.Size = new System.Drawing.Size(63, 13);
            this.propertyPageSectionLabel3.TabIndex = 28;
            this.propertyPageSectionLabel3.Text = "Advanced";
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
            this.linkScannerLog.TabIndex = 10;
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
            this.propertyPageSectionLabel2.Size = new System.Drawing.Size(51, 13);
            this.propertyPageSectionLabel2.TabIndex = 26;
            this.propertyPageSectionLabel2.Text = "Logging";
            this.propertyPageSectionLabel2.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // linkServerLog
            // 
            this.linkServerLog.AutoSize = true;
            this.linkServerLog.Location = new System.Drawing.Point(25, 129);
            this.linkServerLog.Name = "linkServerLog";
            this.linkServerLog.Size = new System.Drawing.Size(82, 13);
            this.linkServerLog.TabIndex = 9;
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
            this.propertyPageSectionLabel1.Size = new System.Drawing.Size(95, 13);
            this.propertyPageSectionLabel1.TabIndex = 24;
            this.propertyPageSectionLabel1.Text = "Startup options";
            this.propertyPageSectionLabel1.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // cbStartAtBoot
            // 
            this.cbStartAtBoot.AutoSize = true;
            this.cbStartAtBoot.BackColor = System.Drawing.Color.White;
            this.cbStartAtBoot.Location = new System.Drawing.Point(28, 31);
            this.cbStartAtBoot.Name = "cbStartAtBoot";
            this.cbStartAtBoot.Size = new System.Drawing.Size(217, 17);
            this.cbStartAtBoot.TabIndex = 18;
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
            this.btnStartStopService.TabIndex = 16;
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
            this.linkSCWebUI.TabIndex = 20;
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
            this.linkSCSettings.TabIndex = 19;
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
            this.linkPlaylistFolder.Location = new System.Drawing.Point(25, 132);
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
            this.linkMusicFolder.Location = new System.Drawing.Point(25, 66);
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
            this.label2.Location = new System.Drawing.Point(25, 92);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(71, 13);
            this.label2.TabIndex = 41;
            this.label2.Text = "Playlist Folder";
            // 
            // playlistFolderInput
            // 
            this.playlistFolderInput.Enabled = false;
            this.playlistFolderInput.Location = new System.Drawing.Point(28, 109);
            this.playlistFolderInput.Name = "playlistFolderInput";
            this.playlistFolderInput.Size = new System.Drawing.Size(230, 20);
            this.playlistFolderInput.TabIndex = 40;
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
            this.browsePlaylistFolderBtn.Location = new System.Drawing.Point(264, 108);
            this.browsePlaylistFolderBtn.Margins = 0;
            this.browsePlaylistFolderBtn.MaximumSize = new System.Drawing.Size(360, 21);
            this.browsePlaylistFolderBtn.MinimumSize = new System.Drawing.Size(72, 21);
            this.browsePlaylistFolderBtn.Name = "browsePlaylistFolderBtn";
            this.browsePlaylistFolderBtn.Size = new System.Drawing.Size(83, 21);
            this.browsePlaylistFolderBtn.TabIndex = 39;
            this.browsePlaylistFolderBtn.Text = "Browse";
            this.browsePlaylistFolderBtn.UseVisualStyleBackColor = true;
            this.browsePlaylistFolderBtn.Click += new System.EventHandler(this.browsePlaylistFolderBtn_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(25, 26);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(67, 13);
            this.label1.TabIndex = 38;
            this.label1.Text = "Music Folder";
            // 
            // musicFolderInput
            // 
            this.musicFolderInput.Enabled = false;
            this.musicFolderInput.Location = new System.Drawing.Point(28, 43);
            this.musicFolderInput.Name = "musicFolderInput";
            this.musicFolderInput.Size = new System.Drawing.Size(230, 20);
            this.musicFolderInput.TabIndex = 37;
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
            this.browseMusicFolderBtn.Location = new System.Drawing.Point(264, 42);
            this.browseMusicFolderBtn.Margins = 0;
            this.browseMusicFolderBtn.MaximumSize = new System.Drawing.Size(360, 21);
            this.browseMusicFolderBtn.MinimumSize = new System.Drawing.Size(72, 21);
            this.browseMusicFolderBtn.Name = "browseMusicFolderBtn";
            this.browseMusicFolderBtn.Size = new System.Drawing.Size(83, 21);
            this.browseMusicFolderBtn.TabIndex = 36;
            this.browseMusicFolderBtn.Text = "Browse";
            this.browseMusicFolderBtn.UseVisualStyleBackColor = true;
            this.browseMusicFolderBtn.Click += new System.EventHandler(this.browseMusicFolderBtn_Click);
            // 
            // progressTime
            // 
            this.progressTime.AutoSize = true;
            this.progressTime.BackColor = System.Drawing.Color.Transparent;
            this.progressTime.Location = new System.Drawing.Point(300, 251);
            this.progressTime.Name = "progressTime";
            this.progressTime.Size = new System.Drawing.Size(49, 13);
            this.progressTime.TabIndex = 35;
            this.progressTime.Text = "00:00:00";
            // 
            // scanProgressBar
            // 
            this.scanProgressBar.BackColor = System.Drawing.Color.WhiteSmoke;
            this.scanProgressBar.Location = new System.Drawing.Point(28, 250);
            this.scanProgressBar.Name = "scanProgressBar";
            this.scanProgressBar.Size = new System.Drawing.Size(266, 16);
            this.scanProgressBar.Style = System.Windows.Forms.ProgressBarStyle.Continuous;
            this.scanProgressBar.TabIndex = 34;
            // 
            // progressInformation
            // 
            this.progressInformation.AutoEllipsis = true;
            this.progressInformation.Location = new System.Drawing.Point(25, 270);
            this.progressInformation.Name = "progressInformation";
            this.progressInformation.Size = new System.Drawing.Size(322, 75);
            this.progressInformation.TabIndex = 33;
            this.progressInformation.Text = "progressInformation";
            // 
            // progressLabel
            // 
            this.progressLabel.AutoEllipsis = true;
            this.progressLabel.Location = new System.Drawing.Point(25, 234);
            this.progressLabel.Name = "progressLabel";
            this.progressLabel.Size = new System.Drawing.Size(322, 13);
            this.progressLabel.TabIndex = 32;
            this.progressLabel.Text = "progressLabel";
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
            this.rescanOptionsList.Location = new System.Drawing.Point(28, 200);
            this.rescanOptionsList.Name = "rescanOptionsList";
            this.rescanOptionsList.Size = new System.Drawing.Size(230, 21);
            this.rescanOptionsList.TabIndex = 31;
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
            this.rescanBtn.Location = new System.Drawing.Point(264, 199);
            this.rescanBtn.Margins = 0;
            this.rescanBtn.MaximumSize = new System.Drawing.Size(360, 21);
            this.rescanBtn.MinimumSize = new System.Drawing.Size(72, 21);
            this.rescanBtn.Name = "rescanBtn";
            this.rescanBtn.Size = new System.Drawing.Size(83, 21);
            this.rescanBtn.TabIndex = 30;
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
            this.propertyPageSectionLabel6.Location = new System.Drawing.Point(3, 176);
            this.propertyPageSectionLabel6.Name = "propertyPageSectionLabel6";
            this.propertyPageSectionLabel6.Size = new System.Drawing.Size(111, 13);
            this.propertyPageSectionLabel6.TabIndex = 28;
            this.propertyPageSectionLabel6.Text = "Music Scan Details";
            this.propertyPageSectionLabel6.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // line6
            // 
            this.line6.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line6.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line6.Location = new System.Drawing.Point(102, 185);
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
            this.propertyPageSectionLabel5.Size = new System.Drawing.Size(81, 13);
            this.propertyPageSectionLabel5.TabIndex = 26;
            this.propertyPageSectionLabel5.Text = "Music Source";
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
            this.maintenance.Controls.Add(this.labelPleaseStopSC);
            this.maintenance.Controls.Add(this.btnCleanup);
            this.maintenance.Location = new System.Drawing.Point(4, 22);
            this.maintenance.Name = "maintenance";
            this.maintenance.Padding = new System.Windows.Forms.Padding(3);
            this.maintenance.Size = new System.Drawing.Size(376, 378);
            this.maintenance.TabIndex = 2;
            this.maintenance.Text = "Maintenance";
            // 
            // labelPleaseStopSC
            // 
            this.labelPleaseStopSC.AutoSize = true;
            this.labelPleaseStopSC.Location = new System.Drawing.Point(12, 153);
            this.labelPleaseStopSC.Name = "labelPleaseStopSC";
            this.labelPleaseStopSC.Size = new System.Drawing.Size(244, 26);
            this.labelPleaseStopSC.TabIndex = 21;
            this.labelPleaseStopSC.Text = "You\'ll have to stop SqueezeCenter before you can\r\nrun the Cleanup Assistant";
            this.labelPleaseStopSC.Visible = false;
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
            this.btnCleanup.Location = new System.Drawing.Point(15, 122);
            this.btnCleanup.Margins = 0;
            this.btnCleanup.MaximumSize = new System.Drawing.Size(360, 21);
            this.btnCleanup.MinimumSize = new System.Drawing.Size(72, 21);
            this.btnCleanup.Name = "btnCleanup";
            this.btnCleanup.Size = new System.Drawing.Size(137, 21);
            this.btnCleanup.TabIndex = 20;
            this.btnCleanup.Text = "Run Cleanup Assistant...";
            this.btnCleanup.UseVisualStyleBackColor = true;
            this.btnCleanup.Click += new System.EventHandler(this.btnCleanup_Click);
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
            this.information.ResumeLayout(false);
            this.maintenance.ResumeLayout(false);
            this.maintenance.PerformLayout();
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

    }
}
