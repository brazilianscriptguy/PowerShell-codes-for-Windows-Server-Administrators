# PowerShell Script to Search and Remove Expired Certificate Files Stored as a repository 
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 9, 2024

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}_$(Get-Date -Format 'yyyyMMddHHmmss').log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    $null = New-Item -Path $logDir -ItemType Directory -ErrorAction SilentlyContinue
    if (-not (Test-Path $logDir)) {
        Write-Error "Failed to create log directory at $logDir. Logging will not be possible."
        return
    }
}

# Enhanced logging function with error handling
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to log error messages
function Log-ErrorMessage {
    param ([string]$message)
    Write-Log "Error: $message"
}

# Function to log information messages
function Log-InfoMessage {
    param ([string]$message)
    Write-Log "Info: $message"
}

# Function to gather files with specific extensions
function Get-CertificateFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Directories,
        [string[]]$Extensions = @('*.cer', '*.crt', '*.pem')
    )
    $certificateFiles = @()
    foreach ($directory in $Directories) {
        if (Test-Path -Path $directory) {
            foreach ($extension in $Extensions) {
                $files = Get-ChildItem -Path $directory -Filter $extension -Recurse -ErrorAction SilentlyContinue
                $certificateFiles += $files
            }
        } else {
            Log-ErrorMessage "Directory not found: $directory"
        }
    }
    return $certificateFiles
}

# Function to check if a certificate file is expired
function Is-CertificateExpired {
    param ([string]$filePath)
    try {
        $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $filePath
        return $certificate.NotAfter -lt (Get-Date)
    } catch {
        Log-ErrorMessage "Error loading certificate file: $filePath. $_"
        return $false
    }
}

# Function to remove expired certificate files
function Remove-ExpiredCertificateFiles {
    param ([string[]]$files)
    Log-InfoMessage "Starting removal of expired certificate files."
    foreach ($file in $files) {
        try {
            Remove-Item -Path $file -Force -Verbose
            Write-Log "Successfully removed expired certificate file: $file"
        } catch {
            Log-ErrorMessage "Error removing certificate file: $file. $_"
        }
    }
    Log-InfoMessage "Certificate file removal process completed."
}

# Directories to scan for expired certificates
$certificateDirectories = @(
    'C:\ProgramData\Microsoft\SystemCertificates',
    "$env:APPDATA\Microsoft\SystemCertificates",
    'C:\CustomCertificateDirectory'  # Add your custom directories here
)

# Get all certificate files from the specified directories
$certificateFiles = Get-CertificateFiles -Directories $certificateDirectories

# Filter out the expired certificate files
$expiredFiles = @()
foreach ($file in $certificateFiles) {
    if (Is-CertificateExpired -filePath $file.FullName) {
        $expiredFiles += $file.FullName
    }
}

# Remove the expired certificate files
Remove-ExpiredCertificateFiles -files $expiredFiles

# End of script
