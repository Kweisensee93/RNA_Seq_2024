#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=00:30:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=quality_control
#SBATCH --output=../logfiles/QC_%J.out   # Standard output
#SBATCH --error=../logfiles/QC_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# if and only if singularity/apptainer is not working (N.B.: It is another version!):
# module load FastQC/0.11.9-Java-11

FASTQC_IMAGE="/containers/apptainer/fastqc-0.12.1.sif"

# Define variables
WORKDIR="/data/users/kweisensee/RNA_Seq"
OUTDIR="${WORKDIR}/output/fastqc_3"
SAMPLELIST="$WORKDIR/output/samplelist.tsv"

# Extract sample information
# adapt if needed!
SAMPLE=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST)
READ1=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST)
READ2=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST)

# run with module:
#fastqc -o "$OUTDIR" -f fastq "${WORKDIR}/rawdata/${READ1}" "${WORKDIR}/rawdata/${READ2}"

# Run FastQC inside Singularity
# change folders as needed!
apptainer exec --bind /data ${FASTQC_IMAGE} fastqc \
    -o "$OUTDIR" \
    -f fastq "${WORKDIR}/rawdata/${READ1}" \
    "${WORKDIR}/rawdata/${READ2}"
