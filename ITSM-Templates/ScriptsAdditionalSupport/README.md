# 🛠️ ScriptsAdditionalSupport Suite

## 📄 Overview

The **ScriptsAdditionalSupport** folder contains a comprehensive collection of additional scripts designed to address configuration inconsistencies identified by **L1 Service Support**. These scripts serve as essential tools for troubleshooting, maintenance, and optimization of workstation and server environments, ensuring smooth operations and compliance with IT standards.

Each script includes robust error handling, detailed logging, and, where applicable, a user-friendly GUI for streamlined interaction.

---

## 📋 Script Descriptions

### **ActivateAllAdminShare**  
**Script:** `Activate-All-AdminShares.ps1`  
Enables administrative shares, activates Remote Desktop Protocol (RDP), disables Windows Firewall, and turns off Windows Defender to facilitate administrative access. Includes a GUI for task management.  

---

### **ExportCustomThemesFiles**  
**Script:** `Exports-CustomThemes-Files.ps1`  
Exports custom Windows theme files, including `LayoutModification.xml`, `.msstyles`, and `.deskthemepack`, to standardize desktop and user interface configurations across the network.  

---

### **FixPrinterDriverIssues**  
**Script:** `Fix-PrinterDriver-Issues.ps1`  
Troubleshoots common printer-related issues by resetting the print spooler, clearing print jobs, and managing printer drivers. The script includes multiple resolution methods and a GUI for user interaction.  

---

### **GetSID**  
**Tool:** Microsoft Internals Tool  
Identifies the **Security Identifier (SID)** of a workstation or user account, useful for diagnostic and management purposes.  

---

### **InventoryInstalledSoftwareList**  
**Script:** `Inventory-InstalledSoftwareList.ps1`  
Inventories all installed software on the workstation, generating a detailed report for auditing and compliance purposes.  

---

### **LegacyWorkstationIngress**  
**Script:** `LSA-NetJoin-Legacy.ps1`  
Modifies registry settings to allow legacy operating systems to join modern domains. Fully compatible with Windows Server 2019 and newer.  

---

### **RecallKESCert**  
**Script:** `RecallKESCert.ps1`  
Points the workstation to the Antivirus server and renews the necessary certificate, ensuring continued protection and secure operations.  

---

### **RenameDiskVolumes**  
**Script:** `ChangeDiskVolumesNames.ps1`  
Renames disk volumes **C:** and **D:**. The **C:** drive is labeled with the hostname, while **D:** is labeled for personal data or custom use. Detailed logging ensures traceability.  

---

### **ResyncGPOsDataStore**  
**Script:** `Resync-GPOs-DataStore.ps1`  
Resets all Group Policy Objects (GPOs) on the workstation and synchronizes them with the domain policies. The script includes a GUI for user guidance and logs all actions for traceability.  

---

### **UnjoinADComputer-and-Cleanup**  
**Script:** `Unjoin-ADComputer-and-Cleanup.ps1`  
Unjoins the workstation from the domain and performs cleanup operations, such as clearing DNS cache, removing old domain profiles, and resetting environment variables. Includes a GUI for seamless interaction and standardized logging.  

---

### **WorkStationConfigReport**  
**Script:** `Workstation-Data-Report.ps1`  
Collects system configuration details, including OS, BIOS, and network information, saving the data into a `.CSV` file. Designed with a GUI for user feedback and error handling.  

---

### **WorkstationTimeSync**  
**Script:** `Workstation-TimeSync.ps1`  
Synchronizes the workstation’s time, date, and time zone with the domain controllers, ensuring network-wide consistency.  

---

## 🚀 How to Use

1. Navigate to the **ScriptsAdditionalSupport** folder in the **ITSM-Templates** directory.  
2. Select and execute the script relevant to the task or issue you are addressing.  
3. Refer to the usage instructions included in the script header or associated documentation for detailed guidance.  

---

## 📝 Logging and Output

Each script generates detailed logs documenting the steps performed, outcomes, and any errors encountered. Logs are saved in the `C:\ITSM-Logs\` directory, making them easily accessible for troubleshooting and auditing purposes.  

---

## 🔗 References

- [ITSM-Templates Documentation](https://github.com/brazilianscriptguy/PowerShell-codes-for-Windows-Server-Administrators/blob/main/ITSM-Templates/README.md)  
- For further assistance, contact **L1 Service Support** or consult the **README.md** file located in the root directory of **ITSM-Templates**.
