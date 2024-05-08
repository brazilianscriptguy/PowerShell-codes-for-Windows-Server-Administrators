# PowerShell Script to Automate Software Updates on Windows OS with Progress Display and Enhanced Logging
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 8, 2024

# Import necessary assemblies
Add-Type -AssemblyName System.Windows.Forms

# Hide the PowerShell console window
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Window {
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public static void Hide() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 0); // 0 = SW_HIDE
    }
    public static void Show() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 5); // 5 = SW_SHOW
    }
}
"@

[Window]::Hide()

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

# Function to display progress
function Show-Progress {
    param (
        [string]$Activity,
        [string]$Status,
        [int]$PercentComplete
    )
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

# Function to find the winget executable path
function Find-WingetPath {
    param (
        [string]$SearchBase = "C:\Program Files\WindowsApps",
        [string]$SearchPattern = 'Microsoft.DesktopAppInstaller_*__8wekyb3d8bbwe\winget.exe'
    )

    try {
        Log-Message "Searching for winget executable..."
        $wingetPath = Get-ChildItem -Path $SearchBase -Filter 'winget.exe' -Recurse -ErrorAction Ignore |
                      Where-Object { $_.FullName -like "*$SearchPattern" } |
                      Select-Object -ExpandProperty FullName -First 1
        if ($wingetPath -and (Test-Path -Path $wingetPath -Type Leaf)) {
            Log-Message "winget found at: $wingetPath"
            return $wingetPath
        } else {
            throw "winget not found."
        }
    } catch {
        $errorMsg = "An error occurred while searching for winget: $($_.Exception.Message)"
        Log-Message $errorMsg
        return $null
    }
}

# Function to update software using winget
function Update-Software {
    param (
        [string]$WingetPath
    )

    try {
        Log-Message "Starting software updates with winget..."
        Show-Progress -Activity "Starting Software Update" -Status "Preparing to update all packages..." -PercentComplete 0

        $wingetCommandQuery = "& `"$WingetPath`" upgrade --query"
        $wingetUpdateAvailable = Invoke-Expression $wingetCommandQuery | Out-String

        if ($wingetUpdateAvailable -match "No applicable updates found") {
            Log-Message "No updates available for any packages."
        } else {
            Show-Progress -Activity "Updating Software" -Status "Performing package updates..." -PercentComplete 50
            $wingetCommandUpgrade = "& `"$WingetPath`" upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements"
            $updateResults = Invoke-Expression $wingetCommandUpgrade | ForEach-Object {
                Log-Message $_
            }
            Log-Message "All package updates completed successfully. Details: `n$updateResults"
        }

        Show-Progress -Activity "Updating Software" -Status "Update completed successfully." -PercentComplete 100
        Start-Sleep -Seconds 2
    } catch {
        Show-Progress -Activity "Updating Software" -Status "An error occurred during the update." -PercentComplete 100
        $errorMsg = "An error occurred during the software update process: $($_.Exception.Message)"
        Log-Message $errorMsg
    }
}

# Main script logic
$wingetPath = Get-Command "winget" -ErrorAction SilentlyContinue

if ($wingetPath) {
    Log-Message "winget found. Proceeding with the update."
    Update-Software -WingetPath $wingetPath
} else {
    Log-Message "Winget is not installed or not found in the PATH. Attempting to find it..."
    $wingetPath = Find-WingetPath

    if ($wingetPath) {
        Update-Software -WingetPath $wingetPath
    } else {
        Log-Message "winget not found. Please verify the installation and path."
    }
}

# End of script
