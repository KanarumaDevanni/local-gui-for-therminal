# ==============================================================================
# CyberShell - Test Suite
# Tests manifest validation, syntax, exported cmdlets, themes, and prompt engine
# ==============================================================================

$root = Split-Path -Parent $PSScriptRoot
$moduleManifest = Join-Path $root "CyberShell\CyberShell.psd1"

Write-Host "`n>>> Running CyberShell Automated Tests...`n" -ForegroundColor Cyan

$passed = 0
$failed = 0

function Assert-Test {
    param(
        [string]$Description,
        [scriptblock]$Test
    )
    try {
        $result = & $Test
        if ($result -ne $false) {
            Write-Host "  [PASS] $Description" -ForegroundColor Green
            $script:passed++
        } else {
            Write-Host "  [FAIL] $Description" -ForegroundColor Red
            $script:failed++
        }
    } catch {
        Write-Host "  [FAIL] ${Description}: $_" -ForegroundColor Red
        $script:failed++
    }
}

# 1. Manifest Test
Assert-Test "Module manifest validates cleanly" {
    $manifest = Test-ModuleManifest -Path $moduleManifest -ErrorAction Stop
    $manifest -ne $null -and $manifest.Version -eq [Version]"1.0.0"
}

# 2. Module Import Test
Assert-Test "Module imports without throwing errors" {
    Remove-Module CyberShell -ErrorAction SilentlyContinue
    Import-Module $moduleManifest -Force -ErrorAction Stop
    $mod = Get-Module CyberShell
    $mod -ne $null
}

# 3. Exported Functions Test
Assert-Test "All expected public cmdlets are exported" {
    $expected = @(
        'Enable-CyberShell',
        'Disable-CyberShell',
        'Get-CyberTheme',
        'Set-CyberTheme',
        'Show-CyberBanner',
        'Start-CyberMatrix',
        'Show-CyberClock',
        'Get-CyberConfig',
        'Set-CyberConfig'
    )
    $actual = (Get-Command -Module CyberShell -CommandType Function).Name
    $missing = $expected | Where-Object { $actual -notcontains $_ }
    $missing.Count -eq 0
}

# 4. Themes Loading Test
Assert-Test "All theme files are valid JSON and contain required color keys" {
    $themes = Get-CyberTheme -ListAvailable
    if ($themes.Count -lt 5) { return $false }

    $allValid = $true
    foreach ($t in $themes) {
        $path = Join-Path $root "CyberShell\Themes\$($t.File)"
        $json = Get-Content $path -Raw | ConvertFrom-Json
        if (-not $json.colors.primary -or -not $json.colors.secondary -or -not $json.symbols.prompt) {
            $allValid = $false
        }
    }
    return $allValid
}

# 5. Switch Theme Test
Assert-Test "Set-CyberTheme updates active theme successfully" {
    Set-CyberTheme -Name "retro-wave"
    $active = Get-CyberTheme
    $active.name -eq "retro-wave"
}

# 6. Prompt Rendering Test
Assert-Test "Render-CyberPrompt executes without exceptions" {
    $promptStr = & (Get-Module CyberShell) { Render-CyberPrompt }
    [string]::IsNullOrEmpty($promptStr) -eq $false
}

# 7. System Info Test
Assert-Test "Get-CyberSystemInfo returns host telemetry" {
    $info = & (Get-Module CyberShell) { Get-CyberSystemInfo }
    $info.OS -ne $null -and $info.PSVersion -ne $null
}

Write-Host "`n==========================================" -ForegroundColor DarkGray
$resultColor = if ($failed -eq 0) { "Green" } else { "Red" }
Write-Host "Results: $passed Passed, $failed Failed" -ForegroundColor $resultColor
Write-Host "==========================================`n" -ForegroundColor DarkGray

if ($failed -gt 0) {
    exit 1
} else {
    exit 0
}
