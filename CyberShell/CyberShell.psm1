# ==============================================================================
# CyberShell - Next-Gen Aesthetic Terminal Mod for PowerShell
# Author: CyberShell Contributors
# License: MIT
# ==============================================================================

$ModuleRoot = $PSScriptRoot

# 1. Load Private helpers
$privateScripts = Get-ChildItem -Path (Join-Path $ModuleRoot "Private") -Filter "*.ps1" -ErrorAction SilentlyContinue
foreach ($file in $privateScripts) {
    . $file.FullName
}

# 2. Load Public functions
$publicScripts = Get-ChildItem -Path (Join-Path $ModuleRoot "Public") -Filter "*.ps1" -ErrorAction SilentlyContinue
foreach ($file in $publicScripts) {
    . $file.FullName
}

# 3. Initialize Configuration
$configFile = Join-Path $ModuleRoot "Config\default.json"
if (Test-Path $configFile) {
    try {
        $script:CyberConfig = Get-Content -Path $configFile -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        $script:CyberConfig = [PSCustomObject]@{
            theme                    = "cyberpunk-2077"
            style                    = "Powerline"
            showBannerOnStartup      = $true
            showGit                  = $true
            showExecutionTime        = $true
            executionTimeThresholdMs = 1000
            notifyOnLongExecution    = $true
            notifyThresholdSeconds   = 5
            showExitCode             = $true
            pathStyle                = "Short"
            showTimestamp            = $false
            soundEffects             = $false
        }
    }
}

# 4. Load Active Theme
$initialThemeName = if ($script:CyberConfig.theme) { $script:CyberConfig.theme } else { "neon-pulse" }
$initialThemeFile = Join-Path $ModuleRoot "Themes\$initialThemeName.json"
if (Test-Path $initialThemeFile) {
    try {
        $script:CyberTheme = Get-Content -Path $initialThemeFile -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        $script:CyberTheme = [PSCustomObject]@{
            name   = "neon-pulse"
            colors = @{ primary = "#FCEE09"; secondary = "#00F0FF"; text = "#FFFFFF" }
        }
    }
}

# 5. Define Aliases
Set-Alias -Name matrix -Value Start-CyberMatrix -Scope Global -ErrorAction SilentlyContinue
Set-Alias -Name cyberclock -Value Show-CyberClock -Scope Global -ErrorAction SilentlyContinue
Set-Alias -Name cyberbanner -Value Show-CyberBanner -Scope Global -ErrorAction SilentlyContinue
Set-Alias -Name cybershell -Value Enable-CyberShell -Scope Global -ErrorAction SilentlyContinue

# 6. Export Functions and Aliases
Export-ModuleMember -Function @(
    "Enable-CyberShell",
    "Disable-CyberShell",
    "Get-CyberTheme",
    "Set-CyberTheme",
    "Show-CyberBanner",
    "Start-CyberMatrix",
    "Show-CyberClock",
    "Get-CyberConfig",
    "Set-CyberConfig"
) -Alias @(
    "matrix",
    "cyberclock",
    "cyberbanner",
    "cybershell"
)
