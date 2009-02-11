using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.IO;
using System.Net;
using System.ServiceProcess;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using Microsoft.HomeServer.Extensibility;
using Microsoft.Win32;

namespace Microsoft.HomeServer.HomeServerConsoleTab.SqueezeCenter
{
    public partial class SettingsTabUserControl : UserControl
    {
        IConsoleServices consoleServices;
        int scStatus;
        
        const string svcName = "squeezesvc";

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
                ServiceController scService = new ServiceController(svcName);

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
                scService = new ServiceController(svcName);

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
                linkSCWebUI_Paint(null, null);
            }
        }

        private void linkServerLog_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start(getLogPath() + @"\server.log");
        }

        private void linkScannerLog_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start(getLogPath() + @"\scanner.log");
        }

        private void linkSCSettings_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            this.consoleServices.OpenUrl(getSCUrl() + @"/settings/index.html");
        }

        private void linkSCWebUI_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            this.consoleServices.OpenUrl(getSCUrl());
        }

        private void linkSCWebUI_Paint(object sender, PaintEventArgs e)
        {
            linkSCWebUI.Text = getSCUrl();
        }

        private String getSCUrl()
        {
            String url = "";

            url = Dns.GetHostName();

 /*           try
            {
                IPAddress[] ip = Dns.GetHostAddresses("");
                if (ip.Length > 0)
                {
                    url = ip[0].ToString();
                }
            }
            catch { }
            */
            return @"http://" + url + ":" + readPref("httpport");
        }

        private String getDataPath()
        {
            RegistryKey OurKey = Registry.LocalMachine;
            OurKey = OurKey.OpenSubKey(@"SOFTWARE\Logitech\SqueezeCenter", true);
            return OurKey.GetValue("DataPath").ToString();
        }

        private string getLogPath()
        {
            return getDataPath() + @"\Logs";
        }

        private string getPrefsPath()
        {
            return getDataPath() + @"\prefs";
        }

        private String readPref(String pref)
        {
            String value = "";
            Regex prefsRegex = new Regex("^(" + pref + @"):\s*(.*)\s*$");

            try
            {
                TextReader prefsFile = new StreamReader(getPrefsPath() + @"\server.prefs");
                value = prefsFile.ReadLine();
                while (value != null)
                {
                    Match pair = prefsRegex.Match(value);
                    if (pair.Groups.Count >= 2)
                    {
                        value = pair.Groups[2].Value;
                        break;
                    }

                    value = prefsFile.ReadLine();
                }

                prefsFile.Close();
            }
            catch { }

            return (value == null ? "" : value);
        }
    }
}
