<#
.SYNOPSIS
    PowerShell Script for Managing Expired Certificates in a Windows Certificate Authority.

.DESCRIPTION
    This script automates listing, revoking, and removing expired certificates 
    in a Windows Certificate Authority. It handles large volumes efficiently with batch processing.
    It expects the user to enter a date in dd/MM/yyyy format.

.PARAMETER Until
    A DateTime up to which certificates are considered expired. Defaults to the current date if not provided.

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
    param(
        [Parameter(Mandatory=$false)]
        [DateTime]$Until = (Get-Date)   # Default to current date if none specified
    )

    # Convert the date to a certutil-friendly format (adjust if needed)
    # For dd/MM/yyyy usage, ensure your system can handle it, or use an appropriate locale-based approach.
    $dateString = $Until.ToString("MM/dd/yyyy")

    Write-Log "Fetching expired certificates until $dateString (certutil uses MM/dd/yyyy)..." -Level "INFO"
    try {
        # 'Disposition=20' -> Issued certificates; 'NotAfter<=date' -> Expires on or before the specified date
        Write-Log "Running: certutil -view -restrict 'Disposition=20,NotAfter<=$dateString'" -Level "INFO"
        $output = certutil -view -restrict "Disposition=20,NotAfter<=$dateString" | Out-String

        $lines = $output -split "`r?`n"
        $expiredCertificates = @()

        foreach ($line in $lines) {
            # Sample lines from certutil output:
            # Request ID: 123
            # Certificate Expiration Date: 12/31/2024 23:59:59
            if ($line -match "Request ID: (\d+).*Certificate Expiration Date: (\d{1,2}\/\d{1,2}\/\d{4} \d{1,2}:\d{2}:\d{2})") {
                $requestID = $matches[1]
                $expirationDate = [datetime]$matches[2]
                
                # Double-check the final date
                if ($expirationDate -le $Until) {
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
    param(
        [Parameter(Mandatory=$false)]
        [DateTime]$Until = (Get-Date)
    )

    $expiredCertificates = Get-ExpiredCertificates -Until $Until
    if ($expiredCertificates.Count -eq 0) {
        Show-Message -Message "No expired certificates to revoke." -Type "Information"
        return
    }

    $total = $expiredCertificates.Count
    $counter = 0
    Write-Log "Starting certificate revocation for $total certificate(s)." -Level "INFO"

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

# Label for date input (dd/MM/yyyy)
$dateLabel = New-Object System.Windows.Forms.Label
$dateLabel.Text = "Enter expiration date (dd/MM/yyyy):"
$dateLabel.Location = New-Object System.Drawing.Point(10, 10)
$dateLabel.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($dateLabel)

$dateText = New-Object System.Windows.Forms.TextBox
$dateText.Location = New-Object System.Drawing.Point(270, 10)
$dateText.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($dateText)

# Helper function to parse dd/MM/yyyy
function Parse-CustomDate($strDate) {
    # If the user leaves the field blank, default to today's date
    if ([string]::IsNullOrWhiteSpace($strDate)) {
        return Get-Date
    }
    else {
        try {
            # Force parse as dd/MM/yyyy
            return [datetime]::ParseExact($strDate, 'dd/MM/yyyy', $null)
        }
        catch {
            Show-Message -Message "Invalid date format. Please use dd/MM/yyyy." -Type "Error"
            return $null
        }
    }
}

# Buttons
$form.Controls.Add((New-Object System.Windows.Forms.Button -Property @{
    Text = "List Expired Certificates"
    Location = New-Object System.Drawing.Point(10, 50)
    Size = New-Object System.Drawing.Size(560, 40)
    Add_Click = {
        $untilDate = Parse-CustomDate $dateText.Text
        if ($untilDate -eq $null) { return }  # If parse failed, do nothing

        $certs = Get-ExpiredCertificates -Until $untilDate
        Show-Message -Message "$($certs.Count) expired certificate(s) found. Check the log for details." -Type "Information"
    }
}))

$form.Controls.Add((New-Object System.Windows.Forms.Button -Property @{
    Text = "Revoke Expired Certificates"
    Location = New-Object System.Drawing.Point(10, 100)
    Size = New-Object System.Drawing.Size(560, 40)
    Add_Click = {
        $untilDate = Parse-CustomDate $dateText.Text
        if ($untilDate -eq $null) { return }
        Revoke-ExpiredCertificates -Until $untilDate
    }
}))

$form.Controls.Add((New-Object System.Windows.Forms.Button -Property @{
    Text = "Remove Revoked Certificates"
    Location = New-Object System.Drawing.Point(10, 150)
    Size = New-Object System.Drawing.Size(560, 40)
    Add_Click = {
        Remove-RevokedCertificates
    }
}))

$form.Controls.Add((New-Object System.Windows.Forms.Button -Property @{
    Text = "Compact CA Database"
    Location = New-Object System.Drawing.Point(10, 200)
    Size = New-Object System.Drawing.Size(560, 40)
    Add_Click = {
        Compact-CADatabase
    }
}))

$form.Controls.Add((New-Object System.Windows.Forms.Button -Property @{
    Text = "Close"
    Location = New-Object System.Drawing.Point(10, 250)
    Size = New-Object System.Drawing.Size(560, 40)
    Add_Click = {
        $form.Close()
    }
}))

# Show the GUI
[void]$form.ShowDialog()

# End of script
