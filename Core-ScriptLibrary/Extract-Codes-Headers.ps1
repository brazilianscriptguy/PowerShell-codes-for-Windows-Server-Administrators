<#
.SYNOPSIS
    PowerShell Script for Extracting Headers from .ps1 Files into Folder-Specific Text Files.

.DESCRIPTION
    This script recursively searches the specified root folder and its subfolders for `.ps1` files,
    extracts their headers, and writes the headers into folder-specific `.txt` files.
    Each text file is named after its respective folder.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 2, 2024
#>

# Capture the script name at the global level
$global:ScriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path)

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

# Add necessary assemblies for the GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Enhanced logging function
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
    Write-Host $logEntry
    try {
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -ErrorAction Stop
        }
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        Write-Warning "Failed to write log entry to file. Log entry: $logEntry"
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

# Function to initialize paths dynamically
function Initialize-ScriptPaths {
    param (
        [string]$defaultLogDir = 'C:\Logs-TEMP'
    )

    # Use the global $ScriptName to ensure correct log naming
    $scriptName = $global:ScriptName
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

    $logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { $defaultLogDir }
    $logFileName = "${scriptName}.log"
    $logPath = Join-Path $logDir $logFileName

    return @{
        LogDir = $logDir
        LogPath = $logPath
        ScriptName = $scriptName
    }
}

# Initialize paths with the correct invocation
$paths = Initialize-ScriptPaths
$global:logDir = $paths.LogDir
$global:logPath = $paths.LogPath

# Function to extract headers from a file
function Extract-FileHeader {
    param (
        [Parameter(Mandatory = $true)][string]$FilePath
    )

    $Header = @()
    $CollectingHeader = $false

    try {
        $HeaderLines = Get-Content -Path $FilePath -ErrorAction Stop
        foreach ($Line in $HeaderLines) {
            if ($Line -match "<#") {
                $CollectingHeader = $true
            }
            if ($CollectingHeader) {
                $Header += $Line
            }
            if ($Line -match "#>") {
                $CollectingHeader = $false
                break
            }
        }
    } catch {
        Handle-Error "Error reading file: $FilePath. $_"
    }

    return $Header
}

# Function to perform header extraction
function Start-HeaderExtraction {
    param (
        [Parameter(Mandatory = $true)][string]$RootFolder
    )

    try {
        Log-Message -Message "Starting header extraction for folder: $RootFolder" -MessageType "INFO"

        # Recursively get all subfolders and include the root folder itself
        $AllFolders = Get-ChildItem -Path $RootFolder -Directory -Recurse -ErrorAction Stop

        foreach ($Folder in $AllFolders) {
            $FolderName = $Folder.Name
            $OutputFile = Join-Path -Path $Folder.FullName -ChildPath "$FolderName-Headers.txt"
            Log-Message -Message "Creating output file: $OutputFile" -MessageType "INFO"

            # Initialize the output file
            Set-Content -Path $OutputFile -Value "### Extracted Headers for Folder: $FolderName ###`n"

            # Get all .ps1 files in the current folder
            $PS1Files = Get-ChildItem -Path $Folder.FullName -Filter *.ps1 -File -ErrorAction SilentlyContinue

            if ($PS1Files.Count -eq 0) {
                Add-Content -Path $OutputFile -Value "No PowerShell files found in this folder.`n"
                continue
            }

            foreach ($File in $PS1Files) {
                Add-Content -Path $OutputFile -Value "### $($File.Name) ###`n"

                # Extract the header from the file
                $Header = Extract-FileHeader -FilePath $File.FullName

                if ($Header.Count -gt 0) {
                    Add-Content -Path $OutputFile -Value ($Header -join "`n")
                    Add-Content -Path $OutputFile -Value "`n"  # Add spacing between headers
                } else {
                    Add-Content -Path $OutputFile -Value "No header found in $($File.Name).`n"
                }
            }
        }

        Log-Message -Message "Header extraction completed successfully for all folders." -MessageType "INFO"
    } catch {
        Handle-Error "An error occurred during header extraction. $_"
    }
}

# Function to create and run the GUI
function Show-GUI {
    # Initialize the form
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = "PowerShell Header Extractor"
    $Form.Size = New-Object System.Drawing.Size(560, 300)
    $Form.StartPosition = "CenterScreen"

    # Label for folder selection
    $FolderLabel = New-Object System.Windows.Forms.Label
    $FolderLabel.Text = "Root Folder:"
    $FolderLabel.Location = New-Object System.Drawing.Point(10, 20)
    $FolderLabel.AutoSize = $true
    $Form.Controls.Add($FolderLabel)

    # Textbox for folder input
    $FolderTextbox = New-Object System.Windows.Forms.TextBox
    $FolderTextbox.Size = New-Object System.Drawing.Size(350, 20)
    $FolderTextbox.Location = New-Object System.Drawing.Point(100, 20)
    $FolderTextbox.Text = (Get-Location).Path
    $Form.Controls.Add($FolderTextbox)

    # Button to browse folder
    $BrowseFolderButton = New-Object System.Windows.Forms.Button
    $BrowseFolderButton.Text = "Browse"
    $BrowseFolderButton.Size = New-Object System.Drawing.Size(75, 30)
    $BrowseFolderButton.Location = New-Object System.Drawing.Point(460, 20)
    $BrowseFolderButton.Add_Click({
        $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        if ($FolderBrowser.ShowDialog() -eq "OK") {
            $FolderTextbox.Text = $FolderBrowser.SelectedPath
        }
    })
    $Form.Controls.Add($BrowseFolderButton)

    # Run Button
    $RunButton = New-Object System.Windows.Forms.Button
    $RunButton.Text = "Run"
    $RunButton.Size = New-Object System.Drawing.Size(100, 30)
    $RunButton.Location = New-Object System.Drawing.Point(120, 220)
    $RunButton.Add_Click({
        $RootFolder = $FolderTextbox.Text
        if (-not (Test-Path -Path $RootFolder)) {
            Handle-Error "Invalid root folder path."
            return
        }
        Start-HeaderExtraction -RootFolder $RootFolder
        [System.Windows.Forms.MessageBox]::Show("Header extraction completed. Check folder-specific text files.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    })
    $Form.Controls.Add($RunButton)

    # Clear Button
    $ClearButton = New-Object System.Windows.Forms.Button
    $ClearButton.Text = "Clear"
    $ClearButton.Size = New-Object System.Drawing.Size(100, 30)
    $ClearButton.Location = New-Object System.Drawing.Point(240, 220)
    $ClearButton.Add_Click({
        $FolderTextbox.Clear()
    })
    $Form.Controls.Add($ClearButton)

    # Exit Button
    $ExitButton = New-Object System.Windows.Forms.Button
    $ExitButton.Text = "Exit"
    $ExitButton.Size = New-Object System.Drawing.Size(100, 30)
    $ExitButton.Location = New-Object System.Drawing.Point(360, 220)
    $ExitButton.Add_Click({
        $Form.Close()
    })
    $Form.Controls.Add($ExitButton)

    # Show the form
    $Form.ShowDialog()
}

# Show the GUI
Show-GUI

# End of script
