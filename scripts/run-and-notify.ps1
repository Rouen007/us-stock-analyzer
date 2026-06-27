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

function Send-DiscordViaChrome {
  param($DiscordConfig, [string]$Text)
  $channelId = $DiscordConfig.channelId
  if ([string]::IsNullOrWhiteSpace($channelId)) {
    throw "Discord chrome-session delivery is enabled, but delivery.discord.channelId is missing."
  }
  if ($channelId -notmatch '^\d{17,20}$') {
    throw "delivery.discord.channelId must be a numeric Discord channel ID."
  }

  $scriptPath = Join-Path $PSScriptRoot "discord-send-via-chrome.js"
  if (-not (Test-Path -LiteralPath $scriptPath)) {
    throw "Discord Chrome sender script not found: $scriptPath"
  }

  $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) ("us-stock-analyzer-discord-" + [guid]::NewGuid().ToString("N") + ".txt")
  try {
    foreach ($part in (Split-Message -Text $Text -MaxLength 1800)) {
      Set-Content -LiteralPath $tempFile -Encoding UTF8 -Value $part
      $cdp = if ([string]::IsNullOrWhiteSpace($DiscordConfig.cdp)) { "http://127.0.0.1:9222" } else { $DiscordConfig.cdp }
      $output = node $scriptPath $channelId $tempFile $cdp 2>&1
      $exitCode = if ($LASTEXITCODE -ne $null) { $LASTEXITCODE } else { 0 }
      if ($exitCode -ne 0) {
        throw "Discord Chrome delivery failed: $($output | Out-String)"
      }
    }
  } finally {
    Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
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
  $mode = if ([string]::IsNullOrWhiteSpace($delivery.discord.mode)) { "webhook" } else { $delivery.discord.mode }
  if ($mode -eq "webhook") {
    $url = Get-EnvValue $delivery.discord.webhookUrlEnv
    if ([string]::IsNullOrWhiteSpace($url)) { throw "Discord webhook delivery is enabled, but webhook environment variable is missing." }
    Send-Discord -WebhookUrl $url -Text $Message
  } elseif ($mode -eq "chrome-session") {
    Send-DiscordViaChrome -DiscordConfig $delivery.discord -Text $Message
  } else {
    throw "Unsupported Discord delivery mode: $mode"
  }
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
