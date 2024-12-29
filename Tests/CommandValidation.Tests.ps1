<#
.SYNOPSIS
    PowerShell Script Template for Structured and Maintainable PowerShell Projects.

.DESCRIPTION
    Provides a reusable framework with standardized logging, error handling, dynamic paths, 
    and GUI integration. Suitable for building robust and maintainable PowerShell tools.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 29, 2024
#>

Describe 'Get-UserInfo Command Validation' {

    Context 'Mock-based AD tests (no domain needed)' {

        Mock -CommandName 'Get-ADUser' -ModuleName 'ActiveDirectory' -MockWith {
            param([string]$Identity)
            [PSCustomObject]@{
                Name           = "$Identity Full"
                SamAccountName = $Identity
                EmailAddress   = "$Identity@example.com"
                Department     = "MockDept"
                Title          = "MockTitle"
            }
        }

        It 'Should return user information when valid parameters are passed' {
            $Result = Get-UserInfo -SamAccountName 'ValidUser'
            $Result | Should -Not -BeNullOrEmpty
            $Result.SamAccountName | Should -Be 'ValidUser'
            $Result.EmailAddress   | Should -Be 'ValidUser@example.com'
        }

        It 'Should throw an error when invalid parameters are passed' {
            { Get-UserInfo -SamAccountName '' } | Should -Throw
        }
    }

    Context 'Real AD integration tests' {
        $ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -ErrorAction SilentlyContinue
        if (-not $ComputerSystem) {
            It '[SKIPPED] Could not detect domain membership' -Skip { }
        }
        elseif (-not $ComputerSystem.PartOfDomain) {
            It '[SKIPPED] Not domain-joined' -Skip { }
        }
        else {
            It 'Should retrieve user info from a real AD domain' {
                $RealUser = 'SomeRealUser'
                $UserInfo = Get-UserInfo -SamAccountName $RealUser
                $UserInfo | Should -Not -BeNullOrEmpty
                $UserInfo.SamAccountName | Should -Be $RealUser
            }
        }
    }
}
