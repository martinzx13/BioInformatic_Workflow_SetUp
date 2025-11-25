#!/bin/bash

set -euo pipefail

# --- Color and formatting definitions ---
RESET="\033[0m"
BOLD="\033[1m"
FG_GREEN="\033[38;5;82m"
FG_RED="\033[31m"
FG_YELLOW="\033[33m"
FG_BLUE="\033[34m"

# --- Trimmomatic Configuration ---
TRIMMOMATIC_THREADS=4
# If this variable is left empty, the ILLUMINACLIP step will be SKIPPED.
TRIMMOMATIC_ADAPTER_FILE=""

# Trimming parameters
# ILLUMINACLIP:adapter_file:seed_mismatches:palindrome_clip_threshold:simple_clip_threshold
TRIMMOMATIC_ILLUMINACLIP_PARAMS="2:30:10" # Example: 2 mismatches, 30 threshold, 10 threshold
TRIMMOMATIC_LEADING=3                     # Remove leading low quality bases (below quality 3)
TRIMMOMATIC_TRAILING=3                    # Remove trailing low quality bases (below quality 3)
TRIMMOMATIC_SLIDINGWINDOW="4:15"          # Scan with a 4-base window, drop if average quality < 15
TRIMMOMATIC_MINLEN=36                     # Drop reads shorter than 36 bases

# --- Initial Setup ---
echo -e "${FG_BLUE}${BOLD}Hello $(whoami)! We are going to run Trimmomatic on paired-end data.${RESET}"

read -rp "Please enter the name of the project directory: " projectPath

# --- Path and Variable Setup ---

workDir="$projectPath/data/raw"
outputDir="$projectPath/data/processed/trimmomatic_output"
logDir="$projectPath/results/logs"
logFile="$logDir/trimmomatic_log_$(date +%Y%m%d_%H%M%S).txt"

# --- Validation and Setup ---
echo -e "\n${FG_YELLOW}🔍 Setting up and validating paths...${RESET}"

# Create output directories if they don't exist to prevent errors.
mkdir -p "$outputDir" "$logDir"
touch "$logFile"

# Log initial setup
{
  echo "Trimmomatic Workflow Log"
  echo "------------------------"
  echo "Project Directory: $projectPath"
  echo "Run Date: $(date)"
  if [ -n "$TRIMMOMATIC_ADAPTER_FILE" ]; then
    echo "Adapter File: $TRIMMOMATIC_ADAPTER_FILE"
  else
    echo "Adapter File: NOT PROVIDED (ILLUMINACLIP will be skipped)"
  fi
  echo "Trimmomatic Threads: $TRIMMOMATIC_THREADS"
  echo "Trimming Parameters:"
  echo "  ILLUMINACLIP: $TRIMMOMATIC_ILLUMINACLIP_PARAMS (if adapter file is provided)"
  echo "  LEADING: $TRIMMOMATIC_LEADING"
  echo "  TRAILING: $TRIMMOMATIC_TRAILING"
  echo "  SLIDINGWINDOW: $TRIMMOMATIC_SLIDINGWINDOW"
  echo "  MINLEN: $TRIMMOMATIC_MINLEN"
  echo "------------------------"
} >>"$logFile"

# Verify that Trimmomatic is installed and executable
if ! command -v trimmomatic &>/dev/null; then
  echo -e "${FG_RED}Error: 'trimmomatic' command not found. Please install it and ensure it's in your PATH.${RESET}" | tee -a "$logFile" >&2
  exit 1
fi

# Verify the input directory exists
if [ ! -d "$workDir" ]; then
  echo -e "${FG_RED}Error: Raw data directory not found at '$workDir'.${RESET}" | tee -a "$logFile" >&2
  exit 1
fi

forward_reads=($(find "$workDir" -name "*_R1*.fastq.gz" | sort))

if [ ${#forward_reads[@]} -eq 0 ]; then
  echo -e "${FG_RED}Error: No forward read files (*_R1*.fastq.gz) found in '${workDir}'. Check your filenames.${RESET}" | tee -a "$logFile" >&2
  exit 1
fi

# --- Main Processing Loop ---
for fwd_read in "${forward_reads[@]}"; do
  rev_read="${fwd_read/_R1/_R2}"
  base_name=$(basename "$fwd_read" | sed 's/_R1.*//')
  echo -e "\n${FG_GREEN}🚀 Processing pair for sample:${RESET} $base_name"
  echo "---" >>"$logFile"
  echo "Processing pair for base: $base_name" >>"$logFile"
  echo "Processing pairs $(basename "$fwd_read") and $(basename "$rev_read")"

  # Define the four output files Trimmomatic creates for paired-end reads
  fwd_paired_out="$outputDir/${base_name}_R1_paired.fastq.gz"
  fwd_unpaired_out="$outputDir/${base_name}_R1_unpaired.fastq.gz"
  rev_paired_out="$outputDir/${base_name}_R2_paired.fastq.gz"
  rev_unpaired_out="$outputDir/${base_name}_R2_unpaired.fastq.gz"

  # Assemble the Trimmomatic command from our configuration variables into an array.
  # This is the safest way to handle commands with variables and paths.
  trimmomatic_command=(
    trimmomatic PE -threads "$TRIMMOMATIC_THREADS"
    "$fwd_read"
    "$rev_read"
    "$fwd_paired_out"
    "$fwd_unpaired_out"
    "$rev_paired_out"
    "$rev_unpaired_out"
  )

  # Conditionally add the ILLUMINACLIP step ONLY if an adapter file is provided and exists.
  if [ -n "$TRIMMOMATIC_ADAPTER_FILE" ]; then
    if [ -f "$TRIMMOMATIC_ADAPTER_FILE" ]; then
      trimmomatic_command+=("ILLUMINACLIP:$TRIMMOMATIC_ADAPTER_FILE:$TRIMMOMATIC_ILLUMINACLIP_PARAMS")
    else
      echo -e "${FG_YELLOW}⚠️ Warning: Adapter file '$TRIMMOMATIC_ADAPTER_FILE' not found. Skipping adapter trimming for $base_name.${RESET}" | tee -a "$logFile"
    fi
  fi

  # Add the remaining trimming steps to the command
  trimmomatic_command+=(
    "LEADING:$TRIMMOMATIC_LEADING"
    "TRAILING:$TRIMMOMATIC_TRAILING"
    "SLIDINGWINDOW:$TRIMMOMATIC_SLIDINGWINDOW"
    "MINLEN:$TRIMMOMATIC_MINLEN"
  )

  echo "Executing: ${trimmomatic_command[*]}" >>"$logFile"

  if ! "${trimmomatic_command[@]}" >>"$logFile" 2>&1; then
    echo -e "${FG_RED}❌ Error processing $base_name. Check log for details: $logFile${RESET}"
    continue
  else
    echo "✅ Finished processing $base_name" | tee -a "$logFile"
  fi
done

echo -e "\n${FG_GREEN}🎉 Trimmomatic workflow complete!${RESET}"
echo -e "${FG_BLUE}Check the output in: ${outputDir}${RESET}"
echo -e "${FG_BLUE}A detailed log was saved to: ${logFile}${RESET}"
