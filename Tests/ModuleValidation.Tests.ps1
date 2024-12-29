Describe 'Windows-SysAdmin-ProSuite Module Validation' {

    # 1) Pull the .psd1 path from the environment variable
    $ManifestPath = $Env:MODULE_FILE
    # 2) Construct the .psm1 path by swapping .psd1 for .psm1
    $ModulePath   = [System.IO.Path]::ChangeExtension($ManifestPath, '.psm1')

    It 'Should load the module manifest without errors' {
        Test-Path -Path $ManifestPath | Should -BeTrue -Because "Manifest path shouldn't be null or missing."
        { Test-ModuleManifest -Path $ManifestPath } | Should -Not -Throw
    }

    It 'Should export all expected commands' {
        Test-Path -Path $ModulePath | Should -BeTrue -Because "Module path shouldn't be null or missing."

        # Force re-import to avoid "parameter set cannot be resolved" issues
        $ImportedModule = Import-Module $ModulePath -Force -PassThru
        $ExportedCmdlets = $ImportedModule.ExportedCommands.Keys

        $ExpectedCmdlets = @('Get-UserInfo', 'Test-SysAdminFeature')
        $ExportedCmdlets | Should -ContainEveryItemOf $ExpectedCmdlets
    }
}
