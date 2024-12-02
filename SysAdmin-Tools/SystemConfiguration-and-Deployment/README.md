# ⚙️ System Configuration and Deployment Tools

## 📄 Overview
This folder includes a collection of PowerShell scripts for deploying and configuring software, group policies, and system settings, ensuring consistent and efficient management of workstations and servers in Active Directory (AD) environments.

---

## 📜 Script List and Descriptions

1. **Broadcast-ADUser-LogonMessage-viaGPO.ps1**  
   Displays customizable logon messages to users via Group Policy Object (GPO), facilitating communication across managed environments.  
   **Complementary File:**  
   - `Broadcast-ADUser-LogonMessage-viaGPO.hta`: A GUI file for configuring and previewing the logon messages.

2. **Cleanup-WebBrowsers-Tool.ps1**  
   Thoroughly removes cookies, cache, session data, history, and other residual files from web browsers (e.g., Firefox, Chrome, Edge) and WhatsApp, improving system performance and privacy.

3. **Clear-and-ReSyncGPOs-ADComputers.ps1**  
   Resets and re-synchronizes Group Policy Objects (GPOs) across domain computers to ensure consistent policy application.

4. **Copy-and-Sync-Folder-to-ADComputers-viaGPO.ps1**  
   Synchronizes folders from a network location to AD computers, ensuring only updated files are copied while outdated files are removed. Full logging is included for traceability.

5. **Deploy-FortiClientVPN-viaGPO.ps1**  
   Automates the deployment of FortiClient VPN software via GPO to support secure remote access. Handles version checks, uninstalling outdated versions, and configuring VPN tunnels.

6. **Deploy-FusionInventoryAgent-viaGPO.ps1**  
   Deploys the FusionInventory Agent to workstations for seamless inventory management and reporting.

7. **Deploy-KasperskyAV-viaGPO.ps1**  
   Automates the installation and configuration of Kaspersky Endpoint Security (KES) and Network Agent on domain workstations using GPO. Includes MSI validation and version management.

8. **Deploy-PowerShell-viaGPO.ps1**  
   Simplifies the deployment of PowerShell to workstations and servers via GPO. Ensures proper version checks, uninstalls older versions, and installs updates as needed.

9. **Deploy-ZoomWorkplace-viaGPO.ps1**  
   Automates the deployment of Zoom software on workstations via GPO for streamlined collaboration.

10. **Enhance-BGInfoDisplay-viaGPO.ps1**  
    Integrates BGInfo with GPO to display critical system information on desktops.  
    **Complementary File:**  
    - `Enhance-BGInfoDisplay-viaGPO.bgi`: Configuration file for customizing BGInfo desktop displays.

11. **Install-KMSLicensingServer-Tool.ps1**  
    Installs and configures a Key Management Service (KMS) Licensing Server in an AD forest. Includes a GUI for ease of use and standardized logging.

12. **Install-RDSLicensingServer-Tool.ps1**  
    Configures a Remote Desktop Services (RDS) Licensing Server to manage client access licenses (CALs). Includes error handling and detailed logs for compliance.

13. **Rename-DiskVolumes-viaGPO.ps1**  
    Renames disk volumes uniformly across workstations using GPO, improving consistency in disk management.

14. **Reset-and-Sync-DomainGPOs-viaGPO.ps1**  
    Resets and re-synchronizes domain GPOs to maintain compliance and uniform policy application across workstations.

15. **Retrieve-LocalMachine-InstalledSoftwareList.ps1**  
    Audits installed software across Active Directory computers, generating detailed reports to verify compliance with software policies.

16. **Remove-SharedFolders-and-Drives-viaGPO.ps1**  
    Removes unauthorized shared folders and drives using GPO, ensuring data-sharing compliance and mitigating data breach risks.

17. **Remove-Softwares-NonCompliance-Tool.ps1**  
    Uninstalls non-compliant or unauthorized software on workstations to ensure adherence to organizational policies.  
    **Complementary File:**  
    - `Remove-Softwares-NonCompliance-Tool.txt`: A configuration file listing the software to be uninstalled.

18. **Remove-Softwares-NonCompliance-viaGPO.ps1**  
    Enforces software compliance by removing unauthorized applications via GPO across domain machines.

19. **Uninstall-SelectedApp-Tool.ps1**  
    Provides a GUI for selecting and uninstalling unwanted applications, automating software removal with minimal manual intervention.

20. **Update-ADComputer-Winget-Explicit.ps1**  
    Updates software on workstations explicitly using the `winget` tool, ensuring that systems run the latest software versions.

21. **Update-ADComputer-Winget-viaGPO.ps1**  
    Automates software updates across workstations using `winget` with deployment managed via GPO.

---

## 🔍 How to Use
Each script includes detailed headers with usage instructions. Open the scripts in a PowerShell editor to review prerequisites, permissions, and execution steps. Use the complementary files as necessary to configure or enhance the script’s operation.

---

## 🛠️ Prerequisites

1. **PowerShell 5.1 or Later:** Required for script execution. Verify your version with:  
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. **Administrative Privileges:** Necessary for deploying software, managing GPOs, and accessing sensitive configurations.

3. **Dependencies:** Ensure the required modules, such as `GroupPolicy`, are installed and available.

---

## 📄 Complementary Files Overview

1. **Broadcast-ADUser-LogonMessage-viaGPO.hta**  
   - A GUI-based tool for configuring and previewing logon messages for deployment via GPO.

2. **Enhance-BGInfoDisplay-viaGPO.bgi**  
   - Customizable configuration file for enriching desktop displays with BGInfo.

3. **Remove-Softwares-NonCompliance-Tool.txt**  
   - A plain text file listing unauthorized software to be uninstalled by the associated script.

---

## 📣 Feedback and Contributions
Feedback and contributions are welcome! If you have suggestions, encounter issues, or want to add new features, submit an issue or pull request on the GitHub repository.  

---
