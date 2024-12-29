Describe 'Test Get-UserInfo Function' {

    # Mock definition for Get-ADUser so it doesn't contact a real Domain Controller
    Mock -CommandName Get-ADUser -MockWith {
        param([string]$Identity)
        # Return a fake AD user object
        [PSCustomObject]@{
            Name           = "$Identity FullName"
            SamAccountName = $Identity
            EmailAddress   = "$Identity@example.com"
            Department     = "MockDept"
            Title          = "MockTitle"
        }
    }

    Context 'When valid parameters are passed' {
        It 'Should return user information' {
            $Result = Get-UserInfo -SamAccountName 'ValidUser'
            $Result | Should -Not -BeNullOrEmpty
            $Result.SamAccountName | Should -Be 'ValidUser'
            $Result.EmailAddress   | Should -Be 'ValidUser@example.com'
        }
    }

    Context 'When invalid parameters are passed' {
        It 'Should throw an error' {
            # Use a script block approach:
            { Get-UserInfo -SamAccountName '' } | Should -Throw
        }
    }
}
