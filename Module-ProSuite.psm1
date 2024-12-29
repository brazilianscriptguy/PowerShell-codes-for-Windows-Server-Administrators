<#
.SYNOPSIS
    Module-ProSuite: Implementation of advanced Windows SysAdmin tasks.

.DESCRIPTION
    Includes logging, error handling, and optional Active Directory integration.
    Exports functions like Get-UserInfo and Test-SysAdminFeature.

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
    Write-Host "[$timestamp] [$MessageType] $Message"
}

function Handle-Error {
    param(
        [Parameter(Mandatory)]
        [string]$ErrorMessage
    )
    Write-Log -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    throw $ErrorMessage
}

try {
    if (-not (Get-Module ActiveDirectory -ListAvailable)) {
        Write-Log -Message "Importing ActiveDirectory..." -MessageType "INFO"
        Import-Module ActiveDirectory -ErrorAction Stop
    }
}
catch {
    Write-Log -Message "Failed to load ActiveDirectory: $_" -MessageType "WARNING"
}

function Get-UserInfo {
<#
.SYNOPSIS
    Retrieves info about an Active Directory user.

.DESCRIPTION
    Uses the ActiveDirectory module to query user properties like Name, Email, Department, etc.

.PARAMETER SamAccountName
    The user's SAM account name.

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
            Name          = $user.Name
            SamAccount    = $user.SamAccountName
            Email         = $user.EmailAddress
            Department    = $user.Department
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
    Placeholder function for system admin features.

.DESCRIPTION
    Stub function to illustrate how multiple features can be included.
#>
    Write-Log -Message "Test-SysAdminFeature called." -MessageType "INFO"
    return "Feature under development..."
}

Export-ModuleMember -Function Get-UserInfo, Test-SysAdminFeature

# End of script
