#!/bin/bash -l
# DESCRIPTION
#   Script used for the generation of statistics and file management of amplicon-sequencing
# Authors
#   Mathias Eskildsen (mk20aj@bio.aau.dk)
#   Patrick Skov Schaksen (insert mail)
#
#   license GNU General Public License
#
# TO DO
#
# Create nanoplot for all barcodes/samples
# Add selection for number of threads. 
# Make use of only one conda environment
# Change default values to match "standard setup"
### DESCRIPTION -------------------------------------------------------------------------
# Default values
#project_dir="/user_data/mhe/Pipeline_test_data" ## Define the folder where your outputs should be stored
#input_fastq="/user_data/mhe/Pipeline_test_data/fastq" ## Define the path containing fastq_pass files. Example: /user_data/mhe/20231027_FAX40979_NFA_VCK/20231027_FAX40979_NFA_VCK/20231027_1305_X3_FAX40979_7b7ec697/fastq_pass
#threads=1
#JobNr=1
# Usage message
USAGE="
-- insert full pipeline name: Nanopore Statistics with NanoPlot
usage: $(basename "$0" .sh) [-h] [-o path] [-i path] [-t value]

where:
    -h Show this help message.
    -o Path where directories and files should be stored
    -i Full path to .fastq.gz files from Nanopore, example: /Full/Path/to/nanopore_data/ONT_RUN_ID/fastq_pass  
    -j Number of parallel jobs [default = 1]
    -t Number of threads [default = 1]
"
# Process command-line options
while getopts 'o:i:t:j:h' OPTION; do
    case $OPTION in
        h) echo "$USAGE"; exit 1;;
        o) project_dir=$OPTARG;;
        i) input_fastq=$OPTARG;;
        j) JobNr=$OPTARG;;
        t) threads=$OPTARG;;
        :) printf "Missing argument for option -$OPTARG\n" >&2; exit 1;;
        \?) printf "Invalid option -$OPTARG\n" >&2; exit 1;;
    esac
done

# Check missing arguments
MISSING="is missing but required. Exiting."
if [ "$project_dir" = "/user_data/mhe/Pipeline_test_data" ]; then
    echo "-o $MISSING"
    echo "$USAGE"
    exit 1
fi

if [ "$input_fastq" = "/user_data/mhe/Pipeline_test_data/fastq" ]; then
    echo "-i $MISSING"
    echo "$USAGE"
    exit 1
fi

if [ -z "$JobNr" ]; then
    JobNr=1
    echo "No value given, using default=1"
fi

if [ "$threads" -eq 1 ]; then
    threads=1
    echo "No value given, using default=1"
fi


echo "project_dir: $project_dir"
echo "input_fastq: $input_fastq"
echo "JobNr": $JobNr
echo "Treads: $threads"

#Create directories 
mkdir -p $project_dir
mkdir -p $project_dir/0_stats
mkdir -p $project_dir/1_raw


#¤ Move unzip and concatenate passed .fastq reads
## Move unzip
### Input files. Directory path leading to passed fastq.gz files
input=$input_fastq
output="$project_dir/1_raw"


files=($(find "$input" -type f -name "*.gz"))
for file in "${files[@]}"; do
##Extract subdirectory name
subdirectory_name=$(basename "$(dirname "$file")")
# Create the output directory based on the subdirectory name
    output_dir="${output}/${subdirectory_name}"
    mkdir -p "$output_dir"
    # Extract the filename without the .gz extension
    filename="${file%.gz}"
    echo "moving and unzipping $(basename "$file")"
    gunzip -c "$file" > "$output_dir/$(basename "$filename")"
done

#Remove directory containing unclassified reads
echo "Removing unclassified reads from $output"
rm -r "${output}/unclassified"
echo "Finished moving and unzipping"

## Concatenate .fastq files
# Directory containing subdirectories with .fastq files
base_dir="$project_dir/1_raw"

# Iterate over each subdirectory
for sub_dir in "$base_dir"/*; do
    if [ -d "$sub_dir" ]; then
        sub_dir_name=$(basename "$sub_dir")
        echo "Processing files in: $sub_dir_name"
        cat "${sub_dir}"/*.fastq > "${sub_dir}/${sub_dir_name}_concatenated.fastq"
        echo "Concatenated fastq files in $sub_dir_name"
    fi
done
# Finished unzipping, moving and concatenating passed .fastq files


# Start of statistics workflow 
eval "$(conda shell.bash hook)"

conda activate /shared_software/conda/envs/mk20aj@bio.aau.dk/OTUtable

input="$project_dir/1_raw"
output="$project_dir/0_stats"


#Create output directories for each input file in the output directory
# Use find to locate files with the pattern "_concatenated.fastq"
files=$(find "$input"/* -type f -name "*_concatenated.fastq")
for file in $files; do
    # Extract the subdirectory name from the file path
    subdirectory_name=$(basename "$file" _concatenated.fastq)
    # Construct the output directory path based on the subdirectory name
    output_dir="${output}/${subdirectory_name}"
    # Create the output directory if it doesn't exist
    echo "created directory for $subdirectory_name in $output"
    mkdir -p "$output_dir"
done

input_dir="$project_dir/1_raw"
output_dir="$project_dir/0_stats"

files=( $(ls ${input_dir}/*/*_concatenated.fastq) )
# Create function for NanoPlot
statistics() {
    local file="$1"
    local threads="$2"
    local output_dir="$3"
    
    # Extract subdirectory name
    local subdirectory_name=$(basename "$(dirname "$file")")
    
    # Create output directory within the specified output_dir
    local output="$output_dir/$subdirectory_name"
    
    echo "Creating plots and stats for $subdirectory_name in $output"
    # Debug statement to print the actual file being processed
    echo "Processing file: $file"

    NanoPlot --fastq_rich "$file" --plots dot -t "$threads" -o "$output"
    
    echo "Finished plots and stats for $subdirectory_name"
}

export -f statistics

module load parallel/20220722-GCCcore-11.3.0
parallel -j "$JobNr" statistics ::: "${files[@]}" ::: "$threads" ::: "$output_dir" 
module purge


echo "Check your amplicon size and quality before setting parameters for chopper filtering, used in the next script"



#### TEST SHIT - KEEP IT AT BOTTOM
