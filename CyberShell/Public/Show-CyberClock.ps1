function Show-CyberClock {
    <#
    .SYNOPSIS
        Displays a cyberpunk live digital clock in the terminal. Press any key to exit.
    .EXAMPLE
        Show-CyberClock
    #>
    [CmdletBinding()]
    param()

    $origCursor = [Console]::CursorVisible
    try {
        [Console]::CursorVisible = $false
        [Console]::Clear()

        $theme = $script:CyberTheme
        $primary = if ($theme.colors.primary) { $theme.colors.primary } else { "#00F0FF" }
        $secondary = if ($theme.colors.secondary) { $theme.colors.secondary } else { "#FF007F" }
        $accent = if ($theme.colors.accent) { $theme.colors.accent } else { "#FCEE09" }

        while ([Console]::KeyAvailable) { [void][Console]::ReadKey($true) }

        while (-not [Console]::KeyAvailable) {
            $now = Get-Date
            $timeStr = $now.ToString("HH : mm : ss")
            $dateStr = $now.ToString("dddd, dd MMMM yyyy")

            [Console]::SetCursorPosition(0, 2)
            Write-Host (Format-CyberGradient -Text "     ╔════════════════════════════════════════╗" -FromHex $primary -ToHex $secondary)
            Write-Host (Format-CyberGradient -Text "     ║          CYBERSHELL TIME SYNC          ║" -FromHex $primary -ToHex $secondary)
            Write-Host (Format-CyberGradient -Text "     ╠════════════════════════════════════════╣" -FromHex $primary -ToHex $secondary)
            Write-Host "     ║" -NoNewline
            Write-Host (Format-CyberFg -Hex $accent -Text "            $timeStr           ") -NoNewline
            Write-Host "║"
            Write-Host (Format-CyberGradient -Text "     ╠════════════════════════════════════════╣" -FromHex $primary -ToHex $secondary)
            Write-Host "     ║" -NoNewline
            $paddedDate = $dateStr.PadLeft(32).PadRight(40)
            Write-Host (Format-CyberFg -Hex "#FFFFFF" -Text $paddedDate) -NoNewline
            Write-Host "║"
            Write-Host (Format-CyberGradient -Text "     ╚════════════════════════════════════════╝" -FromHex $primary -ToHex $secondary)
            Write-Host ""
            Write-Host "       Press any key to return to terminal..." -ForegroundColor DarkGray

            Start-Sleep -Milliseconds 500
        }

        [void][Console]::ReadKey($true)
        [Console]::Clear()
    } finally {
        [Console]::CursorVisible = $origCursor
    }
}
