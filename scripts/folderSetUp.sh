#!/bin/bash

set -euo pipefail

# --- Color and formatting definitions ---
RESET="\033[0m"
BOLD="\033[1m"
FG_GREEN="\033[38;5;82m"
FG_RED="\033[31m"
FG_YELLOW="\033[33m"
FG_BLUE="\033[34m"

# --- Main Script Logic ---
echo -e "${FG_BLUE}${BOLD}Starting Bioinformatics Project Setup...${RESET}"

# --- User Input ---

base_path="${1:-.}"
date=$(date +%Y-%m-%d)
echo "Hello $(whoami) we are gonna set Up the project structure for your work"
read -rp "Please enter the project name: " projectName
# --- Path and Log File Definition ---

baseDir="$base_path/$projectName"
logFile="$baseDir/setup_log_$date.txt"

# Check if project directory already exists to prevent accidental overwrites

# Create the project directory first to house the log file
mkdir -p "$baseDir"
touch "$logFile"

echo "Project Setup Log" >"$logFile"
echo "-----------------" >>"$logFile"
echo "Project Name: $projectName" >>"$logFile"
echo "Creation Date: $(date)" >>"$logFile"
echo "Base Directory: $baseDir" >>"$logFile"
echo "-----------------" >>"$logFile"

# --- Directory Structure Definition (Standardized) ---
directories=(
  "$baseDir/data/raw"
  "$baseDir/data/processed"
  "$baseDir/data/reference"
  "$baseDir/results/figures"
  "$baseDir/results/tables"
  "$baseDir/results/logs"
  "$baseDir/scripts/main_scripts"
  "$baseDir/scripts/utils"
)

# --- Creation Loop ---
echo -e "\n${FG_YELLOW}Creating project folder structure...${RESET}"
echo -e "\nCreating project folder structure..." >>"$logFile"
for dir in "${directories[@]}"; do
  echo -e "📁 ${FG_GREEN}Creating ...${RESET} $dir"
  mkdir -p "$dir"
  echo "CREATED: $dir" >>"$logFile"
  sleep 0.1
done

# --- Verification Loop ---
echo -e "\n${FG_YELLOW}Verifying created folder structure...${RESET}"
echo -e "\nVerifying created folder structure..." >>"$logFile"
for dir in "${directories[@]}"; do
  if [ ! -d "$dir" ]; then
    echo -e "${FG_RED}Error: Directory '$dir' was not created successfully.${RESET}" >&2
    echo "VERIFICATION FAILED for: $dir" >>"$logFile"
    exit 1
  fi
done

echo -e "\n${FG_GREEN}✅ Project structure for '${projectName}' created and verified successfully in '${baseDir}'!${RESET}"
echo -e "\nAll directories created and verified successfully." >>"$logFile"
echo -e "${FG_BLUE}A detailed log has been saved to: ${logFile}${RESET}"

