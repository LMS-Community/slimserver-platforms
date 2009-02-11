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
            this.btnStartStopService = new Microsoft.HomeServer.Controls.QButton();
            this.line1 = new Microsoft.HomeServer.Controls.Line();
            this.labelStatus = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.line2 = new Microsoft.HomeServer.Controls.Line();
            this.linkServerLog = new System.Windows.Forms.LinkLabel();
            this.linkScannerLog = new System.Windows.Forms.LinkLabel();
            this.labelSCStatus = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.line3 = new Microsoft.HomeServer.Controls.Line();
            this.linkSCSettings = new System.Windows.Forms.LinkLabel();
            this.linkSCWebUI = new System.Windows.Forms.LinkLabel();
            this.labelMusicFolder = new System.Windows.Forms.Label();
            this.line4 = new Microsoft.HomeServer.Controls.Line();
            this.linkMusicFolder = new System.Windows.Forms.LinkLabel();
            this.cbStartAtBoot = new System.Windows.Forms.CheckBox();
            this.SuspendLayout();
            // 
            // PollSCTimer
            // 
            this.PollSCTimer.Enabled = true;
            this.PollSCTimer.Interval = 1000;
            this.PollSCTimer.Tick += new System.EventHandler(this.PollSCTimer_Tick);
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
            this.btnStartStopService.Location = new System.Drawing.Point(95, 60);
            this.btnStartStopService.Margins = 0;
            this.btnStartStopService.MaximumSize = new System.Drawing.Size(360, 21);
            this.btnStartStopService.MinimumSize = new System.Drawing.Size(72, 21);
            this.btnStartStopService.Name = "btnStartStopService";
            this.btnStartStopService.Size = new System.Drawing.Size(118, 21);
            this.btnStartStopService.TabIndex = 0;
            this.btnStartStopService.Text = "Start SqueezeCenter";
            this.btnStartStopService.UseVisualStyleBackColor = true;
            this.btnStartStopService.Paint += new System.Windows.Forms.PaintEventHandler(this.btnStartStopService_Paint);
            this.btnStartStopService.Click += new System.EventHandler(this.btnStartStopService_Click);
            // 
            // line1
            // 
            this.line1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line1.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line1.Location = new System.Drawing.Point(95, 12);
            this.line1.Name = "line1";
            this.line1.Size = new System.Drawing.Size(280, 1);
            this.line1.TabIndex = 1;
            // 
            // labelStatus
            // 
            this.labelStatus.AutoSize = true;
            this.labelStatus.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelStatus.Location = new System.Drawing.Point(3, 5);
            this.labelStatus.Name = "labelStatus";
            this.labelStatus.Size = new System.Drawing.Size(90, 13);
            this.labelStatus.TabIndex = 2;
            this.labelStatus.Text = "Service Status";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(4, 129);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(58, 13);
            this.label1.TabIndex = 4;
            this.label1.Text = "Log Files";
            // 
            // line2
            // 
            this.line2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line2.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line2.Location = new System.Drawing.Point(96, 136);
            this.line2.Name = "line2";
            this.line2.Size = new System.Drawing.Size(280, 1);
            this.line2.TabIndex = 3;
            // 
            // linkServerLog
            // 
            this.linkServerLog.AutoSize = true;
            this.linkServerLog.Location = new System.Drawing.Point(92, 165);
            this.linkServerLog.Name = "linkServerLog";
            this.linkServerLog.Size = new System.Drawing.Size(53, 13);
            this.linkServerLog.TabIndex = 5;
            this.linkServerLog.TabStop = true;
            this.linkServerLog.Text = "server.log";
            this.linkServerLog.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkServerLog_LinkClicked);
            // 
            // linkScannerLog
            // 
            this.linkScannerLog.AutoSize = true;
            this.linkScannerLog.Location = new System.Drawing.Point(92, 188);
            this.linkScannerLog.Name = "linkScannerLog";
            this.linkScannerLog.Size = new System.Drawing.Size(62, 13);
            this.linkScannerLog.TabIndex = 6;
            this.linkScannerLog.TabStop = true;
            this.linkScannerLog.Text = "scanner.log";
            this.linkScannerLog.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkScannerLog_LinkClicked);
            // 
            // labelSCStatus
            // 
            this.labelSCStatus.AutoSize = true;
            this.labelSCStatus.Location = new System.Drawing.Point(92, 99);
            this.labelSCStatus.Name = "labelSCStatus";
            this.labelSCStatus.Size = new System.Drawing.Size(35, 13);
            this.labelSCStatus.TabIndex = 7;
            this.labelSCStatus.Text = "status";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(4, 227);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(178, 13);
            this.label2.TabIndex = 9;
            this.label2.Text = "SqueezeCenter User Interface";
            // 
            // line3
            // 
            this.line3.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line3.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line3.Location = new System.Drawing.Point(186, 234);
            this.line3.Name = "line3";
            this.line3.Size = new System.Drawing.Size(190, 1);
            this.line3.TabIndex = 8;
            // 
            // linkSCSettings
            // 
            this.linkSCSettings.AutoSize = true;
            this.linkSCSettings.Location = new System.Drawing.Point(92, 280);
            this.linkSCSettings.Name = "linkSCSettings";
            this.linkSCSettings.Size = new System.Drawing.Size(150, 13);
            this.linkSCSettings.TabIndex = 10;
            this.linkSCSettings.TabStop = true;
            this.linkSCSettings.Text = "Open SqueezeCenter Settings";
            this.linkSCSettings.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkSCSettings_LinkClicked);
            // 
            // linkSCWebUI
            // 
            this.linkSCWebUI.AutoSize = true;
            this.linkSCWebUI.Location = new System.Drawing.Point(92, 254);
            this.linkSCWebUI.Name = "linkSCWebUI";
            this.linkSCWebUI.Size = new System.Drawing.Size(18, 13);
            this.linkSCWebUI.TabIndex = 11;
            this.linkSCWebUI.TabStop = true;
            this.linkSCWebUI.Text = "url";
            this.linkSCWebUI.Paint += new System.Windows.Forms.PaintEventHandler(this.linkSCWebUI_Paint);
            this.linkSCWebUI.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkSCWebUI_LinkClicked);
            // 
            // labelMusicFolder
            // 
            this.labelMusicFolder.AutoSize = true;
            this.labelMusicFolder.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.labelMusicFolder.Location = new System.Drawing.Point(4, 311);
            this.labelMusicFolder.Name = "labelMusicFolder";
            this.labelMusicFolder.Size = new System.Drawing.Size(79, 13);
            this.labelMusicFolder.TabIndex = 13;
            this.labelMusicFolder.Text = "Music Folder";
            // 
            // line4
            // 
            this.line4.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line4.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line4.Location = new System.Drawing.Point(96, 318);
            this.line4.Name = "line4";
            this.line4.Size = new System.Drawing.Size(280, 1);
            this.line4.TabIndex = 12;
            // 
            // linkMusicFolder
            // 
            this.linkMusicFolder.AutoSize = true;
            this.linkMusicFolder.Location = new System.Drawing.Point(92, 340);
            this.linkMusicFolder.Name = "linkMusicFolder";
            this.linkMusicFolder.Size = new System.Drawing.Size(67, 13);
            this.linkMusicFolder.TabIndex = 14;
            this.linkMusicFolder.TabStop = true;
            this.linkMusicFolder.Text = "Music Folder";
            this.linkMusicFolder.Paint += new System.Windows.Forms.PaintEventHandler(this.linkMusicFolder_Paint);
            this.linkMusicFolder.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkMusicFolder_LinkClicked);
            // 
            // cbStartAtBoot
            // 
            this.cbStartAtBoot.AutoSize = true;
            this.cbStartAtBoot.Location = new System.Drawing.Point(96, 28);
            this.cbStartAtBoot.Name = "cbStartAtBoot";
            this.cbStartAtBoot.Size = new System.Drawing.Size(217, 17);
            this.cbStartAtBoot.TabIndex = 15;
            this.cbStartAtBoot.Text = "Start SqueezeCenter when system boots";
            this.cbStartAtBoot.UseVisualStyleBackColor = true;
            this.cbStartAtBoot.Click += new System.EventHandler(this.cbStartAtBoot_Click);
            // 
            // SettingsTabUserControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.cbStartAtBoot);
            this.Controls.Add(this.linkMusicFolder);
            this.Controls.Add(this.labelMusicFolder);
            this.Controls.Add(this.line4);
            this.Controls.Add(this.linkSCWebUI);
            this.Controls.Add(this.linkSCSettings);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.line3);
            this.Controls.Add(this.labelSCStatus);
            this.Controls.Add(this.linkScannerLog);
            this.Controls.Add(this.linkServerLog);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.line2);
            this.Controls.Add(this.labelStatus);
            this.Controls.Add(this.line1);
            this.Controls.Add(this.btnStartStopService);
            this.Name = "SettingsTabUserControl";
            this.Size = new System.Drawing.Size(390, 410);
            this.Load += new System.EventHandler(this.SettingsTabUserControl_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Timer PollSCTimer;
        private Microsoft.HomeServer.Controls.QButton btnStartStopService;
        private Microsoft.HomeServer.Controls.Line line1;
        private System.Windows.Forms.Label labelStatus;
        private System.Windows.Forms.Label label1;
        private Microsoft.HomeServer.Controls.Line line2;
        private System.Windows.Forms.LinkLabel linkServerLog;
        private System.Windows.Forms.LinkLabel linkScannerLog;
        private System.Windows.Forms.Label labelSCStatus;
        private System.Windows.Forms.Label label2;
        private Microsoft.HomeServer.Controls.Line line3;
        private System.Windows.Forms.LinkLabel linkSCSettings;
        private System.Windows.Forms.LinkLabel linkSCWebUI;
        private System.Windows.Forms.Label labelMusicFolder;
        private Microsoft.HomeServer.Controls.Line line4;
        private System.Windows.Forms.LinkLabel linkMusicFolder;
        private System.Windows.Forms.CheckBox cbStartAtBoot;

    }
}
