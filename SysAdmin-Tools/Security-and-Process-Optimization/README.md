# 🔒 Security and Process Optimization Tools

## 📄 Overview
This folder contains scripts designed to enhance system security, enforce compliance, and optimize IT processes through automation.

---

## 📜 Script List and Descriptions

1. **Cleanup-Repository-ExpiredCertificates-Tool.ps1**  
   Detects and removes expired certificates from the repository, maintaining a secure and up-to-date certificate infrastructure.

2. **Initiate-MultipleRDPSessions.ps1**  
   Enables simultaneous RDP sessions to multiple servers, enhancing remote management.

3. **Organize-CERTs-Repository.ps1**  
   Organizes SSL/TLS certificates by issuer for better management and compliance.

4. **Purge-ExpiredInstalledCertificates-Tool.ps1**  
   Automates the selective removal of expired Certificate Authorities (CAs) to reduce security risks.

5. **Purge-ExpiredInstalledCertificates-viaGPO.ps1**  
   Removes expired Certificate Authorities across domain machines using Group Policy.

6. **Remove-EmptyFiles-or-DateRange.ps1**  
   Detects and removes empty files or files within a specified date range to optimize storage usage.

7. **Retrieve-Windows-ProductKey.ps1**  
   Retrieves Windows product keys from the registry to ensure licensing compliance.

8. **Shorten-LongFileNames-Tool.ps1**  
   Automatically shortens file names that exceed a specified length, preventing file system errors.

9. **Unjoin-ADComputer-and-Cleanup.ps1**  
   Unjoins computers from the domain and performs cleanup tasks, including DNS cache clearing and domain profile removal.

---

## 🔍 How to Use
Refer to the detailed instructions provided in each script header for setup and execution steps. Most scripts require administrative privileges to run.

---

## 🛠️ Prerequisites

1. **PowerShell Version:** Ensure PowerShell 5.1 or later is installed.  
2. **Administrator Rights:** Scripts require elevated permissions to perform operations.  
3. **Dependencies:** Check for required modules or system configurations as outlined in each script.

---

## 📣 Feedback and Contributions

For feedback or contributions, please open an issue or submit a pull request in the GitHub repository. Your collaboration is welcome!

---