# PowerShell core default to  logging functio; error handling function; script name and set up file paths; Set log path
# Autho: luizhamilton.lhr@gmail.com - @brazilianscriptguy
# Update: October 15, 2024

# Enhanced logging function with error handling and validation
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

# Unified error handling function
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Log-Message -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Determine script name and set up file paths dynamically
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

# Set log path allow dynamic configuration or fallback to defaults
$logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { 'C:\Logs-TEMP' }
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# The new code bellow
