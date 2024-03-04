# PowerShell Script for Unjoining a Domain and cleaning up Afterward
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 04/03/2024

# 
Add-Type -AssemblyName System.Windows.Forms

# Function to check if the computer is part of a domain
function Is-ComputerInDomain {
    $computerSystem = Get-WmiObject Win32_ComputerSystem
    return $computerSystem.PartOfDomain
}

# Function to remove the computer from the domain
function Unjoin-Domain {
    if (-not (Is-ComputerInDomain)) {
        [System.Windows.Forms.MessageBox]::Show("This computer is not part of a domain.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    try {
        $credential = Get-Credential -Message "Enter domain admin credentials to unjoin the domain:"
        Remove-Computer -UnjoinDomainCredential $credential -Force -Restart
    }
    catch {
        $errorMessage = $_.Exception.Message
        [System.Windows.Forms.MessageBox]::Show("An error occurred while trying to unjoin the domain: `n$errorMessage", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Function for post-restart cleanup
function Cleanup-AfterUnjoin {
    $progressBar.Value = 0
    $progressBar.Step = 1
    $progressBar.Maximum = 4 # Total steps in the cleanup process

    # Step 1: Clear DNS cache
    Clear-DnsClientCache
    $progressBar.PerformStep()

    # Step 2: Remove old domain profiles
    $profiles = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false -and $_.Loaded -eq $false -and $_.LocalPath -notlike '*\Users\LocalUser*' }
    foreach ($profile in $profiles) {
        $profile | Remove-WmiObject
    }
    $progressBar.PerformStep()

    # Step 3: Clear domain-related environment variables
    [Environment]::SetEnvironmentVariable("LOGONSERVER", $null, [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("USERDOMAIN", $null, [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("USERDNSDOMAIN", $null, [EnvironmentVariableTarget]::Machine)
    $progressBar.PerformStep()

    # Step 4: Schedule a system restart after 20 seconds
    Start-Process "shutdown" -ArgumentList "/r /f /t 20" -NoNewWindow -Wait
    $progressBar.PerformStep()

    [System.Windows.Forms.MessageBox]::Show("Cleanup completed. The system will restart in 20 seconds. Please save your work.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# GUI setup
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Domain Unjoin and Cleanup Tool'
$form.Size = New-Object System.Drawing.Size(300,250)
$form.StartPosition = 'CenterScreen'

# Unjoin Domain button
$unjoinButton = New-Object System.Windows.Forms.Button
$unjoinButton.Location = New-Object System.Drawing.Point(50,50)
$unjoinButton.Size = New-Object System.Drawing.Size(180,30)
$unjoinButton.Text = 'Unjoin Domain'
$unjoinButton.Add_Click({ Unjoin-Domain })
$form.Controls.Add($unjoinButton)

# Cleanup button
$cleanupButton = New-Object System.Windows.Forms.Button
$cleanupButton.Location = New-Object System.Drawing.Point(50,100)
$cleanupButton.Size = New-Object System.Drawing.Size(180,30)
$cleanupButton.Text = 'Cleanup After Unjoin'
$cleanupButton.Add_Click({ Cleanup-AfterUnjoin })
$form.Controls.Add($cleanupButton)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(50,150)
$progressBar.Size = New-Object System.Drawing.Size(180,20)
$form.Controls.Add($progressBar)

# Display the form
$form.ShowDialog()

#End of Script
