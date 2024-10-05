# PowerShell Script to Delete Cookies, Cache, and Other Data for Firefox, Chrome, Edge, Internet Explorer, WhatsApp, and Perform General System Cleanup
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: October 05, 2024

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
    }
    elseif ($Browser -eq "Edge") {
        "C:\Users\*\AppData\Local\Microsoft\Edge\User Data"
    }
    Get-ChildItem -Path "C:\Users" -Directory | ForEach-Object {
        $UserName = $_.Name
        $UserProfilePath = $_.FullName
        if ($Browser -eq "Chrome") {
            $BrowserPath = "$UserProfilePath\AppData\Local\Google\Chrome\User Data"
        }
        elseif ($Browser -eq "Edge") {
            $BrowserPath = "$UserProfilePath\AppData\Local\Microsoft\Edge\User Data"
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
                $FontCachePath = "$ProfileFullPath\ChromeDWriteFontCache"
                Remove-Items -Path $FontCachePath
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
# Function to Import Required Module (Optional)
function Import-RequiredModule {
    param (
        [string]$ModuleName
    )
    if (-not (Get-Module -Name $ModuleName)) {
        try {
            if (Get-Module -ListAvailable -Name $ModuleName) {
                Import-Module -Name $ModuleName -ErrorAction Stop
                Write-Log -Message "Module $ModuleName imported successfully." -MessageType "INFO" -Color $Green
            } else {
                $msg = "Module $ModuleName is not available. Please install the module."
                Write-Log -Message $msg -MessageType "CRITICAL" -Color $Yellow
                [System.Windows.Forms.MessageBox]::Show($msg, "Module Import Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                exit
            }
        } catch {
            Handle-Error "Failed to import $ModuleName module. Ensure it's installed and you have the necessary permissions."
            exit
        }
    }
}
# Import Required Module (Optional)
# Uncomment the following lines if you need to import ActiveDirectory module
# Import-RequiredModule -ModuleName 'ActiveDirectory'
# Determine script name and set up file paths dynamically
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { 'C:\Logs-TEMP' }
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName
$csvPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "${scriptName}-$timestamp.csv"
# Global Variables Initialization
$global:logBox = New-Object System.Windows.Forms.ListBox
$global:results = @{}
# Function to Create the GUI
function Create-GUI {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Web Browser Cleanup Tool"
    $form.Size = New-Object System.Drawing.Size(800,600)
    $form.StartPosition = "CenterScreen"
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Multiline = $true
    $textBox.ScrollBars = "Vertical"
    $textBox.Size = New-Object System.Drawing.Size(760,300)
    $textBox.Location = New-Object System.Drawing.Point(10,10)
    $textBox.ReadOnly = $true
    $form.Controls.Add($textBox)
    $instructionLabel = New-Object System.Windows.Forms.Label
    $instructionLabel.Text = "Click 'Start' to begin the cleanup process:"
    $instructionLabel.Location = New-Object System.Drawing.Point(10, 320)
    $instructionLabel.Size = New-Object System.Drawing.Size(300,20)
    $form.Controls.Add($instructionLabel)
    $global:logBox = New-Object System.Windows.Forms.ListBox
    $global:logBox.Size = New-Object System.Drawing.Size(760,100)
    $global:logBox.Location = New-Object System.Drawing.Point(10,385)
    $form.Controls.Add($global:logBox)
    $buttonStart = New-Object System.Windows.Forms.Button
    $buttonStart.Text = "Start"
    $buttonStart.Size = New-Object System.Drawing.Size(100,30)
    $buttonStart.Location = New-Object System.Drawing.Point(10,500)
    $form.Controls.Add($buttonStart)
    $buttonSave = New-Object System.Windows.Forms.Button
    $buttonSave.Text = "Save to CSV"
    $buttonSave.Size = New-Object System.Drawing.Size(100,30)
    $buttonSave.Location = New-Object System.Drawing.Point(120,500)
    $buttonSave.Enabled = $false
    $form.Controls.Add($buttonSave)
    $buttonClose = New-Object System.Windows.Forms.Button
    $buttonClose.Text = "Close"
    $buttonClose.Size = New-Object System.Drawing.Size(100,30)
    $buttonClose.Location = New-Object System.Drawing.Point(230,500)
    $form.Controls.Add($buttonClose)
    $buttonStart.Add_Click({
        $buttonStart.Enabled = $false
        $buttonSave.Enabled = $false
        $textBox.Clear()
        $textBox.Text = "Process started, please wait..."
        try {
            Clear-FirefoxData
            Clear-ChromeAndEdgeData -Browser "Chrome"
            Clear-ChromeAndEdgeData -Browser "Edge"
            Clear-IeData
            Clear-WhatsAppData
            Clear-SystemTemp
            $textBox.Text = "Cleanup process completed successfully."
            Write-Log -Message "Cleanup process completed successfully." -MessageType "INFO" -Color $Green
            if ($ShowConsole) {
                Write-Host "Cleanup process completed successfully." -ForegroundColor Green
            }
            $buttonSave.Enabled = $true
        }
        catch {
            Handle-Error "An error occurred during the cleanup process: $_"
            $textBox.Text = "An error occurred. Check the logs for details."
            if ($ShowConsole) {
                Write-Host "An error occurred during the cleanup process. Check the logs for details." -ForegroundColor Red
            }
        }
        finally {
            $buttonStart.Enabled = $true
        }
    })
    $buttonSave.Add_Click({
        if ($null -eq $global:results -or $global:results.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No data to save. Please ensure the process has completed successfully.", "No Data", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        try {
            $csvData = @()
            foreach ($category in $global:results.Keys) {
                $row = New-Object PSObject
                $row | Add-Member -MemberType NoteProperty -Name "Category" -Value $category
                foreach ($item in $global:results[$category]) {
                    $row | Add-Member -MemberType NoteProperty -Name $item -Value ($item -join ', ')
                }
                $csvData += $row
            }
            $csvData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
            [System.Windows.Forms.MessageBox]::Show("Results saved to " + $csvPath, "Save Successful", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            Write-Log -Message "Results saved to CSV file: $csvPath" -MessageType "INFO" -Color $Green
        } catch {
            Handle-Error "Failed to save results to CSV: $_"
        }
    })
    $buttonClose.Add_Click({
        $form.Close()
    })
    $form.ShowDialog()
}
# Main Script Execution
Write-Log -Message "#######################################################" -MessageType "INFO" -Color $Yellow
Write-Log -Message "PowerShell commands to delete cookies, cache, and other data" -MessageType "INFO" -Color $Green
Write-Log -Message "in Firefox, Chrome, Edge, Internet Explorer, WhatsApp," -MessageType "INFO" -Color $Green
Write-Log -Message "and perform general system cleanup" -MessageType "INFO" -Color $Green
Write-Log -Message "By Luiz Hamilton Silva - @brazilianscriptguy" -MessageType "INFO" -Color $Green
Write-Log -Message "Updated: October 05, 2024" -MessageType "INFO" -Color $Green
Write-Log -Message "#######################################################`n" -MessageType "INFO" -Color $Yellow
Create-GUI

# End of script
