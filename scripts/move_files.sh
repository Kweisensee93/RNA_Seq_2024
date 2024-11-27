#!/bin/bash
#SBATCH --time=00:20:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=moving_files
#SBATCH --output=../logfiles/moving_%J.out   # Standard output
#SBATCH --error=../logfiles/moving_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# .bam files are rather big so this script may be used to safe the login node
# same goes for indexed reference genome

FIRST_FOLDER=$1
SECOND_FOLDER=$2

for file in ${FIRST_FOLDER}/*; do
    cp "$file" ${SECOND_FOLDER}
done

#check the md5sums before removing files:
cd /data/users/kweisensee/RNA_Seq/logfiles
touch md5sum.txt

for file in ${FIRST_FOLDER}/*; do
    md5sum  "${file}" >> md5sum.txt
done

for file in ${SECOND_FOLDER}/*; do
    md5sum  "${file}" >> md5sum.txt
done

# Since we should have the same files twice we split the md5sum.txt in half
# We only take the md5sum part with awk to get rid of the filepath from md5sum command
# The actual output of diff is put into the void of /dev/null
if diff <(awk '{print $1}' md5sum.txt | head -n $(($(wc -l < md5sum.txt) / 2))) \
       <(awk '{print $1}' md5sum.txt | tail -n $(($(wc -l < md5sum.txt) / 2))) > /dev/null; then
    echo "MD5sums are equal --> you can safely remove files" >> md5sum.txt
else
    echo "MD5sums differ --> check the files" >> md5sum.txt
fi
