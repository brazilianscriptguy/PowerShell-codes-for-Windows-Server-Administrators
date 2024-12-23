<#
.SYNOPSIS
    PowerShell Script for Managing Expired Certificates in a Windows Certificate Authority.

.DESCRIPTION
    This script automates listing, revoking, and removing expired certificates 
    in a Windows Certificate Authority. It handles large volumes efficiently with batch processing.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 23, 2024
#>

# Hide PowerShell Console
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

# Add Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Logging Setup
$logDir = 'C:\Logs-TEMP'
$logFileName = "CA_Management_$(Get-Date -Format 'yyyyMMddHHmmss').log"
$logPath = Join-Path $logDir $logFileName

# Ensure Log Directory Exists
if (-not (Test-Path -Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Log Function
function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "ERROR")]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logPath -Value $logEntry
}

# Message Display
function Show-Message {
    param (
        [string]$Message,
        [ValidateSet("Error", "Information")]$Type
    )
    $icon = if ($Type -eq 'Error') { [System.Windows.Forms.MessageBoxIcon]::Error } else { [System.Windows.Forms.MessageBoxIcon]::Information }
    [System.Windows.Forms.MessageBox]::Show($Message, $Type, [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
}

# Retrieve Expired Certificates
function Get-ExpiredCertificates {
    Write-Log "Fetching expired certificates..." -Level "INFO"
    try {
        $output = certutil -view -restrict "Disposition=20" | Out-String
        $lines = $output -split "`r?`n"
        $expiredCertificates = @()
        foreach ($line in $lines) {
            if ($line -match "Request ID: (\d+).*Certificate Expiration Date: (\d+/\d+/\d+ \d+:\d+:\d+)") {
                $requestID = $matches[1]
                $expirationDate = [datetime]$matches[2]
                if ($expirationDate -lt (Get-Date)) {
                    $expiredCertificates += [PSCustomObject]@{
                        RequestID      = $requestID
                        ExpirationDate = $expirationDate
                    }
                }
            }
        }
        Write-Log "Retrieved $($expiredCertificates.Count) expired certificates." -Level "INFO"
        return $expiredCertificates
    } catch {
        Write-Log "Error fetching expired certificates: $_" -Level "ERROR"
        return @()
    }
}

# Revoke Expired Certificates
function Revoke-ExpiredCertificates {
    $expiredCertificates = Get-ExpiredCertificates
    if ($expiredCertificates.Count -eq 0) {
        Show-Message -Message "No expired certificates to revoke." -Type "Information"
        return
    }

    $total = $expiredCertificates.Count
    $counter = 0
    Write-Log "Starting certificate revocation for $total certificates." -Level "INFO"

    foreach ($cert in $expiredCertificates) {
        try {
            certutil -revoke $cert.RequestID | Out-Null
            $counter++
            Write-Log "Revoked certificate RequestID: $($cert.RequestID)" -Level "INFO"
        } catch {
            Write-Log "Error revoking certificate RequestID: $($cert.RequestID) - $_" -Level "ERROR"
        }
    }
    Show-Message -Message "$counter of $total expired certificates revoked." -Type "Information"
}

# Remove Revoked Certificates
function Remove-RevokedCertificates {
    try {
        certutil -deleterow 20 | Out-Null
        Write-Log "All revoked certificates removed successfully." -Level "INFO"
        Show-Message -Message "All revoked certificates removed." -Type "Information"
    } catch {
        Write-Log "Error removing revoked certificates: $_" -Level "ERROR"
    }
}

# Compact CA Database
function Compact-CADatabase {
    try {
        certutil -compactdb | Out-Null
        Write-Log "CA database compacted successfully." -Level "INFO"
        Show-Message -Message "CA database compacted successfully." -Type "Information"
    } catch {
        Write-Log "Error compacting CA database: $_" -Level "ERROR"
    }
}

# GUI Design
$form = New-Object System.Windows.Forms.Form
$form.Text = "CA Management Tool"
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = 'CenterScreen'

# Buttons
$form.Controls.Add((New-Object System.Windows.Forms.Button -Property @{
    Text = "List Expired Certificates"
    Location = New-Object System.Drawing.Point(10, 10)
    Size = New-Object System.Drawing.Size(580, 40)
    Add_Click = {
        $certs = Get-ExpiredCertificates
        Show-Message -Message "$($certs.Count) expired certificates found. Check the logs for details." -Type "Information"
    }
}))

$form.Controls.Add((New-Object System.Windows.Forms.Button -Property @{
    Text = "Revoke Expired Certificates"
    Location = New-Object System.Drawing.Point(10, 60)
    Size = New-Object System.Drawing.Size(580, 40)
    Add_Click = {
        Revoke-ExpiredCertificates
    }
}))

$form.Controls.Add((New-Object System.Windows.Forms.Button -Property @{
    Text = "Remove Revoked Certificates"
    Location = New-Object System.Drawing.Point(10, 110)
    Size = New-Object System.Drawing.Size(580, 40)
    Add_Click = {
        Remove-RevokedCertificates
    }
}))

$form.Controls.Add((New-Object System.Windows.Forms.Button -Property @{
    Text = "Compact CA Database"
    Location = New-Object System.Drawing.Point(10, 160)
    Size = New-Object System.Drawing.Size(580, 40)
    Add_Click = {
        Compact-CADatabase
    }
}))

$form.Controls.Add((New-Object System.Windows.Forms.Button -Property @{
    Text = "Close"
    Location = New-Object System.Drawing.Point(10, 210)
    Size = New-Object System.Drawing.Size(580, 40)
    Add_Click = {
        $form.Close()
    }
}))

# Show the GUI
[void]$form.ShowDialog()

# End of script
