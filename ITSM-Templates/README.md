# 🖥️ Efficient Workstation Management, Configuration, and ITSM Compliance on Windows 10 and 11

## 📄 Description

This repository provides a curated collection of `.VBS` and PowerShell scripts to streamline the management and configuration of Windows 10 and 11 workstations within an IT Service Management (ITSM) framework. These scripts automate various administrative tasks, enabling IT professionals to optimize workflows and maintain consistent configurations across workstations.

✨ **Key Features**:
- Scripts include **graphical user interfaces (GUI)** for intuitive interactions.
- Each script generates **detailed `.log` files** for operational tracking and **exports results to `.csv` files** for reporting and auditing.

---

## 📄 Overview

The **Check-List for Applying ITSM-Templates** standardizes configurations for workstations and printers, ensuring compliance, operational efficiency, and secure deployment.

### **Objectives**:
- Enhance service quality and customer satisfaction.
- Strengthen risk management and IT governance.
- Drive operational efficiency and service continuity.

---

## 🛠️ Prerequisites

Before running the scripts, ensure the following prerequisites are met:

1. **⚙️ PowerShell**
   - PowerShell must be enabled on your system.
   - The **Active Directory** module may need to be imported.

2. **🔑 Administrator Privileges**
   - Elevated permissions are required to uninstall applications or access restricted system configurations.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - Install RSAT to enable remote management of Windows Servers and Active Directory roles.

4. **🔧 Script Execution Policy**
   - Adjust the execution policy to allow `.VBS` and `.REG` scripts, adhering to organizational security policies.

5. **📦 Required Dependencies**
   - Verify that all required scripts, files, and software components are available.

---

## 📋 Steps to Use ITSM-Templates Scripts

1. **Clone the Repository**:
   - Clone the `ITSM-Templates` folder to your Definitive Media Library (DML) network path.

2. **Follow the Checklist**:
   - Refer to the `Check-List for Applying ITSM-Templates on Windows 10 and 11 Workstations.pdf` file located in the main `ITSM-Templates` folder for detailed instructions.

3. **Customize Scripts**:
   - Modify `.VBS` and `.REG` scripts as needed to suit specific configurations.

4. **Personalize Workstation Appearance**:
   - Update workstation themes using the `C:\ITSM-Templates\CustomImages` folder.

---

## 📂 ITSM-Templates Folder Structure and Scripts

### **Folder Descriptions**:
- **Certificates**: Trusted root certificates for secure network connections.
- **CustomImages**: Default desktop wallpapers and user profile images.
- **ModifyReg**: Registry configuration scripts for initial execution.
- **PostIngress**: Scripts executed after domain joining.
- **ScriptsAdditionalSupport**: Support scripts for addressing configuration inconsistencies.
- **Uniquescripts**: Unified scripts for registry and VBS configurations.

### **Key Scripts**:

#### **ITSM-DefaultVBSing.vbs**
Located in `C:\ITSM-Templates\UniqueScripts\`, this script standardizes configurations, including:
1. Installing certificates.
2. Configuring desktop wallpapers and user profiles.
3. Renewing IP connections.
4. Disabling Windows Firewall.
5. Pointing to the WSUS server.

#### **ITSM-ModifyREGing.vbs**
Located in `C:\ITSM-Templates\UniqueScripts\`, this script handles essential registry modifications, such as:
1. Setting browser homepages.
2. Enabling administrative shares.
3. Disabling User Account Control (UAC).
4. Applying desktop themes.

---

### **ScriptsAdditionalSupport**

The `ScriptsAdditionalSupport` folder contains additional support scripts for addressing configuration inconsistencies identified by **L1 Service Support**:

- **ActivateAllAdminShare**: Script to activate administrative shares, enable RDP, disable Windows Firewall, and turn off Windows Defender.  
- **ExportCustomThemesFiles**: Script to export customized system themes.  
- **FixPrinterDriverIssues**: Script to clear the print spooler and reset all printer drivers on the workstation.  
- **GetSID**: Folder containing the Microsoft Internals tool to identify the SID (Security Identifier).  
- **InventoryInstalledSoftwareList**: Script to inventory the list of installed software on the workstation.  
- **LegacyWorkstationIngress**: Script to enable legacy operating system workstations to join new domains.  
- **RecallKESCert**: Script to point to the Antivirus server and renew the certificate.  
- **RenameDiskVolumes**: Script to locally rename the disk volumes C: and D:.  
- **ResyncGPOsDataStore**: Script to reset all GPOs on the workstation and initiate a new synchronization.  
- **UnjoinADComputer-and-Cleanup**: Script to unjoin workstations from a domain and clear old domain data.  
- **WorkStationConfigReport**: Script for generating configuration reports for each workstation and recording them in a spreadsheet.  
- **WorkstationTimeSync**: Script to synchronize the workstation’s time, date, and time zone.

---

## 🚀 Next Releases

Future updates will include new scripts to address evolving ITSM needs and provide innovative tools to enhance IT service delivery.

---

## 📝 Logging and Output

- 📄 **Logging**: Scripts generate `.LOG` files documenting every process, including errors and uninstall actions.
- 📊 **Export Functionality**: Results are exported in `.CSV` format for auditing and reporting.

---

## 📄 Log File Locations

Logs are stored in `C:\ITSM-Logs\` and include:
- **DNS registration logs**.
- **User profile imprinting logs**.
- **Domain join/removal logs**.

---

## 🔗 References

- [ITSM-Templates GitHub Repository](https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators)

---

### **Document Classification**:
This document is **RESTRICTED** for internal use within the COMPANY network.
