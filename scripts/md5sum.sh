#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=md5sum
#SBATCH --output=../logfiles/md5sum_%J.out   # Standard output
#SBATCH --error=../logfiles/md5sum_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# in a first run the mapping .bam files were created in the scripts folder.
# this script should be used after copying (to output/mapping) and before removing the .bam files.
# it creates md5sums for all files in the scripts and the output/mapping subfolders

cd /data/users/kweisensee/RNA_Seq/scripts/
touch md5sum.txt

for file in /data/users/kweisensee/RNA_Seq/scripts/*.bam; do
    md5sum  "${file}" >> md5sum.txt
done

for file in /data/users/kweisensee/RNA_Seq/output/mapping/*.bam; do
    md5sum  "${file}" >> md5sum.txt
done
