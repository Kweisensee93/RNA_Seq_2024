#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=get_reference_gtf
#SBATCH --output=../logfiles/reference_gtf_%J.out   # Standard output
#SBATCH --error=../logfiles/reference_gtf_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# Define variables
WORKDIR="/data/users/kweisensee/RNA_Seq"

# the wget is pre-installed on the cluster
# download the reference genome
wget -P "${WORKDIR}/reference" ftp://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.chr.gtf.gz
# download the checksum to confirm proper download (see script checksum.sh)
#wget -O "${WORKDIR}/reference/CHECKSUM_gtf.txt" ftp://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/CHECKSUMS
