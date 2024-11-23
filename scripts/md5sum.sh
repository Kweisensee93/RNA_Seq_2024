#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=md5sum
#SBATCH --output=../logfiles/md5sum_%J.out   # Standard output
#SBATCH --error=../logfiles/md5sum_%J.err    # Standard error
#SBATCH --partition=pibu_el8

cd /data/users/kweisensee/RNA_Seq/scripts/
touch md5sum.txt

for file in /data/users/kweisensee/RNA_Seq/scripts/*.bam; do
    md5sum  "${file}" >> md5sum.txt
done

for file in /data/users/kweisensee/RNA_Seq/output/mapping/*.bam; do
    md5sum  "${file}" >> md5sum.txt
done
