#Requires -Version 5.1
<#
.SYNOPSIS
  Install the CANNBOT provider plugin for OpenCode on Windows.
#>
$ErrorActionPreference = 'Stop'

$RepoRaw   = if ($env:CANNBOT_REPO_RAW) { $env:CANNBOT_REPO_RAW } else { 'https://raw.githubusercontent.com/BadFatCat0919/opencannbot/main' }
$PluginUrl = "$RepoRaw/cannbot-auth.js"

# OpenCode follows XDG-style paths; on Windows these live under the user profile.
$ConfigDir   = if ($env:XDG_CONFIG_HOME) { Join-Path $env:XDG_CONFIG_HOME 'opencode' } else { Join-Path $env:USERPROFILE '.config\opencode' }
$DataDir     = if ($env:XDG_DATA_HOME)   { Join-Path $env:XDG_DATA_HOME   'opencode' } else { Join-Path $env:USERPROFILE '.local\share\opencode' }
$PluginDir   = Join-Path $ConfigDir 'plugins'
$PluginFile  = Join-Path $PluginDir 'cannbot-auth.js'
$OpencodeJson = Join-Path $ConfigDir 'opencode.json'

function Write-Bold($t)   { Write-Host $t -ForegroundColor White }
function Write-Green($t)  { Write-Host $t -ForegroundColor Green }
function Write-Red($t)    { Write-Host $t -ForegroundColor Red }

Write-Bold "======================================="
Write-Bold "  CANNBOT Provider for OpenCode"
Write-Bold "======================================="
Write-Host ""

if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
  Write-Red "opencode not found. Please install opencode first."
  exit 1
}
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Red "node not found."
  exit 1
}

New-Item -ItemType Directory -Force -Path $PluginDir, $DataDir | Out-Null

# ── 1. Get plugin ───────────────────────────────────────────────────────
# The repo's cannbot-auth.js is the single source of truth.

$LocalPlugin = Join-Path $PSScriptRoot 'cannbot-auth.js'
if (Test-Path $LocalPlugin) {
  Copy-Item $LocalPlugin $PluginFile -Force
  Write-Green "[1/2] Plugin copied from local clone -> $PluginFile"
} else {
  Invoke-WebRequest -Uri $PluginUrl -OutFile $PluginFile -UseBasicParsing
  Write-Green "[1/2] Plugin downloaded -> $PluginFile"
}

# ── 2. Update opencode.json ─────────────────────────────────────────────

$PluginUri = "file://$($PluginFile -replace '\\','/')"

if (Test-Path $OpencodeJson) {
  $cfg = Get-Content $OpencodeJson -Raw | ConvertFrom-Json
  $plugins = @()
  if ($cfg.PSObject.Properties.Name -contains 'plugin' -and $cfg.plugin) { $plugins = @($cfg.plugin) }
  if ($plugins -notcontains $PluginUri) { $plugins += $PluginUri }
  $cfg | Add-Member -NotePropertyName 'plugin' -NotePropertyValue $plugins -Force
  $cfg | ConvertTo-Json -Depth 20 | Set-Content -Path $OpencodeJson -Encoding UTF8
} else {
  $cfg = [ordered]@{
    '$schema' = 'https://opencode.ai/config.json'
    plugin    = @($PluginUri)
  }
  $cfg | ConvertTo-Json -Depth 20 | Set-Content -Path $OpencodeJson -Encoding UTF8
}

Write-Green "[2/2] opencode.json updated -> $OpencodeJson"

Write-Host ""
Write-Bold "Done! Restart opencode, then run:"
Write-Host ""
Write-Host "  /connect"
Write-Host ""
Write-Host "Select 'CANNBOT' and enter your Virtual Key (VK)."
Write-Host ""
