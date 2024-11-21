#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=github
#SBATCH --output=../logfiles/github_%J.out   # Standard output
#SBATCH --error=../logfiles/github_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# Get the current working directory passed as an argument
# sbatch git_add_commit_push.sh "$(pwd)"
SCRIPT_DIR=$1

# Get the commit message
COMMIT_MESSAGE=$2

# go to the parent directory where the .git is
cd "${SCRIPT_DIR}/.."

git add .
sleep 10s
git commit -m "${COMMIT_MESSAGE}"
sleep 10s
git push
sleep 10s