function Get-CyberConfig {
    <#
    .SYNOPSIS
        Gets the current CyberShell configuration.
    .EXAMPLE
        Get-CyberConfig
    #>
    [CmdletBinding()]
    param()

    return $script:CyberConfig
}

function Set-CyberConfig {
    <#
    .SYNOPSIS
        Updates CyberShell configuration settings.
    .PARAMETER Style
        The prompt style: Powerline, NeonBar, or Minimal.
    .PARAMETER ShowGit
        Whether to show git repository info.
    .PARAMETER ShowExecutionTime
        Whether to show execution time for commands.
    .PARAMETER ExecutionThresholdMs
        Minimum command duration in milliseconds to display execution timer.
    .PARAMETER NotifyOnLongExecution
        Whether to notify/alert on long-running commands.
    .PARAMETER NotifyThresholdSeconds
        Threshold in seconds for long-running execution alerts.
    .PARAMETER SoundEffects
        Whether to enable sound effects (beeps).
    .PARAMETER PathStyle
        Path formatting style: Short or Full.
    .EXAMPLE
        Set-CyberConfig -Style NeonBar -SoundEffects $true
    #>
    [CmdletBinding()]
    param(
        [ValidateSet("Powerline", "NeonBar", "Minimal")]
        [string]$Style,

        [Parameter()]
        [bool]$ShowGit,

        [Parameter()]
        [bool]$ShowExecutionTime,

        [Parameter()]
        [int]$ExecutionThresholdMs,

        [Parameter()]
        [bool]$NotifyOnLongExecution,

        [Parameter()]
        [int]$NotifyThresholdSeconds,

        [Parameter()]
        [bool]$SoundEffects,

        [ValidateSet("Short", "Full")]
        [string]$PathStyle
    )

    if ($PSBoundParameters.ContainsKey('Style')) {
        $script:CyberConfig.style = $Style
    }
    if ($PSBoundParameters.ContainsKey('ShowGit')) {
        $script:CyberConfig.showGit = $ShowGit
    }
    if ($PSBoundParameters.ContainsKey('ShowExecutionTime')) {
        $script:CyberConfig.showExecutionTime = $ShowExecutionTime
    }
    if ($PSBoundParameters.ContainsKey('ExecutionThresholdMs')) {
        $script:CyberConfig.executionTimeThresholdMs = $ExecutionThresholdMs
    }
    if ($PSBoundParameters.ContainsKey('NotifyOnLongExecution')) {
        $script:CyberConfig.notifyOnLongExecution = $NotifyOnLongExecution
    }
    if ($PSBoundParameters.ContainsKey('NotifyThresholdSeconds')) {
        $script:CyberConfig.notifyThresholdSeconds = $NotifyThresholdSeconds
    }
    if ($PSBoundParameters.ContainsKey('SoundEffects')) {
        $script:CyberConfig.soundEffects = $SoundEffects
    }
    if ($PSBoundParameters.ContainsKey('PathStyle')) {
        $script:CyberConfig.pathStyle = $PathStyle
    }

    Write-Host "CyberShell settings updated." -ForegroundColor Cyan
}
