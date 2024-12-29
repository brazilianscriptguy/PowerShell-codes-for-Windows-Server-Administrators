Describe 'Test Get-UserInfo Function' {
    # Ensure the mock definition is set up properly for the test environment
    Mock -CommandName Get-UserInfo -MockWith {
        param([string]$UserName)
        if (-not $UserName -or $UserName -eq '') {
            throw [ParameterBindingException]::new("Invalid username provided")
        }
        [PSCustomObject]@{
            UserName = $UserName
            FullName = "$UserName Full"
            Email    = "$UserName@example.com"
            Title    = "Mocked Title"
        }
    }

    Context 'When valid parameters are passed' {
        It 'Should return user information' {
            $Result = Get-UserInfo -UserName 'ValidUser'
            $Result | Should -Not -BeNullOrEmpty
            $Result.UserName | Should -Be 'ValidUser'
            $Result.Email | Should -Be 'ValidUser@example.com'
        }
    }

    Context 'When invalid parameters are passed' {
        It 'Should throw an error' {
            { Get-UserInfo -UserName '' } | Should -Throw -ErrorType 'ParameterBindingException'
        }
    }
}
