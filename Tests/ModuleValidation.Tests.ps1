Describe 'Windows-SysAdmin-ProSuite Module Validation' {
    It 'Should load the module manifest without errors' {
        { Test-ModuleManifest -Path '../Windows-SysAdmin-ProSuite.psd1' } | Should -Not -Throw
    }

    It 'Should export all expected commands' {
        $ExportedCmdlets = (Import-Module '../Windows-SysAdmin-ProSuite.psd1' -PassThru).ExportedCommands.Keys
        $ExpectedCmdlets = @('Function1', 'Function2', 'Function3') # Replace with actual function names
        $ExportedCmdlets | Should -ContainEveryItemOf $ExpectedCmdlets
    }
}
