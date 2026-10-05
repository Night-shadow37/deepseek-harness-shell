using System;
using System.Diagnostics;
using System.IO;

namespace DeepSeekLauncher
{
    class Program
    {
        static void Main(string[] args)
        {
            string logPath = @"D:\dsh\harness-shell\launcher-test.log";
            File.AppendAllText(logPath, "[" + DateTime.Now.ToString() + "] Test launcher started" + Environment.NewLine);

            try
            {
                Process.Start("notepad.exe");
                File.AppendAllText(logPath, "[" + DateTime.Now.ToString() + "] Notepad launched successfully" + Environment.NewLine);
            }
            catch (Exception ex)
            {
                File.AppendAllText(logPath, "[" + DateTime.Now.ToString() + "] ERROR: " + ex.Message + Environment.NewLine);
            }
        }
    }
}
