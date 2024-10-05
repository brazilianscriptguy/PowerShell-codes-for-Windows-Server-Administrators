# 📂 Core-ScriptLibrary

Welcome to the **Core-ScriptLibrary** folder! This collection contains essential PowerShell scripts designed to create and manage custom script libraries with a focus on generating dynamic user interfaces, core functionality, and automation. These scripts serve as foundational tools for building more complex PowerShell-based solutions.

## 🛠️ Prerequisites

Ensure the following prerequisites are in place before running the scripts:

1. **PowerShell 5.1 or later**  
   It is recommended to use PowerShell 5.1 or newer for full compatibility with these scripts. You can verify your version by running:  
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. **Administrative Privileges**  
   Some scripts may require administrative privileges to access system resources or modify configurations.

## 📄 Script Descriptions

1. **📝 Create-Script-Automatic-MenuGUI.ps1**  
   - Automatically generates a dynamic and categorized GUI interface for discovering and executing PowerShell scripts stored in subdirectories. This tool is especially useful for organizing and running scripts with ease, offering a user-friendly interface for script selection.

2. **🛠️ Create-Script-MainCore.ps1**  
   - Provides a reusable template that simplifies the creation of new PowerShell scripts by automating the inclusion of common features such as headers, logging mechanisms, and module imports. This script serves as the core framework for building consistent, maintainable PowerShell tools.

3. **💻 Create-Script-MainGUI.ps1**  
   - Provides a customizable template for generating graphical user interfaces (GUIs) for PowerShell scripts. This script enables developers to easily build interactive GUI elements into their PowerShell-based solutions, enhancing user interaction and accessibility.

## 🚀 How to Use

1. **📝 Create-Script-Automatic-MenuGUI.ps1**  
   - Run this script to automatically generate a GUI menu of all available scripts in a specified folder. The menu is dynamically updated as scripts are added or removed, making it easy to manage large collections of scripts.

2. **🛠️ Create-Script-MainCore.ps1**  
   - Use this core script template to build new PowerShell scripts with a consistent structure. Simply modify the pre-built functions and logging templates to suit your needs, streamlining development and improving script maintainability.

3. **💻 Create-Script-MainGUI.ps1**  
   - Execute this script to create GUIs for your PowerShell scripts. Customize the GUI elements according to the specific requirements of your scripts to create interactive tools that are accessible to users with varying levels of technical expertise.

## 📝 Logging and Output

- Each script provides logging functionality, outputting results in `.LOG` format and, where necessary, generating additional reports in `.CSV` or other formats. This ensures traceability and easy monitoring of script activities.
