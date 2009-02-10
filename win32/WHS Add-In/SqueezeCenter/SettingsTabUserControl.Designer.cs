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
            this.btnStartStopService.Location = new System.Drawing.Point(132, 67);
            this.btnStartStopService.Margins = 0;
            this.btnStartStopService.MaximumSize = new System.Drawing.Size(360, 21);
            this.btnStartStopService.MinimumSize = new System.Drawing.Size(72, 21);
            this.btnStartStopService.Name = "btnStartStopService";
            this.btnStartStopService.Size = new System.Drawing.Size(72, 21);
            this.btnStartStopService.TabIndex = 0;
            this.btnStartStopService.Text = "Start";
            this.btnStartStopService.UseVisualStyleBackColor = true;
            this.btnStartStopService.Paint += new System.Windows.Forms.PaintEventHandler(this.btnStartStopService_Paint);
            this.btnStartStopService.Click += new System.EventHandler(this.btnStartStopService_Click);
            // 
            // line1
            // 
            this.line1.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line1.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line1.Location = new System.Drawing.Point(95, 24);
            this.line1.Name = "line1";
            this.line1.Size = new System.Drawing.Size(280, 1);
            this.line1.TabIndex = 1;
            // 
            // labelStatus
            // 
            this.labelStatus.AutoSize = true;
            this.labelStatus.Location = new System.Drawing.Point(13, 17);
            this.labelStatus.Name = "labelStatus";
            this.labelStatus.Size = new System.Drawing.Size(76, 13);
            this.labelStatus.TabIndex = 2;
            this.labelStatus.Text = "Service Status";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(14, 141);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(49, 13);
            this.label1.TabIndex = 4;
            this.label1.Text = "Log Files";
            // 
            // line2
            // 
            this.line2.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line2.Color = System.Drawing.Color.FromArgb(((int)(((byte)(190)))), ((int)(((byte)(213)))), ((int)(((byte)(232)))));
            this.line2.Location = new System.Drawing.Point(96, 148);
            this.line2.Name = "line2";
            this.line2.Size = new System.Drawing.Size(280, 1);
            this.line2.TabIndex = 3;
            // 
            // linkServerLog
            // 
            this.linkServerLog.AutoSize = true;
            this.linkServerLog.Location = new System.Drawing.Point(129, 176);
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
            this.linkScannerLog.Location = new System.Drawing.Point(129, 199);
            this.linkScannerLog.Name = "linkScannerLog";
            this.linkScannerLog.Size = new System.Drawing.Size(62, 13);
            this.linkScannerLog.TabIndex = 6;
            this.linkScannerLog.TabStop = true;
            this.linkScannerLog.Text = "scanner.log";
            this.linkScannerLog.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkScannerLog_LinkClicked);
            // 
            // SettingsTabUserControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.linkScannerLog);
            this.Controls.Add(this.linkServerLog);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.line2);
            this.Controls.Add(this.labelStatus);
            this.Controls.Add(this.line1);
            this.Controls.Add(this.btnStartStopService);
            this.Name = "SettingsTabUserControl";
            this.Size = new System.Drawing.Size(390, 410);
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

    }
}
