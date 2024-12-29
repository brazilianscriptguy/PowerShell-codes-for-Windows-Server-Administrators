<#
.SYNOPSIS
    Validates the .psd1 manifest & exported commands

.DESCRIPTION
    Verifies the .psd1 loads with Test-ModuleManifest,
    and ensures the .psm1 exports expected commands.

#>

Describe 'Module-ProSuite Validation' {
    $ManifestPath = $Env:MODULE_FILE
    if (-not $ManifestPath) {
        throw "MODULE_FILE is null or empty. Can't validate manifest!"
    }

    $ModulePath = [System.IO.Path]::ChangeExtension($ManifestPath, '.psm1')

    It 'Should load the .psd1 manifest without errors' {
        Test-Path -Path $ManifestPath | Should -BeTrue
        { Test-ModuleManifest -Path $ManifestPath } | Should -Not -Throw
    }

    It 'Should export expected commands' {
        Test-Path -Path $ModulePath | Should -BeTrue

        # Importing the .psm1 here is safe because we do not rely on mocking in this test
        $mod = Import-Module $ModulePath -Force -PassThru
        $Exported = $mod.ExportedCommands.Keys
        $Expected = @('Get-UserInfo','Test-SysAdminFeature')
        $Exported | Should -ContainEveryItemOf $Expected
    }
}

# End of script
