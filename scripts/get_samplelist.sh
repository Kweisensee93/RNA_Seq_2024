#!/bin/bash
#SBATCH --time=00:01:00
#SBATCH --mem=500M
#SBATCH --cpus-per-task=1
#SBATCH --job-name=get_samplelist

# Redirect output and error to the parent directory's 'output' folder
#SBATCH --output=../output/%x-%j.out   # Standard output
#SBATCH --error=../output/%x-%j.err    # Standard error

# recommended partition is pibu_el8, stick with it if not needed otherwise
#SBATCH --partition=pibu_el8

FASTQ_FOLDER=$1

for FILE in $FASTQ_FOLDER/*_*1.fastq.gz
do 
    PREFIX="${FILE%_*.fastq.gz}"
    SAMPLE=`basename $PREFIX`
    echo -e "${SAMPLE}\t$FILE\t${FILE%?.fastq.gz}2.fastq.gz" 
done
