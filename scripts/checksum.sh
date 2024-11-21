#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=checksum
#SBATCH --output=../logfiles/checksum_%J.out   # Standard output
#SBATCH --error=../logfiles/checksum_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# give the path to the file as first argument:

#FILE_CHECKED=$1

#md5sum "${FILE_CHECKED}" > "${FILE_CHECKED}_md5sum.txt"

# Get the current working directory passed as an argument
# sbatch checksum.sh "$(pwd)"
SCRIPT_DIR=$1

# Navigate to the directory where the files are located
cd "${SCRIPT_DIR}/../reference"

# Process all .gz files in the reference directory
for FILE in *.gz; do
    # get the line out of the CHECKSUM for our file
    CHECKSUM_LINE=$(grep "${FILE}" CHECKSUM.txt)

    # for the CHECKSUM of ensembl the sum function is used
    FILE_SIZE=$(sum "${FILE}")
    echo -e "Your file has\n\
${FILE_SIZE}\t${FILE}\n\
The reference file has\n\
${CHECKSUM_LINE}"\
 > "${FILE}_checksum.txt"
done