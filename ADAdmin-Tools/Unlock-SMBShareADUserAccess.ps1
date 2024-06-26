# PowerShell Script to Unlock User in a DFS Namespace Access with GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 10, 2024

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

# Load Windows Forms and drawing libraries
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Configure error handling to silently continue
$ErrorActionPreference = "SilentlyContinue"

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
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
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

# Function to create label
function Create-Label {
    param (
        [string]$Text,
        [int[]]$Location,
        [int[]]$Size
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $label.Size = New-Object System.Drawing.Size($Size[0], $Size[1])
    $label.Text = $Text
    return $label
}

# Function to create textbox
function Create-TextBox {
    param (
        [int[]]$Location,
        [int[]]$Size,
        [string]$Text = ""
    )
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $textBox.Size = New-Object System.Drawing.Size($Size[0], $Size[1])
    $textBox.Text = $Text
    return $textBox
}

# Function to create button
function Create-Button {
    param (
        [string]$Text,
        [int[]]$Location,
        [int[]]$Size,
        [ScriptBlock]$OnClick
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $button.Size = New-Object System.Drawing.Size($Size[0], $Size[1])
    $button.Text = $Text
    $button.Add_Click($OnClick)
    return $button
}

# Function to create ComboBox
function Create-ComboBox {
    param (
        [int[]]$Location,
        [int[]]$Size,
        [string[]]$Items
    )
    $comboBox = New-Object System.Windows.Forms.ComboBox
    $comboBox.Location = New-Object System.Drawing.Point($Location[0], $Location[1])
    $comboBox.Size = New-Object System.Drawing.Size($Size[0], $Size[1])
    $comboBox.Items.AddRange($Items)
    $comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    return $comboBox
}

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -MessageType "ERROR"
}

# Function to display warning messages
function Show-WarningMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Warning', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    Log-Message "Warning: $message" -MessageType "WARNING"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Function to get the FQDN of the domain name
function Get-DomainFQDN {
    try {
        $ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
        $Domain = $ComputerSystem.Domain
        return $Domain
    } catch {
        Show-WarningMessage "Unable to fetch FQDN automatically."
        return "YourDomainHere"
    }
}

# Function to gather current DFS namespaces using Win32_Share
function Get-DFSNamespaces {
    param (
        [string]$ComputerName
    )

    try {
        $shares = Get-CimInstance -ClassName Win32_Share -ComputerName $ComputerName | Where-Object {
            $_.Type -eq 0 # 0 is the type for Disk Drive
        }
        $namespaces = $shares.Name
        if ($namespaces) {
            Log-Message "Retrieved DFS Namespaces: $($namespaces -join ', ')"
            return $namespaces
        } else {
            Show-WarningMessage "No DFS Namespaces found."
            return @()
        }
    } catch {
        Show-WarningMessage "Failed to retrieve DFS Namespaces: $_"
        return @()
    }
}

# Retrieve the FQDN of the current domain
$currentDomainFQDN = Get-DomainFQDN
$localComputerName = $env:COMPUTERNAME

# Retrieve DFS Namespaces
$dfsNamespaces = Get-DFSNamespaces -ComputerName $localComputerName

# Main form setup
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'Unlock User in DFS Namespace'
$main_form.Size = New-Object System.Drawing.Size(500, 400)
$main_form.StartPosition = 'CenterScreen'
$main_form.Topmost = $true

# Labels and TextBoxes setup
$main_form.Controls.Add((Create-Label 'Select the DFS Namespace:' @(10,20) @(480,20)))
$comboBox_namespace = Create-ComboBox @(10,50) @(460,20) -Items $dfsNamespaces
$main_form.Controls.Add($comboBox_namespace)

$main_form.Controls.Add((Create-Label 'Enter the Domain name:' @(10,90) @(480,20)))
$textbox_domain = Create-TextBox @(10,120) @(460,20) -Text $currentDomainFQDN
$main_form.Controls.Add($textbox_domain)

$main_form.Controls.Add((Create-Label 'Enter the User Login name:' @(10,160) @(480,20)))
$textbox_user = Create-TextBox @(10,190) @(460,20)
$main_form.Controls.Add($textbox_user)

# Check Blocked Users Button with Validation and Error Handling
$check_button = Create-Button 'Check Blocked Users' @(10,230) @(230,40) {
    try {
        if ([string]::IsNullOrWhiteSpace($comboBox_namespace.SelectedItem) -or [string]::IsNullOrWhiteSpace($textbox_domain.Text) -or [string]::IsNullOrWhiteSpace($textbox_user.Text)) {
            Show-WarningMessage 'Please enter all required fields (namespace, domain name, and username).'
        } else {
            $namespace = "\\$($comboBox_namespace.SelectedItem)"
            $result = Get-SmbShareAccess -Name $namespace
            if ($result) {
                $result | Out-GridView -Title 'SMB Share Access'
                Log-Message "SMB Share Access retrieved successfully."
            } else {
                Show-InfoMessage 'No blocked users found for the specified DFS Namespace.'
                Log-Message "No blocked users found for DFS Namespace: $namespace"
            }
        }
    } catch {
        Show-ErrorMessage "Failed to retrieve SMB Share Access: $_"
    }
}
$main_form.Controls.Add($check_button)

# Unlock User Button with Validation, Error Handling, and Feedback
$unblock_button = Create-Button 'Unlock User' @(250,230) @(230,40) {
    try {
        if ([string]::IsNullOrWhiteSpace($comboBox_namespace.SelectedItem) -or [string]::IsNullOrWhiteSpace($textbox_domain.Text) -or [string]::IsNullOrWhiteSpace($textbox_user.Text)) {
            Show-WarningMessage 'Please enter all required fields (namespace, domain name, and username).'
        } else {
            $namespace = "\\$($comboBox_namespace.SelectedItem)"
            $username = "$($textbox_domain.Text)\$($textbox_user.Text)"
            Unblock-SmbShareAccess -Name $namespace -AccountName $username -Force
            Show-InfoMessage 'User successfully unlocked!'
            Log-Message "User $username successfully unlocked in DFS Namespace: $namespace"
        }
    } catch {
        Show-ErrorMessage "Failed to unlock user: $_"
    }
}
$main_form.Controls.Add($unblock_button)

# Close Button
$close_button = Create-Button 'Close' @(10,280) @(470,40) {
    $main_form.Close()
}
$main_form.Controls.Add($close_button)

# Show the main form
[void]$main_form.ShowDialog()

# End of script
