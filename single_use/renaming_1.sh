#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --mem=500M
#SBATCH --cpus-per-task=1
#SBATCH --job-name=renaming
#SBATCH --output=../logfiles/renaming_%J.out   # Standard output
#SBATCH --error=../logfiles/renaming_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# pass the directory with files to change as first argument
DIRECTORY_CHANGE=$1

# I did a copy paste error resulting in a double _ instead of one

for file in "${DIRECTORY_CHANGE}"/*; do
  # Check if the file contains a double underscore
  if [[ "${file}" == *"__"* ]]; then
    # Generate the new filename by replacing "__" with "_"
    new_file=$(echo "${file}" | sed 's/__/_/g')
    
    # Rename the file
    mv "${file}" "${new_file}"
  fi
done