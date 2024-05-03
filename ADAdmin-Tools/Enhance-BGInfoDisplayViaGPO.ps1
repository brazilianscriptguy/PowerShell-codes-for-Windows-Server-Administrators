# PowerShell script to display BGInfo (PsTools - Sysinternals) on the Servers Desktop with improvements - using with GPO
# Author: Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# Update: May 03, 2024.

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
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
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
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

# Create a shortcut to BGInfo in the Common Startup directory
$CommonStartUpDir = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" # Common Startup directory path
$BGInfoPath = "\\forest-logonserver-name\netlogon\bginfo-custom\bginfo64.exe" # Ensure BGInfo64.exe is copied to your domain netlogon folder
$BGInfoConfig = "\\forest-logonserver-name\netlogon\bginfo-custom\Enhance-BGInfoDisplayViaGPO.bgi" # Ensure Enhance-BGInfoDisplayViaGPO.bgi is copied to your domain netlogon folder

$shortcutPath = Join-Path -Path $CommonStartUpDir -ChildPath "bginfo.lnk"
try {
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $BGInfoPath
    $shortcut.Arguments = "/timer:0 /silent /nolicprompt $BGInfoConfig"
    $shortcut.Save()
    Log-Message "Shortcut created successfully: $shortcutPath"
} catch {
    Log-Message "Failed to create shortcut: $_"
}

# End of script
