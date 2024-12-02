# 🔵 BlueTeam-Tools - Threat Hunting Suite

## 📝 Overview

The **ThreatHunting Folder** contains a suite of **PowerShell scripts** designed to enhance threat detection and mitigate security risks within **Windows networks**. These tools automate critical tasks, such as analyzing suspicious emails, purging expired certificates, and removing unauthorized shared resources, helping administrators maintain a secure and compliant infrastructure.

### Key Features:
- **User-Friendly GUI:** Simplifies user interaction for efficient operation.
- **Detailed Logging:** All scripts generate `.log` files for operational transparency and troubleshooting.
- **Exportable Reports:** Scripts export data in `.csv` format for easy integration with reporting tools.
- **Proactive Security Management:** Automates tasks to improve your network's security posture and compliance.

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

1. **🔍 Decipher-EML-MailMessages.ps1**  
   Decodes suspicious email content using techniques such as offset subtraction, encoding conversions, ROT13, and Caesar cipher brute force. This script is invaluable for uncovering hidden threats in email messages.

2. **🗑️ Purge-ExpiredCAs-Explicitly.ps1**  
   Selectively removes expired Certificate Authorities (CAs) from the system to reduce security risks and maintain a secure certificate infrastructure.

3. **🗑️ Purge-ExpiredCAs-viaGPO.ps1**  
   Automates the removal of expired Certificate Authorities across domain machines using Group Policy Objects (GPO), ensuring consistent and efficient certificate management.

4. **🗑️ Cleanup-Repository-ExpiredCertificates-Tool.ps1**  
   Detects and removes expired certificates from the certificate repository, ensuring your network’s certificates remain up to date and secure.

5. **📂 Remove-SharedFolders-and-Drives-viaGPO.ps1**  
   Removes unauthorized shared folders and drives across the network using GPOs, ensuring compliance with data-sharing policies and reducing the risk of data leaks.

---

## 🚀 Usage Instructions

### General Steps:
1. **Run the Script:** Launch the desired script using the `Run With PowerShell` option.  
2. **Provide Inputs:** Follow on-screen prompts or specify parameters as required.  
3. **Review Outputs:** Check generated `.log` files and, where applicable, `.csv` reports for results.

### Example Scenarios:

- **🔍 Decipher-EML-MailMessages.ps1**  
   - Run the script with administrative privileges.  
   - Specify the email or string to decode. The script applies decoding techniques and presents the results in a readable format.  
   - Logs detail the decoding process and findings for further analysis.

- **🗑️ Purge-ExpiredCAs-Explicitly.ps1**  
   - Execute the script to identify and remove expired CAs from the system.  
   - Review logs to confirm which CAs were removed and ensure successful operation.

- **🗑️ Purge-ExpiredCAs-viaGPO.ps1**  
   - Ensure GPO is properly configured.  
   - Run the script to remove expired CAs across domain machines.  
   - Logs provide a record of removed CAs for compliance verification.

- **🗑️ Cleanup-Repository-ExpiredCertificates-Tool.ps1**  
   - Scan and remove expired certificates from the repository.  
   - Logs list all removed certificates and document any issues encountered.

- **📂 Remove-SharedFolders-and-Drives-viaGPO.ps1**  
   - Use GPO to automate the removal of unauthorized shared folders and drives.  
   - Logs detail the actions taken, providing an audit trail for compliance.

---

## 📝 Logging and Output

- **📄 Logs:** Each script generates `.log` files, detailing the steps performed, items modified or removed, and any errors encountered.  
- **📊 Reports:** Scripts that export `.csv` files provide actionable data for compliance verification and reporting.

---

## 💡 Tips for Optimization

- **Automate Execution:** Schedule scripts to run periodically using task schedulers, ensuring consistent security monitoring and compliance.  
- **Centralize Logs and Reports:** Store `.log` and `.csv` files in a shared location for collaborative analysis and auditing.  
- **Customize Scripts:** Adjust script parameters and thresholds to align with your organization’s specific security and compliance needs.
