#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=14:30:00
#SBATCH --mem=8g
#SBATCH --cpus-per-task=4
#SBATCH --job-name=mapping
#SBATCH --output=../logfiles/mapping_%J_%a.out   # Standard output
#SBATCH --error=../output/mapping_%J_%a.err    # Standard error
#SBATCH --partition=pibu_el8

HISAT2_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"
SAMTOOLS_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"

WORKDIR="/data/users/kweisensee/RNA_Seq"
INDEXING="${WORKDIR}/output/indexing"
OUTDIR="${WORKDIR}/output/mapping"
SAMPLELIST="$WORKDIR/output/samplelist.tsv"

SAMPLE=$(awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST)
READ1=${SAMPLE}_fastp_R1.fastq.gz
READ2=${SAMPLE}_fastp_R2.fastq.gz

apptainer exec --bind /data ${HISAT2_IMAGE} hisat2 \
    -p 16 \
    -x ${INDEXING}/GRCh38_index \
    -1 ${WORKDIR}/output/fastp/${READ1} \
    -2 ${WORKDIR}/output/fastp/${READ2} \
    -S ${OUTDIR}/${SAMPLE}_aligned.sam

sleep 30s

apptainer exec --bind /data ${SAMTOOLS_IMAGE} samtools view \
    -S \
    -b ${OUTDIR}/${SAMPLE}_aligned.sam > ${OUTDIR}/${SAMPLE}_aligned.bam

sleep 30s

rm ${OUTDIR}/*_aligned.sam
