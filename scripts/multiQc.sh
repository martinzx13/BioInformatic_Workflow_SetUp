#!/bin/bash

set -euo pipefail

# --- Color and formatting definitions ---
RESET="\033[0m"
BOLD="\033[1m"
FG_GREEN="\033[38;5;82m"
FG_RED="\033[31m"
FG_YELLOW="\033[33m"
FG_BLUE="\033[34m"

# --- Initial Setup ---
echo -e "${FG_BLUE}${BOLD}Hello $(whoami)! We are going to run MultiQC to generate a quality control report.${RESET}"

# --- User Input & Path Validation ---
read -rp "Please provide the name of the project created: " projectName

# --- Variable Declaration ---

mutiqcReport="$projectName/results/multiqc_report"
workDir="$projectName/results/figures/fastqc_report"
logDir="$projectName/results/logs"
logFile="$logDir/multiqc_log_$(date +%Y%m%d_%H%M%S).txt"

# --- Directory and Tool Verification ---

# Verify that the input directory exists
if [ ! -d "$workDir" ]; then
  echo -e "${FG_RED}Error: Input data directory not found at '${workDir}'.${RESET}" >&2
  echo -e "${FG_YELLOW}Please ensure the project was set up correctly and that FastQC (or other analysis) has been run first.${RESET}" >&2
  exit 1
fi

# Verify that multiqc command exists
if ! command -v multiqc &>/dev/null; then
  echo -e "${FG_RED}Error: 'multiqc' command not found. Please install MultiQC and ensure it is in your system's PATH.${RESET}" >&2
  exit 1
fi

# Create output directories if they don't exist
mkdir -p "$mutiqcReport"
mkdir -p "$logDir"
touch "$logFile"

# --- Logging Setup ---
echo "MultiQC Workflow Log" >"$logFile"
echo "--------------------" >>"$logFile"
echo "Project: $projectName" >>"$logFile"
echo "Run Date: $(date)" >>"$logFile"
echo "--------------------" >>"$logFile"
echo "Input directory: $workDir" >>"$logFile"
echo "Output directory: $mutiqcReport" >>"$logFile"
echo "--------------------" >>"$logFile"

# --- Running MultiQC ---
echo -e "\n${FG_YELLOW}🚀 Running MultiQC on analysis results in '${workDir}'...${RESET}"
echo -e "\n--- MultiQC Processing ---" >>"$logFile"
echo "Command: multiqc \"$workDir\" -o \"$mutiqcReport\" --force --export" >>"$logFile"

# Running MultiQC

if multiqc "$workDir" -o "$mutiqcReport" --force --export >>"$logFile" 2>&1; then
  echo -e "\n${FG_GREEN}✅ MultiQC report generated successfully in '${mutiqcReport}'.${RESET}"
  echo "MultiQC completed successfully." >>"$logFile"
else
  # set -e will cause the script to exit on error
  echo -e "\n${FG_RED}❌ Error running MultiQC. See log file for details.${RESET}"
  echo -e "${FG_YELLOW}Log file saved at: ${logFile}${RESET}"
  exit 1
fi

# --- Final Summary ---
echo -e "\n${FG_GREEN}🎉 MultiQC workflow complete!${RESET}"
echo -e "${FG_BLUE}Check the report in: ${mutiqcReport}${RESET}"
echo -e "${FG_BLUE}A detailed log was saved to: ${logFile}${RESET}"

