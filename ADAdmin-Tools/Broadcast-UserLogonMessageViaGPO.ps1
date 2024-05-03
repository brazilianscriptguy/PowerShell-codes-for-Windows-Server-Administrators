# PowerShell Script for Displaying a Warning Message at User Logon on Workstations -  via Group Policy Objects (GPO).
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 03, 2024. 

# Setting error handling to be less intrusive
$ErrorActionPreference = "SilentlyContinue"

# Define the path to the post-logon message file located on the network share
$messagePath = "\\forest-logonserver-name\netlogon\broadcast-logonmessage\Broadcast-UserLogonMessageViaGPO.hta"

try {
    # Verify if the message file exists on the server before attempting to execute
    if (Test-Path $messagePath -PathType Leaf) {
        # Create a shell object to run the Windows Script Host
        $shell = New-Object -ComObject WScript.Shell

        # Execute the message file in a hidden window and wait for it to finish
        $exitCode = $shell.Run($messagePath, 0, $true)

        # Log an error if the script exits with a non-zero status indicating a failure
        if ($exitCode -ne 0) {
            Write-Error "Failed to execute the post-logon message. Exit code: $exitCode"
        }
    } else {
        Write-Error "Post-logon message file is missing at: $messagePath"
    }
} catch {
    # Log the specific system exception if any error occurs during execution
    Write-Error "An unexpected error occurred: $_"
}

# End of the script
