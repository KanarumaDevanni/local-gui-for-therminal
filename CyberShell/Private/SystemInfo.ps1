# ==============================================================================
# CyberShell - System Telemetry Engine
# Retrieves host metrics for Cyber banner and system status
# ==============================================================================

function Get-CyberSystemInfo {
    $info = @{
        OS          = "Windows"
        Uptime      = "N/A"
        RAM         = "N/A"
        RamPercent  = 0
        PSVersion   = $PSVersionTable.PSVersion.ToString()
        PSEdition   = if ($PSVersionTable.PSEdition) { $PSVersionTable.PSEdition } else { "Desktop" }
        User        = $env:USERNAME
        Host        = $env:COMPUTERNAME
    }

    try {
        if ([Environment]::OSVersion.VersionString) {
            $info.OS = [Environment]::OSVersion.VersionString
        }
    } catch {}

    try {
        # Calculate uptime from Environment.TickCount64 (or TickCount)
        $ticks = 0
        if ([Environment]::TickCount -ne $null) {
            $ticks = [Environment]::TickCount
        }
        $ts = [TimeSpan]::FromMilliseconds([Math]::Abs($ticks))
        if ($ts.Days -gt 0) {
            $info.Uptime = "$($ts.Days)d $($ts.Hours)h $($ts.Minutes)m"
        } else {
            $info.Uptime = "$($ts.Hours)h $($ts.Minutes)m"
        }
    } catch {}

    try {
        # Memory check via CIM or WMI
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        if (-not $os) {
            $os = Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue
        }
        if ($os) {
            $totalKb = [double]$os.TotalVisibleMemorySize
            $freeKb = [double]$os.FreePhysicalMemory
            $usedKb = $totalKb - $freeKb
            $totalGb = [Math]::Round($totalKb / 1048576, 1)
            $usedGb = [Math]::Round($usedKb / 1048576, 1)
            $pct = [Math]::Round(($usedKb / $totalKb) * 100)
            $info.RAM = "$usedGb / $totalGb GB ($pct%)"
            $info.RamPercent = $pct
        }
    } catch {}

    return $info
}
