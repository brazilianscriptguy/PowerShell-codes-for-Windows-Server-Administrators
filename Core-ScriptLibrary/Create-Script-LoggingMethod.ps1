<#
.SYNOPSIS
    PowerShell Script for Standardized Logging and Error Handling.

.DESCRIPTION
    This script provides reusable functions for standardized logging and error handling, 
    ensuring uniformity and consistency across PowerShell scripts. It includes methods 
    to initialize paths dynamically, handle errors gracefully, and log messages effectively.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 6, 2024
#>

# Function for standardized logging with error handling and validation
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"

    try {
        # Ensure the log directory exists, create if necessary
        if (-not (Test-Path $global:logDir)) {
            New-Item -Path $global:logDir -ItemType Directory -ErrorAction Stop | Out-Null
        }
        # Write the log entry to the log file
        Add-Content -Path $global:logPath -Value $logEntry -ErrorAction Stop
    } catch {
        # Log to the console if writing to the log file fails
        Write-Error "Failed to write to log: $_"
        Write-Output $logEntry
    }
}

# Function for standardized error handling with GUI and logging
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ErrorMessage
    )
    Log-Message -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show(
        $ErrorMessage, 
        "Error", 
        [System.Windows.Forms.MessageBoxButtons]::OK, 
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
}

# Function to initialize dynamic paths for logging and file management
function Initialize-ScriptPaths {
    param (
        [string]$DefaultLogDir = 'C:\Logs-TEMP'
    )

    # Dynamically determine the script name and timestamp
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

    # Configure paths for log and output files
    $logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { $DefaultLogDir }
    $logFileName = "${scriptName}.log"
    $logPath = Join-Path $logDir $logFileName

    return @{
        LogDir     = $logDir
        LogPath    = $logPath
        ScriptName = $scriptName
    }
}

# Example usage demonstrating logging and error handling
function Example-Script {
    # Initialize paths dynamically
    $paths = Initialize-ScriptPaths
    $global:logDir = $paths.LogDir
    $global:logPath = $paths.LogPath

    # Log a starting message
    Log-Message -Message "Script has started." -MessageType "INFO"

    try {
        # Simulate some functionality, intentionally triggering an error
        Write-Output "Executing some operations..."
        throw "Simulated error for demonstration."
    } catch {
        Handle-Error -ErrorMessage $_.Exception.Message
    } finally {
        # Log the completion of the script
        Log-Message -Message "Script execution completed." -MessageType "INFO"
    }
}

# Execute the example function to test logging and error handling
Example-Script
