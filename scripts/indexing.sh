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
SAMPLELIST="${WORKDIR}/output/samplelist.tsv"

# Check if sample list exists
if [[ ! -f ${SAMPLELIST} ]]; then
    echo "Sample list file not found: ${SAMPLELIST}"
    exit 1
fi

# Get sample name for this task
SAMPLE=$(awk -v line=${SLURM_ARRAY_TASK_ID} 'NR==line{print $1; exit}' ${SAMPLELIST})

# Check if sample is valid
if [[ -z ${SAMPLE} ]]; then
    echo "No sample found for SLURM_ARRAY_TASK_ID=${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

# Define input and output files
SORTED_BAM="${SORTED_BAM_DIR}/${SAMPLE}_sorted.bam"
INDEX_FILE="${SORTED_BAM}.bai"

# Check if BAM file exists
if [[ ! -f ${SORTED_BAM} ]]; then
    echo "Sorted BAM file not found: ${SORTED_BAM}"
    exit 1
fi

# Run Samtools index
apptainer exec --bind /data ${SAMTOOLS_IMAGE} samtools index ${SORTED_BAM} ${INDEX_FILE}

# Verify that the index file was created
if [[ -f ${INDEX_FILE} ]]; then
    echo "Indexing completed successfully for ${SORTED_BAM}"
else
    echo "Indexing failed for ${SORTED_BAM}"
    exit 1
fi
