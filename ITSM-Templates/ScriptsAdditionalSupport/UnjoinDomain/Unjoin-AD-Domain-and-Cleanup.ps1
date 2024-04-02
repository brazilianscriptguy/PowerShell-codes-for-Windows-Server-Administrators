# PowerShell Script to UNJOIN MACHINE FROM DOMAIN AND PERFORM CLEANUP AFTER UNJOIN
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 29, 2024

# Add necessary libraries for Windows GUI components
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Check and create the logs folder if necessary
If (-not (Test-Path "C:\ITSM-Logs")) {
    New-Item -ItemType Directory -Path "C:\ITSM-Logs"
}

# Log file path
$logPath = "C:\ITSM-Logs\Unjoin-AD-Domain-and-Cleanup.log"

# Function to add log entries
function Add-Log {
    Param ([string]$message)
    $dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "${dateTime}: $message" | Out-File -FilePath $logPath -Append
}

# Start log generation
Add-Log "Starting the script to unjoin machine from domain and perform cleanup."

# Function to check if the computer is part of a domain
function Is-ComputerInDomain {
    $computerSystem = Get-WmiObject Win32_ComputerSystem
    return $computerSystem.PartOfDomain
}

# Function to remove the computer from the domain
function Unjoin-Domain {
    if (-not (Is-ComputerInDomain)) {
        [System.Windows.Forms.MessageBox]::Show("This computer is not part of a domain.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Add-Log "This computer is not part of a domain."
        return
    }

    try {
        $credential = Get-Credential -Message "Enter the domain administrator credentials to unjoin the domain:"
        Remove-Computer -UnjoinDomainCredential $credential -Force -Restart
        Add-Log "Computer successfully unjoined from the domain."
    }
    catch {
        $errorMessage = $_.Exception.Message
        [System.Windows.Forms.MessageBox]::Show("An error occurred while trying to unjoin the domain:`n$errorMessage", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        Add-Log "Error trying to unjoin the domain: $errorMessage"
    }
}

# Function for post-unjoin cleanup
function Cleanup-AfterUnjoin {
    # Initialize progress bar
    $progressBar.Value = 0
    $progressBar.Step = 1
    $progressBar.Maximum = 4 # Total steps in the cleanup process

    # Step 1: Clear DNS cache
    Clear-DnsClientCache
    $progressBar.PerformStep()
    Add-Log "DNS cache cleared."

    # Step 2: Remove old domain profiles
    $profiles = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.Special -eq $false -and $_.Loaded -eq $false -and $_.LocalPath -notlike '*\Users\LocalUser*' }
    foreach ($profile in $profiles) {
        $profile.Delete()
        Add-Log "Old domain profile removed: $($profile.LocalPath)"
    }
    $progressBar.PerformStep()

    # Step 3: Clear domain-related environment variables
    [Environment]::SetEnvironmentVariable("LOGONSERVER", $null, [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("USERDOMAIN", $null, [EnvironmentVariableTarget]::Machine)
    [Environment]::SetEnvironmentVariable("USERDNSDOMAIN", $null, [EnvironmentVariableTarget]::Machine)
    $progressBar.PerformStep()
    Add-Log "Domain environment variables cleared."

    # Step 4: Schedule system restart after 20 seconds
    Start-Process "shutdown" -ArgumentList "/r /f /t 20" -NoNewWindow -Wait
    $progressBar.PerformStep()
    Add-Log "System scheduled to restart in 20 seconds."

    [System.Windows.Forms.MessageBox]::Show("Cleanup completed. The system will restart in 20 seconds. Save your work.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Add-Log "Post-unjoin cleanup completed."
}

# GUI Configuration
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Domain Unjoin and Cleanup Tool'
$form.Size = New-Object System.Drawing.Size(300,250)
$form.StartPosition = 'CenterScreen'

# Button to unjoin domain
$unjoinButton = New-Object System.Windows.Forms.Button
$unjoinButton.Location = New-Object System.Drawing.Point(50,50)
$unjoinButton.Size = New-Object System.Drawing.Size(180,30)
$unjoinButton.Text = 'Unjoin Domain'
$unjoinButton.Add_Click({ Unjoin-Domain })
$form.Controls.Add($unjoinButton)

# Button for cleanup
$cleanupButton = New-Object System.Windows.Forms.Button
$cleanupButton.Location = New-Object System.Drawing.Point(50,100)
$cleanupButton.Size = New-Object System.Drawing.Size(180,30)
$cleanupButton.Text = 'Cleanup After Unjoin'
$cleanupButton.Add_Click({
    $form.Hide() # Hide the form to not block the progress bar
    Cleanup-AfterUnjoin
})
$form.Controls.Add($cleanupButton)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(50,150)
$progressBar.Size = New-Object System.Drawing.Size(180,20)
$form.Controls.Add($progressBar)

# Show the form
$form.ShowDialog()

# End of script
Add-Log "Domain unjoin and cleanup tool finished."