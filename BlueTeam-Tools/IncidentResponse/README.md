# 🔵 BlueTeam-Tools - Incident Response Suite

## 📝 Overview

The **IncidentResponse Folder** provides a suite of **PowerShell scripts** designed to streamline **incident response** activities in **Active Directory (AD)** and **Windows Server** environments. These tools help administrators handle security incidents effectively, automate cleanup processes, and ensure system integrity during and after incidents.

---

## 🔑 Key Features

- **User-Friendly GUI:** Simplifies usage with intuitive interfaces.  
- **Detailed Logging:** Generates `.LOG` files for thorough tracking and troubleshooting.  
- **Exportable Reports:** Outputs in `.CSV` format for easy reporting and integration with audits.  
- **Enhanced Incident Management:** Automates critical response tasks to reduce downtime and accelerate system recovery.

---

## 🛠️ Prerequisites

Before running the scripts, ensure the following requirements are met:

1. **⚙️ PowerShell**
   - PowerShell must be enabled on your system.  
   - Import the required module where applicable:  
     - **Active Directory:** `Import-Module ActiveDirectory`

2. **🔑 Administrator Privileges**
   - Elevated permissions may be needed to modify AD objects, manage server roles, or access sensitive configurations.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - Install RSAT on your Windows 10/11 workstation for managing AD and server functions remotely.

---

## 📄 Script Descriptions (Alphabetical Order)

1. **🔍 Decipher-EML-MailMessages-Tool.ps1**  
   - **Purpose:** Decodes suspicious email messages using techniques like offset subtraction, encoding conversions, ROT13, and Caesar cipher brute force.  
   - **Output:** Analyzes and identifies hidden threats in email content.

2. **🗑️ Delete-FilesByExtension-Tool.ps1**  
   - **Purpose:** Deletes files in bulk based on specified extensions, ideal for post-incident cleanup or routine maintenance.  
   - **Complementary File:**  
     - **Delete-FilesByExtension-List.txt**: Lists file extensions to target for deletion. Modify this file to customize cleanup parameters.

---

## 🚀 Usage Instructions

### General Steps:
1. **Run the Script:** Right-click and select `Run With PowerShell`.  
2. **Provide Inputs:** Follow on-screen prompts or update configuration files as necessary.  
3. **Review Outputs:** Check the `.LOG` files for a summary of actions and results.

### Example Scenarios:

- **🔍 Decipher-EML-MailMessages-Tool.ps1**  
   - Use the script to decode suspicious email messages, identifying hidden threats or harmful content.  
   - Analyze the logs for detailed decoding steps and results.

- **🗑️ Delete-FilesByExtension-Tool.ps1**  
   - Update `Delete-FilesByExtension-List.txt` to specify extensions for deletion (e.g., `.tmp`, `.bak`).  
   - Run the script to delete files in bulk from targeted directories.  
   - Review the generated log to verify file removal and identify any issues.

---

## 📝 Logging and Output

- **📄 Logs:** Each script generates `.LOG` files that detail execution steps, actions taken, and errors encountered.  
- **📊 Reports:** Some scripts output data in `.CSV` format, offering insights for audits and compliance reporting.

---

## 💡 Tips for Optimization

- **Automate Execution:** Use task schedulers to run scripts regularly for consistent incident response and cleanup.  
- **Centralize Logs and Reports:** Store `.LOG` and `.CSV` files in a shared location to facilitate collaborative analysis.  
- **Customize Configurations:** Modify configuration files (e.g., `Delete-FilesByExtension-Bulk.txt`) to align with organizational policies and specific incident response needs.

---

## 🎯 Contributions and Feedback

For improvements, suggestions, or bug reports, submit an issue or pull request on GitHub. Collaborative contributions are encouraged to enhance the effectiveness of these tools!
