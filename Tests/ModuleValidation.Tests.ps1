Describe 'Windows-SysAdmin-ProSuite Module Validation' {

    # Pull the .psd1 path from the environment variable
    $ManifestPath = $Env:MODULE_FILE

    # Construct the matching .psm1 path by swapping .psd1 for .psm1
    $ModulePath   = [System.IO.Path]::ChangeExtension($ManifestPath, '.psm1')

    It 'Should load the module manifest without errors' {
        # Ensure $ManifestPath is not null or empty
        Test-Path -Path $ManifestPath | Should -BeTrue -Because "Manifest path should exist."
        { Test-ModuleManifest -Path $ManifestPath } | Should -Not -Throw
    }

    It 'Should export all expected commands' {
        # Ensure $ModulePath is valid
        Test-Path -Path $ModulePath | Should -BeTrue -Because "Module path should exist."

        # Import the module from $ModulePath, then retrieve its exported commands
        # Use -Force/-PassThru to avoid "Parameter set cannot be resolved" errors
        $ImportedModule = Import-Module $ModulePath -Force -PassThru
        $ExportedCmdlets = $ImportedModule.ExportedCommands.Keys

        $ExpectedCmdlets = @('Get-UserInfo', 'Test-SysAdminFeature')

        $ExportedCmdlets | Should -ContainEveryItemOf $ExpectedCmdlets `
            -Because "The module should export all expected commands."
    }
}
