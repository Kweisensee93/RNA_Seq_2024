#!/bin/bash
#SBATCH --time=00:01:00
#SBATCH --mem=500M
#SBATCH --cpus-per-task=1
#SBATCH --job-name=link_rawdata
#SBATCH --output=../output/%x-%j.out   # Standard output
#SBATCH --error=../output/%x-%j.err    # Standard error
#SBATCH --partition=pibu_el8

# this links the rawdata for the breastcancer study
ln -s /data/courses/rnaseq_course/breastcancer_de/reads/* /data/users/kweisensee/RNA_Seq/rawdata/
