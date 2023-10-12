# uas_preamble

`uas_preamble` is a convenience program for simplifying and standardizing the initial loading, cleaning, and variable derivation for each UAS education survey wave data file.

# Installation
For new installations, paste the following code into your command line in a Stata interface: `net install uas_preamble, from(https://raw.githubusercontent.com/usc-care/uas_preamble/master)`. To update an existing installation, add the `replace` option.

# Usage
Type `help uas_preamble` into a command line to access the help file.

# Update log

- 06nov2022: Fixed file path issue for creating the log file. 
- 01nov2022: Major overhaul that adds several new features and changes to how the program functions.
- 18Oct2022: Modified the conditional logic for creating the global macros containing the project paths to account for users who do not have access to the _MASTER_UAS_COVID Box folder.
- 12oct2023: Updated the global macros definitions to reflect the new project directory structure. 