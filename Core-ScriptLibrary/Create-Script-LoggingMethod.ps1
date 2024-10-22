<#
.SYNOPSIS
    PowerShell Script for Implementing a Standardized Logging Method.

.DESCRIPTION
    This script implements a standardized logging method across PowerShell scripts, ensuring 
    uniform and consistent logging for improved traceability, debugging, and auditing.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: October 22, 2024
#>

# Enhanced logging function with error handling and validation, refactored as a reusable method
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"

    try {
        # Ensure the log path exists, create if necessary
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -ErrorAction Stop
        }
        # Attempt to write to the log file
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        # Fallback: Log to console if writing to the log file fails
        Write-Error "Failed to write to log: $_"
        Write-Output $logEntry
    }
}

# Unified error handling function refactored as a reusable method
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Log-Message -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Function to initialize script name and file paths, refactored for reuse in other scripts
function Initialize-ScriptPaths {
    param (
        [string]$defaultLogDir = 'C:\Logs-TEMP'
    )

    # Determine script name and set up file paths dynamically
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

    # Set log path allowing dynamic configuration or fallback to defaults
    $logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { $defaultLogDir }
    $logFileName = "${scriptName}.log"
    $logPath = Join-Path $logDir $logFileName

    return @{
        LogDir = $logDir
        LogPath = $logPath
        ScriptName = $scriptName
    }
}

# Example usage of the functions in another script
function Example-Script {
    # Initialize paths
    $paths = Initialize-ScriptPaths

    # Set log directory and path variables for the current session
    $global:logDir = $paths.LogDir
    $global:logPath = $paths.LogPath

    # Log a test message
    Log-Message -Message "Script has started" -MessageType "INFO"

    try {
        # Simulate some code here, and intentionally throw an error
        throw "Simulated error"
    } catch {
        Handle-Error -ErrorMessage $_.Exception.Message
    }
}

# Call the example function to test logging and error handling
Example-Script
