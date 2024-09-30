
# 📂 Eventlogs-Tools Folder

## 🛠️ Prerequisites

Before using the scripts in this folder, ensure that the **Microsoft Log Parser utility** is installed on the Windows Server machines or the Windows 10 or 11 workstations where these scripts will be executed. You can also execute scripts that handle `.evtx` files directly from a Windows 10 or 11 workstation. To fully leverage these scripts, which include the `Import-Module ActiveDirectory` command, **Remote Server Administration Tools (RSAT)** must be installed on the workstation.

## 📄 Description
This directory contains a collection of scripts specifically designed to process `Windows Event Log files (.evtx)`. These scripts extract relevant information from the logs and generate outputs in .CSV format for straightforward analysis.

> **✨ Each script features a graphical user interface `(GUI)` to enhance user interaction. Additionally, they offer functionalities for generating `.log` files and exporting results to `.csv` files, making the management of servers and workstations more intuitive and efficient.**

### 📜 Script Descriptions (Alphabetically Ordered)

1. **EventID-Count-AllEvtx-Events.ps1**  
   Analyzes EVTX files, counting occurrences of each EventID, and exports the results to a CSV file for easier event log analysis.

2. **EventID307-PrintAudit.ps1**  
   Extracts detailed insights from the Microsoft-Windows-PrintService/Operational Event Log (Event ID 307), auditing print activities for enhanced tracking.

3. **EventID4624-LogonViaRDP.ps1**  
   Reports on RDP logon activities (Event ID 4624) by generating a CSV report to monitor remote access security and identify potential risks.

4. **EventID4624-UserLogonTracking.ps1**  
   Tracks user logon activities (Event ID 4624) and provides detailed logon data in a CSV report for auditing and compliance purposes.

5. **EventID4625-LogonAccountFailed.ps1**  
   Compiles failed logon attempts (Event ID 4625) into a CSV file to help identify potential security breaches and failed login patterns.

6. **EventID4648-ExplicitCredentialsLogon.ps1**  
   Logs explicit credential usage (Event ID 4648) and generates a CSV report to detect unauthorized or improper credential use.

7. **EventID4660and4663-ObjectDeletionTracking.ps1**  
   Tracks object deletion events (Event IDs 4660 and 4663), organizes the data into a CSV report, and aids in auditing security and access changes.

8. **EventID4771-KerberosPreAuthFailed.ps1**  
   Identifies Kerberos pre-authentication failures (Event ID 4771) and outputs findings to a CSV file, assisting in diagnosing authentication issues.

9. **EventID4800and4801-WorkstationLockStatus.ps1**  
   Tracks workstation locking and unlocking events (Event IDs 4800 and 4801) and provides a CSV report to monitor workstation security.

10. **EventID5136-5137-5141-ADObjectChanges.ps1**  
    Analyzes Active Directory object changes and deletions (Event IDs 5136, 5137, and 5141), generating a CSV report for auditing AD modifications.

11. **EventIDs1074-6006-6008-6013-SystemRestarts.ps1**  
    Retrieves details on normal system restarts and unexpected shutdowns (Event ID 6008) into a CSV file, aiding in the diagnosis of system instability.

12. **EventLogFiles-MigratorTool.ps1**  
    Manages Windows Server Event Log files by reorganizing, moving, and resizing them for optimized accessibility and storage efficiency.

### COMING SOON:
Stay tuned for the next series of EventID analysis scripts, which will provide more innovative and efficient tools to enhance system administration and event log management.

## ❓ Additional Assistance

*All script codes can be edited and customized to suit your preferences and requirements. For further help or detailed information regarding prerequisites and environment setup, please refer to the `README.md` file in the main root folder.*
