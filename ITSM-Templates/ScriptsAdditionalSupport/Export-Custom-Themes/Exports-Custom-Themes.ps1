# PowerShell Script to EXPORTS THE CUSTOM THEMES FILES
# Author: Luiz Hamilton Silva - @brazilianscriptguy
# Update: March, 29, 2024

# Define output folder
$outputFolder = "C:\ITSM-Logs\THEMES-Export"

# Ensure output folder exists
if (-not (Test-Path $outputFolder)) {
    New-Item -Path $outputFolder -ItemType Directory | Out-Null
}

# Export current .deskthemepack file
$deskThemePackPath = "$outputFolder\CurrentTheme.deskthemepack"
Get-Item -Path "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper" | Copy-Item -Destination $deskThemePackPath -Force

# Export current .msstyles file
$msstylesPath = "$outputFolder\CurrentTheme.msstyles"
Get-Item -Path "$env:SYSTEMROOT\Resources\Themes\aero\aero.msstyles" | Copy-Item -Destination $msstylesPath -Force

# Export current LayoutModification.xml file if exists
$layoutModificationXmlPath = "$outputFolder\LayoutModification.xml"
$layoutModificationXmlFiles = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Windows\Shell\*.xml" -ErrorAction SilentlyContinue
if ($layoutModificationXmlFiles) {
    $latestLayoutModificationXml = $layoutModificationXmlFiles | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
    Copy-Item -Path $latestLayoutModificationXml.FullName -Destination $layoutModificationXmlPath -Force
}

# Export current .theme file if exists
$customThemePath = "$env:LOCALAPPDATA\Microsoft\Windows\Themes\Custom.theme"
if (Test-Path $customThemePath) {
    $themeFilePath = "$outputFolder\CurrentTheme.theme"
    Copy-Item -Path $customThemePath -Destination $themeFilePath -Force
}

Write-Host "Exported current theme files to $outputFolder."

#End of script