# 注册「每 20 分钟 + 登录时」的 MyLittleHouse 备份任务（对应 launchd plist）
# 通过 wscript + VBS(Run style 0) 调 bash，彻底不弹黑框
# 以当前用户运行一次即可（无需管理员）：
#   powershell -ExecutionPolicy Bypass -File E:\Code\DotFiles\scripts\register-vault-backup-task.ps1

$ErrorActionPreference = "Stop"

$taskName = "MyLittleHouse Backup"
$bash = "D:\Git\bin\bash.exe"
$script = "E:\Code\DotFiles\scripts\vault-backup.win.sh"
$vbs = "E:\Code\DotFiles\scripts\vault-backup-hidden.vbs"

if (-not (Test-Path $bash)) {
    throw "Git Bash not found: $bash"
}
if (-not (Test-Path $script)) {
    throw "Backup script not found: $script"
}
if (-not (Test-Path $vbs)) {
    throw "Hidden launcher not found: $vbs"
}

Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

# wscript 跑 VBS；VBS 里 Run(..., 0) 才真正无窗口（powershell -WindowStyle Hidden 仍可能闪）
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "//nologo `"$vbs`""
$triggerLogon = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
# RepetitionDuration 不能用 TimeSpan.MaxValue；用约 10 年
$triggerRepeat = New-ScheduledTaskTrigger -Once -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes 20) `
    -RepetitionDuration (New-TimeSpan -Days 3650)
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10) `
    -Hidden
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger @($triggerLogon, $triggerRepeat) `
    -Settings $settings `
    -Principal $principal `
    -Description "Obsidian vault git backup every 20 min (DotFiles vault-backup.win.sh)" |
    Out-Null

Write-Host "Registered: $taskName (VBS hidden)"
Get-ScheduledTask -TaskName $taskName | Format-List TaskName, State
(Get-ScheduledTask -TaskName $taskName).Actions | Format-List Execute, Arguments
