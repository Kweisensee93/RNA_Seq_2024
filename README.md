# RNA_Seq_2024
The scripts used for analysis on the cluster are stored within the folder "scripts". The R-script for a local work and its corresponding R session are saved seperately.

The folder structure on the cluster is not represented on Github.
For a better understanding of the scripts the folders are listed below

# Stores .err and .out of all scripts
logfiles/
# Data handled by scripts are directed to this repository
output/
output/fastp        reads after cleaning
output/fastqc_1     fastQC on raw-reads
output/fastqc_2     fastQC after fastp clean-up
# Rawdaty provided for this course (derived from the paper)
rawdata/
# Human reference genome and its checksum
reference/
# Scripts used for the RNASeq course 2024
scripts/
