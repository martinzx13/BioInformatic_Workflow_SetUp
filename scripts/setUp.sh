#!/bin/bash

# -----------------------------------------------------------------------------
# Bioinformatics SetUp: A terminal showcase for bioinformatics workflows
# Author: Juan Pablo Martinez Aldana
# Course: Introduction to Bioinformatics and Computational Biology.
# -----------------------------------------------------------------------------
#

# Variable Declaration
# date, username and location

set -euo pipefail

#DATE=$(date)
#USER=$(USER)
#WHERE=$(PWD)

width=$(tput cols || echo 80)
height=$(tput lines || echo 24)

# ----- Colors -----
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

FG_TEAL="\033[38;5;37m"
FG_PURPLE="\033[38;5;135m"
FG_SILVER="\033[38;5;250m"
FG_WHITE="\033[97m"
FG_GREEN="\033[38;5;82m"
FG_YELLOW="\033[33m"
FG_RED="\033[31m"
FG_BLUE="\033[34m"

BG_DARK="\033[48;5;234m"
BG_NONE="\033[49m"

#-----------------------
# Some Helper Functions.

center() {
  local text="$1"
  # Strip ANSI escape codes to calculate the real length of the text
  local stripped_text
  stripped_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
  local pad=$(((width - ${#stripped_text}) / 2))
  printf "%*s%s\n" "$pad" "" "$text"
}

line() {
  printf "%b%*s%b\n" "$FG_SILVER" "$width" "$(printf '─%.0s' $(seq 1 $width))" "$RESET" | cut -c1-"$width"
}

# ---------------- Title banner ---------------

banner() {
  clear
  line
  center "$(printf '%b%s%b' "$FG_TEAL$BOLD" 'Bioinformatics and Computational Biology' "$RESET")"
  center "$(printf '%b%s%b' "$FG_SILVER" 'Terminal workflow for bioinformatics' "$RESET")"
}

# ----- Footer -----
footer() {
  echo
  line
  center "$(printf '%b%s%b' "$FG_SILVER$DIM" '© JUAN • Lisboa • Live demo' "$RESET")"
  line
}

folderCreation() {
  banner
  center "$(printf '%b%s%b' "$FG_WHITE$BOLD" 'Module: Workspace SetUp' "$RESET")"
  echo
  line
  echo
  (
    sleep 1
    ./folderSetUp.sh
    sleep 1
  )
  echo
  center "$(printf '%b%s%b' "$FG_GREEN" 'Folder Set Up prepare for further Analysis' "$RESET")"
  footer
  read -rp "Press Enter to return to menu..."
}

fastQc() {
  banner
  center "$(printf '%b%s%b' "$FG_WHITE$BOLD " 'Module : Quality Control Running using the Tool fastQc ' "$RESET")"
  echo
  line
  echo
  (
    ./fastQc.sh
  )
  echo
  center "$(printf '%b%s%b' "$FG_GREEN" 'fastQc Analysis performed successfully' "$RESET")"
  footer
  read -rp "Press Enter to return to menu..."
}

ft_trimmomatic() {
  banner
  center "$(printf '%b%s%b' "$FG_GREEN" 'Module : Trimmomatic tool for sequence enhancement : ' "$RESET") "
  echo
  line
  echo
  (
    sleep 0.5
    ./trimmomatic.sh
  )
  echo
  center "$(printf '%b%s%b' "$FG_GREEN" 'Trimmomatic performed successfully ' "$RESET") "
  footer
  read -rp "Press Enter to return to menu"
}
multiQc() {
  banner
  center "$(printf '%b%s%b' "$FG_WHITE$BOLD" 'Module : MultiQc Analysis Report ' "$RESET")"
  echo
  line
  echo
  (
    ./multiQc.sh
  )
  echo
  center "$(printf '%b%s%b' $FG_GREEN 'MultiQc Analysis performed successfully' "$RESET")"
  footer
  read -rp "Press Enter to return to menu"

}
menu() {
  while true; do
    banner
    center "$(printf '%b%s%b' "$FG_PURPLE$BOLD" 'Select A Module you want to run ' "$RESET")"
    echo

    printf "%b%2s%b %b%-22s%b %b%s%b\n" \
      "$FG_TEAL$BOLD" "[1]" "$RESET" \
      "$FG_WHITE$BOLD" "Folder SetUp" "$RESET" \
      "$FG_SILVER" "- Folder Structure Creation " "$RESET"
    printf "%b%2s%b %b%-22s%b %b%s%b\n" \
      "$FG_TEAL$BOLD" "[2]" "$RESET" \
      "$FG_WHITE$BOLD" "FASTQ quality control" "$RESET" \
      "$FG_SILVER" "- Inspect quality, adapters, summary" "$RESET"

    printf "%b%2s%b %b%-22s%b %b%s%b\n" \
      "$FG_TEAL$BOLD" "[3]" "$RESET" \
      "$FG_WHITE$BOLD" "Trimmomatic " "$RESET" \
      "$FG_SILVER" "- Improve you data quality using Trimmomatic Tool " "$RESET"

    printf "%b%2s%b %b%-22s%b %b%s%b\n" \
      "$FG_TEAL$BOLD" "[4]" "$RESET" \
      "$FG_WHITE$BOLD" "MultiQc" "$RESET" \
      "$FG_SILVER" "- Run the MultiQc Programm to visualize your data quality" "$RESET"

    echo
    line
    echo
    read -rp "$(printf '%b%s%b ' "$FG_SILVER" "Enter choice (1/2/3/4 or q)" "$RESET")" choice

    case "$choice" in
    1)
      folderCreation
      ;;
    2)
      fastQc
      ;;
    3)
      echo "Trimmomatic module."
      ft_trimmomatic
      ;;
    4)
      echo "MultiQc module"
      multiQc
      ;;
    q | quit | exit)
      clear
      exit 0
      ;;
    *)
      echo "Invalid choice."
      sleep 1
      ;;
    esac
  done
}

menu
