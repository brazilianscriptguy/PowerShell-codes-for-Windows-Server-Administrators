# PowerShell Script to Delete Cookies, Cache, and Other Data for Firefox, Chrome, Edge, Internet Explorer, WhatsApp, and Perform General System Cleanup
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: October 05, 2024

# Parameters
param(
    [switch]$ShowConsole = $false
)

# Hide the PowerShell console window for a cleaner UI unless requested to show the console
if (-not $ShowConsole) {
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
}

# Add necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define Colors for Logging
$Yellow = "Yellow"
$Green  = "Green"
$Cyan   = "Cyan"

# Function to Log Messages with Color
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")]
        [string]$MessageType = "INFO",

        [Parameter(Mandatory=$false)]
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"

    try {
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
        }
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
        Write-Host $logEntry -ForegroundColor $Color
    }

    if ($global:logBox -and $global:logBox.InvokeRequired -eq $false) {
        $global:logBox.Items.Add($logEntry)
        $global:logBox.TopIndex = $global:logBox.Items.Count - 1
    }
}

# Function to Handle Errors
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Write-Log -Message "ERROR: $ErrorMessage" -MessageType "ERROR" -Color $Yellow
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Function to Remove Items with Error Handling
function Remove-Items {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    try {
        if (Test-Path $Path) {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction SilentlyContinue -Verbose
            Write-Log -Message "Removed: $Path" -MessageType "INFO" -Color $Cyan
        }
        else {
            Write-Log -Message "Path does not exist: $Path" -MessageType "WARNING" -Color $Yellow
        }
    }
    catch {
        Handle-Error "Failed to remove items at path: $Path. Error: $_"
    }
}

# Function to Clear Firefox Data
function Clear-FirefoxData {
    Write-Log -Message "Clearing Mozilla Firefox Data" -MessageType "INFO" -Color $Green
    Get-ChildItem "C:\Users" -Directory | ForEach-Object {
        $UserName = $_.Name
        $ProfilePath = "C:\Users\$UserName\AppData\Local\Mozilla\Firefox\Profiles"
        if (Test-Path $ProfilePath) {
            Get-ChildItem $ProfilePath -Directory | ForEach-Object {
                Write-Log -Message "  Processing Firefox Profile: $($_.Name)" -MessageType "INFO" -Color $Cyan
                $ProfileFullPath = $_.FullName
                $PathsToClear = @(
                    "$ProfileFullPath\cookies.sqlite",
                    "$ProfileFullPath\cache2\entries",
                    "$ProfileFullPath\cookies.sqlite-journal",
                    "$ProfileFullPath\places.sqlite",
                    "$ProfileFullPath\places.sqlite-journal",
                    "$ProfileFullPath\sessionstore.jsonlz4",
                    "$ProfileFullPath\webappsstore.sqlite",
                    "$ProfileFullPath\downloads.json",
                    "$ProfileFullPath\storage\default",
                    "$ProfileFullPath\thumbnails",
                    "$ProfileFullPath\cache",
                    "$ProfileFullPath\extensions"
                )
                foreach ($Path in $PathsToClear) {
                    Remove-Items -Path $Path
                }
            }
        }
        else {
            Write-Log -Message "Firefox profiles not found for user: $UserName" -MessageType "WARNING" -Color $Yellow
        }
    }
    Write-Log -Message "Mozilla Firefox Data Cleared." -MessageType "INFO" -Color $Green
}

# Function to Clear Chrome and Edge Data
function Clear-ChromeAndEdgeData {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Chrome", "Edge")]
        [string]$Browser
    )
    Write-Log -Message "Clearing Microsoft $Browser Data" -MessageType "INFO" -Color $Green
    $BrowserDataBasePath = if ($Browser -eq "Chrome") {
        "C:\Users\*\AppData\Local\Google\Chrome\User Data"
    } elseif ($Browser -eq "Edge") {
        "C:\Users\*\AppData\Local\Microsoft\Edge\User Data"
    }
    Get-ChildItem -Path "C:\Users" -Directory | ForEach-Object {
        $UserName = $_.Name
        $UserProfilePath = $_.FullName
        $BrowserPath = if ($Browser -eq "Chrome") {
            "$UserProfilePath\AppData\Local\Google\Chrome\User Data"
        } else {
            "$UserProfilePath\AppData\Local\Microsoft\Edge\User Data"
        }
        if (Test-Path $BrowserPath) {
            Write-Log -Message "  Processing $Browser profiles for user: $UserName" -MessageType "INFO" -Color $Cyan
            $Profiles = Get-ChildItem $BrowserPath -Directory | Where-Object { $_.Name -like "Profile*" -or $_.Name -eq "Default" }
            foreach ($Profile in $Profiles) {
                Write-Log -Message "    Cleaning profile: $($Profile.Name)" -MessageType "INFO" -Color $Cyan
                $ProfileFullPath = $Profile.FullName
                $PathsToClear = @(
                    "$ProfileFullPath\Cookies",
                    "$ProfileFullPath\Cookies-Journal",
                    "$ProfileFullPath\Local Storage",
                    "$ProfileFullPath\IndexedDB",
                    "$ProfileFullPath\Cache",
                    "$ProfileFullPath\Cache2",
                    "$ProfileFullPath\Media Cache",
                    "$ProfileFullPath\GPUCache",
                    "$ProfileFullPath\Code Cache",
                    "$ProfileFullPath\ShaderCache",
                    "$ProfileFullPath\Local Extension Settings",
                    "$ProfileFullPath\Sessions",
                    "$ProfileFullPath\databases",
                    "$ProfileFullPath\*.*_lock"
                )
                foreach ($Path in $PathsToClear) {
                    Remove-Items -Path $Path
                }
                Remove-Items -Path "$ProfileFullPath\ChromeDWriteFontCache"
            }
        }
        else {
            Write-Log -Message "$Browser data path not found for user: $UserName" -MessageType "WARNING" -Color $Yellow
        }
    }
    Write-Log -Message "Microsoft $Browser Data Cleared." -MessageType "INFO" -Color $Green
}

# Function to Clear Internet Explorer Data
function Clear-IeData {
    Write-Log -Message "Clearing Internet Explorer Data" -MessageType "INFO" -Color $Green
    Get-ChildItem "C:\Users" -Directory | ForEach-Object {
        $UserName = $_.Name
        $UserProfilePath = $_.FullName
        $IeCachePath     = "$UserProfilePath\AppData\Local\Microsoft\Windows\INetCache"
        $IeCookiesPath   = "$UserProfilePath\AppData\Local\Microsoft\Windows\INetCookies"
        $IeHistoryPath   = "$UserProfilePath\AppData\Local\Microsoft\Windows\History"
        Write-Log -Message "  Processing Internet Explorer data for user: $UserName" -MessageType "INFO" -Color $Cyan
        $PathsToClear = @(
            "$IeCachePath\*",
            "$IeCookiesPath\*",
            "$IeHistoryPath\*"
        )
        foreach ($Path in $PathsToClear) {
            Remove-Items -Path $Path
        }
    }
    $SystemPathsToClear = @(
        "C:\Windows\Temp\*",
        "C:\Windows\Prefetch\*",
        "C:\$Recycle.Bin\*"
    )
    foreach ($Path in $SystemPathsToClear) {
        Remove-Items -Path $Path
    }
    Write-Log -Message "Internet Explorer Data Cleared." -MessageType "INFO" -Color $Green
}

# Function to Perform General System Cleanup
function Clear-SystemTemp {
    Write-Log -Message "Performing General System Cleanup" -MessageType "INFO" -Color $Green
    $GeneralTempPaths = @(
        "C:\Users\*\AppData\Local\Temp\*",
        "C:\Windows\Temp\*",
        "C:\Windows\Prefetch\*",
        "C:\$Recycle.Bin\*",
        "C:\ProgramData\Microsoft\Windows\WER\*"
    )
    foreach ($Path in $GeneralTempPaths) {
        Remove-Items -Path $Path
    }
    Write-Log -Message "General System Cleanup Completed." -MessageType "INFO" -Color $Green
}

# Function to Clear WhatsApp Data
function Clear-WhatsAppData {
    Write-Log -Message "Clearing WhatsApp Data" -MessageType "INFO" -Color $Green
    Get-ChildItem "C:\Users" -Directory | ForEach-Object {
        $UserName = $_.Name
        $UserProfilePath = $_.FullName
        $WhatsAppPaths = @(
            "$UserProfilePath\AppData\Roaming\WhatsApp",
            "$UserProfilePath\AppData\Local\WhatsApp"
        )
        foreach ($Path in $WhatsAppPaths) {
            if (Test-Path $Path) {
                Write-Log -Message "  Processing WhatsApp data for user: $UserName" -MessageType "INFO" -Color $Cyan
                $PathsToClear = @(
                    "$Path\Cache",
                    "$Path\Local Storage",
                    "$Path\*.*_lock",
                    "$Path\Sessions",
                    "$Path\Databases",
                    "$Path\IndexedDB",
                    "$Path\Media Cache",
                    "$Path\*.*"
                )
                foreach ($ClearPath in $PathsToClear) {
                    Remove-Items -Path $ClearPath
                }
            }
            else {
                Write-Log -Message "WhatsApp data path not found for user: $UserName" -MessageType "WARNING" -Color $Yellow
            }
        }
    }
    Write-Log -Message "WhatsApp Data Cleared." -MessageType "INFO" -Color $Green
}

# Main Script Execution - Logging Header
$headerMessage = @"
#######################################################
PowerShell Script: Delete Cookies, Cache, and Other Data
Browsers: Firefox, Chrome, Edge, Internet Explorer, WhatsApp
Perform General System Cleanup
Author: Luiz Hamilton Silva - @brazilianscriptguy
Updated: October 05, 2024
#######################################################
"@

Write-Log -Message $headerMessage -MessageType "INFO" -Color $Yellow

Create-GUI

# End of script
