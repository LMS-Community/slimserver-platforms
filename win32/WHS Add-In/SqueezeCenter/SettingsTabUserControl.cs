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
using System.Web.Services.Protocols;
using System.Windows.Forms;
using Jayrock.Json;
using Microsoft.HomeServer.Extensibility;
using Microsoft.Win32;

namespace Microsoft.HomeServer.HomeServerConsoleTab.SqueezeCenter
{
    public partial class SettingsTabUserControl : UserControl
    {
        string snPasswordPlaceholder = "SN_PASSWORD_PLACEHOLDER";

        IConsoleServices consoleServices;
        Dictionary<string, string> scStrings = new Dictionary<string, string>();
        int scStatus;
        bool isScanning;
        
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
            this.isScanning = false;

            musicLibraryName.Text = getPref("libraryname");
            musicFolderInput.Text = getPref("audiodir");
            musicLibraryStats.Text = "";
            playlistFolderInput.Text = getPref("playlistdir");
            progressLabel.Text = "";
            progressInformation.Text = "";
            rescanOptionsList.SelectedIndex = 0;

            snUsername.Text = getPref("sn_email");
            snPassword.Text = getPref("sn_password_sha") != "" ? snPasswordPlaceholder : "";
            snStatsOptions.SelectedIndex = 1;

            String pref = getPref("sn_sync");

            pref = getPref("sn_disable_stats");
            snStatsOptions.SelectedIndex = Convert.ToInt16(pref == "" ? "0" : pref);
            
            PollSCTimer_Tick(new Object(), new EventArgs());
            updateCheckTimer_Tick(new Object(), new EventArgs());

            updateLibraryStats();

            jsonRequest(new string[] { "pref", "wizardDone", "1" });
        }

        /* basic settings, startup mode etc. */
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
            catch {}
        }

        private void btnStartStopService_Paint(object sender, PaintEventArgs e)
        {
            if (this.scStatus == 1)
            {
                btnStartStopService.Text = "Stop Logitech Media Server";
                labelSCStatus.Text = "Logitech Media Server is running";
            }
            else
            {
                if (this.scStatus == -1)
                    labelSCStatus.Text = "Logitech Media Server is not available";

                else if (this.scStatus == -2)
                    labelSCStatus.Text = "Logitech Media Server is stopping...";
                
                else if (this.scStatus == -3)
                    labelSCStatus.Text = "Logitech Media Server is starting...";
                
                else
                    labelSCStatus.Text = "Logitech Media Server is stopped";
                
                btnStartStopService.Text = "Start Logitech Media Server";
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
                    if (scService.Status == ServiceControllerStatus.StartPending)
                        this.scStatus = -3;
    
                    else if (scService.Status == ServiceControllerStatus.StopPending)
                        this.scStatus = -2;

                    else if (scService.Status == ServiceControllerStatus.Stopped)
                        this.scStatus = 0;
                    
                    else
                        this.scStatus = 1;
                }
                else
                    this.scStatus = -1;

            }
            catch {
                this.scStatus = -1;
            }

            if (oldStatus != this.scStatus)
            {
                if (this.scStatus == 1)
                {
                    string url = getSCUrl();
                    informationBrowser.Url = new Uri(url + @"/EN/settings/server/status.html?simple=1&os=whs");
                    jsonClient.Url = url + "/jsonrpc.js";
                }

                btnStartStopService_Paint(null, null);
            }

            cbStartAtBoot.Enabled = (this.scStatus != -1);

            musicFolderInput.Enabled = (this.scStatus == 1 && !this.isScanning);
            browseMusicFolderBtn.Enabled = (this.scStatus == 1 && !this.isScanning);
            playlistFolderInput.Enabled = (this.scStatus == 1 && !this.isScanning);
            browsePlaylistFolderBtn.Enabled = (this.scStatus == 1 && !this.isScanning);
            rescanOptionsList.Enabled = (this.scStatus == 1 && !this.isScanning);
            rescanBtn.Enabled = (this.scStatus == 1);

            snUsername.Enabled = (this.scStatus == 1);
            snPassword.Enabled = (this.scStatus == 1);
            snStatsOptions.Enabled = (this.scStatus == 1);
            
            if (this.isScanning)
                rescanBtn.Text = "Abort";
            else
                rescanBtn.Text = "Rescan";

            cbCleanupCache.Enabled = (this.scStatus != 1);
            cbCleanupPrefs.Enabled = (this.scStatus != 1);
            btnCleanup.Enabled = (this.scStatus != 1);
            labelPleaseStopSC.Visible = (this.scStatus == 1);
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
            linkSCWebUI.Text = "Web Control  (" + getSCUrl() + ")";
        }

        private String getSCUrl()
        {
            String url = "";

            url = Dns.GetHostName();

            return @"http://" + url + ":" + getPref("httpport");
        }

        private void SettingsTabUserControl_Load(object sender, EventArgs e)
        {
            cbStartAtBoot.Checked = AutostartSCService();
        }

        private void cbStartAtBoot_Click(object sender, EventArgs e)
        {
            this.consoleServices.EnableSettingsApply();
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

                    String success = svcMgr.InvokeMethod("ChangeStartMode", p).ToString();

                    if (success != @"0")
                    {
                        MessageBox.Show("Service Manager returned error code " + success, "Logitech Media Server", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                    }
                }
                catch {
                    MessageBox.Show("Changing startup mode failed.", "Logitech Media Server", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }

            jsonRequest(new string[] { "pref", "libraryname", musicLibraryName.Text });

            if (musicFolderInput.Text != getPref("audiodir"))
                jsonRequest(new string[] { "pref", "audiodir", musicFolderInput.Text });

            if (playlistFolderInput.Text != getPref("playlistdir"))
                jsonRequest(new string[] { "pref", "playlistdir", playlistFolderInput.Text });

            if (snUsername.Text != getPref("sn_email") || (snPassword.Text != "" && snPassword.Text != snPasswordPlaceholder && snPassword.Text != getPref("sn_password_sha")))
            {
                JsonObject result = jsonRequest(new string[] { "setsncredentials", snUsername.Text, snPassword.Text });
                if (result != null && result["validated"].ToString() != "" && result["warning"].ToString() != "")
                {
                    if (result["validated"].ToString() == "0")
                        MessageBox.Show(result["warning"].ToString(), "mysqueezebox.com", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                }
            }

            jsonRequest(new string[] { "pref", "sn_disable_stats", snStatsOptions.SelectedIndex.ToString()});

            return false;
        }

        private void btnCleanup_Click(object sender, EventArgs e)
        {
            String cleanupParams = @"";

            if (cbCleanupCache.Checked)
                cleanupParams += @" --cache";

            if (cbCleanupPrefs.Checked)
                cleanupParams += @" --prefs";

            if (cleanupParams != @"")
            {
                try
                {
                    RegistryKey OurKey = Registry.LocalMachine;
                    OurKey = OurKey.OpenSubKey(@"SOFTWARE\Logitech\Squeezebox", true);
                    String path = OurKey.GetValue("Path").ToString() + @"\server\";

                    Process p = new Process();
                    p.StartInfo.UseShellExecute = false;
                    p.StartInfo.FileName = path + "squeezeboxcp.exe";
                    p.StartInfo.Arguments = cleanupParams;
                    p.StartInfo.WorkingDirectory = path;
                    p.Start();
                }
                catch { }
            }
        }

        private void prefsTabControl_Selected(object sender, TabControlEventArgs e)
        {
            if (e.TabPage == information)
            {
                if (this.scStatus == 1)
                    informationBrowser.Refresh();
                else
                    informationBrowser.DocumentText = @"No status information available. Please note that Logitech Media Server has to be up and running in order to display its status information.";
            }
            else if (e.TabPage == status)
                libraryStatsTimer.Interval = 150;
        }

        private void updateLibraryStats()
        {
            JsonObject libraryStats = jsonRequest(new string[] { "systeminfo", "items", "0", "999" });

            if (libraryStats != null && libraryStats["loop_loop"] != null)
            {
                String libraryName = getSCString("INFORMATION_MENU_LIBRARY");
                String scanning = getSCString("RESCANNING_SHORT");

                JsonArray steps = (JsonArray)libraryStats["loop_loop"];

                int x;
                JsonObject step = null;
                for (x = 0; x < steps.Length; x++)
                {
                    step = (JsonObject)steps[x];

                    if (step != null && (step["name"].ToString() == libraryName) || (step["name"].ToString() == scanning))
                        break;
                }

                if (x < steps.Length && step["name"].ToString() == libraryName)
                {
                    libraryStats = jsonRequest(new string[] { "systeminfo", "items", "0", "999", "item_id:" + Convert.ToString(x) });

                    if (libraryStats != null)
                        steps = (JsonArray)libraryStats["loop_loop"];

                    if (steps != null)
                    {
                        libraryName = "";

                        for (x = 0; x < steps.Length; x++)
                        {
                            step = (JsonObject)steps[x];

                            if (step != null && step["name"] != null)
                                libraryName += step["name"].ToString() + "\n";
                        }

                        musicLibraryStats.Text = libraryName;
                    }

                }

                else if (x < steps.Length && step["name"].ToString() == scanning)
                    musicLibraryStats.Text = scanning;
            }
        }


        /* update checker */
        private bool checkForUpdate()
        {
            String filePath = "";

            try
            {
                TextReader versionFile = new StreamReader(getCachePath() + @"\updates\server.version");
                filePath = versionFile.ReadLine();

                versionFile.Close();
            }
            catch { }

            return (filePath != null && File.Exists(filePath));
        }

        /* Music library management */
        private void browseMusicFolderBtn_Click(object sender, EventArgs e)
        {
            _browseFolder(musicFolderInput, "SETUP_AUDIODIR_DESC");
        }

        private void browsePlaylistFolderBtn_Click(object sender, EventArgs e)
        {
            _browseFolder(playlistFolderInput, "SETUP_PLAYLISTDIR_DESC");
        }

        private void _browseFolder(TextBox whichFolder, string description)
        {
            FolderBrowserDialog folderBrowser = new FolderBrowserDialog();
            folderBrowser.SelectedPath = whichFolder.Text;
            folderBrowser.Description = getSCString(description);
            DialogResult objResult = folderBrowser.ShowDialog();
            if (objResult == DialogResult.OK)
                whichFolder.Text = folderBrowser.SelectedPath;
        }

        private void linkMusicFolder_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            _folderLinkClicked("audiodir");
        }

        private void linkPlaylistFolder_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            _folderLinkClicked("playlistdir");
        }

        private void _folderLinkClicked(string whichFolder)
        {
            String audiodir = getPref(whichFolder);

            // if audiodir is on a share, try to open it on the client
            if (audiodir.Substring(0, 2) == @"\\")
                this.consoleServices.OpenUrl(audiodir);
            else
                System.Diagnostics.Process.Start(audiodir);
        }

        private void rescanBtn_Click(object sender, EventArgs e)
        {
            if (this.isScanning)
            {
                jsonRequest(new string[] { "abortscan" });
            }
            else
            {
                if (rescanOptionsList.SelectedIndex == 0)
                    jsonRequest(new string[] { "rescan" });
                else if (rescanOptionsList.SelectedIndex == 1)
                    jsonRequest(new string[] { "wipecache" });
                else if (rescanOptionsList.SelectedIndex == 2)
                    jsonRequest(new string[] { "rescan", "playlists" });
            }

            ScanPollTimer_Tick(this, new EventArgs());
        }

        private void ScanPollTimer_Tick(object sender, EventArgs e)
        {
            rescanOptionsList.Enabled = !this.isScanning;

            JsonObject scanProgress = jsonRequest(new string[] { "rescanprogress" } );
            progressInformation.Text = "";

            if (scanProgress != null && scanProgress["steps"] != null && scanProgress["rescan"] != null)
            {
                this.isScanning = true;
                rescanOptionsList.Enabled = false;

                string[] steps = scanProgress["steps"].ToString().Split(',');

                if (steps.Length > 0 && scanProgress[steps[steps.Length - 1].ToString()] != null)
                {
                    string step = steps[steps.Length - 1].ToString();
                    progressLabel.Text = getSCString(step.ToUpper() + "_PROGRESS");

                    int val = Convert.ToInt16(scanProgress[step]);
                    if (val > 0)
                    {
                        scanProgressBar.Style = ProgressBarStyle.Continuous;
                        scanProgressBar.Value = val;
                    }
                    else
                        scanProgressBar.Style = ProgressBarStyle.Marquee;
                }

                if (scanProgress["info"] != null)
                    progressInformation.Text = scanProgress["info"].ToString();

                if (scanProgress["totaltime"] != null)
                    progressTime.Text = scanProgress["totaltime"].ToString();
                else
                    progressTime.Text = "00:00:00";

                return;
            }

            else if (scanProgress != null && scanProgress["lastscanfailed"] != null)
            {
                progressLabel.Text = scanProgress["lastscanfailed"].ToString();
            }

            if (this.isScanning)
            {
                progressLabel.Text = getSCString("PROGRESS_IMPORTER_COMPLETE_DESC");
                scanProgressBar.Style = ProgressBarStyle.Continuous;
                scanProgressBar.Value = 100;
            }

            this.isScanning = false;
        }


        /* helper methods */
        private String getDataPath()
        {
            try
            {
                RegistryKey OurKey = Registry.LocalMachine;
                OurKey = OurKey.OpenSubKey(@"SOFTWARE\Logitech\Squeezebox", true);
                return OurKey.GetValue("DataPath").ToString();
            }
            catch
            {
                return "";
            }
        }

        private string getLogPath()
        {
            return getDataPath() + @"\Logs";
        }

        private string getPrefsPath()
        {
            return getDataPath() + @"\prefs";
        }

        private string getCachePath()
        {
            return getDataPath() + @"\Cache";
        }

        /* reading prefs from the file directly */
        private String getPref(String pref)
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
            catch {}

            if (value == null)
                value = "";

            value = value.Trim(new char[] {'"', '\''});

            return ( value == "''" ? "" : value );
        }

        private JsonObject jsonRequest(string[] query)
        {
            try
            {
                JsonObject result = (JsonObject)jsonClient.Invoke(new object[] { "", query });
                return result;
            }
            catch
            {
                return new JsonObject();
            }
        }

        /* get localized strings from SC and cache them in a dictionary */
        private string getSCString(string stringToken)
        {
            stringToken = stringToken.ToUpper();
            string translation = "";


            if (scStrings.ContainsKey(stringToken))
            {
                translation = scStrings[stringToken];
            }
            else
            {
                // initialize entry with empty value to prevent querying string twice
                scStrings.Add(stringToken, "");

                JsonObject translationTuple = jsonRequest(new string[] { "getstring", stringToken });

                if (translationTuple != null && translationTuple[stringToken] != null)
                    translation = translationTuple[stringToken].ToString();

                if (translation == "")
                    scStrings.Remove(stringToken);
                else
                    scStrings[stringToken] = translation;
            }
                        
            return translation;
        }

        private void EnableApply(object sender, EventArgs e)
        {
            this.consoleServices.EnableSettingsApply();
        }

        private void linkPrivacyPolicy_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            this.consoleServices.OpenUrl(@"http://www.logitech.com/index.cfm/footer/privacy/&cl=us,en");
        }

        private void linkNeedSNAccount_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            this.consoleServices.OpenUrl(@"http://www.mysqueezebox.com/");
        }

        private void linkForgotPassword_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            this.consoleServices.OpenUrl(@"http://www.mysqueezebox.com/user/forgotPassword");
        }

        private void updateCheckTimer_Tick(object sender, EventArgs e)
        {
            updateNotification.Visible = checkForUpdate();
        }

        private void libraryStatsTimer_Tick(object sender, EventArgs e)
        {
            libraryStatsTimer.Interval = 9876;
            updateLibraryStats();
        }
    }

    public class JsonRpcClient : HttpWebClientProtocol
    {
        private int _id;

        public virtual object Invoke(params object[] args)
        {
            WebRequest request = GetWebRequest(new Uri(Url));
            request.Method = "POST";

            using (Stream stream = request.GetRequestStream())
            using (StreamWriter writer = new StreamWriter(stream))
            {
                JsonObject call = new JsonObject();
                call["id"] = ++_id;
                call["method"] = "slim.request";
                call["params"] = args;
                call.Export(new JsonTextWriter(writer));
            }

            using (WebResponse response = GetWebResponse(request))
            using (Stream stream = response.GetResponseStream())
            using (StreamReader reader = new StreamReader(stream, Encoding.UTF8))
            {
                JsonObject answer = new JsonObject();
                answer.Import(new JsonTextReader(reader));

                object errorObject = answer["error"];

                if (errorObject != null)
                    return null;

                return answer["result"];
            }
        }
    }
}
