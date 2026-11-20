# ==============================================================================
# CyberShell - One-Step Installer Script
# ==============================================================================

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$NoProfile
)

Write-Host "`n⚡ Installing CyberShell Terminal Mod...`n" -ForegroundColor Cyan

# 1. Determine User Module Destination
$isCore = ($PSVersionTable.PSEdition -eq "Core")
$moduleDirName = if ($isCore) { "PowerShell" } else { "WindowsPowerShell" }
$targetParent = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "$moduleDirName\Modules"
$targetModulePath = Join-Path $targetParent "CyberShell"

$sourceModulePath = Join-Path $PSScriptRoot "CyberShell"
if (-not (Test-Path $sourceModulePath)) {
    Write-Error "Source CyberShell folder not found at $sourceModulePath"
    exit 1
}

# 2. Copy Files
Write-Host ">>> Deploying module files to: $targetModulePath" -ForegroundColor DarkGray
if (-not (Test-Path $targetParent)) {
    New-Item -Path $targetParent -ItemType Directory -Force | Out-Null
}

if (Test-Path $targetModulePath) {
    Remove-Item -Path $targetModulePath -Recurse -Force | Out-Null
}

Copy-Item -Path $sourceModulePath -Destination $targetModulePath -Recurse -Force
Write-Host "    [OK] Module files installed successfully." -ForegroundColor Green

# 3. Configure PowerShell Profile
if (-not $NoProfile) {
    $profilePath = $PROFILE
    $profileDir = Split-Path -Parent $profilePath

    if (-not (Test-Path $profileDir)) {
        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    }

    if (-not (Test-Path $profilePath)) {
        New-Item -Path $profilePath -ItemType File -Force | Out-Null
    }

    $profileContent = Get-Content -Path $profilePath -Raw -ErrorAction SilentlyContinue
    if (-not $profileContent) { $profileContent = "" }

    $snippet = @"

# >>> CyberShell Terminal Mod >>>
Import-Module CyberShell
Enable-CyberShell
# <<< CyberShell Terminal Mod <<<
"@

    if ($profileContent -notmatch "CyberShell Terminal Mod") {
        Add-Content -Path $profilePath -Value $snippet
        Write-Host "    [OK] Added CyberShell startup hook to `$PROFILE: $profilePath" -ForegroundColor Green
    } else {
        Write-Host "    [OK] `$PROFILE already configured with CyberShell." -ForegroundColor Yellow
    }
}

# 4. Check Execution Policy
$currPolicy = Get-ExecutionPolicy
if ($currPolicy -in @("Restricted", "Undefined")) {
    Write-Host "`n[NOTE] PowerShell ExecutionPolicy is '$currPolicy'." -ForegroundColor Yellow
    Write-Host "To allow scripts to run in your user account, execute:" -ForegroundColor Yellow
    Write-Host "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Cyan
}

Write-Host "`n⚡ Installation complete! Restart PowerShell or run: Import-Module CyberShell; Enable-CyberShell`n" -ForegroundColor Green
