# 🖥️ Efficient Workstation Management, Configuration, and ITSM Compliance on Windows 10 and 11

## 📄 Description

This repository contains a curated collection of VBScripts and PowerShell scripts specifically designed to streamline the management and configuration of Windows 10 and 11 workstations within an IT Service Management (ITSM) framework. These tools automate essential administrative tasks, enabling IT professionals to enhance workflows, ensure consistency, and maintain compliance across the organization.

✨ **Key Features**:
- **Graphical User Interfaces (GUI)** for intuitive operation.
- **Comprehensive `.log` Files** for transparent process tracking.
- **Export to `.csv`** for streamlined reporting and auditing.

---

## 📄 Overview

The **Check-List for Applying ITSM-Templates-WKS** establishes a structured approach for configuring workstations and printers, promoting compliance, operational efficiency, and secure deployment.

### **Objectives**:
- Enhance service quality and customer satisfaction.
- Strengthen IT governance and risk management.
- Ensure operational efficiency and continuity.

---

## 📋 Steps to Use ITSM-Templates-WKS Scripts

To effectively deploy and utilize the `ITSM-Templates-WKS` scripts, follow these steps:

1. **Clone the Repository**:
   - Clone the `ITSM-Templates-WKS` folder to your network’s **Definitive Media Library (DML)** for centralized storage. This ensures the repository is easily accessible across the network for consistent deployment.

2. **Deploy Locally to Workstations**:
   - Each operator must copy the `ITSM-Templates-WKS` folder from the DML to the `C:\` drive of each workstation requiring configuration. Running scripts locally reduces dependency on network connectivity and ensures efficient execution.

3. **Maintain an Updated DML**:
   - Regularly update the DML repository with the latest version of the ITSM-Templates-WKS folder. This ensures all configurations align with the most current scripts, templates, and organizational standards.

4. **Standardize Local Administrative Privileges**:
   - Limit workstations to **one local administrative account** with elevated privileges.
   - Perform all configurations and management tasks using this designated account to maintain consistency, simplify troubleshooting, and reduce security risks.

5. **Follow the Checklist**:
   - Refer to the `Check-List for Applying ITSM-Templates on Windows 10 and 11 Workstations.pdf` in the main folder for detailed guidance.

6. **Customize Scripts**:
   - Adjust `.vbs` and `.reg` scripts to fit specific organizational needs.

7. **Personalize Workstation Appearance**:
   - Use files in the `C:\ITSM-Templates-WKS\CustomImages\` folder to customize workstation visuals.
   - Modify desktop themes and layouts in the `C:\ITSM-Templates-WKS\ModifyReg\UserDesktopTheme\` folder.

By following these steps, IT professionals can ensure the effective implementation of ITSM standards while maintaining an efficient and secure workstation environment.

---

## 📂 ITSM-Templates-WKS Folder Structure and Scripts

### **Folder Descriptions**:
- **Certificates**: Trusted root certificates for secure network communication.
- **CustomImages**: Default desktop wallpapers and user profile images.
- **MainDocs**: Stores the editable document `Check-List for Applying ITSM-Templates on Windows 10 and 11 Workstations.docx`, allowing for tailored modifications.
- **ModifyReg**: Registry configuration scripts for initial setup.
- **PostIngress**: Scripts executed after domain joining to finalize configurations.
- **ScriptsAdditionalSupport**: Tools for resolving workstation configuration issues.
- **UniqueScripts**: Comprehensive scripts for registry and VBS configurations.

### **Key Scripts**

#### **ITSM-DefaultVBSing.vbs**
Located in `C:\ITSM-Templates-WKS\UniqueScripts\`, this script:
1. Installs certificates for secure network communication.
2. Applies standardized wallpapers and user profile settings.
3. Renews IP configurations for seamless network integration.
4. Disables Windows Firewall to align with organizational policies.
5. Configures the WSUS server for system updates.

#### **ITSM-ModifyREGing.vbs**
Located in `C:\ITSM-Templates-WKS\UniqueScripts\`, this script applies critical registry settings, including:
1. Configuring default browser homepages.
2. Enabling administrative shares for remote management.
3. Disabling User Account Control (UAC) for simplified administration.
4. Standardizing desktop themes.

---

### **PostIngress Scripts**

Located in `C:\ITSM-Templates-WKS\PostIngress\`, these scripts finalize domain-related configurations:

1. **ITSM-NewDNSRegistering.vbs**:  
   Updates the workstation's hostname and domain details in Active Directory DNS servers for accurate registration.

2. **ITSM-ProfileImprinting.vbs**:  
   Registers user domain profiles after three login cycles to enforce organizational policies and profile consistency.

---

### **ScriptsAdditionalSupport**

Located in `C:\ITSM-Templates-WKS\ScriptsAdditionalSupport\`, these scripts address configuration inconsistencies:

- **ActivateAllAdminShare**: Enables administrative shares, activates RDP, disables Windows Firewall, and deactivates Windows Defender.  
- **ExportCustomThemesFiles**: Exports customized desktop themes.  
- **FixPrinterDriverIssues**: Resets printer drivers and clears the print spooler.  
- **GetSID**: Retrieves Security Identifiers (SIDs) using Sysinternals tools.  
- **InventoryInstalledSoftwareList**: Generates an inventory of installed software for compliance.  
- **LegacyWorkstationIngress**: Allows legacy systems to join modern domains.  
- **RecallKESCert**: Updates antivirus certificates.  
- **RenameDiskVolumes**: Renames C: and D: disk volumes locally.  
- **ResyncGPOsDataStore**: Resets and synchronizes workstation GPOs.  
- **UnjoinADComputer-and-Cleanup**: Removes a workstation from a domain and clears residual domain data.  
- **WorkStationConfigReport**: Creates detailed workstation configuration reports in `.csv` format.  
- **WorkstationTimeSync**: Synchronizes time, date, and time zone with the domain.

---

## 🚀 Next Releases

Future updates will include new tools to address evolving ITSM requirements and enhance IT service delivery capabilities.

---

## 📝 Logging and Output

- **Logging**: Detailed `.log` files record all execution processes and errors.  
- **Export Functionality**: Results are exported in `.csv` format for auditing and compliance reporting.

---

## 📄 Log File Locations

Logs are saved in `C:\ITSM-Logs-WKS\`, including:
- DNS registration logs.  
- User profile imprinting logs.  
- Domain join/removal logs.

---

## 🔗 References

- [ITSM-Templates-WKS GitHub Repository](https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators)

---

### **Document Classification**  
This document is **RESTRICTED** for internal use within the Company’s network.
