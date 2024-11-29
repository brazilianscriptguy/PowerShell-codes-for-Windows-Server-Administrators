# 🔵 BlueTeam-Tools - Incident Response Suite

## 📝 Overview

The **IncidentResponse Folder** contains a suite of **PowerShell scripts** designed to streamline **incident response** activities within **Active Directory (AD)** and **Windows Server** environments. These tools assist administrators in managing security incidents effectively, automating cleanup processes, and maintaining system integrity during and after incidents.

### Key Features:
- **User-Friendly GUI:** Enhances ease of use with an intuitive interface.  
- **Detailed Logging:** All scripts generate `.log` files for comprehensive tracking and troubleshooting.  
- **Exportable Reports:** Outputs in `.csv` format facilitate integration with reporting tools and audits.  
- **Streamlined Incident Management:** Automates tasks to minimize downtime and maximize system recovery efficiency.

---

## 🛠️ Prerequisites

Ensure the following requirements are met before running the scripts:

1. **⚙️ PowerShell**
   - PowerShell must be enabled on your system.  
   - The following module may need to be imported where applicable:  
     - **Active Directory:** `Import-Module ActiveDirectory`

2. **🔑 Administrator Privileges**
   - Scripts may require elevated permissions to access sensitive configurations, modify AD objects, or manage server roles.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - RSAT must be installed on your Windows 10/11 workstation to enable remote management of AD and server functions.

---

## 📄 Script Descriptions (Alphabetical Order)

1. **🧹 Cleanup-MetaData-ADForest-Tool.ps1**  
   Automates the cleanup of the AD forest by removing orphaned objects, synchronizing Domain Controllers, and managing unnecessary CNs. This script is essential for maintaining a secure and optimized AD environment after incidents.

2. **🧼 Cleanup-WebBrowsers-Tool.ps1**  
   Removes cookies, cache, session data, browsing history, and other residual files from popular web browsers (Firefox, Chrome, Edge, Internet Explorer) and applications like WhatsApp. It also performs general system cleanup tasks across all user profiles.

3. **🗑️ Delete-FilesByExtension-Bulk.ps1**  
   Facilitates bulk deletion of files based on their extensions, aiding in the removal of unwanted or harmful files during incident response and cleanup efforts.

   **📑 Delete-FilesByExtension-Bulk.txt**  
      - A configuration text file used by the **Delete-FilesByExtension-Bulk.ps1** script. It specifies the file extensions to target for deletion, allowing administrators to customize the cleanup process.

---

## 🚀 Usage Instructions

### General Steps:
1. **Run the Script:** Launch the desired script using the `Run With PowerShell` option.  
2. **Provide Inputs:** Follow the on-screen prompts or customize configuration files as required.  
3. **Review Outputs:** Check generated `.log` files and, where applicable, `.csv` reports for results.

### Example Scenarios:

- **🧹 Cleanup-MetaData-ADForest-Tool.ps1**  
   - Run the script with administrative privileges.  
   - Use the GUI to select options for synchronizing Domain Controllers, cleaning up orphaned objects, and managing unnecessary CNs.  
   - Review logs for a detailed record of actions taken.

- **🧼 Cleanup-WebBrowsers-Tool.ps1**  
   - Execute the script to clean residual data such as cookies and cache from web browsers.  
   - Ensure all user profiles are cleaned, enhancing privacy and reducing residual vulnerabilities.  
   - Logs document the cleanup process for auditing purposes.

- **🗑️ Delete-FilesByExtension-Bulk.ps1**  
   - Open the **Delete-FilesByExtension-Bulk.txt** file and specify the file extensions to target.  
   - Run the script to delete files in bulk based on the defined extensions.  
   - Logs provide details on the deleted files and any issues encountered.

---

## 📝 Logging and Output

- **📄 Logs:** Each script generates `.log` files, detailing the steps performed, items modified or removed, and any errors encountered.  
- **📊 Reports:** Scripts export data in `.csv` format, enabling streamlined analysis and reporting.

---

## 💡 Tips for Optimization

- **Automate Execution:** Use task schedulers to deploy scripts periodically, ensuring consistent incident response and cleanup.  
- **Centralize Logs and Reports:** Store `.log` and `.csv` files in a shared location for collaborative analysis and audits.  
- **Customize Configuration Files:** Tailor the cleanup processes by modifying configuration files (e.g., `Delete-FilesByExtension-Bulk.txt`) to align with your organization’s policies.
