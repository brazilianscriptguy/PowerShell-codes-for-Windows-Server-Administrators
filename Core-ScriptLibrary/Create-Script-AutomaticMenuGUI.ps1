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
    Last Updated: October 22, 2024
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
    # Get all subdirectories in the current directory (customize path if needed)
    $directories = Get-ChildItem -Path $scriptDirectory -Directory

    # Create a dictionary to hold scripts for each directory
    $scriptsByCategory = @{}

    foreach ($dir in $directories) {
        Write-Host "Checking directory: $($dir.FullName)" -ForegroundColor Yellow
        
        # Get all .ps1 files in the current subdirectory
        $scriptFiles = Get-ChildItem -Path $scriptDirectory -Recurse -Filter "*.ps1" -File
        
        if ($scriptFiles.Count -gt 0) {
            # Use the directory name as the category
            $category = $dir.Name

            # Initialize an array for scripts in this category
            $scriptsByCategory[$category] = @{}

            # Add each script to the dictionary using the script name as the key
            foreach ($file in $scriptFiles) {
                $scriptsByCategory[$category][$file.Name] = $file.FullName
                Write-Host "Found script: $($file.FullName)" -ForegroundColor Green
            }
        } else {
            Write-Host "No scripts found in directory: $($dir.FullName)" -ForegroundColor Red
        }
    }

    return $scriptsByCategory
}

# Generate dictionaries for each section dynamically
$scriptsByCategory = Get-ScriptDictionaries

# Check if any scripts were found
if ($scriptsByCategory.Count -eq 0) {
    Write-Host "No scripts found in any subdirectory." -ForegroundColor Yellow
}

# Function to create and show the GUI
function Create-GUI {
    # Initialize form components
    $form = [System.Windows.Forms.Form]::new()
    $form.Text = 'PowerShell Script Execution Menu'
    $form.Size = [System.Drawing.Size]::new(600, 600)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = [System.Drawing.Color]::WhiteSmoke

    # Header label
    $headerLabel = [System.Windows.Forms.Label]::new()
    $headerLabel.Text = "Select Scripts to Execute"
    $headerLabel.Size = [System.Drawing.Size]::new(550, 30)
    $headerLabel.Location = [System.Drawing.Point]::new(25, 20)
    $headerLabel.Font = [System.Drawing.Font]::new("Arial", 14, [System.Drawing.FontStyle]::Bold)
    $headerLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $form.Controls.Add($headerLabel)

    # Define initial position for group boxes
    $yPosition = 60

    # Function to create a group box and a checked list box for each script category
    function Create-CategoryUI {
        param (
            [string]$CategoryName,
            [System.Collections.IDictionary]$Scripts,
            [ref]$yPos
        )

        Write-Host "Creating UI for category: $CategoryName" -ForegroundColor Blue

        $groupBox = [System.Windows.Forms.GroupBox]::new()
        $groupBox.Text = "$CategoryName"
        $groupBox.Size = [System.Drawing.Size]::new(550, 200)
        $groupBox.Location = [System.Drawing.Point]::new(25, $yPos.Value)
        $groupBox.Font = [System.Drawing.Font]::new("Arial", 10, [System.Drawing.FontStyle]::Bold)
        $form.Controls.Add($groupBox)

        $listBox = [System.Windows.Forms.CheckedListBox]::new()
        $listBox.Size = [System.Drawing.Size]::new(530, 160)
        $listBox.Location = [System.Drawing.Point]::new(10, 20)
        $listBox.Font = [System.Drawing.Font]::new("Arial", 10)

        # Populate the checked list box with scripts in alphabetical order
        if ($Scripts.Count -gt 0) {
            foreach ($entry in $Scripts.GetEnumerator() | Sort-Object -Property Key) {
                $listBox.Items.Add($entry.Key)
                Write-Host "Adding script to list: $($entry.Key)" -ForegroundColor Cyan
            }
        } else {
            Write-Host "No scripts found in category: $CategoryName" -ForegroundColor Red
        }

        $groupBox.Controls.Add($listBox)

        # Adjust the y position for the next group box
        $yPos.Value += 210

        return $listBox
    }

    # Create UI for each script category dynamically
    $listBoxes = @{}
    foreach ($category in $scriptsByCategory.Keys) {
        $listBoxes[$category] = Create-CategoryUI -CategoryName $category -Scripts $scriptsByCategory[$category] -yPos ([ref]$yPosition)
    }

    # Status label
    $statusLabel = [System.Windows.Forms.Label]::new()
    $statusLabel.Text = "Status: Ready"
    $statusLabel.Location = [System.Drawing.Point]::new(25, $yPosition)
    $statusLabel.Size = [System.Drawing.Size]::new(550, 20)
    $statusLabel.Font = [System.Drawing.Font]::new("Arial", 9)
    $form.Controls.Add($statusLabel)

    # Create an execute button
    $executeButton = [System.Windows.Forms.Button]::new()
    $executeButton.Text = 'Execute'
    $executeButton.Size = [System.Drawing.Size]::new(150, 40)
    $executeButton.Location = [System.Drawing.Point]::new(120, $yPosition + 30)
    $executeButton.Font = [System.Drawing.Font]::new("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $executeButton.BackColor = [System.Drawing.Color]::LightSkyBlue
    $executeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

    # Add the execute button click event
    $executeButton.Add_Click({
        $anySelected = $false

        # Execute scripts for each category
        foreach ($category in $scriptsByCategory.Keys) {
            $listBox = $listBoxes[$category]
            $selectedScripts = $listBox.CheckedItems

            if ($selectedScripts.Count -gt 0) {
                $anySelected = $true
                [System.Windows.Forms.MessageBox]::Show("Executing selected scripts from $category...", "Information")

                foreach ($option in $selectedScripts) {
                    try {
                        $scriptFile = $scriptsByCategory[$category][$option]
                        if ($null -ne $scriptFile -and (Test-Path $scriptFile)) {
                            # Debug output to verify the script path
                            Write-Host "Executing script: $scriptFile" -ForegroundColor Green
                            # Execute the selected script with full path
                            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptFile`"" -NoNewWindow
                        } else {
                            [System.Windows.Forms.MessageBox]::Show("Script not found or invalid path: $($scriptFile)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                        }
                    } catch {
                        [System.Windows.Forms.MessageBox]::Show("An error occurred while executing $($scriptFile): $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
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

    # Create an exit button
    $exitButton = [System.Windows.Forms.Button]::new()
    $exitButton.Text = 'Exit'
    $exitButton.Size = [System.Drawing.Size]::new(150, 40)
    $exitButton.Location = [System.Drawing.Point]::new(300, $yPosition + 30)
    $exitButton.Font = [System.Drawing.Font]::new("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $exitButton.BackColor = [System.Drawing.Color]::Salmon
    $exitButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

    # Add the exit button click event
    $exitButton.Add_Click({
        $form.Close()
    })
    $form.Controls.Add($exitButton)

    # Show the form
    [void] $form.ShowDialog()
}

# Call the function to create the GUI
Create-GUI

# End of script
