# PowerShell Script to Find and Delete Empty Files with Enhanced GUI
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: 25/02/2024

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$logDir = 'C:\Logs-TEMP'
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory }
$logPath = Join-Path $logDir 'Find-and-Delete-Empty-Files.log'

function Log-Message {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logPath -Value "[$timestamp] $Message"
}

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

# Setup UI Elements
function SetupUIElements {
    param ($form)
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10,10)
    $listBox.Size = New-Object System.Drawing.Size(560,280)
    $form.Controls.Add($listBox)

    $buttonSelectFolder = New-Object System.Windows.Forms.Button
    $buttonSelectFolder.Location = New-Object System.Drawing.Point(10,300)
    $buttonSelectFolder.Size = New-Object System.Drawing.Size(100,30)
    $buttonSelectFolder.Text = 'Select Folder'
    $buttonSelectFolder.Add_Click({ if ($folderBrowserDialog.ShowDialog() -eq 'OK') { Find-EmptyFiles } })
    $form.Controls.Add($buttonSelectFolder)

    $buttonDeleteFiles = New-Object System.Windows.Forms.Button
    $buttonDeleteFiles.Location = New-Object System.Drawing.Point(120,300)
    $buttonDeleteFiles.Size = New-Object System.Drawing.Size(100,30)
    $buttonDeleteFiles.Text = 'Delete Files'
    $buttonDeleteFiles.Add_Click({ Delete-EmptyFiles })
    $form.Controls.Add($buttonDeleteFiles)

    $buttonOpenFolder = New-Object System.Windows.Forms.Button
    $buttonOpenFolder.Location = New-Object System.Drawing.Point(230,300)
    $buttonOpenFolder.Size = New-Object System.Drawing.Size(100,30)
    $buttonOpenFolder.Text = 'Open Folder'
    $buttonOpenFolder.Add_Click({ if ($folderBrowserDialog.SelectedPath) { Start-Process explorer.exe -ArgumentList $folderBrowserDialog.SelectedPath } })
    $form.Controls.Add($buttonOpenFolder)

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10,340)
    $progressBar.Size = New-Object System.Drawing.Size(560,20)
    $form.Controls.Add($progressBar)
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Find and Delete Empty Files'
$form.Size = New-Object System.Drawing.Size(600,450)
$form.StartPosition = 'CenterScreen'

SetupUIElements $form

$form.ShowDialog()

#End of script