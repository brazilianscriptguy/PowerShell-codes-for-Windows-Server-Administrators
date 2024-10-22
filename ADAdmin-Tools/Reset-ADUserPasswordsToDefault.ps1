<#
.SYNOPSIS
    PowerShell Script for Resetting AD User Passwords to a Default Value.

.DESCRIPTION
    This script resets the passwords for a group of Active Directory (AD) users to a default value, 
    providing an efficient way to manage password policies and quickly reset multiple user accounts.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: October 22, 2024
#>

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

# Import necessary assemblies and modules
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Import-Module ActiveDirectory

# Setup form and components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Reset User Passwords in Active Directory'
$form.Size = New-Object System.Drawing.Size(500, 300)
$form.StartPosition = 'CenterScreen'

# Logging setup
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
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

# Function to display error messages
function Show-ErrorMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Log-Message "Error: $message" -MessageType "ERROR"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -MessageType "INFO"
}

# Load and refresh the OUs list, filtered by "Usuarios*"
function Load-OUs {
    $global:allOUs = Get-ADOrganizationalUnit -Filter 'Name -like "Usuarios*"' | Select-Object -ExpandProperty DistinguishedName
    $cmbOUs.Items.Clear()
    $global:allOUs | ForEach-Object { $cmbOUs.Items.Add($_) }
    if ($cmbOUs.Items.Count -gt 0) {
        $cmbOUs.SelectedIndex = 0
    } else {
        $cmbOUs.Text = 'No matching OU found'
    }
}

# Label for OU search
$labelOUSearch = New-Object System.Windows.Forms.Label
$labelOUSearch.Text = 'Search for an OU:'
$labelOUSearch.Location = New-Object System.Drawing.Point(10, 20)
$labelOUSearch.AutoSize = $true
$form.Controls.Add($labelOUSearch)

# TextBox for OU search
$txtOUSearch = New-Object System.Windows.Forms.TextBox
$txtOUSearch.Location = New-Object System.Drawing.Point(10, 50)
$txtOUSearch.Size = New-Object System.Drawing.Size(450, 20)
$form.Controls.Add($txtOUSearch)

# ComboBox for displaying OUs
$cmbOUs = New-Object System.Windows.Forms.ComboBox
$cmbOUs.Location = New-Object System.Drawing.Point(10, 80)
$cmbOUs.Size = New-Object System.Drawing.Size(450, 20)
$cmbOUs.DropDownStyle = 'DropDownList'
$form.Controls.Add($cmbOUs)

# Button to load OUs
$btnLoadOUs = New-Object System.Windows.Forms.Button
$btnLoadOUs.Text = 'Refresh OUs List'
$btnLoadOUs.Location = New-Object System.Drawing.Point(10, 110)
$btnLoadOUs.Size = New-Object System.Drawing.Size(150, 23)
$btnLoadOUs.Add_Click({ Load-OUs })
$form.Controls.Add($btnLoadOUs)

# Search functionality
$txtOUSearch.Add_TextChanged({
    $searchText = $txtOUSearch.Text
    $filteredOUs = $global:allOUs | Where-Object { $_ -like "*$searchText*" }
    $cmbOUs.Items.Clear()
    $filteredOUs | ForEach-Object { $cmbOUs.Items.Add($_) }
    if ($cmbOUs.Items.Count -gt 0) {
        $cmbOUs.SelectedIndex = 0
    } else {
        $cmbOUs.Text = 'No matching OU found'
    }
})

# Label for Default Password
$labelPassword = New-Object System.Windows.Forms.Label
$labelPassword.Text = 'Enter the default password:'
$labelPassword.Location = New-Object System.Drawing.Point(10, 150)
$labelPassword.AutoSize = $true
$form.Controls.Add($labelPassword)

# TextBox for Default Password input
$textBoxPassword = New-Object System.Windows.Forms.TextBox
$textBoxPassword.Location = New-Object System.Drawing.Point(10, 170)
$textBoxPassword.Size = New-Object System.Drawing.Size(450, 20)
$form.Controls.Add($textBoxPassword)

# Function to reset user passwords in a specific OU
function Reset-UserPasswords {
    param (
        [string]$ou,
        [string]$defaultPassword
    )

    Log-Message "Starting password reset process in '$ou' with default password."

    try {
        $users = Get-ADUser -Filter * -SearchBase $ou -Properties SamAccountName
        foreach ($user in $users) {
            Set-ADAccountPassword $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $defaultPassword -Force) -PassThru | Set-ADUser -ChangePasswordAtLogon $true
            Log-Message "Password reset for $($user.SamAccountName) with 'change at login' enforced."
        }
        Show-InfoMessage "Password reset process completed successfully. All users are required to change their password at next login."
    } catch {
        Log-Message "Error encountered during password reset process: $_" -MessageType "ERROR"
        Show-ErrorMessage "Error encountered during password reset process: $_"
    }
}

# Button to execute password reset
$buttonExecute = New-Object System.Windows.Forms.Button
$buttonExecute.Text = 'Reset Passwords'
$buttonExecute.Location = New-Object System.Drawing.Point(10, 200)
$buttonExecute.Size = New-Object System.Drawing.Size(150, 30)
$buttonExecute.Add_Click({
    Log-Message "Reset Passwords button clicked, starting password reset process."
    $ou = $cmbOUs.SelectedItem.ToString()
    $defaultPassword = $textBoxPassword.Text

    if (![string]::IsNullOrWhiteSpace($ou) -and ![string]::IsNullOrWhiteSpace($defaultPassword)) {
        if ([System.Windows.Forms.MessageBox]::Show("Are you sure you want to reset passwords in '$ou'?", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question) -eq [System.Windows.Forms.DialogResult]::Yes) {
            Reset-UserPasswords -ou $ou -defaultPassword $defaultPassword
        } else {
            Log-Message "Password reset cancelled by user."
        }
    } else {
        Show-ErrorMessage "Please provide a valid OU Distinguished Name and default password."
    }
})
$form.Controls.Add($buttonExecute)

# Show the form
$form.ShowDialog() | Out-Null

# End of script
