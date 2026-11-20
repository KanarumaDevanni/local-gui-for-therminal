function Show-CyberBanner {
    <#
    .SYNOPSIS
        Displays the CyberShell neon ASCII logo and system telemetry banner.
    .EXAMPLE
        Show-CyberBanner
    #>
    [CmdletBinding()]
    param()

    $theme = $script:CyberTheme
    $primary = if ($theme.colors.primary) { $theme.colors.primary } else { "#00F0FF" }
    $secondary = if ($theme.colors.secondary) { $theme.colors.secondary } else { "#FF003C" }
    $muted = if ($theme.colors.muted) { $theme.colors.muted } else { "#555566" }
    $accent = if ($theme.colors.accent) { $theme.colors.accent } else { "#FCEE09" }

    $logo = @'
   ______      __               _____ __          ____
  / ____/_  __/ /_  ___  _____ / ___// /_  ___   / / /
 / /   / / / / __ \/ _ \/ ___/ \__ \/ __ \/ _ \ / / / 
/ /___/ /_/ / /_/ /  __/ /    ___/ / / / /  __// / /  
\____/\__, /_.___/\___/_/    /____/_/ /_/\___//_/_/   
     /____/                                           
'@

    Write-Host ""
    $lines = $logo.Split("`n")
    foreach ($line in $lines) {
        Write-Host (Format-CyberGradient -Text $line.TrimEnd("`r") -FromHex $primary -ToHex $secondary)
    }

    $info = Get-CyberSystemInfo
    $themeTitle = if ($theme.displayName) { $theme.displayName } else { "Default" }

    $boxBorder = Format-CyberFg -Hex $muted
    $labelFg = Format-CyberFg -Hex $primary
    $valFg = Format-CyberFg -Hex "#FFFFFF"
    $accentFg = Format-CyberFg -Hex $accent
    $rst = $script:RESET
    $bld = $script:BOLD

    Write-Host "$boxBorder  ┌────────────────────────────────────────────────────────────┐$rst"
    Write-Host "$boxBorder  │ $labelFg$bld HOST   $rst${boxBorder}: $valFg$($info.User)@$($info.Host) $accentFg[$($info.OS)]$rst"
    Write-Host "$boxBorder  │ $labelFg$bld UPTIME $rst${boxBorder}: $valFg$($info.Uptime)$rst"
    Write-Host "$boxBorder  │ $labelFg$bld MEMORY $rst${boxBorder}: $valFg$($info.RAM)$rst"
    Write-Host "$boxBorder  │ $labelFg$bld ENGINE $rst${boxBorder}: ${valFg}PowerShell $($info.PSVersion) ($($info.PSEdition))$rst"
    Write-Host "$boxBorder  │ $labelFg$bld THEME  $rst${boxBorder}: $accentFg$bld$themeTitle$rst"
    Write-Host "$boxBorder  └────────────────────────────────────────────────────────────┘$rst"
    Write-Host ""
}
