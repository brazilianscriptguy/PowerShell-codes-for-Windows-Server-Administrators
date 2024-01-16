# # PowerShell script to show warning at logon on the workstations
# by Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# on 16/01/2024

# Set error handling to be more verbose
$ErrorActionPreference = "SilentlyContinue"

# Define the path to the post-logon message file
$messagePath = "\\forest.domain.name\netlogon\post-logon-message\post-logon-message.hta"

try {
    # Check if the message file exists before running it
    if (Test-Path $messagePath -PathType Leaf) {
        # Create shell object
        $shell = New-Object -ComObject WScript.Shell

        # Run the message file and wait for it to complete
        $exitCode = $shell.Run($messagePath, 0, $true)

        # Check the exit code and display an error message if it is non-zero
        if ($exitCode -ne 0) {
            Write-Error "Error running post-logon message. Exit code: $exitCode"
        }
    } else {
        Write-Error "Post-logon message file not found: $messagePath"
    }
} catch {
    Write-Error "An error occurred: $_"
}

# End of script