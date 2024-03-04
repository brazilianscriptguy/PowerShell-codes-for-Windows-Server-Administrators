# PowerShell Script for Resetting all Domain GPOs from Workstation and Resync with GUI Interface
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 04/03/2024

# Load Windows Forms and drawing assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define the function to delete GPO directories
function Delete-GPODirectory {
    param ([string]$FolderPath)
    if (Test-Path -Path $FolderPath) {
        Remove-Item -Path $FolderPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Define the logging function
function Log-Message {
    param ([string]$Message)
    $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    $LogFilePath = "C:\Logs-TEMP\ClearDomainGPOs-InitiateSync-Explicit.log"
    Add-Content -Path $LogFilePath -Value $LogEntry
}

# Create the Form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = 'Reset Domain GPOs'
$Form.Size = New-Object System.Drawing.Size(400,200)
$Form.StartPosition = 'CenterScreen'

# Add a label to the form
$Label = New-Object System.Windows.Forms.Label
$Label.Text = 'Are you sure you want to reset all Domain GPOs and resync?'
$Label.Location = New-Object System.Drawing.Point(10,20)
$Label.Size = New-Object System.Drawing.Size(380,40)
$Form.Controls.Add($Label)

# Add Yes Button
$YesButton = New-Object System.Windows.Forms.Button
$YesButton.Text = 'Yes'
$YesButton.Location = New-Object System.Drawing.Point(75,100)
$YesButton.Size = New-Object System.Drawing.Size(100,23)
$YesButton.DialogResult = [System.Windows.Forms.DialogResult]::Yes
$Form.Controls.Add($YesButton)
$Form.AcceptButton = $YesButton

# Add No Button
$NoButton = New-Object System.Windows.Forms.Button
$NoButton.Text = 'No'
$NoButton.Location = New-Object System.Drawing.Point(225,100)
$NoButton.Size = New-Object System.Drawing.Size(100,23)
$NoButton.DialogResult = [System.Windows.Forms.DialogResult]::No
$Form.Controls.Add($NoButton)
$Form.CancelButton = $NoButton

# Show the Form
$Form.Topmost = $True
$Result = $Form.ShowDialog()

if ($Result -eq [System.Windows.Forms.DialogResult]::Yes) {
    try {
        # Logging the script start time
        Log-Message "Script execution started."

        # Deleting the registry key where current GPO settings reside
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy" -Recurse -Force -ErrorAction SilentlyContinue

        # Removing Group Policy directories
        $envWinDir = [System.Environment]::GetEnvironmentVariable("WinDir")
        Delete-GPODirectory -FolderPath "$envWinDir\System32\GroupPolicy"
        Delete-GPODirectory -FolderPath "$envWinDir\System32\GroupPolicyUsers"
        Delete-GPODirectory -FolderPath "$envWinDir\SysWOW64\GroupPolicy"
        Delete-GPODirectory -FolderPath "$envWinDir\SysWOW64\GroupPolicyUsers"

        # Logging the script completion time
        Log-Message "Script execution completed successfully."

        # Scheduling a system restart after 15 minutes
        Start-Process "shutdown" -ArgumentList "/r /f /t 900 /c ""O Sistema reiniciará em 15 minutos. Por favor, salve o seu trabalho e aguarde a reinicialização.""" -NoNewWindow -Wait
    }
    catch {
        # Logging any errors that occur during script execution
        Log-Message "An error occurred: $_"
    }
}

#End of script
