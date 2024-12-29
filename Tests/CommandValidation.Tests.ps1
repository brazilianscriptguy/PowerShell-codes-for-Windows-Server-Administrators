Describe 'Test Get-UserInfo Function' {
    Context 'When valid parameters are passed' {
        It 'Should return user information' {
            $Result = Get-UserInfo -UserName 'TestUser'
            $Result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When invalid parameters are passed' {
        It 'Should throw an error' {
            { Get-UserInfo -UserName '' } | Should -Throw
        }
    }
}
