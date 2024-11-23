#!/bin/bash
#SBATCH --time=00:01:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=permission_test
#SBATCH --output=../logfiles/permission_test_%J.out   # Standard output
#SBATCH --error=../logfiles/permission_test_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# check for permissions in a folder where a script raised errors
# alter to needed repository
touch /data/users/kweisensee/RNA_Seq/logfiles/testfile
