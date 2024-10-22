<#
.SYNOPSIS
    PowerShell Script for DHCP Scope Transfer with GUI.
    
.DESCRIPTION
    This script provides functionality to export and import DHCP scopes 
    between servers within a specified domain, with error handling and logging 
    to track operations.

.AUTHOR
    Luiz Hamilton Silva - @brazilianscriptguy

.VERSION
    Last Updated: October 22, 2024
#>

param(
    [switch]$ShowConsole = $false
)

# Hide the PowerShell console window for a cleaner UI unless requested to show the console
if (-not $ShowConsole) {
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
}

# Load Windows Forms Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Enhanced logging function with error handling and validation
function Log-Message {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "ERROR", "WARNING", "DEBUG", "CRITICAL")]
        [string]$MessageType = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$MessageType] $Message"

    try {
        # Ensure the log path exists, create if necessary
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory -ErrorAction Stop
        }
        # Attempt to write to the log file
        Add-Content -Path $logPath -Value $logEntry -ErrorAction Stop
    } catch {
        # Fallback: Log to console if writing to the log file fails
        Write-Error "Failed to write to log: $_"
        Write-Output $logEntry
    }
}

# Unified error handling function refactored as a reusable method
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)][string]$ErrorMessage
    )
    Log-Message -Message "ERROR: $ErrorMessage" -MessageType "ERROR"
    [System.Windows.Forms.MessageBox]::Show($ErrorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Function to initialize script name and file paths
function Initialize-ScriptPaths {
    param (
        [string]$defaultLogDir = 'C:\Logs-TEMP'
    )

    # Determine script name and set up file paths dynamically
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Path)
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

    # Set log path allowing dynamic configuration or fallback to defaults
    $logDir = if ($env:LOG_PATH -and $env:LOG_PATH -ne "") { $env:LOG_PATH } else { $defaultLogDir }
    $logFileName = "${scriptName}_${timestamp}.log"
    $logPath = Join-Path $logDir $logFileName

    # Log the name of the log file created
    Log-Message -Message "Log file created: $logFileName" -MessageType "INFO"

    return @{
        LogDir = $logDir
        LogPath = $logPath
        ScriptName = $scriptName
    }
}

# Function to retrieve forest domains
function Get-ForestDomains {
    try {
        $forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
        return $forest.Domains | Select-Object -ExpandProperty Name
    } catch {
        Handle-Error "Failed to retrieve forest domains. Error: $_"
        return @()
    }
}

# Function to retrieve DHCP server from the domain
function Get-DHCPServerFromDomain {
    param (
        [string]$domain
    )
    try {
        $dhcpServers = Get-DhcpServerInDC
        if ($dhcpServers -and $dhcpServers.Count -gt 0) {
            foreach ($server in $dhcpServers) {
                if ($server.DNSName -like "*$domain*") {
                    return $server.DNSName  # Return the first matching DHCP server for the domain
                }
            }
            Handle-Error "No authorized DHCP server found for the domain '${domain}'."
            return $null
        } else {
            Handle-Error "No authorized DHCP servers found in Active Directory."
            return $null
        }
    } catch {
        Handle-Error "Error retrieving DHCP server for domain '${domain}': $_"
        return $null
    }
}

# Function to execute the export of DHCP scopes
function Export-DhcpScope {
    param (
        [string]$Server,
        [string]$ScopeId,
        [string]$ExportFilePath,
        [bool]$ExcludeScope,
        [bool]$InactivateScope
    )

    try {
        # Log the parameters being used
        Log-Message -Message "Starting export of Scope ID '$ScopeId' from Server '$Server' to File '$ExportFilePath'. ExcludeScope: $ExcludeScope, InactivateScope: $InactivateScope" -MessageType "INFO"

        # Validate the server and scope ID
        if (-not $Server) {
            Handle-Error "Server name is required for export."
            return $false
        }
        if (-not $ScopeId) {
            Handle-Error "Scope ID is required for export."
            return $false
        }

        # Validate the export file path
        if (-not (Test-Path (Split-Path -Path $ExportFilePath -Parent))) {
            try {
                # Create export directory if it doesn't exist
                New-Item -Path (Split-Path -Path $ExportFilePath -Parent) -ItemType Directory -Force | Out-Null
            } catch {
                Handle-Error "Failed to create export directory: $_"
                return $false
            }
        }

        # Log the start of the Export-DhcpServer command
        Log-Message -Message "Executing Export-DhcpServer for Scope '$ScopeId' on Server '$Server'." -MessageType "INFO"

        # Actual Export-DhcpServer cmdlet (synchronous)
        try {
            Export-DhcpServer -ComputerName $Server -File $ExportFilePath -ScopeId $ScopeId -Leases -Force -ErrorAction Stop
            Log-Message -Message "Export completed for Scope '$ScopeId' on Server '$Server'" -MessageType "INFO"
        } catch {
            $errorMsg = $_.Exception.Message
            Handle-Error "Failed to execute Export-DhcpServer for Scope '$ScopeId' on Server '$Server'. Error: $errorMsg"
            return $false
        }

        # Handle ExcludeScope option if needed
        if ($ExcludeScope) {
            Log-Message -Message "Excluded Scope '$ScopeId' as per user selection." -MessageType "INFO"
        }

        # Handle InactivateScope option
        if ($InactivateScope) {
            Log-Message -Message "Inactivating Scope '$ScopeId' as per user selection." -MessageType "INFO"
            try {
                Set-DhcpServerv4Scope -ComputerName $Server -ScopeId $ScopeId -State Inactive -ErrorAction Stop
                Log-Message -Message "Scope '$ScopeId' inactivated on Server '$Server'." -MessageType "INFO"
            } catch {
                Handle-Error "Failed to inactivate DHCP scope '$ScopeId' on server '$Server'. Error: $_"
                return $false
            }
        }

        return $true
    } catch {
        Handle-Error "An unexpected error occurred during the export of DHCP scope '$ScopeId' from server '$Server'. Error: $_"
        return $false
    }
}

# Function to import DHCP scope from file (target server and domain included)
function Import-DhcpScope {
    param (
        [string]$Server,
        [string]$Domain,
        [string]$ImportFilePath,
        [string]$ScopeId
    )

    try {
        Log-Message -Message "Starting import of DHCP scope '$ScopeId' from file '$ImportFilePath' to server '$Server' in domain '$Domain'." -MessageType "INFO"

        # Validate server, domain, and import file
        if (-not $Server) {
            Handle-Error "Target server is required for import."
            return $false
        }
        if (-not $Domain) {
            Handle-Error "Target domain is required for import."
            return $false
        }
        if (-not (Test-Path $ImportFilePath)) {
            Handle-Error "Import file does not exist: $ImportFilePath"
            return $false
        }

        # Check if the scope exists before import
        $existingScope = Get-DhcpServerv4Scope -ComputerName $Server | Where-Object { $_.ScopeId -eq $ScopeId }
        if ($existingScope) {
            Handle-Error "AVISO: O escopo $ScopeId existe no servidor $Server. Este escopo não será importado."
            return $false
        }

        # Execute import cmdlet
        try {
            Import-DhcpServer -ComputerName $Server -File $ImportFilePath -Leases -BackupPath "C:\Backup" -ScopeId $ScopeId -ErrorAction Stop
            Log-Message -Message "Import completed for Scope '$ScopeId' from file '$ImportFilePath' on Server '$Server'." -MessageType "INFO"
        } catch {
            $errorMsg = $_.Exception.Message
            Handle-Error "Failed to execute Import-DhcpServer for Scope '$ScopeId' on Server '$Server'. Error: $errorMsg"
            return $false
        }

        return $true
    } catch {
        Handle-Error "An unexpected error occurred during the import. Error: $_"
        return $false
    }
}

# Function to execute asynchronous jobs with progress handling
function Run-AsynchronousJob {
    param (
        [scriptblock]$JobScript,
        [string]$JobDescription,
        [ref]$Result
    )

    Log-Message "Starting background task: ${JobDescription}" -MessageType "INFO"

    $job = Start-Job -ScriptBlock $JobScript -Name $JobDescription

    Register-ObjectEvent -InputObject $job -EventName StateChanged -Action {
        param($sender, $e)

        if ($e.NewState -eq 'Completed') {
            $jobResult = Receive-Job -Job $sender -ErrorAction SilentlyContinue

            if ($sender.ChildJobs[0].JobStateInfo.State -eq 'Failed') {
                $errorMessage = $sender.ChildJobs[0].JobStateInfo.Reason.ToString()
                Handle-Error "${JobDescription} failed: ${errorMessage}"
                $Result.Value = $false
            } else {
                Log-Message "${JobDescription} completed successfully." -MessageType "INFO"
                $Result.Value = $true
            }

            # Clean up the job
            Remove-Job -Job $sender -Force
        }
    }
}

# GUI Creation Function
function Create-GUI {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'DHCP Scope Transfer Tool'
    $form.Size = New-Object System.Drawing.Size(650, 480)
    $form.StartPosition = 'CenterScreen'

    # Create Tab Control for Export and Import
    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Location = New-Object System.Drawing.Point(10, 10)
    $tabControl.Size = New-Object System.Drawing.Size(600, 400)
    $form.Controls.Add($tabControl)

    # Export Tab
    $exportTab = New-Object System.Windows.Forms.TabPage
    $exportTab.Text = 'Export DHCP Scope'
    $tabControl.Controls.Add($exportTab)

    # Import Tab
    $importTab = New-Object System.Windows.Forms.TabPage
    $importTab.Text = 'Import DHCP Scope'
    $tabControl.Controls.Add($importTab)

    # Elements on Export Tab
    $lblSourceDomain = New-Object System.Windows.Forms.Label
    $lblSourceDomain.Text = "Source Domain:"
    $lblSourceDomain.Location = New-Object System.Drawing.Point(10, 20)
    $lblSourceDomain.AutoSize = $true
    $exportTab.Controls.Add($lblSourceDomain)

    $comboBoxSourceDomain = New-Object System.Windows.Forms.ComboBox
    $comboBoxSourceDomain.Location = New-Object System.Drawing.Point(150, 20)
    $comboBoxSourceDomain.Size = New-Object System.Drawing.Size(200, 20)
    $comboBoxSourceDomain.DropDownStyle = 'DropDownList'
    $exportTab.Controls.Add($comboBoxSourceDomain)

    $lblSourceServer = New-Object System.Windows.Forms.Label
    $lblSourceServer.Text = "Source Server:"
    $lblSourceServer.Location = New-Object System.Drawing.Point(10, 100)
    $lblSourceServer.AutoSize = $true
    $exportTab.Controls.Add($lblSourceServer)

    $txtSourceServer = New-Object System.Windows.Forms.TextBox
    $txtSourceServer.Location = New-Object System.Drawing.Point(150, 100)
    $txtSourceServer.Size = New-Object System.Drawing.Size(200, 20)
    $exportTab.Controls.Add($txtSourceServer)

    $lblScopeId = New-Object System.Windows.Forms.Label
    $lblScopeId.Text = "Scope ID:"
    $lblScopeId.Location = New-Object System.Drawing.Point(10, 180)
    $lblScopeId.AutoSize = $true
    $exportTab.Controls.Add($lblScopeId)

    $comboBoxScopes = New-Object System.Windows.Forms.ComboBox
    $comboBoxScopes.Location = New-Object System.Drawing.Point(150, 180)
    $comboBoxScopes.Size = New-Object System.Drawing.Size(200, 20)
    $comboBoxScopes.DropDownStyle = 'DropDownList'
    $exportTab.Controls.Add($comboBoxScopes)

    $lblBackupPath = New-Object System.Windows.Forms.Label
    $lblBackupPath.Text = "Export File Path:"
    $lblBackupPath.Location = New-Object System.Drawing.Point(10, 220)
    $lblBackupPath.AutoSize = $true
    $exportTab.Controls.Add($lblBackupPath)

    $txtBackupPath = New-Object System.Windows.Forms.TextBox
    $txtBackupPath.Text = "C:\Logs-TEMP\DhcpScopeConfig.xml"
    $txtBackupPath.Location = New-Object System.Drawing.Point(150, 220)
    $txtBackupPath.Size = New-Object System.Drawing.Size(400, 20)
    $txtBackupPath.ReadOnly = $true
    $exportTab.Controls.Add($txtBackupPath)

    $chkExcludeScope = New-Object System.Windows.Forms.CheckBox
    $chkExcludeScope.Text = "Exclude Source Scope"
    $chkExcludeScope.Location = New-Object System.Drawing.Point(400, 20)
    $chkExcludeScope.AutoSize = $true
    $exportTab.Controls.Add($chkExcludeScope)

    $chkInactivateScope = New-Object System.Windows.Forms.CheckBox
    $chkInactivateScope.Text = "Inactivate Source Scope"
    $chkInactivateScope.Location = New-Object System.Drawing.Point(400, 60)
    $chkInactivateScope.AutoSize = $true
    $exportTab.Controls.Add($chkInactivateScope)

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 300)
    $progressBar.Size = New-Object System.Drawing.Size(550, 30)
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Step = 50
    $exportTab.Controls.Add($progressBar)

    $btnExport = New-Object System.Windows.Forms.Button
    $btnExport.Text = "Export Scope"
    $btnExport.Location = New-Object System.Drawing.Point(400, 100)
    $btnExport.Size = New-Object System.Drawing.Size(150, 30)
    $exportTab.Controls.Add($btnExport)

    # Import Tab Elements
    $lblImportDomain = New-Object System.Windows.Forms.Label
    $lblImportDomain.Text = "Target Domain:"
    $lblImportDomain.Location = New-Object System.Drawing.Point(10, 20)
    $lblImportDomain.AutoSize = $true
    $importTab.Controls.Add($lblImportDomain)

    $comboBoxTargetDomain = New-Object System.Windows.Forms.ComboBox
    $comboBoxTargetDomain.Location = New-Object System.Drawing.Point(150, 20)
    $comboBoxTargetDomain.Size = New-Object System.Drawing.Size(200, 20)
    $comboBoxTargetDomain.DropDownStyle = 'DropDownList'
    $importTab.Controls.Add($comboBoxTargetDomain)

    $lblImportServer = New-Object System.Windows.Forms.Label
    $lblImportServer.Text = "Target Server:"
    $lblImportServer.Location = New-Object System.Drawing.Point(10, 100)
    $lblImportServer.AutoSize = $true
    $importTab.Controls.Add($lblImportServer)

    $txtTargetServer = New-Object System.Windows.Forms.TextBox
    $txtTargetServer.Location = New-Object System.Drawing.Point(150, 100)
    $txtTargetServer.Size = New-Object System.Drawing.Size(200, 20)
    $importTab.Controls.Add($txtTargetServer)

    $lblImportFile = New-Object System.Windows.Forms.Label
    $lblImportFile.Text = "Import File Path:"
    $lblImportFile.Location = New-Object System.Drawing.Point(10, 60)
    $lblImportFile.AutoSize = $true
    $importTab.Controls.Add($lblImportFile)

    $txtImportFile = New-Object System.Windows.Forms.TextBox
    $txtImportFile.Text = "C:\Logs-TEMP\DhcpScopeConfig.xml"
    $txtImportFile.Location = New-Object System.Drawing.Point(150, 60)
    $txtImportFile.Size = New-Object System.Drawing.Size(400, 20)
    $importTab.Controls.Add($txtImportFile)

    $progressBarImport = New-Object System.Windows.Forms.ProgressBar
    $progressBarImport.Location = New-Object System.Drawing.Point(10, 300)
    $progressBarImport.Size = New-Object System.Drawing.Size(550, 30)
    $progressBarImport.Minimum = 0
    $progressBarImport.Maximum = 100
    $progressBarImport.Step = 50
    $importTab.Controls.Add($progressBarImport)

    $btnImport = New-Object System.Windows.Forms.Button
    $btnImport.Text = "Import Scope"
    $btnImport.Location = New-Object System.Drawing.Point(400, 100)
    $btnImport.Size = New-Object System.Drawing.Size(150, 30)
    $importTab.Controls.Add($btnImport)

    # Event Handlers for the Export button
    $btnExport.Add_Click({
        $sourceServer = $txtSourceServer.Text.Trim()
        $selectedScope = $comboBoxScopes.SelectedItem
        if ($selectedScope) {
            $scopeId = $selectedScope
        } else {
            $scopeId = ""
        }
        $exportFilePath = $txtBackupPath.Text
        $excludeScope = $chkExcludeScope.Checked
        $inactivateScope = $chkInactivateScope.Checked

        if ($sourceServer -and $scopeId) {
            $progressBar.Value = 0
            $progressBar.PerformStep()
            
            # Directly call Export-DhcpScope synchronously to capture errors
            $exportResult = Export-DhcpScope -Server $sourceServer -ScopeId $scopeId -ExportFilePath $exportFilePath -ExcludeScope $excludeScope -InactivateScope $inactivateScope

            $progressBar.Value = 100

            # Show message after the operation
            if ($exportResult) {
                [System.Windows.Forms.MessageBox]::Show("Export completed successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            } else {
                [System.Windows.Forms.MessageBox]::Show("Export failed!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } else {
            Handle-Error "Please select the Source Server and Scope ID."
        }
    })

    # Event Handlers for the Import button
    $btnImport.Add_Click({
        # Retrieve the values from the input fields and ComboBox
        $targetServer = $txtTargetServer.Text.Trim()
        $importFilePath = $txtImportFile.Text.Trim()
        $selectedTargetDomain = $comboBoxTargetDomain.SelectedItem
        $importScopeId = $comboBoxScopes.SelectedItem  # Assuming this is where the scope ID comes from

        # Debugging: Log retrieved values for troubleshooting
        Log-Message -Message "Target Server: $targetServer" -MessageType "DEBUG"
        Log-Message -Message "Import File Path: $importFilePath" -MessageType "DEBUG"
        Log-Message -Message "Import Scope ID: $importScopeId" -MessageType "DEBUG"
        Log-Message -Message "Selected Target Domain: $selectedTargetDomain" -MessageType "DEBUG"

        # Validate that all fields are correctly filled
        if (-not [string]::IsNullOrWhiteSpace($targetServer) -and 
            -not [string]::IsNullOrWhiteSpace($importFilePath) -and 
            -not [string]::IsNullOrWhiteSpace($importScopeId) -and 
            $selectedTargetDomain) {

            # Set progress bar to 0 before starting the import process
            $progressBarImport.Value = 0
            $progressBarImport.PerformStep()

            # Run the import function with filled parameters
            $importResult = Import-DhcpScope -Server $targetServer -Domain $selectedTargetDomain -ImportFilePath $importFilePath -ScopeId $importScopeId

            # Complete progress bar once the process is done
            $progressBarImport.Value = 100

            # Notify the user of success or failure
            if ($importResult) {
                [System.Windows.Forms.MessageBox]::Show("Import completed successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            } else {
                [System.Windows.Forms.MessageBox]::Show("Import failed!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } else {
            # Log the values and show an error if any required field is not filled
            Log-Message -Message "Failed validation: Target Server = $targetServer, Import File Path = $importFilePath, Scope ID = $importScopeId, Target Domain = $selectedTargetDomain" -MessageType "ERROR"
            Handle-Error "Please specify the Target Server, Import File Path, Scope ID, and Target Domain."
        }
    })

    # Populate domain comboboxes
    $domains = Get-ForestDomains
    foreach ($domain in $domains) {
        $comboBoxSourceDomain.Items.Add($domain) | Out-Null
        $comboBoxTargetDomain.Items.Add($domain) | Out-Null
    }

    # Event handler for selecting the Source Domain to get DHCP servers and scopes
    $comboBoxSourceDomain.Add_SelectedIndexChanged({
        $selectedSourceDomain = $comboBoxSourceDomain.SelectedItem
        if ($selectedSourceDomain) {
            $sourceServer = Get-DHCPServerFromDomain -domain $selectedSourceDomain
            if ($sourceServer) {
                $txtSourceServer.Text = $sourceServer
                $comboBoxScopes.Items.Clear()
                try {
                    $scopes = Get-DhcpServerv4Scope -ComputerName $sourceServer
                    foreach ($scope in $scopes) {
                        $comboBoxScopes.Items.Add($scope.ScopeId) | Out-Null
                    }
                    Log-Message -Message "Fetched DHCP scopes for server '$sourceServer'." -MessageType "INFO"
                } catch {
                    Handle-Error "Failed to retrieve scopes from server '$sourceServer'. Error: $_"
                }
            }
        }
    })

    # Event handler for selecting the Target Domain to get DHCP servers
    $comboBoxTargetDomain.Add_SelectedIndexChanged({
        $selectedTargetDomain = $comboBoxTargetDomain.SelectedItem
        if ($selectedTargetDomain) {
            $targetServer = Get-DHCPServerFromDomain -domain $selectedTargetDomain
            if ($targetServer) {
                $txtTargetServer.Text = $targetServer
                Log-Message -Message "Selected target server: '$targetServer'." -MessageType "INFO"
            }
        }
    })

    # Display the GUI
    $form.ShowDialog()
}

# Initialize Script Paths and Logging
$paths = Initialize-ScriptPaths
$global:logDir = $paths.LogDir
$global:logPath = $paths.LogPath

# Ensure the log directory and file exist
try {
    if (-not (Test-Path $global:logDir)) {
        New-Item -Path $global:logDir -ItemType Directory -Force | Out-Null
    }
    if (-not (Test-Path $global:logPath)) {
        New-Item -Path $global:logPath -ItemType File -Force | Out-Null
    }
} catch {
    Handle-Error "Failed to initialize logging."
    exit
}

# Import Necessary Modules with Error Handling
try {
    Import-Module DHCPServer -ErrorAction Stop
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Handle-Error "Failed to import necessary modules."
    exit
}

# Log that the script has started
Log-Message -Message "Script started" -MessageType "INFO"

# Execute the GUI creation function
Create-GUI

# End of script
