### 🖥️ Efficient Workstation Management, Configuration, and ITSM Compliance on Windows 10 and 11

## 📄 Description

This repository offers a curated collection of `.vbs` and PowerShell scripts designed to streamline the management and configuration of Windows 10 and 11 workstations within an IT Service Management (ITSM) framework. These scripts automate essential administrative tasks, empowering IT professionals to optimize workflows and ensure consistent workstation configurations across the organization.

✨ **Key Features**:
- **Graphical User Interfaces (GUI)** for intuitive interaction.
- **Detailed `.log` Files** for comprehensive operational tracking.
- **Export to `.csv`** for reporting and auditing purposes.

---

## 📄 Overview

The **Check-List for Applying ITSM-Templates-WKS** establishes a standardized approach to configuring workstations and printers, promoting compliance, operational efficiency, and secure deployment.

### **Objectives**:
- Improve service quality and customer satisfaction.
- Enhance risk management and IT governance.
- Drive operational efficiency and ensure service continuity.

---

## 📋 Clone the Repository

To effectively implement and utilize the ITSM-Templates-WKS scripts, follow these steps:

1. **Centralize the Repository in the Definitive Media Library (DML)**:  
   Clone the `ITSM-Templates-WKS` folder to your network’s **Definitive Media Library (DML)** path. This central location ensures the repository is easily accessible across your network infrastructure for consistent deployment.

2. **Deploy Locally to Workstations**:  
   Each operator must copy the `ITSM-Templates-WKS` folder from the DML to the `C:\` drive of each workstation requiring configuration. Running scripts from the local environment ensures efficient execution and reduces dependency on network connectivity during configuration.

3. **Maintain a Regularly Updated DML**:  
   Continuously update the DML repository with the latest version of the ITSM-Templates-WKS folder. This ensures all operators and configurations are using the most up-to-date scripts and templates, maintaining alignment with organizational policies and standards.

4. **Standardize Local Administrative Privileges**:  
   - Ensure that only **one local administrative account** with elevated privileges exists on each workstation.  
   - All configurations and management should be performed using this designated administrative instance to ensure consistency, reduce security risks, and simplify troubleshooting.

By adhering to these steps, the ITSM-Templates-WKS repository becomes a powerful tool for maintaining compliance, optimizing workstation configurations, and improving operational efficiency across your organization’s network.

---

## 🛠️ Prerequisites

Ensure the following prerequisites are met before running the scripts:

1. **⚙️ PowerShell**:
   - PowerShell must be enabled.
   - The **Active Directory** module may need to be imported.

2. **🔑 Administrator Privileges**:
   - Elevated permissions are required for tasks such as uninstalling applications and accessing restricted configurations.

3. **🖥️ Remote Server Administration Tools (RSAT)**:
   - Install RSAT to enable remote management of Windows Servers and Active Directory roles.

4. **🔧 Script Execution Policy**:
   - Configure execution policies to allow `.vbs` and `.REG` scripts in compliance with organizational security protocols.

5. **📦 Required Dependencies**:
   - Ensure all necessary scripts, files, and software components are available.

---

## 📋 Steps to Use ITSM-Templates-WKS Scripts

1. **Clone the Repository**:
   - Clone the `ITSM-Templates-WKS` folder to your network’s **Definitive Media Library (DML)** for centralized storage.

2. **Follow the Checklist**:
   - Refer to the `Check-List for Applying ITSM-Templates on Windows 10 and 11 Workstations.pdf` in the main `ITSM-Templates-WKS` folder for step-by-step guidance.

3. **Customize Scripts**:
   - Tailor `.vbs` and `.REG` scripts as needed to match specific configurations.

4. **Personalize Workstation Appearance**:
   - Update workstation visuals using files in the `C:\ITSM-Templates-WKS\CustomImages\` folder.
   - Modify desktop themes and layouts using the `C:\ITSM-Templates-WKS\ModifyReg\UserDesktopTheme\` folder.

---

## 📂 ITSM-Templates-WKS Folder Structure and Scripts

### **Folder Descriptions**:
- **Certificates**: Trusted root certificates for secure connections.
- **CustomImages**: Default desktop wallpapers and user profile images.
- **ModifyReg**: Registry configuration scripts for initial setup.
- **PostIngress**: Scripts executed after domain joining.
- **ScriptsAdditionalSupport**: Scripts for resolving configuration inconsistencies.
- **UniqueScripts**: Consolidated scripts for registry and VBS configurations.

### **Key Scripts**

#### **ITSM-DefaultVBSing.vbs**
Located in `C:\ITSM-Templates-WKS\UniqueScripts\`, this script handles:
1. Installing certificates for secure network connections.
2. Applying standardized wallpapers and user profiles.
3. Renewing IP connections for seamless network integration.
4. Disabling Windows Firewall per organizational policies.
5. Configuring the WSUS server for updates.

#### **ITSM-ModifyREGing.vbs**
Located in `C:\ITSM-Templates-WKS\UniqueScripts\`, this script applies essential registry settings:
1. Configuring default browser homepages for accessibility.
2. Enabling administrative shares for remote management.
3. Disabling User Account Control (UAC) for streamlined administration.
4. Standardizing desktop themes.

---

### **PostIngress Scripts**

Located in `C:\ITSM-Templates-WKS\PostIngress\`, these scripts finalize domain-related configurations:

1. **ITSM-NewDNSRegistering.vbs**:  
   Updates the workstation’s hostname and domain information in Active Directory DNS servers, ensuring accurate integration.

2. **ITSM-ProfileImprinting.vbs**:  
   Registers user domain profiles on workstations after three login cycles, enforcing domain policies and user profile consistency.

---

### **ScriptsAdditionalSupport**

Located in `C:\ITSM-Templates-WKS\ScriptsAdditionalSupport\`, these scripts address configuration inconsistencies identified by **L1 Service Support**:

- **ActivateAllAdminShare**: Activates administrative shares, enables RDP, disables Windows Firewall, and turns off Windows Defender.  
- **ExportCustomThemesFiles**: Exports custom system themes.  
- **FixPrinterDriverIssues**: Clears the print spooler and resets printer drivers.  
- **GetSID**: Utilizes Sysinternals tools to retrieve SIDs (Security Identifiers).  
- **InventoryInstalledSoftwareList**: Inventories installed software for auditing.  
- **LegacyWorkstationIngress**: Allows legacy systems to join modern domains.  
- **RecallKESCert**: Updates the workstation’s antivirus server certificate.  
- **RenameDiskVolumes**: Renames disk volumes C: and D: locally.  
- **ResyncGPOsDataStore**: Resets and synchronizes GPOs on the workstation.  
- **UnjoinADComputer-and-Cleanup**: Unjoins a workstation from a domain and clears residual data.  
- **WorkStationConfigReport**: Generates configuration reports for workstations in `.csv` format.  
- **WorkstationTimeSync**: Synchronizes time, date, and time zone with the domain.

---

## 🚀 Next Releases

Future updates will expand the script library with new tools to address evolving ITSM requirements and further improve IT service delivery.

---

## 📝 Logging and Output

- **Logging**: All scripts generate `.log` files documenting execution details and errors.  
- **Export Functionality**: Key results are exported to `.csv` files for audits and reporting.

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
