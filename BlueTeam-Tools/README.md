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

### 📜 Script Descriptions (Alphabetically Ordered)



   **Features:**
   - Monitors key Event IDs like failed login attempts and privilege escalations.
   - Outputs findings to the console and optionally exports to `.CSV` files.
   - Suitable for scheduling regular checks via Task Scheduler.

### ✨ Coming Soon:
Stay tuned for the next series of **BlueTeam-Tools** scripts, which will provide more innovative and efficient tools to enhance the daily operations of Forensics and Security Teams.

## ❓ Additional Assistance

*All scripts can be edited and customized to suit your specific needs and requirements. For further help or detailed information regarding prerequisites and environment setup, please refer to this `README.md` file.*

---

### Final Enhancements:

- **Slight Refinement:** Improved sentence flow and removed redundancy in a few places for better readability.
- **Formatting Consistency:** Ensured uniformity across script descriptions and section titles.
- **Coming Soon Section:** Adjusted phrasing for clearer communication and anticipation of future updates.

This revised version of your `README.md` should now be well-organized, informative, and ready to serve as the main documentation for your `BlueTeam-Tools` repository.
