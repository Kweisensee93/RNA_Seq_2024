#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=14:30:00
#SBATCH --mem=8g
#SBATCH --cpus-per-task=4
#SBATCH --job-name=mapping
#SBATCH --output=../logfiles/mapping_%J_%a.out   # Standard output
#SBATCH --error=../output/mapping/mapping_%J_%a.err    # Standard error
#SBATCH --partition=pibu_el8

#adapt array-size as needed!

# get links for the images of Hisat2 and samtools
HISAT2_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"
SAMTOOLS_IMAGE="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"

# define variables
WORKDIR="/data/users/kweisensee/RNA_Seq"
INDEXING="${WORKDIR}/output/indexing"
OUTDIR="${WORKDIR}/output/mapping"
SAMPLELIST="${WORKDIR}/output/samplelist.tsv"

# retrieve sample information; Note: the fastp-processed files have different endings,
# which are not retrieved from the samplelist file. The ending should align as in script fastp.sh
SAMPLE=$(awk -v line=${SLURM_ARRAY_TASK_ID} 'NR==line{print $1; exit}' ${SAMPLELIST})
READ1=${SAMPLE}_fastp_R1.fastq.gz
READ2=${SAMPLE}_fastp_R2.fastq.gz

# mapping of all fastp processed data to the reference genome; Note: The different index files will
# be taken up by hisat2 automatically, so the GRCh38_index is sufficient as input
apptainer exec --bind /data ${HISAT2_IMAGE} hisat2 \
    -p 16 \
    -x ${INDEXING}/GRCh38_index \
    -1 ${WORKDIR}/output/fastp_mapping/${READ1} \
    -2 ${WORKDIR}/output/fastp_mapping/${READ2} \
    -S ${OUTDIR}/${SAMPLE}_aligned.sam

# better safe than sorry then sorrow
sleep 30s

# transfer .sam to .bam
apptainer exec --bind /data ${SAMTOOLS_IMAGE} samtools view \
    -S \
    -b ${OUTDIR}/${SAMPLE}_aligned.sam > ${OUTDIR}/${SAMPLE}_aligned.bam

# better safe than sorry then sorrow
sleep 30s

# remove unneeded .sam files
rm ${OUTDIR}/${SAMPLE}_aligned.sam
