# 🔵 BlueTeam-Tools - Malicious Process Detection Suite

## 📝 Overview

The **MaliciousProcessDetection Folder** contains a collection of **PowerShell scripts** tailored to detect and remove **malicious processes** and unauthorized applications within **Windows environments**. These tools automate the uninstallation of suspicious software, enhancing system integrity, ensuring compliance, and strengthening overall security.

### Key Features:
- **User-Friendly GUI:** Simplifies user interaction for efficient operation.
- **Detailed Logging:** All scripts generate `.LOG` files for operational transparency and troubleshooting.
- **Exportable Reports:** Outputs in `.CSV` format for seamless integration with reporting tools.
- **Proactive Software Compliance:** Automates the removal of non-compliant applications, reducing vulnerabilities and enhancing security.

---

## 🛠️ Prerequisites

Before using the scripts in this folder, ensure the following prerequisites are met:

1. **⚙️ PowerShell**
   - PowerShell must be enabled on your system.
   - The following modules may need to be imported where applicable:
     - **Active Directory:** `Import-Module ActiveDirectory`
     - **DHCP:** `Import-Module DHCPServer`

2. **🔑 Administrator Privileges**
   - Scripts may require elevated permissions to access sensitive configurations, uninstall applications, or modify system settings.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - Install RSAT on your Windows 10/11 workstation to enable remote management of Active Directory, DNS, DHCP, and other server roles.

---

## 📄 Script Descriptions (Alphabetical Order)

### **1. Remove-EmptyFiles-or-DateRange.ps1**
   Detects and removes empty files or files within a specified date range, optimizing file storage and maintaining system organization.

### **2. 🛡️ Remove-Softwares-NonCompliance-Tool.ps1**  
   Automates the uninstallation of multiple software applications based on a `.TXT` configuration file. Logs every action performed, handles errors gracefully, and provides an efficient solution for bulk software removal.

   **Additional Files:**  
   - **Softwares-NonCompliance-List.txt**:  
     Serves as a configuration file for the script. Each application to be uninstalled must be listed on a separate line to ensure targeted and precise uninstallation.

### **3. 🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   Enforces software compliance by removing non-compliant or unauthorized applications via Group Policy Objects (GPO). Automates removal across multiple machines, reducing vulnerabilities.

### **4. 🗑️ Uninstall-SelectedApp-Tool.ps1**  
   Provides a user-friendly GUI for selecting and uninstalling applications directly from workstations. Detects and removes unwanted or malicious software with minimal manual intervention, ensuring effective removal.

---

## 🚀 Usage Instructions

### General Steps:
1. **Run the Script:** Launch the desired script using the `Run With PowerShell` option.  
2. **Provide Inputs:** Follow on-screen prompts or specify parameters as required.  
3. **Review Outputs:** Check generated `.LOG` files and, where applicable, `.CSV` reports for results.

### Example Scenarios:

- **Remove-EmptyFiles-or-DateRange.ps1**  
   - Run the script and specify the target directory and file criteria (empty or within a specific date range).  
   - The script removes matching files and logs all actions for review.

- **🛡️ Remove-Softwares-NonCompliance-Tool.ps1**  
   - Open **Softwares-NonCompliance-List.txt** and list the names of applications to uninstall (one per line).  
   - Run the script with administrative privileges.  
   - Automatically uninstalls listed applications, logs actions, and gracefully handles errors.  
   - Review the `.LOG` file for detailed uninstallation reports.

- **🚫 Remove-Softwares-NonCompliance-viaGPO.ps1**  
   - Deploy the script via a GPO to uninstall unauthorized software across multiple systems.  
   - Logs confirm uninstallation processes and ensure compliance.

- **🗑️ Uninstall-SelectedApp-Tool.ps1**  
   - Run the script to launch the GUI.  
   - Select application(s) to uninstall from the displayed list.  
   - Confirm and proceed with the uninstallation.  
   - Logs document the removed applications and any issues encountered.

---

## 📝 Logging and Output

- **📄 Logs:** Each script generates detailed logs in `.LOG` format, documenting all actions performed and errors encountered.  
- **📊 Reports:** Outputs in `.CSV` format provide actionable insights for auditing and reporting.

---

## 💡 Tips for Optimization

- **Automate Execution:** Use task schedulers to deploy scripts periodically for consistent software compliance.  
- **Centralize Logs and Reports:** Store `.LOG` and `.CSV` files in a shared location for collaborative analysis and audits.  
- **Customize to Policies:** Tailor scripts and configuration files to align with your organization's specific compliance requirements.
