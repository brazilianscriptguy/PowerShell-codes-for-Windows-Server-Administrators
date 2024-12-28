# 🖥️ Efficient Workstation Management, Configuration, and ITSM Compliance on Windows 10 and 11

## 📄 Description

This repository provides a curated collection of `.VBS` and PowerShell scripts to streamline the management and configuration of Windows 10 and 11 workstations within an IT Service Management (ITSM) framework. These scripts automate various administrative tasks, enabling IT professionals to optimize workflows and maintain consistent configurations across workstations.

✨ **Key Features**:
- Scripts include **graphical user interfaces (GUI)** for intuitive interactions.
- Each script generates **detailed `.log` files** for operational tracking and **exports results to `.csv` files** for reporting and auditing.

---

## 📄 Overview

The **Check-List for Applying ITSM-Templates-WKS** standardizes configurations for workstations and printers, ensuring compliance, operational efficiency, and secure deployment.

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

## 📋 Steps to Use ITSM-Templates-WKS Scripts

1. **Clone the Repository**:
   - Clone the `ITSM-Templates-WKS` folder to your Definitive Media Library (DML) network path.

2. **Follow the Checklist**:
   - Refer to the `Check-List for Applying ITSM-Templates on Windows 10 and 11 Workstations.pdf` file located in the main `ITSM-Templates-WKS` folder for detailed instructions.

3. **Customize Scripts**:
   - Modify `.VBS` and `.REG` scripts as needed to suit specific configurations.

4. **Personalize Workstation Appearance**:
   - Update desktop appearance and user images using the `C:\ITSM-Templates-WKS\CustomImages\` folder.
   - Update workstation themes and layout using the `C:\ITSM-Templates-WKS\ModifyReg\UserDesktopTheme` folder.

---

## 📂 ITSM-Templates-WKS Folder Structure and Scripts

### **Folder Descriptions**:
- **Certificates**: Trusted root certificates for secure network connections.
- **CustomImages**: Default desktop wallpapers and user profile images.
- **ModifyReg**: Registry configuration scripts for initial execution.
- **PostIngress**: Scripts executed after domain joining.
- **ScriptsAdditionalSupport**: Support scripts for addressing configuration inconsistencies.
- **Uniquescripts**: Unified scripts for registry and VBS configurations.

### **Key Scripts**

#### **ITSM-DefaultVBSing.vbs**
Located in `C:\ITSM-Templates-WKS\UniqueScripts\`, this script standardizes workstation configurations by:
1. Installing certificates required for secure network connections.
2. Applying consistent desktop wallpapers and user profile settings.
3. Renewing IP connections to ensure proper network integration.
4. Disabling Windows Firewall for compatibility with the Company’s network policies.
5. Configuring the WSUS server address to manage updates.

#### **ITSM-ModifyREGing.vbs**
Located in `C:\ITSM-Templates-WKS\UniqueScripts\`, this script applies critical registry configurations, including:
1. Setting default browser homepages for user accessibility.
2. Enabling administrative shares to support remote management.
3. Disabling User Account Control (UAC) to streamline administrative operations.
4. Applying desktop themes to maintain a consistent user interface.

---

### **PostIngress Scripts**

Located in `C:\ITSM-Templates-WKS\PostIngress\`, this collection of scripts is executed after the workstation joins the domain to complete critical configurations:

1. **ITSM-NewDNSRegistering.vbs**  
   Updates the workstation's hostname and domain information in the DNS servers of the Company’s Active Directory forest. This ensures accurate DNS registration and seamless integration with the domain network.  
 
2. **ITSM-ProfileImprinting.vbs**  
   Registers the user's domain profile on the workstation after three login cycles (login, logoff, and restart). This process enforces the network environment, domain configurations, and user profile registration, ensuring proper functionality both within and outside the Company’s network.  
 
---

### **ScriptsAdditionalSupport**

The `C:\ITSM-Templates-WKS\ScriptsAdditionalSupport` folder contains additional support scripts for addressing configuration inconsistencies identified by **L1 Service Support**:

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

Logs are stored in `C:\ITSM-Logs-WKS\` and include:
- **DNS registration logs**.
- **User profile imprinting logs**.
- **Domain join/removal logs**.

---

## 🔗 References

- [ITSM-Templates-WKS GitHub Repository](https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators)

---

### **Document Classification**:
This document is **RESTRICTED** for internal use within the Company's network.
