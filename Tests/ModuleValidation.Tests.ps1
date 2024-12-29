<#
.SYNOPSIS
    Pester Tests for Module Validation in Windows-SysAdmin-ProSuite

.DESCRIPTION
    Verifies the .psd1 manifest, checks that the module loads without errors,
    and confirms that all expected commands are exported.

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
