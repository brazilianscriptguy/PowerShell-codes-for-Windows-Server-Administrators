📂 Files in the Eventlogs-Tools Folder

🛠️ Prerequisites

Before running the scripts in this folder, ensure that the **Microsoft Log Parser utility** is installed on your system. Additionally, to fully utilize these scripts, you must have the ability to execute PowerShell scripts `(.PS1)`, especially those that use the `Import-Module ActiveDirectory` command. This is particularly important on Windows 10 and 11 Workstations, which require the installation of `Remote Server Administration Tools (RSAT)`.

Each script in this repository **features a graphical user interface** `(GUI)`, enhances user interaction, and includes functionalities for **generating operational** `.log` files and **exporting results** to `.csv` files, making server and workstation management more intuitive and user-friendly.

## 📄 Description

This directory contains a collection of scripts designed for selecting and processing **Windows Event Log files (.evtx)**. These scripts focus on extracting relevant information from the logs and generating outputs in a `.CSV` file format for easy analysis.

> **✨ All scripts in this folder are equipped with a graphical user interface (GUI), enhancing user interaction and making them more user-friendly and accessible for event log management tasks.**

### 📜 Script Descriptions (Alphabetically Ordered)

1. **EventID-Count-AllEvents-EVTX.ps1**: Analyzes EVTX files, counting each EventID occurrence, and exports the results to a CSV file for easier event log analysis.

2. **EventID307-PrintAudit.ps1**: Extracts detailed insights from the Microsoft-Windows-PrintService/Operational Event Log (Event ID 307), auditing print activities.

3. **EventID4624-LogonViaRDP.ps1**: Reports on RDP logon activities (Event ID 4624) by generating a CSV report to monitor remote access security.

4. **EventID4624-UserLogonTracking.ps1**: Tracks user logon activities (Event ID 4624) and provides logon details in a CSV report for auditing purposes.

5. **EventID4625-LogonAccountFailed.ps1**: Compiles failed logon attempts (Event ID 4625) into a CSV file to identify potential security breaches.

6. **EventID4648-ExplicitCredentialsLogon.ps1**: Logs explicit credential usage (Event ID 4648), generating a CSV report to detect unauthorized access.

7. **EventID4660and4663-ObjectDeletionTracking.ps1**: Tracks object deletion events (Event IDs 4660 and 4663) and organizes them into a CSV report.

8. **EventID4771-KerberosPreAuthFailed.ps1**: Identifies Kerberos pre-authentication failures (Event ID 4771) and outputs findings to a CSV file.

9. **EventID4800and4801-WorkstationLockStatus.ps1**: Tracks workstation locking/unlocking events (Event IDs 4800 and 4801) and provides a CSV report.

10. **EventID5136-5137-5141-ADObjectChanges.ps1**: Analyzes Active Directory object changes/deletions (Event IDs 5136, 5137, and 5141) and generates a CSV report.

11. **EventIDs1074-6006-6008-6013-SystemRestarts.ps1**: Retrieves ordinary system restarts and unexpected shutdowns (EventID 6008) into a CSV file for diagnosing system instability, and generates a CSV report.

12. **EventLogFiles-MigratorTool.ps1**: Manages Windows Server Event Log files by reorganizing, moving, and resizing them for optimized accessibility.

13. **COMING SOON**: Stay tuned for the next series of EventID analyses, providing more innovative and efficient tools to enhance system administration and event log management.

## ❓ Additional Assistance

All script codes can be edited and customized to suit your preferences and requirements. For further help or detailed information regarding prerequisites and environment setup, please refer to the `README.md` file in the main root folder.
