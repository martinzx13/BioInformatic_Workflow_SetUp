# Project Overview

This project consists of a set of bash scripts designed to bootstrap a directory structure for a typical bioinformatics workflow. It also provides a menu-driven terminal interface to guide the user through common analysis steps like quality control, read alignment, and quantification. The scripts make use of terminal colors and formatting to create a user-friendly experience.

## Building and Running

There is no build process for this project. The scripts can be run directly.

**To run the project:**

```bash
bash scripts/setUp.sh
```

This will start the main menu interface. From there, you can navigate to the different modules.

**To set up the directory structure:**

1.  Run `bash scripts/setUp.sh`.
2.  Select option `[1] Folder SetUp`.
3.  Follow the prompts to enter your name and a project name.

## Development Conventions

*   The scripts are written in `bash`.
*   The scripts use `set -euo pipefail` to ensure that the script will exit immediately if a command exits with a non-zero status.
*   The scripts make extensive use of functions to modularize the code.
*   The scripts use a consistent style for defining and using colors in the terminal.
*   The `upStreamTools.sh` script seems to be a more advanced version of the workflow, but it is not currently integrated with the main `setUp.sh` script.
*   The `checker.sh` script is empty and does not seem to be used.
*   The `folderSetUp.sh` script is missing the `mkdir -p` commands to actually create the directories.
