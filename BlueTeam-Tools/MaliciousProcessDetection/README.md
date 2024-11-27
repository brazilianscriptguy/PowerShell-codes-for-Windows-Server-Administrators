# 🔵 BlueTeam-Tools - MaliciousProcessDetection Folder

## 📝 Overview

This folder contains scripts designed to help detect and remove **malicious processes** and unwanted applications in Windows environments. These tools enable administrators to efficiently uninstall suspicious or unauthorized software, ensuring system integrity and enhancing security.

## 🛠️ Prerequisites

Before using the scripts in this folder, ensure the following prerequisites are met:

1. **⚙️ PowerShell**
   - **Requirement:** PowerShell must be enabled on your system.
   - **Module:** Import the **Active Directory** module if necessary.

2. **🔑 Administrator Privileges**
   - **Note:** Some scripts require elevated permissions to uninstall applications and access certain system information.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - **Installation:** Ensure RSAT is installed on your Windows 10/11 workstation to enable remote administration of Windows Servers.
   - **Usage:** Facilitates the management of Active Directory and other remote server roles.

## 📄 Description

This folder contains a suite of PowerShell scripts crafted to detect and remove **malicious processes** and unwanted applications within Windows environments. These tools automate and simplify the uninstallation of unauthorized software, enhancing system security and maintaining organizational compliance.

> **✨ Each script includes a graphical user interface (GUI) for enhanced user interaction. Scripts also generate `.log` files and export results to `.csv` files, streamlining server and workstation management processes.**

### 📜 Script Descriptions (Alphabetically Ordered)

1. **🛡️ Remove-Softwares-NonCompliance-Tool.ps1**  
   - **Purpose:** Uninstalls multiple software applications based on a list of software names provided in a `.txt` file. It logs all actions, handles errors gracefully, and allows users to execute, cancel, or close the uninstallation process with ease.

2. **📝 Softwares-NonCompliance-List.txt**  
   - **Purpose:** A configuration text file used by the **Remove-Softwares-NonCompliance-Tool.ps1** script. It contains the names of the software applications to be uninstalled, ensuring only the specified apps are targeted.

3. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   - **Purpose:** Enforces software compliance by removing non-compliant or unauthorized software via Group Policy Objects (GPO). This script helps reduce vulnerabilities by automatically uninstalling unauthorized applications across multiple machines.

4. **🗑️ Uninstall-SelectedApp-Tool.ps1**  
   - **Purpose:** Provides a user-friendly GUI for selecting and uninstalling applications from workstations. This tool is particularly useful for detecting and removing unwanted or malicious software. The process is automated, minimizing manual intervention and ensuring effective removal.

## 🚀 How to Use

### 1. **🛡️ Remove-Softwares-NonCompliance-Tool.ps1**
   - **Step 1:** Open the **📝 Softwares-NonCompliance-List.txt** file and list the names of the software you want to uninstall. Ensure each software name is on a separate line.
   - **Step 2:** Run the **Remove-Softwares-NonCompliance-Tool.ps1** script with administrative privileges.
   - **Step 3:** The script will automatically uninstall all the listed applications. It will log all actions performed and handle any errors encountered during the process.
   - **Step 4:** Review the generated `.log` file for details on the uninstallation process and any errors that were handled.

### 2. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**
   - **Step 1:** Prepare your GPO to deploy this script across multiple systems.
   - **Step 2:** Execute the **Remove-Softwares-NonCompliance-viaGPO.ps1** script to silently remove non-compliant or unauthorized software from target machines.
   - **Step 3:** The script will uninstall the specified software and log the results. Review the logs to confirm the uninstallation was successful and to ensure compliance across all systems.

### 3. **🗑️ Uninstall-SelectedApp-Tool.ps1**
   - **Step 1:** Run the **Uninstall-SelectedApp-Tool.ps1** script with administrative privileges.
   - **Step 2:** A graphical user interface (GUI) will appear, showing a list of installed applications on the system.
   - **Step 3:** Select the application(s) you want to uninstall from the list.
   - **Step 4:** Confirm the uninstallation. The script will proceed to uninstall the selected application(s) and log the actions taken, including any errors encountered.
   - **Step 5:** Review the `.log` file for details about the uninstalled applications and any issues that were handled during the process.

## 📝 Logging and Output

- 📄 **Logging:** Each script generates detailed logs in `.LOG` format, documenting every step of the process, from uninstalling software to handling errors.
- 📊 **Export Functionality:** Results are exported in `.CSV` format, providing easy-to-analyze data for auditing and reporting purposes.
