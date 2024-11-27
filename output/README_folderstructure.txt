There are 3 fastQC folders
fastqc_1 = first run on the rawdata using module load of fastQC
fastqc_2 = run of fastQC on the cleaned data by fastp with apptainer
fastqc_3 = third run on the rawdata using apptainer (in order to stay consistent)

fastp = first run of fastp on all rawdata
fastp_repeat = mapping threw errors on HER22 and NonTNBC1, so those were repeated
fastp_mapping = softlinks to the fastp_repeat files and to the correct ones in fastp
