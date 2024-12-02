<#
.SYNOPSIS
    PowerShell GUI for Executing Scripts Organized by Tabs.

.DESCRIPTION
    This script provides a GUI interface to browse, search, and execute PowerShell scripts
    from a hierarchy of folders. Each folder is represented as a tab, and its scripts are listed
    in a scrollable list. Users can search for specific scripts and execute them.

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

# Get the current script directory
$scriptDirectory = (Get-Location).Path
Write-Host "Current Script Directory: $scriptDirectory" -ForegroundColor Cyan

# Function to generate a dictionary of script filenames and paths from all subdirectories
function Get-ScriptDictionaries {
    $directories = Get-ChildItem -Path $scriptDirectory -Directory -Recurse
    $scriptsByCategory = @{}

    foreach ($dir in $directories) {
        Write-Host "Checking directory: $($dir.FullName)" -ForegroundColor Yellow
        
        $scriptFiles = Get-ChildItem -Path $dir.FullName -Filter "*.ps1" -File
        if ($scriptFiles.Count -gt 0) {
            $category = $dir.Name
            $scriptsByCategory[$category] = @{}

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
    $form = [System.Windows.Forms.Form]::new()
    $form.Text = 'SysAdmin Tool Set Interface'
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
    $form.BackColor = [System.Drawing.Color]::WhiteSmoke

    $headerLabel = [System.Windows.Forms.Label]::new()
    $headerLabel.Text = "SysAdmin Tool Set Menu"
    $headerLabel.Size = [System.Drawing.Size]::new($form.Width - 20, 30)
    $headerLabel.Location = [System.Drawing.Point]::new(10, 10)
    $headerLabel.Font = [System.Drawing.Font]::new("Arial", 16, [System.Drawing.FontStyle]::Bold)
    $headerLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $headerLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $form.Controls.Add($headerLabel)

    $tabControl = [System.Windows.Forms.TabControl]::new()
    $tabControl.Size = [System.Drawing.Size]::new($form.Width - 40, $form.Height - 150)
    $tabControl.Location = [System.Drawing.Point]::new(10, 50)
    $tabControl.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
    $form.Controls.Add($tabControl)

    foreach ($category in $scriptsByCategory.Keys) {
        $tabPage = [System.Windows.Forms.TabPage]::new()
        $tabPage.Text = $category
        $tabPage.AutoScroll = $true

        $searchBox = [System.Windows.Forms.TextBox]::new()
        $searchBox.Size = [System.Drawing.Size]::new($tabPage.Width - 20, 25)
        $searchBox.Location = [System.Drawing.Point]::new(10, 10)
        $searchBox.Font = [System.Drawing.Font]::new("Arial", 10)
        $searchBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
        $tabPage.Controls.Add($searchBox)

        $listBox = [System.Windows.Forms.CheckedListBox]::new()
        $listBox.Size = [System.Drawing.Size]::new($tabPage.Width - 20, $tabPage.Height - 70)
        $listBox.Location = [System.Drawing.Point]::new(10, 40)
        $listBox.Font = [System.Drawing.Font]::new("Arial", 9)
        $listBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
        $listBox.ScrollAlwaysVisible = $true

        foreach ($entry in $scriptsByCategory[$category].Keys) {
            $listBox.Items.Add($entry)
        }
        $tabPage.Controls.Add($listBox)

        $searchBox.Add_TextChanged({
            $searchText = $searchBox.Text.ToLower()
            $listBox.Items.Clear()
            foreach ($entry in $scriptsByCategory[$category].Keys) {
                if ($entry.ToLower() -like "*$searchText*") {
                    $listBox.Items.Add($entry)
                }
            }
        })

        $tabControl.TabPages.Add($tabPage)
    }

    $executeButton = [System.Windows.Forms.Button]::new()
    $executeButton.Text = 'Execute'
    $executeButton.Size = [System.Drawing.Size]::new(150, 40)
    $executeButton.Location = [System.Drawing.Point]::new($form.ClientSize.Width - 170, $form.ClientSize.Height - 60)
    $executeButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $executeButton.BackColor = [System.Drawing.Color]::LightSkyBlue
    $executeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

    $executeButton.Add_Click({
        $anyExecuted = $false

        foreach ($tabPage in $tabControl.TabPages) {
            foreach ($control in $tabPage.Controls) {
                if ($control -is [System.Windows.Forms.CheckedListBox]) {
                    foreach ($script in $control.CheckedItems) {
                        $scriptPath = $scriptsByCategory[$tabPage.Text][$script]
                        if ((Test-Path $scriptPath)) {
                            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptPath`"" -NoNewWindow
                            Write-Host "Executed: $scriptPath"
                            $anyExecuted = $true
                        } else {
                            [System.Windows.Forms.MessageBox]::Show("Script not found: $scriptPath", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                        }
                    }
                }
            }
        }

        if (-not $anyExecuted) {
            [System.Windows.Forms.MessageBox]::Show("No scripts selected for execution.", "Info", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
    })
    $form.Controls.Add($executeButton)

    [void] $form.ShowDialog()
}

# Call the function to create the GUI
Create-GUI

# End of script
