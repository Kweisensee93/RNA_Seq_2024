#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=md5sum_fastp
#SBATCH --output=../logfiles/md5sum_fastp_%J.out   # Standard output
#SBATCH --error=../logfiles/md5sum_fastp_%J.err    # Standard error
#SBATCH --partition=pibu_el8


# Get the current working directory passed as an argument
# sbatch checksum_fastp.sh "$(pwd)"
SCRIPT_DIR=$1

cd "${SCRIPT_DIR}/../output/"

touch md5sum_fastp.txt

# Navigate to the directory where the files are located
cd "${SCRIPT_DIR}/../output/fastp_repeat"

# # Process all .gz files in the reference directory
# for FILE in "${SCRIPT_DIR}/../output/fastp_repeat"*.gz; do

#     # go to repeat subdirectory
#     cd "${SCRIPT_DIR}/../output/fastp_repeat"

#     echo -e "Check for ${FILE} in fastp_repeat" >> md5sum_fastp.txt
#     md5sum  "${FILE}" >> ../md5sum_fastp.txt

#     # go to original subdirectory
#     cd "${SCRIPT_DIR}/../output/fastp"

#     echo -e "Check for ${FILE} in fastp (original)" >> md5sum_fastp.txt
#     md5sum  "${FILE}" >> ../md5sum_fastp.txt

# done


for FILE in "${SCRIPT_DIR}/../output/fastp_repeat/"*.gz; do
    BASENAME=$(basename "$FILE") # Extract filename

    # Navigate to fastp_repeat subdirectory and calculate checksum
    echo -e "Check for ${BASENAME} in fastp_repeat" >> md5sum_fastp.txt
    md5sum "$FILE" >> md5sum_fastp.txt

    # Navigate to fastp (original) subdirectory and calculate checksum
    ORIGINAL_FILE="${SCRIPT_DIR}/../output/fastp/${BASENAME}"
    if [[ -f "$ORIGINAL_FILE" ]]; then
        echo -e "Check for ${BASENAME} in fastp (original)" >> md5sum_fastp.txt
        md5sum "$ORIGINAL_FILE" >> md5sum_fastp.txt
    else
        echo -e "File ${BASENAME} not found in fastp (original)" >> md5sum_fastp.txt
    fi
done