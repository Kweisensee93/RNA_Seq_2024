#!/bin/bash
#SBATCH --time=00:30:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=multi_qc
#SBATCH --output=../logfiles/Multi_QC_%J.out   # Standard output
#SBATCH --error=../logfiles/Multi_QC_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# if singularity/apptainer is not working (N.B.: It is another version!):
#module load MultiQC/1.11-foss-2021a

# Define variables
OUTDIR="/data/users/kweisensee/RNA_Seq/output/fastqc_3"

MULTI_QC_IMAGE="/containers/apptainer/multiqc-1.19.sif"

# take the QC reports from quality_control.sh and create a MultiQC report
apptainer exec --bind /data ${MULTI_QC_IMAGE} multiqc "${OUTDIR}" -o "${OUTDIR}"
