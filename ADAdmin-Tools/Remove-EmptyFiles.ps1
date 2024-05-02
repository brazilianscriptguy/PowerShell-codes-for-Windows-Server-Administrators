# PowerShell Script to Find and Delete Empty Files or Delete Files by Date Range with Enhanced GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: May 02, 2024.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$logDir = 'C:\Logs-TEMP'
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory }
$logPath = Join-Path $logDir 'Remove-EmptyFiles.log'

function Log-Message {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logPath -Value "[$timestamp] $Message"
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'File Operation Tool'
$form.Size = New-Object System.Drawing.Size(600,700) # Adjusted size for better layout
$form.StartPosition = 'CenterScreen'

$folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog

# Section Labels
$labelDateSection = New-Object System.Windows.Forms.Label
$labelDateSection.Location = New-Object System.Drawing.Point(10,10)
$labelDateSection.Size = New-Object System.Drawing.Size(200,20)
$labelDateSection.Text = 'Delete Files by Date Range'
$form.Controls.Add($labelDateSection)

$labelEmptyFilesSection = New-Object System.Windows.Forms.Label
$labelEmptyFilesSection.Location = New-Object System.Drawing.Point(10,360)
$labelEmptyFilesSection.Size = New-Object System.Drawing.Size(200,20)
$labelEmptyFilesSection.Text = 'Find and Delete Empty Files'
$form.Controls.Add($labelEmptyFilesSection)

# Drive and Date Pickers
$driveLabel = New-Object System.Windows.Forms.Label
$driveLabel.Location = New-Object System.Drawing.Point(10,40)
$driveLabel.Size = New-Object System.Drawing.Size(50,20)
$driveLabel.Text = 'Drive:'
$form.Controls.Add($driveLabel)

$driveComboBox = New-Object System.Windows.Forms.ComboBox
$driveComboBox.Location = New-Object System.Drawing.Point(70,40)
$driveComboBox.Size = New-Object System.Drawing.Size(260,20)
$driveComboBox.DropDownStyle = 'DropDownList'
$driveComboBox.Items.AddRange([System.IO.DriveInfo]::GetDrives().Name)
$form.Controls.Add($driveComboBox)

$startDateLabel = New-Object System.Windows.Forms.Label
$startDateLabel.Text = 'Start Date:'
$startDateLabel.Location = New-Object System.Drawing.Point(10,70)
$form.Controls.Add($startDateLabel)

$startDatePicker = New-Object System.Windows.Forms.DateTimePicker
$startDatePicker.Location = New-Object System.Drawing.Point(70,70)
$form.Controls.Add($startDatePicker)

$endDateLabel = New-Object System.Windows.Forms.Label
$endDateLabel.Text = 'End Date:'
$endDateLabel.Location = New-Object System.Drawing.Point(10,100)
$form.Controls.Add($endDateLabel)

$endDatePicker = New-Object System.Windows.Forms.DateTimePicker
$endDatePicker.Location = New-Object System.Drawing.Point(70,100)
$form.Controls.Add($endDatePicker)

$deleteByDateButton = New-Object System.Windows.Forms.Button
$deleteByDateButton.Text = 'Delete Files'
$deleteByDateButton.Location = New-Object System.Drawing.Point(10,130)
$deleteByDateButton.Size = New-Object System.Drawing.Size(320,30)
$deleteByDateButton.Add_Click({
    $drive = $driveComboBox.SelectedItem
    $startDate = $startDatePicker.Value
    $endDate = $endDatePicker.Value
    $files = Get-ChildItem -Path $drive -Recurse -File | Where-Object { $_.LastWriteTime -ge $startDate -and $_.LastWriteTime -le $endDate }
    foreach ($file in $files) {
        Remove-Item $file.FullName -Force
    }
    [System.Windows.Forms.MessageBox]::Show("Files deleted successfully!")
})
$form.Controls.Add($deleteByDateButton)

# Empty Files Section
$buttonSelectFolder = New-Object System.Windows.Forms.Button
$buttonSelectFolder.Text = 'Select Folder'
$buttonSelectFolder.Location = New-Object System.Drawing.Point(10,390)
$buttonSelectFolder.Size = New-Object System.Drawing.Size(100,30)
$buttonSelectFolder.Add_Click({ 
    if ($folderBrowserDialog.ShowDialog() -eq 'OK') { 
        Find-EmptyFiles 
    } 
})
$form.Controls.Add($buttonSelectFolder)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,430)
$listBox.Size = New-Object System.Drawing.Size(560,180)
$form.Controls.Add($listBox)

$buttonDeleteFiles = New-Object System.Windows.Forms.Button
$buttonDeleteFiles.Text = 'Delete Files'
$buttonDeleteFiles.Location = New-Object System.Drawing.Point(120,390)
$buttonDeleteFiles.Size = New-Object System.Drawing.Size(100,30)
$buttonDeleteFiles.Add_Click({ Delete-EmptyFiles })
$form.Controls.Add($buttonDeleteFiles)

$buttonOpenFolder = New-Object System.Windows.Forms.Button
$buttonOpenFolder.Text = 'Open Folder'
$buttonOpenFolder.Location = New-Object System.Drawing.Point(230,390)
$buttonOpenFolder.Size = New-Object System.Drawing.Size(100,30)
$buttonOpenFolder.Add_Click({ 
    if ($folderBrowserDialog.SelectedPath) { 
        Start-Process explorer.exe -ArgumentList $folderBrowserDialog.SelectedPath 
    } 
})
$form.Controls.Add($buttonOpenFolder)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10,620)
$progressBar.Size = New-Object System.Drawing.Size(560,20)
$form.Controls.Add($progressBar)

function Find-EmptyFiles {
    $listBox.Items.Clear()
    $files = Get-ChildItem -Path $folderBrowserDialog.SelectedPath -File -Recurse -ErrorAction SilentlyContinue
    $progressBar.Maximum = $files.Count
    $progressBar.Value = 0
    $foundFiles = $files | Where-Object { $_.Length -eq 0 }
    if ($foundFiles) {
        $listBox.Items.AddRange($foundFiles.FullName)
        Log-Message "Found $($listBox.Items.Count) empty file(s)"
    } else {
        [System.Windows.Forms.MessageBox]::Show('No empty files found', 'Info')
        Log-Message 'No empty files found'
    }
}

function Delete-EmptyFiles {
    if ($listBox.Items.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show('No files to delete', 'Info')
        return
    }
    foreach ($item in $listBox.Items) {
        Remove-Item -Path $item -Force -ErrorAction SilentlyContinue
        Log-Message "Deleted file: $item"
    }
    [System.Windows.Forms.MessageBox]::Show("$($listBox.Items.Count) file(s) deleted", 'Info')
    Log-Message "$($listBox.Items.Count) file(s) deleted"
    $listBox.Items.Clear()
}

$form.ShowDialog()

#End of script
