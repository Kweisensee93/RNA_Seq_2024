#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=00:10:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=quality_control
#SBATCH --output=../logfiles/QC_%J.out   # Standard output
#SBATCH --error=../logfiles/QC_%J.err    # Standard error
#SBATCH --partition=pibu_el8


# Load FastQC module from specified path
#module add UHTS/Quality_control/fastqc/0.12.1

FASTQC_IMAGE="/containers/apptainer/fastqc-0.12.1.sif"

# Define variables
WORKDIR="/data/users/kweisensee/RNA_Seq"
OUTDIR="${WORKDIR}/logfiles"
SAMPLELIST="$WORKDIR/output/samplelist.tsv"

# Extract sample information
SAMPLE=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST)
READ1=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST)
READ2=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST)

# Run FastQC on the sample's reads
#fastqc -o "$OUTDIR" -f fastq "$READ1" "$READ2"

# Run FastQC inside Singularity
singularity exec "$FASTQC_IMAGE" fastqc -o "$OUTDIR" -f fastq "$READ1" "$READ2"