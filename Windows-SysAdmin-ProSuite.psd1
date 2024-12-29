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

    # This FileList enumerates all relevant folders and files in Windows-SysAdmin-ProSuite-main\Core-ScriptLibrary,
    # as well as other module and test files in your repository.
    FileList = @(
        # Existing module & tests
        'Windows-SysAdmin-ProSuite.psm1'
        'Tests\CommandValidation.Tests.ps1'
        'Tests\ModuleValidation.Tests.ps1'
        '.github\workflows\windows-rsat-pester.yml'

        # Core-ScriptLibrary structure
        'Windows-SysAdmin-ProSuite-main\Core-ScriptLibrary\Create-Script-DefaultHeader.ps1'
        'Windows-SysAdmin-ProSuite-main\Core-ScriptLibrary\Create-Script-LoggingMethod.ps1'
        'Windows-SysAdmin-ProSuite-main\Core-ScriptLibrary\Create-Script-MainCore.ps1'
        'Windows-SysAdmin-ProSuite-main\Core-ScriptLibrary\Create-Script-MainGUI.ps1'
        'Windows-SysAdmin-ProSuite-main\Core-ScriptLibrary\Extract-Script-Headers.ps1'
        'Windows-SysAdmin-ProSuite-main\Core-ScriptLibrary\Launch-Script-AutomaticMenu.ps1'
        'Windows-SysAdmin-ProSuite-main\Core-ScriptLibrary\README.md'
    )
}

# End of script
