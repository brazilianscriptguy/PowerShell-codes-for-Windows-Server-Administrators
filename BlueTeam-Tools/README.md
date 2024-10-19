# 📂 BlueTeam-Tools

Welcome to the **BlueTeam-Tools** repository! This collection of PowerShell scripts is designed to assist Forensics and Blue Team professionals in effectively monitoring, detecting, and responding to security threats. Each tool extracts crucial information from logs, system configurations, and other sources, generating outputs in `.CSV` format for easy analysis and reporting.

## 🛠️ Prerequisites

Before using the scripts in this repository, ensure the following prerequisites are met:

1. **📝 Microsoft Log Parser Utility**
   - **Installation:** Required on Windows Server machines or Windows 10/11 workstations where these scripts will be executed.
   - **Usage:** Enables advanced querying and analysis of various log formats.

2. **🖥️ Remote Server Administration Tools (RSAT)**
   - **Installation:** Necessary on Windows 10 or 11 workstations to fully leverage scripts that include the `Import-Module ActiveDirectory` command.
   - **Usage:** Facilitates the management of Active Directory and other remote server roles.

3. **⚙️ PowerShell Version**
   - **Recommendation:** PowerShell 5.1 or later.
   - **Check Version:** Run the following command to verify your PowerShell version:
     ```powershell
     $PSVersionTable.PSVersion
     ```

4. **🔑 Administrator Privileges**
   - **Note:** Some scripts require elevated permissions to access certain system information and logs.

## 📄 Description

This repository contains a comprehensive suite of PowerShell scripts specifically designed to streamline forensic investigations and enhance Blue Team operations. These tools allow for the extraction and analysis of key information from Windows Event Logs, system configurations, running processes, and more. Key features include:

- **💻 Graphical User Interface (GUI):** Each script includes an intuitive GUI to enhance user interaction.
- **📝 Logging:** Generates `.LOG` files to maintain audit trails of script executions.
- **📊 Export Functionality:** Outputs results in `.CSV` format for easy data manipulation and reporting.

> **✨ Boost your security posture with these tools, making server and workstation management more intuitive and efficient.**

## 📁 Folder Structure

The repository is organized into the following subfolders, each containing specific tools tailored for different Blue Team tasks:

1. **📄 EventLogMonitoring**  
   Scripts for processing and analyzing Windows Event Logs, providing detailed insights into key event activities. Ideal for monitoring and auditing logs to detect anomalies.

2. **🛡️ IncidentResponse**  
   Tools designed to gather comprehensive system data and assist with incident response efforts. These scripts help rapidly gather and analyze critical information during a security incident.

3. **🔍 MaliciousProcessDetection**  
   Scripts that identify and report suspicious or malicious processes running on your systems, providing a fast way to detect and respond to active threats.

4. **⚙️ SystemComplianceCheck**  
   Tools to ensure that system configurations meet security and compliance standards by identifying non-compliant settings, helping to maintain a secure environment.

5. **🕵️ ThreatHunting**  
   Scripts designed for proactive threat hunting, using advanced detection techniques and simulations, including modules like **Invoke-AtomicRedTeam**, to identify potential threats in your network.

### ✨ Coming Soon:

Stay tuned for more **BlueTeam-Tools** scripts, designed to provide even more innovative and efficient solutions to enhance the daily operations of Forensics and Security Teams.

## ❓ Additional Assistance

*All scripts can be edited and customized to suit your specific needs and requirements. For further help or detailed information regarding prerequisites and environment setup, please refer to this `README.md` file.*
