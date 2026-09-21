' Hidden launcher for vault-backup.win.sh (Task Scheduler → no console flash)
' WindowStyle 0 = completely hidden
Set sh = CreateObject("WScript.Shell")
sh.Run """D:\Git\bin\bash.exe"" ""E:\Code\DotFiles\scripts\vault-backup.win.sh""", 0, True
