function Get-CyberTheme {
    <#
    .SYNOPSIS
        Lists all available CyberShell themes or returns the current theme.
    .EXAMPLE
        Get-CyberTheme -ListAvailable
    #>
    [CmdletBinding()]
    param(
        [switch]$ListAvailable
    )

    if ($ListAvailable) {
        $themesDir = [System.IO.Path]::Combine($PSScriptRoot, "..", "Themes")
        $themeFiles = Get-ChildItem -Path $themesDir -Filter "*.json"
        
        $results = @()
        foreach ($file in $themeFiles) {
            try {
                $raw = Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
                $isCurrent = ($raw.name -eq $script:CyberTheme.name)
                $results += [PSCustomObject]@{
                    Name        = $raw.name
                    DisplayName = $raw.displayName
                    Current     = if ($isCurrent) { "● active" } else { "" }
                    File        = $file.Name
                }
            } catch {}
        }
        return $results
    }

    return $script:CyberTheme
}

function Set-CyberTheme {
    <#
    .SYNOPSIS
        Changes the active CyberShell theme.
    .PARAMETER Name
        The name of the theme (e.g. cyberpunk-2077, synthwave-84, matrix, tokyo-night, blood-moon, ghost-white).
    .EXAMPLE
        Set-CyberTheme -Name synthwave-84
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet("neon-pulse", "retro-wave", "digital-rain", "midnight-cyan", "crimson-dusk", "arctic-frost")]
        [string]$Name
    )

    $themeFile = [System.IO.Path]::Combine($PSScriptRoot, "..", "Themes", "$Name.json")
    if (-not (Test-Path $themeFile)) {
        Write-Error "Theme '$Name' not found at $themeFile"
        return
    }

    try {
        $loadedTheme = Get-Content -Path $themeFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $script:CyberTheme = $loadedTheme
        $script:CyberConfig.theme = $Name

        $primary = if ($loadedTheme.colors.primary) { $loadedTheme.colors.primary } else { "#00F0FF" }
        $secondary = if ($loadedTheme.colors.secondary) { $loadedTheme.colors.secondary } else { "#FF007F" }

        Write-Host (Format-CyberGradient -Text "⚡ CyberShell theme switched to: $($loadedTheme.displayName)" -FromHex $primary -ToHex $secondary)
    } catch {
        Write-Error "Failed to load theme: $_"
    }
}
