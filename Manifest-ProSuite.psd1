<#
.SYNOPSIS
    Windows-SysAdmin-ProSuite Module Manifest

.DESCRIPTION
    Specifies metadata, exports, and file references for Module-ProSuite.psm1.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 29, 2024
#>

@{
    RootModule        = 'Module-ProSuite.psm1'
    ModuleVersion     = '1.0.4'
    Author            = 'Luiz Hamilton Silva - @brazilianscriptguy'
    CompanyName       = '@brazilianscriptguy'
    Description       = 'PowerShell module for advanced Windows SysAdmin tasks, includes ActiveDirectory integration.'
    GUID              = 'f81ecf42-2c94-4ad9-a7d1-bb8f580de39b'
    PowerShellVersion = '5.1'

    FunctionsToExport = @('Get-UserInfo', 'Test-SysAdminFeature')
    CmdletsToExport   = @()
    VariablesToExport = @('*')
    AliasesToExport   = @()

    PrivateData = @{
        ProjectUri   = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite'
        LicenseUri   = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite/blob/main/LICENSE'
        ReleaseNotes = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite/releases'
    }

    # FileList enumerates relevant folders/files in the repository
    FileList = @(
        'Module-ProSuite.psm1'
        'Tests\01-CommandValidation.Tests.ps1'
        'Tests\02-ModuleValidation.Tests.ps1'
        'Tests\README.md'
        '.github\workflows\windows-rsat-pester.yml'
        'Manifest-ProSuite.psd1'
    )
}

# End of script
