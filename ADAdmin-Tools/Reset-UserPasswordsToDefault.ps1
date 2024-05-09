# PowerShell Script to Batch Reset User Passwords in a Specific OU
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: May 8, 2024

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

# Import necessary modules and assemblies
Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Determine the script name and set up logging path
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = 'C:\Logs-TEMP'
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the log directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -ErrorAction Stop | Out-Null
    Log-Message "Log directory created: $logDir"
}

# Enhanced logging function
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string]$LogLevel = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$LogLevel] $Message"
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
    Log-Message "Error: $message" -LogLevel "ERROR"
}

# Function to display information messages
function Show-InfoMessage {
    param ([string]$message)
    [System.Windows.Forms.MessageBox]::Show($message, 'Information', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Info: $message" -LogLevel "INFO"
}

# Function to reset user passwords in a specific OU
function Reset-UserPasswords {
    param (
        [string]$ou,
        [string]$defaultPassword
    )
    try {
        $users = Get-ADUser -Filter * -SearchBase $ou -ErrorAction Stop
        foreach ($user in $users) {
            Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $defaultPassword -Force) -PassThru |
            Set-ADUser -ChangePasswordAtLogon $true -ErrorAction Stop
            Log-Message "Password reset for $($user.SamAccountName) with 'change at login' enforced"
        }
        Show-InfoMessage "Password reset completed successfully. All users in '$ou' are required to change their password at next login."
    } catch {
        Show-ErrorMessage "Error resetting passwords: $($_.Exception.Message)"
    }
}

# Initialize form components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Reset AD User Passwords in Specific OU'
$form.Size = New-Object System.Drawing.Size(450, 250)
$form.StartPosition = 'CenterScreen'

# Label for OU
$labelOU = New-Object System.Windows.Forms.Label
$labelOU.Text = 'Enter the Distinguished Name (DN) of the target OU:'
$labelOU.Location = New-Object System.Drawing.Point(10, 20)
$labelOU.AutoSize = $true
$form.Controls.Add($labelOU)

# Textbox for OU input
$textBoxOU = New-Object System.Windows.Forms.TextBox
$textBoxOU.Location = New-Object System.Drawing.Point(10, 40)
$textBoxOU.Size = New-Object System.Drawing.Size(420, 20)
$form.Controls.Add($textBoxOU)

# Label for Default Password
$labelPassword = New-Object System.Windows.Forms.Label
$labelPassword.Text = 'Enter the default password:'
$labelPassword.Location = New-Object System.Drawing.Point(10, 70)
$labelPassword.AutoSize = $true
$form.Controls.Add($labelPassword)

# Textbox for Password input
$textBoxPassword = New-Object System.Windows.Forms.TextBox
$textBoxPassword.Location = New-Object System.Drawing.Point(10, 90)
$textBoxPassword.Size = New-Object System.Drawing.Size(420, 20)
$textBoxPassword.PasswordChar = '*'
$form.Controls.Add($textBoxPassword)

# Button to execute password reset
$buttonExecute = New-Object System.Windows.Forms.Button
$buttonExecute.Text = 'Reset Passwords'
$buttonExecute.Location = New-Object System.Drawing.Point(10, 130)
$buttonExecute.Size = New-Object System.Drawing.Size(140, 30)
$buttonExecute.Add_Click({
    Log-Message "Reset Passwords button clicked, starting password reset process."
    $ou = $textBoxOU.Text
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

# Button to close the form
$buttonClose = New-Object System.Windows.Forms.Button
$buttonClose.Text = 'Close'
$buttonClose.Location = New-Object System.Drawing.Point(290, 130)
$buttonClose.Size = New-Object System.Drawing.Size(140, 30)
$buttonClose.Add_Click({ $form.Close() })
$form.Controls.Add($buttonClose)

# Show the form
$form.ShowDialog() | Out-Null

# Log the end of the script
Log-Message "AD User Password Reset script finished."

# End of script
