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

Describe 'Windows-SysAdmin-ProSuite Module Validation' {

    $ManifestPath = $Env:MODULE_FILE
    $ModulePath   = [System.IO.Path]::ChangeExtension($ManifestPath, '.psm1')

    It 'Should load the module manifest without errors' {
        Test-Path -Path $ManifestPath | Should -BeTrue
        { Test-ModuleManifest -Path $ManifestPath } | Should -Not -Throw
    }

    It 'Should export all expected commands' {
        Test-Path -Path $ModulePath | Should -BeTrue

        $ImportedModule = Import-Module $ModulePath -Force -PassThru
        $ExportedCmdlets = $ImportedModule.ExportedCommands.Keys
        $ExpectedCmdlets = @('Get-UserInfo', 'Test-SysAdminFeature')

        $ExportedCmdlets | Should -ContainEveryItemOf $ExpectedCmdlets
    }
}

# End of script
