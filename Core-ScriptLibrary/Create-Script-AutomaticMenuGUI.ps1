<#
.SYNOPSIS
    PowerShell Script for Generating a Dynamic Script Execution Menu GUI.

.DESCRIPTION
    This script automatically generates a dynamic, categorized GUI interface for discovering 
    and executing PowerShell scripts stored in subdirectories. It is ideal for organizing 
    and managing large script collections through an intuitive user-friendly interface.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: December 2, 2024
#>

# Hide the PowerShell console window
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Window {
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    public static void Hide() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 0); // 0 = SW_HIDE
    }
    public static void Show() {
        var handle = GetConsoleWindow();
        ShowWindow(handle, 5); // 5 = SW_SHOW
    }
}
"@
[Window]::Hide()

# Import necessary assemblies for Windows Forms and Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Get the current script directory (can be customized as needed)
$scriptDirectory = (Get-Location).Path
Write-Host "Current Script Directory: $scriptDirectory" -ForegroundColor Cyan

# Function to generate a dictionary of script filenames and paths from all subdirectories
function Get-ScriptDictionaries {
    $scriptFiles = Get-ChildItem -Path $scriptDirectory -Recurse -Filter "*.ps1" -File
    $scriptsByCategory = @{}

    foreach ($file in $scriptFiles) {
        $folderName = (Split-Path -Path $file.DirectoryName -Leaf)

        if (-not $scriptsByCategory.ContainsKey($folderName)) {
            $scriptsByCategory[$folderName] = @{}
        }
        $scriptsByCategory[$folderName][$file.Name] = $file.FullName
        Write-Host "Found script: $($file.FullName)" -ForegroundColor Green
    }

    return $scriptsByCategory
}

$scriptsByCategory = Get-ScriptDictionaries
if ($scriptsByCategory.Count -eq 0) {
    Write-Host "No scripts found in any subdirectory." -ForegroundColor Yellow
}

# Function to create and show the GUI
function Create-GUI {
    $form = [System.Windows.Forms.Form]::new()
    $form.Text = 'PowerShell Script Execution Menu'
    $form.Size = [System.Drawing.Size]::new(850, 600)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = [System.Drawing.Color]::WhiteSmoke

    $headerLabel = [System.Windows.Forms.Label]::new()
    $headerLabel.Text = "Select Scripts to Execute"
    $headerLabel.Size = [System.Drawing.Size]::new(800, 30)
    $headerLabel.Location = [System.Drawing.Point]::new(25, 20)
    $headerLabel.Font = [System.Drawing.Font]::new("Arial", 14, [System.Drawing.FontStyle]::Bold)
    $headerLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $form.Controls.Add($headerLabel)

    $xPositionLeft = 25
    $xPositionRight = 430
    $yPositionLeft = 60
    $yPositionRight = 60
    $toggleColumn = $true

    function Create-CategoryUI {
        param (
            [string]$CategoryName,
            [System.Collections.IDictionary]$Scripts,
            [ref]$xPosLeft,
            [ref]$yPosLeft,
            [ref]$xPosRight,
            [ref]$yPosRight,
            [ref]$toggle
        )

        $groupBox = [System.Windows.Forms.GroupBox]::new()
        $groupBox.Text = "$CategoryName"
        $groupBox.Size = [System.Drawing.Size]::new(380, 200)

        if ($toggle.Value) {
            $groupBox.Location = [System.Drawing.Point]::new($xPosLeft.Value, $yPosLeft.Value)
            $yPosLeft.Value += 210
        } else {
            $groupBox.Location = [System.Drawing.Point]::new($xPosRight.Value, $yPosRight.Value)
            $yPosRight.Value += 210
        }
        $toggle.Value = -not $toggle.Value

        $groupBox.Font = [System.Drawing.Font]::new("Arial", 10, [System.Drawing.FontStyle]::Bold)
        $form.Controls.Add($groupBox)

        $listBox = [System.Windows.Forms.CheckedListBox]::new()
        $listBox.Size = [System.Drawing.Size]::new(360, 160)
        $listBox.Location = [System.Drawing.Point]::new(10, 20)
        $listBox.Font = [System.Drawing.Font]::new("Arial", 10)

        foreach ($entry in $Scripts.GetEnumerator() | Sort-Object -Property Key) {
            $listBox.Items.Add($entry.Key)
        }

        $groupBox.Controls.Add($listBox)
        return $listBox
    }

    $listBoxes = @{}
    foreach ($category in $scriptsByCategory.Keys) {
        $listBoxes[$category] = Create-CategoryUI -CategoryName $category -Scripts $scriptsByCategory[$category] `
            -xPosLeft ([ref]$xPositionLeft) -yPosLeft ([ref]$yPositionLeft) `
            -xPosRight ([ref]$xPositionRight) -yPosRight ([ref]$yPositionRight) -toggle ([ref]$toggleColumn)
    }

    $statusLabel = [System.Windows.Forms.Label]::new()
    $statusLabel.Text = "Status: Ready"
    $statusLabel.Location = [System.Drawing.Point]::new(25, 520)
    $statusLabel.Size = [System.Drawing.Size]::new(800, 20)
    $statusLabel.Font = [System.Drawing.Font]::new("Arial", 9)
    $form.Controls.Add($statusLabel)

    $executeButton = [System.Windows.Forms.Button]::new()
    $executeButton.Text = 'Execute'
    $executeButton.Size = [System.Drawing.Size]::new(150, 40)
    $executeButton.Location = [System.Drawing.Point]::new(250, 550)
    $executeButton.Font = [System.Drawing.Font]::new("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $executeButton.BackColor = [System.Drawing.Color]::LightSkyBlue
    $executeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

    $executeButton.Add_Click({
        $anySelected = $false
        foreach ($category in $scriptsByCategory.Keys) {
            $listBox = $listBoxes[$category]
            $selectedScripts = $listBox.CheckedItems

            if ($selectedScripts.Count -gt 0) {
                $anySelected = $true
                foreach ($option in $selectedScripts) {
                    try {
                        $scriptFile = $scriptsByCategory[$category][$option]
                        if ($null -ne $scriptFile -and (Test-Path $scriptFile)) {
                            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptFile`"" -NoNewWindow
                        } else {
                            [System.Windows.Forms.MessageBox]::Show("Script not found: $scriptFile", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                        }
                    } catch {
                        [System.Windows.Forms.MessageBox]::Show("Error executing script: $scriptFile`r`nError Details: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                    }
                }
            }
        }

        if (-not $anySelected) {
            [System.Windows.Forms.MessageBox]::Show("Please select at least one script to execute.", "Warning", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
        $statusLabel.Text = "Status: Completed"
    })
    $form.Controls.Add($executeButton)

    $exitButton = [System.Windows.Forms.Button]::new()
    $exitButton.Text = 'Exit'
    $exitButton.Size = [System.Drawing.Size]::new(150, 40)
    $exitButton.Location = [System.Drawing.Point]::new(450, 550)
    $exitButton.Font = [System.Drawing.Font]::new("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $exitButton.BackColor = [System.Drawing.Color]::Salmon
    $exitButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

    $exitButton.Add_Click({
        $form.Close()
    })
    $form.Controls.Add($exitButton)

    [void] $form.ShowDialog()
}

Create-GUI
