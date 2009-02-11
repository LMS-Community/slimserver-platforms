using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.ServiceProcess;
using System.Text;
using System.Windows.Forms;
using Microsoft.HomeServer.Extensibility;

namespace Microsoft.HomeServer.HomeServerConsoleTab.SqueezeCenter
{
    public partial class SettingsTabUserControl : UserControl
    {
        IConsoleServices consoleServices;
        int scStatus;

        public SettingsTabUserControl()
        {
            InitializeComponent();
        }

        public SettingsTabUserControl(int width, int height, IConsoleServices consoleServices)
            : this()
        {
            this.Width = width;
            this.Height = height;
            this.consoleServices = consoleServices;
            this.scStatus = 0;
        }
        private void btnStartStopService_Click(object sender, EventArgs e)
        {
            try
            {
                ServiceController scService = new ServiceController("squeezesvc");

                if (scService != null)
                {
                    if (this.scStatus == 1)
                    {
                        scService.Stop();
                    }
                    else
                    {
                        scService.Start();
                    }
                }
            }
            catch { }
        }

        private void btnStartStopService_Paint(object sender, PaintEventArgs e)
        {
            if (this.scStatus == 1)
            {
                btnStartStopService.Text = "Stop";
            }
            else
            {
                btnStartStopService.Text = "Start";
            }

            btnStartStopService.Enabled = this.scStatus != -1;
            labelSCUnavailable.Visible = this.scStatus == -1;
        }

        private void PollSCTimer_Tick(object sender, EventArgs e)
        {
            ServiceController scService = null;

            int oldStatus = this.scStatus;

            try
            {
                scService = new ServiceController("squeezesvc");

                if (scService != null)
                {
                    this.scStatus = (scService.Status == ServiceControllerStatus.Stopped) ? 0 : 1;
                }
                else
                {
                    this.scStatus = -1;
                }
            }
            catch {
                this.scStatus = -1;
            }

            if (oldStatus != this.scStatus)
            {
                btnStartStopService_Paint(null, null);
            }
        }

        private void linkServerLog_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start("c:\\documents and settings\\all users\\application data\\SqueezeCenter\\logs\\server.log");
        }

        private void linkScannerLog_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start("c:\\documents and settings\\all users\\application data\\SqueezeCenter\\logs\\scanner.log");
        }
    }
}
