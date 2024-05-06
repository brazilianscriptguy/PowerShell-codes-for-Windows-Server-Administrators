# Determine the script name for logging and exporting .csv files
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)


$csvPath = [Environment]::GetFolderPath('MyDocuments') + "\${scriptName}-$dcName-$timestamp.csv"
