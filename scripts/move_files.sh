#!/bin/bash
#SBATCH --time=00:20:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=moving_files
#SBATCH --output=../logfiles/moving_%J.out   # Standard output
#SBATCH --error=../logfiles/moving_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# .bam files are rather big so this script may be used to safe the login node

for file in /data/users/kweisensee/RNA_Seq/scripts/*.bam; do
    cp "$file" /data/users/kweisensee/RNA_Seq/output/mapping
done