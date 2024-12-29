<#
.SYNOPSIS
    Pester Tests: Validate Manifest-ProSuite.psd1

.DESCRIPTION
    Ensures the module loads, passes Test-ModuleManifest,
    and exports expected commands.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 29, 2024
#>

Describe 'Module-ProSuite Validation' {
    $ManifestPath = $Env:MODULE_FILE
    if (-not $ManifestPath) {
        throw "Environment variable MODULE_FILE is null/empty! Cannot test manifest."
    }

    $ModulePath = [System.IO.Path]::ChangeExtension($ManifestPath, '.psm1')

    It 'Should load the .psd1 manifest without errors' {
        Test-Path -Path $ManifestPath | Should -BeTrue
        { Test-ModuleManifest -Path $ManifestPath } | Should -Not -Throw
    }

    It 'Should export expected commands' {
        Test-Path -Path $ModulePath | Should -BeTrue

        $Imported = Import-Module $ModulePath -Force -PassThru
        $Exported = $Imported.ExportedCommands.Keys
        $Expected = @('Get-UserInfo','Test-SysAdminFeature')
        $Exported | Should -ContainEveryItemOf $Expected
    }
}

# End of script
