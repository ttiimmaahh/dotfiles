# Windows installer for the Herdr app files (herdr-app/) and agent skills
# (agents/skills/). The other configs in this repository are for Linux and
# macOS; use ./apply there.
#
#   powershell -ExecutionPolicy Bypass -File .\apply.ps1 [-DryRun]
#
# Symbolic links need Windows Developer Mode (Settings > System > For
# developers) or an elevated shell. Existing destinations are moved to
# ~\.dotfiles-backup\<timestamp-pid>\ first.

param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repo = $PSScriptRoot
$backupDir = Join-Path $HOME (".dotfiles-backup\" + (Get-Date -Format 'yyyyMMdd-HHmmss') + "-$PID")

if ($env:HERDR_APP_HOME) {
  $herdrApp = $env:HERDR_APP_HOME
} elseif ($env:XDG_CONFIG_HOME) {
  $herdrApp = Join-Path $env:XDG_CONFIG_HOME 'herdr-app'
} else {
  $herdrApp = Join-Path $HOME '.config\herdr-app'
}

# Herdr rewrites AGENTS.md in its folder on every start: if it's missing, this
# isn't the folder Herdr uses (or Herdr hasn't run yet).
if (-not (Test-Path (Join-Path $herdrApp 'AGENTS.md'))) {
  throw "No Herdr app folder at $herdrApp. Start Herdr once, or set HERDR_APP_HOME to its folder, then run this again."
}

function Install-Link([string]$Source, [string]$Destination) {
  $item = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
  if ($item -and $item.LinkType -eq 'SymbolicLink' -and $item.Target -contains $Source) {
    Write-Host "Already linked: $Destination"
    return
  }
  if ($item) {
    $backup = Join-Path $backupDir $Destination.Substring($HOME.Length).TrimStart('\', '/')
    Write-Host "Backing up: $Destination -> $backup"
    if (-not $DryRun) {
      New-Item -ItemType Directory -Force -Path (Split-Path $backup) | Out-Null
      Move-Item -LiteralPath $Destination -Destination $backup
    }
  }
  Write-Host "Linking: $Destination -> $Source"
  if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Destination) | Out-Null
    try {
      New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
    } catch {
      throw "Could not create a symbolic link at $Destination. Turn on Developer Mode or run as administrator. ($_)"
    }
  }
}

# Default keymaps differ per platform, so Windows has its own
# keys\windows.json. Without one yet, adopt the keymap Herdr wrote here,
# pointing its palette key at my-palette.
$keys = Join-Path $repo 'herdr-app\keys\windows.json'
$liveKeys = Join-Path $herdrApp 'keys.json'
if (-not (Test-Path $keys)) {
  $live = Get-Item -LiteralPath $liveKeys -Force -ErrorAction SilentlyContinue
  if ($live -and -not $live.LinkType) {
    Write-Host "Adopting this machine's Herdr keymap as herdr-app\keys\windows.json (commit it)"
    if (-not $DryRun) {
      $text = [IO.File]::ReadAllText($liveKeys)
      [IO.File]::WriteAllText($keys, $text.Replace('"app.palette"', '"mod.open:my-palette"'))
    }
  } else {
    Write-Host "Skipping Herdr keys: start Herdr once so it writes its Windows keymap, then run this again"
  }
}
if ((Test-Path $keys) -or $DryRun) {
  Install-Link $keys $liveKeys
}

Install-Link (Join-Path $repo 'herdr-app\settings.json') (Join-Path $herdrApp 'settings.json')

foreach ($dir in 'layouts', 'themes') {
  $from = Join-Path $repo "herdr-app\$dir"
  if (Test-Path $from) {
    Get-ChildItem -LiteralPath $from -File | Where-Object { $_.Extension -in '.json', '.svg' } | ForEach-Object {
      Install-Link $_.FullName (Join-Path $herdrApp "$dir\$($_.Name)")
    }
  }
}

$mods = Join-Path $repo 'herdr-app\mods'
if (Test-Path $mods) {
  Get-ChildItem -LiteralPath $mods -Directory | ForEach-Object {
    Install-Link $_.FullName (Join-Path $herdrApp "mods\$($_.Name)")
  }
}

# Agent skills: ~\.agents\skills is read by Codex, pi and other agents;
# Claude Code reads ~\.claude\skills.
$skills = Join-Path $repo 'agents\skills'
if (Test-Path $skills) {
  Get-ChildItem -LiteralPath $skills -Directory | ForEach-Object {
    Install-Link $_.FullName (Join-Path $HOME ".agents\skills\$($_.Name)")
    Install-Link $_.FullName (Join-Path $HOME ".claude\skills\$($_.Name)")
  }
}

if (Test-Path $backupDir) {
  Write-Host "Backup directory: $backupDir"
}
