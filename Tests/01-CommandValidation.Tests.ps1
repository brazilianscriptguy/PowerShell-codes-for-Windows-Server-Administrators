<#
.SYNOPSIS
    Pester Tests: Validate commands in Module-ProSuite

.DESCRIPTION
    Mocks ActiveDirectory calls for domainless testing.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 29, 2024
#>

Describe 'Get-UserInfo Command Validation' {

    BeforeAll {
        # Ensure the AD module is loaded so Pester can detect the command
        if (-not (Get-Module ActiveDirectory)) {
            Import-Module ActiveDirectory -ErrorAction SilentlyContinue
        }

        # Define the mock AFTER AD is recognized
        Mock -CommandName 'Get-ADUser' -ModuleName 'ActiveDirectory' -MockWith {
            param([string]$Identity)
            [PSCustomObject]@{
                Name       = "$Identity Mock"
                SamAccount = $Identity
                Email      = "$Identity@example.com"
                Department = "MockDept"
            }
        }
    }

    Context 'Mock-based AD tests' {
        It 'Should return user info for a valid SamAccountName' {
            $result = Get-UserInfo -SamAccountName 'ValidUser'
            $result | Should -Not -BeNullOrEmpty
            $result.SamAccount | Should -Be 'ValidUser'
            $result.Email      | Should -Be 'ValidUser@example.com'
        }

        It 'Should throw an error for an empty SamAccountName' {
            { Get-UserInfo -SamAccountName '' } | Should -Throw
        }
    }

    Context 'Real AD integration tests' {
        $comp = Get-WmiObject -Class Win32_ComputerSystem -ErrorAction SilentlyContinue
        if (-not $comp) {
            It '[SKIPPED] Could not detect domain membership' -Skip { }
        }
        elseif (-not $comp.PartOfDomain) {
            It '[SKIPPED] Not domain-joined' -Skip { }
        }
        else {
            It 'Should retrieve real user info from AD domain' {
                $RealUser = 'SomeDomainUser'
                $info = Get-UserInfo -SamAccountName $RealUser
                $info | Should -Not -BeNullOrEmpty
                $info.SamAccount | Should -Be $RealUser
            }
        }
    }
}

# End of script
