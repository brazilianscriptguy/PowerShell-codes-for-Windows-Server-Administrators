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

    # This FileList enumerates the relevant folders/files 
    # relative to the repository root in GitHub Actions.
    FileList = @(
        # Main module & tests
        'Windows-SysAdmin-ProSuite.psm1'
        'Tests\CommandValidation.Tests.ps1'
        'Tests\ModuleValidation.Tests.ps1'
        '.github\workflows\windows-rsat-pester.yml'

        # Top-level README (repo root)
        'README.md'

        # BlueTeam-Tools folder
        'BlueTeam-Tools\README.md'
        'BlueTeam-Tools\EventLogMonitoring\EventID-Count-AllEvtx-Events.ps1'
        'BlueTeam-Tools\EventLogMonitoring\EventID307-PrintAudit.ps1'
        'BlueTeam-Tools\EventLogMonitoring\EventID4624-ADUserLoginViaRDP.ps1'
        'BlueTeam-Tools\EventLogMonitoring\EventID4624and4634-ADUserLoginTracking.ps1'
        'BlueTeam-Tools\EventLogMonitoring\EventID4625-ADUserLoginAccountFailed.ps1'
        'BlueTeam-Tools\EventLogMonitoring\EventID4648-ExplicitCredentialsLogon.ps1'
        'BlueTeam-Tools\EventLogMonitoring\EventID4660and4663-ObjectDeletionTracking.ps1'
        'BlueTeam-Tools\EventLogMonitoring\EventID4771-KerberosPreAuthFailed.ps1'
        'BlueTeam-Tools\EventLogMonitoring\EventID4800and4801-WorkstationLockStatus.ps1'
        'BlueTeam-Tools\EventLogMonitoring\EventID5136-5137and5141-ADChanges-and-ObjectDeletions.ps1'
        'BlueTeam-Tools\EventLogMonitoring\EventID6005-6006-6008-6009-6013-1074-1076-SystemRestarts.ps1'
        'BlueTeam-Tools\EventLogMonitoring\Migrate-WinEvtStructure-Tool.ps1'
        'BlueTeam-Tools\EventLogMonitoring\README.md'
    )
}

# End of script
