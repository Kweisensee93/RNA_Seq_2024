#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=fastp_single
#SBATCH --output=../logfiles/fastp_single_%J.out   # Standard output
#SBATCH --error=../logfiles/fastp_single_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# Define variables
WORKDIR="/data/users/kweisensee/RNA_Seq"
OUTDIR="${WORKDIR}/output/fastp_repeat"

SAMPLE=$1
READ1="${SAMPLE}_R1.fastq.gz"
READ2="${SAMPLE}_R2.fastq.gz"

#for the analysis fastp version 0.23.2 was used
FASTP_IMAGE="/containers/apptainer/fastp_0.23.2--h5f740d0_3.sif"

# load the fastp module
# bind your specific folder for rerun; _fastp is added for distinction to rawrfiles
apptainer exec --bind /data ${FASTP_IMAGE} fastp \
    --dont_overwrite \
    -h "${OUTDIR}/${SAMPLE}_fastp.html" \
    -j "${OUTDIR}/${SAMPLE}_fastp.json" \
    --detect_adapter_for_pe \
    -i "${WORKDIR}/rawdata/${READ1}" \
    -I "${WORKDIR}/rawdata/${READ2}" \
    -o "${OUTDIR}/${SAMPLE}_fastp_R1.fastq.gz" \
    -O "${OUTDIR}/${SAMPLE}_fastp_R2.fastq.gz"