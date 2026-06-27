param(
  [string]$Config = "$PSScriptRoot\..\config.local.json"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Config)) {
  throw "Config file not found: $Config. Copy scripts/config.example.json to config.local.json first."
}

$configObject = Get-Content -Raw -LiteralPath $Config | ConvertFrom-Json
$schedule = $configObject.schedule

if ($null -eq $schedule -or [string]::IsNullOrWhiteSpace($schedule.taskName) -or [string]::IsNullOrWhiteSpace($schedule.time)) {
  throw "schedule.taskName and schedule.time are required."
}

$runScript = Join-Path $PSScriptRoot "run-and-notify.ps1"
$actionArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$runScript`" -Config `"$Config`""
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $actionArgs

$triggerParams = @{
  Weekly = $true
  At = [datetime]::ParseExact($schedule.time, "HH:mm", $null)
}

if ($schedule.daysOfWeek -and $schedule.daysOfWeek.Count -gt 0) {
  $triggerParams.DaysOfWeek = @($schedule.daysOfWeek)
}

$trigger = New-ScheduledTaskTrigger @triggerParams
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName $schedule.taskName -Action $action -Trigger $trigger -Settings $settings -Description "Run US Stock Analyzer report and deliver it to configured channels." -Force | Out-Null

Write-Output "Scheduled task installed: $($schedule.taskName)"
