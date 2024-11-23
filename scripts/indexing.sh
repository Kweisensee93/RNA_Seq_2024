#!/bin/bash
#SBATCH --time=04:00:00
#SBATCH --mem=8g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=indexing
#SBATCH --output=../logfiles/indexing_%J.out   # Standard output
#SBATCH --error=../logfiles/indexing_%J.err    # Standard error
#SBATCH --partition=pibu_el8

HISAT2_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"

WORKDIR="/data/users/kweisensee/RNA_Seq"
OUTDIR="${WORKDIR}/output/indexing"

# Unzip reference genome for further processing, if not already present
if [ ! -f ${WORKDIR}/reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa ]; then
    gunzip -c ${WORKDIR}/reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz > \
        ${WORKDIR}/reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa
fi

# bind to correct path if rerunning the script
# this indexes the human reference genome with hisat2
apptainer exec --bind /data ${HISAT2_IMAGE} hisat2-build \
    -p 16 \
    ${WORKDIR}/reference/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
    ${OUTDIR}/GRCh38_index \
    > ${OUTDIR}/indexing.log 2>&1
