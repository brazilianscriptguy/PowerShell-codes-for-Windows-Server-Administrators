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
   Counts occurrences of each EventID in EVTX files and exports the results to a CSV, aiding event log analysis.

2. **EventID307-PrintAudit.ps1**  
   Audits print activities by analyzing Event ID 307 from the Microsoft-Windows-PrintService/Operational log, generating detailed tracking reports that include user actions, printer usage, and job specifics.

   **PrintService-Operational-EventLogs.reg**
   Before initiating print activity audits, you must first customize and merge these registry configurations into the Windows Print Servers. This step ensures that the necessary logging is enabled to capture detailed print activity data effectively.

4. **EventID4624-LogonViaRDP.ps1**  
   Generates a CSV report on RDP logon activities (Event ID 4624) to monitor remote access and identify potential security risks.

5. **EventID4624-UserLogonTracking.ps1**  
   Tracks user logon activities (Event ID 4624) and produces a CSV report for auditing and compliance purposes.

6. **EventID4625-LogonAccountFailed.ps1**  
   Compiles failed logon attempts (Event ID 4625) into a CSV, helping to identify potential breaches and failed login patterns.

7. **EventID4648-ExplicitCredentialsLogon.ps1**  
   Logs explicit credential usage (Event ID 4648) and generates a CSV report, aiding in detecting unauthorized credential use.

8. **EventID4660and4663-ObjectDeletionTracking.ps1**  
   Tracks object deletion events (Event IDs 4660 and 4663), organizing data into a CSV for auditing security and access changes.

9. **EventID4771-KerberosPreAuthFailed.ps1**  
   Identifies Kerberos pre-authentication failures (Event ID 4771) and outputs findings to a CSV, helping diagnose authentication issues.

10. **EventID4800and4801-WorkstationLockStatus.ps1**  
   Tracks workstation locking and unlocking events (Event IDs 4800 and 4801), generating a CSV report for monitoring workstation security.

11. **EventID5136-5137-5141-ADObjectChanges.ps1**  
    Analyzes Active Directory object changes and deletions (Event IDs 5136, 5137, and 5141), producing a CSV report for auditing AD modifications.

12. **EventID6005-6006-6008-6009-6013-1074-1076-SystemRestarts.ps1**  
    Retrieves details of system restarts and shutdown events (Event IDs 6005, 6006, 6008, 6009, 6013, 1074, and 1076) from the System log using `Get-EventLog`,  and exports the results to a CSV file.

13. **Migrate-WinEvtStructure-Tool.ps1**  
    Moves Windows Event Log files to a new directory, updating registry paths; stops and restarts the Event Log service to move `.evtx` files; requires administrative privileges.

## ❓ Additional Assistance

*All script codes can be customized to suit your specific needs. For further assistance or detailed information on prerequisites and setup, please refer to the `README.md` in the main root folder.*
