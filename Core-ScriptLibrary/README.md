# 📂 Core-ScriptLibrary

Welcome to the **Core-ScriptLibrary**! This folder contains essential PowerShell scripts designed to create and manage custom script libraries with a focus on dynamic user interfaces, core functionality, and automation. These foundational tools enable the development of more complex and efficient PowerShell-based solutions.

## 🛠️ Prerequisites

Before running the scripts, ensure the following prerequisites are in place:

1. **💻 PowerShell 5.1 or Later**  
   It is recommended to use PowerShell 5.1 or newer for full compatibility with these scripts. You can check your PowerShell version by running the following command:  
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. **🔒 Administrative Privileges**  
   Some scripts may require administrative privileges to access system resources or modify configurations.

## 📄 Script Descriptions

1. **📋 Create-Default-ScriptHeader.ps1**  
   - Placeholder script for generating default headers in PowerShell scripts, standardizing details like author, version, and description. 

2. **📝 Create-Script-Automatic-MenuGUI.ps1**  
   - Automatically generates a dynamic and categorized GUI interface for discovering and executing PowerShell scripts stored in subdirectories. This tool simplifies organizing and running scripts, making it ideal for managing large script collections.

3. **🛠️ Create-Script-MainCore.ps1**  
   - Provides a reusable template for building PowerShell scripts, including essential features like headers, logging mechanisms, and module imports. This core framework ensures consistency and maintainability across PowerShell projects.

4. **📊 Create-Script-LoggingMethod.ps1**  
   - Placeholder script for developing a standardized logging method that can be implemented across PowerShell scripts.

5. **💻 Create-Script-MainGUI.ps1**  
   - A customizable template for generating graphical user interfaces (GUIs) within PowerShell scripts. This script enables the integration of interactive GUI elements, improving user interaction and accessibility for various technical users.

## 🚀 How to Use

### Script Usage Instructions:

1. **📝 Create-Script-Automatic-MenuGUI.ps1**  
   - Run this script to automatically generate a dynamic GUI menu displaying all available scripts in a specified folder. The menu dynamically updates as scripts are added or removed, making it easy to manage large script libraries.

2. **🛠️ Create-Script-MainCore.ps1**  
   - Use this core script template to build new PowerShell scripts with a consistent structure. Modify the pre-built functions and logging templates to fit your needs, streamlining script development and improving maintainability.

3. **💻 Create-Script-MainGUI.ps1**  
   - Execute this script to create custom GUIs for your PowerShell scripts. Customize the GUI elements according to your specific script requirements to enhance usability for users with varying technical skills.

## 📝 Logging and Output

Each script includes built-in logging functionality, outputting results in `.LOG` format. Where applicable, additional reports are generated in `.CSV` or other formats, ensuring traceability and easy monitoring of script activity and outcomes.
