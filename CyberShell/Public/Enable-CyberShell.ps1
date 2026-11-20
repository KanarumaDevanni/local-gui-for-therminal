function Enable-CyberShell {
    <#
    .SYNOPSIS
        Activates the CyberShell cyberpunk prompt theme and telemetry.
    .EXAMPLE
        Enable-CyberShell
    #>
    [CmdletBinding()]
    param()

    # Backup existing prompt if not already backed up
    if (-not $script:OriginalPromptFunction -and (Test-Path function:prompt)) {
        $script:OriginalPromptFunction = (Get-Item function:prompt).ScriptBlock
    }

    # Hook prompt
    Set-Item -Path function:prompt -Value {
        Render-CyberPrompt
    }

    $themeName = if ($script:CyberTheme.displayName) { $script:CyberTheme.displayName } else { "CyberShell" }
    $primaryColor = if ($script:CyberTheme.colors.primary) { $script:CyberTheme.colors.primary } else { "#00F0FF" }

    Write-Host (Format-CyberGradient -Text "⚡ CyberShell activated [$themeName]" -FromHex $primaryColor -ToHex "#FF007F")
}
