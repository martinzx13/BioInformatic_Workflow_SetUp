# BioInformatic Workflow SetUp

A collection of scripts to bootstrap a bioinformatics project structure and run a typical upstream analysis workflow, including quality control, trimming, and reporting.

## Dependencies and Installation

This workflow relies on several common bioinformatics tools. It is highly recommended to manage them using Conda and the Bioconda channel.

1.  **Conda**: If you don't have Conda, install [Miniconda](https://docs.conda.io/en/latest/miniconda.html). After installation, initialize your shell:
    ```bash
    conda init
    ```
    Then, close and reopen your terminal.

2.  **Required Tools (FastQC, Trimmomatic, MultiQC)**: The easiest way to install these is by creating a dedicated Conda environment.

    First, configure Conda to use the necessary channels (the order is important):
    ```bash
    conda config --add channels defaults
    conda config --add channels bioconda
    conda config --add channels conda-forge
    ```

    Now, create an environment and install the tools:
    ```bash
    # This command creates a new environment named "bio_env" and installs the tools into it
    conda create -n bio_env fastqc trimmomatic multiqc

    # Activate the environment before running any scripts
    conda activate bio_env
    ```
    **Note:** Remember to activate this environment (`conda activate bio_env`) in your terminal before running the workflow scripts.

## Project Structure

The scripts assume and will create a project structure like this:

```
<project_name>/
|
├── data/
│   ├── raw/             # Raw, unprocessed data (e.g., FASTQ files)
│   └── processed/       # Data that has been cleaned or filtered
│
├── results/
│   ├── figures/         # Plots, charts, and other visualizations
│   ├── tables/          # Tab-separated files, CSVs, etc.
│   └── logs/            # Log files from various analyses
│
└── scripts/
    ├── create_test_data.sh
    ├── fastQc.sh
    └── trimmomatic.sh
```

## Scripts and Usage

### 1. `create_test_data.sh` - Generate Dummy Data

This script generates dummy paired-end FASTQ files (`.fastq.gz`) for testing the workflow.

**Usage:**

Run the script by providing a path to a directory where the test data should be created. This directory will typically be the `data/raw` folder within your project.

```bash
# Example: Create test data in a project named "my_ngs_project"
bash scripts/create_test_data.sh my_ngs_project/data/raw
```

This will create 10 pairs of gzipped FASTQ files (e.g., `sample1_R1.fastq.gz`, `sample1_R2.fastq.gz`, etc.).

### 2. `fastQc.sh` - Raw Data Quality Control

This script runs [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) on all FASTQ files found in the `data/raw` directory to assess their quality.

**Usage:**

The script will prompt you for the path to your project directory.

```bash
bash scripts/fastQc.sh
```

Upon running, it will ask: `Please enter the path to the project created previously :`. Enter the path to your main project folder (e.g., `my_ngs_project`).

-   **Input**: Reads all files from `<project_path>/data/raw`.
-   **Output**: FastQC reports are saved in `<project_path>/results/figures/fastqc_reports`.
-   **Log**: A log file is created in `<project_path>/results/logs`.

### 3. `trimmomatic.sh` - Adapter and Quality Trimming

This script uses [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) to remove adapters and low-quality bases from the raw paired-end reads.

**Usage:**

Like the FastQC script, this script will prompt you for your project directory name.

```bash
bash scripts/trimmomatic.sh
```

When prompted (`Please enter the name of the project directory:`), provide the path to your project.

-   **Input**: Reads `*_R1*.fastq.gz` files from `<project_path>/data/raw`. It automatically finds the corresponding `_R2` files.
-   **Output**: Trimmed FASTQ files are saved in `<project_path>/data/processed/trimmomatic_output`. It produces files for both paired and unpaired reads.
-   **Log**: A detailed log file is created in `<project_path>/results/logs`.
-   **Adapters**: The script is configured to skip adapter trimming by default. To perform adapter trimming, you must edit the `trimmomatic.sh` script and set the `TRIMMOMATIC_ADAPTER_FILE` variable to the path of your adapter sequences FASTA file.

### 4. Running MultiQC (Manual Step)

After running FastQC and Trimmomatic, you can use [MultiQC](https://multiqc.info/) to aggregate the logs and reports from all samples into a single, comprehensive HTML report.

**Usage:**

Navigate to your project's `results` directory and run `multiqc` on it.

```bash
# First, change into your project's results directory
cd my_ngs_project/results

# Run multiqc on the current directory
multiqc .
```

This will scan the directory for analysis logs (from FastQC, Trimmomatic, etc.) and create a `multiqc_report.html` file in the same directory. Open this file in a web browser to view the aggregated results.