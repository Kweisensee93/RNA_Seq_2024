#!/bin/bash
#SBATCH --array=1-12
#SBATCH --time=00:10:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=quality_control
#SBATCH --output=../logfiles/array_%J.out   # Standard output
#SBATCH --error=../logfiles/array_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# define variables
WORKDIR="/data/users/kweisensee/RNA_Seq"
OUTDIR="$WORKDIR/output"
SAMPLELIST="$WORKDIR/output/samplelist.tsv"

SAMPLE=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
READ1=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
READ2=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`

OUTFILE="$OUTDIR/${SAMPLE}.txt"