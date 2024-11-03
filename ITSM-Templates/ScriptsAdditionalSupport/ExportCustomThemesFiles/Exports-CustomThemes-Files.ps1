<#
.SYNOPSIS
    PowerShell Script for Exporting Custom Windows Theme Files.

.DESCRIPTION
    This script exports specific theme customization files, including LayoutModification.xml, 
    the current .msstyles file, and the .deskthemepack file, to a designated directory.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: November 3, 2024
#>

# Hide PowerShell console window
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
}
"@
[Window]::Hide()

# Import necessary libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set up log path and output directory
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = "C:\ITSM-Logs"
$outputFolder = Join-Path -Path $logDir -ChildPath "Exported-Themes"
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure output and log directories exist
if (-not (Test-Path $logDir)) {
    try {
        New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    } catch {
        Write-Error "Failed to create log directory at ${logDir}. Logging will not be possible."
        return
    }
}
New-Item -Path $outputFolder -ItemType Directory -Force | Out-Null

# Function to log messages
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"
    
    try {
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Error "Failed to write to log: $_"
    }
}

# Function to Handle Errors
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Write-Log -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

Write-Log -Message "Starting Windows Theme Customization Files Export." -MessageType "INFO"

# Function to export theme files
function Export-ThemeFiles {
    Write-Log -Message "Starting export operation..." -MessageType "INFO"
    
    # Export LayoutModification.xml
    try {
        $layoutModificationPath = Join-Path -Path $outputFolder -ChildPath "LayoutModification.xml"
        Export-StartLayout -Path $layoutModificationPath
        Write-Log -Message "LayoutModification.xml exported successfully to $layoutModificationPath" -MessageType "INFO"
    } catch {
        Handle-Error "Failed to export LayoutModification.xml: $_"
    }
    
    # Export current .msstyles file
    try {
        $msstylesPath = Join-Path -Path $outputFolder -ChildPath "CurrentTheme.msstyles"
        $currentMsstyles = "$env:SYSTEMROOT\Resources\Themes\aero\aero.msstyles"
        Copy-Item -Path $currentMsstyles -Destination $msstylesPath -Force
        Write-Log -Message "Current .msstyles exported successfully to $msstylesPath" -MessageType "INFO"
    } catch {
        Handle-Error "Failed to export current .msstyles: $_"
    }
    
    # Export current .deskthemepack file
    try {
        $deskThemePackPath = Join-Path -Path $outputFolder -ChildPath "CurrentTheme.deskthemepack"
        $currentDeskThemePack = "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper"
        Copy-Item -Path $currentDeskThemePack -Destination $deskThemePackPath -Force
        Write-Log -Message "Current .deskthemepack exported successfully to $deskThemePackPath" -MessageType "INFO"
    } catch {
        Handle-Error "Failed to export current .deskthemepack: $_"
    }

    # Display a completion message box
    $filesExported = "LayoutModification.xml; CurrentTheme.msstyles; CurrentTheme.deskthemepack."
    [System.Windows.Forms.MessageBox]::Show(("The following files have been exported to {0}:`n{1}" -f $outputFolder, $filesExported), "Export Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Write-Log -Message "Export operation completed for all theme customization files." -MessageType "INFO"
}

# GUI setup
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Export Windows Theme Customization Files'
$form.Size = New-Object System.Drawing.Size(500, 200)
$form.StartPosition = 'CenterScreen'

# Label to display the list of files that will be exported
$labelFilesToExport = New-Object System.Windows.Forms.Label
$labelFilesToExport.Text = "Files to be exported:"
$labelFilesToExport.Location = New-Object System.Drawing.Point(30, 20)
$labelFilesToExport.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($labelFilesToExport)

# List of files that will be exported
$listBoxFiles = New-Object System.Windows.Forms.ListBox
$listBoxFiles.Location = New-Object System.Drawing.Point(30, 50)
$listBoxFiles.Size = New-Object System.Drawing.Size(420, 60)
$listBoxFiles.Items.Add("1. LayoutModification.xml")
$listBoxFiles.Items.Add("2. CurrentTheme.msstyles")
$listBoxFiles.Items.Add("3. CurrentTheme.deskthemepack")
$form.Controls.Add($listBoxFiles)

# Export button
$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Location = New-Object System.Drawing.Point(180, 130)
$exportButton.Size = New-Object System.Drawing.Size(140, 40)
$exportButton.Text = 'Export Files'
$exportButton.Add_Click({
    Export-ThemeFiles
})
$form.Controls.Add($exportButton)

# Show the form
$form.ShowDialog() | Out-Null

Write-Log -Message "Windows Theme Customization Files Export session ended." -MessageType "INFO"

# End of script
