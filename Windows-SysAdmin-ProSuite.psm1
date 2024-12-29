<#
.SYNOPSIS
    PowerShell Script Template for Structured and Maintainable PowerShell Projects.

.DESCRIPTION
    Provides a reusable framework with standardized logging, error handling, dynamic paths, 
    and GUI integration. Suitable for building robust and maintainable PowerShell tools.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 29, 2024
#>

# Function: Write-Log
function Write-Log {
    param (
        [Parameter(Mandatory)]
        [string]$Message,
        
        [ValidateSet("INFO","ERROR","WARNING","DEBUG","CRITICAL")]
        [string]$MessageType = "INFO"
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logEntry = "[$timestamp] [$MessageType] $Message"
    Write-Host $logEntry
    # Optionally write to a file:
    # Add-Content -Path 'C:\temp\module.log' -Value $logEntry
}

# Function: Handle-Error
function Handle-Error {
    param (
        [Parameter(Mandatory)]
        [string]$ErrorMessage
    )
    Write-Log -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    throw $ErrorMessage
}

# Attempt to import ActiveDirectory
try {
    if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
        Write-Log -Message "Importing Active Directory module..."
        Import-Module ActiveDirectory -ErrorAction Stop
    }
}
catch {
    Write-Log -Message "ActiveDirectory module not found or failed to load. $_" -MessageType "WARNING"
}

# Function: Get-UserInfo
function Get-UserInfo {
<#
.SYNOPSIS
    Retrieves detailed information about an Active Directory user.

.DESCRIPTION
    Leverages the AD module to query domain user properties.

.PARAMETER SamAccountName
    The SAM account name of the user to retrieve.

.EXAMPLE
    Get-UserInfo -SamAccountName jdoe
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SamAccountName
    )

    try {
        if (-not $SamAccountName) {
            throw "SamAccountName cannot be empty."
        }
        
        $user = Get-ADUser -Identity $SamAccountName -Properties * 2>$null
        if (-not $user) {
            throw "User '$SamAccountName' not found in AD."
        }

        [PSCustomObject]@{
            Name           = $user.Name
            SamAccountName = $user.SamAccountName
            EmailAddress   = $user.EmailAddress
            Department     = $user.Department
            Title          = $user.Title
        }
    }
    catch {
        Handle-Error "Failed to retrieve user info for '$SamAccountName': $_"
        return $null
    }
}

# Function: Test-SysAdminFeature
function Test-SysAdminFeature {
<#
.SYNOPSIS
    Placeholder function for future system admin features.

.DESCRIPTION
    This is a stub function to illustrate how multiple functions can be included in the module.

.EXAMPLE
    Test-SysAdminFeature
#>
    Write-Log "Test-SysAdminFeature called." -MessageType "INFO"
    return "Feature under development..."
}

Export-ModuleMember -Function Get-UserInfo, Test-SysAdminFeature

# End of script
