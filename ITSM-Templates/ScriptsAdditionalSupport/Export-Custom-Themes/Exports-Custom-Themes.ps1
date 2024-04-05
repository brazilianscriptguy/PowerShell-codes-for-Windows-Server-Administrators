# PowerShell Script to EXPORTS THE CUSTOM THEMES FILES
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 04, 2024

# Windows Theme Customization Files Export Script with GUI
# Now exporting specific theme customization files to C:\ITSM-Logs\Exported-Themes

# Import necessary libraries for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Logging setup
$scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$logDir = "C:\ITSM-Logs"
$outputFolder = Join-Path -Path $logDir -ChildPath "Exported-Themes"
$logFileName = "${scriptName}.log"
$logPath = Join-Path $logDir $logFileName

# Ensure the output and log directories exist
New-Item -Path $outputFolder, $logDir -ItemType Directory -Force | Out-Null

# Function to log messages
function Log-Message {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $logPath -Value $logEntry
}

# Initialize form components
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Export Windows Theme Customization Files'
$form.Size = New-Object System.Drawing.Size(500, 150)
$form.StartPosition = 'CenterScreen'

# Function to export theme files
function Export-ThemeFiles {
    Log-Message "Starting export operation..."
    
    # Export LayoutModification.xml using Export-StartLayout
    try {
        $layoutModificationPath = Join-Path -Path $outputFolder -ChildPath "LayoutModification.xml"
        Export-StartLayout -Path $layoutModificationPath
        Log-Message "LayoutModification.xml exported successfully to $layoutModificationPath"
    } catch {
        Log-Message "Failed to export LayoutModification.xml: $_"
    }
    
    # Export current .msstyles file
    try {
        $msstylesPath = Join-Path -Path $outputFolder -ChildPath "CurrentTheme.msstyles"
        $currentMsstyles = "$env:SYSTEMROOT\Resources\Themes\aero\aero.msstyles"
        Copy-Item -Path $currentMsstyles -Destination $msstylesPath -Force
        Log-Message "Current .msstyles exported successfully to $msstylesPath"
    } catch {
        Log-Message "Failed to export current .msstyles: $_"
    }
    
    # Export current .deskthemepack file
    try {
        $deskThemePackPath = Join-Path -Path $outputFolder -ChildPath "CurrentTheme.deskthemepack"
        $currentDeskThemePack = "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper"
        Copy-Item -Path $currentDeskThemePack -Destination $deskThemePackPath -Force
        Log-Message "Current .deskthemepack exported successfully to $deskThemePackPath"
    } catch {
        Log-Message "Failed to export current .deskthemepack: $_"
    }

    # Display the result in a message box
    $filesExported = "LayoutModification.xml, CurrentTheme.msstyles, CurrentTheme.deskthemepack"
    [System.Windows.Forms.MessageBox]::Show(("The following files have been exported to {0}:`n{1}" -f $outputFolder, $filesExported), "Export Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    Log-Message "Export operation completed for all theme customization files."
}

# Button for exporting files
$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Location = New-Object System.Drawing.Point(180, 50)
$exportButton.Size = New-Object System.Drawing.Size(140, 40)
$exportButton.Text = 'Export Files'
$exportButton.Add_Click({
    Export-ThemeFiles
})
$form.Controls.Add($exportButton)

# Show the form
$form.ShowDialog() | Out-Null

# End of script
