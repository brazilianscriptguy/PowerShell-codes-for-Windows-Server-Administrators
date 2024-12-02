# ⚙️ System Configuration and Deployment Tools

## 📄 Overview
This folder includes scripts for deploying and configuring software, group policies, and other system settings, ensuring consistent and efficient management of workstations and servers.

---

## 📜 Script List and Descriptions

1. **Broadcast-ADUser-LogonMessage-viaGPO.ps1**  
   Displays customizable logon messages to users via GPO, facilitating communication across managed environments.  
   **Complementary File:**  
   - `Broadcast-ADUser-LogonMessage-viaGPO.hta`: A GUI file used to configure and preview the logon messages.

2. **Cleanup-WebBrowsers-Tool.ps1**  
   Removes cookies, cache, and other residual data from browsers and user profiles, improving performance and privacy.

3. **Clear-and-ReSyncGPOs-ADComputers.ps1**  
   Resets and re-synchronizes Group Policy Objects (GPOs) across domain computers to ensure consistent policy application.

4. **Copy-and-Sync-Folder-to-ADComputers-viaGPO.ps1**  
   Synchronizes folders from a network location to AD computers, ensuring only updated files are copied and outdated files removed.

5. **Deploy-FortiClientVPN-viaGPO.ps1**  
   Automates the deployment of FortiClient VPN software via GPO to support secure remote access.

6. **Deploy-FusionInventoryAgent-viaGPO.ps1**  
   Deploys the FusionInventory Agent to workstations, enabling inventory management and reporting.

7. **Deploy-KasperskyAV-viaGPO.ps1**  
   Installs and configures Kaspersky Endpoint Security and Network Agent on domain workstations using GPO.

8. **Deploy-PowerShell-viaGPO.ps1**  
   Simplifies the installation and update of PowerShell on domain workstations and servers via GPO.

9. **Deploy-ZoomWorkplace-viaGPO.ps1**  
   Automates the deployment of Zoom software on workstations using GPO for streamlined collaboration.

10. **Enhance-BGInfoDisplay-viaGPO.ps1**  
    Integrates BGInfo with GPO to display detailed system information on desktops.  
    **Complementary File:**  
    - `Enhance-BGInfoDisplay-viaGPO.bgi`: Configuration file for customizing BGInfo displays on desktops.

11. **Install-KMSLicensingServer-Tool.ps1**  
    Installs and configures a Key Management Service (KMS) Licensing Server within the AD forest.

12. **Install-RDSLicensingServer-Tool.ps1**  
    Configures a Remote Desktop Services (RDS) Licensing Server to manage client access licenses.

13. **Rename-DiskVolumes-viaGPO.ps1**  
    Renames disk volumes uniformly across workstations using GPO, improving disk management consistency.

14. **Reset-and-Sync-DomainGPOs-viaGPO.ps1**  
    Resets and synchronizes domain GPOs to maintain compliance and policy uniformity.

15. **Update-ADComputer-Winget-Explicit.ps1**  
    Updates software on workstations explicitly using the `winget` tool.

16. **Update-ADComputer-Winget-viaGPO.ps1**  
    Automates software updates across workstations via `winget` with GPO deployment.

17. **Remove-Softwares-NonCompliance-Tool.ps1**  
    Uninstalls unauthorized or non-compliant software on workstations to ensure adherence to policy.  
    **Complementary File:**  
    - `Remove-Softwares-NonCompliance-Tool.txt`: Configuration file listing the software to be uninstalled, with each application specified on a separate line.

---

## 🔍 How to Use
Each script includes detailed headers with usage instructions. Open the scripts in a PowerShell editor to review prerequisites, permissions, and execution steps. Use the complementary files as necessary to configure or enhance the script’s operation.

---

## 🛠️ Prerequisites

1. **PowerShell 5.1 or Later:** Required for script execution. Verify your version with `$PSVersionTable.PSVersion`.
2. **Administrative Privileges:** Necessary for deploying software and managing GPOs.
3. **Dependencies:** Check for required modules like `GroupPolicy` or system configurations as outlined in each script.

---

## 📄 Complementary Files Overview

1. **Broadcast-ADUser-LogonMessage-viaGPO.hta**  
   - Enables GUI-based configuration of logon messages for deployment via GPO.

2. **Enhance-BGInfoDisplay-viaGPO.bgi**  
   - Customizable configuration file for displaying system information on desktops.

3. **Remove-Softwares-NonCompliance-Tool.txt**  
   - Provides a list of software applications to be removed using the associated script.

---

## 📣 Feedback and Contributions
For feedback or to contribute, submit an issue or pull request on the GitHub repository. Your suggestions and improvements are always welcome!

---