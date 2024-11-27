#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=01:15:00
#SBATCH --mem=4g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=indexing
#SBATCH --output=../logfiles/indexing_%J_%a.out   # Standard output
#SBATCH --error=../logfiles/indexing_%J_%a.err    # Standard error
#SBATCH --partition=pibu_el8

# Define paths and variables
SAMTOOLS_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"
WORKDIR="/data/users/kweisensee/RNA_Seq"
SORTED_BAM_DIR="${WORKDIR}/output/sorting"
OUTDIR="${WORKDIR}/output/indexing"
SAMPLELIST="${WORKDIR}/output/samplelist.tsv"

# Get sample names
SAMPLE=$(awk -v line=${SLURM_ARRAY_TASK_ID} 'NR==line{print $1; exit}' ${SAMPLELIST})

# Define input and output files
SORTED_BAM="${SORTED_BAM_DIR}/${SAMPLE}_sorted.bam"
INDEX_FILE="${OUTDIR}/${SAMPLE}_sorted.bam.bai"

# Run Samtools index
apptainer exec --bind /data ${SAMTOOLS_IMAGE} samtools index \
    -o  ${INDEX_FILE} \
    ${SORTED_BAM}
