<#
.SYNOPSIS
    Windows-SysAdmin-ProSuite Module: Implementation of advanced Windows SysAdmin tasks.

.DESCRIPTION
    This PowerShell module includes logging, error handling, and optional Active Directory integration.
    Exports functions that help with user account queries and placeholder system admin features.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 29, 2024
#>

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
}

function Handle-Error {
    param (
        [Parameter(Mandatory)]
        [string]$ErrorMessage
    )
    Write-Log -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    throw $ErrorMessage
}

try {
    if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
        Write-Log -Message "Importing Active Directory module..."
        Import-Module ActiveDirectory -ErrorAction Stop
    }
}
catch {
    Write-Log -Message "ActiveDirectory module not found or failed to load. $_" -MessageType "WARNING"
}

function Get-UserInfo {
<#
.SYNOPSIS
    Retrieves detailed information about an Active Directory user.

.DESCRIPTION
    Queries an AD domain for user properties like Name, Email, Department, Title, etc.
    Uses the ActiveDirectory module when available.

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

function Test-SysAdminFeature {
<#
.SYNOPSIS
    Placeholder function for future system admin features.

.DESCRIPTION
    Demonstrates how multiple functions can be included in this module.
#>
    Write-Log "Test-SysAdminFeature called." -MessageType "INFO"
    return "Feature under development..."
}

Export-ModuleMember -Function Get-UserInfo, Test-SysAdminFeature

# End of script
