<#
.SYNOPSIS
    PowerShell Script Template for Structured and Maintainable PowerShell Projects.

.DESCRIPTION
    Provides a reusable framework with standardized logging, error handling, dynamic paths, 
    and GUI integration. Suitable for building robust and maintainable PowerShell tools.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 29, 2024
#>

@{
    RootModule        = 'Windows-SysAdmin-ProSuite.psm1'
    ModuleVersion     = '1.0.4'
    Author            = 'Luiz Hamilton Silva - @brazilianscriptguy'
    CompanyName       = '@brazilianscriptguy'
    Copyright         = '(c) 2024'
    Description       = 'PowerShell module for advanced Windows SysAdmin tasks, includes ActiveDirectory integration.'
    GUID              = 'f81ecf42-2c94-4ad9-a7d1-bb8f580de39b'

    FunctionsToExport = @('Get-UserInfo', 'Test-SysAdminFeature')
    CmdletsToExport   = @()
    VariablesToExport = @('*')
    AliasesToExport   = @()

    PrivateData = @{
        ProjectUri   = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite'
        LicenseUri   = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite/blob/main/LICENSE'
        ReleaseNotes = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite/releases'
    }

    PowerShellVersion = '5.1'

    FileList = @(
        'Windows-SysAdmin-ProSuite.psm1',
        'Tests\CommandValidation.Tests.ps1',
        'Tests\ModuleValidation.Tests.ps1'
    )
}

# End of script
