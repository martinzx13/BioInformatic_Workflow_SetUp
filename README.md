# BioInformatic_Workflow_SetUp
This will contain a basic 3 scripts to set up your files structure to proceed with any bioinformatic analisys.

# Introduction.

There is a set of scripts that will perform a set up
of your desktop for genomic data analysis.

## Project structure.

```
<project_name>/
|
├── 📄 a_good_name.sh # This will be our main script for the project
│
├── 📂 data/
│   ├── 📂 raw/             # Raw, unprocessed data (e.g., FASTQ files)
│   ├── 📂 processed/       # Data that has been cleaned or filtered
│   └── 📂 reference/       # Reference genomes, annotations, etc.
│
├── 📂 results/
│   ├── 📂 figures/         # Plots, charts, and other visualizations
│   ├── 📂 tables/          # Tab-separated files, CSVs, etc.
│   └── 📂 logs/            # Log files from various analyses
│
├── 📂 scripts/           # All the scripts for the project
│   ├── 📂 main_scripts/    # Main analysis scripts
│   └── 📂 utils/           # Utility or helper scripts
│
└── 📄 README.md           # A detailed description of the project
```

# Usage.

First clone your repo.


move your data to the data folder.

execute the scripts in the order mention.


# Script description.

## Script 1.
This script will write some directories for structure for
data analysis in your area ex

your_area/structure.


## Script 2.

After this we will need to be able to do the following.
Process your pair end fastq samples (assume a large number greater than 100) with in a reproductible and portable way to other datasets with minimal changes.

We assumed that we need to rerun samples to improve the parameters

This will record all the steps in a log file for further analysis. 

