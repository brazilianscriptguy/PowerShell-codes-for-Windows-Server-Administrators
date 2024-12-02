# 📂 Core-ScriptLibrary Folder

Welcome to the **Core-ScriptLibrary**! This folder features essential **PowerShell scripts** tailored to simplify the creation and management of custom script libraries. By focusing on dynamic user interfaces, core functionality, and automation, these tools offer a reliable foundation for developing efficient and maintainable PowerShell-based solutions.

### Key Features:
- **User-Friendly GUIs:** Simplifies user interaction with intuitive graphical interfaces.  
- **Standardized Logging:** Ensures consistent and traceable logs across all scripts, improving debugging and auditing.  
- **Exportable Results:** Outputs actionable data in `.CSV` format for streamlined analysis and reporting.  
- **Efficient Automation:** Facilitates the rapid creation of dynamic PowerShell script libraries and reusable templates.

---

## 🛠️ Prerequisites

Before using the scripts, ensure the following requirements are met:

1. **⚙️ PowerShell**
   - PowerShell must be enabled on your system.
   - Import necessary modules, such as:
     - **Active Directory:** `Import-Module ActiveDirectory`
     - **DHCP Server:** `Import-Module DHCPServer`

2. **🔑 Administrator Privileges**
   - Required for executing tasks that involve sensitive configurations, log creation, or system management.

3. **🖥️ Remote Server Administration Tools (RSAT)**
   - Install RSAT on Windows 10/11 workstations to enable remote management of **Active Directory, DHCP, and other server roles**.

---

## 📄 Script Descriptions (Alphabetical Order)

### 1. **📝 Create-Script-AutomaticMenuGUI.ps1**
   - **Purpose:** Provides a dynamic GUI for browsing and executing scripts organized in folder tabs.  
   - **Features:** Search functionality, categorized browsing, and streamlined script execution through an intuitive interface.

### 2. **📋 Create-Script-DefaultHeader.ps1**
   - **Purpose:** Creates standardized headers for PowerShell scripts, ensuring uniformity and adherence to best practices.  
   - **Features:** Customizable metadata fields such as author, version, and description.

### 3. **📊 Create-Script-LoggingMethod.ps1**
   - **Purpose:** Implements a standardized logging mechanism for PowerShell scripts, enhancing traceability and debugging.  
   - **Features:** Configurable log file locations and detailed event/error logging.

### 4. **🛠️ Create-Script-MainCore.ps1**
   - **Purpose:** Provides a reusable template for creating structured PowerShell scripts, complete with headers, logging, and modular functionality.  
   - **Features:** Accelerates script development with a prebuilt framework.

### 5. **💻 Create-Script-MainGUI.ps1**
   - **Purpose:** Enables the development of graphical user interfaces (GUIs) within PowerShell scripts for enhanced user interaction.  
   - **Features:** Includes support for buttons, input fields, and customizable event handling.

### 6. **📄 Extract-Script-Headers.ps1**
   - **Purpose:** Extracts headers from `.ps1` files within a specified directory and organizes them into folder-specific `.txt` files for easy reference.  
   - **Features:** Automates the documentation of script metadata and categorization.

---

## 🚀 Usage Instructions

### How to Use Each Script:

1. **📝 Create-Script-AutomaticMenuGUI.ps1**  
   - Navigate to the folder containing the script.  
   - Run `.\Create-Script-AutomaticMenuGUI.ps1`.  
   - Specify the directory containing PowerShell scripts.  
   - Use the generated GUI to browse and execute scripts effortlessly.

2. **📋 Create-Script-DefaultHeader.ps1**  
   - Execute the script and provide inputs for author, version, and description.  
   - Copy the generated header into your new or existing PowerShell script.

3. **📊 Create-Script-LoggingMethod.ps1**  
   - Integrate the logging function into your PowerShell scripts.  
   - Define log file locations for consistent traceability.  
   - Use logs to review events, errors, and debugging information.

4. **🛠️ Create-Script-MainCore.ps1**  
   - Use the provided template as a base for your PowerShell projects.  
   - Customize core functionalities and logging as required.

5. **💻 Create-Script-MainGUI.ps1**  
   - Open the script in your PowerShell editor and define GUI components such as buttons and input fields.  
   - Add logic for user interaction and events.  
   - Test the GUI functionality by running the script.

6. **📄 Extract-Script-Headers.ps1**  
   - Specify a root folder containing `.ps1` files.  
   - Run the script to extract and save headers into `.txt` files categorized by folder.

---

## 📝 Logging and Output

- **📄 Logs:** Scripts generate `.LOG` files documenting actions performed and errors encountered.  
- **📊 Reports:** Some scripts produce `.CSV` files for detailed analysis and reporting.

---

## 💡 Tips for Optimization

- **Automate Execution:** Schedule scripts to run periodically for consistent results.  
- **Centralize Logs and Reports:** Save `.LOG` and `.CSV` files in shared directories for collaborative audits.  
- **Customize Templates:** Modify script templates to meet specific organizational needs.  

---

Enjoy exploring and utilizing the **Core-ScriptLibrary**! These tools are designed to enhance your PowerShell scripting experience, making it easier to create, manage, and automate complex workflows.
