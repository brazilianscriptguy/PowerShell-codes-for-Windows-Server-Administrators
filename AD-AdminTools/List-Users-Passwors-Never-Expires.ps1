# PowerShell Script to export a list of Active Directory users with passwords set to never expire into CSV file
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 22/12/2023

# Check if the Active Directory module is available and import it
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Import-Module ActiveDirectory
} else {
    Write-Error "Active Directory module is not available."
    Exit
}

# Get current timestamp in a format suitable for a filename
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Define the path for the CSV output file in the "My Documents" directory with the current timestamp
$outputFile = "$([Environment]::GetFolderPath('MyDocuments'))\NeverExpiresUsers_$timestamp.csv"

try {
    # Fetch all user accounts with passwords set to never expire
    $neverExpireUsers = Get-ADUser -Filter { PasswordNeverExpires -eq $true } -Properties PasswordNeverExpires |
                       Select-Object Name, SamAccountName, DistinguishedName

    # Check if any users are fetched
    if ($neverExpireUsers.Count -gt 0) {
        # Export the results to the CSV file
        $neverExpireUsers | Export-Csv -Path $outputFile -NoTypeInformation
        Write-Output "Users with passwords set to never expire have been exported to $outputFile"
    } else {
        Write-Output "No users with 'Password Never Expires' found."
    }
} catch {
    Write-Error "An error occurred: $_"
}

# End of script
