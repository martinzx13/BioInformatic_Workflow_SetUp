#!/bin/bash

set -euo pipefail

# --- Color and formatting definitions (from suggest.txt) ---
RESET="\033[0m"
BOLD="\033[1m"
FG_GREEN="\033[38;5;82m"
FG_RED="\033[31m"
FG_YELLOW="\033[33m"
FG_BLUE="\033[34m"

# --- Initial Setup, keeping your variable names and style ---
whoami=$(whoami)
echo -e "${FG_BLUE}${BOLD}Hello ${whoami}! We are going to run A Quality Control application for FastQ files.${RESET}"

read -rp "${whoami} Please enter the path to the project created previously : " projectSetUp

# --- Define Paths, keeping your variable names ---
workdir="$projectSetUp/data/raw"
resultdir="$projectSetUp/results"
today=$(date +%Y-%m-%d)
fastqc_output_dir="$resultdir/figures/fastqc_reports" # Specific output dir from suggestion
log_dir="$resultdir/logs"

# --- Log file setup, keeping your naming convention but with a more robust path ---
logFile="$log_dir/fastqc_log_$today.txt"

# --- Create directories and log file, and check for tools ---
echo -e "\n${FG_YELLOW}Setting up environment...${RESET}"
mkdir -p "$fastqc_output_dir"
mkdir -p "$log_dir"
touch "$logFile"

if ! command -v fastqc &> /dev/null; then
    echo -e "${FG_RED}Error: 'fastqc' command not found. Please install FastQC.${RESET}" >&2
    exit 1
fi

echo "FastQC Workflow Log" > "$logFile"
echo "-------------------" >> "$logFile"
echo "Project Directory: $projectSetUp" >> "$logFile"
echo "Run Date: $today" >> "$logFile"
echo "-------------------" >> "$logFile"


# --- Find and Check for FASTQ files, using your improved loop ---
echo -e "\n${FG_YELLOW}🔍 Searching for FASTQ files in '${workdir}'...${RESET}"
rawFiles=()
# Using a glob to find all files. We will check for FASTQ extensions later if needed.
# This loop handles the case where the directory is empty gracefully.
for file in "$workdir"/*; do
  # Check if the file exists and is a regular file before adding
  if [ -f "$file" ]; then
    rawFiles+=("$file")
  fi
done

# Now, check if the array is empty
if [ ${#rawFiles[@]} -eq 0 ]; then
  echo -e "${FG_RED}Error: No files found in '${workdir}'.${RESET}" >&2
  echo "Error: No files found in '${workdir}'." >> "$logFile"
  exit 1
fi

echo "Found ${#rawFiles[@]} file(s) to process." | tee -a "$logFile"


# --- Main Processing Loop, with nice logs ---
echo -e "\n${FG_YELLOW}🚀 Running FastQC on all found files...${RESET}"
echo -e "\n--- FastQC Processing ---" >> "$logFile"

for fastqFile in "${rawFiles[@]}"; do
  filename=$(basename "$fastqFile")
  echo -e "🧬 ${FG_GREEN}Processing:${RESET} $filename"
  echo "Running fastqc on: $filename" >> "$logFile"

  if ! fastqc "$fastqFile" -o "$fastqc_output_dir"; then
      echo -e "${FG_RED}❌ Error running FastQC on $filename.${RESET}" | tee -a "$logFile"
  else
      echo "Successfully processed $filename." >> "$logFile"
  fi
done

# --- Final Summary with MultiQC (from suggest.txt) ---
echo -e "\n${FG_YELLOW}📊 Attempting to generate a MultiQC summary report...${RESET}"
if command -v multiqc &> /dev/null; then
    multiqc_output_dir="$resultdir/figures" # Place report in the main figures dir
    echo "Running MultiQC to aggregate reports..." | tee -a "$logFile"
    if multiqc "$fastqc_output_dir" -o "$multiqc_output_dir" --force; then
        echo -e "\n${FG_GREEN}✅ MultiQC report generated successfully in '${multiqc_output_dir}'.${RESET}" | tee -a "$logFile"
    else
        echo -e "${FG_YELLOW}⚠️ Warning: MultiQC ran but encountered errors.${RESET}" | tee -a "$logFile"
    fi
else
    echo -e "${FG_YELLOW}Warning: 'multiqc' command not found. Skipping summary report generation.${RESET}" | tee -a "$logFile"
fi

echo -e "\n${FG_GREEN}🎉 FastQC workflow complete!${RESET}"
echo -e "${FG_BLUE}Check the reports in: ${fastqc_output_dir}${RESET}"
echo -e "${FG_BLUE}A detailed log was saved to: ${logFile}${RESET}"