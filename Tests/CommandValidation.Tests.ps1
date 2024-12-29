Describe 'Test Get-UserInfo Function' {
    Context 'When valid parameters are passed' {
        Mock -CommandName Get-UserInfo -MockWith {
            [PSCustomObject]@{
                UserName = 'TestUser'
                FullName = 'Test User'
                Email    = 'testuser@example.com'
                Title    = 'System Admin'
            }
        }

        It 'Should return user information' {
            $Result = Get-UserInfo -UserName 'TestUser'
            $Result | Should -Not -BeNullOrEmpty
            $Result.UserName | Should -Be 'TestUser'
            $Result.Email | Should -Be 'testuser@example.com'
        }
    }

    Context 'When invalid parameters are passed' {
        Mock -CommandName Get-UserInfo -MockWith {
            throw "Invalid username"
        }

        It 'Should throw an error' {
            { Get-UserInfo -UserName '' } | Should -Throw -ErrorMessage "Invalid username"
        }
    }
}
