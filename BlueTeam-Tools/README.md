# 📂 BlueTeam-Tools

Welcome to the **BlueTeam-Tools** repository! This collection of PowerShell scripts is meticulously designed to assist Forensics and Blue Team professionals in efficiently monitoring, detecting, and responding to security threats. Each tool is built to extract crucial information from logs and other sources, generating outputs in `.CSV` format for straightforward analysis.

## 🛠️ Prerequisites

Before using the scripts in this repository, ensure the following prerequisites are met:

1. **Microsoft Log Parser Utility**
   - **Installation:** Required on Windows Server machines or Windows 10/11 workstations where these scripts will be executed.
   - **Usage:** Enables advanced querying and analysis of various log formats.

2. **Remote Server Administration Tools (RSAT)**
   - **Installation:** Necessary on Windows 10 or 11 workstations to fully leverage scripts that include the `Import-Module ActiveDirectory` command.
   - **Usage:** Facilitates the management of Active Directory and other remote server roles.

3. **PowerShell Version**
   - **Recommendation:** PowerShell 5.1 or later.
   - **Check Version:** Run the following command to verify your PowerShell version:
     ```powershell
     $PSVersionTable.PSVersion
     ```

4. **Administrator Privileges**
   - **Note:** Some scripts require elevated permissions to access certain system information and logs.

## 📄 Description

This repository contains a suite of PowerShell scripts specifically designed to streamline forensic investigations and enhance Blue Team operations. These tools facilitate the extraction and analysis of key information from Windows Event Logs, system configurations, running processes, and more. Key features include:

- **Graphical User Interface (GUI):** Each script includes an intuitive GUI to enhance user interaction.
- **Logging:** Generates `.log` files to maintain audit trails of script executions.
- **Export Functionality:** Outputs results in `.CSV` format for easy data manipulation and reporting.

> **✨ Boost your security posture with these tools, making server and workstation management more intuitive and efficient.**

### 📁 Folder Structure

The repository is organized into the following subfolders, each containing specific tools:

1. **EventLogMonitoring**  
   Scripts for processing and analyzing Windows Event Logs, providing detailed insights into key event activities.
   
2. **IncidentResponse**  
   Tools designed to gather comprehensive system data and assist with incident response efforts.
   
3. **MaliciousProcessDetection**  
   Scripts that identify and report suspicious or malicious processes running on your systems.
   
4. **SystemComplianceCheck**  
   Tools to ensure system configurations meet security and compliance standards by identifying non-compliant settings.
   
5. **ThreatHunting**  
   Scripts for proactive threat hunting using detection techniques and simulations, including modules like Invoke-AtomicRedTeam.

### ✨ Coming Soon:
Stay tuned for the next series of **BlueTeam-Tools** scripts, which will provide more innovative and efficient tools to enhance the daily operations of Forensics and Security Teams.

## ❓ Additional Assistance

*All scripts can be edited and customized to suit your specific needs and requirements. For further help or detailed information regarding prerequisites and environment setup, please refer to this `README.md` file.*

---

### Final Enhancements:

- **Folder Structure:** Added a detailed folder structure to describe each subfolder and its purpose.
- **Formatting Consistency:** Ensured uniformity across the document for readability and ease of navigation.
- **Coming Soon Section:** Clear and anticipatory language to encourage future use.

This `README.md` is now ready to serve as the main documentation file for your `BlueTeam-Tools` repository, providing users with clear instructions and an overview of the tools available.
