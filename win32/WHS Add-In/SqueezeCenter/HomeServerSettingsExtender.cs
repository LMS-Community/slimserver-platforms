using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;
using Microsoft.HomeServer.Extensibility;

namespace Microsoft.HomeServer.HomeServerConsoleTab.SqueezeCenter
{
    public class HomeServerSettingsExtender : ISettingsTab
    {
        private IConsoleServices consoleServices;
        private SettingsTabUserControl tabControl;

        public HomeServerSettingsExtender(int width, int height, IConsoleServices consoleServices)
        {
            this.consoleServices = consoleServices;

            tabControl = new SettingsTabUserControl(width, height, consoleServices);

            //Additional setup code here


        }

        public Guid SettingsGuid
        {
            get
            {
                return new Guid("8b73852a-d83a-43ef-ba88-2ee4ebbfae8f");
            }
        }

        public Control TabControl
        {
            get
            {
                return tabControl;
            }
        }

        public Bitmap TabImage
        {
            get
            {
                return Properties.Resources.Squeezebox;
            }
        }

        public string TabText
        {
            get
            {
                return "Logitech Media Server";
            }
        }

        public bool Commit()
        {
            return this.tabControl.Commit();
        }

        public bool GetHelp()
        {
            return false;
        }
    }
}
