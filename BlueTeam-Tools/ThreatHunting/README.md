# 🔵 BlueTeam-Tools - Threat Hunting Suite

## 📝 Overview

The **ThreatHunting Folder** houses a suite of **PowerShell scripts** specifically designed to bolster threat detection and reduce security risks within **Windows networks**. These tools automate essential tasks such as analyzing suspicious emails, purging expired certificates, and removing unauthorized shared resources, enabling administrators to maintain a secure and compliant infrastructure.

### Key Features:
- **User-Friendly GUI:** Intuitive graphical interfaces streamline operations.  
- **Detailed Logging:** Comprehensive `.log` files ensure operational transparency and simplify troubleshooting.  
- **Exportable Reports:** Outputs in `.csv` format facilitate integration with reporting tools.  
- **Proactive Security Management:** Automated tasks strengthen your network's security posture and enhance compliance.

---

## 🛠️ Prerequisites

Before running the scripts, ensure the following requirements are met:

1. **⚙️ PowerShell**
   - **Version Requirement:** PowerShell 5.1 or later is recommended.  
   - **Active Directory Module:** Use the following command to import if needed:  
     ```powershell
     Import-Module ActiveDirectory
     ```

2. **🔑 Administrator Privileges**
   - **Requirement:** Elevated permissions may be necessary to access system configurations, uninstall applications, or modify settings.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - **Installation:** Required for remote management of Active Directory, DNS, DHCP, and other server roles on Windows 10/11 workstations.

---

## 📄 Script Descriptions (Alphabetical Order)

1. **🗑️ Cleanup-Repository-ExpiredCertificates-Tool.ps1**  
   Detects and removes expired certificates from the certificate repository, ensuring your network’s certificates remain current and secure.

2. **🔍 Decipher-EML-MailMessages.ps1**  
   Decodes suspicious email content using techniques such as offset subtraction, encoding conversions, ROT13, and Caesar cipher brute force. A crucial tool for uncovering hidden threats in emails.

3. **🗑️ Purge-ExpiredInstalledCertificates-Tool.ps1**  
   Identifies and removes expired Certificate Authorities (CAs) to mitigate security risks and maintain an up-to-date certificate infrastructure.

4. **🗑️ Purge-ExpiredInstalledCertificates-viaGPO.ps1**  
   Automates the removal of expired Certificate Authorities across domain machines using Group Policy Objects (GPO), ensuring consistent and efficient management.

5. **📂 Remove-SharedFolders-and-Drives-viaGPO.ps1**  
   Automates the removal of unauthorized shared folders and drives across the network via GPO, ensuring compliance with data-sharing policies and reducing data leakage risks.

---

## 🚀 Usage Instructions

### General Steps:
1. **Run the Script:** Execute the desired script using the `Run With PowerShell` option.  
2. **Provide Inputs:** Follow on-screen prompts or configure parameters as required.  
3. **Review Outputs:** Examine `.log` files and, where applicable, `.csv` reports for results.

### Example Scenarios:

- **🗑️ Cleanup-Repository-ExpiredCertificates-Tool.ps1**  
   - Scan the repository for expired certificates and remove them.  
   - Logs provide a detailed record of removed certificates and any encountered issues.

- **🔍 Decipher-EML-MailMessages.ps1**  
   - Launch the script with administrator privileges.  
   - Input the email or string to decode.  
   - View decoding results in a readable format and check logs for detailed insights.

- **🗑️ Purge-ExpiredInstalledCertificates-Tool.ps1**  
   - Run the script to identify and remove expired Certificate Authorities.  
   - Check logs to verify which CAs were removed.

- **🗑️ Purge-ExpiredInstalledCertificates-viaGPO.ps1**  
   - Configure the GPO appropriately before running the script.  
   - Logs will record all actions for compliance verification.

- **📂 Remove-SharedFolders-and-Drives-viaGPO.ps1**  
   - Automate the removal of unauthorized shared folders and drives via GPO.  
   - Review logs for an audit trail of completed actions.

---

## 📝 Logging and Output

- **📄 Logs:** All scripts generate `.log` files with detailed information about actions taken, items modified or removed, and errors encountered.  
- **📊 Reports:** Scripts that produce `.csv` outputs provide actionable data for compliance and reporting.

---

## 💡 Tips for Optimization

- **Automate Execution:** Use task schedulers to periodically run scripts, ensuring consistent monitoring and compliance.  
- **Centralize Logs and Reports:** Store `.log` and `.csv` files in a shared location for collaborative analysis and auditing.  
- **Customize Scripts:** Adjust parameters and thresholds to align with your organization's specific security and compliance needs.
