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

# Scripts usage on cluster
These are according to the provided procedure
Quality checking        quality_control.sh (after fastp quality_control_2.sh may be used, but only minor adjustments are done)
data trimming           fastp.sh
get reference genome    get_reference.sh
check reference         checksum.sh
indexing                indexing_reference.sh
mapping                 mapping.sh
sam to bam              already withing mapping.sh
sort bam files          sorting.sh
index sorted bam        indexing.sh
feature counts          feature_counts.sh
