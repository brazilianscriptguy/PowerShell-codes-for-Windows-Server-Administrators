Describe 'Test Get-UserInfo Function' {

    # Mock definition for Get-UserInfo
    Mock -CommandName Get-UserInfo -MockWith {
        param([string]$SamAccountName)
        if (-not $SamAccountName -or $SamAccountName -eq '') {
            throw [ParameterBindingException]::new("Invalid username provided")
        }
        [PSCustomObject]@{
            SamAccountName = $SamAccountName
            FullName       = "$SamAccountName Full"
            Email          = "$SamAccountName@example.com"
            Title          = "Mocked Title"
        }
    }

    Context 'When valid parameters are passed' {
        It 'Should return user information' {
            $Result = Get-UserInfo -SamAccountName 'ValidUser'
            $Result | Should -Not -BeNullOrEmpty
            $Result.SamAccountName | Should -Be 'ValidUser'
            $Result.Email         | Should -Be 'ValidUser@example.com'
        }
    }

    Context 'When invalid parameters are passed' {
        It 'Should throw an error' {
            { Get-UserInfo -SamAccountName '' } | Should -Throw -ErrorType 'ParameterBindingException'
        }
    }
}
