# PowerShell Script to List Installed Software x86 and x64 with GUID with Enhanced GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 12/01/2024

# Import necessary modules
Add-Type -AssemblyName System.Windows.Forms
Import-Module ActiveDirectory

# Function to extract the GUID from the registry path
function Get-GUIDFromPath {
    param ([string]$path)
    $splitPath = $path -split '\\'
    return $splitPath[-1]
}

# Function to get installed programs
function Get-InstalledPrograms {
    # Retrieve installed programs (64-bit and 32-bit) and combine them
    $installedPrograms64Bit = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' |
                              Where-Object { $_.DisplayName } |
                              Select-Object DisplayName, DisplayVersion,
                                            @{Name="IdentifyingNumber"; Expression={Get-GUIDFromPath $_.PSPath}},
                                            @{Name="Architecture"; Expression={"64-bit"}}

    $installedPrograms32Bit = Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' |
                              Where-Object { $_.DisplayName } |
                              Select-Object DisplayName, DisplayVersion,
                                            @{Name="IdentifyingNumber"; Expression={Get-GUIDFromPath $_.PSPath}},
                                            @{Name="Architecture"; Expression={"32-bit"}}

    return $installedPrograms64Bit + $installedPrograms32Bit
}

# Create a Windows Forms form
$form = New-Object System.Windows.Forms.Form
$form.Text = "List Installed Software"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = 'CenterScreen'

# Radio buttons for output option
$radioDefaultPath = New-Object System.Windows.Forms.RadioButton
$radioDefaultPath.Text = "Use Default Documents Folder"
$radioDefaultPath.Location = New-Object System.Drawing.Point(10, 10)
$radioDefaultPath.AutoSize = $true
$radioDefaultPath.Checked = $true
$form.Controls.Add($radioDefaultPath)

$radioCustomPath = New-Object System.Windows.Forms.RadioButton
$radioCustomPath.Text = "Specify Custom Path"
$radioCustomPath.Location = New-Object System.Drawing.Point(10, 30)
$radioCustomPath.AutoSize = $true
$form.Controls.Add($radioCustomPath)

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

# Enable TextBox when custom path radio button is selected
$radioCustomPath.Add_Click({ $textBox.Enabled = $true })
$radioDefaultPath.Add_Click({ $textBox.Enabled = $false })

# OK button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Location = New-Object System.Drawing.Point(10, 100)
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($okButton)
$form.AcceptButton = $okButton

# Show the form and get the result
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $outputFileName = "GUID-Installed-Softwares_$timestamp.csv"

    if ($radioDefaultPath.Checked) {
        $outputPath = [Environment]::GetFolderPath('MyDocuments') + "\" + $outputFileName
    } elseif ($radioCustomPath.Checked) {
        $outputPath = $textBox.Text
        if ([string]::IsNullOrWhiteSpace($outputPath)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter a valid custom output path.", "Error")
            return
        }
        $outputPath = Join-Path $outputPath $outputFileName
    }

    $allInstalledPrograms = Get-InstalledPrograms
    if ($allInstalledPrograms -ne $null -and $allInstalledPrograms.Count -gt 0) {
        $allInstalledPrograms | Export-Csv -Path $outputPath -NoTypeInformation
        [System.Windows.Forms.MessageBox]::Show("List of installed software exported successfully to:`n$outputPath", "Export Successful")
    } else {
        [System.Windows.Forms.MessageBox]::Show("No installed software found to export.", "No Data")
    }
} else {
    [System.Windows.Forms.MessageBox]::Show("Operation canceled by the user.", "Canceled")
}

# End of script