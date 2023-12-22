# PowerShell script to move the Event Logs default paths
# by Luiz Hamilton Silva - luizhamilton.lhr@gmail.com
# on 10/05/2023

   # Set error handling to silently continue
    $ErrorActionPreference = "SilentlyContinue"

    # Define the original folder for event logs and the target folder where they will be moved
    $originalFolder = "$env:SystemRoot\system32\winevt\Logs"
    $targetRootFolder = "L:\"

    # Get all log names from the system
    $logNames = Get-WinEvent -ListLog * | Select-Object -ExpandProperty LogName

    # Initialize progress bar variables
    $totalLogs = $logNames.Count
    $currentLogNumber = 0

    # Loop through each log name
    foreach ($logName in $logNames) {
        # Increment the current log number
        $currentLogNumber++

        # Display progress bar
        Write-Progress -Activity "Moving Event Logs" -Status "Handling $($logName)" -PercentComplete (($currentLogNumber / $totalLogs) * 100)

        # Replace forward slashes with hyphens in log name for compatibility with folder naming
        $escapedLogName = $logName.Replace('/', '-')
        # Create a target folder path for the current log
        $targetFolder = Join-Path $targetRootFolder $escapedLogName

        # Create the target folder if it doesn't already exist
        if (-not (Test-Path $targetFolder)) {
            New-Item -Path $targetFolder -ItemType Directory
        }

        # Get the ACL of the original folder and set it to the target folder
        $originalAcl = Get-Acl -Path $originalFolder -Audit -AllCentralAccessPolicies
        Set-Acl -Path $targetFolder -AclObject $originalAcl -ClearCentralAccessPolicy
        # Get the ACL of the target folder and set its owner to the SYSTEM account
        $targetAcl = Get-Acl -Path $targetFolder -Audit -AllCentralAccessPolicies
        $targetAcl.SetOwner([System.Security.Principal.NTAccount]::new("SYSTEM"))

        # Create a new registry entry for AutoBackupLogFiles and set its value to 1
        New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\$logName" -Name "AutoBackupLogFiles" -Value "1" -PropertyType "DWord"
        # Create a new registry entry for Flags and set its value to 1
        New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\$logName" -Name "Flags" -Value "1" -PropertyType "DWord"
        # Update the File property in the registry to point to the new event log file location
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\$logName" -Name "File" -Value "$targetFolder\$escapedLogName.evtx"
    }

    # End of script
