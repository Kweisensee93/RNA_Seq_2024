#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=02:15:00  # 2 hours was quite close
#SBATCH --mem=20g # 4CPUs * 4G + 4G for safety
#SBATCH --cpus-per-task=4
#SBATCH --job-name=sorting
#SBATCH --output=../logfiles/sorting_%J_%a.out   # Standard output
#SBATCH --error=../logfiles/sorting_%J_%a.err    # Standard error
#SBATCH --partition=pibu_el8


# get links for the image of samtools
SAMTOOLS_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"

# define variables
WORKDIR="/data/users/kweisensee/RNA_Seq"
MAPPING="${WORKDIR}/output/mapping"
OUTDIR="${WORKDIR}/output/sorting"
SAMPLELIST="${WORKDIR}/output/samplelist.tsv"

# get sample names
SAMPLE=$(awk -v line=${SLURM_ARRAY_TASK_ID} 'NR==line{print $1; exit}' ${SAMPLELIST})

#samtools sort -o sorted_file.bam input_file.bam
# -@ [Number of GPU] -m [memory per thread] -o [output]
apptainer exec --bind /data ${SAMTOOLS_IMAGE} samtools sort \
    -@ 4 \
    -m 4G \
    -o ${OUTDIR}/${SAMPLE}_sorted.bam \
    ${MAPPING}/${SAMPLE}_aligned.bam
