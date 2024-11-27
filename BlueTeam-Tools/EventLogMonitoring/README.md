# 🔵 BlueTeam-Tools - EventLogMonitoring Folder

## 🛠️ Prerequisites

To effectively use the scripts in this folder, ensure the following prerequisites are met:

1. **Microsoft Log Parser Utility**  
   - **Download**: Visit the [Log Parser 2.2 page](https://www.microsoft.com/en-us/download/details.aspx?id=24659) and download LogParser.msi.
   - **Installation:** Required on Windows Server machines or Windows 10/11 workstations.  
   - **Usage:** Facilitates advanced querying and analysis of various log formats.

3. **Remote Server Administration Tools (RSAT)**  
   - **Installation:** Necessary on Windows 10/11 workstations to fully leverage scripts that use the `Import-Module ActiveDirectory` command.  
   - **Usage:** Enables Active Directory and other remote server role management.

4. **PowerShell Version**  
   - **Recommendation:** PowerShell 5.1 or later.  
   - **Check Version:** Run the following command to verify your PowerShell version:
     ```powershell
     $PSVersionTable.PSVersion
     ```

5. **Administrator Privileges**  
   - **Note:** Some scripts require elevated permissions to access certain system information and logs.

*Scripts that process `.evtx` files can also be run directly from a Windows 10 or 11 workstation.*

## 📄 Description

This folder contains a suite of PowerShell scripts crafted to process **Windows Event Log files (.evtx)**. These tools extract key data from event logs and generate outputs in `.CSV` format, facilitating easy analysis and reporting.

> **✨ Each script includes a graphical user interface (GUI) for enhanced user interaction. Scripts also generate `.LOG` files and export results to `.CSV`, streamlining server and workstation management.**

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

## 🚀 How to Use

1. **EventID-Count-AllEvtx-Events.ps1**  
   - **Instructions:** Run the script with administrative privileges to count EventIDs in `.evtx` files. The GUI will guide you through selecting log files and exporting the count to a `.CSV`.

2. **EventID307-PrintAudit.ps1**  
   - **Instructions:** Execute this script to audit print activities. Ensure that the `PrintService-Operational-EventLogs.reg` and `PrintService-Operational-EventLogs.md` files are correctly configured and merged into your Windows Print Servers before running the script.

3. **EventID4624-LogonViaRDP.ps1**  
   - **Instructions:** Use this script to generate a report on RDP logon activities. Run the script with administrative privileges to access and analyze relevant Event IDs.

4. **EventID4624-UserLogonTracking.ps1**  
   - **Instructions:** Execute this script to track user logon activities. The GUI will assist in selecting the appropriate logs and exporting the data to a `.CSV` for auditing purposes.

5. **EventID4625-LogonAccountFailed.ps1**  
   - **Instructions:** Run the script to compile failed logon attempts. Review the generated `.CSV` to identify potential security threats or breaches.

6. **EventID4648-ExplicitCredentialsLogon.ps1**  
   - **Instructions:** Use this script to log and review explicit credential usage. The GUI will help you filter and export relevant Event IDs to a `.CSV` for analysis.

7. **EventID4660and4663-ObjectDeletionTracking.ps1**  
   - **Instructions:** Execute this script to track and audit object deletion events. The generated `.CSV` will provide detailed information on security and access changes.

8. **EventID4771-KerberosPreAuthFailed.ps1**  
   - **Instructions:** Run the script to identify and analyze Kerberos pre-authentication failures. Review the `.CSV` report to address authentication issues.

9. **EventID4800and4801-WorkstationLockStatus.ps1**  
   - **Instructions:** Use this script to monitor workstation locking and unlocking events. The GUI will facilitate the generation of a `.CSV` report for security monitoring.

10. **EventID5136-5137-5141-ADObjectChanges.ps1**  
    - **Instructions:** Execute this script to analyze Active Directory object changes and deletions. The GUI will assist in selecting the relevant Event IDs and exporting the data to a `.CSV` for auditing.

11. **EventID6005-6006-6008-6009-6013-1074-1076-SystemRestarts.ps1**  
    - **Instructions:** Run this script to retrieve and export system restart and shutdown event details. The `.CSV` output will help in monitoring system uptime and stability.

12. **Migrate-WinEvtStructure-Tool.ps1**  
    - **Instructions:** Use this script to migrate Windows Event Log files to a new directory. Ensure you have administrative privileges before running the script, as it modifies registry paths and restarts the Event Log service.

## 📝 Logging and Output

- 📄 **Logging:** Each script generates detailed logs in `.LOG` format, documenting every step of the process, from uninstalling software to handling errors.
- 📊 **Export Functionality:** Results are exported in `.CSV` format, providing easy-to-analyze data for auditing and reporting purposes.
