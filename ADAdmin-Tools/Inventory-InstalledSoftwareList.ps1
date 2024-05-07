# PowerShell Script to List Installed Software x86 and x64 with GUID with Enhanced GUI
# Author: Luiz Hamilton Silva
# Update: May 06, 2024

# Import necessary modules
Add-Type -AssemblyName System.Windows.Forms

# Determine the script name and set up the path for the CSV export
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)

# Function to extract the GUID from the registry path
function Get-GUIDFromPath {
    param ([string]$path)
    $splitPath = $path -split '\\'
    return $splitPath[-1]
}

# Function to get installed programs
function Get-InstalledPrograms {
    # Retrieve installed programs (64-bit and 32-bit) and combine them
    $registryPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $installedPrograms = $registryPaths | ForEach-Object {
        Get-ItemProperty -Path $_ |
        Where-Object { $_.DisplayName } |
        Select-Object DisplayName, DisplayVersion,
                      @{Name="IdentifyingNumber"; Expression={Get-GUIDFromPath $_.PSPath}},
                      @{Name="Architecture"; Expression={if ($_ -match 'WOW6432Node') {'32-bit'} else {'64-bit'}}}
    }
    return $installedPrograms
}

# Main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "List Installed Software"
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.StartPosition = 'CenterScreen'

# Radio buttons for output option
$radioButtons = @{
    DefaultPath = New-Object System.Windows.Forms.RadioButton
    CustomPath  = New-Object System.Windows.Forms.RadioButton
}
$y = 10
foreach ($key in $radioButtons.Keys) {
    $radio = $radioButtons[$key]
    $radio.Text = if ($key -eq 'DefaultPath') {"Use Default Documents Folder"} else {"Specify Custom Path"}
    $radio.Location = New-Object System.Drawing.Point(10, $y)
    $radio.AutoSize = $true
    $radio.Checked = $key -eq 'DefaultPath'
    $form.Controls.Add($radio)
    $y += 20
}

# Label and TextBox for custom output path
$label = New-Object System.Windows.Forms.Label
$label.Text = "Custom Output Path:"
$label.Location = New-Object System.Drawing.Point(10, 50)
$label.AutoSize = $true
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 70)
$textBox.Size = New-Object System.Drawing.Size(370, 20)
$textBox.Enabled = $false
$form.Controls.Add($textBox)

# Enable/Disable TextBox based on radio button selection
$radioButtons.CustomPath.Add_Click({ $textBox.Enabled = $true })
$radioButtons.DefaultPath.Add_Click({ $textBox.Enabled = $false })

# OK and Cancel buttons
$buttons = @{
    OK     = New-Object System.Windows.Forms.Button
    Cancel = New-Object System.Windows.Forms.Button
}
$y = 100
foreach ($key in $buttons.Keys) {
    $button = $buttons[$key]
    $button.Text = $key
    $button.Location = New-Object System.Drawing.Point(10, $y)
    $button.Size = New-Object System.Drawing.Size(75, 23)
    $form.Controls.Add($button)
    $y += 30
    if ($key -eq 'OK') {
        $button.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $button
    } else {
        $button.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.CancelButton = $button
    }
}

# Show the form and get the result
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $outputFileName = "${scriptName}_${env:COMPUTERNAME}_${timestamp}.csv"
    
    if ($radioButtons.DefaultPath.Checked) {
        $outputPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) $outputFileName
    } elseif ($radioButtons.CustomPath.Checked -and -not [string]::IsNullOrWhiteSpace($textBox.Text)) {
        $outputPath = Join-Path $textBox.Text $outputFileName
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid custom output path.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    
    $allInstalledPrograms = Get-InstalledPrograms
    if ($allInstalledPrograms -ne $null -and $allInstalledPrograms.Count -gt 0) {
        try {
            $allInstalledPrograms | Export-Csv -Path $outputPath -NoTypeInformation -ErrorAction Stop
            [System.Windows.Forms.MessageBox]::Show("List of installed software exported successfully to:`n$outputPath", "Export Successful", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to export the list of installed software. Error: $_", "Export Failed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("No installed software found to export.", "No Data", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}

# End of script
