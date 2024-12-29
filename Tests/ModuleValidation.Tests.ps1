Describe 'Windows-SysAdmin-ProSuite Module Validation' {
    # Use the .psd1 from the environment variable
    $ManifestPath = $Env:MODULE_FILE
    # Compute the corresponding .psm1 path by replacing .psd1 with .psm1
    $ModulePath   = [System.IO.Path]::ChangeExtension($ManifestPath, '.psm1')

    It 'Should load the module manifest without errors' {
        Test-Path -Path $ManifestPath | Should -BeTrue
        { Test-ModuleManifest -Path $ManifestPath } | Should -Not -Throw
    }

    It 'Should export all expected commands' {
        Test-Path -Path $ModulePath | Should -BeTrue
        # Import the .psm1 and check exported commands
        $ExportedCmdlets = (Import-Module -Name $ModulePath -PassThru).ExportedCommands.Keys
        $ExpectedCmdlets = @('Get-UserInfo', 'Test-SysAdminFeature')
        $ExportedCmdlets | Should -ContainEveryItemOf $ExpectedCmdlets
    }
}
