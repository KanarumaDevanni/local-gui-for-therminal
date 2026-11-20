@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'CyberShell.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'e69837a1-872f-4c54-9cf8-6936d53862b5'

    # Author of this module
    Author = 'CyberShell Contributors'

    # Company or vendor of this module
    CompanyName = 'Open Source Community'

    # Copyright statement for this module
    Copyright = '(c) 2026. MIT License.'

    # Description of the functionality provided by this module
    Description = 'Next-gen cyberpunk terminal aesthetic, zero-overhead Git status, execution telemetry, themes, and visual FX for PowerShell.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards
    FunctionsToExport = @(
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

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @(
        'matrix',
        'cyberclock',
        'cyberbanner',
        'cybershell'
    )

    # Private data to pass to the module specified in RootModule
    PrivateData = @{
        PSData = @{
            Tags = @('Cyberpunk', 'Terminal', 'Prompt', 'Git', 'OhMyPosh', 'Theme', 'CLI', 'Aesthetic', 'Matrix')
            LicenseUri = 'https://raw.githubusercontent.com/username/CyberShell/main/LICENSE'
            ProjectUri = 'https://github.com/username/CyberShell'
        }
    }
}
