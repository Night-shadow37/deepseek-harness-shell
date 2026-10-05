Dim WshShell
Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "D:\dsh\harness-shell"
WshShell.Run """C:\Users\xingg\.dsh\dsh-orb\electron-runtime\electron.exe"" ""D:\dsh\harness-shell""", 1, False
Set WshShell = Nothing
