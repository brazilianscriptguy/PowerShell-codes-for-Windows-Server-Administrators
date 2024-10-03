# 📂 BlueTeam-Tools

Welcome to the **BlueTeam-Tools** repository! This collection of PowerShell scripts is meticulously crafted to assist Forensics and Blue Team professionals in monitoring, detecting, and responding to security threats efficiently. Each tool is designed to extract relevant information from logs and other crucial sources, generating outputs in `.CSV` format for straightforward analysis.

## 🛠️ Prerequisites

Before using the scripts in this repository, ensure the following prerequisites are met:

1. **Microsoft Log Parser Utility**
   - **Installation:** Required on Windows Server machines or Windows 10/11 workstations where these scripts will be executed.
   - **Usage:** Enables advanced querying and analysis of various log formats.

2. **Remote Server Administration Tools (RSAT)**
   - **Installation:** Necessary on Windows 10 or 11 workstations to fully leverage scripts that include the `Import-Module ActiveDirectory` command.
   - **Usage:** Facilitates management of Active Directory and other remote server roles.

3. **PowerShell Version**
   - **Recommendation:** PowerShell 5.1 or later.
   - **Check Version:**
     ```powershell
     $PSVersionTable.PSVersion
     ```

4. **Administrator Privileges**
   - **Note:** Some scripts require elevated permissions to access certain system information and logs.

## 📄 Description

This repository encompasses a suite of PowerShell scripts specifically designed to streamline Forensics and Blue Team operations. These tools facilitate the extraction and analysis of critical information from Windows Event Logs, system configurations, running processes, and more. Key features include:

- **Graphical User Interface (GUI):** Each script offers an intuitive GUI to enhance user interaction.
- **Logging:** Generates `.log` files to maintain audit trails of script executions.
- **Export Functionality:** Outputs results to `.CSV` files for easy data manipulation and reporting.

> **✨ Enhance your security posture with these tools, making server and workstation management more intuitive and efficient.**

### 📜 Script Descriptions (Alphabetically Ordered)

1. ### [Automated Threat Hunting with Invoke-AtomicRedTeam](./ThreatHunting/ThreatHunting-InvokeAtomicRedTeam.ps1)
   
   **Description:**  
   Leverages the **Invoke-AtomicRedTeam** module to execute atomic tests that simulate adversary techniques. This script automates threat hunting and vulnerability assessments, collecting and exporting results for analysis.

   **Features:**
   - Executes specified or all atomic tests.
   - Generates detailed `.CSV` reports of test outcomes.
   - Provides a summary of findings directly within the console.

2. ### [Collect-SystemInfo](./IncidentResponse/Collect-SystemInfo.ps1)
   
   **Description:**  
   Gathers comprehensive system information crucial for incident response. This script collects data on network configurations, running services, installed software, active network connections, and scheduled tasks, exporting the information for thorough analysis.

   **Features:**
   - Creates an organized output directory for reports.
   - Exports data to various formats (`.txt` and `.csv`).
   - Facilitates quick assessment of system status during incidents.

3. ### [Check-SystemCompliance](./SystemComplianceCheck/Check-SystemCompliance.ps1)
   
   **Description:**  
   Evaluates system configurations against predefined compliance standards or organizational security policies. Identifies non-compliant settings and provides actionable reports to ensure adherence to best practices.

   **Features:**
   - Checks critical security settings like firewall status and PowerShell logging.
   - Optionally exports compliance reports to `.CSV` files.
   - Easy customization to include additional compliance checks.

4. ### [Detect-MaliciousProcesses](./MaliciousProcessDetection/Detect-MaliciousProcesses.ps1)
   
   **Description:**  
   Scans running processes to identify known malicious signatures or suspicious behaviors such as high CPU usage. This script helps in early detection of potential threats, allowing for timely remediation.

   **Features:**
   - Utilizes a customizable list of known malicious processes.
   - Flags processes exceeding defined CPU usage thresholds.
   - Exports detection results for further investigation.

5. ### [Monitor-SecurityEvents](./EventLogMonitoring/Monitor-SecurityEvents.ps1)
   
   **Description:**  
   Monitors Windows Security Event Logs for specific Event IDs associated with suspicious or malicious activities. Provides real-time alerts and detailed reports to aid in proactive threat detection.

   **Features:**
   - Monitors key Event IDs like failed login attempts and privilege escalations.
   - Outputs findings to the console and optionally exports to `.CSV` files.
   - Suitable for scheduling regular checks via Task Scheduler.

### COMING SOON:
Stay tuned for the next series of BlueTeam-Tools scripts, which will provide more innovative and efficient tools to enhance Forensics and Security Teams everyday tasks.

## ❓ Additional Assistance

*All script codes can be edited and customized to suit your preferences and requirements. For further help or detailed information regarding prerequisites and environment setup, please refer to the `README.md` file in the main root folder.*
