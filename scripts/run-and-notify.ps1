param(
  [string]$Config = "$PSScriptRoot\..\config.local.json",
  [string]$Message = ""
)

$ErrorActionPreference = "Stop"

function Get-EnvValue {
  param([string]$Name)
  if ([string]::IsNullOrWhiteSpace($Name)) { return $null }
  $value = [Environment]::GetEnvironmentVariable($Name, "User")
  if (-not [string]::IsNullOrWhiteSpace($value)) { return $value }
  $value = [Environment]::GetEnvironmentVariable($Name, "Machine")
  if (-not [string]::IsNullOrWhiteSpace($value)) { return $value }
  return [Environment]::GetEnvironmentVariable($Name, "Process")
}

function Split-Message {
  param(
    [string]$Text,
    [int]$MaxLength
  )
  $items = New-Object System.Collections.Generic.List[string]
  if ([string]::IsNullOrWhiteSpace($Text)) { return @("") }
  for ($i = 0; $i -lt $Text.Length; $i += $MaxLength) {
    $len = [Math]::Min($MaxLength, $Text.Length - $i)
    $items.Add($Text.Substring($i, $len))
  }
  return $items.ToArray()
}

function Send-Discord {
  param([string]$WebhookUrl, [string]$Text)
  foreach ($part in (Split-Message -Text $Text -MaxLength 1800)) {
    $body = @{ content = $part } | ConvertTo-Json -Depth 5
    Invoke-RestMethod -Method Post -Uri $WebhookUrl -ContentType "application/json" -Body $body | Out-Null
  }
}

function Send-Slack {
  param([string]$WebhookUrl, [string]$Text)
  foreach ($part in (Split-Message -Text $Text -MaxLength 3500)) {
    $body = @{ text = $part } | ConvertTo-Json -Depth 5
    Invoke-RestMethod -Method Post -Uri $WebhookUrl -ContentType "application/json" -Body $body | Out-Null
  }
}

function Send-Email {
  param($EmailConfig, [string]$Text)
  $smtpServer = Get-EnvValue $EmailConfig.smtpServerEnv
  $smtpPortRaw = Get-EnvValue $EmailConfig.smtpPortEnv
  $username = Get-EnvValue $EmailConfig.usernameEnv
  $password = Get-EnvValue $EmailConfig.passwordEnv
  $from = Get-EnvValue $EmailConfig.fromEnv
  $to = Get-EnvValue $EmailConfig.toEnv

  if ([string]::IsNullOrWhiteSpace($smtpServer) -or [string]::IsNullOrWhiteSpace($from) -or [string]::IsNullOrWhiteSpace($to)) {
    throw "Email delivery is enabled, but SMTP server/from/to environment variables are missing."
  }

  $smtpPort = if ([string]::IsNullOrWhiteSpace($smtpPortRaw)) { 587 } else { [int]$smtpPortRaw }
  $mailParams = @{
    SmtpServer = $smtpServer
    Port = $smtpPort
    From = $from
    To = $to.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    Subject = "US Stock Analyzer Report"
    Body = $Text
    UseSsl = [bool]$EmailConfig.useSsl
  }

  if (-not [string]::IsNullOrWhiteSpace($username)) {
    if ([string]::IsNullOrWhiteSpace($password)) {
      throw "Email username is set, but password environment variable is missing."
    }
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $mailParams.Credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)
  }

  Send-MailMessage @mailParams
}

if (-not (Test-Path -LiteralPath $Config)) {
  throw "Config file not found: $Config. Copy scripts/config.example.json to config.local.json first."
}

$configObject = Get-Content -Raw -LiteralPath $Config | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace($Message)) {
  $runner = $configObject.runner
  if ($null -eq $runner -or [string]::IsNullOrWhiteSpace($runner.command)) {
    throw "No message was provided and runner.command is not configured."
  }

  $workingDirectory = if ([string]::IsNullOrWhiteSpace($runner.workingDirectory)) { (Get-Location).Path } else { $runner.workingDirectory }
  $arguments = @()
  if ($runner.arguments) { $arguments = @($runner.arguments) }

  Push-Location $workingDirectory
  try {
    $output = & $runner.command @arguments 2>&1
    $exitCode = if ($LASTEXITCODE -ne $null) { $LASTEXITCODE } else { 0 }
  } finally {
    Pop-Location
  }

  $Message = ($output | Out-String).Trim()
  if ($exitCode -ne 0) {
    $Message = "US Stock Analyzer runner failed with exit code $exitCode.`n`n$Message"
  }
}

if ([string]::IsNullOrWhiteSpace($Message)) {
  $Message = "US Stock Analyzer produced an empty report."
}

$delivery = $configObject.delivery
if ($delivery.discord.enabled) {
  $url = Get-EnvValue $delivery.discord.webhookUrlEnv
  if ([string]::IsNullOrWhiteSpace($url)) { throw "Discord delivery is enabled, but webhook environment variable is missing." }
  Send-Discord -WebhookUrl $url -Text $Message
}

if ($delivery.slack.enabled) {
  $url = Get-EnvValue $delivery.slack.webhookUrlEnv
  if ([string]::IsNullOrWhiteSpace($url)) { throw "Slack delivery is enabled, but webhook environment variable is missing." }
  Send-Slack -WebhookUrl $url -Text $Message
}

if ($delivery.email.enabled) {
  Send-Email -EmailConfig $delivery.email -Text $Message
}

Write-Output $Message
