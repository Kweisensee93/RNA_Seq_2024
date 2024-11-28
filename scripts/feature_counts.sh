#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=13:15:00
#SBATCH --mem=20g # 4CPUs * 4G + 4G for safety
#SBATCH --cpus-per-task=4
#SBATCH --job-name=feature_count
#SBATCH --output=../logfiles/feature_count_%J_%a.out   # Standard output
#SBATCH --error=../logfiles/feature_count_%J_%a.err    # Standard error
#SBATCH --partition=pibu_el8


FEATURECOUNT_IMAGE="/containers/apptainer/subread_2.0.1--hed695b0_0.sif"

# define variables
WORKDIR="/data/users/kweisensee/RNA_Seq"
MAPPING="${WORKDIR}/output/indexing"
OUTDIR="${WORKDIR}/output/feature_count"
SAMPLELIST="${WORKDIR}/output/samplelist.tsv"

# get sample names
SAMPLE=$(awk -v line=${SLURM_ARRAY_TASK_ID} 'NR==line{print $1; exit}' ${SAMPLELIST})

# get samples
INPUT_BAM="${MAPPING}/${SAMPLE}_sorted.bam"
OUTPUT_COUNTS="${OUTDIR}/${SAMPLE}_counts.txt"

apptainer exec --bind /data "${FEATURECOUNT_IMAGE}" featureCounts \
    -T 4 \
    -t exon \
    -g gene_id \
    -a "/data/users/kweisensee/RNA_Seq/reference/Homo_sapiens.GRCh38.113.gtf.gz" \
    -o "${OUTPUT_COUNTS}" \
    "${INPUT_BAM}"
