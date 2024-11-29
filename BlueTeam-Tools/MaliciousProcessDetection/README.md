# 🔵 BlueTeam-Tools - Malicious Process Detection Suite

## 📝 Overview

The **MaliciousProcessDetection Folder** contains a suite of **PowerShell scripts** designed to detect and remove **malicious processes** and unauthorized applications within **Windows environments**. These tools automate the uninstallation of suspicious software, enhancing system integrity, ensuring compliance, and strengthening overall security.

### Key Features:
- **User-Friendly GUI:** Simplifies user interaction for efficient operation.
- **Detailed Logging:** All scripts generate `.log` files for operational transparency and troubleshooting.
- **Exportable Reports:** Scripts export data in `.csv` format for easy integration with reporting tools.
- **Proactive Software Compliance:** Automates the removal of non-compliant applications, improving security and reducing vulnerabilities.

---

## 🛠️ Prerequisites

Ensure the following requirements are met before running the scripts:

1. **⚙️ PowerShell**
   - PowerShell must be enabled on your system.
   - The following module may need to be imported where applicable:
     - **Active Directory:** `Import-Module ActiveDirectory`

2. **🔑 Administrator Privileges**
   - Scripts may require elevated permissions to access sensitive configurations, uninstall applications, or modify system settings.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - Install RSAT on your Windows 10/11 workstation to enable remote management of Active Directory and server roles.

---

## 📄 Script Descriptions (Alphabetical Order)

1. **🛡️ Remove-Softwares-NonCompliance-Tool.ps1**  
   Automates the uninstallation of multiple software applications based on a `.txt` configuration file. Logs all actions performed, handles errors gracefully, and provides an efficient solution for bulk software removal.

2. **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   Enforces software compliance by removing non-compliant or unauthorized applications via Group Policy Objects (GPO). This script reduces vulnerabilities by automating software removal across multiple machines.

3. **📝 Softwares-NonCompliance-List.txt**  
   A configuration text file used by **Remove-Softwares-NonCompliance-Tool.ps1**. Contains the names of applications to uninstall, ensuring targeted and precise uninstallation.

4. **🗑️ Uninstall-SelectedApp-Tool.ps1**  
   Provides a user-friendly GUI for selecting and uninstalling applications directly from workstations. This script detects and removes unwanted or malicious software with minimal manual intervention, ensuring effective removal.

---

## 🚀 Usage Instructions

### General Steps:
1. **Run the Script:** Launch the desired script using the `Run With PowerShell` option.  
2. **Provide Inputs:** Follow on-screen prompts or specify parameters as required.  
3. **Review Outputs:** Check generated `.log` files and, where applicable, `.csv` reports for results.

### Example Scenarios:

- **🛡️ Remove-Softwares-NonCompliance-Tool.ps1**  
   - Open **Softwares-NonCompliance-List.txt** and list the names of applications to uninstall (one per line).  
   - Run the script with administrative privileges.  
   - The script automatically uninstalls the listed applications, logs actions taken, and gracefully handles errors.  
   - Review the `.log` file for detailed uninstallation reports.

- **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   - Prepare a GPO to deploy this script across multiple systems.  
   - Execute the script to silently uninstall non-compliant software on target machines.  
   - Logs confirm the uninstallation process and ensure compliance.

- **🗑️ Uninstall-SelectedApp-Tool.ps1**  
   - Run the script to launch a graphical user interface (GUI).  
   - Select the application(s) to uninstall from the displayed list.  
   - Confirm and proceed with the uninstallation.  
   - Logs document the removed applications and any issues encountered.

---

## 📝 Logging and Output

- **📄 Logs:** Each script generates detailed logs in `.LOG` format, documenting every step of the process, including uninstallation actions and error handling.  
- **📊 Reports:** Scripts export data in `.CSV` format, providing actionable insights for auditing and reporting purposes.

---

## 💡 Tips for Optimization

- **Automate Execution:** Use task schedulers to deploy scripts periodically, ensuring consistent software compliance.  
- **Centralize Logs and Reports:** Store `.log` and `.csv` files in a shared location for collaborative analysis and audits.  
- **Tailor Scripts to Policies:** Customize the scripts and configuration files to meet your organization's specific compliance requirements.
