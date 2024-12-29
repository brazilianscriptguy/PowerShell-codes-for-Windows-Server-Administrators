Describe 'Get-UserInfo Command Validation' {

    # --------------------------------------------------------------------------
    # 1) Mock-based AD tests (no domain needed)
    # --------------------------------------------------------------------------
    Context 'Mock-based AD tests' {

        # IMPORTANT: Include -ModuleName 'ActiveDirectory' so that Pester
        # knows to intercept calls from that specific module.
        Mock -CommandName 'Get-ADUser' -ModuleName 'ActiveDirectory' -MockWith {
            param([string]$Identity)
            # Return a fake AD user object
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

    # --------------------------------------------------------------------------
    # 2) Real AD tests (skip if not domain-joined)
    # --------------------------------------------------------------------------
    Context 'Real AD integration tests' {

        # Attempt to detect domain membership
        $ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -ErrorAction SilentlyContinue

        if (-not $ComputerSystem) {
            It '[SKIPPED] Could not detect domain membership' -Skip { }
        }
        elseif (-not $ComputerSystem.PartOfDomain) {
            It '[SKIPPED] Not domain-joined' -Skip { }
        }
        else {
            # If domain-joined, run a real query
            It 'Should retrieve user info from a real AD domain' {
                $RealUser = 'SomeRealUser'
                $UserInfo = Get-UserInfo -SamAccountName $RealUser
                $UserInfo | Should -Not -BeNullOrEmpty
                $UserInfo.SamAccountName | Should -Be $RealUser
            }
        }
    }
}
