Describe 'Windows-SysAdmin-ProSuite Module Validation' {
    # Define paths relative to the test directory
    $ManifestPath = (Join-Path -Path $PSScriptRoot -ChildPath '../Windows-SysAdmin-ProSuite.psd1')
    $ModulePath = (Join-Path -Path $PSScriptRoot -ChildPath '../Windows-SysAdmin-ProSuite.psm1')

    It 'Should load the module manifest without errors' {
        Test-Path -Path $ManifestPath | Should -BeTrue -Because "The module manifest file should exist at $ManifestPath"
        { Test-ModuleManifest -Path $ManifestPath } | Should -Not -Throw
    }

    It 'Should export all expected commands' {
        Test-Path -Path $ModulePath | Should -BeTrue -Because "The module file should exist at $ModulePath"
        $ExportedCmdlets = (Import-Module -Name $ModulePath -PassThru).ExportedCommands.Keys
        $ExpectedCmdlets = @('Get-UserInfo', 'AnotherFunction', 'ThirdFunction') # Replace with actual function names
        $ExportedCmdlets | Should -ContainEveryItemOf $ExpectedCmdlets -Because "The module should export all expected commands"
    }
}
