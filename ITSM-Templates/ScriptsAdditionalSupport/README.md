# 🛠️ ScriptsAdditionalSupport Suite

## 📄 Overview

The **ScriptsAdditionalSupport** folder contains a collection of additional scripts designed to address configuration inconsistencies identified by **L1 Service Support**. These scripts provide critical tools for troubleshooting, maintenance, and optimization of workstation and server environments.

---

## 📋 Script Descriptions

### **ActivateAllAdminShare**  
Activates administrative shares, enables Remote Desktop Protocol (RDP), disables Windows Firewall, and turns off Windows Defender to facilitate administrative access.

### **ExportCustomThemesFiles**  
Exports customized system themes for consistent desktop and user interface configurations.

### **FixPrinterDriverIssues**  
Clears the print spooler and resets all printer drivers on the workstation to resolve common printer-related issues.

### **GetSID**  
Provides the Microsoft Internals tool to identify the **Security Identifier (SID)** of a workstation or user account.

### **InventoryInstalledSoftwareList**  
Inventories the list of installed software on the workstation, generating a comprehensive report.

### **LegacyWorkstationIngress**  
Enables legacy operating system workstations to join new domains, ensuring compatibility and network integration.

### **RecallKESCert**  
Points the workstation to the Antivirus server and renews the required certificate for secure antivirus operations.

### **RenameDiskVolumes**  
Locally renames the disk volumes **C:** and **D:** to maintain standardized naming conventions.

### **ResyncGPOsDataStore**  
Resets all Group Policy Objects (GPOs) on the workstation and initiates a new synchronization with the domain.

### **UnjoinADComputer-and-Cleanup**  
Unjoins the workstation from the domain and clears old domain data, preparing it for reallocation or repurposing.

### **WorkStationConfigReport**  
Generates configuration reports for each workstation and records the details in a spreadsheet for auditing and analysis.

### **WorkstationTimeSync**  
Synchronizes the workstation’s time, date, and time zone to ensure consistency with domain controllers.

---

## 🚀 How to Use

1. Navigate to the **ScriptsAdditionalSupport** folder in the **ITSM-Templates** directory.
2. Select the desired script for execution based on the task or issue to be addressed.
3. Follow the usage instructions included in the script header or associated documentation.

---

## 📝 Logging and Output

Each script generates detailed logs to document the steps performed, outcomes, and any errors encountered. These logs are saved in the `C:\ITSM-Logs\` directory for easy access and troubleshooting.

---

## 🔗 References

- [ITSM-Templates Documentation](https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators)  
- For additional assistance, contact **L1 Service Support** or refer to the **README.md** file in the root directory of **ITSM-Templates**.
