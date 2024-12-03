<#
.SYNOPSIS
    PowerShell GUI for Executing Scripts Organized by Tabs with Real-Time Search.

.DESCRIPTION
    This script provides a GUI interface to browse, search, and execute PowerShell scripts
    organized by tabs representing different script categories (folders). It ensures that the 
    search function works consistently in real time for each tab.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Updated: December 2, 2024
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
        $scriptFiles = Get-ChildItem -Path $dir.FullName -Filter "*.ps1" -File
        if ($scriptFiles.Count -gt 0) {
            $category = $dir.Name
            $scriptsByCategory[$category] = $scriptFiles | Sort-Object -Property Name
        }
    }
    return $scriptsByCategory
}

# Generate dictionaries for each section dynamically
$scriptsByCategory = Get-ScriptDictionaries

# Function to update listbox items based on the search text
function Update-ListBox {
    param (
        [System.Windows.Forms.TextBox]$searchBox,
        [System.Windows.Forms.CheckedListBox]$listBox,
        [System.Collections.ObjectModel.Collection[System.IO.FileInfo]]$originalList
    )

    $searchText = $searchBox.Text.Trim().ToLower()
    $listBox.BeginUpdate()
    $listBox.Items.Clear()

    # Repopulate the list box based on the search text
    foreach ($file in $originalList) {
        if ($file.Name.ToLower().Contains($searchText)) {
            $listBox.Items.Add($file.Name)
        }
    }

    # Add a placeholder if no matches are found
    if ($listBox.Items.Count -eq 0) {
        $listBox.Items.Add("<No matching scripts found>")
    }

    $listBox.EndUpdate()
}

# Function to create and show the GUI
function Create-GUI {
    # Initialize the Form
    $form = [System.Windows.Forms.Form]::new()
    $form.Text = 'SysAdmin Tool Set Interface'
    $form.Size = [System.Drawing.Size]::new(1200, 900)
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $form.BackColor = [System.Drawing.Color]::WhiteSmoke

    # Add TabControl for organizing script categories
    $tabControl = [System.Windows.Forms.TabControl]::new()
    $tabControl.Size = [System.Drawing.Size]::new($form.Width - 40, $form.Height - 150)
    $tabControl.Location = [System.Drawing.Point]::new(10, 10)
    $tabControl.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
    $form.Controls.Add($tabControl)

    # Store references to controls in a dictionary for easier access
    $tabControls = @{}

    # Add Tabs for each category
    foreach ($category in $scriptsByCategory.Keys) {
        # Create a new TabPage for the category
        $tabPage = [System.Windows.Forms.TabPage]::new()
        $tabPage.Text = $category

        # Add Search Box
        $searchBox = [System.Windows.Forms.TextBox]::new()
        $searchBox.Size = [System.Drawing.Size]::new($tabPage.Width - 20, 25)
        $searchBox.Location = [System.Drawing.Point]::new(10, 10)
        $searchBox.Font = [System.Drawing.Font]::new("Arial", 10)
        $searchBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
        $tabPage.Controls.Add($searchBox)

        # Add ListBox to display scripts with scrollbar support
        $listBox = [System.Windows.Forms.CheckedListBox]::new()
        $listBox.Size = [System.Drawing.Size]::new($tabPage.Width - 20, $tabPage.Height - 80)
        $listBox.Location = [System.Drawing.Point]::new(10, 40)
        $listBox.Font = [System.Drawing.Font]::new("Arial", 9)
        $listBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
        $listBox.ScrollAlwaysVisible = $true
        $tabPage.Controls.Add($listBox)

        # Populate listbox initially
        Update-ListBox -searchBox $searchBox -listBox $listBox -originalList $scriptsByCategory[$category]

        # Add Search Functionality for real-time updates
        $searchBox.Add_TextChanged({
            Update-ListBox -searchBox $searchBox -listBox $listBox -originalList $scriptsByCategory[$category]
        })

        # Store controls in the dictionary
        $tabControls[$category] = @{
            SearchBox = $searchBox
            ListBox = $listBox
        }

        # Add the TabPage to the TabControl
        $tabControl.TabPages.Add($tabPage)
    }

    # Add TabControl SelectedIndexChanged event to handle updating the active tab
    $tabControl.Add_SelectedIndexChanged({
        $selectedTab = $tabControl.SelectedTab
        if ($selectedTab -ne $null) {
            $category = $selectedTab.Text
            if ($tabControls.ContainsKey($category)) {
                $controls = $tabControls[$category]
                Update-ListBox -searchBox $controls.SearchBox -listBox $controls.ListBox -originalList $scriptsByCategory[$category]
            }
        }
    })

    # Add Execute Button
    $executeButton = [System.Windows.Forms.Button]::new()
    $executeButton.Text = 'Execute'
    $executeButton.Size = [System.Drawing.Size]::new(150, 40)
    $executeButton.Location = [System.Drawing.Point]::new(($form.ClientSize.Width - 150) / 2, $form.ClientSize.Height - 80)
    $executeButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
    $executeButton.BackColor = [System.Drawing.Color]::LightSkyBlue
    $executeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $executeButton.Add_Click({
        $anyExecuted = $false

        foreach ($tabPage in $tabControl.TabPages) {
            $listBox = $tabPage.Controls | Where-Object { $_ -is [System.Windows.Forms.CheckedListBox] }
            if ($listBox) {
                foreach ($script in $listBox.CheckedItems) {
                    if ($script -eq "<No matching scripts found>") { continue }

                    # Find the corresponding script path
                    $scriptPath = $scriptsByCategory[$tabPage.Text] | Where-Object { $_.Name -eq $script } | Select-Object -ExpandProperty FullName
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

        if (-not $anyExecuted) {
            [System.Windows.Forms.MessageBox]::Show("No scripts selected for execution.", "Info", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
    })
    $form.Controls.Add($executeButton)

    # Show the Form
    [void] $form.ShowDialog()
}

# Call the function to create the GUI
Create-GUI

# End of script
