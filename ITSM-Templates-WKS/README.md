# 🖥️ Efficient Workstation Management, Configuration, and ITSM Compliance on Windows 10 and 11

## 📄 Description

This repository contains a curated collection of VBScript and PowerShell tools specifically designed to streamline the management and configuration of Windows 10 and 11 workstations within an IT Service Management (ITSM) framework. These tools automate essential administrative tasks, enabling IT professionals to enhance workflows, ensure consistency, and maintain compliance across the organization.

✨ **Key Features**:
- **Graphical User Interfaces (GUI)** for user-friendly operation.  
- **Comprehensive `.log` Files** for transparent process tracking.  
- **Export to `.csv`** for streamlined reporting and auditing.

---

## 📄 Overview

The **Check-List for Applying ITSM-Templates-WKS** defines a standardized approach to configuring workstations and printers, promoting compliance, operational efficiency, and secure deployment.

### **Objectives**:
- Enhance service quality and user satisfaction.  
- Strengthen IT governance and risk management.  
- Ensure operational efficiency and continuity.

---

## 📋 Steps to Use ITSM-Templates-WKS Scripts

Follow these steps for effective deployment of the `ITSM-Templates-WKS` scripts:

1. **Clone the Repository**:  
   - Clone the `ITSM-Templates-WKS` folder to your network’s **Definitive Media Library (DML)**. This ensures centralized storage and easy accessibility for deployment across the organization.

2. **Deploy Locally to Workstations**:  
   - Copy the `ITSM-Templates-WKS` folder from the DML to the `C:\` drive of each workstation requiring configuration. Running scripts locally ensures efficient execution and reduces dependency on network connectivity.

3. **Maintain an Updated DML**:  
   - Regularly update the DML repository with the latest version of the ITSM-Templates-WKS folder. This ensures all scripts, templates, and configurations align with current organizational standards.

4. **Standardize Local Administrative Privileges**:  
   - Limit each workstation to **one local administrative account** with elevated privileges.  
   - Perform all configurations and management tasks using this designated account to ensure consistency and reduce security risks.

5. **Follow the Checklist**:  
   - Refer to the `Check-List for Applying ITSM-Templates on Windows 10 and 11 Workstations.pdf` for detailed, step-by-step guidance.

6. **Customize Scripts**:  
   - Adjust `.vbs` and `.reg` scripts to suit specific organizational requirements.

7. **Personalize Workstation Appearance**:  
   - Use files in the `C:\ITSM-Templates-WKS\CustomImages\` folder to customize wallpapers and user profiles.  
   - Update themes and layouts using the `C:\ITSM-Templates-WKS\ModifyReg\UserDesktopTheme\` folder.

By following these steps, IT professionals can effectively implement ITSM standards while maintaining efficient, compliant, and secure workstation environments.

---

## 📂 ITSM-Templates-WKS Folder Structure and Scripts

### **Folder Descriptions**:
- **Certificates**: Trusted root certificates for secure network communication.  
- **CustomImages**: Default wallpapers and user profile images.  
- **MainDocs**: Editable documentation, including the `Check-List for Applying ITSM-Templates on Windows 10 and 11 Workstations.docx`.  
- **ModifyReg**: Registry configuration scripts for initial setup.  
- **PostIngress**: Scripts executed after domain joining to finalize configurations.  
- **ScriptsAdditionalSupport**: Tools for troubleshooting and resolving workstation configuration issues.  
- **UniqueScripts**: Comprehensive scripts for registry and VBScript configurations.

---

### **Key Scripts**

The two main scripts, located in `C:\ITSM-Templates-WKS\UniqueScripts\`, prepare workstations for domain integration by automating critical configurations:

#### **1. ITSM-DefaultVBSing.vbs**  
*Note: Right-click the script and select "Run with Command Prompt."*  
This script automates ten (10) key configurations to standardize workstation settings and prepare the environment for domain integration:  

1. **Disable-Windows-Firewall.vbs**: Disables the Windows Firewall.  
2. **Grant-Full-Access-Gestor.vbs**: Grants access to the Manager account.  
3. **Renew-all-IP-Connections.vbs**: Renews all TCP/IP connections.  
4. **WSUS-Certificate-Install.vbs**: Installs the WSUS certificate for update management.  
5. **WSUS-Clean-SID.vbs**: Cleans residual WSUS connections.  
6. **CopyDefaultFolders.vbs**: Copies default desktop folders and XML profiles for Start menu and desktop appearance.  
7. **CopyHosts.vbs**: Updates the hosts file to secure network connections before antivirus installation.  
8. **CopyUserLogo.vbs**: Copies standardized user profile images.  
9. **CopyWallPaperDefault.vbs**: Applies the default desktop wallpaper.  
10. **CopyLogonBackground.vbs**: Updates the default lock screen image.

#### **2. ITSM-ModifyREGing.vbs**  
*Note: Right-click the script and select "Run with Command Prompt."*  
This script applies ten (10) registry modifications to align the workstation configuration with organizational standards:  

1. **AddStartPageADM.reg**: Sets the default browser start page.  
2. **DisableUAC-LUA.reg**: Disables User Account Control (UAC) for streamlined administration.  
3. **Enable-AutoShareAdmin.reg**: Enables administrative shares.  
4. **Register-Owner.reg**: Customizes COMPANY information in the Windows license.  
5. **Win10_Domain-Ingress.reg**: Configures secure domain-sharing settings.  
6. **WSUS-App-Intranet.reg**: Points to the corporate WSUS server for updates.  
7. **DesktopCurrent.reg**: Configures the current user’s desktop settings.  
8. **DesktopDefault.reg**: Applies default desktop settings for new users.  
9. **EnableCustomLogonBackgrounds.reg**: Enables custom lock screen wallpapers.  
10. **ITSM-GSTI-Templates.deskthemepack**: Applies the COMPANY-standard desktop theme.

---

### **PostIngress Scripts**

Located in `C:\ITSM-Templates-WKS\PostIngress\`, these scripts finalize critical domain-related configurations:

1. **ITSM-NewDNSRegistering.vbs**:  
   Updates the workstation’s hostname and domain details in Active Directory DNS servers for accurate registration.

2. **ITSM-ProfileImprinting.vbs**:  
   Registers user domain profiles after three login cycles, ensuring adherence to organizational policies and maintaining profile consistency.

---

### **ScriptsAdditionalSupport**

Located in `C:\ITSM-Templates-WKS\ScriptsAdditionalSupport\`, these scripts resolve workstation configuration inconsistencies and enhance troubleshooting:

- **ActivateAllAdminShare**: Enables administrative shares, activates RDP, disables Windows Firewall, and deactivates Windows Defender.  
- **ExportCustomThemesFiles**: Exports customized desktop themes.  
- **FixPrinterDriverIssues**: Resets printer drivers and clears the print spooler.  
- **GetSID**: Retrieves Security Identifiers (SIDs) using Sysinternals tools.  
- **InventoryInstalledSoftwareList**: Inventories installed software for compliance.  
- **LegacyWorkstationIngress**: Enables legacy systems to join modern domains.  
- **RecallKESCert**: Updates antivirus certificates.  
- **RenameDiskVolumes**: Renames local C: and D: disk volumes.  
- **ResyncGPOsDataStore**: Resets and synchronizes workstation GPOs.  
- **UnjoinADComputer-and-Cleanup**: Unjoins a workstation from a domain and clears residual domain data.  
- **WorkStationConfigReport**: Creates detailed workstation configuration reports in `.csv` format.  
- **WorkstationTimeSync**: Synchronizes time, date, and time zone with the domain.

---

## 🚀 Next Releases

Future updates will include new tools to address evolving ITSM requirements and enhance IT service delivery capabilities.

---

## 📝 Logging and Output

- **Logging**: Scripts generate `.log` files that document execution processes and errors.  
- **Export Functionality**: Results are exported in `.csv` format for audits and reporting.

---

## 📄 Log File Locations

Logs are stored in `C:\ITSM-Logs-WKS\` and include:
- DNS registration logs.  
- User profile imprinting logs.  
- Domain join/removal logs.

---

## 🔗 References

- [ITSM-Templates-WKS GitHub Repository](https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators)

---

### **Document Classification**  
This document is **RESTRICTED** for internal use within the Company’s network.  
