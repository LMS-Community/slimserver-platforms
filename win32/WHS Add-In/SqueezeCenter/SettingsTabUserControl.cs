using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.Data;
using System.IO;
using System.Management;
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
                btnStartStopService.Text = "Stop SqueezeCenter";
                labelSCStatus.Text = "The SqueezeCenter service is running";
            }
            else
            {
                if (this.scStatus == -1)
                {
                    labelSCStatus.Text = "The SqueezeCenter service is not available";
                }
                else if (this.scStatus == -2)
                {
                    labelSCStatus.Text = "SqueezeCenter is stopping...";
                }
                else if (this.scStatus == -3)
                {
                    labelSCStatus.Text = "SqueezeCenter is starting...";
                }
                else
                {
                    labelSCStatus.Text = "The SqueezeCenter service is stopped";
                }

                btnStartStopService.Text = "Start SqueezeCenter";
            }

            btnStartStopService.Enabled = this.scStatus >= 0;
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
                    if (scService.Status == ServiceControllerStatus.StartPending) {
                        this.scStatus = -3;
                    }
                    else if (scService.Status == ServiceControllerStatus.StopPending)
                    {
                        this.scStatus = -2;
                    }
                    else if (scService.Status == ServiceControllerStatus.Stopped)
                    {
                        this.scStatus = 0;
                    }
                    else
                    {
                        this.scStatus = 1;
                    }
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
                cbStartAtBoot.Enabled = (this.scStatus != -1);
                btnCleanup.Enabled = (this.scStatus != 1);
                labelPleaseStopSC.Visible = (this.scStatus == 1);
            }
        }

        private void linkServerLog_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start(getLogPath() + @"\server.log");
        }

/*        private void linkServerLog_Paint(object sender, PaintEventArgs e)
        {
            linkServerLog.Text = getLogPath() + @"\server.log";
        }
*/
        private void linkScannerLog_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start(getLogPath() + @"\scanner.log");
        }

/*        private void linkScannerLog_Paint(object sender, PaintEventArgs e)
        {
            linkScannerLog.Text = getLogPath() + @"\scanner.log";
        }
*/

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

        private void linkMusicFolder_Paint(object sender, PaintEventArgs e)
        {
            linkMusicFolder.Text = readPref("audiodir");
        }

        private void linkMusicFolder_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            String audiodir = readPref("audiodir");

            // if audiodir is on a share, try to open it on the client
            if (audiodir.Substring(0, 2) == @"\\")
            {
                this.consoleServices.OpenUrl(audiodir);
            }
            else
            {
                System.Diagnostics.Process.Start(audiodir);
            }
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

        private void SettingsTabUserControl_Load(object sender, EventArgs e)
        {
            cbStartAtBoot.Checked = AutostartSCService();
        }

        private void cbStartAtBoot_Click(object sender, EventArgs e)
        {
            this.consoleServices.EnableSettingsApply();
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

        private bool AutostartSCService()
        {
            bool auto = true;
            try
            {
                ManagementPath mp = new ManagementPath(@"Win32_Service.Name='" + svcName + "'");
                ManagementObject svcMgr = new ManagementObject(mp);

                auto = (svcMgr["StartMode"].ToString().ToLower() == "auto");
            }
            catch {}

            return auto;
        }

        public bool Commit()
        {
            object [] p = new object[1];

            if (AutostartSCService() != cbStartAtBoot.Checked)
            {
                p[0] = (cbStartAtBoot.Checked ? "Automatic" : "Manual");

                try
                {
                    ManagementPath mp = new ManagementPath(@"Win32_Service.Name='" + svcName + "'");
                    ManagementObject svcMgr = new ManagementObject(mp);

                    svcMgr.InvokeMethod("ChangeStartMode", p);
                }
                catch {
                    MessageBox.Show("Changing startup mode failed.");
                }
            }
            return false;
        }

        private void btnCleanup_Click(object sender, EventArgs e)
        {
            RegistryKey OurKey = Registry.LocalMachine;
            OurKey = OurKey.OpenSubKey(@"SOFTWARE\Logitech\SqueezeCenter", true);
            String path = OurKey.GetValue("Path").ToString() + @"\server\";

            Process p = new Process();
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.FileName = path + "cleanup.exe";
            p.StartInfo.WorkingDirectory = path;
            p.Start();
        }

        private void customTabControl1_Selected(object sender, TabControlEventArgs e)
        {
            if (e.TabPage == information)
            {
                if (this.scStatus == 1)
                {
//                    informationBrowser.Url = new Uri(getSCUrl() + @"/EN/settings/server/status.html?simple=1");
                    informationBrowser.Navigate(getSCUrl() + @"/EN/settings/server/status.html?simple=1");
                    informationBrowser.Refresh();
                }
                else
                {
                    informationBrowser.DocumentText = @"No status information available. Please note that SqueezeCenter has to be up and running in order to display its status information.";
                }
            }
        }

    }
}
