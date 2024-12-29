@{
    # Module manifest for module 'Windows-SysAdmin-ProSuite'
    RootModule        = 'Windows-SysAdmin-ProSuite.psm1'
    ModuleVersion     = '1.0.1'
    Author            = 'Luiz Hamilton Silva - @brazilianscriptguy'
    CompanyName       = '@brazilianscriptguy'
    Copyright         = "(c) Luiz Hamilton Silva - @brazilianscriptguy. All rights reserved."
    Description       = 'A PowerShell module for advanced Windows system administration, tailored for Active Directory, ITSM, and forensic tasks.'
    GUID              = 'f81ecf42-2c94-4ad9-a7d1-bb8f580de39b'

    # Functions to export from this module
    FunctionsToExport = @('*')

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @('*')

    # Aliases to export from this module
    AliasesToExport   = @()

    # Private data specific to this module
    PrivateData = @{
        Tags         = @('active-directory', 'sysadmin', 'siem', 'itsm', 'workstations', 'audit-log', 'admin-tools', 'customize', 'blueteam', 'active-directory-domain-services', 'evtx-analisys', 'sysadmin-tasks', 'sysadmin-tool', 'sysadmin-scripts', 'eventlogs', 'windows-server-2019', 'organizational-units', 'forensics-tools', 'itsm-solutions')
        ProjectUri   = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite'
        LicenseUri   = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite/blob/main/.github/LICENSE'
        ReleaseNotes = 'https://github.com/brazilianscriptguy/Windows-SysAdmin-ProSuite/releases/tag/Windows-SysAdmin-ProSuite'
    }

    # Minimum version of PowerShell required to use this module
    PowerShellVersion = '5.1'

    # External modules required by this module
    RequiredModules   = @()

    # External assemblies required by this module
    RequiredAssemblies = @()

    # Modules to process before this module
    NestedModules     = @()

    # Formats to export from this module
    FormatsToProcess  = @()

    # Types to export from this module
    TypesToProcess    = @()

    # Scripts to process before this module
    ScriptsToProcess  = @()

    # File list from repository structure
    FileList          = @(
        'BlueTeam-Tools\EventLogMonitoring',
        'BlueTeam-Tools\IncidentResponse',
        'Core-ScriptLibrary',
        'ITSM-Templates-SVR',
        'ITSM-Templates-WKS\Certificates',
        'SysAdmin-Tools\ActiveDirectory-Management',
        'SysAdmin-Tools\GroupPolicyObjects-Templates\enable-audit-logs-DC-servers',
        'SysAdmin-Tools\GroupPolicyObjects-Templates\disable-firewall-domain-workstations',
        'ITSM-Templates-WKS\ModifyReg\UserDesktopFolders\My Corporate Web Portals',
        'SysAdmin-Tools\Security-and-Process-Optimization'
    )
}
