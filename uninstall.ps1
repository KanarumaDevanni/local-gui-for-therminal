# ==============================================================================
# CyberShell - Clean Uninstaller Script
# ==============================================================================

Write-Host "`n⚡ Uninstalling CyberShell...`n" -ForegroundColor Yellow

$isCore = ($PSVersionTable.PSEdition -eq "Core")
$moduleDirName = if ($isCore) { "PowerShell" } else { "WindowsPowerShell" }
$targetModulePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "$moduleDirName\Modules\CyberShell"

if (Test-Path $targetModulePath) {
    Remove-Item -Path $targetModulePath -Recurse -Force
    Write-Host "    [OK] Removed module directory: $targetModulePath" -ForegroundColor Green
} else {
    Write-Host "    [INFO] Module folder not found at $targetModulePath" -ForegroundColor DarkGray
}

$profilePath = $PROFILE
if (Test-Path $profilePath) {
    $content = Get-Content -Path $profilePath -Raw
    if ($content -match "CyberShell Terminal Mod") {
        $cleaned = $content -replace "(?ms)\r?\n# >>> CyberShell Terminal Mod >>>.*?# <<< CyberShell Terminal Mod <<<\r?\n", ""
        Set-Content -Path $profilePath -Value $cleaned -Force
        Write-Host "    [OK] Removed CyberShell hook from `$PROFILE" -ForegroundColor Green
    }
}

Write-Host "`n⚡ CyberShell successfully uninstalled. You can restart PowerShell.`n" -ForegroundColor Green
