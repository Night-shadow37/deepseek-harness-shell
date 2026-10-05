using System;
using System.Diagnostics;
using System.IO;
using System.Threading;

namespace DeepSeekLauncher
{
    class Program
    {
        static void Main(string[] args)
        {
            string logPath = @"D:\dsh\harness-shell\launcher-debug.log";
            string electron = @"C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe";
            string appDir = @"D:\dsh\harness-shell";

            try
            {
                File.AppendAllText(logPath, "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "] Launcher started" + Environment.NewLine);

                if (!File.Exists(electron))
                {
                    File.AppendAllText(logPath, "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "] ERROR: Electron not found" + Environment.NewLine);
                    return;
                }

                File.AppendAllText(logPath, "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "] Launching Electron..." + Environment.NewLine);

                var psi = new ProcessStartInfo();
                psi.FileName = electron;
                psi.Arguments = "\"" + appDir + "\"";
                psi.WorkingDirectory = appDir;
                psi.UseShellExecute = true;
                psi.WindowStyle = ProcessWindowStyle.Normal;

                Process proc = Process.Start(psi);
                if (proc != null)
                {
                    File.AppendAllText(logPath, "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "] Launched PID=" + proc.Id + Environment.NewLine);
                    
                    // Wait up to 10 seconds for the process to stabilize
                    bool stillRunning = false;
                    for (int i = 0; i < 100; i++)
                    {
                        Thread.Sleep(100);
                        if (!proc.HasExited)
                        {
                            stillRunning = true;
                            break;
                        }
                    }
                    
                    if (stillRunning)
                    {
                        File.AppendAllText(logPath, "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "] Electron is running after 10s" + Environment.NewLine);
                    }
                    else
                    {
                        File.AppendAllText(logPath, "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "] ERROR: Electron exited quickly with code " + proc.ExitCode + Environment.NewLine);
                    }
                }
                else
                {
                    File.AppendAllText(logPath, "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "] ERROR: Process.Start returned null" + Environment.NewLine);
                }
            }
            catch (Exception ex)
            {
                File.AppendAllText(logPath, "[" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "] ERROR: " + ex.ToString() + Environment.NewLine);
            }
        }
    }
}
