<#
.SYNOPSIS
    Module-ProSuite: Implementation of advanced Windows SysAdmin tasks.

.DESCRIPTION
    Includes logging, error handling, and optional Active Directory integration.
    Exports functions to help with user account queries and placeholder sysadmin features.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 29, 2024
#>

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO","ERROR","WARNING","DEBUG","CRITICAL")]
        [string]$MessageType = "INFO"
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "[$timestamp] [$MessageType] $Message"
}

function Handle-Error {
    param(
        [string]$ErrorMessage
    )
    Write-Log -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    throw $ErrorMessage
}

try {
    if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
        Write-Log -Message "Importing ActiveDirectory..."
        Import-Module ActiveDirectory -ErrorAction Stop
    }
}
catch {
    Write-Log -Message "Failed to load ActiveDirectory module: $_" -MessageType "WARNING"
}

function Get-UserInfo {
<#
.SYNOPSIS
    Retrieves info about an AD user

.DESCRIPTION
    Uses ActiveDirectory module to query user properties (Name, Email, Dept, etc.)

.EXAMPLE
    Get-UserInfo -SamAccountName "jdoe"
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SamAccountName
    )
    try {
        if (-not $SamAccountName) { throw "SamAccountName is empty." }

        $user = Get-ADUser -Identity $SamAccountName -Properties * 2>$null
        if (-not $user) {
            throw "User '$SamAccountName' not found in AD."
        }
        [PSCustomObject]@{
            Name         = $user.Name
            SamAccount   = $user.SamAccountName
            Email        = $user.EmailAddress
            Department   = $user.Department
        }
    }
    catch {
        Handle-Error "Failed to retrieve user '$SamAccountName': $_"
        return $null
    }
}

function Test-SysAdminFeature {
<#
.SYNOPSIS
    Placeholder function
#>
    Write-Log "Test-SysAdminFeature called." -MessageType "INFO"
    "Feature under development..."
}

Export-ModuleMember -Function Get-UserInfo, Test-SysAdminFeature

# End of script
