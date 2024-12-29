Describe 'Windows-SysAdmin-ProSuite Module Validation' {
    $ManifestPath = '../Windows-SysAdmin-ProSuite.psd1'
    $ModulePath = '../Windows-SysAdmin-ProSuite.psm1'

    It 'Should load the module manifest without errors' {
        Test-Path -Path $ManifestPath | Should -BeTrue -Because "The module manifest file should exist at $ManifestPath"
        { Test-ModuleManifest -Path $ManifestPath } | Should -Not -Throw
    }

    It 'Should export all expected commands' {
        Test-Path -Path $ModulePath | Should -BeTrue -Because "The module file should exist at $ModulePath"
        $ExportedCmdlets = (Import-Module $ModulePath -PassThru).ExportedCommands.Keys
        $ExpectedCmdlets = @('Get-UserInfo', 'AnotherFunction', 'ThirdFunction') # Update with actual function names
        $ExportedCmdlets | Should -ContainEveryItemOf $ExpectedCmdlets -Because "The module should export all expected commands"
    }
}
