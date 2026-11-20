function Disable-CyberShell {
    <#
    .SYNOPSIS
        Deactivates CyberShell and restores the default PowerShell prompt.
    .EXAMPLE
        Disable-CyberShell
    #>
    [CmdletBinding()]
    param()

    if ($script:OriginalPromptFunction) {
        Set-Item -Path function:prompt -Value $script:OriginalPromptFunction
    } else {
        Set-Item -Path function:prompt -Value { "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) " }
    }

    Write-Host "CyberShell deactivated. Restored standard prompt." -ForegroundColor DarkGray
}
