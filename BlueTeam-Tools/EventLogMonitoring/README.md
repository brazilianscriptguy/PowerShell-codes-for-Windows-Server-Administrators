# 📂 EventLogMonitoring Folder

## 🛠️ Prerequisites

To effectively use the scripts in this folder, ensure the following prerequisites are met:

1. **Microsoft Log Parser Utility**  
   - **Installation:** Required on Windows Server machines or Windows 10/11 workstations.  
   - **Usage:** Facilitates advanced querying and analysis of various log formats.

2. **Remote Server Administration Tools (RSAT)**  
   - **Installation:** Necessary on Windows 10/11 workstations to fully leverage scripts that use the `Import-Module ActiveDirectory` command.  
   - **Usage:** Enables Active Directory and other remote server role management.

*Scripts that process `.evtx` files can also be run directly from a Windows 10 or 11 workstation.*

## 📄 Description

This folder contains a suite of PowerShell scripts crafted to process **Windows Event Log files (.evtx)**. These tools extract key data from event logs and generate outputs in `.CSV` format, facilitating easy analysis and reporting.

> **✨ Each script includes a graphical user interface (GUI) for enhanced user interaction. Scripts also generate `.log` files and export results to `.csv`, streamlining server and workstation management.**

### 📜 Script Descriptions (Alphabetically Ordered)

1. **EventID-Count-AllEvtx-Events.ps1**  
   - **Purpose:** Counts occurrences of each EventID in `.evtx` files and exports the results to a `.CSV`, aiding event log analysis.

2. **EventID307-PrintAudit.ps1**  
   - **Purpose:** Audits print activities by analyzing Event ID 307 from the Microsoft-Windows-PrintService/Operational log, generating detailed tracking reports that include user actions, printer usage, and job specifics.
   - **Additional Files:**
     - **PrintService-Operational-EventLogs.reg**  
       Customize and merge these registry configurations into Windows Print Servers before initiating print activity audits. This step ensures that the necessary logging is enabled to capture detailed print activity data effectively.
     - **PrintService-Operational-EventLogs.md**  
       Read the `PrintService-Operational-EventLogs.md` for all instructions and best practices before configuring the Windows Event Log for the PrintService Operational log. This ensures that the necessary configurations are correctly applied to capture detailed print activity data effectively.

3. **EventID4624-LogonViaRDP.ps1**  
   - **Purpose:** Generates a `.CSV` report on RDP logon activities (Event ID 4624) to monitor remote access and identify potential security risks.

4. **EventID4624-UserLogonTracking.ps1**  
   - **Purpose:** Tracks user logon activities (Event ID 4624) and produces a `.CSV` report for auditing and compliance purposes.

5. **EventID4625-LogonAccountFailed.ps1**  
   - **Purpose:** Compiles failed logon attempts (Event ID 4625) into a `.CSV`, helping to identify potential breaches and failed login patterns.

6. **EventID4648-ExplicitCredentialsLogon.ps1**  
   - **Purpose:** Logs explicit credential usage (Event ID 4648) and generates a `.CSV` report, aiding in detecting unauthorized credential use.

7. **EventID4660and4663-ObjectDeletionTracking.ps1**  
   - **Purpose:** Tracks object deletion events (Event IDs 4660 and 4663), organizing data into a `.CSV` for auditing security and access changes.

8. **EventID4771-KerberosPreAuthFailed.ps1**  
   - **Purpose:** Identifies Kerberos pre-authentication failures (Event ID 4771) and outputs findings to a `.CSV`, helping diagnose authentication issues.

9. **EventID4800and4801-WorkstationLockStatus.ps1**  
   - **Purpose:** Tracks workstation locking and unlocking events (Event IDs 4800 and 4801), generating a `.CSV` report for monitoring workstation security.

10. **EventID5136-5137-5141-ADObjectChanges.ps1**  
    - **Purpose:** Analyzes Active Directory object changes and deletions (Event IDs 5136, 5137, and 5141), producing a `.CSV` report for auditing AD modifications.

11. **EventID6005-6006-6008-6009-6013-1074-1076-SystemRestarts.ps1**  
    - **Purpose:** Retrieves details of system restarts and shutdown events (Event IDs 6005, 6006, 6008, 6009, 6013, 1074, and 1076) from the System log using `Get-EventLog`, and exports the results to a `.CSV` file.

12. **Migrate-WinEvtStructure-Tool.ps1**  
    - **Purpose:** Moves Windows Event Log files to a new directory, updates registry paths, stops and restarts the Event Log service to move `.evtx` files. **Note:** Requires administrative privileges.

## ❓ Additional Assistance

*All script codes can be customized to suit your specific needs. For further assistance or detailed information on prerequisites and setup, please refer to the `README.md` file in the main root folder.*
