# 📂 Core-ScriptLibrary

Welcome to the **Core-ScriptLibrary**! This folder contains essential PowerShell scripts designed to create and manage custom script libraries, with a focus on dynamic user interfaces, core functionality, and automation. These tools provide a strong foundation for building more complex, efficient PowerShell-based solutions.

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

1. **📝 Create-Script-AutomaticMenuGUI.ps1**  
   - Automatically generates a dynamic, categorized GUI interface for discovering and executing PowerShell scripts stored in subdirectories. This tool is ideal for organizing and managing large script collections through an intuitive, user-friendly interface.

2. **📋 Create-Script-DefaultHeader.ps1**  
   - Generates standardized headers for new PowerShell scripts, including details like author, version, and description. This ensures consistency across your PowerShell scripts.

3. **📊 Create-Script-LoggingMethod.ps1**  
   - Implements a standardized logging method across PowerShell scripts, ensuring uniform and consistent logging for improved traceability and debugging.

4. **🛠️ Create-Script-MainCore.ps1**  
   - Provides a reusable template for building PowerShell scripts, complete with essential features such as standardized headers, logging mechanisms, and module imports. This script serves as the core framework for creating structured and maintainable PowerShell projects.

5. **💻 Create-Script-MainGUI.ps1**  
   - A customizable template for generating graphical user interfaces (GUIs) within PowerShell scripts. This enables developers to incorporate interactive GUI elements into their scripts, making them more user-friendly and accessible to users of varying technical expertise.

## 🚀 Script Usage Instructions

### How to Use Each Script:

1. **📝 Create-Script-AutomaticMenuGUI.ps1**  
   - This script scans a specified folder containing PowerShell scripts and dynamically generates a categorized menu for easy navigation and execution. The menu auto-updates as scripts are added or removed, making it an excellent tool for managing large script collections.

   **Steps**:
   - Open PowerShell and navigate to the folder containing the script.
   - Run `.\Create-Script-AutomaticMenuGUI.ps1`.
   - Specify the directory containing your PowerShell scripts.
   - Use the generated GUI to browse and execute scripts from an intuitive interface.

2. **📋 Create-Script-DefaultHeader.ps1**  
   - This script generates standardized headers for new PowerShell scripts, ensuring a consistent format across all your scripts. The headers include details such as the author, version, and description of the script.

   **Steps**:
   - Run `.\Create-Script-DefaultHeader.ps1`.
   - Enter the required details such as author name, script description, and version.
   - The script will output a standardized header that you can paste into your new PowerShell script.

3. **📊 Create-Script-LoggingMethod.ps1**  
   - This script provides a standardized logging method for PowerShell scripts, allowing consistent and organized logs across different projects. Use this script to add detailed logging to any of your scripts for improved traceability.

   **Steps**:
   - Import the logging method into your existing PowerShell scripts by copying and pasting the required functions.
   - Define the log file location within your script.
   - Ensure your script writes key events and errors to the log file for future review.

4. **🛠️ Create-Script-MainCore.ps1**  
   - This template script provides a core structure for building new PowerShell scripts. It includes standardized headers, logging mechanisms, and essential imports, allowing you to focus on the specific logic of your script while ensuring a consistent structure.

   **Steps**:
   - Copy `Create-Script-MainCore.ps1` and use it as a starting template for your new PowerShell scripts.
   - Modify the core functions and include your custom logic.
   - Use the built-in logging mechanisms for tracking script execution.

5. **💻 Create-Script-MainGUI.ps1**  
   - This script serves as a customizable template for creating graphical user interfaces (GUIs) in PowerShell. You can use this script to add interactive GUI elements to your scripts, such as buttons, input fields, and dropdowns.

   **Steps**:
   - Open `Create-Script-MainGUI.ps1` and define the layout of your GUI elements (e.g., buttons, labels, input fields).
   - Add event handlers to the GUI elements to execute specific actions when the user interacts with them.
   - Run the script to display the GUI and allow users to interact with the interface.

## 📝 Logging and Output

Each script is designed with built-in logging functionality, generating output in `.LOG` format. Where applicable, additional reports are provided in `.CSV` or other formats, ensuring thorough traceability and monitoring of script activities. This consistent logging methodology simplifies troubleshooting and auditing.
