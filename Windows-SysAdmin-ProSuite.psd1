@{
    RootModule        = 'Windows-SysAdmin-ProSuite.psm1'
    ModuleVersion     = '1.0.4'
    Author            = 'Luiz Hamilton Silva - @brazilianscriptguy'
    CompanyName       = '@brazilianscriptguy'
    Copyright         = "(c) Luiz Hamilton Silva - @brazilianscriptguy. All rights reserved."
    Description       = 'PowerShell module for advanced Windows system administration tasks, including Active Directory and ITSM support.'
    GUID              = 'f81ecf42-2c94-4ad9-a7d1-bb8f580de39b'

    FunctionsToExport = @('Get-UserInfo', 'Test-SysAdminFeature')
    CmdletsToExport   = @()
    VariablesToExport = @('*')
    AliasesToExport   = @()

    PrivateData = @{
        Tags = @('active-directory', 'sysadmin', 'itsm', 'windows', 'powershell', 'blueteam', 'eventlogs')
        ProjectUri   = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite'
        LicenseUri   = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite/blob/main/.github/LICENSE'
        ReleaseNotes = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite/releases'
    }

    PowerShellVersion = '5.1'

    FileList = @(
        'BlueTeam-Tools\EventLogMonitoring',
        'Core-ScriptLibrary',
        'Tests\CommandValidation.Tests.ps1',
        'Tests\ModuleValidation.Tests.ps1',
        'README.md'
    )
}
