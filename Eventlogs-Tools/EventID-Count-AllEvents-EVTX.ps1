# PowerShell Script to Count Event IDs in an EVTX File
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Updated: April 7, 2024

Add-Type -AssemblyName System.Windows.Forms

# Create and configure the OpenFileDialog
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "Event Log files (*.evtx)|*.evtx"
$openFileDialog.Title = "Select an .evtx file"

# Show a "Please wait" window
$waitForm = New-Object Windows.Forms.Form
$waitForm.Text = "Please Wait"
$waitForm.Size = New-Object Drawing.Size @(300, 100)
$waitForm.FormBorderStyle = "FixedSingle"
$waitForm.StartPosition = "CenterScreen"

$label = New-Object Windows.Forms.Label
$label.Location = New-Object Drawing.Point @(50, 20)
$label.Size = New-Object Drawing.Size @(200, 30)
$label.Text = "Processing, please wait..."
$waitForm.Controls.Add($label)

$waitForm.Show()
$waitForm.Refresh()

# Show the OpenFileDialog and get the selected file path
if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $evtxFilePath = $openFileDialog.FileName
    $events = Get-WinEvent -Path $evtxFilePath
    $eventCounts = $events | Group-Object -Property Id | Select-Object Count, Name
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $resultFileName = "EventID-Count-AllEvents-EVTX_${timestamp}.csv"
    $resultFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments), $resultFileName)
    $eventCounts | Export-Csv -Path $resultFilePath -NoTypeInformation -Delimiter ',' -Encoding UTF8 -Force
    (Get-Content $resultFilePath) | ForEach-Object { $_ -replace 'Count', 'Counting' -replace 'Name', 'EventID' } | Set-Content $resultFilePath
    [System.Windows.Forms.MessageBox]::Show("Event counts exported to $resultFilePath", 'Report Generated', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
} else {
    [System.Windows.Forms.MessageBox]::Show('No file selected.', 'Input Error', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
}

# Close the "Please wait" window
$waitForm.Close()

#End of script
