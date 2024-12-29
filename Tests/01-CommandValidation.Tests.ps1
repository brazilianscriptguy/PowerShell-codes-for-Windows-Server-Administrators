<#
.SYNOPSIS
    Mock-based & Real AD tests for Get-UserInfo

.DESCRIPTION
    Ensures domainless testing is possible by mocking Get-ADUser. 
    If domain-joined, tests real AD calls.

#>

Describe 'Get-UserInfo Command Validation' {

    BeforeAll {
        # 1) Check if AD is installed
        if (-not (Get-Module ActiveDirectory)) {
            Import-Module ActiveDirectory -ErrorAction SilentlyContinue
        }
        
        # 2) Define the mock AFTER AD is recognized by Pester
        Mock -CommandName 'Get-ADUser' -ModuleName 'ActiveDirectory' -MockWith {
            param([string]$Identity)
            [PSCustomObject]@{
                Name       = "$Identity Mock"
                SamAccount = $Identity
                Email      = "$Identity@example.com"
                Department = "MockDept"
            }
        }

        # 3) We do NOT import the .psd1 here; we only import the .psm1 if needed. 
        #    But if your code calls Import-Module from .psd1, that’s fine. 
        #    The key is: do NOT re-import 'Get-UserInfo' after the mock is defined or we lose the mock.
        #    Alternatively, dot-source the .psm1. Example:
        $ModulePsm1 = [System.IO.Path]::ChangeExtension($Env:MODULE_FILE, '.psm1')
        . $ModulePsm1
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
        $comp = Get-WmiObject Win32_ComputerSystem -ErrorAction SilentlyContinue
        if (-not $comp) {
            It '[SKIPPED] Could not detect domain membership' -Skip { }
        }
        elseif (-not $comp.PartOfDomain) {
            It '[SKIPPED] Not domain-joined' -Skip { }
        }
        else {
            It 'Should retrieve real user info from AD domain' {
                $realUser = 'SomeDomainUser'
                $info = Get-UserInfo -SamAccountName $realUser
                $info | Should -Not -BeNullOrEmpty
                $info.SamAccount | Should -Be $realUser
            }
        }
    }
}

# End of script
