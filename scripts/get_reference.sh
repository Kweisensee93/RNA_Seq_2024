#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=get_reference
#SBATCH --output=../logfiles/reference_%J.out   # Standard output
#SBATCH --error=../logfiles/reference_%J.err    # Standard error
#SBATCH --partition=pibu_el8

# Define variables
WORKDIR="/data/users/kweisensee/RNA_Seq"

# the wget is pre-installed on the cluster
# download the reference genome
wget -P "${WORKDIR}/reference" ftp://ftp.ensembl.org/pub/release-113/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
# download the checksum to confirm proper download (see script checksum.sh)
wget -O "${WORKDIR}/reference/CHECKSUM.txt" ftp://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/CHECKSUMS

# the reference genome used was under:
# https://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/
# as the file:
# Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
# the newest one can be downloaded as
# ftp://ftp.ensembl.org/pub/current_fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz