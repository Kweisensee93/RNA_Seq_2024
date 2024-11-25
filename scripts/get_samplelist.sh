#!/bin/bash
#SBATCH --time=00:01:00
#SBATCH --mem=500M
#SBATCH --cpus-per-task=1
#SBATCH --job-name=get_samplelist
#SBATCH --output=../output/fastp_repeat/samplelist.tsv   # Standard output
#SBATCH --error=../logfiles/%x-%j.err    # Standard error
#SBATCH --partition=pibu_el8

# first argument passed to the bashscript should be the path to the rawdata
# for this course as first argument:
# /data/users/kweisensee/RNA_Seq/rawdata/
FASTQ_FOLDER=$1

for FILE in "${FASTQ_FOLDER}"*_R1.fastq.gz
do
    FILENAME=$(basename "${FILE}")
    SAMPLENAME="${FILENAME%%_*}"
    # for fastp results add the _fastp for rawdata make sure the _fastp is removed
    echo -e "${SAMPLENAME}\t${SAMPLENAME}_fastp_R1.fastq.gz\t${SAMPLENAME}_fastp_R2.fastq.gz"
done

# the echo goes to the standard output from SBATCH: Alter repository as needed


# derived from the given get_samplelist.sh for this course:
#FASTQ_FOLDER=$1

#loop over all R1 files (the naming for R1 and R2 is the same)
#for FILE in $FASTQ_FOLDER/*_*1.fastq.gz
##do 
#     PREFIX="${FILE%_*.fastq.gz}"
#     SAMPLE=`basename $PREFIX`
#     echo -e "${SAMPLE}\t$FILE\t${FILE%?.fastq.gz}2.fastq.gz" 
# done