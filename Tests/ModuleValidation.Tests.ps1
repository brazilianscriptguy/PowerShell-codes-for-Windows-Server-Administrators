Describe 'Windows-SysAdmin-ProSuite Module Validation' {
    # Use $PSCommandPath instead of $MyInvocation
    $PSScriptRoot = Split-Path -Parent $PSCommandPath

    $ManifestPath = Join-Path -Path $PSScriptRoot -ChildPath '../Windows-SysAdmin-ProSuite.psd1'
    $ModulePath   = Join-Path -Path $PSScriptRoot -ChildPath '../Windows-SysAdmin-ProSuite.psm1'

    It 'Should load the module manifest without errors' {
        Test-Path -Path $ManifestPath | Should -BeTrue
        { Test-ModuleManifest -Path $ManifestPath } | Should -Not -Throw
    }

    It 'Should export all expected commands' {
        Test-Path -Path $ModulePath | Should -BeTrue
        $ExportedCmdlets = (Import-Module -Name $ModulePath -PassThru).ExportedCommands.Keys

        $ExpectedCmdlets = @('Get-UserInfo', 'Test-SysAdminFeature')
        $ExportedCmdlets | Should -ContainEveryItemOf $ExpectedCmdlets
    }
}
