<#
.SYNOPSIS
    Windows-SysAdmin-ProSuite Module Manifest

.DESCRIPTION
    This file specifies metadata, exports, and file references for the Windows-SysAdmin-ProSuite module.
    It includes a FileList that enumerates the relevant folders/files in your GitHub repository.

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

    # This FileList should reflect your GitHub folder structure
    FileList = @(
        'Windows-SysAdmin-ProSuite.psm1',
        'Tests\CommandValidation.Tests.ps1',
        'Tests\ModuleValidation.Tests.ps1',
        '.github\workflows\windows-rsat-pester.yml'
    )
}

# End of script
