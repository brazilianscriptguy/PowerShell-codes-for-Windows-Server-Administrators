# Tests for Windows-SysAdmin-ProSuite

This directory contains automated tests for the **Windows-SysAdmin-ProSuite** PowerShell module. The tests are written using the [Pester](https://github.com/pester/Pester) framework.

## Structure
- `01-ModuleValidation.Tests.ps1`: Validates the module manifest and exported commands.
- `02-CommandValidation.Tests.ps1`: Validates individual functions for expected behavior.

## Writing Tests
1. Create a new `.Tests.ps1` file in the `Tests` directory.
2. Use the `Describe`, `Context`, and `It` blocks to structure your tests.
3. Ensure all test files follow the naming convention: `FunctionName.Tests.ps1`.

### Example Test File
```powershell
Describe 'FunctionName' {
    It 'Should perform the expected action' {
        { Invoke-FunctionName -Param1 'value' } | Should -Not -Throw
    }
}
